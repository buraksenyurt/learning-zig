const std = @import("std");

// 21_interfaces.zig kodundakinden farklı olarak fonksiyon işaretçileri kullanarak
// ortak davranış tanımlamak da mümkün.
// Bu uygulanış biçimi bana epeyce karışık geldi ancak pointer
// kullanımlarının uç senaryolarından birisi olduğu için öğrenmek istedim.
const ShapeAreaBehavior = struct {
    // anyopaque türü, herhangi bir türden işaretçiyi temsil etmek için kullanılıyor.
    // Kaynaklar bunu black box olarak da ifade ediyorlar. Zira bir pointer normalde,
    // işaret ettiği türün bilgisine sahiptir. anyopaque ise comptime'da hesaplanamayan
    // bir türü temsil eder ve bu nedenle işaret ettiği tür hakkında bilgi vermez, deniyor.

    // Öncelikle her şekil için alan hesaplama fonksiyon işaretçisini tutacak
    // bir field tanımı var. getAreaFn alanı da bu işaretçiyi parametre olarak alıyor.
    // asıl alan hesaplayan fonksiyonda bu alan kullanılıyor. Bir başka ifadeyle,
    // Shape türünden bir nesnenin getArea() metodu çağrıldığında, asıl şekil türüne
    // ait alan hesaplama fonksiyonu çağrılmış olması bekleniyor.
    ptr: *anyopaque,
    getAreaFn: *const fn (*anyopaque) f64,
    pub fn getArea(self: ShapeAreaBehavior) f64 {
        return self.getAreaFn(self.ptr);
    }
};

// Tabii yukarıdaki yeni kurgu bu davranışın ilgili veri yapıları için olan
// implementasyonunu da bir hayli değiştiriyor.
const Circle = struct {
    radius: f64,
    pub fn getArea(self: *anyopaque) f64 {
        // Belki de en kritik kısım aşağıdaki satır.
        // Burada anyopaque türünden gelen işaretçi, asıl türüne cast ediliyor.
        // Sonrasında asıl türün alanlarına da erişilebiliyor ve hesaplama için kullanılıyor.
        const c: *Circle = @ptrCast(@alignCast(self));
        return std.math.pi * c.radius * c.radius;
    }
    // Bu fonksiyon ise, Circle nesnesini ShapeAreaBehavior türüne dönüştürüyor.
    // Bunu yaparken getAreaFn alanına Circle nesnesinin getArea fonksiyonunu atıyor.
    pub fn toShapeAreaBehavior(self: *Circle) ShapeAreaBehavior {
        return ShapeAreaBehavior{
            .ptr = self,
            .getAreaFn = Circle.getArea,
        };
    }
};

const Rectangle = struct {
    width: f64,
    height: f64,
    pub fn getArea(self: *anyopaque) f64 {
        const r: *Rectangle = @ptrCast(@alignCast(self));
        return r.width * r.height;
    }
    pub fn toShapeAreaBehavior(self: *Rectangle) ShapeAreaBehavior {
        return ShapeAreaBehavior{
            .ptr = self,
            .getAreaFn = Rectangle.getArea,
        };
    }
};

const Triangle = struct {
    base: f64,
    height: f64,
    pub fn getArea(self: *anyopaque) f64 {
        const t: *Triangle = @ptrCast(@alignCast(self));
        return 0.5 * t.base * t.height;
    }
    pub fn toShapeAreaBehavior(self: *Triangle) ShapeAreaBehavior {
        return ShapeAreaBehavior{
            .ptr = self,
            .getAreaFn = Triangle.getArea,
        };
    }
};

pub fn main() void {
    // Birkaç şekilde tanımı yapıyoruz.
    var redCircle = Circle{ .radius = 5.0 };
    var blueRectangle = Rectangle{ .width = 4.0, .height = 6.0 };
    var greenTriangle = Triangle{ .base = 3.0, .height = 4.0 };
    // Alttaki dizi bu şekillerin ortak davranışlarını tutuyor ama toShapeAreaBehavior()
    // fonksiyonuna yaptığı çağrılar ile.
    const shapes = [_]ShapeAreaBehavior{
        redCircle.toShapeAreaBehavior(),
        blueRectangle.toShapeAreaBehavior(),
        greenTriangle.toShapeAreaBehavior(),
    };
    // Dizi üzerinde dolaşırken esasında her şeklin kendi alan hesaplama fonksiyonu
    // pointer'ları aracılığıyla işletilmiş oluyor.
    for (shapes) |shape| {
        const area = shape.getArea();
        std.debug.print("Shape area: {d}\n", .{area});
    }

    const area = findArea(redCircle.toShapeAreaBehavior());
    std.debug.print("Area from function: {d}\n", .{area});
}

// Doğal olarak ShapeAreaBehavior veri yapısını parametre alan
// dolayısıyla herhangi bir şeklin alanını hesaplayabilen fonksiyonlar da yazılabilir.
fn findArea(shape: ShapeAreaBehavior) f64 {
    return shape.getArea();
}
