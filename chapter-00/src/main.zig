// standart kütüphaneyi kullanacağımızı belirtiyoruz
const std = @import("std");

// klasik main fonksiyonu
// exe olarak uygulamanın giriş noktası
// pub keyword'e sahip olduğuna göre public erişilebilir
// void olduğu için geriye bir şey döndürmediğini ifade edebiliriz.
pub fn main() void {
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
    std.debug.print("Hello there.\nMy name is {s}.\nAnd my lucky number is {d}\n", .{ person[0], person[1] });

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
    std.debug.print("Big number is {}\n", .{bigNumber});

    var pi: f32 = 0.0;
    pi = 3.14;

    const hexValue: u8 = 0x1A;
    std.debug.print("Hex value is {x}\n", .{hexValue});

    const binValue: u8 = 0b1010_1111;
    std.debug.print("Binary value is {b}\n", .{binValue});

    const charValue: u8 = 'A';
    std.debug.print("Character value is {c}\n", .{charValue});

    // // Yukarıda const türünden bir tuple kullanmıştık(person)
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
    // Aşağıdaki yazım şeklinde özellikle name alanının nasıl yazıldığına dikkat edelim.
    std.debug.print("\n{}\n", .{product});

    const z = sum(3, 5);
    std.debug.print("Sum of 3 and 5 is {}\n", .{z});

    // std kütüphanesindeki birçok fonksiyona @ operatörü ile erişebildiğini fark ettim
    const alpha = @mod(19, 3);
    std.debug.print("19 % 3 = {}\n", .{alpha});

    // Pek tabii modüle almak için birçok dilde olduğu gibi % operatörü de kullanılabilir
    const beta = 19 % 3;
    std.debug.print("19 % 3 = {}\n", .{beta});

    // Aşağıdaki örnek kodda title içerisindeki karakterleri tek tek terminale yazdırıyoruz.
    const title = "The Legend of Zig";

    // title içeriği u8 türünden bir dilim (slice) olarak ifade ediliyor.
    for (title) |c| {
        std.debug.print("{c} ", .{c});
    }
    std.debug.print("\n", .{});

    // Burada da title içeriğinin ilk 10 karakterini alıp ekrana basıyoruz
    std.debug.print("{s}\n", .{title[0..10]});

    std.debug.print("Temperature Conversions:\n", .{});
    const celsius: f32 = 24.0;
    const fahrenheit: f32 = celciusToFahrenheit(celsius);
    std.debug.print("{d:.2} C is {d:.2} F\n", .{ celsius, fahrenheit });

    const celsius2: f32 = fahrenheitToCelcius(fahrenheit);
    std.debug.print("{d:.2} F is {d:.2} C\n", .{ fahrenheit, celsius2 });
}

// Çok basit bir aritmetik fonksiyon tanımı
// i32 türünden iki parametre alıyor ve i32 türünden değer döndürüyor
fn sum(x: i32, y: i32) i32 {
    return x + y;
}

fn celciusToFahrenheit(celsius: f32) f32 {
    return (celsius * 9.0 / 5.0) + 32.0;
}

fn fahrenheitToCelcius(fahrenheit: f32) f32 {
    return (fahrenheit - 32.0) * 5.0 / 9.0;
}
