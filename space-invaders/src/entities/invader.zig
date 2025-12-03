const Vector2D = @import("../geometry.zig").Vector2D;
const Size = @import("../geometry.zig").Size;
const Rectangle = @import("../geometry.zig").Rectangle;
const rl = @import("raylib");

pub const Invader = struct {
    position: Vector2D,
    size: Size,
    speed: f32,
    alive: bool,

    pub fn init(startPos: Vector2D, size: Size) @This() {
        return .{ .position = startPos, .size = size, .speed = 5.0, .alive = true };
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.position.x),
                @intFromFloat(self.position.y),
                @intFromFloat(self.size.width),
                @intFromFloat(self.size.height),
                rl.Color.black,
            );
        }
    }
};
