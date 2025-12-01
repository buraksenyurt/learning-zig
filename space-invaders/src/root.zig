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
const rl = @import("raylib");
const expect = std.testing.expect;

test "Rectangle collision detection" {
    const rect1 = Rectangle{ .position = .{ .x = 0, .y = 0 }, .size = .{ .width = 10, .height = 10 } };
    const rect2 = Rectangle{ .position = .{ .x = 5, .y = 5 }, .size = .{ .width = 10, .height = 10 } };
    const rect3 = Rectangle{ .position = .{ .x = 20, .y = 20 }, .size = .{ .width = 10, .height = 10 } };

    try expect(rect1.collides(rect2) == true);
    try expect(rect1.collides(rect3) == false);
}

/// Game configuration structure.
pub const GameConfig = struct {
    fps: f32 = 60,
    screenSize: Size,
    playerSize: Size = Size{ .width = 80, .height = 25 },
    playerStartPosition: Vector2D = undefined,
    rocketSize: Size = Size{ .width = 8, .height = 24 },
    shieldStartPosition: Vector2D = undefined,
    shieldSize: Size = undefined,
    shieldSpacing: f32 = undefined,
    invaderStartPosition: Vector2D = undefined,
    invaderSize: Size = undefined,
    invaderSpacing: Vector2D = undefined,
    maxRockets: u32 = 10,
};

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
        //todo@buraksenyurt: add boundary checks
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
            rl.Color.green,
        );
    }
    pub fn getRectangle(self: @This()) Rectangle {
        return Rectangle{
            .position = self.position,
            .size = self.size,
        };
    }
};

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
};
