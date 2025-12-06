const Vector2D = @import("../geometry.zig").Vector2D;
const Size = @import("../geometry.zig").Size;
const Rectangle = @import("../geometry.zig").Rectangle;
const rl = @import("raylib");

pub const Invader = struct {
    position: Vector2D,
    size: Size,
    speed: f32,
    alive: bool,
    color: rl.Color,

    pub fn init(startPos: Vector2D, size: Size) @This() {
        return .{ .position = startPos, .size = size, .speed = 20.0, .alive = true, .color = getRandomColor() };
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.position.x),
                @intFromFloat(self.position.y),
                @intFromFloat(self.size.width),
                @intFromFloat(self.size.height),
                self.color,
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

fn getRandomColor() rl.Color {
    const colors = [_]rl.Color{
        rl.Color.violet.alpha(0.9),
        rl.Color.dark_green.alpha(0.9),
        rl.Color.beige.alpha(0.9),
        rl.Color.brown.alpha(0.9),
        rl.Color.orange.alpha(0.9),
        rl.Color.magenta.alpha(0.9),
        rl.Color.sky_blue.alpha(0.9),
        rl.Color.lime.alpha(0.9),
        rl.Color.yellow.alpha(0.9),
    };
    const randomIndex: usize = @intCast(rl.getRandomValue(0, colors.len - 1));
    return colors[randomIndex];
}
