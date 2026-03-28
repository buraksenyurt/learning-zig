const std = @import("std");

pub fn main() !void {
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
    std.debug.print("Time taken to open file: ({d} ms)\n", .{elapsed_ms});
}
