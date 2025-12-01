//! Definitions for core game structures and configurations.
//! This file contains definitions for vectors, sizes, rectangles, game configurations, and player entities.

/// 2D vector structure.
/// Fields:
/// - x: The x-coordinate.
/// - y: The y-coordinate.
pub const Vector2D = struct { x: f32, y: f32 };

/// Size structure.
/// Fields:
/// - width: The width dimension.
/// - height: The height dimension.
pub const Size = struct { width: f32, height: f32 };

/// Rectangle structure.
/// Fields:
/// - position: The top-left position of the rectangle.
/// - size: The size dimensions of the rectangle.
/// Methods:
/// - collides: Checks if this rectangle collides with another rectangle.
pub const Rectangle = struct {
    position: Vector2D,
    size: Size,
    pub fn collides(self: Rectangle, other: Rectangle) bool {
        return self.position.x < other.position.x + other.size.width and
            self.position.x + self.size.width > other.position.x and
            self.position.y < other.position.y + other.size.height and
            self.position.y + self.size.height > other.position.y;
    }
};

const std = @import("std");
const expect = std.testing.expect;

test "Rectangle collision detection" {
    const rect1 = Rectangle{ .position = .{ .x = 0, .y = 0 }, .size = .{ .width = 10, .height = 10 } };
    const rect2 = Rectangle{ .position = .{ .x = 5, .y = 5 }, .size = .{ .width = 10, .height = 10 } };
    const rect3 = Rectangle{ .position = .{ .x = 20, .y = 20 }, .size = .{ .width = 10, .height = 10 } };

    try expect(rect1.collides(rect2) == true);
    try expect(rect1.collides(rect3) == false);
}
