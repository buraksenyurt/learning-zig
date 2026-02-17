// Comptime kullanımının avantajlarını görmenin pratik yollarından birisi
// JSON serileştirme işlemleri olabilir. Reflection'ın çalışma zamanı
// yerine derleme zamanında yapılması performans açısından büyük bir avantaj sağlar.
// Normalde standart kütüphanede JSON serileştirme işlemleri için std.json modülü var.
// Burada sadece eğitim amaçlı basit bir JSON string üreteceğiz.

const std = @import("std");

const Position = struct {
    x: f32,
    y: f32,
};
const Player = struct {
    name: []const u8,
    score: u32,
    position: Position,
};

pub fn main() !void {
    // Genel amaçlı bir allocator oluşturuyoruz. JSON string'ini heap'de oluşturacağız.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const jerico = Player{
        .name = "Jerico",
        .score = 1500,
        .position = Position{
            .x = 10.5,
            .y = 20.75,
        },
    };
    const jString = try stringfy(allocator, jerico);
    defer allocator.free(jString);
    std.debug.print("{s}\n", .{jString});

    // Birde array oluşturalım ve bunu JSON string'e dönüştürelim
    const players = [_]Player{
        Player{
            .name = "Bacyo",
            .score = 1500,
            .position = Position{
                .x = 10.5,
                .y = 20.75,
            },
        },
        Player{
            .name = "Lokatelli",
            .score = 2000,
            .position = Position{
                .x = 15.0,
                .y = 25.0,
            },
        },
    };
    const pString = try stringfy(allocator, players);
    defer allocator.free(pString);
    std.debug.print("{s}\n", .{pString});

    // Birde optional tür kullanımına bakalım
    const maybePlayer: ?Player = null;
    const mpString = try stringfy(allocator, maybePlayer);
    defer allocator.free(mpString);
    std.debug.print("{s}\n", .{mpString});
}

// Herhangibir zig değerini JSON string'e dönüştüren fonksiyon
// anytype kullanarak herhangi bir türdeki değeri alabiliriz.
// İlk parametre olarak bir allocator alırız çünkü JSON string'ini heap'de oluşturacağız.
fn stringifyValue(writer: anytype, value: anytype) !void {
    // tür bilgisini derleme zamanında alıyoruz
    const T = @TypeOf(value);
    const info = @typeInfo(T);

    // Tür bilgisine göre JSON string'ini oluşturuyoruz
    switch (info) {
        // primitive türlerde işimiz kolay
        .int, .float => try writer.print("{d}", .{value}),
        .bool => try writer.print("{b}", .{value}),
        .null => try writer.print("null"),
        // pointer aynı zamanda slice da olabilir.
        // Yani fullName gibi []u8 türünden bir değeri de burada ele alabiliriz
        .pointer => |ptr| {
            if (ptr.size == .slice and ptr.child == u8) {
                try writer.print("\"{s}\"", .{value});
            } else if (ptr.size == .slice) {
                try writer.writerAll("[");
                for (value, 0..) |item, i| {
                    if (i > 0) try writer.writeAll(",");
                    try stringifyValue(writer, item); // recursive çağrı
                }
                try writer.writeAll("]");
            }
        },
        // Burada ise struct türlerini ele alıyoruz.
        // Reflection sayesinde struct'ın field'larında da dolaşabiliyoruz.
        .@"struct" => |structInfo| {
            try writer.writeAll("{");
            inline for (structInfo.fields, 0..) |field, i| {
                if (i > 0) try writer.writeAll(",");
                try writer.print("\"{s}\":", .{field.name});
                try stringifyValue(writer, @field(value, field.name));
            }
            try writer.writeAll("}");
        },
        // Bir array de söz konusu olabilir
        .array => {
            try writer.writeAll("[");
            for (value, 0..) |item, i| {
                if (i > 0) try writer.writeAll(",");
                try stringifyValue(writer, item); // recursive çağrı
            }
            try writer.writeAll("]");
        },
        .optional => { // Optional türleri ele alıyoruz
            if (value) |v| {
                try stringifyValue(writer, v);
            } else {
                try writer.writeAll("null");
            }
        },
        else => @compileError("Unsupported JSON type: " ++ @typeName(T)),
    }
}

// Bir üst soyutlama diyelim. stringifyValue'yu sarmalayarak herhangi bir değeri
// JSON string'e dönüştürür
fn stringfy(allocator: std.mem.Allocator, value: anytype) ![]u8 {
    var list = std.ArrayList(u8).init(allocator);
    errdefer list.deinit();

    try stringifyValue(list.writer(), value);

    return list.toOwnedSlice();
}
