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

        rl.clearBackground(rl.Color.blue);

        game.update();
        game.draw();

        rl.drawText("Space Invaders", 0, 0, 50, rl.Color.white);
    }
}
