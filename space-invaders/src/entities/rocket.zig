const Vector2D = @import("../geometry.zig").Vector2D;
const Size = @import("../geometry.zig").Size;
const Rectangle = @import("../geometry.zig").Rectangle;
const rl = @import("raylib");

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
                rl.Color.violet.alpha(0.8),
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
