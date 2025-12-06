const Size = @import("geometry.zig").Size;
const Vector2D = @import("geometry.zig").Vector2D;

pub const MAX_ROCKETS: u32 = 10;
pub const MAX_SHIELDS: u32 = 5;
pub const INVADER_ROWS: u32 = 5;
pub const INVADER_COLUMNS: u32 = 11;
pub const MAX_ENEMY_BOMBS: u32 = 5;

/// Game configuration structure.
pub const GameConfig = struct {
    fps: f32 = 60,
    screenSize: Size,
    playerSize: Size = Size{ .width = 80, .height = 25 },
    playerStartPosition: Vector2D = undefined,
    rocketSize: Size = Size{ .width = 8, .height = 24 },
    enemyBombSize: Size = Size{ .width = 10, .height = 10 },
    shieldStartPosition: Vector2D = Vector2D{ .x = 80, .y = 450 },
    shieldSize: Size = Size{ .width = 80, .height = 40 },
    shieldSpacing: f32 = 150.0,
    invaderStartPosition: Vector2D = Vector2D{ .x = 80, .y = 60 },
    invaderSize: Size = Size{ .width = 40, .height = 30 },
    invaderSpacing: Vector2D = Vector2D{ .x = 60, .y = 40 },
};
