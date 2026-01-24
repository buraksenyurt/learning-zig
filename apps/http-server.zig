const std = @import("std");

pub fn main() !void {
    const socket = try Socket.init();
    std.debug.print("Server listening on {any}\n", .{socket.address});
    var server = try socket.address.listen(.{});
    const connection = try server.accept();
    _ = connection;
    //todo Dinleme kısmı eklenecek
}

const Socket = struct {
    address: std.net.Address,
    stream: std.net.Stream,

    pub fn init() !@This() {
        const host = [4]u8{ 127, 0, 0, 1 };
        const addr = std.net.Address.initIp4(host, 7000);
        const socket = try std.posix.socket(
            addr.any.family,
            std.posix.SOCK.STREAM,
            std.posix.IPPROTO.TCP,
        );
        const stream = std.net.Stream{ .handle = socket };
        return .{
            .address = addr,
            .stream = stream,
        };
    }
};
