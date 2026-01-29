// cat uygulamasının çok basit bir klonu.
// ve genel amaç fixed-size buffer kullanmak, IO hatalarını ele almak.
// cat uygulaması felsefe olarak bir veya daha fazla byte'tan oluşan stream'leri tek bir byte stream içerisine almayı hedefler.
// Verinin text, binary olması veya network hattından gelmesi ya da bir sürücü çıktısı (device output) cat uygulaması için çok
// önemli değildir. Zira Unix felsefesi şunu öğütler; Write programs that do one thing well, Write programs to work together
// Programı doğrudan zig dosyası ile çalıştırmak için aşağıdaki komutu kullandım(Windows 11 OS üzerinde)
// zig run catty.zig -- ./samples/file_1.txt ./samples/file_2.txt ./samples/games.json ./samples/games.dat

const std = @import("std");
const fs = std.fs;

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
    const stdout = std.io.getStdOut().writer();

    var i: usize = 1;
    while (i < arguments.len) : (i += 1) {
        try catSingleFile(arguments[i], stdout);
    }
}

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
