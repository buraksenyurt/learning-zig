const std = @import("std");
const Allocator = std.mem.Allocator;

fn CreateHashmap(comptime T: type) type {
    return struct {
        const Pair = struct {
            key: ?T,
            used: bool,
        };

        allocator: Allocator,
        items: []Pair,
        count: usize,

        const Self = @This();

        pub fn init(allocator: Allocator) @This() {
            return .{
                .allocator = allocator,
                .items = &[_]Pair{},
                .count = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn getCount(self: Self) usize {
            return self.count;
        }

        fn getHash(self: Self, key: T) u64 {
            _ = self;
            var hasher = std.hash.Wyhash.init(0);
            std.hash.autoHash(&hasher, key);
            return hasher.final();
        }
    };
}

const expect = std.testing.expect;

test "create an empty hash map is ok" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var map = CreateHashmap(i32).init(allocator);
    defer map.deinit();
    try expect(map.getCount() == 0);
}
