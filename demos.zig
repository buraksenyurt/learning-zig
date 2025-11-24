const std = @import("std");
const common = @import("common.zig");

pub fn main() !void {
    // todo@buraksenyurt: Demo için başka ilginç örnekler ekle.

    // #00: String Comparisons
    // String yok. Onun yerine []const u8 kullanılıyor.
    // Peki iki string içeriğinin eşit olup olmadığını nasıl kontrol ederiz?
    const str1: []const u8 = "Zig Programming Language";
    const str2: []const u8 = "Zig Language";
    if (std.mem.eql(u8, str1, str2)) {
        std.debug.print("Strings are equal: {s} == {s}\n", .{ str1, str2 });
    } else {
        std.debug.print("Strings are NOT equal: {s} != {s}\n", .{ str1, str2 });
    }

    // #01: Dış Modülden Fonksiyon Çağırma
    // games.data içeriğini satır satır okuma
    try common.writeLines("games.dat");

    // #02: Pointer Mevzusu
    var numbers = [_]u8{ 1, 2, 3, 4, 5 };
    var ptrNumbers: [*]u8 = &numbers; // multi-item pointer
    for (0..10) |_| {
        std.debug.print("Pointer Address: {*}, Value: {d}\n", .{ ptrNumbers, ptrNumbers[0] });
        ptrNumbers += 1;
    }

    // 03: Belki Pattern Matching tınısı vardır
    // "switch must handle all possibilities"
    const Color = enum {
        Red,
        Green,
        Blue,
    };
    const myColor = Color.Blue;
    switch (myColor) {
        Color.Red => std.debug.print("Red: {0x}\n", .{0xFF0000}),
        Color.Green => std.debug.print("Green: {0x}\n", .{0x00FF00}),
        Color.Blue => std.debug.print("Blue: {0x}\n", .{0x0000FF}),
    }
}
