const std = @import("std");
const models = @import("models.zig");
const utility = @import("utility.zig");
const parser = @import("parser.zig");
// Bu basit kod parçasında şema yapısı belli olan bir YAML dosyasının okunup,
// içeriğinin ilgili veri yapısına dönüştürülmesi (deserialization)
// ve tam tersinin yapılması (serialization) ele alınmaktadır.

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 2) {
        utility.printUsage();
        std.process.exit(1);
    }

    const file = args[1];
    const service = try parser.deserialize(file);
    defer _ = service.deinit();

    service.print();
}
