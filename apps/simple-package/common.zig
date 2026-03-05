const std = @import("std");

pub fn print(comptime text: []const u8) void {
    std.debug.print(text, .{});
}

test {
    try std.testing.expect(true);
}
