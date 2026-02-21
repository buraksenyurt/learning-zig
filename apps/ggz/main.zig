const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const std = @import("std");
const Shape = @import("shape.zig");
const Color = @import("palette.zig").BaseColor;

pub fn main() !void {
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        std.debug.print("Failed to initialize SDL: {s}\n", .{c.SDL_GetError()});
        return;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow(
        "GGZ",
        800,
        600,
        0,
    ) orelse {
        std.debug.print("Failed to create window: {s}\n", .{c.SDL_GetError()});
        return;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, null) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLRendererFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var quit = false;
    var event: c.SDL_Event = undefined;

    var rect = Shape.Rect.new(
        100,
        100,
        200,
        150,
        Color.Blue,
    );
    const square1 = Shape.GetSizedSquare(50, 50, Shape.MicroSquareType.Small, Color.Yellow);
    const square2 = Shape.GetSizedSquare(60, 60, Shape.MicroSquareType.Medium, Color.White);
    const square3 = Shape.GetSizedSquare(70, 70, Shape.MicroSquareType.Large, Color.Magenta);
    var growing = true;

    while (!quit) {
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => quit = true,
                c.SDL_EVENT_KEY_DOWN => {
                    if (event.key.key == c.SDLK_ESCAPE) quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        if (growing) {
            rect = rect.increase(1);
            if (rect.width > 300) growing = false;
        } else {
            rect = rect.decrease(1);
            if (rect.width < 200) growing = true;
        }

        rect.draw(renderer);
        square1.draw(renderer);
        square2.draw(renderer);
        square3.draw(renderer);
        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }
}
