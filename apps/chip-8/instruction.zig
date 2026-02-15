const std = @import("std");

// Instructon komutlarını hexadecimal olarak okumak çok kolay değil
// Bir union enum kullanarak işi kolaylaştıralım

// Instruction'lar farklı türlerde veri içerebilirler.
// Örneğin bazı komutlar sadece bir adres içerirken bazıları register index'i ve bir değer içerebilir.
pub const Instruction = union(enum) {
    clearScreen, // 00E0 Ekranı temizle komutu
    returnSubroutine, // 00EE Alt programdan geri dön komutu
    jump: u16, // 1NNN NNN adresine sıçrama komutu
    callSubroutine: u16, // 2NNN NNN adresindeki alt programı çağır komutu
    setRegister: struct { x: u4, nn: u8 }, // 6XNN (Vx = NN) register'ı NN değeri ile günceller
    addImmediate: struct { x: u4, nn: u8 }, // 7XNN (Vx += NN) komutu, Vx register'ına NN değerini ekler
    setIndex: u16, // ANNN (I = NNN) komutu, index register'ını NNN değeri ile günceller
    unknown: u16,
};

// decode fonksiyonu, 16 bit'lik bir opcode'u alır ve bu opcode'un hangi komutu temsil ettiğini belirler.
pub fn decode(opCode: u16) Instruction {
    const nnn = opCode & 0x0FFF; // nnn değeri, opcode'un son 12 bit'ini temsil eder
    const nn = @as(u8, @truncate(opCode & 0x00FF)); // nn değeri, opcode'un son 8 bit'ini temsil eder
    const x = @as(u4, @truncate((opCode & 0x0F00) >> 8)); // x değeri, opcode'un 8-11 bit'lerini temsil eder (register index'i)

    // opcode'un ilk 4 bit'ine göre hangi komutun söz konusu olduğu belirlenir
    return switch (opCode & 0xF000) {
        // 0x0000 ile başlayan opcode'lar genellikle özel komutları temsil eder
        0x0000 => switch (opCode & 0x00FF) {
            // Örneğin 00E0 komutu ekranı temizler, 00EE komutu ise alt programdan geri dönmeyi sağlar
            0xE0 => .clearScreen,
            0xEE => .returnSubroutine,
            else => .{ .unknown = opCode },
        },
        // 0x1000 ile başlayan opcode'lar genellikle bir adrese sıçrama(JUMP) komutlarını temsil eder
        0x1000 => .{ .jump = nnn },
        // 0x2000 ile başlayan opcode'lar genellikle alt program çağırma komutlarını temsil eder
        0x2000 => .{ .callSubroutine = nnn },
        // 0x6000 ile başlayan opcode'lar genellikle register'lara değer atama komutlarını temsil eder
        0x6000 => .{ .setRegister = .{
            .x = x,
            .nn = nn,
        } },
        // 0x7000 ile başlayan opcode'lar genellikle register'lara değer ekleme komutlarını temsil eder
        0x7000 => .{ .addImmediate = .{
            .x = x,
            .nn = nn,
        } },
        // 0xA000 ile başlayan opcode'lar genellikle index register'ını güncelleme komutlarını temsil eder
        0xA000 => .{ .setIndex = nnn },
        else => .{ .unknown = opCode },
    };
}
