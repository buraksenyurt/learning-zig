const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const palette = @import("palette.zig");

pub const Rect = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    color: c.SDL_Color,
    pub fn new(x: i32, y: i32, width: i32, height: i32, color: palette.BaseColor) @This() {
        return .{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .color = palette.GetColor(color),
        };
    }

    pub fn draw(self: @This(), renderer: *c.SDL_Renderer) void {
        var rect = c.SDL_FRect{
            .x = @floatFromInt(self.x),
            .y = @floatFromInt(self.y),
            .w = @floatFromInt(self.width),
            .h = @floatFromInt(self.height),
        };
        _ = c.SDL_SetRenderDrawColor(
            renderer,
            self.color.r,
            self.color.g,
            self.color.b,
            self.color.a,
        );
        _ = c.SDL_RenderRect(renderer, &rect);
    }

    pub fn increase(self: @This(), amount: i32) Rect {
        return Rect{
            .x = self.x - amount,
            .y = self.y - amount,
            .width = self.width + 2 * amount,
            .height = self.height + 2 * amount,
            .color = self.color,
        };
    }

    pub fn decrease(self: @This(), amount: i32) Rect {
        return self.increase(-amount);
    }
};

pub const MicroSquareType = enum {
    Small,
    Medium,
    Large,
};

pub fn GetSizedSquare(x: i32, y: i32, squareType: MicroSquareType, color: palette.BaseColor) Rect {
    switch (squareType) {
        MicroSquareType.Small => return Rect.new(x, y, 16, 16, color),
        MicroSquareType.Medium => return Rect.new(x, y, 32, 32, color),
        MicroSquareType.Large => return Rect.new(x, y, 64, 64, color),
    }
}

pub const Circle = struct {
    centerX: i32,
    centerY: i32,
    radius: i32,
    color: c.SDL_Color,
    pub fn new(centerX: i32, centerY: i32, radius: i32, color: palette.BaseColor) @This() {
        return .{
            .centerX = centerX,
            .centerY = centerY,
            .radius = radius,
            .color = palette.GetColor(color),
        };
    }

    pub fn draw(self: @This(), renderer: *c.SDL_Renderer) void {
        var x: i32 = self.radius - 1;
        var y: i32 = 0;
        var dx: i32 = 1;
        var dy: i32 = 1;
        var err: i32 = dx - (self.radius << 1);

        while (x >= y) {
            _ = c.SDL_SetRenderDrawColor(
                renderer,
                self.color.r,
                self.color.g,
                self.color.b,
                self.color.a,
            );
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX + x)), @as(f32, @floatFromInt(self.centerY + y)));
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX + y)), @as(f32, @floatFromInt(self.centerY + x)));
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX - y)), @as(f32, @floatFromInt(self.centerY + x)));
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX - x)), @as(f32, @floatFromInt(self.centerY + y)));
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX - x)), @as(f32, @floatFromInt(self.centerY - y)));
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX - y)), @as(f32, @floatFromInt(self.centerY - x)));
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX + y)), @as(f32, @floatFromInt(self.centerY - x)));
            _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.centerX + x)), @as(f32, @floatFromInt(self.centerY - y)));

            if (err <= 0) {
                y += 1;
                err += dy;
                dy += 2;
            }
            if (err > 0) {
                x -= 1;
                dx += 2;
                err += dx - (self.radius << 1);
            }
        }
    }

    pub fn increase(self: @This(), amount: i32) Circle {
        return Circle{
            .centerX = self.centerX,
            .centerY = self.centerY,
            .radius = self.radius + amount,
            .color = self.color,
        };
    }

    pub fn decrease(self: @This(), amount: i32) Circle {
        return self.increase(-amount);
    }
};
