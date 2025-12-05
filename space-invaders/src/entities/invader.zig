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
        return .{ .position = startPos, .size = size, .speed = 20.0, .alive = true };
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

    pub fn update(self: *@This(), direction: Vector2D) void {
        if (self.alive) {
            self.position.x += direction.x * self.speed;
            self.position.y += direction.y * self.speed;
        }
    }

    pub fn getRectangle(self: @This()) Rectangle {
        return .{
            .position = self.position,
            .size = self.size,
        };
    }
};
