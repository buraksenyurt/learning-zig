// Bu örnek kodda basit bir HTTP sunucusu yazılmaya çalışıyor.
// Örneğin http://localhost:7000 adresine gelen istekleri dinleyeceğiz.
// Söz gelimi bir API endpoint gibi kurgulayabiliriz.
// /api/v1/resource gibi bir endpoint tanımlayıp buraya gelen json body'leri parse edip işleyebilirsek güzel olur.
// Basit olarak HTTP Get, Post ile başlayalım.

const std = @import("std");
const Connection = std.net.Server.Connection;

pub fn main() !void {
    const socket = try Socket.init();
    std.debug.print("Server listening on {any}\n", .{socket.address});
    // Address veri yapısının listen metodunu kullanarak sunucuyu dinleme moduna aldık
    var server = try socket.address.listen(.{});

    while (true) {
        // ve aşağıdaki satırla da gelen istekleri kabul etmeye başladık.
        const connection = try server.accept();
        std.debug.print("New connection from {any}\n", .{connection.address});
        defer connection.stream.close();

        // Gelen istekler için 1024 byte'lık bir buffer tanımladık.
        var buffer: [1024]u8 = undefined;

        // Connection'a gelen içerikleri referans olarak gönderdiğimiz
        // buffer değişkeni içerisine yazdırıyoruz. Önce n ile ne kadarlık bir veri okunduğunu alıyoruz.
        // Sonrasında ise bu veriyi parse edip Request veri yapısına dönüştürüyoruz.
        const n = try RequestHandler.read(connection, buffer[0..]);
        // std.debug.print("RAW Request: {s}\n", .{buffer[0..n]});
        const request = try RequestHandler.parse(buffer[0..n]);
        std.debug.print("PARSED request:\nMethod={any}, URI={s}, Version={s}\n", .{
            request.header.method,
            request.header.uri,
            request.header.version,
        });
        std.debug.print("Body: {s}\n", .{request.body});
        // api/v1/products endpoint'ine gelen istekleri denetleyeceğiz ama burada
        // api/v1/products?id=123 gibi query parametreleri de olabilir.
        // Bu nedenle '?' karakterine göre URI'yi bölüp path kısmını alıyoruz.
        var it = std.mem.splitScalar(u8, request.header.uri, '?');
        const path = it.first();
        if (std.mem.eql(u8, path, "/")) {
            try sendIndexPageResponse(connection);
            // try sendIndexResponse(std.heap.page_allocator, connection);
            continue;
        } else if (std.mem.eql(u8, path, "/api/v1/products")) {
            if (request.header.method == HttpMethod.GET) {
                // Deneysel olduğu için api/v1/products endpoint'ine gelen GET isteklerinde
                // basit bir OK yanıtı döndürüyoruz.
                try sendTextResponse(connection, "200 OK", "OK");
                continue;
            } else if (request.header.method == HttpMethod.POST) {
                // POST isteklerinde body içeriğini de işlemek lazım ama bu deneysel çalışmada çok da gerekli değil.
                // Şimdilik sadece HTTP 200 OK yanıtı gönderiyoruz.
                try sendTextResponse(connection, "200 OK", "OK");
                continue;
            } else {
                // Diğer HTTP metotları için şimdilik 404 Not Found yanıtı gönderiyoruz.
                try sendTextResponse(connection, "404 Not Found", "Not Found");
                continue;
            }
        }

        // Ayrıca tanımlı olmayan endpoint'ler için de 404 Not Found yanıtı gönderiyoruz.
        try sendTextResponse(connection, "404 Not Found", "Not Found");
    }
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
    pub fn read(conn: Connection, buffer: []u8) !usize {
        return try conn.stream.reader().read(buffer);
    }

    // Parser fonksiyonunun görevi gelen ham içeriği alıp, Request veri yapısına dönüştürmek.
    // Burada ilk satırdan Header bilgilerini alırken, CRLF CRLF (yani \r\n\r\n) karakterinden itibaren de body kısmını ayrıştırıyoruz.
    // Bu fonksiyon esasında hatalara oldukça müsait. İdeal senaryoda gelen HTTP içeriğindeki structure'ın standarda
    // uygun geldiğini düşünüyoruz. Test metotlarında bunla ilgili örnekler yer alıyor.
    pub fn parse(content: []const u8) !Request {
        // HTTP standardına göre ilk satır \r\n ile biter
        const headerLineIndex = std.mem.indexOf(u8, content, "\r\n") orelse content.len;

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
        // Body kısmının ayrıştırılması için HTTP standardı gereği \r\n\r\n (CRLF CRLF) karakterini baz alıyoruz.
        const bodyStartIndex = std.mem.indexOf(u8, content, "\r\n\r\n") orelse content.len;
        std.debug.print("Body starts at index: {}\n", .{bodyStartIndex});
        // Bir body içeriği söz konusu ile alıyoruz yoksa boş bırakıyoruz.
        const bodyRaw = if (bodyStartIndex < content.len) content[bodyStartIndex + 4 ..] else "";
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
        return Mapper.get(text) orelse error.InvalidHttpMethod;
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
        return .{ .header = header, .body = body };
    }
};

