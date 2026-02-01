// CLONE    : ls (listeleme) programının hafifsiklet bir sürümü.
// AMAÇLAR  :
//          - Klasör içeriğini okuma,
//          - Metadata verilerine erişim
//          - iterator kullanımı
// RUN      : zig run .\dir.zig -- .\some-directory
//          : zig run .\dir.zig -- -a .\some-directory
//          : zig run .\dir.zig -- -l .\some-directory
// YORUM    :

const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var showHidden: bool = false;
    var longFormat: bool = false;
    var targetFolder: []const u8 = ".";

    var index: usize = 1;
    while (index < args.len) : (index += 1) {
        const arg = args[index];
        if (std.mem.eql(u8, arg, "-a")) {
            showHidden = true;
        } else if (std.mem.eql(u8, arg, "-l")) {
            longFormat = true;
        } else {
            targetFolder = arg;
        }
    }

    var directory = try std.fs.cwd().openDir(targetFolder, .{ .iterate = true });
    defer directory.close();

    var iterator = directory.iterate();
    var fileCount: usize = 0;
    var totalFileSize: u64 = 0;

    try printRepeat(stdout, '-', 80);
    try stdout.print("\nListing of directory: {s}\n", .{targetFolder});
    try printRepeat(stdout, '-', 80);
    try stdout.print("\n", .{});

    while (try iterator.next()) |item| {
        if (!showHidden and item.name[0] == '.') continue;
        if (longFormat) {
            if (item.kind == .file) {
                const metadata = directory.statFile(item.name) catch |err| {
                    try stdout.print("ERR {s} {s}\n", .{
                        item.name,
                        @errorName(err),
                    });
                    continue;
                };
                try stdout.print("{s:<8} {d: >10} {s}\n", .{
                    "file",
                    metadata.size,
                    item.name,
                });
                fileCount += 1;
                totalFileSize += metadata.size;
            } else if (item.kind == .directory) {
                try stdout.print("{s:<17}   {s}\n", .{
                    "dir",
                    item.name,
                });
            }
        } else {
            try stdout.print("{s} \n", .{item.name});
        }
    }

    try printRepeat(stdout, '-', 80);
    try stdout.print("\n", .{});
    if (longFormat) {
        try stdout.print("{d:<5}files {d:>16} bytes\n", .{
            fileCount,
            totalFileSize,
        });
    }
}

fn printRepeat(writer: anytype, c: u8, count: usize) !void {
    var i: usize = 0;
    while (i < count) : (i += 1) {
        try writer.writeByte(c);
    }
}
