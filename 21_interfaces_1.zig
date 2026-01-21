const std = @import("std");

// Zig dilinde doğrudan interface şeklinde bir enstrüman bulunmuyor.
// Ancak farklı tipler için aynı davranışı tanımlamak amacıyla union(enum) yapısı kullanılabilir.
// Rust tarafındaki trait'lerin rahatlığı sağlamıyor elbette ama farklı bir bakış açısı sunuyor.

// Basit bir örnek yapalım.
// Aşağıdaki örnekte farklı türden şekilleri içeren bir tagged union tanımı var.
const Shape = union(enum) {
    circle: Circle,
    rectangle: Rectangle,
    triangle: Triangle,

    // Burada her şekil için geçerli olan area isimli bir metot tanımımız var.
    pub fn area(self: @This()) f64 {
        return switch (self) {
            inline else => |s| s.area(),
        };
    }
};

// Söz konusu metot dikkat edileceği üzere Circle, Rectangle ve Triangle veri yapılarında
// asıl işini yapar vaziyette.
const Circle = struct {
    radius: f64,
    pub fn area(self: @This()) f64 {
        return std.math.pi * self.radius * self.radius;
    }
};

const Rectangle = struct {
    width: f64,
    height: f64,
    pub fn area(self: @This()) f64 {
        return self.width * self.height;
    }
};

const Triangle = struct {
    base: f64,
    height: f64,
    pub fn area(self: @This()) f64 {
        return 0.5 * self.base * self.height;
    }
};

pub fn main() void {
    // Yukarıdaki kurguya göre her biri farklı türden bir şekli ifade eden
    // ama Shape union(enum) tipiyle taşınabilen nesneler oluşturmak mümkün.
    const shapes = [_]Shape{
        Shape{ .circle = Circle{ .radius = 5.0 } },
        Shape{ .rectangle = Rectangle{ .width = 4.0, .height = 6.0 } },
        Shape{ .triangle = Triangle{ .base = 3.0, .height = 4.0 } },
    };
    // Bu durumda aşağıdaki iterasyonda Shape türünden nesnelerin alan hesaplama metodunu çağırmamız
    // aslında asıl şeklin alan hesaplama metodunu çağırmamız demek.
    for (shapes) |shape| {
        const area = shape.area();
        std.debug.print("Shape area: {d}\n", .{area});
    }

    // Buna göre parametre olarak Shape türünden nesneler alan bir fonksiyonu da
    // ortak davranışın farklı uygulanışlarını ele almak için kullanabiliriz.
    for (shapes) |shape| {
        const area = calculateArea(shape);
        std.debug.print("Calculated area: {d}\n", .{area});
    }

    // Elbette Shape türünü kullanmadan doğrudan asıl türleri de kullanabiliriz.
    const redCircle = Circle{ .radius = 10.0 };
    const redCircleArea = redCircle.area();
    std.debug.print("Red Circle area: {d}\n", .{redCircleArea});
}

// Bu fonksiyon Shape türünden bir nesne alıp onun alanını hesaplıyor.
// Örneğin Circle gönderirsek onun alanını hesaplar.
fn calculateArea(s: Shape) f64 {
    std.debug.print("The type is {}\n", .{@TypeOf(s)});
    return s.area();
}
