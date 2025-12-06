const Vector2D = @import("../geometry.zig").Vector2D;
const Size = @import("../geometry.zig").Size;
const Rectangle = @import("../geometry.zig").Rectangle;
const rl = @import("raylib");

/// Player entity structure.
/// Fields:
/// - position: The current position of the player.
/// - size: The size dimensions of the player.
/// - speed: The movement speed of the player.
/// Methods:
/// - init: Initializes a new player instance with a starting position and size.
/// - update: Updates the player's position based on keyboard input.
/// - draw: Renders the player on the screen.
/// - getRectangle: Returns the player's bounding rectangle for collision detection.
pub const Player = struct {
    position: Vector2D,
    size: Size,
    speed: f32,
    pub fn init(startPos: Vector2D, size: Size) @This() {
        return .{ .position = startPos, .size = size, .speed = 5.0 };
    }
    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position.x += self.speed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position.x -= self.speed;
        }
        if (self.position.x + self.size.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position.x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.size.width;
        }
        if (self.position.x < 0) {
            self.position.x = 0;
        }
    }
    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position.x),
            @intFromFloat(self.position.y),
            @intFromFloat(self.size.width),
            @intFromFloat(self.size.height),
            rl.Color.white.alpha(0.9),
        );
    }
    pub fn getRectangle(self: @This()) Rectangle {
        return .{
            .position = self.position,
            .size = self.size,
        };
    }
};
