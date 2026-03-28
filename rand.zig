//! Random number generation utility functions
//!
//! This module provides functions to generate random integers.
//! It uses the standard library's random number generation facilities.
//!
//! Author: Burak Selim Senyurt
const std = @import("std");

// Bu fonksiyon rastgele sayı üretmekte.
// u8 yerine !u8 türünden bir dönüş yaptığımıza dikkat edelim zira bu metod hata fırlatabilir.
// try ile çağrılan yerden bir hata fırlatılabilir. ! ile bu hatayı çağıran yere iletiyoruz.

/// Create a random integer between 0 and 255 (u8 range)
/// @return A random u8 integer
pub fn getU8() !u8 {
    // Bazı kaynaklarda Zig'in 0.13 versiyonunda random sayı üretimi için std.rand namespace tanımlı
    // Ama tabii 0.14'te değişmiş. https://ziglang.org/download/0.14.0/release-notes.html adresindeki gibi release notları okumak lazım

    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    return rand.int(u8);
}

/// Get a random u8 integer within a specified range
/// @param rangeStart The start of the range (inclusive)
/// @param rangeEnd The end of the range (inclusive)
/// @return A random u8 integer within the specified range
pub fn getFromRange(rangeStart: u8, rangeEnd: u8) !u8 {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    return rand.intRangeAtMost(u8, rangeStart, rangeEnd);
}

test "getU8 generates values within u8 range" {
    const value = try getU8();
    try std.testing.expect(value <= 255);
}

test "getFromRange generates values within specified range" {
    const start: u8 = 10;
    const end: u8 = 20;
    const value = try getFromRange(start, end);
    try std.testing.expect(value >= start and value <= end);
}
