// Sanal makine state'ini tutacağımız veri yapısı

const std = @import("std");

pub const Cpu = struct {
    memory: [4096]u8, // 4 Kb'lık bir bellek alanı tanımlanır
    v: [16]u8, // V0 dan VF'e kadar olan register'lar için kullanılır
    i: u16, // Index register'ı dır (I). Bellek adreslerini tutmak için.
    pc: u16, //Aktif olarak çalışmakta olan komut adresini tutmak için
    stack: [16]u16, // Stack veri yapısını temsil eder
    sp: u8, // Stack pointer'ı
    delay_timer: u8, // Geri sayım sayacıdır. 60 Hz hızında çalışmalı.
    sound_timer: u8,
    gfx: [64 * 32]u8, // 64 x 32 lik ekranı temsil eder. u8 türünden. 1 = white, 0 = black
    key: [16]u8, // Tuşa basılıp basılmadı bilgisi.
    pub fn init() @This() {
        return .{
            .memory = [_]u8{0} ** 4096, // 4KB'lık belleği temizleyerek başlatıyoruz
            .v = [_]u8{0} ** 16,
            .i = 0,
            .pc = 0x200, // 512 adresini temsil eder. İlk 512 byte'ı register'lar için rezerver ettiğimiz düşünelim.
            .stack = [_]u16{0} ** 16, // Stack'i temizleyerek başlatıyoruz
            .sp = 0,
            .delay_timer = 0,
            .sound_timer = 0,
            .gfx = [_]u8{0} ** (64 * 32), // Ekranı da temizleyerek başlatıyoruz ki tüm ekran siyah
            .key = [_]u8{0} ** 16,
        };
    }
    pub fn repl(self: *@This()) void {
        // Bu fonksiyon instruction yani operasyon kodunu alan FETCH,
        // Bu operasyon kodunun ne anlama geldiğini çözem DECODE,
        // Ve çözülen operasyon koduna göre bir takım matematik işlemleri yapan ya da bir şeyler çizen
        // veya bellekte bir yerlere sıçramayı sağlayan EXECUTE aşamalarını ele alır.

        // Bellekten 2 byte'lık komutu oku. CHIP-8'de her komut 2 byte uzunluğunda ama bellek 1 byte genişliğinde.
        // Bu nedenle, iki byte'ı birleştirerek tek bir 16-bit opcode oluşturulmakta.
        const operation_code: u16 = (@as(u16, self.memory[self.pc]) << 8) | self.memory[self.pc + 1];
        self.pc += 2; // Her komut 2 byte olduğu için program counter'ı 2 artırıyoruz

        // Burada bitwise maskeleme işlemi yapılır ve böylece Operasyon kodu parçalara bölünebilir.
        // Operasyon kodları önemli zira herbiri bir işlevi temsil etmekte.
        // https://chip8.gulrak.net/ adresinde detaylı bir içerik de mevcut.
        switch (operation_code & 0xF000) {
            0x0000 => {
                // 00E0 (Clear Screen) anlamında
                // 00EE ise (Return) anlamında
                switch (operation_code & 0x00FF) {
                    0xE0 => {
                        // Clear Screen komutu söz konusu ise @memset fonksiyonu ile gfx
                        // alanının tüm elemanları sıfıra çekilir. Yani ekran karartılır.
                        @memset(&self.gfx, 0);
                    },
                    0xEE => {
                        // Return ile bir önceki stack noktasına dönmemiz gerekiyor
                        // O nedenle sp değeri 1 azaltılır ve pc isimli stack'te bu indisli yere gidilir.
                        self.sp -= 1;
                        self.pc = self.stack[self.sp];
                    },
                    else => {},
                }
            },
            0x1000 => {
                // 1NNN: NNN adresine sıçrama(JUMP) komutu gelmiştir
                // Bu durumda operasyon kodundan adres kısmını alıp (0x0FFF değeri ile bit maskeleme),
                // güncel komut adresi değiştirilir
                self.pc = operation_code & 0x0FFF;
            },
            0x6000 => {
                // 6XNN: VX register'ını NN'e set et der.
                // Operasyon Kodu şöyle bir anlama geliyor: 6 (Set), X (Reg Index), N N (Value)
                const x = (operation_code & 0x0F00) >> 8; // 0 ile 15 arasındaki index değerini elde etmek için 8 bit sağa kaydırma
                const nn = @as(u8, @truncate(operation_code & 0x00FF));
                self.v[x] = nn;
            },
            0x7000 => {
                // 7XNN komutu söz konusu ise NN değeri VX register'ına eklenir
                const x = (operation_code & 0x0F00) >> 8;
                // @truncate ile 16 bit'lik operation_code'un sadece son 8 bit'ini alarak NN değerini elde ediyoruz.
                const nn = @as(u8, @truncate(operation_code & 0x00FF));
                //
                self.v[x] +%= nn;
            },
            0xA000 => {
                // ANNN: Index Register(I) bilgisi NNN değeri ile günceller
                // Operasyon kodundan adres kısmını alıp (0x0FFF değeri ile bit maskeleme) yapılarak bu işlem gerçekleştirilir.
                self.i = operation_code & 0x0FFF;
            },
            // Burada daha birçok operasyon komutu söz konusu. Bunları şimdilik konu dışı bırakalım
            else => {
                std.debug.print("Unknown opcode: {X:0>4}\n", .{operation_code});
            },
        }

        // CHIP-8'de delay timer ve sound timer 60 Hz hızında çalışır.
        // Yani her saniyede 60 kez bu timer'ların değeri 1 azalır.
        if (self.delay_timer > 0) self.delay_timer -= 1;
        if (self.sound_timer > 0) self.sound_timer -= 1;
    }

    // Örneğin bir oyunu ROM'a yüklemek istersek bu fonksiyon yardımıyla bunu yapabiliriz.
    // ROM dosyasını açar, içeriğini okur ve bellekte 0x200 adresinden itibaren yerleştirir.
    // 0x200 adresi, CHIP-8'de programların başladığı standart adrestir.
    // İlk 512 byte'lık alan genellikle sistem tarafından rezerve edilir.
    pub fn loadRom(self: *@This(), fileName: []const u8) !void {
        const file = try std.fs.cwd().openFile(fileName, .{});
        defer file.close();

        const size = try file.readAll(self.memory[0x200..]);
        std.debug.print("ROM load is OK! {s} ({d} bytes)\n", .{
            fileName,
            size,
        });
    }
};
