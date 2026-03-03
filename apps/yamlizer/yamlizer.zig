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

    std.debug.print("Service Name: {s}\n", .{service.serviceName});
    std.debug.print("Domain: {s}\n", .{service.domain});
}
