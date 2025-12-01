//! Space Invaders game module.
//! This is the public API that re-exports all game types and structures.

pub const Vector2D = @import("geometry.zig").Vector2D;
pub const Size = @import("geometry.zig").Size;
pub const Rectangle = @import("geometry.zig").Rectangle;
pub const GameConfig = @import("config.zig").GameConfig;
pub const Game = @import("game.zig").Game;
pub const Player = @import("entities/player.zig").Player;
pub const Rocket = @import("entities/rocket.zig").Rocket;

test {
    @import("std").testing.refAllDecls(@This());
    _ = @import("geometry.zig");
}
