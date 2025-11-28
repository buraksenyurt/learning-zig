//! # System Module
//! This module provides basic system-level utilities and abstractions.
//!
//! It includes definitions for common data structures such as String and Vector (vint).
//! The String struct encapsulates a byte slice and provides methods for common string operations.
//! The vint struct represents a vector of integers with size tracking and element access methods.

const std = @import("std");

/// String struct represents a simple string abstraction
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

/// vint struct represents a simple vector of integers
pub const vint = struct {
    size: u32,
    data: []const i32,

    pub fn fromArray(arr: []const i32) vint {
        return vint{
            .size = @intCast(arr.len),
            .data = arr,
        };
    }

    pub fn get(self: vint, index: u32) ?i32 {
        if (index >= self.size) return null;
        return self.data[@intCast(index)];
    }
};

test "vector struct works correctly" {
    const arr = [_]i32{ 1, 2, 3 };
    const vec = vint.fromArray(&arr);
    try std.testing.expect(vec.size == 3);
    try std.testing.expect(vec.data[0] == 1);
    try std.testing.expect(vec.data[1] == 2);
    try std.testing.expect(vec.data[2] == 3);
}

test "vector get method works correctly" {
    const arr = [_]i32{ 10, 20, 30, 40 };
    const vec = vint.fromArray(&arr);
    try std.testing.expect(vec.get(0) == 10);
    try std.testing.expect(vec.get(2) == 30);
    try std.testing.expect(vec.get(4) == null);
}
