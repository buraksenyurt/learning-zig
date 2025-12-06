const rl = @import("raylib");
const GameConfig = @import("space_invaders").GameConfig;
const Game = @import("space_invaders").Game;

pub fn main() void {
    const gameConfig = GameConfig{ .screenSize = .{ .width = 800, .height = 600 } };
    var game = Game.init(gameConfig);

    rl.initWindow(gameConfig.screenSize.width, gameConfig.screenSize.height, "Space Invaders in Zig with Raylib");
    defer rl.closeWindow();

    rl.setTargetFPS(gameConfig.fps);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (game.gameOver) {
            const gameOverText =
                \\ Game Over!
                \\
                \\ Your Score: %d
                \\
                \\ Press ENTER to play again.
                \\ or ESC to quit.
            ;
            const sizeOfText: f32 = @floatFromInt(
                rl.measureText(gameOverText, 40),
            );
            const text = rl.textFormat(gameOverText, .{game.gameState.playerScore});
            rl.drawText(
                text,
                @intFromFloat(gameConfig.screenSize.width / 2 - sizeOfText / 2),
                @intFromFloat(gameConfig.screenSize.height / 2 - 200),
                40,
                rl.Color.red,
            );
            if (rl.isKeyPressed(rl.KeyboardKey.escape)) {
                break;
            }
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game = Game.init(gameConfig);
            }
            continue;
        }
        if (game.gameState.remainingInvaders == 0) {
            const gameOverText =
                \\ You Win!
                \\
                \\ Your Score: %d
                \\
                \\ Press ENTER to play again.
                \\ or ESC to quit.
            ;
            const sizeOfText: f32 = @floatFromInt(
                rl.measureText(gameOverText, 40),
            );
            const text = rl.textFormat(gameOverText, .{game.gameState.playerScore});
            rl.drawText(
                text,
                @intFromFloat(gameConfig.screenSize.width / 2 - sizeOfText / 2),
                @intFromFloat(gameConfig.screenSize.height / 2 - 200),
                40,
                rl.Color.yellow,
            );
            if (rl.isKeyPressed(rl.KeyboardKey.escape)) {
                break;
            }
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game = Game.init(gameConfig);
            }
            continue;
        }

        game.update();
        game.draw();
    }
}
