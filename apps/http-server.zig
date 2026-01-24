const std = @import("std");

pub fn main() !void {
    const socket = try Socket.init();
    std.debug.print("Server listening on {any}\n", .{socket.address});
    // Address veri yapısının listen metodunu kullanarak sunucuyu dinleme moduna aldık
    var server = try socket.address.listen(.{});
    // ve aşağıdaki satırla da gelen istekleri kabul etmeye başladık.
    const connection = try server.accept();
    // Gelen istekler için 1024 byte'lık bir buffer tanımladık.
    // Başlangıçta içeriğini sıfırlıyoruz
    var buffer: [1024]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    // Aşağıdaki satırda connection'a gelen içerikleri referans olarak gönderdiğimiz
    // buffer değişkeni içerisine yazdırıyoruz.
    try RequestHandler.read(connection, &buffer);
    std.debug.print("{s}\n", .{buffer});
}

// HTTP Server'ımızda TCP tabanlı dinlemeyi yapmak için kullanacağımız veri yapısı
const Socket = struct {
    address: std.net.Address,
    stream: std.net.Stream,

    pub fn init() !@This() {
        const host = [4]u8{ 127, 0, 0, 1 };
        // IP4 protokolüne göre bir host ve port üzerinden adres tanımlıyoruz.
        // Örneğimize göre localhost:7000 adresi
        const addr = std.net.Address.initIp4(host, 7000);
        // Socket nesnesini oluşturuyoruz. POSIX'i cross-platform bir ABI olarak düşünebiliriz.
        // libc ile bind olunmasını gerektirdiği ifade ediliyor.
        // Aynı kodu linux ve macOS üzerinden deneyebiliriz.
        const socket = try std.posix.socket(
            addr.any.family,
            std.posix.SOCK.STREAM, // SOCK veri yapısında birçok farklı model tanımlanmış. F12'ler ile bakılabilir.
            std.posix.IPPROTO.TCP, //TCP protokolünü kullanacağını belirtiyoruz.
        );
        // TCP tabanlı stream nesnesini de oluşturup bu veri yapısından geri döndürüyoruz.
        const stream = std.net.Stream{ .handle = socket };
        return .{
            .address = addr,
            .stream = stream,
        };
    }
};

const RequestHandler = struct {
    // Bu fonksiyon Connnection nesnesine gönderilen mesakları okur
    // ve bunları yine parametre olarak verilen buffer içerisine yazar
    pub fn read(conn: std.net.Server.Connection, buffer: []u8) !void {
        const reader = conn.stream.reader();
        _ = try reader.read(buffer);
    }
};

// HTTP metotlarımız GET, POST, PUT, PATCH, DELETE gibi birçok farklı türde olabilir.
// Bunların kolay yönetimi için bir enum nesnesi kullanmak çok mantıklı.
const HttpMethod = enum {
    GET,
    POST,
    PUT,
    PATCH,
    DELETE,
    pub fn init(text: []const u8) !@This() {
        return Mapper.get(text) orelse
            return error.InvalidHttpMethod;
    }

    pub fn isSupported(method: []const u8) bool {
        return Mapper.get(method) != null;
    }
};

test "Http GET init works correctly" {
    const method = try HttpMethod.init("GET");
    try std.testing.expect(method == HttpMethod.GET);
}

test "Http unsupported method returns error" {
    const result = HttpMethod.init("INVALID");
    try std.testing.expectError(error.InvalidHttpMethod, result);
}

// HTTP metotlarını string ifadelerden enum türüne çevirmek için static_string_map veri yapısını kullanabiliriz.
// Zig Standart Kütüphanesi ile birlikte gelen türün initComptime fonksiyonu ile
// derleme zamanında bir harita oluşturulması sağlanıyor.
const Mapper = std.static_string_map.StaticStringMap(HttpMethod).initComptime(.{
    .{ "GET", HttpMethod.GET },
    .{ "POST", HttpMethod.POST },
    .{ "PUT", HttpMethod.PUT },
    .{ "PATCH", HttpMethod.PATCH },
    .{ "DELETE", HttpMethod.DELETE },
});
