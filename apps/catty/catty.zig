// CLONE   : Unix Cat programının hafifsiklet bir sürümü
// AMAÇLAR : Allocator kullanımını kavramak, IO hatalarını ele almak, komut satırından arguman okumak, anytype kullanmak
// YORUM   : Cat uygulaması felsefe olarak bir veya daha fazla byte'tan oluşan stream'leri tek bir byte stream içerisine almayı hedefler.
//           Verinin text, binary olması veya network hattından gelmesi ya da bir sürücü çıktısı (device output) cat uygulaması için çok
//           önemli değildir. Zira Unix felsefesi şunu öğütler; Write programs that do one thing well, Write programs to work together
const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const arguments = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, arguments);
    const stdout = std.io.getStdOut().writer();

    if (arguments.len < 2) {
        try catStdin(stdout);
    }

    var i: usize = 1;
    while (i < arguments.len) : (i += 1) {
        try catSingleFile(arguments[i], stdout);
    }
}

// zig run catty.zig -- ./samples/file_1.txt ./samples/file_2.txt ./samples/games.json ./samples/games.dat
fn catSingleFile(path: []const u8, stdout: anytype) !void {
    var file = try fs.cwd().openFile(path, .{});
    defer file.close();

    var buffer: [8 * 1024]u8 = undefined;

    while (true) {
        const n = try file.read(&buffer);
        if (n == 0) break;

        try stdout.writeAll(buffer[0..n]);
        try stdout.print("\n", .{});
    }
}

// echo "Hello World from pipeline" | zig run .\catty.zig
fn catStdin(stdout: anytype) !void {
    var stdin = std.io.getStdIn().reader();
    var buffer: [8 * 1024]u8 = undefined;

    while (true) {
        const n = try stdin.read(&buffer);
        if (n == 0) break;
        try stdout.writeAll(buffer[0..n]);
    }
}
