const Game = @import("../game.zig").Game;
const rl = @import("raylib");

pub fn fire(self: *Game) void {
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

pub fn isPlayerWin(game: Game) bool {
    return game.invadersCount == 0;
}
