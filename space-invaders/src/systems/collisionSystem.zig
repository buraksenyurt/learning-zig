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
                            game.score += 10;
                            game.invadersCount -= 1;
                            break;
                        }
                    }
                }
            }
        }
    }
}
