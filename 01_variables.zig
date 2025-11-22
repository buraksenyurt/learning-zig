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

    const hexValue: u8 = 0x1A;
    std.debug.print("Hex value is {x}\n", .{hexValue});

    const binValue: u8 = 0b1010_1111;
    std.debug.print("Binary value is {b}\n", .{binValue});

    const charValue: u8 = 'A';
    std.debug.print("Character value is {c}\n", .{charValue});

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
