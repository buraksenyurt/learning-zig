const Game = @import("../game.zig").Game;
const Vector2D = @import("../geometry.zig").Vector2D;
const Invader = @import("../entities/invader.zig").Invader;

pub fn initAll(game: *Game) void {
    for (&game.invaders, 0..) |*invaderRow, row| {
        for (invaderRow, 0..) |*invader, col| {
            invader.* = Invader.init(
                .{
                    .x = game.config.invaderStartPosition.x + @as(f32, @floatFromInt(col)) * game.config.invaderSpacing.x,
                    .y = game.config.invaderStartPosition.y + @as(f32, @floatFromInt(row)) * game.config.invaderSpacing.y,
                },
                game.config.invaderSize,
            );
        }
    }
}

pub fn updateMoves(self: *Game) void {
    self.moveTimer += 1.0;
    if (self.moveTimer >= self.config.fps / 2) {
        self.moveTimer = 0.0;

        var edgeReached = false;
        for (&self.invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive) {
                    const nextX = invader.position.x + (self.invaderDirection.x * invader.speed);
                    if (nextX < 0 or (nextX + invader.size.width) > self.config.screenSize.width) {
                        edgeReached = true;
                        break;
                    }
                }
            }
            if (edgeReached)
                break;
        }
        if (edgeReached) {
            self.invaderDirection.x *= -1.0;
            for (&self.invaders) |*row| {
                for (row) |*invader| {
                    invader.update(Vector2D{ .x = 0.0, .y = 1.0 });
                }
            }
        } else {
            for (&self.invaders) |*row| {
                for (row) |*invader| {
                    invader.update(self.invaderDirection);
                }
            }
        }
    }
}

pub fn drawAll(game: Game) void {
    for (&game.invaders) |*row| {
        for (row) |*invader| {
            invader.draw();
        }
    }
}
