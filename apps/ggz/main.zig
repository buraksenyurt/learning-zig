const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const std = @import("std");
const Shape = @import("shape.zig");
const Color = @import("palette.zig").Color;
const BaseColor = @import("palette.zig").BaseColor;

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
        Color.fromBaseColor(BaseColor.Red, 100),
        Shape.ShapeKind.Normal,
    );
    var rectGrowing = true;

    const square1 = Shape.GetSizedSquare(
        50,
        50,
        Shape.MicroSquareType.Small,
        Color.fromBaseColor(BaseColor.Yellow, 100),
    );
    const square2 = Shape.GetSizedSquare(
        60,
        60,
        Shape.MicroSquareType.Medium,
        Color.fromBaseColor(BaseColor.White, 100),
    );
    const square3 = Shape.GetSizedSquare(
        70,
        70,
        Shape.MicroSquareType.Large,
        Color.new(
            50,
            50,
            255,
            100,
        ),
    );

    var circle = Shape.Circle.new(
        400,
        300,
        30,
        Color.fromBaseColor(BaseColor.Red, 25),
        Shape.ShapeKind.Filled,
    );
    var circleGrowing = true;

    const thinLine = Shape.GetSizedLine(
        200,
        500,
        600,
        500,
        Shape.LineType.Thin,
        Color.fromBaseColor(BaseColor.Gray, 100),
    );
    const boldLine = Shape.GetSizedLine(
        200,
        550,
        600,
        550,
        Shape.LineType.Bold,
        Color.fromBaseColor(BaseColor.Cyan, 255),
    );
    const verticalLine = Shape.GetSizedLine(
        400,
        100,
        400,
        500,
        Shape.LineType.Medium,
        Color.fromBaseColor(BaseColor.Yellow, 255),
    );

    const filledRect = Shape.Rect.new(
        500,
        100,
        150,
        100,
        Color.fromBaseColor(BaseColor.Yellow, 255),
        Shape.ShapeKind.Filled,
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

        if (rectGrowing) {
            rect = rect.increase(1);
            if (rect.width > 300) rectGrowing = false;
        } else {
            rect = rect.decrease(1);
            if (rect.width < 200) rectGrowing = true;
        }

        rect.draw(renderer);
        square1.draw(renderer);
        square2.draw(renderer);
        square3.draw(renderer);
        if (circleGrowing) {
            circle = circle.increase(1);
            if (circle.radius > 100) circleGrowing = false;
        } else {
            circle = circle.decrease(1);
            if (circle.radius < 50) circleGrowing = true;
        }
        circle.draw(renderer);
        thinLine.draw(renderer);
        boldLine.draw(renderer);
        verticalLine.draw(renderer);
        filledRect.draw(renderer);

        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }
}
