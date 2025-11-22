// Birim testler aşağıdaki gibi yazılabilir
const std = @import("std");
const expect = std.testing.expect; // assert gibi düşünebilir miyiz?

test "ping function returns Pong!" {
    const lib = @import("common.zig");
    const response = lib.ping();
    const expected = "Pong!";
    // std.mem.eql fonksiyonu iki dizinin eşit olup olmadığını kontrol ediyor
    // I know I know... Bu biraz kafa karıştırıcı
    // response == expected yazamıyoruz zira String türü zig'de yok
    try expect(std.mem.eql(u8, response, expected));
}

test "factorial function works correctly" {
    const lib = @import("common.zig");
    try expect(lib.factorial(0) == 1);
    try expect(lib.factorial(1) == 1);
    try expect(lib.factorial(5) == 120);
    try expect(lib.factorial(10) == 3628800);
}