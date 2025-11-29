const std = @import("std");
const utility = @import("utility.zig");
const rand = @import("rand.zig");

pub fn main() !void {
    // Veri compiler time veya runtime zamanında ele alınır.
    // Bir constant tanımladığımızda tür belirtmezsek derleyici türü otomatik olarak çıkarır (type inference).
    // Bu tür çıkarımı compiler time'da yapılır ve comptime_int, comptime_float gibi türler kullanılır
    const piValue = 3.14;
    std.debug.print("Pi value type is: {}\n", .{@TypeOf(piValue)});

    const exponantialValue: f32 = 2.71828;
    std.debug.print("Exponantial value type is: {}\n", .{@TypeOf(exponantialValue)});

    // Çalışma zamanına bir yansıması olmayan ve derleme zamanı ile ilgili türler için geçerli olan bir kavramdır.
    // comptime_int, comptime_flot gibi versiyonlarımız var.
    // Resmi kaynakta bunların boyutlarının olmadığı dolayısıyla çalışma zamanında kullanılamayacağı ifade edilmekte.
    // Bunu daha iyi anlamak için şöyle bir örnek düşünelim.
    const number: u32 = 5;
    const powerOf3 = calcPower(number, 3);
    std.debug.print("{d} to the power of 3 is {d}\n", .{ number, powerOf3 });

    // // Ancak aşağıdaki kullanım derleme zamanı hatası verir: error: unable to resolve comptime value
    // // Zira randomInt değeri sadece çalışma zamanında bilinirken, comptime ile işaretlenmiş bir parametrenin
    // // derleme zamanında biliniyor olması gerekiyor
    // const randomPower = try rand.getU8();
    // const powerOf2 = calcPower(2, randomPower);
    // std.debug.print("{d} to the power of 2 is {d}\n", .{ randomPower, powerOf2 });

    iAm(u8, 8);
    iAm(usize, 1903);
    iAm(f32, 3.14);

    // comptime operatörüne sahip türler tanımlayabiliriz. (Bir nevi generic olmuyor mu?)
    // Burada önemli olan comptime ile işaretlenmiş T türünün derleme zamanında mutlaka bilinmesi gerektiğidir.
    // Yani arrEql fonksiyonunda kullanılacak olan T türünün derleme zamanında bilinmesi şarttır.
    const arr1 = [_]u8{ 1, 2, 3, 4 };
    const arr2 = [_]u8{ 3, 5, 7, 2 };
    const result = arrEql(u8, &arr1, &arr2);
    std.debug.print("{?}\n", .{result});

    const arr3 = [_]f32{ 0.1, 0.3, 0.4 };
    const arr4 = [_]f32{ 0.1, 0.3, 0.4 };
    const result2 = arrEql(f32, &arr3, &arr4);
    std.debug.print("{?}\n", .{result2});

    useSource(u16, 18);
    useSource(f32, 3.1415);
    useSource(title, .{ .id = 1, .name = "The Legend of Zig" });

    const total1 = genericSum(u8, 1, 4);
    std.debug.print("Total1: {d}\n", .{total1});
    const total2 = genericSum(i32, 1000, 2500);
    std.debug.print("Total2: {d}\n", .{total2});
    const total3 = genericSum(f32, 12.34, 45.67);
    std.debug.print("Total3: {d}\n", .{total3});
    // const total4 = genericSum(bool, true, false);
    // std.debug.print("Total4: {d}\n", .{total4});

    // comptime isimli bir keyword' de var.
    // Bunu variable'lar, fonksiyon parametreleri ve expression'larda kullanabiliriz
    // Örneğin aşağıdaki kullanıma göre ilgili değişkenin sadece derleme zamanında yüklenip kullanılacağı belirtilir
    comptime var gravity: f32 = 9.81;
    _ = &gravity;

    // Bir comptime değişkenini var ile tanımlayabilir ve başka bir const ile başlatabiliriz
    const marsGravity: f32 = 3.71;
    comptime var currentGravitiy: f32 = 0;
    currentGravitiy = marsGravity;
    std.debug.print("Current gravity: {}\n", .{currentGravitiy});

    // Bir expression'ı da comptime ile işaretleyebiliriz
    // Bu durumda expression derleme zamanında değerlendirilir
    const earthWeight: f32 = 75.0;
    const mass: f32 = comptime earthWeight / gravity;
    const weightOnMars: f32 = mass * marsGravity;
    std.debug.print("Weight on Mars is: {}\n", .{weightOnMars});
}

const title = struct { id: u8, name: []const u8 };

// Bu üst alma fonksiyonunda ikinci parametre olarak comptime bir sayı alıyoruz
// Bu sayı derleme zamanında biliniyor olmalı.
fn calcPower(n: u32, comptime power: u32) u32 {
    var result: u32 = 1;
    for (0..power) |_| {
        result *= n;
    }
    return result;
}

fn arrEql(comptime T: type, left: []const T, right: []const T) bool {
    if (left.len != right.len) return false;

    for (left, right) |l, r| {
        if (l != r) return false;
    }

    return true;
}

fn iAm(comptime T: type, value: T) void {
    std.debug.print("I am {} and my type is {}\n", .{ value, @TypeOf(value) });
}

fn useSource(comptime T: type, source: T) void {
    std.debug.print("{?}\n", .{source});
}

// Fonksiyonlardan comptime türünden parametre de dönebiliriz.
// Aşağıdaki fonksiyon T türünden iki parametre alıyor ve T türünden bir değer döndürüyor.
fn genericSum(comptime T: type, a: T, b: T) T {
    return a + b;
}
