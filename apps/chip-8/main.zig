// Bu örnekte Joseph Weisbecker tarafından geliştirilmiş CHIP-8 isimli interpretter'ın bir uygulaması ele alınmaktadır.
// CHIP-8 hakkında detaylı bilgi almak için https://tr.wikipedia.org/wiki/CHIP-8
// Amaç hem zig pratiği yapmak hem de bilgisayarın gerçekten nasıl çalıştığını anlamak. CHIP-8'in temel özellikleri şunlardır:
// - 4K bellek (4096 byte)
// - 16 adet 8-bit register (V0-VF)
// - Stack. Çağırılan fonksiyonların geri dönüş adreslerini tutar.
// - Display. 64x32 piksel çözünürlüğünde siyah-beyaz bir ekran.
// - Input. 16 tuşlu hex klavye (0-9, A-F)

const std = @import("std");
const cpu = @import("cpu.zig").Cpu;

pub fn main() void {
    std.debug.print("CHIP-8 Emulator", .{});
    const the_cpu = cpu.init();
    _ = the_cpu;
}
