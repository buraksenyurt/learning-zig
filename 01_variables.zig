const std = @import("std");

// const ve var keyword'leri ile değişken tanımlanabilir
// const ile tanımlanan değişkenlerin değeri değiştirilemez (immutable variable)
// var ile tanımlanan değişkenlerin değeri değiştirilebilir (mutable variable)
// Genelde değişken adından sonra : operatörü ve veri türü belirilir ancak zig derleyicisi
// tür çıkarımı (type inference) yapabildiği için tür belirtilmese de olur.
// Zig'in resmi dokümantasyonuna göre var yerine const kullanımı öneriliyor.

pub fn main() void {
    // // number isimli değişken var ile tanımlandıktan sonra değeri hiç değiştirilmediyse
    // var number: i32 = 250;
    // std.debug.print("Number is {}", .{number});

    // // derleyici şöyle bir hata mesajı veriyor.
    // // 01_variables.zig:11:9: error: local variable is never mutated
    // // var number: i32 = 250;
    // //     ^~~~~~
    // // 01_variables.zig:11:9: note: consider using 'const'

    // // Bu sorun bigNumber için söz konusu değil zira onun değişmez bir değer olduğunu const ile zaten belirttik.

    const bigNumber: u64 = 123456789012345;
    std.debug.print("Big number is {}\n", .{bigNumber});

    var pi: f32 = 0.0;
    pi = 3.14;

    // myLuckyNumber isimli değişken için type inference yapılıyor.
    // 7 için comptime_int türü kullanılır.
    const myLuckyNumber = 7;
    std.debug.print("My lucky number is {}\n", .{myLuckyNumber});

    // Javascript'çilerin aşina olduğu undefined türü gibi dursa da tamamen farklı bir kavram.
    // Zig'de undefined bir değeri temsil etmiyor, daha çok "değer atanmamış" anlamında kullanılıyor.
    // Bunu ilerleyen zamanlarda daha iyi kavramaya çalışacağım.
    // const unknownType: i32 = undefined;
    // std.debug.print("Unknown type value is {}\n", .{unknownType});

    // Hexadecimal (0x), Octal (0o), Binary (0b) sayısal değerler desteklenir.
    const hexValue: u8 = 0x1A;
    std.debug.print("Hex value is {x}\n", .{hexValue});

    const octValue: u8 = 0o32;
    std.debug.print("Octal value is {o}\n", .{octValue});

    // Rust dilindeki gibi büyük sayıları okunabilir kılmak için alt çizgi kullanılabilir
    const bigNumberValue: u64 = 1_000_000_000;
    std.debug.print("Big number with underscores is {d}\n", .{bigNumberValue});

    const binValue: u8 = 0b1010_1111;
    std.debug.print("Binary value is {b}\n", .{binValue});

    const charValue: u8 = 'A';
    std.debug.print("Character value is {c}\n", .{charValue});

    // cast işlemleri
    // Aşağıdaki gibi açık bir şekilde büyük bir türden küçük bir türe dönüşüm yapmak istediğimizde
    // dönüştürülmek istenen tür sınır dışında kalıyorsa derleyici hata verir;
    // çünkü veri kaybı olabilir. error: type 'u8' cannot represent integer value '1000000000'
    // const smallNumber: u8 = @intCast(bigNumberValue);
    // const smallNumber = @as(u8, bigNumberValue);
    // std.debug.print("Small number after cast is {d}\n", .{smallNumber});

    // Overflow operatörü
    // Bazı durumlarda veri kaybı yaşanabileceğini bilerek cast işlemi yapmak isteyebiliriz.
    // Bu gibi durumlarda owerflow operatörü kullanılabilir.
    // Örneğin aşağıdaki örnekte number1 ve number2 değişkenleri u8 türündendir.
    // number2 değişkeni u8 tipinden olduğu için 0-255 aralığında değer alabilir.
    // Ancak % operatörü ile overflow durumu bilinçli olarak kabul edilir.
    // Bazı matematiksel işlemlerde bu tip overflow durumları istenebilir. Örneğin kriptografik algoritmalarda.
    const number1: u8 = 255;
    const number2: u8 = number1 +% 10; // 255 + 10 = 265 -> 265 - 256 = 9 olacaktır
    std.debug.print("Number2 after overflow use is {d}\n", .{number2});

    // Aşağıdaki kullanım ise sorunsuz çalışır zira 100 sayısı u8 türünün sınırları içindedir.
    const numberA = 100;
    const numberB: u8 = @intCast(numberA);
    std.debug.print("Number B after cast is {d}\n", .{numberB});

    // Metinsel bir ifadeyi sayıya dönüştürmek için std kütüphaneden parseInt metodu kullanılabilir
    const numberStr = "1903";
    // Üçüncü parametre kaçlık sayı düzenini kullandığımızı ifade eder. Varsayılan olarak 10 luk sayı düzenidir.
    const convertedNumber = std.fmt.parseInt(u16, numberStr, 10) catch 0; // Eğer dönüştüremiyorsa 0 olarak kabul edilir
    std.debug.print("Converted number from string {d}", .{convertedNumber});

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

    // std kütüphanesindeki birçok fonksiyona @ operatörü ile erişebildiğini fark ettim
    const alpha = @mod(19, 3);
    std.debug.print("19 % 3 = {}\n", .{alpha});

    // Pek tabii modüle almak için birçok dilde olduğu gibi % operatörü de kullanılabilir
    const beta = 19 % 3;
    std.debug.print("19 % 3 = {}\n", .{beta});
}
