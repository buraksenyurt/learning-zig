const Vector2D = @import("../geometry.zig").Vector2D;
const Size = @import("../geometry.zig").Size;
const Rectangle = @import("../geometry.zig").Rectangle;
const rl = @import("raylib");

pub const Shield = struct {
    position: Vector2D,
    size: Size,
    health: i32,

    pub fn init(startPos: Vector2D, size: Size) @This() {
        return .{
            .position = startPos,
            .size = size,
            .health = 10,
        };
    }

    pub fn getRectangle(self: @This()) Rectangle {
        return .{
            .position = self.position,
            .size = self.size,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.health > 0) {
            const alpha = @as(u8, @intCast(@min(255, self.health * 25)));
            rl.drawRectangle(
                @intFromFloat(self.position.x),
                @intFromFloat(self.position.y),
                @intFromFloat(self.size.width),
                @intFromFloat(self.size.height),
                rl.Color{
                    .r = 0,
                    .g = 255,
                    .b = 0,
                    .a = alpha,
                },
            );
        }
    }
};
