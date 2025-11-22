const std = @import("std");
const common = @import("common.zig");

pub fn main() !void {
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

    // Bazı durumlarda slice (dilimler) çok işe yarar.
    // Bakalım zig'de nasıl kullanılıyorlar.
    // Bir slice genellikle bir pointer ve uzunluk bilgisi içerir ve bellekteki başka bir serinin belli bir parçasını kullanmamızı sağlar
    const someNumbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const slice1 = someNumbers[0..5]; // 0ncı indisten i 5nci indise kadar (5 dahil değil) olan kısmı alıyoruz
    printSlice(slice1);
    printSlice(someNumbers[5..]); // Burada ise 5nci indisten sonrasını alıyoruz

    // Slice'lar üzerinden değişiklik de yapabiliriz
    // Aşağıdaki örnek kod parçasında myNumbers isimli dizinin birkaç elemanını aldığımız bir slice söz konusu
    var myNumbers = [_]i32{ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 };
    var slice2 = myNumbers[2..7]; // 2nci indisten 7nciye kadar sayıları başka bir slice'a aldık
    // Ancak dikkat edelim const yerine var kullanıyoruz çünkü slice içeriğini değiştireceğiz
    slice2[0] = 300;
    slice2[3] = 600;
    printSlice(slice2);

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
        // createRandomInteger metodu hata fırlatabileceği için try ile çağırıyoruz
        // Bu aynı zamanda main metodunun da !void dönüş türüne sahip olmasını gerektirir
        const number = try common.createRandomInteger();
        if (number % 19 == 0) {
            std.debug.print("Breaking at iteration {d} with number {d}\n", .{ i, number });
            break;
        }
    }
}

// Burada metoda bir slice'ı parametre olarak geçiyoruz.
// Çağırdığımız yerdeki slice'lar const olduğundan burada da parametre tanımında const kullanılıyor.
// const'u kaldırıp build hatasına bakılabilir.
// Fonksiyon geriye bir şey döndürmüyor, sadece ekrana slice içeriğini yazdırıyor. Bu nedenle dönüş türü void.
fn printSlice(slice: []const i32) void {
    std.debug.print("\n", .{});

    for (slice, 0..) |element, index| {
        std.debug.print("{d}: {d}\n", .{ index, element });
    }
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
