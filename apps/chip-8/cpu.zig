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
};
