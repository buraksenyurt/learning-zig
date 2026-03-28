const std = @import("std");

// log dosyasındaki ERROR loglarının sayısını bulan bir uygulama.
// Tam performans için release modda çalıştırmak daha iyi olur
// zig run .\log-parser.zig -O ReleaseFast
pub fn main() !void {
    try version_0(); // Klasik versiyon. Buffer kullanarak satır satır okuma.
    try version_1(); // Dosyayı doğrudan belleğe yükleyip işleme. Ram'in alabildiği ölçüde avantajlı olabilir.
    try version_2(); // Manuel chunking yaparak okuma. Büyük dosyalarda bellek kullanımını optimize eder.
}

// Manuel Chunking
fn version_2() !void {
    std.debug.print("Running version 2: Manual Chunking\n", .{});
    var timer = try std.time.Timer.start();

    const f = try std.fs.cwd().openFile("dummy-log.txt", .{});
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
fn version_1() !void {
    std.debug.print("Running version 1: Bulk Load and Stream\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var timer = try std.time.Timer.start();
    const f = try std.fs.cwd().openFile("dummy-log.txt", .{});
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
fn version_0() !void {
    std.debug.print("Running version 0: Buffered Reader\n", .{});
    var timer = try std.time.Timer.start();

    const f = try std.fs.cwd().openFile("dummy-log.txt", .{});
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
