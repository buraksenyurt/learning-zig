// standart kütüphaneyi kullanacağımızı belirtiyoruz
const std = @import("std");

// klasik main fonksiyonu
// exe olarak uygulamanın giriş noktası
// pub keyword'e sahip olduğuna göre public erişilebilir
// void (yani geriye bir sonuç döndürmüyor)
pub fn main() !void {
    // terminale bir bilgi yazdırıyoruz.
    // {s} string ifadelerin yerini alıyor
    // {d} decimal olduğunu düşünüyorum.
    // args: tarafında {} arasında bir tuple veri türü kullanıyoruz
    // \n , alt satıra geç anlamında (new line)
    std.debug.print("Hello there.\nMy name is {s}.\n{s}\n{s}!\nAnd my lucky number is {d}.\n", .{ "Dam", "Van Dam", "Claude Van Dam", 23 });

    // Person burada otomatik olarak bir struct veri türüne dönüşüyor
    // İçerisinde iki alan var: birincisi string, ikincisi integer
    // person değişkeni bu struct türünden bir örnek (instance) gibi
    const person = .{
        "John Doe", // bu constant string türünden oluştu *const [8:0]u8 şeklinde bir sabit gibi.
        23, // comptime_int, derlenme zamanında bilinen integer türünden anlamında
    };
    // person değişkeninin alanlarına erişim için indeksleme kullanılıyor
    // {d} ve {s} yer tutucularına sırasıyla person[1] ve person[0] değerleri atanıyor
    std.debug.print("Hello there.\nMy name is {s}.\nAnd my lucky number is {d}", .{ person[0], person[1] });

    // Biraz da değişken tanımlayalım öyleyse

    // // point değişkenini aşağıdaki gibi tanımlayınca hiç içeriğini değiştirmediğim için derleme zamanı hatası aldım.
    // // Bu sorun bigNumber için söz konusu değil zira onun değişmez bir değer olduğunu const ile zaten belirttik.
    // // src\main.zig:31:9: error: local variable is never mutated
    // //     var number: i32 = 250;
    // //         ^~~~~~
    // // src\main.zig:31:9: note: consider using 'const'

    // var number: i32 = 250;
    // std.debug.print("Number is {}", .{number});

    const bigNumber: u64 = 123456789012345;
    std.debug.print("\nBig number is {}", .{bigNumber});

    var pi: f32 = 0.0;
    pi = 3.14;

    // // Yukarıda const türünden bir tuple kullanmıştık.
    // // Tuple'lar immutable türler. İçerikleri değiştirilemiyor anladığım kadarıyla.
    // // Söz gelimi aşağıdaki kod parçasını ele alalım.
    // // Burada tanımlı p1 tuple türünün 2nci alanının içeriğini değiştirmek istiyorum.
    // // Derleyici aşağıdaki hatayı veriyor
    // // error: value stored in comptime field does not match the default value of the field

    // var p1 = .{ 1001, "Monitor 1080P", 1983.30, false };
    // p1[2] = 2000.00;
    // std.debug.print("New price is {d}", .{p1[2]});

    // Dolayısıyla içeriği değiştirilebilir bir veri türü için struct kullanmak gerekiyor
    // Product isimli struct içinde 32 bit işaretli integer, u8 türününde dizi olarak ifade edilen string
    // 32 bit floating-point bir başka değer ile boolean bir alan yer alıyor.
    const Product = struct {
        id: i32,
        name: []const u8,
        price: f32,
        available: bool,
    };

    var product = Product{
        .id = 1001,
        .name = "ElCi Optik Mouse",
        .price = 190.40,
        .available = true,
    };

    // Fiyat bilgisini değiştirebiliriz.
    product.price *= 0.90;
    // {d:.3} ifadesi ile ondalık kısmı 3 basamak olarak formatlıyoruz
    std.debug.print("\n{s} list price is {d:.3}", .{ product.name, product.price });
}
