const Game = @import("../game.zig").Game;

pub fn detect(game: *Game) void {
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
                            game.score.value += 10;
                            game.score.remainingInvaders -= 1;
                            break;
                        }
                    }
                }
            }
        }
    }
}
