const std = @import("std");
const utility = @import("utility.zig");

pub fn main() !void {
    const introMessage =
        \\Hello pessengers of the Zig world!
        \\
        \\  Try to read my mind.
        \\
        \\  I have got a number between 1 and 10...
        \\  If you find it, you can get free ticket to pass into the Matrix.
        \\
        \\  But!!! You have only 3 chances.
        \\
        \\  What is your guess?
        \\
    ;
    std.debug.print("{s}", .{introMessage});
    const myGuess = try getRandomNumber(1, 10);
    var guess = try readUserInput();

    for (1..3) |attempt| {
        if (guess == myGuess) {
            std.debug.print("Congratulations! You guessed it right in {d} attempt(s).\n", .{attempt});
            return;
        } else if (guess < myGuess) {
            std.debug.print("Your guess is too low. Try again.\n", .{});
        } else {
            std.debug.print("Your guess is too high. Try again.\n", .{});
        }
        if (attempt < 3) {
            const newGuess = try readUserInput();
            guess = newGuess;
        }
    }

    std.debug.print("You shall not pass! The correct number was {d}.\n", .{myGuess});
}

fn readUserInput() !i32 {
    var buf: [8]u8 = undefined;
    const stdin = std.io.getStdIn().reader();

    const line = try stdin.readUntilDelimiter(&buf, '\n');
    const cleaned = std.mem.trim(u8, line, " \r\n\t");
    const value = try std.fmt.parseInt(i32, cleaned, 10);
    return value;
}

pub fn getRandomNumber(rangeStart: u8, rangeEnd: u8) !u8 {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    while (true) {
        const value = rand.int(u8);
        if (value >= rangeStart and value <= rangeEnd) return value;
    }
    return 0;
}
