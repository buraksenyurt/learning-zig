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
    // continue ve break ifadelerini de kullanabiliyoruz.
    // test metodunda continue kullanımına dair bir örnek var.
    // Birde break örneği yapalım ama bu sefer standart kütüphaneden rand modülünü de kullanalım

    // Bazı kaynaklarda Zig'in 0.13 versiyonunda random sayı üretimi için std.rand namespace tanımlı
    // Ama tabii 0.14'te değişmiş. https://ziglang.org/download/0.14.0/release-notes.html adresindeki gibi release notları okumak lazım

    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    return rand.int(u8);
}