test "Request parsing works for HTTP GET correctly" {
    const rawRequest =
        "GET /api/v1/resource HTTP/1.1\r\n" ++
        "User-Agent: PostmanRuntime/7.51.0\r\n" ++
        "Accept: */*\r\n" ++
        "Cache-Control: no-cache\r\n" ++
        "Host: localhost:7000\r\n" ++
        "Accept-Encoding: gzip, deflate, br\r\n" ++
        "Connection: keep-alive\r\n" ++
        "\r\n";
    const parsedRequest = try RequestHandler.parse(rawRequest);

    try std.testing.expect(parsedRequest.header.method == HttpMethod.GET);
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.uri, "/api/v1/resource"));
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.version, "HTTP/1.1"));
}

test "Request parsing works for HTTP POST with body correctly" {
    const rawRequest =
        "POST /api/v1/resource HTTP/1.1\r\n" ++
        "User-Agent: PostmanRuntime/7.51.0\r\n" ++
        "Accept: */*\r\n" ++
        "Cache-Control: no-cache\r\n" ++
        "Host: localhost:7000\r\n" ++
        "Accept-Encoding: gzip, deflate, br\r\n" ++
        "Connection: keep-alive\r\n" ++
        "\r\n" ++
        "{\"name\":\"Can Cey Rambo\",\"age\":34}";
    const parsedRequest = try RequestHandler.parse(rawRequest);

    try std.testing.expect(parsedRequest.header.method == HttpMethod.POST);
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.uri, "/api/v1/resource"));
    try std.testing.expect(std.mem.eql(u8, parsedRequest.header.version, "HTTP/1.1"));
    try std.testing.expect(std.mem.eql(u8, parsedRequest.body, "{\"name\":\"Can Cey Rambo\",\"age\":34}"));
}

fn sendTextResponse(connection: Connection, status: []const u8, body: []const u8) !void {
    try connection.stream.writer().print(
        "HTTP/1.1 {s}\r\n" ++
            "Content-Length: {d}\r\n" ++
            "Content-Type: text/plain; charset=utf-8\r\n" ++
            "Connection: close\r\n" ++
            "\r\n",
        .{ status, body.len },
    );
    try connection.stream.writeAll(body);
}

// / adresine yani root'a gelen istekler için basit bir karşılama sayfası dönüyoruz.
// Burada tipik olarak connection nesnesi üzerinde stream'e veri yazdırmaktayız.
fn sendIndexPageResponse(connection: Connection) !void {
    const body = "Index Page: Welcome to Zig HTTP Server!";

    // İlk olarak Header bilgilerini yazdırıyoruz.
    // Body uznunluğunu Content-Length başlığı ile belirtiyoruz.
    // Ayrıca Content-Type başlığı ile de içeriğin text/plain olduğunu,
    // Connection: close bildirimi ile de bu isteğin ardından bağlantının kapatılacağını belirttik
    try connection.stream.writer().print(
        "HTTP/1.1 200 OK\r\n" ++
            "Content-Length: {d}\r\n" ++
            "Content-Type: text/plain; charset=utf-8\r\n" ++
            "Connection: close\r\n" ++
            "\r\n",
        .{body.len},
    );

    // Hemen arkasından da body içeriğini yazdırıyoruz.
    try connection.stream.writeAll(body);
}

// // Yukarıdaki kullanıma alternatif olarak allocator kullanan bir fonksiyon da yazabiliriz.
// fn sendIndexResponse(allocator: std.mem.Allocator, connection: Connection) !void {
//     const body = "Index Page: Welcome to Zig HTTP Server!";

//     const response = try std.fmt.allocPrint(
//         allocator,
//         "HTTP/1.1 200 OK\r\nContent-Length: {d}\r\nContent-Type: text/plain; charset=utf-8\r\nConnection: close\r\n\r\n{s}",
//         .{ body.len, body },
//     );
//     defer allocator.free(response);

//     try connection.stream.writeAll(response);
// }
