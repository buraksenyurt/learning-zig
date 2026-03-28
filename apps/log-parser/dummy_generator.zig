const std = @import("std");

// Bu programın amacı log-parser uygulaması için büyük boyutlu dummy-log dosyası üretmektir.
pub fn main() !void {
    const f = try std.fs.cwd().createFile("dummy-log.txt", .{});
    defer f.close();

    var buff_writer = std.io.bufferedWriter(f.writer());
    const writer = buff_writer.writer();

    const total_lines = try get_total_lines();

    for (0..total_lines) |i| {
        if (i % 100 == 0) {
            try writer.print("[ERROR] This is a dummy log line number {d}\n", .{i});
        } else {
            try writer.print("[INFO] This is a dummy log line number {d}\n", .{i});
        }
    }

    try buff_writer.flush();
    std.debug.print("Dummy log file 'dummy-log.txt' created with {d} lines.\n", .{total_lines});
}

fn get_total_lines() !usize {
    var total_lines: usize = 1_000_000;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip();
    if (args.next()) |arg| {
        total_lines = std.fmt.parseInt(usize, arg, 10) catch blk: {
            std.debug.print("Invalid line count argument: '{s}'\n", .{arg});
            break :blk 1_000_000;
        };
    }

    return total_lines;
}
