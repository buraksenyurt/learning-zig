const std = @import("std");

// !void burada error union type olarak ifade ediliyor.
// yani main fonksiyonu void olabilir veya bir error throw edilebileceğini belirtecek şekilde error void dönebilir
pub fn main() !void {
    // Biraz da koşullu ifadelere ve döngülere bakalım

    const myPoint = 55;
    const yourPoint = 60;
    if (myPoint > yourPoint) {
        std.debug.print("Congrats! You win with `{}` point.\n", .{yourPoint});
    } else {
        std.debug.print("I win with `{}` point.\n", .{myPoint});
    }

    const yourScore = 55;
    if (yourScore > 50 and yourScore < 50) {
        std.debug.print("Not passed. Your point is F.\n", .{});
    } else if (yourScore >= 50 and yourScore < 70) {
        std.debug.print("Passed with C.\n", .{});
    } else if (yourScore >= 70 and yourScore < 90) {
        std.debug.print("Passed with B.\n", .{});
    } else if (yourScore >= 90 and yourScore <= 100) {
        std.debug.print("Passed with A.\n", .{});
    } else {
        std.debug.print("What a score huh!\n", .{});
    }

    // Bir while döngüsü yazalım
    var counter: usize = 1;
    while (counter <= 10) {
        std.debug.print("{} ", .{counter});
        counter += 1;
    }
    std.debug.print("\n", .{});

    // Birde for döngüsü yazalım
    // 110 ile 125 arasındaki sayıların çift veya tek sayı olduklarına dair ekrana bilgi yazdırıyoruz
    for (110..126) |number| {
        if (@rem(number, 2) == 0) {
            std.debug.print("{} is even\n", .{number});
        } else {
            std.debug.print("{} is odd\n", .{number});
        }
    }

    // Çok doğal olarak diziler tanımlayıp çalışmak lazım
    const numbers: [5]i32 = .{ 10, 20, 30, 40, 50 };
    // dizi elemanlarına indeksler ile erişebiliriz
    std.debug.print("First element is {d}\n", .{numbers[0]});
    // Pek tabii tüm dizi elemanlarını aşağıdaki gibi dolaşabiliriz
    for (numbers) |num| {
        std.debug.print("{d} ", .{num});
    }

    std.debug.print("\n", .{});

    // Sayı dizisini şöyle de tanımlayabiliriz
    const points = [_]i32{ 15, 25, 35, 45, 55 };
    for (points) |p| {
        std.debug.print("{d} ", .{p});
    }

    std.debug.print("\n", .{});

    const colors = [_][]const u8{ "Black", "Blue", "Red", "Green", "Pink" };
    for (colors) |color| {
        std.debug.print("{s}\n", .{color});
    }

    // Dizideki bir elemana indis ile erişim değerini değiştirelim
    var anArray = [3]i32{ 1, 2, 3 };
    anArray[1] = 20;
    for (anArray) |value| {
        std.debug.print("{d} ", .{value});
    }

    std.debug.print("\n", .{});

    const chars: []const u8 = &.{ 'h', 'e', 'l', 'l', 'o' };
    // Dizideki elemanlarına index değerleri birlikte ulaşmak istersek aşağıdaki formatı kullanabiliriz.
    for (chars, 0..) |value, index| {
        std.debug.print("{d}. -> {c}, ", .{ index, value });
    }

    std.debug.print("\n", .{});
}
