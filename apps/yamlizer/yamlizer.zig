const std = @import("std");
const models = @import("models.zig");
const utility = @import("utility.zig");
const parser = @import("parser.zig");
// Bu basit kod parçasında şema yapısı belli olan bir YAML dosyasının okunup,
// içeriğinin ilgili veri yapısına dönüştürülmesi (deserialization)
// ve tam tersinin yapılması (serialization) ele alınmaktadır.

pub fn main() !void {
    const file = "data/cache-service.yaml";
    const service = try parser.deserialize(file);
    defer _ = service.deinit();

    const versionStr = try service.version.toString(std.heap.page_allocator);
    defer std.heap.page_allocator.free(versionStr);

    std.debug.print("Service: {s} ({s})\n", .{
        service.serviceName,
        versionStr,
    });
    std.debug.print("Domain: {s}\n", .{service.domain});
    std.debug.print("Network:\n", .{});
    for (service.network.items) |net| {
        std.debug.print("- Host: {s}\n", .{net.host});
        std.debug.print("  Port: {d}\n", .{net.port});
        std.debug.print("  Protocol: {s}\n", .{net.protocol.toString()});
        std.debug.print("  Environment: {s}\n", .{net.environment.toString()});
    }
}
