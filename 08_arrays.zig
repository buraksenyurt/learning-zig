const std = @import("std");
const utility = @import("utility.zig");

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

    utility.println();

    // Dizideki eleman sayısını belirtmek zorunda değiliz
    // _ operatörü ile bunu zig'e bırakabiliriz
    const points = [_]f32{ 1.3, 1.24, 5.55, 0.46 };
    for (points) |p| {
        std.debug.print("{d:.2}, ", .{p});
    }

    utility.println();

    // metinsel ifadelerden oluşan bir array tanımı
    // [_], eleman sayısını sen bul
    // []const u8 ile de her biri u8 array olacak türden bir seri olacağını belirtmiş oluyoruz
    var colors = [_][]const u8{ "red", "green", "blue", "yellow", "green" };
    // Döngülerde öğrendiğimiz gibi dizi elemanlarını dolaşırken index değerlerini de alabiliriz
    for (colors, 0..) |color, id| {
        std.debug.print("{d}:{s}\n", .{ id, color });
    }

    utility.println();

    // var keyword ile tanımladığımız için dizi elemanlarında değişiklik yapabiliriz.
    colors[colors.len - 1] = "cyan";

    for (colors, 0..) |color, id| {
        std.debug.print("{d}:{s}\n", .{ id, color });
    }

    utility.println();

    // u8 türünden bir array'i print ederken {s} format specifier'ını kullanabiliriz
    // Bu durumda array'deki sayısal değerlerin karşılığı olan ASCII karakterler yazılır.
    const helloArray: [13]u8 = [_]u8{ 72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33 };
    std.debug.print("{s}", .{helloArray});

    utility.println();

    // Pek tabii dizi elemanlarına index operatörü ile de erişebiliriz
    for (0..numbers.len) |i| {
        std.debug.print("numbers[{d}] = {d}\n", .{ i, numbers[i] });
    }

    // Array'leri birleştirmek için ++ operatörünü kullanabiliriz
    const array1 = [_]i32{ 1, 2, 3 };
    const array2 = [_]i32{ 4, 5, 6 };
    const combined = array1 ++ array2; // combined türü [6]i32
    std.debug.print("Combined array: {any}\n", .{combined});

    // Array'leri ** operatörü ile çoklayabiliriz.
    // Bunu varsayılan değer içeren bir diziyi oluşturmak için kullanabiliriz.
    const startPoints = [_]u8{1} ** 10; // 10 elemanlı ve tüm elemanları 1 olan bir dizi oluşturuyoruz
    std.debug.print("Start points array: {any}\n", .{startPoints});

    // Birden fazla boyuttan oluşan (multi-dimensional) diziler de tanımlanabilir
    // Örneğin 6*4 boyutlarında bir matrisi aşağıdaki gibi oluşturabiliriz.
    // Bir oyun sahasınının iki boyutlu tasarımında bu tip çok boyutlu diziler epeyce işe yarıyor.
    const matrix: [6][4]u8 = [_][4]u8{
        [_]u8{ 1, 1, 0, 0 },
        [_]u8{ 1, 0, 0, 1 },
        [_]u8{ 1, 0, 1, 1 },
        [_]u8{ 1, 0, 2, 1 },
        [_]u8{ 1, 1, 2, 0 },
        [_]u8{ 1, 1, 2, 2 },
    };
    // ve içiçe bir döngü yardımıyla tüm elemanlarını dolaşabiliriz.
    for (matrix) |row| {
        for (row) |value| {
            std.debug.print("{d}\t", .{value});
        }
        utility.println();
    }
    // Tabii belli bir elemanına ulaşmak için yine index operatörünü kullanabiliriz
    const element = matrix[3][2]; // 3. satır ve 2. sütundaki eleman
    std.debug.print("Element at matrix[3][2] = {d}\n", .{element});

    // Bir dizideki elemanların bellek adreslerini almak için & operatörünü kullanabiliriz
    const nums = [_]u16{ 100, 200, 300, 400, 500 };
    std.debug.print("Nums :\n", .{});
    for (&nums) |*value| {
        // & ile nums dizisinin referans adresine ulaştık
        // *value ile de işaret edilen adresteki gerçek değere erişiyoruz
        // value.* ile de pointer'ın gösterdiği değeri alıyoruz
        std.debug.print("{} -> {}\n", .{ value, value.* });
    }

    // Eleman sayıları eşit olan dizileri aynı for döngüsü ile dolaşabiliriz.
    // Bu senaryoda n sayıda farklı türde dizi bir arada ele alınabilir.
    // Aşağıdaki örnekte üç farklı türde dizi tanımlanıyor ve bunlar aynı for döngüsünde dolaşılıyor.
    const arrayA = [_]u8{ 1, 2, 3, 4, 5 };
    const arrayB = [_]f32{ 10.0, 20.5, 30.99, 40.01, 50.075 };
    const arrayC = [_]i32{ 100, 200, 300, 400, 500 };
    std.debug.print("Array A and B elements:\n", .{});
    for (arrayA, arrayB, arrayC, 0..) |a, b, c, idx| {
        std.debug.print("A[{d}] = {d}\tB[{d}] = {d}\tC[{d}] = {d}\n", .{ idx, a, idx, b, idx, c });
    }

    // Dizilerin alt kümesini oluşturmak aslında slice işlemi olarak da bilinir.
    // Yeni bir dizi tanımlayıp deneyelim.
    const somePoints = [_]i32{ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21 };
    std.debug.print("Some points array: {any}\n", .{somePoints});
    const subPoints = somePoints[2..5]; // 2. indexten başlayıp 5. indexe kadar olan alt küme
    std.debug.print("Sub points array: {any}\n", .{subPoints});
    const subPoints2 = somePoints[somePoints.len / 2 ..]; // Diziyi orta noktasından sonuna kadar almaya çalıştık
    std.debug.print("Sub points 2 array: {any}\n", .{subPoints2});

    // filterU8 fonksiyonunu deneyelim.
    const mixedNumbers = [_]u8{ 10, 15, 22, 33, 42, 55, 60, 71, 80, 91 };
    std.debug.print("Mixed numbers array: {any}\n", .{mixedNumbers});
    var evenBuffer: [mixedNumbers.len]u8 = undefined; // Filtrelenmiş sonuçları tutacak buffer
    const evenNumbers = filterU8(&mixedNumbers, isEven, &evenBuffer);
    std.debug.print("Even numbers array: {any}\n", .{evenNumbers});

    // // filterU8Error fonksiyonunu filterU8'in farklı bir versiyonu
    // // Ancak bu versiyon hiçde beklediğimiz şekilde çalışmayacaktır.
    // // Zira filterU8Error içinde geçici bir buffer tanımlanıp geriye bir slice olarak döndürülüyor.
    // // Bu buffer fonksiyonun kapsamı dışında kalacağı için aslında geçersiz bir slice döndürülmüş olacak.
    // // Buna göre her seferinde içinde farklı sayılar barındıran bir içerik elde edeceğiz ki sanırım bu
    // // dangling reference olma hali olarak düşünülebilir.
    // // Bu nedenle doğru kullanım olarak filterU8 fonksiyonunu tercih etmek lazım.
    // // filterU8 içerisine dışarıdan bir buffer alınıyor ve bu buffer üzerinde işlem yapılıyor.
    // // Dolayısıyla main fonksiyonunda tanımlanmış bir buffer kullanıldığı için geçerli bir slice elde ediliyor.
    // const evenNumbers2 = filterU8Error(&mixedNumbers, isEven);
    // std.debug.print("Even numbers 2 array: {any}\n", .{evenNumbers2});

    // reverseU8Array fonksiyonunun örnek kullanımı
    const anArray = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    std.debug.print("An array: {any}\n", .{anArray});
    var reverseBuffer: [anArray.len]u8 = undefined; // Ters çevrilmiş sonucu tutacak dizi
    const reversedArray = reverseU8Array(&anArray, &reverseBuffer);
    std.debug.print("Reversed array: {any}\n", .{reversedArray});
}

