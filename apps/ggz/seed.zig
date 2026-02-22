const std = @import("std");
const Shape = @import("shape.zig");
const Point = Shape.Point;
const Palette = @import("palette.zig");
const Color = Palette.Color;
const BaseColor = Palette.BaseColor;

pub fn loadShapes(allocator: std.mem.Allocator) ![]Shape.AnyShape {
    var list = std.ArrayList(Shape.AnyShape).init(allocator);

    const square1 = Shape.GetSizedSquare(
        Point{ .x = 50, .y = 50 },
        Shape.MicroSquareType.Small,
        Color.fromBaseColor(BaseColor.Yellow, .{}),
    );
    const square2 = Shape.GetSizedSquare(
        Point{ .x = 60, .y = 60 },
        Shape.MicroSquareType.Medium,
        Color.fromBaseColor(BaseColor.White, .{}),
    );
    const square3 = Shape.GetSizedSquare(
        Point{ .x = 70, .y = 70 },
        Shape.MicroSquareType.Large,
        Color.new(
            50,
            50,
            255,
            150,
        ),
    );
    const thinLine = Shape.GetSizedLine(
        Point{ .x = 200, .y = 500 },
        Point{ .x = 600, .y = 500 },
        Shape.LineType.Thin,
        Color.fromBaseColor(BaseColor.Gray, .{ .transparency = 100 }),
    );
    const boldLine = Shape.GetSizedLine(
        Point{ .x = 200, .y = 550 },
        Point{ .x = 600, .y = 550 },
        Shape.LineType.Bold,
        Color.fromBaseColor(BaseColor.Cyan, .{}),
    );
    const verticalLine = Shape.GetSizedLine(
        Point{ .x = 400, .y = 100 },
        Point{ .x = 400, .y = 500 },
        Shape.LineType.Medium,
        Color.fromBaseColor(BaseColor.Yellow, .{}),
    );
    const filledRect = Shape.Rect.new(
        Point{ .x = 500, .y = 100 },
        150,
        100,
        Color.fromBaseColor(BaseColor.Yellow, .{}),
        Shape.ShapeKind.Filled,
    );
    const triangle = Shape.Triangle.new(
        Point{ .x = 600, .y = 400 },
        Point{ .x = 700, .y = 400 },
        Point{ .x = 650, .y = 300 },
        Color.fromBaseColor(BaseColor.Magenta, .{ .transparency = 150 }),
    );
    try list.append(.{ .rect = square1 });
    try list.append(.{ .rect = square2 });
    try list.append(.{ .rect = square3 });
    try list.append(.{ .line = thinLine });
    try list.append(.{ .line = boldLine });
    try list.append(.{ .line = verticalLine });
    try list.append(.{ .rect = filledRect });
    try list.append(.{ .triangle = triangle });

    return list.toOwnedSlice();
}
