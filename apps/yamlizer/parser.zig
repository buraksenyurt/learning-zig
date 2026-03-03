const std = @import("std");

// Bu basit kod parçasında şema yapısı belli olan bir YAML dosyasının okunup,
// içeriğinin ilgili veri yapısına dönüştürülmesi (deserialization)
// ve tam tersinin yapılması (serialization) ele alınmaktadır.

const version = struct {
    major: u8,
    minor: u8,
    revision: u16,
};

const Protocol = enum {
    Http,
    Https,
    Grpc,
};

const Environment = enum {
    Development,
    Test,
    Production,
};

const network = struct {
    host: []const u8,
    port: u16,
    protocol: Protocol,
    environment: Environment,
};

const service = struct {
    serviceName: []const u8,
    version: version,
    domain: []const u8,
    network: std.ArrayList(network),
    technologyStack: std.ArrayList([]const u8),
    dependencies: std.ArrayList([]const u8),
};

pub fn main() !void {}
