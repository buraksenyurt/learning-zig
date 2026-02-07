const std = @import("std");
const net = std.net;

// Sunucu tarafını concurrent modda çalışacak hale getiriyoruz.
// Bunun için Mutex(Mutual Exclusion Lock) ile bir kilit mekanizması kullanacağız.
// Sunucu tarafı için öncelikle bir veri yapısı tasarlanır
const Server = struct {
    store: std.StringHashMap([]const u8),
    allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex,

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .store = std.StringHashMap([]const u8).init(allocator),
            .allocator = allocator,
            .mutex = std.Thread.Mutex{},
        };
    }

    // Server yapısında bir deinit fonksiyonu tanımlayarak bellekteki kaynakları serbest bırakmayı sağlıyoruz.
    // Özellikle test fonksiyonunda alınan hata üzerine eklendi.
    pub fn deinit(self: *@This()) void {
        var it = self.store.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.store.deinit();
    }

    // hem get ile veri okuma hem de set ile veri yazma sırasında
    // mutex ile kilit konur ve başka bir thread'in burada işlem yapması engellenir.
    pub fn get(self: *@This(), key: []const u8) ?[]const u8 {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.store.get(key);
    }

    pub fn set(self: *@This(), key: []const u8, value: []const u8) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        const keyCopy = try self.allocator.dupe(u8, key);
        const valCopy = try self.allocator.dupe(u8, value);
        try self.store.put(keyCopy, valCopy);
    }
};

test "Concurrent server set and get" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var server = Server.init(allocator);
    defer server.deinit();

    try server.set("default-port", "5329");
    try server.set("mode", "development");

    const val1 = server.get("default-port") orelse null;
    const val2 = server.get("mode") orelse null;

    std.debug.print("default-port: {any}, mode: {any}\n", .{ val1, val2 });
}

fn handleClient(server: *Server, connection: net.Server.Connection) void {
    _ = server;
    _ = connection;
    //todq@buraksenyurt
}

pub fn main() !void {}
