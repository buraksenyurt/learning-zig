// Birim testler aşağıdaki gibi yazılabilir
const std = @import("std");
const expect = std.testing.expect; // assert gibi düşünebilir miyiz?

test "ping function returns Pong!" {
    const utility = @import("utility.zig");
    const response = utility.ping();
    const expected = "Pong!";
    // std.mem.eql fonksiyonu iki dizinin eşit olup olmadığını kontrol ediyor
    // I know I know... Bu biraz kafa karıştırıcı
    // response == expected yazamıyoruz zira String türü zig'de yok
    try expect(std.mem.eql(u8, response, expected));
}

test "factorial function works correctly" {
    const utility = @import("utility.zig");
    try expect(utility.factorial(0) == 1);
    try expect(utility.factorial(1) == 1);
    try expect(utility.factorial(5) == 120);
    try expect(utility.factorial(10) == 3628800);
}

// Eşitlik testleri için kullanışlı fonksiyonlar da vardır.
// expectEqual,expectEqaulSlices, expectEqualStrings gibi
// Aşağıdaki örnekler de bu fonksiyonların basit kullanımları yer alıyor.

test "expectEqual works for integers" {
    const a: i32 = 42;
    const b: i32 = 42;
    try std.testing.expectEqual(a, b);
}

test "expectEqualSlices works for arrays" {
    const arr1: [5]u8 = .{ 1, 2, 3, 4, 5 };
    const arr2: [5]u8 = .{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqualSlices(u8, arr1[0..], arr2[0..]);
}

test "expectEqualStrings works for strings" {
    const str1: []const u8 = "Hello, Zig!";
    const str2: []const u8 = "Hello, Zig!";
    try std.testing.expectEqualStrings(str1, str2);
}

// Özellikle error döndüren kurgularda testlerinde
// expectError fonksiyonu ile testler yapılır.
// Söz gelimi aşağıdaki changeBalance fonksiyonunu ele alalım.
// negatif bir bakiye oluştuğunda InsufficientFunds hatası döndürüyoruz.
// Buna göre exceptError ile bu durumu test edebiliriz.

fn changeBalance(balance: i32, value: i32) !i32 {
    if (balance + value < 0) {
        return error.InsufficientFunds;
    }
    return balance + value;
}
test "changeBalance function returns error on insufficient funds" {
    try std.testing.expectError(
        error.InsufficientFunds,
        changeBalance(10, -20),
    );
}

// Zig dilinde heap bellek bölgesinde çalışırken allocator türlerinden yararlanılıyor.
// Bu türlerin kullanımı sırasında bellek kaçakları (memory leak) oluşma ihtimali var.
// Ancak std.testing.allocator nesnesini kullanarak bu tür bellek sızıntılarını tespit edebiliriz.
// Aşağıdaki fonksiyonu gözden kaçırılan bir memory leak oluşturmakta.
fn createLeakingArray(allocator: std.mem.Allocator, size: usize) !void {
    // Parametre olarak gelen Allocator'dan yararlanılarak size değerine göre
    // heap'te yer ayrılıyor. Normalde programcı olarak fonksiyon sonlanırken
    // bu bellek bölgesini de serbest bırakmamız gerekir.
    const arr = try allocator.alloc(u8, size);
    // defer allocator.free(arr); // <- Bunu unutuyoruz!
    // return;
    _ = arr;
}

// Yukarıdaki fonksiyonda memory leak oluşup oluşmadığını test fonksiyonundan yakalayabiliriz.
test "createLeakingArray should not leak memory" {
    const allocator = std.testing.allocator;
    try createLeakingArray(allocator, 1024);
    // Eğer createLeakingArray fonksiyonu bellek sızıntısına sebep oluyorsa test fail dönecektir.
}
