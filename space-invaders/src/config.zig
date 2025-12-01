const Size = @import("geometry.zig").Size;
const Vector2D = @import("geometry.zig").Vector2D;

pub const MAX_ROCKETS: u32 = 10;

/// Game configuration structure.
pub const GameConfig = struct {
    fps: f32 = 60,
    screenSize: Size,
    playerSize: Size = Size{ .width = 80, .height = 25 },
    playerStartPosition: Vector2D = undefined,
    rocketSize: Size = Size{ .width = 8, .height = 24 },
    shieldStartPosition: Vector2D = undefined,
    shieldSize: Size = undefined,
    shieldSpacing: f32 = undefined,
    invaderStartPosition: Vector2D = undefined,
    invaderSize: Size = undefined,
    invaderSpacing: Vector2D = undefined,
};
