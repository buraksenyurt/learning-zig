const std = @import("std");

pub const String = struct {
    data: []const u8,

    pub fn from(input: []const u8) String {
        return String{
            .data = input,
        };
    }

    pub fn len(self: String) usize {
        return self.data.len;
    }

    pub fn equals(self: String, other: []const u8) bool {
        return std.mem.eql(u8, self.data, other);
    }
};

test "String struct works correctly" {
    const str = String.from("Hello, Zig!");
    try std.testing.expect(str.len() == 11);
    try std.testing.expect(str.equals("Hello, Zig!"));
}
