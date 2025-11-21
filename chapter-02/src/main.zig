const std = @import("std"); // standart kütüphaneyi kullanacağımız belirtiyoruz
const lib = @import("lib.zig"); // aynı dizindeki lib.zig dosyasını import edebiliriz

pub fn main() void {
    // Player türünden bir değişken tanımı
    // const veya var keyword ile tanımlamalar yapılabiliyor
    const draga = Player{ .nick = "Ivan Dragaa", .power = 85, .level = -300 };

    // terminal çıktısı almak için print metodu kullanılıyor
    // s, metinsel ifadeleri, d sayısal ifadeleri işaret eden placeholder'lar
    // ikini parametre bir tuple olarak ifade ediliyor ve placeholder yerine gelecek değerler burada yazılıyor
    std.debug.print("{s} ({d})\n", .{ draga.nick, draga.level });

    // std.debug.print("\n"); // Bu şekilde kullanamıyoruz
    std.debug.print("\n", .{}); // Şeklinde boş bir tuple vermek gerekiyor.

    const content = lib.read_content(); // lib.zig dosyasındaki read_content fonksiyonunu çağırıyoruz
    std.debug.print("{s}\n", .{content}); // fonksiyondan dönen değeri yazdırıyoruz
}

// Bir veri yapısı tanımı
pub const Player = struct {
    nick: []const u8, // String türü yok onun yerine u8 türünden bir aray söz konusu
    power: u8, // Pozitif 8 bit tam sayı
    level: i32, // pozitif/negatif aralıklı 32 bit integer
};
