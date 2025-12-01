//! Space Invaders game module.
//! This is the public API that re-exports all game types and structures.

// Re-export geometry types
pub const Vector2D = @import("geometry.zig").Vector2D;
pub const Size = @import("geometry.zig").Size;
pub const Rectangle = @import("geometry.zig").Rectangle;

// Re-export game configuration
pub const GameConfig = @import("config.zig").GameConfig;

// Re-export entities
pub const Player = @import("entities/player.zig").Player;
pub const Rocket = @import("entities/rocket.zig").Rocket;

// Re-export tests from geometry
test {
    @import("std").testing.refAllDecls(@This());
    _ = @import("geometry.zig");
}
