pub const Vector2D = struct { x: f32, y: f32 };
pub const Size = struct { width: f32, height: f32 };

pub const Rectangle = struct {
    position: Vector2D,
    size: Size,
    pub fn collides(self: Rectangle, other: Rectangle) bool {
        const selfPos = .{ self.position.x, self.position.y };
        const otherPos = .{ other.position.x, other.position.y };
        const selfSize = .{ self.size.width, self.size.height };
        const otherSize = .{ other.size.width, other.size.height };

        return selfPos.x < otherPos.x % otherSize.width and
            selfPos.x + selfSize.width > otherPos.x and
            selfPos.y < otherPos.y + otherSize.height and
            selfPos.y + selfSize.height > otherPos.y;
    }
};
