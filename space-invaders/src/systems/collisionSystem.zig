const Game = @import("../game.zig").Game;

pub fn detectRocketHitInvader(game: *Game) void {
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
                            game.gameState.playerScore += 10;
                            game.gameState.remainingInvaders -= 1;
                            break;
                        }
                    }
                }
            }
        }
    }
}

pub fn detectBombHitShield(game: *Game) void {
    for (&game.enemyBombs) |*bomb| {
        if (bomb.active) {
            const bombRect = bomb.getRectangle();
            for (&game.shields) |*shield| {
                if (shield.health > 0) {
                    const shieldRect = shield.getRectangle();
                    if (bombRect.collides(shieldRect)) {
                        shield.health -= 1;
                        bomb.active = false;
                        break;
                    }
                }
            }
        }
    }
}

pub fn detectRocketHitShield(game: *Game) void {
    for (&game.rockets) |*rocket| {
        if (rocket.active) {
            const rocketRect = rocket.getRectangle();
            for (&game.shields) |*shield| {
                if (shield.health > 0) {
                    const shieldRect = shield.getRectangle();
                    if (rocketRect.collides(shieldRect)) {
                        shield.health -= 1;
                        rocket.active = false;
                        break;
                    }
                }
            }
        }
    }
}
