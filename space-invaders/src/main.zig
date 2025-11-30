const rl = @import("raylib");
const Rectangle = @import("space_invaders").Rectangle;
const Size = @import("space_invaders").Size;

pub fn main() void {
    const screenSize = Size{ .width = 800, .height = 600 };
    const fps: f32 = 60;

    rl.initWindow(screenSize.width, screenSize.height, "Space Invaders in Zig with Raylib");
    defer rl.closeWindow();

    rl.setTargetFPS(fps);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        const r: Rectangle = undefined;
        _ = r;

        rl.clearBackground(rl.Color.blue);
        rl.drawText("Space Invaders", 0, 0, 50, rl.Color.white);
    }
}
