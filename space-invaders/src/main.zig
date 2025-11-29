const rl = @import("raylib");
pub fn main() void {
    const screenWidth: i32 = 800;
    const screenHeight: i32 = 600;

    rl.initWindow(screenWidth, screenHeight, "Space Invaders in Zig with Raylib");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.blue);
        rl.drawText("Space Invaders", 0, 0, 50, rl.Color.white);
    }
}
