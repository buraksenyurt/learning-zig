const std = @import("std");

// Value referans etmek için &, değere ulaşmak için (dereference) * operatörü kullanılır.
// C dile ile uyumluluğu sağlamak adına Single-Item ve Multi-Item pointers gibi kavramlar olduğunu söyleyebiliriz.
pub fn main() void {
    var number: i32 = 23;
    std.debug.print("Number value : {d}\n", .{number});
    addOne(&number); // burada number değişkeninin referansı addOne fonksiyonuna taşınıyor
    std.debug.print("After add, {d}\n", .{number});

    // // Yukarıdaki gibi bir kullanım mümkünken aşağıdaki kullanım derleme hatası verir
    // var number2: i32 = 45;
    // var ptrNumber: *i32 = &number2; // error: local variable is never mutated
    // ptrNumber.* += 5;

    // pointer'ları const ile de tanımlayabiliriz
    const luckySeven: u8 = 7;
    std.debug.print("Lucky Seven : {d}\n", .{luckySeven});

    // // const olarak tanımlanan pointer değerleri kesin olarak değiştirilemez.
    // // Aşağıdaki kod parçasında iki hata söz konusudur
    // var newValue = &luckySeven; // error: local variable is never mutated
    // newValue.* += 1; // error: cannot assign to constant

    // Bu bilgi şu anda ne kadar önemli bilemedim ama
    // usize ve isize pointer'lar ile aynı boyuta sahiplermiş
    std.debug.print("Size of usize->{d} and size of *u8->{d}\n", .{ @sizeOf(usize), @sizeOf(*u8) });
    std.debug.print("Size of isize->{d} and size of *u8->{d}\n", .{ @sizeOf(isize), @sizeOf(*u8) });

    // pointer'lar daha çok derleme zamanında ne kadar yer kaplayacakları
    // bilinmeyen buffer alanların ele alınmasında işe yarar.
    // Bunun için Many-Item pointers kavramı kullanılıyor.
    // Hatta single-item pointer ile bir kıyaslama da var.
    // Detaylar için https://zig.guide/language-basics/many-item-pointers
    // Many-Item pointer'lar *T yerine [*]T olarak ifade edilir.
    // Aşağıdaki örneğe inceleyelim
    var numbers = [_]u8{ 10, 20, 30 };
    var ptrNumbers: [*]u8 = &numbers; // multi-item pointer
    std.debug.print("\nType of the ptrNumbers is {}\n", .{@TypeOf(ptrNumbers)});
    ptrNumbers[0] = 11;
    std.debug.print("\nptrNumbers[0]={}, numbers[0]={}", .{ ptrNumbers[0], numbers[0] });
    // Aşağıdaki satırda pointer 2 artırılıyor.
    // Bu aslında 0ncı konumda olan pointer'ın bir u8 kadar ötelenmesi olarak düşünülebilir.
    // Buna göre ptrNumbers[0] artık numbers'ın 30 numaralı 3ncü indisteki değerini işaret edecekken,
    // numbers[0] halen daha 1nci indisteki 11 olarak değişmiş değeri taşıyacaktır.
    ptrNumbers += 2;
    std.debug.print("\nptrNumbers[0]={}, numbers[0]={}", .{ ptrNumbers[0], numbers[0] });

    // Şimdi tekrar -2 çıkartırsak 0ncı indis konumuna dönebiliriz.
    ptrNumbers -= 2;
    std.debug.print("\nptrNumbers[0]={}, numbers[0]={}", .{ ptrNumbers[0], numbers[0] });

    // Peki aralık dışı bir değere set edersek ne olacak?
    ptrNumbers += 5;
    // Çalışma zamanında pointer'ın 5 ileri götürülmesi sonrası her seferinde değişen u8 değerleri elde edilir
    // Bu iyi bir şey mi emin olamadım.
    std.debug.print("\nptrNumbers[0]={}, numbers[0]={}", .{ ptrNumbers[0], numbers[0] });

    // Pointer aritmetiği ile bir döngü olarak ilerleyebiliriz
    // Ancak bu sefer bellekte someNumbers dizisinin dışına çıkıyoruz ve belirsiz değerlere erişiyoruz
    // Bu da tanımsız davranışa (undefined behavior) yol açabilir.
    var someNumbers = [_]u8{ 1, 2, 3, 4, 5 };
    var ptrSomeNumbers: [*]u8 = &someNumbers; // multi-item pointer
    for (0..10) |_| {
        std.debug.print("Pointer Address: {*}, Value: {d}\n", .{ ptrSomeNumbers, ptrSomeNumbers[0] });
        ptrSomeNumbers += 1;
    }
}

// addOne parametre olarak i32 türünden bir pointer almakta
// Örneğe göre &number isimli değişken pointer buraya atanıyor
fn addOne(n: *i32) void {
    n.* += 1; // burada dereference edilen değer 1 artırılıyor
}
