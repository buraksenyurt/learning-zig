const std = @import("std");

pub fn main() void {
    // Bir çok dilde olduğu gibi Zig'de de slice enstrümanı vardır.
    // Baze "Fat Pointers" olarak isimlendiriliyorlar zira bir pointer'ın iki katı bellek kaplıyorlar.
    // Bir slice genellikle bir pointer ve uzunluk bilgisi içerir ve bellekteki başka bir serinin belli bir parçasını kullanmamızı sağlar
    // Go dilindeki slice kavramına benzer olduğu ifade ediliyor
    const someNumbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const slice1 = someNumbers[0..5]; // 0ncı indisten i 5nci indise kadar (5 dahil değil) olan kısmı alıyoruz
    printI32Slice(slice1);
    printI32Slice(someNumbers[5..]); // Burada ise 5nci indisten sonrasını alıyoruz

    // Slice'lar üzerinden değişiklik de yapabiliriz
    // Aşağıdaki örnek kod parçasında myNumbers isimli dizinin birkaç elemanını aldığımız bir slice söz konusu
    var myNumbers = [_]i32{ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 };
    var slice2 = myNumbers[2..7]; // 2nci indisten 7nciye kadar sayıları başka bir slice'a aldık
    // Ancak dikkat edelim const yerine var kullanıyoruz çünkü slice içeriğini değiştireceğiz
    slice2[0] = 300;
    slice2[3] = 600;
    printI32Slice(slice2);
}

// Burada kullanılan fonksiyona i32 türünden bir slice parametre olarak geçiliyor.
// Çağırdığımız yerdeki slice'lar const olduğundan burada da parametre tanımında const kullanılıyor.
// const'u kaldırıp build hatasına bakılabilir.
// Fonksiyon geriye bir şey döndürmüyor, sadece ekrana slice içeriğini yazdırıyor. Bu nedenle dönüş türü void.
fn printI32Slice(slice: []const i32) void {
    std.debug.print("\n", .{});

    for (slice, 0..) |element, index| {
        std.debug.print("{d}: {d}\n", .{ index, element });
    }
}
