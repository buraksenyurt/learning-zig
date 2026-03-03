const std = @import("std");
const models = @import("models.zig");
pub fn parseVersion(versionStr: []const u8) !models.version {
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

pub fn readFileContent(allocator: std.mem.Allocator, filePath: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(filePath, .{ .mode = .read_only });
    defer file.close();

    const fileSize = (try file.metadata()).size();
    const content = try file.readToEndAlloc(allocator, fileSize);
    return content;
}
