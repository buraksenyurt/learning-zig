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

    while (try iterator.next()) |item| {
        try stdout.print("{s} \n", .{item.name});
    }

    try stdout.print("\n", .{});
}
