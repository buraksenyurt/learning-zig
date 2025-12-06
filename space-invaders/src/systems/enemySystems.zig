const Game = @import("../game.zig").Game;
const rl = @import("raylib");
const EnemyBomb = @import("../entities/enemyBomb.zig").EnemyBomb;

pub fn initAllBombs(game: *Game) void {
    for (&game.enemyBombs) |*bomb| {
        bomb.* = EnemyBomb.init(.{ .x = 0, .y = 0 }, game.config.enemyBombSize);
    }
}

pub fn updateAll(game: *Game) void {
    for (&game.enemyBombs) |*bomb| {
        bomb.update();
    }
    game.enemyMoveTimer += 1.0;
    if (game.enemyMoveTimer >= game.enemyShootDelay * game.config.fps) {
        game.enemyMoveTimer = 0.0;
        for (&game.invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive and rl.getRandomValue(0, 100) < game.enemyShootChance) {
                    for (&game.enemyBombs) |*bomb| {
                        if (!bomb.active) {
                            bomb.position.x = invader.position.x + invader.size.width / 2 - bomb.size.width / 2;
                            bomb.position.y = invader.position.y + invader.size.height;
                            bomb.active = true;
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
}

pub fn drawAllBombs(game: Game) void {
    for (&game.enemyBombs) |*bomb| {
        bomb.draw();
    }
}
