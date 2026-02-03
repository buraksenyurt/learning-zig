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
        capacity: usize,

        const Self = @This();

        pub fn init(allocator: Allocator) @This() {
            return .{
                .allocator = allocator,
                .items = &[_]Pair{},
                .count = 0,
                .capacity = 8,
            };
        }

        pub fn initCapacity(allocator: Allocator, capacity: usize) @This() {
            return .{
                .allocator = allocator,
                .items = &[_]Pair{},
                .count = 0,
                .capacity = capacity,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn getCount(self: Self) usize {
            return self.count;
        }

        pub fn getCapacity(self: Self) usize {
            return self.capacity;
        }

        fn getHash(self: Self, key: T) u64 {
            _ = self;
            var hasher = std.hash.Wyhash.init(0);
            std.hash.autoHashStrat(&hasher, key, .Deep);
            return hasher.final();
        }

        fn resize(self: *Self) !void {
            const newCapacity = if (self.items.len == 0)
                self.capacity
            else
                self.items.len * 2;
            const newItems = try self.allocator.alloc(Pair, newCapacity);

            for (newItems) |*item| {
                item.key = null;
                item.used = false;
            }

            for (self.items) |item| {
                if (item.key) |k| {
                    var id = self.getHash(k) % newItems.len;
                    while (newItems[id].used) {
                        id = (id + 1) % newItems.len;
                    }

                    newItems[id].key = k;
                    newItems[id].used = true;
                }
            }

            self.allocator.free(self.items);
            self.items = newItems;
            self.capacity = newCapacity;
        }

        pub fn put(self: *Self, key: T) !void {
            if (self.count >= self.items.len / 2) {
                try self.resize();
            }

            var id = self.getHash(key) % self.items.len;

            while (self.items[id].used) {
                if (std.meta.eql(self.items[id].key.?, key)) {
                    return;
                }
                id = (id + 1) % self.items.len;
            }

            self.items[id].key = key;
            self.items[id].used = true;
            self.count += 1;
        }

        pub fn isExist(self: Self, key: T) bool {
            if (self.items.len == 0) return false;

            var id = self.getHash(key) % self.items.len;
            const startIndex = id;

            while (self.items[id].used) {
                if (std.meta.eql(self.items[id].key.?, key)) {
                    return true;
                }
                id = (id + 1) % self.items.len;
                if (id == startIndex) break;
            }
            return false;
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
    try expect(map.getCapacity() == 8);
}

test "insert items into hash map is ok" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var map = CreateHashmap(i32).init(allocator);
    defer map.deinit();

    try map.put(10);
    try map.put(20);
    try map.put(30);

    try expect(map.getCount() == 3);
}

test "check existence of items in hash map is ok" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var map = CreateHashmap([]const u8).init(allocator);
    defer map.deinit();

    try map.put("red");
    try map.put("green");
    try map.put("blue");

    try expect(map.isExist("red"));
    try expect(map.isExist("green"));
    try expect(map.isExist("blue"));
    try expect(!map.isExist("yellow"));
}

test "resize hash map when capacity is reached is ok" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var map = CreateHashmap([]const u8).init(allocator);
    defer map.deinit();

    const initialCapacity = map.getCapacity();

    try map.put("one");
    try map.put("two");
    try map.put("three");
    try map.put("four");
    try map.put("five");

    try expect(map.getCapacity() == initialCapacity * 2);
    try expect(map.getCount() == 5);
    std.debug.print("Current Capacity: {d}\n", .{map.getCapacity()});
}
