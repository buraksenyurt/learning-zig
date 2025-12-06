const Game = @import("../game.zig").Game;
const rl = @import("raylib");

pub fn fire(game: *Game) void {
    if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        for (&game.rockets) |*rocket| {
            if (!rocket.active) {
                rocket.position.x = game.player.position.x + game.player.size.width / 2 - rocket.size.width / 2;
                rocket.position.y = game.player.position.y;
                rocket.active = true;
                game.gameState.totalFiredRockets += 1;
                break;
            }
        }
    }
}

pub fn detectHits(game: *Game) void {
    const playerRect = game.player.getRectangle();
    for (&game.enemyBombs) |*bomb| {
        if (bomb.active) {
            const bombRect = bomb.getRectangle();
            if (playerRect.collides(bombRect)) {
                bomb.active = false;
                game.gameOver = true;
                break;
            }
        }
    }
}