fn isEven(n: u8) bool {
    return (n % 2) == 0;
}

// u8 türünden bir diziyi verilen predicate fonksiyonuna göre filtreleyen fonksiyon örneği.
// Gerçek anlamda bir HOF (Higher-Order Function) örneği sayılmayabilir tabii ama benzer konseptte ele alabiliriz.
fn filterU8(arr: []const u8, predicate: fn (u8) bool, buffer: []u8) []const u8 {
    var index: u8 = 0;
    for (arr) |value| {
        if (predicate(value)) {
            if (index >= buffer.len) break; // Dizide overflow olmasın diye eklediğimiz kontrol
            buffer[index] = value;
            index += 1;
        }
    }
    return buffer[0..index];
}

// Dizi elemanlarını ters sıralayan ve geriye yeni bir dizi olarak döndüren bir fonksiyon
fn reverseU8Array(arr: []const u8, buffer: []u8) []const u8 {
    const len = arr.len;
    if (buffer.len < len) {
        return &[_]u8{};
    }
    for (0..len) |i| {
        buffer[i] = arr[len - 1 - i];
    }
    return buffer[0..len];
}

// // Bu oldukça tehlikeli bir fonksiyon. Çalışma zamanı çıktılarına bakarak değerlendirmek lazım.
// fn filterU8Error(arr: []const u8, predicate: fn (u8) bool) []const u8 {
//     var index: u8 = 0;
//     var temp: [256]u8 = undefined;
//     for (arr) |value| {
//         if (predicate(value)) {
//             if (index >= temp.len) break; // Dizide overflow olmasın diye eklediğimiz kontrol
//             temp[index] = value;
//             index += 1;
//         }
//     }
//     return temp[0..index];
// }
