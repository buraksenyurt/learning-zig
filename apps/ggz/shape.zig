const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub const Rect = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    color: c.SDL_Color,
    //todo@burak: get colors from enums or something instead of using SDL_Color directly
    pub fn new(x: i32, y: i32, width: i32, height: i32, color: c.SDL_Color) @This() {
        return .{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .color = color,
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
};
