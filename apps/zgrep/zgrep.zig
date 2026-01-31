// CLONE    : grep programının hafifsiklet bir sürümü
// AMAÇLAR  :
//          - Allocator kullanımı,
//          - Komut satırından arguman okuma,
//          - Dosya okuma işlemi
// RUN      :
// YORUM    : zig run .\zgrep.zig -- Sample .\test-file.txt

const std = @import("std");

pub fn main() !void {
    // Çalışma zamanında gelen argüman bilgilerini heap'e alacağız
    // Bu nedenle genel amaçlı bir Allocator tanımladık
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit(); // Programdan çıkarken Allocator'ü temizle
    const allocator = gpa.allocator();

    // Argümanlar, kendileri için tahsis edilen alana alınırken kod tarafında da args üstünde erişilebilir hale gelir
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args); // Programdan çıkarken argümanları temizle

    // Hafif bir kontrol. Beklentimiz en az 3 argüman olması
    if (args.len < 3) {
        try printUsage(); // Eğer değilse küçük bir kullanım kılavuzu gösterelim
    }

    // Argümaları değişkenlere bağlayalım (bind)
    const query = args[1];
    const filePath = args[2];

    // İkinci parametre ile belirtilen dosyayı okuma amaçlı açıyoruz
    var file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close(); // Programdan çıkarken dosyayı kapat

    // Dosyadan okuma yaparken tampon (buffer) kullanmak performans açısından faydalı olur
    var buffReader = std.io.bufferedReader(file.reader());
    var stream = buffReader.reader();
    var buffer: [4096]u8 = undefined; // 4 KB'lık bloklar halinde okuma yapacağız

    // Dosya sonuna gelinceye kadar okuma yapacak bir while döngüsü
    // Windows, Linux, Unix fark eder mi?
    while (try stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        // mem modülündeki indexOf fonksiyonu ile aranan query'nin satır içerisinde
        // geçip geçmediğini kontrol ediyoruz
        if (std.mem.indexOf(u8, line, query) != null) {
            // Eğer geçiyorsa ekrana yazdırıyoruz
            try std.io.getStdOut().writer().print("{s}\n", .{line});
        }
    }
}

fn printUsage() !void {
    try std.io.getStdOut().writer().print(
        \\zgrep : A grep clone written with zig programming language
        \\
        \\Usages;
        \\zgrep <query> <file_path>
        \\
    , .{});
}
