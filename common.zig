const std = @import("std");

pub fn ping() []const u8 {
    return "Pong!";
}

// Basit ve rekürsif olarak çalışan bir faktöriyel fonksiyonu
pub fn factorial(value:u64) u64 {
    if (value == 0 or value == 1) {
        return 1;
    }
    return value * factorial(value - 1);
}