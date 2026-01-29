// CLONE   : Unix Cat programının hafifsiklet bir sürümü
// AMAÇLAR :
//          - Allocator kullanımını kavramak (OS Seviyesinde özelleştirmek),
//          - IO hatalarını ele almak,
//          - Komut satırından arguman okumak,
//          - anytype kullanmak
// YORUM   : Cat uygulaması felsefe olarak bir veya daha fazla byte'tan oluşan stream'leri tek bir byte stream içerisine almayı hedefler.
//           Verinin text, binary olması veya network hattından gelmesi ya da bir sürücü çıktısı (device output) cat uygulaması için çok
//           önemli değildir. Zira Unix felsefesi şunu öğütler; Write programs that do one thing well, Write programs to work together
const std = @import("std");
const fs = std.fs;
const builtin = @import("builtin");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    if (builtin.os.tag == .windows) {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        var iterator = try std.process.argsWithAllocator(allocator);
        defer iterator.deinit();
        const appPath = iterator.next() orelse "catty";
        const appName = std.fs.path.basename(appPath);

        try processArgs(&iterator, stdout, appName);
    } else {
        var iterator = std.process.args();
        const appPath = iterator.next() orelse "catty";
        const appName = std.fs.path.basename(appPath);

        try processArgs(&iterator, stdout, appName);
    }
}

fn processArgs(iterator: anytype, stdout: anytype, appName: []const u8) !void {
    var isErrorState: bool = false;
    const firstArg = iterator.next() orelse {
        try catStdin(stdout, false);
        return;
    };

    if (std.mem.eql(u8, firstArg, "--help") or std.mem.eql(u8, firstArg, "-h")) {
        try printUsage();
        return;
    }

    if (std.mem.eql(u8, firstArg, "-n")) {
        const path = iterator.next() orelse {
            try catStdin(stdout, true);
            return;
        };
        catSingleFile(path, stdout, true) catch |err| {
            isErrorState = true;
            try printFileError(appName, std.io.getStdErr().writer(), path, err);
        };
        while (iterator.next()) |p| {
            catSingleFile(p, stdout, true) catch |err| {
                isErrorState = true;
                try printFileError(appName, std.io.getStdErr().writer(), p, err);
            };
        }
        if (isErrorState) return std.process.exit(1);
        return;
    }

    try catSingleFile(firstArg, stdout, false);
    while (iterator.next()) |p| {
        catSingleFile(p, stdout, false) catch |err| {
            isErrorState = true;
            try printFileError(appName, std.io.getStdErr().writer(), p, err);
        };
    }
    if (isErrorState) return std.process.exit(1);
}

fn printFileError(appName: []const u8, stderr: anytype, path: []const u8, err: anyerror) !void {
    try stderr.print(
        "{s}: {s}: {s}\n",
        .{ appName, path, @errorName(err) },
    );
}

// zig run catty.zig -- ./samples/file_1.txt ./samples/file_2.txt ./samples/games.json ./samples/games.dat
// zig run catty.zig -- -n ./samples/file_1.txt ./samples/file_2.txt ./samples/games.json ./samples/games.dat
// zig run catty.zig -- -n ./samples/games.dat
// zig run catty.zig -- ./samples/games.dat ./none.txt ./samples/file_2.txt
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
