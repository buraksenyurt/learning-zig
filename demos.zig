const std = @import("std");
const common = @import("common.zig");

pub fn main() !void {
    // todo@buraksenyurt: Demo için başka ilginç örnekler ekle.

    // games.data içeriğini satır satır okuma
    try common.writeLines("games.dat");
}
