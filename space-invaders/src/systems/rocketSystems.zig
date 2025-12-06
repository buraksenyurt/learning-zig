const Game = @import("../game.zig").Game;
const Rocket = @import("../entities/rocket.zig").Rocket;

pub fn initAll(game: *Game) void {
    for (&game.rockets) |*rocket| {
        rocket.* = Rocket.init(.{ .x = 0, .y = 0 }, game.config.rocketSize);
    }
}

pub fn moveAll(game: *Game) void {
    for (&game.rockets) |*rocket| {
        rocket.update();
    }
}

pub fn drawAll(game: Game) void {
    for (&game.rockets) |*rocket| {
        rocket.draw();
    }
}
