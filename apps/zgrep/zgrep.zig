// CLONE   : grep programının hafifsiklet bir sürümü
// AMAÇLAR :
//          - Allocator kullanımını kavramak (OS Seviyesinde özelleştirmek),
//          - IO hatalarını ele almak,
//          - Komut satırından arguman okumak,
//          - anytype kullanmak
// YORUM   :

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        try printUsage();
    }
}

fn printUsage() !void {
    try std.io.getStdOut().writer().print(
        \\zgrep : A grep clone written with zig programming language
        \\
        \\Usages;
        \\zgrep <query> <file_path>
        \\
    , .{});
}
