const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
    pub fn new(r: u8, g: u8, b: u8, a: u8) @This() {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }
    pub fn fromBaseColor(baseColor: BaseColor, transparency: u8) Color {
        const sdlColor = GetColor(baseColor, transparency);
        return Color{
            .r = sdlColor.r,
            .g = sdlColor.g,
            .b = sdlColor.b,
            .a = sdlColor.a,
        };
    }
};

pub const BaseColor = enum {
    Black,
    Blue,
    Cyan,
    Gray,
    Green,
    Magenta,
    Red,
    Yellow,
    White,
};

pub fn GetColor(color: BaseColor, transparency: u8) c.SDL_Color {
    return switch (color) {
        .Black => c.SDL_Color{ .r = 0, .g = 0, .b = 0, .a = transparency },
        .Red => c.SDL_Color{ .r = 255, .g = 0, .b = 0, .a = transparency },
        .Green => c.SDL_Color{ .r = 0, .g = 255, .b = 0, .a = transparency },
        .Yellow => c.SDL_Color{ .r = 255, .g = 255, .b = 0, .a = transparency },
        .Blue => c.SDL_Color{ .r = 0, .g = 0, .b = 255, .a = transparency },
        .Magenta => c.SDL_Color{ .r = 255, .g = 0, .b = 255, .a = transparency },
        .Cyan => c.SDL_Color{ .r = 0, .g = 255, .b = 255, .a = transparency },
        .White => c.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = transparency },
        .Gray => c.SDL_Color{ .r = 128, .g = 128, .b = 128, .a = transparency },
    };
}
