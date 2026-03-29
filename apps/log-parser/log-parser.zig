const std = @import("std");

// log dosyasındaki ERROR loglarının sayısını bulan bir uygulama.
// Tam performans için release modda çalıştırmak daha iyi olur
// zig run .\log-parser.zig -O ReleaseFast
pub fn main() !void {
    const log_file_name = try get_file_name();
    std.debug.print("Parsing log file: '{s}'\n", .{log_file_name});

    try version_0(log_file_name); // Klasik versiyon. Buffer kullanarak satır satır okuma.
    try version_1(log_file_name); // Dosyayı doğrudan belleğe yükleyip işleme. Ram'in alabildiği ölçüde avantajlı olabilir.
    try version_2(log_file_name); // Manuel chunking yaparak okuma. Büyük dosyalarda bellek kullanımını optimize eder.
    try version_3(log_file_name); // Multithreaded versiyon. Büyük dosyalarda performans artışı sağlar.
}

fn get_file_name() ![]const u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip();
    if (args.next()) |arg| {
        return arg;
    }

    return "dummy-log.txt";
}

// Multithreaded version
fn version_3(log_file_name: []const u8) !void {
    std.debug.print("\nRunning version 3: Multithreaded Processing\n", .{});
    var timer = try std.time.Timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pool: std.Thread.Pool = undefined;
    try pool.init(.{ .allocator = allocator });
    defer pool.deinit();

    var wait_group = std.Thread.WaitGroup{};
    const f = try std.fs.cwd().openFile(log_file_name, .{});
    defer f.close();

    const buffer_size = 4 * 1024 * 1024;
    var buffer: [buffer_size]u8 = undefined;
    var leftover: usize = 0;

    while (true) {
        const bytes_read = try f.read(buffer[leftover..]);
        if (bytes_read == 0) break;

        const total_bytes = leftover + bytes_read;
        var last_newline: usize = total_bytes;
        while (last_newline > 0 and buffer[last_newline - 1] != '\n') {
            last_newline -= 1;
        }

        if (last_newline == 0) return error.LineTooLongForBuffer;

        const chunk = try allocator.alloc(u8, last_newline);
        @memcpy(chunk, buffer[0..last_newline]);

        wait_group.start();
        try pool.spawn(proc_chunk, .{ chunk, allocator, &wait_group });

        leftover = total_bytes - last_newline;
        if (leftover > 0) {
            std.mem.copyForwards(u8, &buffer, buffer[last_newline..total_bytes]);
        }
    }
    pool.waitAndWork(&wait_group);

    const elapsed_ns = timer.read();
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000.0;
    std.debug.print(
        "Total lines: {d}, Error lines: {d}\n",
        .{
            global_line_count.load(.monotonic),
            global_error_count.load(.monotonic),
        },
    );
    std.debug.print("Time taken to find error logs: ({d} ms)\n", .{elapsed_ms});
}

var global_line_count = std.atomic.Value(usize).init(0);
var global_error_count = std.atomic.Value(usize).init(0);

fn proc_chunk(chunk: []u8, allocator: std.mem.Allocator, wait_group: *std.Thread.WaitGroup) void {
    defer wait_group.finish();

    defer allocator.free(chunk);

    var local_lines: usize = 0;
    var local_errors: usize = 0;
    var i: usize = 0;
    var line_start: usize = 0;

    while (i < chunk.len) : (i += 1) {
        if (chunk[i] == '\n') {
            const line = chunk[line_start..i];
            local_lines += 1;

            if (std.mem.startsWith(u8, line, "[ERROR]")) {
                local_errors += 1;
            }
            line_start = i + 1;
        }
    }

    _ = global_line_count.fetchAdd(local_lines, .monotonic);
    _ = global_error_count.fetchAdd(local_errors, .monotonic);
}

// Manuel Chunking
fn version_2(log_file_name: []const u8) !void {
    std.debug.print("\nRunning version 2: Manual Chunking\n", .{});
    var timer = try std.time.Timer.start();

    const f = try std.fs.cwd().openFile(log_file_name, .{});
    defer f.close();

    const buffer_size = 4 * 1024 * 1024;
    var buffer: [buffer_size]u8 = undefined;
    var error_count: usize = 0;
    var line_count: usize = 0;
    var leftover: usize = 0;

    while (true) {
        const bytes_read = try f.read(buffer[leftover..]);
        if (bytes_read == 0) break;

        const total_bytes = leftover + bytes_read;
        const process_slice = buffer[0..total_bytes];

        var line_start: usize = 0;
        var i: usize = 0;

        while (i < process_slice.len) : (i += 1) {
            if (process_slice[i] == '\n') {
                const line = process_slice[line_start..i];
                line_count += 1;

                if (std.mem.startsWith(u8, line, "[ERROR]")) {
                    error_count += 1;
                }

                line_start = i + 1;
            }
        }

        leftover = process_slice.len - line_start;
        if (leftover > 0) {
            std.mem.copyForwards(u8, &buffer, process_slice[line_start..]);
        }
    }

    const elapsed_ns = timer.read();
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000.0;
    std.debug.print("Total lines: {d}, Error lines: {d}\n", .{ line_count, error_count });
    std.debug.print("Time taken to find error logs: ({d} ms)\n", .{elapsed_ms});
}

// Streaming
fn version_1(log_file_name: []const u8) !void {
    std.debug.print("\nRunning version 1: Bulk Load and Stream\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var timer = try std.time.Timer.start();
    const f = try std.fs.cwd().openFile(log_file_name, .{});
    defer f.close();

    const file_size = (try f.stat()).size;

    const content = try f.readToEndAlloc(allocator, file_size); // Dosyayı tamamen belleğe yükle
    defer allocator.free(content);

    var error_count: usize = 0;
    var line_count: usize = 0;

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        line_count += 1;
        if (std.mem.startsWith(u8, line, "[ERROR]")) {
            error_count += 1;
        }
    }

    const elapsed_ns = timer.read();
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000.0;
    std.debug.print("Total lines: {d}, Error lines: {d}\n", .{ line_count, error_count });
    std.debug.print("Time taken to find error logs: ({d} ms)\n", .{elapsed_ms});
}

// Bulk Load and Stream
fn version_0(log_file_name: []const u8) !void {
    std.debug.print("\nRunning version 0: Buffered Reader\n", .{});
    var timer = try std.time.Timer.start();

    const f = try std.fs.cwd().openFile(log_file_name, .{});
    defer f.close();

    var buff_reader = std.io.bufferedReader(f.reader());
    var stream_reader = buff_reader.reader();

    var buffer: [4096]u8 = undefined;
    var error_count: usize = 0;
    var line_count: usize = 0;

    while (try stream_reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        line_count += 1;
        if (std.mem.startsWith(u8, line, "[ERROR]")) {
            error_count += 1;
        }
    }

    const elapsed_ns = timer.read();
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000.0;
    std.debug.print("Total lines: {d}, Error lines: {d}\n", .{ line_count, error_count });
    std.debug.print("Time taken to find error logs: ({d} ms)\n", .{elapsed_ms});
}
