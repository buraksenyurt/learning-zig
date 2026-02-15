// Joseph Weisbecker tarafından geliştirilmiş CHIP-8 isimli yorumlayıcının zig ile temel bir klonu
// CHIP-8 hakkında detaylı bilgi almak için https://chip-8.github.io/links/
// Amaç hem zig pratiği yapmak hem de bilgisayarın gerçekten nasıl çalıştığını anlamak.
// CHIP-8 emülatörünün temel muhteviyatı:
// - 4K bellek (4096 byte)
// - 16 adet 8-bit register (V0-VF)
// - Stack. Çağırılan fonksiyonların geri dönüş adreslerini tutar.
// - Display. 64x32 piksel çözünürlüğünde siyah-beyaz bir ekran.
// - Input. 16 tuşlu hex klavye (0-9, A-F)

const std = @import("std");
const Cpu = @import("cpu.zig").Cpu;

pub fn main() !void {
    std.debug.print("CHIP-8 Emulator", .{});
    // CHIP-8 Rom dosyaları için https://github.com/loktar00/chip8/tree/master/roms adresine epey örnek var.
    var cpu = Cpu.init();
    // IBM_Logo.ch8 isimli rom dosyası, CHIP-8'de ekranın ortasında IBM logosunu çizen bir program içerir.
    try cpu.loadRom("ibm_logo.ch8");

    // Emülatörün ana döngüsü.
    // Bu döngüde CPU'nun repl fonksiyonu çağrılır ve böylece CHIP-8 programı çalıştırılır.
    while (true) {
        cpu.repl();

        // CPU'nun program counter'ı her 10 komutta bir ekrana yazdırılır.
        // Böylece programın nasıl ilerlediğini gözlemleyebiliriz.
        // Normalde gerçek bir emülatör yazmadığımızdan şimdilik bu kadar basit bir çıktı yeterli olur.

        if (cpu.pc % 10 == 0) {
            std.debug.print("PC: {x} I:{x} V0: {d}\n", .{
                cpu.pc,
                cpu.i,
                cpu.v[0],
            });
        }

        std.time.sleep(2 * 1000 * 1000);
        // 2 ms bekle. CHIP-8'de her komut yaklaşık 500 Hz hızında çalışmakta.
        // Bir başka deyişle her 2 mili saniyede bir komut çalıştırılır.
    }
}
