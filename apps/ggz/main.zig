const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const std = @import("std");
const Shape = @import("shape.zig");
const Point = Shape.Point;
const Palette = @import("palette.zig");
const Color = Palette.Color;
const BaseColor = Palette.BaseColor;
const Seed = @import("seed.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const shapes = try Seed.loadShapes(allocator);
    defer allocator.free(shapes);

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

    _ = c.SDL_SetRenderDrawBlendMode(renderer, c.SDL_BLENDMODE_BLEND);

    var quit = false;
    var event: c.SDL_Event = undefined;

    var rect = Shape.Rect.new(
        Point{ .x = 100, .y = 100 },
        200,
        150,
        Color.fromBaseColor(BaseColor.Red, .{}),
        Shape.ShapeKind.Normal,
    );
    var rectGrowing = true;

    var circle = Shape.Circle.new(
        Point{ .x = 400, .y = 300 },
        30,
        Color.fromBaseColor(BaseColor.Red, .{ .transparency = 100 }),
        Shape.ShapeKind.Filled,
    );
    var circleGrowing = true;

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

        if (rectGrowing) {
            rect = rect.increase(1);
            if (rect.width > 300) rectGrowing = false;
        } else {
            rect = rect.decrease(1);
            if (rect.width < 200) rectGrowing = true;
        }

        rect.draw(renderer);
        if (circleGrowing) {
            circle = circle.increase(1);
            if (circle.radius > 100) circleGrowing = false;
        } else {
            circle = circle.decrease(1);
            if (circle.radius < 50) circleGrowing = true;
        }
        circle.draw(renderer);

        for (shapes) |shape| {
            shape.draw(renderer);
        }

        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }
}
