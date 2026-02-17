// Comptime kullanımının avantajlarını görmenin pratik yollarından birisi
// JSON serileştirme işlemleri olabilir. Reflection'ın çalışma zamanı
// yerine derleme zamanında yapılması performans açısından büyük bir avantaj sağlar.
// Normalde standart kütüphanede JSON serileştirme işlemleri için std.json modülü var.
// Burada sadece eğitim amaçlı basit bir JSON string üreteceğiz.

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const Position = struct {
        x: f32,
        y: f32,
    };
    const myPosition = Position{
        .x = 3.13,
        .y = 10,
    };
    const jString = try stringfy(allocator, myPosition);
    defer allocator.free(jString);
    std.debug.print("{}\n", .{jString});
}

fn getValue(writer: anytype, value: anytype) !void {
    const T = @TypeOf(value);
    const info = @typeInfo(T);

    switch (info) {
        .Int, .Float => try writer.print("{d}", .{value}),
        .Bool => try writer.print("{b}", .{value}),
        .Null => try writer.print("null"),
        else => @compileError("Unsupported type :" ++ @typeName(T)),
    }
}
fn stringfy(allocator: std.mem.Allocator, value: anytype) ![]u8 {
    var list = std.ArrayList(u8).init(allocator);
    errdefer list.deinit();

    try getValue(list.writer(), value);

    return list.toOwnedSlice();
}
