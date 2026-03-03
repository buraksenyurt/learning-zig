const std = @import("std");
const models = @import("models.zig");
const utility = @import("utility.zig");
const parser = @import("parser.zig");

test "Protocol fromString correctly parses protocol strings" {
    const grpcStr = "gRPC";
    const httpStr = "HTTP";
    const httpsStr = "HTTPS";
    const invalidStr = "FTP";

    try std.testing.expectEqual(.Grpc, models.Protocol.fromString(grpcStr) orelse unreachable);
    try std.testing.expectEqual(.Http, models.Protocol.fromString(httpStr) orelse unreachable);
    try std.testing.expectEqual(.Https, models.Protocol.fromString(httpsStr) orelse unreachable);
    try std.testing.expectEqual(null, models.Protocol.fromString(invalidStr));
}

test "Protocol toString correctly converts enum to string" {
    try std.testing.expectEqual("gRPC", models.Protocol.Grpc.toString());
    try std.testing.expectEqual("HTTP", models.Protocol.Http.toString());
    try std.testing.expectEqual("HTTPS", models.Protocol.Https.toString());
}

test "Environment fromString correctly parses environment strings" {
    const devStr = "Development";
    const testStr = "Test";
    const prodStr = "Production";
    const invalidStr = "Staging";

    try std.testing.expectEqual(.Development, models.Environment.fromString(devStr) orelse unreachable);
    try std.testing.expectEqual(.Test, models.Environment.fromString(testStr) orelse unreachable);
    try std.testing.expectEqual(.Production, models.Environment.fromString(prodStr) orelse unreachable);
    try std.testing.expectEqual(null, models.Environment.fromString(invalidStr));
}

test "Environment toString correctly converts enum to string" {
    try std.testing.expectEqual("Development", models.Environment.Development.toString());
    try std.testing.expectEqual("Test", models.Environment.Test.toString());
    try std.testing.expectEqual("Production", models.Environment.Production.toString());
}

test "parseVersion parses partial versions with defaults" {
    const validVersionStr = "1.0";
    const result = try utility.parseVersion(validVersionStr);
    try std.testing.expectEqual(@as(u8, 1), result.major);
    try std.testing.expectEqual(@as(u8, 0), result.minor);
    try std.testing.expectEqual(@as(u16, 0), result.revision);
}

test "parseVersion returns error on non-numeric input" {
    const invalidVersionStr = "1.a.3";
    try std.testing.expectError(
        error.InvalidCharacter,
        utility.parseVersion(invalidVersionStr),
    );
}

test "parseVersion correctly parses version strings" {
    const versionStr = "1.0.3";
    const expected = models.version{
        .major = 1,
        .minor = 0,
        .revision = 3,
    };
    const result = try utility.parseVersion(versionStr);
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
