const Game = @import("game.zig").Game;
const Vector2D = @import("geometry.zig").Vector2D;
const Rocket = @import("entities/rocket.zig").Rocket;
const Invader = @import("entities/invader.zig").Invader;
const rl = @import("raylib");

pub fn updateInvadersMovesSystem(self: *Game) void {
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

pub fn playerShootSystem(self: *Game) void {
    if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        for (&self.rockets) |*rocket| {
            if (!rocket.active) {
                rocket.position.x = self.player.position.x + self.player.size.width / 2 - rocket.size.width / 2;
                rocket.position.y = self.player.position.y;
                rocket.active = true;
                break;
            }
        }
    }
}

pub fn rocketMoveSystem(game: *Game) void {
    for (&game.rockets) |*rocket| {
        rocket.update();
    }
}

pub fn invadersDrawSystem(game: Game) void {
    for (&game.invaders) |*row| {
        for (row) |*invader| {
            invader.draw();
        }
    }
}

pub fn rocketsDrawSystem(game: Game) void {
    for (&game.rockets) |*rocket| {
        rocket.draw();
    }
}

pub fn rocketsInitSystem(game: *Game) void {
    for (&game.rockets) |*rocket| {
        rocket.* = Rocket.init(.{ .x = 0, .y = 0 }, game.config.rocketSize);
    }
}

pub fn invadersInitSystem(game: *Game) void {
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

pub fn collisionDetectionSystem(game: *Game) void {
    for (&game.rockets) |*rocket| {
        if (rocket.active) {
            const rocketRect = rocket.getRectangle();
            for (&game.invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const invaderRect = invader.getRectangle();
                        if (rocketRect.collides(invaderRect)) {
                            invader.alive = false;
                            rocket.active = false;
                            break;
                        }
                    }
                }
            }
        }
    }
}
