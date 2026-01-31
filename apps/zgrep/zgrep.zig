// CLONE    : grep programının hafifsiklet bir sürümü
// AMAÇLAR  :
//          - Allocator kullanımı,
//          - Komut satırından arguman okuma,
//          - Dosya okuma işlemi
// RUN      : zig run .\zgrep.zig -- Sample .\test-file.txt
//            zig run .\zgrep.zig -- -ics sAMplE .\test-file.txt
// YORUM    :

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

    var query: []u8 = "";
    var filePath: []u8 = "";
    var ignoreCase = false;

    // Argümanları dolaşalım.
    // İlk index uygulamayı işaret ettiğinden 1den başlıyoruz
    var index: usize = 1;
    while (index < args.len) : (index += 1) {
        // komut satırı argümanını alalım
        // Argümanları sıralı olarak değerlendirebiliriz, o nedenle sıradaki argümanı kontrol edip
        // doğru değişkenlere bağlıyoruz.
        const arg = args[index];
        // eğer -ics yazıyorsa ignore case sensitive anlamındadır
        if (std.mem.eql(u8, arg, "-ics")) {
            ignoreCase = true;
        } else if (query.len == 0) {
            query = arg;
        } else if (filePath.len == 0) {
            filePath = arg;
        }
    }

    // Döngü, argüman sayısı kadar devam ettiği için
    // sorgu ifadesi ve dosya bilgilerinin verilip verilmediğine bakıp
    // kullanım kılavuzunu yayınlıyoruz.
    if (query.len == 0 or filePath.len == 0) {
        try printUsage();
        return;
    }

    // İkinci parametre ile belirtilen dosyayı okuma amaçlı açıyoruz
    var file = try std.fs.cwd().openFile(filePath, .{});
    defer file.close(); // Programdan çıkarken dosyayı kapat

    // Dosyadan okuma yaparken tampon (buffer) kullanmak performans açısından faydalı olur
    var buffReader = std.io.bufferedReader(file.reader());
    var stream = buffReader.reader();
    var buffer: [4096]u8 = undefined; // 4 KB'lık bloklar halinde okuma yapacağız

    var lineNumber: usize = 0;
    // Dosya sonuna gelinceye kadar okuma yapacak bir while döngüsü
    // Windows, Linux, Unix fark eder mi?

    while (try stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        // -ics (is case sensitive) flag aktifse
        if (ignoreCase) {
            // yardımcı fonksiyon üzerinden arama yaptırılıyor
            if (containsCaseInsensitve(line, query)) {
                try std.io.getStdOut().writer().print("{d}: {s}\n", .{ lineNumber, line });
            }
        } else {
            // aksi durumda Case Sensitive arama söz konusu
            if (std.mem.indexOf(u8, line, query) != null) {
                try std.io.getStdOut().writer().print("{d}: {s}\n", .{ lineNumber, line });
            }
        }
        lineNumber += 1;
    }
}

fn printUsage() !void {
    try std.io.getStdOut().writer().print(
        \\zgrep : A grep clone written in Zig
        \\
        \\Usages;
        \\zgrep [-ics] <query> <file_path>
        \\Arguments:
        \\  -ics    : Ignore case sensitivity while searching (optional)
        \\
    , .{});
}

// Bu yardımcı fonksiyon küçük büyük harf duyarlılığı geçersiz olduğunda devreye giriyor
fn containsCaseInsensitve(content: []const u8, searchTerm: []const u8) bool {
    if (content.len == 0) return true;
    if (searchTerm.len > content.len) return false;

    var i: usize = 0;
    while (i <= content.len - searchTerm.len) : (i += 1) {
        const part = content[i .. i + searchTerm.len];
        if (std.ascii.eqlIgnoreCase(part, searchTerm)) {
            return true;
        }
    }
    return false;
}
