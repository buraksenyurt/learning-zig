const rl = @import("raylib");
const Rectangle = @import("space_invaders").Rectangle;
const Size = @import("space_invaders").Size;
const GameConfig = @import("space_invaders").GameConfig;
const Player = @import("space_invaders").Player;

pub fn main() void {
    const gameConfig = GameConfig{ .screenSize = Size{ .width = 800, .height = 600 } };

    rl.initWindow(gameConfig.screenSize.width, gameConfig.screenSize.height, "Space Invaders in Zig with Raylib");
    defer rl.closeWindow();

    var hero = Player.init(
        .{ .x = gameConfig.screenSize.width / 2 - 25, .y = gameConfig.screenSize.height - 60 },
        .{ .width = 50, .height = 30 },
    );
    _ = &hero;

    rl.setTargetFPS(gameConfig.fps);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        const r: Rectangle = undefined;
        _ = r;

        rl.clearBackground(rl.Color.blue);
        hero.update();
        hero.draw();

        rl.drawText("Space Invaders", 0, 0, 50, rl.Color.white);
    }
}
