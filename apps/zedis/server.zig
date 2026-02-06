// CLONE    : Redis'in çok ilkel bir sürümü
// AMAÇLAR  :
//          - Allocator kullanımı,
//          - Hashmap ile key;value desteği sağlama
//          - TCP sunucusu oluşturma, istek dinleme, cevap verme
// RUN      : zig run .\server
// YORUM    :
const std = @import("std");
const net = std.net;

pub fn main() !void {
    // Bir key-value store söz konusu olacağından ve in-memory kullanılacağından
    // pek tabii allocator'a başvurmamız gerekiyor.
    // Genel amaçlı bir Allocator oluşturduktan sonra
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    // standart kütüphanede yer alan StringHasMap nesnesini bu allocator ile başlatıyoruz
    var store = std.StringHashMap([]const u8).init(allocator);

    // defer kısmında bu kez bir block açtığımıza dikkat edelim
    // zira store üzerinden belleğe aldığımız öğelerin de ayrı ayrı düşürülmesi gerekiyor
    defer {
        // bu nedenle önce bir iterator nesne oluşturup
        var iter = store.keyIterator();
        // iterator ile bellekteki öğeleri dolaşıp
        while (iter.next()) |key| {
            // her birinin key ve value değerlerini serbest bırakıyoruz
            allocator.free(key.*);
            if (store.get(key.*)) |val| {
                allocator.free(val);
            }
        }
        store.deinit();
    }

    // İlk olarak localhost adresi ve 7329 portu için bir Ip nesnesi tanımlıyoruz
    const host = try net.Address.parseIp4("127.0.0.1", 7329);
    // Şimdi bu adresi dinlemek üzere bir server nesnesi tanımlıyoruz.
    // kernel_backlog ile kuyruktan maksimum kaç istemci olacağını belirtiyoruz ki burada 8
    var server = try net.Address.listen(host, .{ .kernel_backlog = 8 });
    defer server.deinit(); // Çıkarken kaynakları iade et

    std.debug.print("Zedis is online at {any}", .{host});

    // İstemci taleplerini dinleyecek sonsuz döngü
    while (true) {
        // Her istemci bu sunucu ile bir oturumu başlatır.
        // İstemciden gelen talepleri kabul etmek için bir connection nesnesi tanımlanır
        const connection = try server.accept();
        defer connection.stream.close(); // istemci ile sunucu arasında açılan stream işimiz bitince otomatik kapatılır diyebilir miyiz?

        // Bağlanan istemci adresini gösteren minik bir log.
        std.debug.print("{any} connected...\n", .{connection.address});

        // İstemci ve sunucu arasında açılan kanalı kullanarak okuma ve yazma işlemleri yapacağız.
        // Bu nedenle bir buffer alan ve reader, writer için birer nesne hazırlıyoruz
        var buffer: [1024]u8 = undefined;
        const reader = connection.stream.reader();
        const writer = connection.stream.writer();

        // İstemci aralıksız bir stream göndereceği için sonsuz bir döngü açtık
        while (true) {
            // Alt satıra geçme karakterini de gözeterek istemciden gelen mesajı referans olarak gelen buffer'a alıyoruz
            // Burada bir hata durumu oluşabilir o yüzden catch bloğu kullanıldı
            const message = reader.readUntilDelimiterOrEof(&buffer, '\n') catch |e| {
                std.debug.print("ERROR:{}\n", .{e});
                break; // hata varsa döngüden çıkıp sonraki connection ile devam etmek lazım
            };

            if (message == null) break; // Message yoksa zaten döngüden çıkmak lazım :D

            // Mesaj sorunsuz geldiyse boşluklarını silelim
            const trimmedMsg = std.mem.trim(u8, message.?, "\r \t");
            // Tipik bir redis komutu SET <key_name> <value> şeklindedir
            // Dolayısıyla trim edilmiş mesajı da boşluk karakterine göre ayrıştırıp
            // elde ettiğimi SplitIterator nesnesini de kullanarak parçalı şekilde okuyabiliriz
            var parts = std.mem.splitScalar(u8, trimmedMsg, ' ');
            // Burada komutu okuyoruz
            const command = parts.first();

            if (std.mem.eql(u8, command, "PING")) {
                // Eğer PING komutu gelmişse
                try writer.print("PONG\n", .{}); // istemciye PONG cevabı veriyoruz ki bu bir klasiktir
            } else if (std.mem.eql(u8, command, "SET")) {
                // Eğer SET komutu gönderilmişse depoya bir key:value çifti eklenmek isteniyordur
                const key = parts.next(); // iterasyonda sonraki ifade key değerini
                const value = parts.next(); // ondan sonraki ifade de value değerini işaret edecektir.
                // İkisi de null değilse store'a ekleyebiliriz
                if (key != null and value != null) {
                    // Store ekleme işinden önce key:value değerlerini heap üzerine alıyoruz.
                    // Bunun için dupe komutu kullanılabilir. Bu komut, değerlerin koypalarını heap üzerinde oluşturr
                    const keyCopy = try allocator.dupe(u8, key.?);
                    const valCopy = try allocator.dupe(u8, value.?);

                    // Peki ya key değeri varsa ne yapacağız?
                    // store'a key ve value içeriklerinin kopyası eklenir
                    try store.put(keyCopy, valCopy);
                    // ve istemci tarafa işlemin olduğuna dair bir OK mesajı basılır
                    try writer.print("OK\n", .{});
                } else {
                    try writer.print("ERROR: Usage SET <key> <value>\n", .{});
                }
            } else if (std.mem.eql(u8, command, "GET")) {
                // GET <key_name> komutu gelmişse
                const key = parts.next(); // istenen key değerini alıyoruz
                if (key) |k| { // null değil ve bir değere sahipse
                    // v olarak isimlendirilen value'yu store'dan çekmeye çalışıyoruz
                    if (store.get(k)) |v| {
                        // ve çekebilirse, yani varsa writer ile stream'a bir başka deyişle ağ üzerinden istemciye gönderiyoruz
                        try writer.print("{s}\n", .{v});
                    } else {
                        // yoksa da nil değerini basıyoruz
                        try writer.print("nil\n", .{});
                    }
                }
            }
        }
    }
}
