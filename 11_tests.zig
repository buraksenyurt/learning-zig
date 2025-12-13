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
