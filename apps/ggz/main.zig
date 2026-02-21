const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const std = @import("std");
const Rect = @import("shape.zig").Rect;

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

    const rect = Rect.new(
        100,
        100,
        200,
        150,
        c.SDL_Color{
            .r = 255,
            .g = 0,
            .b = 0,
            .a = 255,
        },
    );

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
        rect.draw(renderer);
        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }
}
