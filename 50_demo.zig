const std = @import("std");
const utility = @import("utility.zig");
const string = @import("string.zig");

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
    try utility.writeLines("games.dat");

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

    // 04: C'ye yakın record tipleri (Record Literals)
    const Point = struct {
        x: i32,
        y: i32,
    };
    const p: Point = .{ .x = 10, .y = 20 };
    std.debug.print("Point Coordinates: ({d}, {d})\n", .{ p.x, p.y });

    // 06: Koşullu ifadelerde && ve || yerine "and" ve "or" kullanılır
    const a: bool = true;
    const b: bool = false;
    if (a and b) {
        std.debug.print("Both a and b are true\n", .{});
    } else if (a or b) {
        std.debug.print("At least one of a or b is true\n", .{});
    } else {
        std.debug.print("Both a and b are false\n", .{});
    }

    // 07 Python dilinde döngülerde else bloğu kullanılabilir.
    // Zig dili de bunu destekler.
    var found: bool = false;
    for (1..10) |_| {
        const number = utility.createRandomInteger() catch 0;
        std.debug.print("Checking number: {d}\n", .{number});
        if (number % 13 == 0) {
            std.debug.print("Found a number divisible by 13: {d}\n", .{number});
            found = true;
            break;
        }
    } else {
        std.debug.print("Loop completed without finding mod 13\n", .{});
    }

    // 08: Zig dilinde String diye bir kavram olmayabilir ama bu
    // kendi String veri yapımızı oluşturamayacağımız anlamına gelmez.
    const message = string.String.from("Wellcome back!");
    std.debug.print("{s}\n", .{message.data});
}

// 09 Birim testler kolay bir şekilde aşağıdaki gibi yazılabiliyor
// Test sonucunu görmek için terminalden `zig test demos.zig` komutunu çalıştırmak yeterli.
test "add function works correctly" {
    const result = add(5, 7);
    try std.testing.expect(result == 12);
}

// 05: Rust' ta fonskiyon dönüşlerinde -> operatörü vardır
// // fn add(a: i32, b: i32) -> i32 {
// //     return a + b;
// // }
// Zig'te -> yoktur, dönüş tipi fonksiyon adından sonra direkt belirtilir.
// Ancak Zig daha statement odaklı bir dildir. Bu nedenle dönüş ifadesi
// return anahtar kelimesi ile yapılır.
fn add(a: i32, b: i32) i32 {
    return a + b;
}
