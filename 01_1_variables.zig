const std = @import("std");
// print fonksiyonu için aşağıdaki gibi bir değişken tanımı yaparak kullanımını kısaltabiliriz
const print = @import("std").debug.print;

// const ve var keyword'leri ile değişken tanımlanabilir
// const ile tanımlanan değişkenlerin değeri değiştirilemez (immutable variable)
// var ile tanımlanan değişkenlerin değeri değiştirilebilir (mutable variable)
// Genelde değişken adından sonra : operatörü ve veri türü belirilir ancak zig derleyicisi
// tür çıkarımı (type inference) yapabildiği için tür belirtilmese de olur.
// Zig'in resmi dokümantasyonuna göre var yerine const kullanımı öneriliyor.

pub fn main() void {
    // // number isimli değişken var ile tanımlandıktan sonra değeri hiç değiştirilmediyse
    // var number: i32 = 250;
    // print("Number is {}", .{number});

    // // derleyici şöyle bir hata mesajı veriyor.
    // // 01_variables.zig:11:9: error: local variable is never mutated
    // // var number: i32 = 250;
    // //     ^~~~~~
    // // 01_variables.zig:11:9: note: consider using 'const'

    // // Bu sorun bigNumber için söz konusu değil zira onun değişmez bir değer olduğunu const ile zaten belirttik.

    const bigNumber: u64 = 123456789012345;
    print("Big number is {}\n", .{bigNumber});

    var pi: f32 = 0.0;
    pi = 3.14;

    // myLuckyNumber isimli değişken için type inference yapılıyor.
    // 7 için comptime_int türü kullanılmakta.

    const myLuckyNumber = 7;
    print("My lucky number is {}\n", .{myLuckyNumber});
    // Değişken isimlendirmelerinde illegal karakter kullanımı söz konusu değilse @ operatöründen yararlanılabilir.
    const @"Part$1001@Stock" = "This is a variable with special characters in its name.";
    print("{s}\n", .{@"Part$1001@Stock"});

    // const türlerde yukarıdaki gibi tip tahmileri sorun teşkil etmez ancak var türlerinde sıkıntı olabilir.
    // Örneğin aşağıdaki kullanım derleme hatası verir:  error: variable of type 'comptime_int' must be const or comptime
    // Burada 0 değeri comptime_int türündendir. comptime'lar derleme zamanında mutlaka bilinen sabitlerdir.
    // Sabit oldukları için de variable olarak tanımlanamazlar. Dolayısıyla var tanımlarında türün açıkça belirtilmesi gerekir.
    // var myLuckyNumber2 = 0;
    // myLuckyNumber2 = 42;
    // print("My second lucky number is {}\n", .{myLuckyNumber2});

    // Javascript'çilerin aşina olduğu undefined türü gibi dursa da tamamen farklı bir kavram.
    // Zig'de undefined bir değeri temsil etmiyor, daha çok "değer atanmamış" anlamında kullanılıyor.
    // Bunu ilerleyen zamanlarda daha iyi kavramaya çalışacağım.
    // const unknownType: i32 = undefined;
    // print("Unknown type value is {}\n", .{unknownType});

    // Eğer henüz kullanmayacağımız bir değişken söz konusu ise
    // const için derleyici normalde hata verir.
    // ancak aşağıdaki gibi _ (underscore) ataması ile geçici olarak bunun önüne geçilebilir.
    const value: f32 = 3.1415;
    _ = value;
    // Ancak yukarıdaki senaryo var ile tanımlanan variable'lar için geçerli değildir.
    // Aşağıdaki kullanım derleme hatası verir
    // Lakin burada da istisani bir durum var. & operatörü ile referans alındığında sorun ortadan kalkar.
    // Bana kalırsa development ve debug amaçlı kullanımlarda bu tür atamalar yapılabilir.
    // var value2: i32 = 1903;
    // _ = value2;
    var value2: i32 = 1903;
    _ = &value2;

    // Hexadecimal (0x), Octal (0o), Binary (0b) sayısal değerler desteklenir.
    const hexValue: u8 = 0x1A;
    print("Hex value is {x}\n", .{hexValue});

    const octValue: u8 = 0o32;
    print("Octal value is {o}\n", .{octValue});

    // Rust dilindeki gibi büyük sayıları okunabilir kılmak için alt çizgi kullanılabilir
    const bigNumberValue: u64 = 1_000_000_000;
    print("Big number with underscores is {d}\n", .{bigNumberValue});

    const binValue: u8 = 0b1010_1111;
    print("Binary value is {b}\n", .{binValue});

    // Bir karakter tanımlamak için u8 türü veya u7 türü kullanılabilir
    // Aslında karakterler için ayrılmış özel bir tür yoktur. Her bir karakter sayısal bir değer ile ifade edilir
    // Bu sayısal değer tahmin edileceği üzere ASCII tablosundan gelir
    const letterA: u8 = 'A';
    const letterB: u7 = 'B';
    // Ancak tür belirtmesek de olur. ' ' işaretlerinde type inference yapılır
    const letterC = 'C';
    print("{c},{c},{c}\n", .{ letterA, letterB, letterC });

    // String ifadeler için ise u8 türünden diziler kullanılır
    // Bir başka deyişle string ifadelere birer byte array' dir.
    const motto: []const u8 = "I am learning Zig, programming language.";
    print("{s}\n", .{motto});
    // birden fazla string içeriği birleştirmek için(concatenation) ++ operatörü kullanılır
    const fullMotto = motto ++ " " ++ "It's really fun!";
    print("{s}\n", .{fullMotto});
    print("Type of a string is {}\n", .{@TypeOf(fullMotto)});

    // string ifadeler var ile tanımlansalar bile değiştirilemezler (immutable)
    // Aşağıdaki kullanım derleme hatası verir: error: cannot assign to constant
    // var greeting: []const u8 = "Hello, World!";
    // greeting[0] = 'B'; // Hata verir
    // print("{s}\n", .{greeting});

    const oneNumber: u8 = 1;
    print("1 is {d}\n", .{oneNumber});
    print("1 in hex is {x}\n", .{oneNumber});
    print("1 in octal is {o}\n", .{oneNumber});
    print("1 in binary is {b}\n", .{oneNumber});
    print("1 as character is {c}\n", .{oneNumber});

    // cast işlemleri
    // Aşağıdaki gibi açık bir şekilde büyük bir türden küçük bir türe dönüşüm yapmak istediğimizde
    // dönüştürülmek istenen tür sınır dışında kalıyorsa derleyici hata verir;
    // çünkü veri kaybı olabilir. error: type 'u8' cannot represent integer value '1000000000'
    // const smallNumber: u8 = @intCast(bigNumberValue);
    // const smallNumber = @as(u8, bigNumberValue);
    // print("Small number after cast is {d}\n", .{smallNumber});

    // Overflow operatörü
    // Bazı durumlarda veri kaybı yaşanabileceğini bilerek cast işlemi yapmak isteyebiliriz.
    // Bu gibi durumlarda owerflow operatörü kullanılabilir.
    // Örneğin aşağıdaki örnekte number1 ve number2 değişkenleri u8 türündendir.
    // number2 değişkeni u8 tipinden olduğu için 0-255 aralığında değer alabilir.
    // Ancak % operatörü ile overflow durumu bilinçli olarak kabul edilir.
    // Bazı matematiksel işlemlerde bu tip overflow durumları istenebilir. Örneğin kriptografik algoritmalarda.
    const number1: u8 = 255;
    const number2: u8 = number1 +% 10; // 255 + 10 = 265 -> 265 - 256 = 9 olacaktır
    print("Number2 after overflow use is {d}\n", .{number2});

    // Aşağıdaki kullanım ise sorunsuz çalışır zira 100 sayısı u8 türünün sınırları içindedir.
    const numberA = 100;
    const numberB: u8 = @intCast(numberA);
    print("Number B after cast is {d}\n", .{numberB});

    // Metinsel bir ifadeyi sayıya dönüştürmek için std kütüphaneden parseInt metodu kullanılabilir
    const numberStr = "1903";
    // Üçüncü parametre kaçlık sayı düzenini kullandığımızı ifade eder. Varsayılan olarak 10 luk sayı düzenidir.
    const convertedNumber = std.fmt.parseInt(u16, numberStr, 10) catch 0; // Eğer dönüştüremiyorsa 0 olarak kabul edilir
    print("Converted number from string {d}", .{convertedNumber});

    // // Tuple'lar immutable türler. İçerikleri değiştirilemiyor anladığım kadarıyla.
    // // Söz gelimi aşağıdaki kod parçasını ele alalım.
    // // Burada tanımlı p1 tuple türünün 2nci alanının içeriğini değiştirmek istiyorum.
    // // Derleyici aşağıdaki hatayı veriyor
    // // error: value stored in comptime field does not match the default value of the field

    // var p1 = .{ 1001, "Monitor 1080P", 1983.30, false };
    // p1[2] = 2000.00;
    // print("New price is {d}", .{p1[2]});

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
    print("\n{s} list price is {d:.3}", .{ product.name, product.price });
    // Aşağıdaki yazım şeklinde özellikle name alanının nasıl yazıldığına dikkat edelim.
    print("\n{}\n", .{product});

    // std kütüphanesindeki birçok fonksiyona @ operatörü ile erişebildiğini fark ettim
    const alpha = @mod(19, 3);
    print("19 % 3 = {}\n", .{alpha});

    // Pek tabii modüle almak için birçok dilde olduğu gibi % operatörü de kullanılabilir
    const beta = 19 % 3;
    print("19 % 3 = {}\n", .{beta});

    // null değer taşıyan değişkenler için optional türler kullanılır
    const maybeNumber: ?i32 = null;
    _ = maybeNumber;

    // Bir değişkenin hangi türden olduğunu öğrenmek için built-in @TypeOf fonksiyonu kullanılabilir
    // Bir veri türü ile ilgili bilgi almak içinse @typeInfo fonksiyonu kullanılabilir
    const varType = @TypeOf(bigNumber);
    print("Type of bigNumber variable: {}\n", .{varType});
    print("Type info of the bigNumber variable: {}\n", .{@typeInfo(varType)});

    print("Type infos\nu8:{}\nu3:{}\nf32:{}\nbool:{}\n", .{ @typeInfo(u8), @typeInfo(u3), @typeInfo(f32), @typeInfo(bool) });

    // Aşağıdaki gibi bir tipi bir variable olarak tanımlamakta mümkündür
    // Şu anda i8 türünü temsil eden signedByte isimli bir değişken tanımladık
    const signedByte: type = i8;
    const point: signedByte = 10;
    print("Type of `signedByte` is {}\n", .{@TypeOf(point)});
    print("Value of point is {}\n", .{point});

    // Bir değişkenin bellek adresini pointer türünde elde etmek de mümkündür.
    // Burada & operatörünü kullanarak bigNumber değişkeninin adresini alıyoruz
    const addressOfBigNumber: *const u64 = &bigNumber;
    print("Address of bigNumber is {x}\n", .{addressOfBigNumber});

    // Buradaki kullanımda ise bigNumber değişkeninin adresini
    // usize türünde bir değişkene atıyoruz.
    // Tahmin edileceği üzere addressOfBigNumber ile aynı adres değerini yakalayacağız
    const anotherAddress: usize = @intFromPtr(&bigNumber);
    print("Another address of bigNumber is {x}\n", .{anotherAddress});
}
