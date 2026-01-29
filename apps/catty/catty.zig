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

    var argIndex: usize = 1;
    var useLineNumbers = false;
    while (argIndex < arguments.len) : (argIndex += 1) {
        const arg = arguments[argIndex];
        if (!std.mem.startsWith(u8, arg, "-")) break;

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            try printUsage();
            return;
        } else if (std.mem.eql(u8, arg, "-n")) {
            useLineNumbers = true;
        } else if (std.mem.eql(u8, arg, "--")) {
            argIndex += 1;
            break;
        } else {
            try std.io.getStdErr().writer().print("Invalid options: {s}\n\n", .{arg});
            try printUsage();
            return;
        }
    }

    if (argIndex >= arguments.len) {
        try catStdin(stdout, useLineNumbers);
        return;
    }
    while (argIndex < arguments.len) : (argIndex += 1) {
        try catSingleFile(arguments[argIndex], stdout, useLineNumbers);
    }
}

// zig run catty.zig -- ./samples/file_1.txt ./samples/file_2.txt ./samples/games.json ./samples/games.dat
// zig run catty.zig -- -n ./samples/file_1.txt ./samples/file_2.txt ./samples/games.json ./samples/games.dat
// zig run catty.zig -- -n ./samples/games.dat
fn catSingleFile(path: []const u8, stdout: anytype, useLineNumbers: bool) !void {
    var file = try fs.cwd().openFile(path, .{});
    defer file.close();
    if (useLineNumbers) {
        try copyRawContentWithLineNumbers(file, stdout);
    } else {
        try copyRawContent(file, stdout);
    }
}

// echo "Hello World from pipeline" | zig run .\catty.zig
// echo "Hello World from pipeline" | zig run .\catty.zig -- -n
fn catStdin(stdout: anytype, useLineNumbers: bool) !void {
    const stdin = std.io.getStdIn().reader();
    if (useLineNumbers) {
        try copyRawContentWithLineNumbers(stdin, stdout);
    } else {
        try copyRawContent(stdin, stdout);
    }
}

fn copyRawContent(reader: anytype, stdout: anytype) !void {
    var buffer: [8 * 1024]u8 = undefined;
    while (true) {
        const n = try reader.read(&buffer);
        if (n == 0) break;
        try stdout.writeAll(buffer[0..n]);
    }
}

fn copyRawContentWithLineNumbers(reader: anytype, stdout: anytype) !void {
    var buffer: [8 * 1024]u8 = undefined;

    var lineNumber: usize = 1;
    var atLineStart = true;

    while (true) {
        const n = try reader.read(&buffer);
        if (n == 0) break;

        const chunk = buffer[0..n];
        var i: usize = 0;
        while (i < chunk.len) : (i += 1) {
            if (atLineStart) {
                try stdout.print("{d}\t", .{lineNumber});
                atLineStart = false;
            }

            const currByte = chunk[i];
            try stdout.writeByte(currByte);

            if (currByte == '\n') {
                lineNumber += 1;
                atLineStart = true;
            }
        }
    }
}

fn printUsage() !void {
    try std.io.getStdOut().writer().print(
        \\Usage: catty [options] [file...]
        \\
        \\Options:
        \\  -n,         Print line numbers
        \\  -h, --help  Show this help
        \\
        \\If no file is provided, reads from stdin.
        \\
        \\Samples:
        \\catty file_1.txt file_2.json
        \\echo "hello world" | catty
        \\catty --help
    , .{});
}
