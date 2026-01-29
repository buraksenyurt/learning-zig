// cat uygulamasının basit bir klonu.
// Amaç fixed-size buffer kullanmak, IO hatalarını ele almak.
// Programı bu şekilde çalıştırmak için;
// zig run catty.zig -- file_1 file_2

const std = @import("std");

pub fn main() !void {
    // Adım 1: Komut satırından gelen argümanların okunması
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const arguments = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, arguments);

    if (arguments.len < 2) {
        std.log.err("Argument error", .{});
        std.debug.print("Usage: cat <file1> [file2...]", .{});
        return;
    }
    std.debug.print("\n", .{});

    var i: usize = 1;
    while (i < arguments.len) : (i += 1) {
        std.debug.print("{s} ", .{arguments[i]});
    }
    // for (arguments) |argument| {
    //     std.debug.print("{s} ", .{argument});
    // }

    std.debug.print("\n", .{});
}
