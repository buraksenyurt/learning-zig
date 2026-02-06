// Bu uygulama Redis klonu olan Zedis için basit bir istemci

const std = @import("std");
const net = std.net;

pub fn main() !void {
    // Örnekte sabit boyutlu stream'ler kullanılıyor. Komutlarımızın ve
    // saklamak istediğimi key:value değerlerinin küçük olduğunu düşünüyoruz.
    // Ancak belli bir boyutun üstündeki value'lar için (örneğin 5 Mb üzeri)
    // satır okurken allocator kullanımı da tercih edilebilir.

    // Burada da zedis sunucusuna bağlanmaya çalışıyoruz
    const endpoint = try net.Address.parseIp("127.0.0.1", 7329);
    const stream = try net.tcpConnectToAddress(endpoint);
    defer stream.close();

    std.debug.print("Connected to Zedis server", .{});

    // Çift yönlü bir iletişim söz konusu bu nedenle std input ve output üzerinde
    // çalışacak nesnelere gerekiyor
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const reader = stream.reader();
    const writer = stream.writer();

    // İstemci tarafından gönderilecek komutlar ve sunucudan gelen
    // cevaplar için birer buffer değişken hazırlıyoruz.
    var commandBuffer: [1024]u8 = undefined;
    var responseBuffer: [2048]u8 = undefined;

    // Burası REPL döngüsü. Yani read evaluate print ve loop aşaması
    while (true) {
        try stdout.print("> ", .{});
        // Kullanıcının girdiği komutu input değişkenine okuyoruz
        // Altsatıra geçme karakterini görünceye kadar okuma  yapıyoruz
        const input = try stdin.readUntilDelimiterOrEof(&commandBuffer, '\n');
        if (input == null) break;
        // Windows işletim sistemindeysek sonda \r karakteri olabilir.
        // Varsa bunu kesiyoruz
        const line = std.mem.trim(u8, input.?, "\r");

        if (line.len == 0) continue; // Hiçbir şey girilmemişse döngü devam eder
        if (std.mem.eql(u8, line, "quit")) break; // Kullanıcı quit yazmışsa döngüden ve dolayısıyla istemci uygulamadan çıkılır

        // Bu kısım kritik.
        // Komutu zedis server'ına gönderiyoruz. Nasıl mı?
        // Writer stream'ini kullanıp doğrudan soket üzerine yazarak
        try writer.print("{s}\n", .{line});

        // ve tabii ki sunucu tarafından gelen cevabı alıyoruz
        // Burada sunucudan gelen cevabın tamamlanmasını beklemek için bir End Of File kontrolü var.
        const response = try reader.readUntilDelimiterOrEof(&responseBuffer, '\n');

        // Eğer ortada bir cevap varsa
        if (response) |r| {
            // Bunu istemci terminaline basıyoruz
            try stdout.print("{s}\n", .{r});
        } else {
            std.debug.print("Connection closed.\n", .{});
            break;
        }
    }
}
