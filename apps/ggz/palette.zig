const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub const BaseColor = enum {
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
};

pub fn GetColor(color: BaseColor) c.SDL_Color {
    return switch (color) {
        .Black => c.SDL_Color{ .r = 0, .g = 0, .b = 0, .a = 255 },
        .Red => c.SDL_Color{ .r = 255, .g = 0, .b = 0, .a = 255 },
        .Green => c.SDL_Color{ .r = 0, .g = 255, .b = 0, .a = 255 },
        .Yellow => c.SDL_Color{ .r = 255, .g = 255, .b = 0, .a = 255 },
        .Blue => c.SDL_Color{ .r = 0, .g = 0, .b = 255, .a = 255 },
        .Magenta => c.SDL_Color{ .r = 255, .g = 0, .b = 255, .a = 255 },
        .Cyan => c.SDL_Color{ .r = 0, .g = 255, .b = 255, .a = 255 },
        .White => c.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 },
    };
}
