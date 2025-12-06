const Game = @import("../game.zig").Game;
const Shield = @import("../entities/shield.zig").Shield;

pub fn initAll(game: *Game) void {
    for (game.shields[0..], 0..) |*shield, index| {
        const startX = game.config.shieldStartPosition.x + @as(f32, @floatFromInt(index)) * game.config.shieldSpacing;
        const startY = game.config.shieldStartPosition.y;
        shield.* = Shield.init(
            .{ .x = startX, .y = startY },
            game.config.shieldSize,
        );
    }
}

pub fn drawAll(game: Game) void {
    for (game.shields[0..]) |*shield| {
        shield.draw();
    }
}
