const std = @import("std");
const common = @import("common.zig");

// Dizi türü bir programlama dilinin vazgeçilmezi.
// Her şey ama her şey bir dizi ile ifade edilebilir mi? Who cares? :D
pub fn main() void {
    // Bir dizi tanımlanırken eleman sayısı ve türü açıkça belirtilebilir
    // Örneğin 32 bit integer sayılardan oluşan 5 elemanlı bir dizi;
    const numbers = [5]i32{ 1, 5, 9, -2, -3 };
    std.debug.print("Number count {}\n", .{numbers.len}); // dizi boyutunu bulmak için len field'ını kullanabiliriz

    for (numbers) |n| {
        std.debug.print("{d}, ", .{n});
    }

    common.println();

    // Dizideki eleman sayısını belirtmek zorunda değiliz
    // _ operatörü ile bunu zig'e bırakabiliriz
    const points = [_]f32{ 1.3, 1.24, 5.55, 0.46 };
    for (points) |p| {
        std.debug.print("{d:.2}, ", .{p});
    }

    common.println();

    // metinsel ifadelerden oluşan bir array tanımı
    // [_], eleman sayısını sen bul
    // []const u8 ile de her biri u8 array olacak türden bir seri olacağını belirtmiş oluyoruz
    var colors = [_][]const u8{ "red", "green", "blue", "yellow", "green" };
    // Döngülerde öğrendiğimiz gibi dizi elemanlarını dolaşırken index değerlerini de alabiliriz
    for (colors, 0..) |color, id| {
        std.debug.print("{d}:{s}\n", .{ id, color });
    }

    common.println();

    // var keyword ile tanımladığımız için dizi elemanlarında değişiklik yapabiliriz.
    colors[colors.len - 1] = "cyan";

    for (colors, 0..) |color, id| {
        std.debug.print("{d}:{s}\n", .{ id, color });
    }

    common.println();
}
