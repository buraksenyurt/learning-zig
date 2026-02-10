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

    try server.set("default-port", "7329");
    try server.set("mode", "development");

    const val1 = server.get("default-port") orelse null;
    const val2 = server.get("mode") orelse null;

    std.debug.print("default-port: {any}, mode: {any}\n", .{ val1, val2 });
}

fn handleClient(server: *Server, connection: net.Server.Connection) void {
    defer connection.stream.close();
    const reader = connection.stream.reader();
    const writer = connection.stream.writer();
    var buffer: [1024]u8 = undefined;

    while (true) {
        const message = reader.readUntilDelimiterOrEof(&buffer, '\n') catch return;
        const trimmedMsg = std.mem.trim(u8, message.?, "\r \t");

        const line = std.mem.trim(u8, trimmedMsg, "\r \t");
        var iterator = std.mem.splitScalar(u8, line, ' ');
        const command = iterator.first();
        var commandUpper: [16]u8 = undefined;
        const upperCommand = std.ascii.upperString(&commandUpper, command);

        if (std.mem.eql(u8, upperCommand, "SET")) {
            const key = iterator.next();
            const value = iterator.next();
            if (key != null and value != null) {
                server.set(key.?, value.?) catch {
                    writer.print("ERR \n", .{}) catch {};
                    continue;
                };
                writer.print("OK\n", .{}) catch {};
            }
        } else if (std.mem.eql(u8, upperCommand, "GET")) {
            const key = iterator.next();
            if (key) |k| {
                if (server.get(k)) |value| {
                    writer.print("{s}\n", .{value}) catch {};
                } else {
                    writer.print("(nil)\n", .{}) catch {};
                }
            }
        } else if (std.mem.eql(u8, upperCommand, "PING")) {
            writer.print("PONG\n", .{}) catch {};
        } else {
            writer.print("ERROR: Unknown command '{s}'\n", .{command}) catch {};
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var server = Server.init(allocator);
    const address = try net.Address.parseIp("127.0.0.1", 7329);
    var listener = try address.listen(.{ .kernel_backlog = 8 });
    std.debug.print("Multi-thread zedis server running on 7329...", .{});

    while (true) {
        const connection = try listener.accept();

        const thread = try std.Thread.spawn(
            .{},
            handleClient,
            .{ &server, connection },
        );

        thread.detach();
    }
}
