const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const palette = @import("palette.zig");
const Color = palette.Color;
const BaseColor = palette.BaseColor;

pub const ShapeKind = enum {
    Normal,
    Filled,
};

pub const AnyShape = union(enum) {
    rect: Rect,
    circle: Circle,
    line: Line,
    triangle: Triangle,

    pub fn draw(self: AnyShape, renderer: *c.SDL_Renderer) void {
        switch (self) {
            inline else => |s| s.draw(renderer),
        }
    }
};

pub const Point = struct {
    x: i32,
    y: i32,
    pub fn increment(self: @This(), amount: i32) Point {
        return Point{
            .x = self.x + amount,
            .y = self.y + amount,
        };
    }
};

pub const Rect = struct {
    point: Point,
    width: i32,
    height: i32,
    color: Color,
    shapeKind: ShapeKind = ShapeKind.Normal,
    pub fn new(point: Point, width: i32, height: i32, color: Color, shapeKind: ShapeKind) @This() {
        return .{
            .point = point,
            .width = width,
            .height = height,
            .color = color,
            .shapeKind = shapeKind,
        };
    }

    pub fn draw(self: @This(), renderer: *c.SDL_Renderer) void {
        var rect = c.SDL_FRect{
            .x = @floatFromInt(self.point.x),
            .y = @floatFromInt(self.point.y),
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
        switch (self.shapeKind) {
            ShapeKind.Normal => _ = c.SDL_RenderRect(renderer, &rect),
            ShapeKind.Filled => _ = c.SDL_RenderFillRect(renderer, &rect),
        }
    }

    pub fn increase(self: @This(), amount: i32) Rect {
        return Rect{
            .point = self.point.increment(-amount),
            .width = self.width + 2 * amount,
            .height = self.height + 2 * amount,
            .color = self.color,
            .shapeKind = self.shapeKind,
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

pub fn GetSizedSquare(point: Point, squareType: MicroSquareType, color: Color) Rect {
    switch (squareType) {
        MicroSquareType.Small => return Rect.new(
            point,
            16,
            16,
            color,
            ShapeKind.Normal,
        ),
        MicroSquareType.Medium => return Rect.new(
            point,
            32,
            32,
            color,
            ShapeKind.Normal,
        ),
        MicroSquareType.Large => return Rect.new(
            point,
            64,
            64,
            color,
            ShapeKind.Normal,
        ),
    }
}

pub const Circle = struct {
    origin: Point,
    radius: i32,
    color: Color,
    shapeKind: ShapeKind = ShapeKind.Normal,
    pub fn new(origin: Point, radius: i32, color: Color, shapeKind: ShapeKind) @This() {
        return .{
            .origin = origin,
            .radius = radius,
            .color = color,
            .shapeKind = shapeKind,
        };
    }

    pub fn draw(self: @This(), renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(
            renderer,
            self.color.r,
            self.color.g,
            self.color.b,
            self.color.a,
        );

        var x: i32 = self.radius - 1;
        var y: i32 = 0;
        var dx: i32 = 1;
        var dy: i32 = 1;
        var err: i32 = dx - (self.radius << 1);

        while (x >= y) {
            switch (self.shapeKind) {
                ShapeKind.Normal => {
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x + x)), @as(f32, @floatFromInt(self.origin.y + y)));
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x + y)), @as(f32, @floatFromInt(self.origin.y + x)));
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x - y)), @as(f32, @floatFromInt(self.origin.y + x)));
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x - x)), @as(f32, @floatFromInt(self.origin.y + y)));
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x - x)), @as(f32, @floatFromInt(self.origin.y - y)));
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x - y)), @as(f32, @floatFromInt(self.origin.y - x)));
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x + y)), @as(f32, @floatFromInt(self.origin.y - x)));
                    _ = c.SDL_RenderPoint(renderer, @as(f32, @floatFromInt(self.origin.x + x)), @as(f32, @floatFromInt(self.origin.y - y)));
                },
                ShapeKind.Filled => {
                    _ = c.SDL_RenderLine(renderer, @as(f32, @floatFromInt(self.origin.x - x)), @as(f32, @floatFromInt(self.origin.y + y)), @as(f32, @floatFromInt(self.origin.x + x)), @as(f32, @floatFromInt(self.origin.y + y)));
                    _ = c.SDL_RenderLine(renderer, @as(f32, @floatFromInt(self.origin.x - x)), @as(f32, @floatFromInt(self.origin.y - y)), @as(f32, @floatFromInt(self.origin.x + x)), @as(f32, @floatFromInt(self.origin.y - y)));
                    _ = c.SDL_RenderLine(renderer, @as(f32, @floatFromInt(self.origin.x - y)), @as(f32, @floatFromInt(self.origin.y + x)), @as(f32, @floatFromInt(self.origin.x + y)), @as(f32, @floatFromInt(self.origin.y + x)));
                    _ = c.SDL_RenderLine(renderer, @as(f32, @floatFromInt(self.origin.x - y)), @as(f32, @floatFromInt(self.origin.y - x)), @as(f32, @floatFromInt(self.origin.x + y)), @as(f32, @floatFromInt(self.origin.y - x)));
                },
            }

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
            .origin = self.origin,
            .radius = self.radius + amount,
            .color = self.color,
            .shapeKind = self.shapeKind,
        };
    }

    pub fn decrease(self: @This(), amount: i32) Circle {
        return self.increase(-amount);
    }
};

