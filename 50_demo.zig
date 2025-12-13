const std = @import("std");
const utility = @import("utility.zig");
const string = @import("system.zig").String;
const rand = @import("rand.zig");

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
    // mem.eql fonksiyonu iki dizinin eşit olup olmamasının kontrolünde de kullanılır.
    // Hoş, yukarıdaki örnekte zaten diziler kullanılıyor.
    const arr1: [5]u8 = .{ 1, 2, 3, 4, 5 };
    const arr2: [5]u8 = .{ 1, 2, 3, 4, 5 };
    if (std.mem.eql(u8, &arr1, &arr2)) {
        std.debug.print("Arrays are equal\n", .{});
    } else {
        std.debug.print("Arrays are NOT equal\n", .{});
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
        const number = rand.getU8() catch 0;
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
    const message = string.from("Wellcome back!");
    std.debug.print("{s}\n", .{message.data});

    // 10: Integer türlerde özel bit boyutları kullanılabilir
    const smallInt: i3 = 2; // 3 bit işaretli integer
    const largeInt: u40 = 1099511627775; // 40 bit işaretsiz integer
    std.debug.print("Small Int (i3): {d}, Large Int (u40): {d}\n", .{ smallInt, largeInt });
    // 80 bit float türü de mevcuttur ama float türlerde kendi boyutlarımızı veremeyiz
    // f16, f32, f64, f80, f128 türleri vardır
    const someFloat: f80 = 3.14159265358979323846264338327950288419716939937510;
    std.debug.print("Some Float (f80): {d}\n", .{someFloat});

    // 09: block ifadeleri
    // Bir block { ... } ifadesi bir değer döndürebilir. Bunun için block'a bir isim verilir
    // ve break ifadesi ile block'tan çıkılırken bir değer döndürülebilir.
    const value: i32 = sampleBlock: {
        var sum: i32 = 0;
        for (1..6) |i| {
            sum += @as(i32, @intCast(i));
            if (sum > 10) {
                break :sampleBlock sum; // block'tan sum değeri ile çık
            }
        }
        break :sampleBlock 0; // block'tan 0 değeri ile çık
    };
    std.debug.print("Block result value: {d}\n", .{value});

    // 10: Conditional If Kullanımı
    const isFound: ?bool = searchTitle("Zig Programming Language");
    if (isFound) |result| {
        std.debug.print("Title search result: {}\n", .{result});
    } else {
        std.debug.print("Title not found\n", .{});
    }
}

// Semboil bir arama fonksiyonu.
// Bunu conditional if örneğinde kullanmak için yazdık.
fn searchTitle(title: []const u8) ?bool {
    return if (std.mem.eql(u8, title, "Zig Programming Language")) true else null;
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
