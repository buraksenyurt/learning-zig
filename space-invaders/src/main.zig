const rl = @import("raylib");
const Rectangle = @import("space_invaders").Rectangle;
const Size = @import("space_invaders").Size;
const GameConfig = @import("space_invaders").GameConfig;
const Player = @import("space_invaders").Player;
const Rocket = @import("space_invaders").Rocket;

pub fn main() void {
    const gameConfig = GameConfig{ .screenSize = Size{ .width = 800, .height = 600 } };
    var hero = Player.init(
        .{ .x = gameConfig.screenSize.width / 2 - gameConfig.playerSize.width / 2, .y = gameConfig.screenSize.height - gameConfig.playerSize.height * 2 },
        gameConfig.playerSize,
    );
    _ = &hero;
    var rockets: [gameConfig.maxRockets]Rocket = undefined;
    for (&rockets) |*rocket| {
        rocket.* = Rocket.init(.{ .x = 0, .y = 0 }, gameConfig.rocketSize);
    }

    rl.initWindow(gameConfig.screenSize.width, gameConfig.screenSize.height, "Space Invaders in Zig with Raylib");
    defer rl.closeWindow();

    rl.setTargetFPS(gameConfig.fps);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        const r: Rectangle = undefined;
        _ = r;

        rl.clearBackground(rl.Color.blue);

        hero.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&rockets) |*rocket| {
                if (!rocket.active) {
                    rocket.position.x = hero.position.x + hero.size.width / 2 - rocket.size.width / 2;
                    rocket.position.y = hero.position.y;
                    rocket.active = true;
                    break;
                }
            }
        }

        for (&rockets) |*rocket| {
            rocket.update();
        }

        for (&rockets) |*rocket| {
            rocket.draw();
        }

        hero.draw();

        rl.drawText("Space Invaders", 0, 0, 50, rl.Color.white);
    }
}