pub const Line = struct {
    start: Point,
    end: Point,
    color: Color,
    pub fn new(start: Point, end: Point, color: Color) @This() {
        return .{
            .start = start,
            .end = end,
            .color = color,
        };
    }

    pub fn draw(self: @This(), renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(
            renderer,
            self.color.r,
            self.color.g,
            self.color.b,
            self.color.a,
        );
        _ = c.SDL_RenderLine(
            renderer,
            @as(f32, @floatFromInt(self.start.x)),
            @as(f32, @floatFromInt(self.start.y)),
            @as(f32, @floatFromInt(self.end.x)),
            @as(f32, @floatFromInt(self.end.y)),
        );
    }
};

pub const LineType = enum {
    Thin,
    Medium,
    Bold,
};

pub fn GetSizedLine(start: Point, end: Point, lineType: LineType, color: Color) Line {
    switch (lineType) {
        LineType.Thin => return Line.new(start, end, color),
        LineType.Medium => return Line.new(Point{ .x = start.x, .y = start.y + 1 }, Point{ .x = end.x, .y = end.y + 1 }, color),
        LineType.Bold => return Line.new(Point{ .x = start.x, .y = start.y + 2 }, Point{ .x = end.x, .y = end.y + 2 }, color),
    }
}

pub const Triangle = struct {
    point1: Point,
    point2: Point,
    point3: Point,
    color: Color,
    pub fn new(point1: Point, point2: Point, point3: Point, color: Color) @This() {
        return .{
            .point1 = point1,
            .point2 = point2,
            .point3 = point3,
            .color = color,
        };
    }

    pub fn draw(self: @This(), renderer: *c.SDL_Renderer) void {
        _ = c.SDL_SetRenderDrawColor(
            renderer,
            self.color.r,
            self.color.g,
            self.color.b,
            self.color.a,
        );
        _ = c.SDL_RenderLine(renderer, @as(f32, @floatFromInt(self.point1.x)), @as(f32, @floatFromInt(self.point1.y)), @as(f32, @floatFromInt(self.point2.x)), @as(f32, @floatFromInt(self.point2.y)));
        _ = c.SDL_RenderLine(renderer, @as(f32, @floatFromInt(self.point2.x)), @as(f32, @floatFromInt(self.point2.y)), @as(f32, @floatFromInt(self.point3.x)), @as(f32, @floatFromInt(self.point3.y)));
        _ = c.SDL_RenderLine(renderer, @as(f32, @floatFromInt(self.point3.x)), @as(f32, @floatFromInt(self.point3.y)), @as(f32, @floatFromInt(self.point1.x)), @as(f32, @floatFromInt(self.point1.y)));
    }
};
