const std = @import("std");

pub fn main() void {
    // Bir çok dilde olduğu gibi Zig'de de slice enstrümanı vardır.
    // Bazen "Fat Pointers" olarak isimlendiriliyorlar zira bir pointer'ın iki katı bellek kaplıyorlar.
    // Ancak daha çok Many-Item pointer olarak ifade edilmekteler.
    // Bir slice genellikle bir pointer ve uzunluk bilgisi içerir ve bellekteki başka bir serinin belli bir parçasını kullanmamızı sağlar
    // Go dilindeki slice kavramına benzer olduğu ifade ediliyor ama burada kapasite bilgisi yok.
    const someNumbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    // Aşağıdaki kullanımda bir kafa karışıklığı olabilir
    // Aslında subNumbers derleme zamanında uzunluğu ve içeriği bilinen yeni bir dizi işaretçisi oluyor. Slice olarak ifade edilmiyor.
    // Ancak printI32Slice fonksiyonuna geçerken slice türüne dönüşüyor.
    const subNumbers = someNumbers[0..5]; // 0ncı indisten i 5nci indise kadar (5 dahil değil) olan kısmı aldık
    printI32Slice(subNumbers);
    printI32Slice(someNumbers[5..]); // Burada ise 5nci indisten sonrasını aldık

    // Fakat şöyle bir kullanıma gidersek kesin olarak bir slice tanımına gitmiş oluyoruz.
    // Slice'ı açıkça ifade edersek
    const slice1: []const i32 = someNumbers[3..9];
    printI32Slice(slice1);

    // Aşağıdaki örnek kod parçasında myNumbers isimli dizinin birkaç elemanını aldığımız bir slice söz konusu
    // Burada da endIndex kullandığımız için derleme zamanı için bir kesinlik söz konusu değil.
    // Dolayısıyla slice2 türü kesinlikle bir slice oluyor diyebiliriz.
    var myNumbers = [_]i32{ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 };
    var endIndex: usize = myNumbers.len - 3;
    endIndex += 1;
    const slice2: []i32 = myNumbers[2..endIndex]; // 2nci indisten endIndex değerine kadar sayıları başka bir slice'a aldık
    // Burada dikkat edilmesi gereken önemli bir nokta var.
    // slice2 üzerinden yapılan değişiklikler myNumbers dizisini de etkiler.
    // Bu nedenle myNumbers'ın, slice2 üzerinden değiştirilebilmesi için var ile tanımlanması gerekir.
    // Eğer const ile tanımlansaydı derleme hatası alırdık; expected type '[]i32', found '[]const i32'
    std.debug.print("Slice 2 before modification:\n", .{});
    printI32Slice(slice2);
    slice2[0] = 300; //slice2 üzerinden yapılan değişiklik myNumbers dizisini de etkiler
    slice2[3] = 600;
    std.debug.print("Slice 2 after modification:\n", .{});
    printI32Slice(slice2);
    std.debug.print("Numbers after modification: ", .{});
    for (myNumbers) |num| {
        std.debug.print("{d}, ", .{num});
    }
    std.debug.print("\n", .{});
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
