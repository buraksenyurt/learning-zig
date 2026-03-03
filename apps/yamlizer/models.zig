const std = @import("std");

pub const version = struct {
    major: u8,
    minor: u8,
    revision: u16,
    pub fn toString(self: @This(), allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(
            allocator,
            "{}.{}.{}",
            .{
                self.major,
                self.minor,
                self.revision,
            },
        );
    }
};

pub const Protocol = enum {
    Http,
    Https,
    Grpc,
};

pub const Environment = enum {
    Development,
    Test,
    Production,
};

pub const network = struct {
    host: []const u8,
    port: u16,
    protocol: Protocol,
    environment: Environment,
};

pub const service = struct {
    serviceName: []const u8,
    version: version,
    domain: []const u8,
    network: std.ArrayList(network),
    technologyStack: std.ArrayList([]const u8),
    dependencies: std.ArrayList([]const u8),
};
