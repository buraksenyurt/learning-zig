const std = @import("std");

pub fn ping() []const u8 {
    return "Pong!";
}

// Basit ve rekürsif olarak çalışan bir faktöriyel fonksiyonu
pub fn factorial(value: u64) u64 {
    if (value == 0 or value == 1) return 1;
    return value * factorial(value - 1);
}

// Daha kolay yolu var mı henüz bilmiyorum
// Ama çalışırken sürekli std.debug.print, \n ve .{} kullanmaktan sıkılınca
// Bu yardımcı fonksiyonu yazmaya karar verdim.
pub fn println() void {
    std.debug.print("\n", .{});
}

// Bu fonksiyon rastgele sayı üretmekte.
// u8 yerine !u8 türünden bir dönüş yaptığımıza dikkat edelim zira bu metod hata fırlatabilir.
// try ile çağrılan yerden bir hata fırlatılabilir. ! ile bu hatayı çağıran yere iletiyoruz.
pub fn createRandomInteger() !u8 {
    // Bazı kaynaklarda Zig'in 0.13 versiyonunda random sayı üretimi için std.rand namespace tanımlı
    // Ama tabii 0.14'te değişmiş. https://ziglang.org/download/0.14.0/release-notes.html adresindeki gibi release notları okumak lazım

    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    return rand.int(u8);
}

// statik buffer kullanılarak bir dosya içeriğini satır bazlı ekrana yazdıran fonksiyon
// Dinamik buffer ihtiyacı olmadığı için herhangi bir Allocator kullanılmıyor
pub fn writeLines(filePath: []const u8) !void {
    // Dosyamızı read only modda açıyoruz
    var file = try std.fs.cwd().openFile(filePath, .{ .mode = .read_only });
    // Defer kullanımı söz konusu. Yani metot sonlanırken dosya da kapatılacak
    defer file.close();

    // Buffer kullanarak okuma yapacağımız için gerekli hazırlıklar
    var bufReader = std.io.bufferedReader(file.reader());
    var reader = bufReader.reader();
    // 256 byte uzunluğunda bir satır okuyacağımızı belirtiyoruz
    // 256 karakterden fazla bir satır olursa ne olur mesela?
    var lineBuffer: [256]u8 = undefined;

    // Burada sonsuz bir döngü söz konusu
    // line değişkeni End Of File'a gelene kadar satırları reader yardımıyla lineBuffer okuyacak
    while (true) {
        // orelse ve try kullanımlarına dikkat
        const line = try reader.readUntilDelimiterOrEof(&lineBuffer, '\n') orelse break;
        // satırı ekrana yazdırıyoruz
        std.debug.print("{s}\n", .{line});
    }
}
