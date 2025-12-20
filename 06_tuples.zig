const std = @import("std"); // standart kütüphaneyi kullanacağımızı belirtiyoruz

pub fn main() void {
    // print fonksiyonunda da sıklıkla kullanılan Tuple türünden değişkenler de birer struct olarak düşünülebilir.
    // Örneğin aşağıdaki game değişkeni beş farklı türden alanı barındıran bir tuple türü.
    const game = .{ "Adventure of Zig", 2025, "Strategy, RPG", 7.9, "$19.99" };
    std.debug.print("Game Info:\n", .{}); // Tüm içeriğini doğrudan yazdırabiliriz
    std.debug.print("Title: {s}\n", .{game[0]}); // Ya da indislerle ulaşabiliriz
    std.debug.print("Release Year: {d}\n", .{game.@"1"}); // Ya da @"indis" şeklinde erişim sağlayabiliriz
    std.debug.print("Genres: {s}\n", .{game[2]});
    std.debug.print("Length of tuple is {d}\n", .{game.len}); // Bir tuple'ın byte cinsinden uzunluğu

    // // tuple türü ile ilgili önemli bir diğer husus da iç elemanlarını nasıl değiştirebileceğimizdir.
    // var origin = .{ 0.0, 0.0 };
    // std.debug.print("Origin type: {}\n", .{@TypeOf(origin)});
    // origin[0] = 10.0; // Burada derleme hatası alınır. error: cannot assign to constant
    // // Öncelikli olarak origin var ile tanımlanmalıdır ancak bu yeterli olmaz.
    // // Zira var ile tanımlasak bile derleyici bu kez şöyle bir hata verir
    // // error: value stored in comptime field does not match the default value of the field
    // // Bu son derece doğaldır çünkü tuple içeriğindeki elemanlar değiştirilemez comptime sabitlerdir.
    // // Burada çözüm olarak tuple içerisinde değiştirilebilir (mutable) olması beklenen elemanları dışarıdan verebiliriz.
    var x: i32 = 0.0;
    _ = &x;
    var origin = .{ x, 0.0 };
    std.debug.print("Origin type: {}\n", .{@TypeOf(origin)}); // x değişkeni artık comptime int değil i32 türündendir
    origin[0] = 10.0; // Artık derleme hatası alınmaz
    std.debug.print("Origin after change: ({d}, {d})\n", .{ origin[0], origin[1] });

    // Tuple'ları birbirleriyle birleştirebiliriz (concatenation)
    // Bunun için ++ operatörü kullanılır
    // Ya da kendisini tekrar ettirecek şekilde çoklayabiliriz. Bunun için de ** operatörü kullanılır
    const points = .{ 10, 20, 30 };
    const names = .{ "Jonathan", "Anderson", "Eva" };
    const combined = points ++ names;
    std.debug.print("Points and Names: {}\n", .{combined});

    const repeated = points ** 3;
    std.debug.print("Repeated Points: {}\n", .{repeated});
}
