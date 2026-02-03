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

        // İstemciye basit bir mesaj ile cevap veriyoruz.
        // Böylece bir el sıkışma(handshake) yapmış olduğumuzu varsayabiliriz
        try connection.stream.writer().writeAll(("Ready to conversation\n"));
    }
}
