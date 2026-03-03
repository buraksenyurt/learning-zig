const std = @import("std");
const models = @import("models.zig");
fn parseVersion(versionStr: []const u8) !models.version {
    var parts = std.mem.splitSequence(
        u8,
        versionStr,
        ".",
    );
    var major: ?u8 = null;
    var minor: ?u8 = null;
    var revision: ?u16 = null;

    while (parts.next()) |part| {
        if (part.len == 0) {
            return error.InvalidVersionFormat;
        }
        if (major == null) {
            major = try std.fmt.parseInt(u8, part, 10);
        } else if (minor == null) {
            minor = try std.fmt.parseInt(u8, part, 10);
        } else if (revision == null) {
            revision = try std.fmt.parseInt(u16, part, 10);
        } else {
            return error.InvalidVersionFormat;
        }
    }

    return models.version{
        .major = major orelse 0,
        .minor = minor orelse 0,
        .revision = revision orelse 0,
    };
}

test "parseVersion parses partial versions with defaults" {
    const validVersionStr = "1.0";
    const result = try parseVersion(validVersionStr);
    try std.testing.expectEqual(@as(u8, 1), result.major);
    try std.testing.expectEqual(@as(u8, 0), result.minor);
    try std.testing.expectEqual(@as(u16, 0), result.revision);
}

test "parseVersion returns error on non-numeric input" {
    const invalidVersionStr = "1.a.3";
    try std.testing.expectError(
        error.InvalidCharacter,
        parseVersion(invalidVersionStr),
    );
}

test "parseVersion correctly parses version strings" {
    const versionStr = "1.0.3";
    const expected = models.version{
        .major = 1,
        .minor = 0,
        .revision = 3,
    };
    const result = try parseVersion(versionStr);
    try std.testing.expectEqual(expected.major, result.major);
    try std.testing.expectEqual(expected.minor, result.minor);
    try std.testing.expectEqual(expected.revision, result.revision);
}

test "parseVersion returns valid string with toString method" {
    const version = models.version{
        .major = 2,
        .minor = 5,
        .revision = 10,
    };
    var allocator = std.testing.allocator;
    const versionStr = try version.toString(allocator);
    defer allocator.free(versionStr);
    try std.testing.expectEqualStrings(versionStr, "2.5.10");
}
