const Vector2D = @import("../geometry.zig").Vector2D;
const Size = @import("../geometry.zig").Size;
const Rectangle = @import("../geometry.zig").Rectangle;
const rl = @import("raylib");

/// Rocket entity structure.
/// Fields:
/// - position: The current position of the rocket.
/// - size: The size dimensions of the rocket.
/// - speed: The movement speed of the rocket.
/// - active: Indicates whether the rocket is currently active (fired).
/// Methods:
/// - init: Initializes a new rocket instance with a starting position and size.
/// - update: Updates the rocket's position if it is active.
/// - draw: Renders the rocket on the screen if it is active.
pub const Rocket = struct {
    position: Vector2D,
    size: Size,
    speed: f32,
    active: bool,

    pub fn init(startPos: Vector2D, size: Size) @This() {
        return .{ .position = startPos, .size = size, .speed = 10.0, .active = false };
    }
    pub fn update(self: *@This()) void {
        if (self.active) {
            self.position.y -= self.speed;
            if (self.position.y + self.size.height < 0) {
                self.active = false;
            }
        }
    }
    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position.x),
                @intFromFloat(self.position.y),
                @intFromFloat(self.size.width),
                @intFromFloat(self.size.height),
                rl.Color.red,
            );
        }
    }

    pub fn getRectangle(self: @This()) Rectangle {
        return .{
            .position = self.position,
            .size = self.size,
        };
    }
};
