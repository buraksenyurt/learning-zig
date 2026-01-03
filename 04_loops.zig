const std = @import("std");
const utility = @import("utility.zig");
const rand = @import("rand.zig");

pub fn main() !void {
    // Bir while döngüsü yazalım
    var counter: usize = 1;
    while (counter <= 10) {
        std.debug.print("{} ", .{counter});
        counter += 1;
    }
    std.debug.print("\n", .{});

    // while döngülerinde sayaçlar : operatörü sonrası koşul kısmında da belirtilebilir.
    var totalOfFirstTen: u16 = 0;
    var ctr: u16 = 1;
    while (ctr <= 100) : (ctr += 1) {
        totalOfFirstTen += ctr;
    }
    std.debug.print("Sum of 1 to 100 is {d}\n", .{totalOfFirstTen});

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

    const sensorValues: [5]f32 = .{ 24.50, 21.20, 19.90, 23.20, 21.02 };
    var total: f32 = 0.0;

    for (sensorValues) |v| {
        total += v;
    }
    const average = total / sensorValues.len;
    std.debug.print("Average value is {}\nCritical values are;\n", .{average});

    for (sensorValues, 0..) |value, i| {
        if (value > average) {
            std.debug.print("{}. {}", .{ i, value });
        }
    }

    std.debug.print("\n", .{});

    for (1..1000) |i| {
        // getU8 metodu hata fırlatabileceği için try ile çağırıyoruz
        // Bu aynı zamanda main metodunun da !void dönüş türüne sahip olmasını gerektirir
        const number = try rand.getU8();
        if (number % 19 == 0) {
            std.debug.print("Breaking at iteration {d} with number {d}\n", .{ i, number });
            break;
        }
    }

    // Döngüleri birer expression olarak da kullanabiliriz
    // Aşağıda bunun iki farklı örneği yer alıyor.
    // İlk örnekte while döngüsünü bir epxression olarak kullanıyoruz
    // 1'den 100'e kadar olan sayıların toplamını hesaplayıp sum değişkenine atıyoruz
    var sum: i16 = 0;
    const begin: u16 = 1;
    const end: u16 = 100;
    sum = while (true) {
        var tempSum: i16 = 0;
        for (begin..end + 1) |n| {
            tempSum += @intCast(n);
        }
        break tempSum;
    };
    std.debug.print("Sum of 1 to 100 is {d}\n", .{sum});

    const target: u8 = 77;
    const arr: [5]u8 = .{ 10, 25, 50, 77, 100 };
    const found = contains(&arr, target);
    if (found) {
        std.debug.print("Array contains the target value: {d}\n", .{target});
    } else {
        std.debug.print("Array does not contain the target value: {d}\n", .{target});
    }

    // Döngülerde block labeling de yapabiliriz
    outerLoop: for (1..100) |i| {
        for (1..100) |j| {
            const prod = i * j;
            if (prod % 13 == 0) {
                std.debug.print("Found a product divisible by 13: {d} * {d} = {d}\n", .{ i, j, prod });
                break :outerLoop;
            }
        }
    }
}

fn contains(arr: []const u8, target: u8) bool {
    // Burada da bir for döngüsü expression olarak kullanılıyor
    return for (arr) |value| {
        if (value == target) {
            break true;
        }
    } else false;
}

const expect = std.testing.expect;

test "continue under some condition in while loop" {
    var sum: u16 = 0;
    var i: u16 = 0;
    while (i <= 100) : (i += 1) {
        if (i % 2 == 0) continue; // 2 ile bölünen bir sayı ise döngünün bir sonraki iterasyonundan devam et
        sum += i;
    }

    // Birçok dilde bu şekilde fail eden bir test yazıldığında asıl hesaplanan değer de loga düşer
    // Yani, ben 2500 bekliyordum ama 10 aldım gibisinden
    // Zig aşağıdaki fail durumu için şöyle bir mesaj verdi
    // try expect(sum == 10);

    // // 1/1 03_cond_loops.test.use continue in while loop...FAIL (TestUnexpectedResult)
    // // C:\ZigWindows\lib\std\testing.zig:604:14: 0x7ff746a4102f in expect (test_zcu.obj)
    // //     if (!ok) return error.TestUnexpectedResult;
    // //             ^
    // // C:\Users\burak\Development\learning-zig\03_cond_loops.zig:138:5: 0x7ff746a41155 in test.use continue in while loop (test_zcu.obj)
    // //     try expect(sum == 10);
    // //     ^
    // // 0 passed; 0 skipped; 1 failed.
    try expect(sum == 2500);
}
