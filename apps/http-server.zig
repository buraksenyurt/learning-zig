// Bu örnek kodda basit bir HTTP sunucusu yazılmaya çalışıyor.
// Örneğin http://localhost:7000 adresine gelen istekleri dinleyeceğiz.
// Söz gelimi bir API endpoint gibi kurgulayabiliriz.
// /api/v1/resource gibi bir endpoint tanımlayıp buraya gelen json body'leri parse edip işleyebilirsek güzel olur.
// Basit olarak HTTP Get, Post ile başlayalım.

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
    // Bu fonksiyon Connnection nesnesine gönderilen mesajları okur
    // ve bunları yine parametre olarak verilen buffer içerisine yazar
    pub fn read(conn: std.net.Server.Connection, buffer: []u8) !void {
        const reader = conn.stream.reader();
        _ = try reader.read(buffer);
    }

    // Parser fonksiyonunun görevi gelen ham içeriği alıp, Request veri yapısına dönüştürmek.
    // Burada ilk satırdan Header bilgilerini alırken, \n\n satırından itibaren de body kısmını ayrıştırıyoruz.
    // Bu fonksiyon esasında hatalara oldukça müsait. İdeal senaryoda gelen HTTP içeriğindeki structure'ın standarda
    // uygun geldiğini düşünüyoruz. Test metotlarında bunla ilgili örnekler yer alıyor.
    pub fn parse(content: []const u8) !Request {
        const headerLineIndex = std.mem.indexOfScalar(u8, content, '\n') orelse content.len;

        // ' ' karakterine göre bir Split Iterator nesnesi oluşturuyoruz.
        // Yani ilk satırda boşluk karakterine göre next() çağrıları ile ilerleyeip sırasıyla
        // method, uri ve version bilgilerini alıyoruz. Elbette burada HTTP standartlarına güvenerek hareket ettik.
        // Bu senaryoda söz konusu sıralama değişmez ama değişirse de mutlaka hata fırlatmalıyız.
        var iterator = std.mem.splitScalar(
            u8,
            content[0..headerLineIndex],
            ' ',
        );
        const methodText = iterator.next().?;
        const uriText = iterator.next().?;
        const versionText = iterator.next().?;

        const method = try HttpMethod.init(methodText);

        const header = RequestHeader.init(method, uriText, versionText);

        // Bu satırdan itibaren de body kısmını okumaya başladık.
        // Body kısmının ayrıştırılması için çift yeni satır (\n\n) karakterini baz aldık. En azından
        // Postman ile gelen istekler de bu şekilde bir içerik söz konusu. Daha detaylı testler ile deneyeceğim.
        const bodyStartIndex = std.mem.indexOf(u8, content, "\n\n") orelse content.len;
        // Bir body içeriği söz konusu ile alıyoruz yoksa boş bırakıyoruz.
        const bodyRaw = if (bodyStartIndex < content.len) content[bodyStartIndex + 2 ..] else "";
        // Sonda yer alan alt satır ve boşluk karakterlerini törpülüyoruz ve böylece body içeriğini tam olarak çekmiş oluyoruz.
        const body = std.mem.trim(u8, bodyRaw, "\n\r ");

        return .{
            .header = header,
            .body = body,
        };
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

// Header bilgilerini tutmak için aşağıdaki gibi bir veri yapısını kullanabiliriz.
// Basitçe header ile gelen HTTP metodu, URI ve versiyon bilgilerini tutar.
// Bu bilgiler önemlidir. GET, POST'a göre farklı akışlar söz konusu olur.
// Hatta versiyon da önemlidir. HTTP/1.1 ile HTTP/2 farklı şekillerde işlenir.
const RequestHeader = struct {
    method: HttpMethod,
    uri: []const u8,
    version: []const u8,

    pub fn init(method: HttpMethod, uri: []const u8, version: []const u8) @This() {
        return .{
            .method = method,
            .uri = uri,
            .version = version,
        };
    }
};

// Gelen talebin tamamını temsil eden veri yapısı olarak düşünelim
// Basit olması açısından sadece Header içeriğini ve Body kısmını tutmaktayız.
const Request = struct {
    header: RequestHeader,
    body: []const u8,
    pub fn init(header: RequestHeader, body: []const u8) @This() {
        .{
            .header = header,
            .body = body,
        };
    }
};

test "Request parsing works for HTTP GET correctly" {
    const rawRequest =
        \\GET /api/v1/resource HTTP/1.1
        \\User-Agent: PostmanRuntime/7.51.0
        \\Accept: */*
        \\Cache-Control: no-cache
        \\Host: localhost:7000
        \\Accept-Encoding: gzip, deflate, br
        \\Connection: keep-alive
        \\
    ;
    const parsedRequest = try RequestHandler.parse(rawRequest);

    try std.testing.expect(parsedRequest.header.method == HttpMethod.GET);
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.uri, "/api/v1/resource"));
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.version, "HTTP/1.1"));
}

test "Request parsing works for HTTP POST with body correctly" {
    const rawRequest =
        \\POST /api/v1/resource HTTP/1.1
        \\User-Agent: PostmanRuntime/7.51.0
        \\Accept: */*
        \\Cache-Control: no-cache
        \\Host: localhost:7000
        \\Accept-Encoding: gzip, deflate, br
        \\Connection: keep-alive
        \\
        \\{"name":"Can Cey Rambo","age":34}
        \\
    ;
    const parsedRequest = try RequestHandler.parse(rawRequest);

    try std.testing.expect(parsedRequest.header.method == HttpMethod.POST);
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.uri, "/api/v1/resource"));
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.version, "HTTP/1.1"));
    try std.testing.expect(std.mem.eql(u8, parsedRequest.body, "{\"name\":\"Can Cey Rambo\",\"age\":34}"));
}
