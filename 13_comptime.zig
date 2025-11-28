const std = @import("std");
const utility = @import("utility.zig");

pub fn main() !void {
    // comptime kavramını anlamakta biraz zorlanıyorum!
    // Çalışma zamanına bir yansıması olmayan ve derleme zamanı ile ilgili türler için geçerli bir kavram.
    // comptime_int, comptime_flot gibi versiyonlarımız var.
    // Resmi kaynakta bunların boyutlarının olmadığı dolayısıyla çalışma zamanında kullanılamayacağı ifade edilmekte
    // Bunu daha iyi anlamak için şöyle bir örnek düşünelim.
    const number: u32 = 5;
    const powerOf3 = calcPower(number, 3);
    std.debug.print("{d} to the power of 3 is {d}\n", .{ number, powerOf3 });

    // // Ancak aşağıdaki kullanım derleme zamanı hatası verir: error: unable to resolve comptime value
    // // Zira randomInt değeri çalışma zamanında biliniyor olacak oysa ki comptime ile işaretlenmiş bir parametre
    // // derleme zamanında biliniyor olmalı
    // const randomPower = try utility.createRandomInteger();
    // const powerOf2 = calcPower(2, randomPower);
    // std.debug.print("{d} to the power of 2 is {d}\n", .{ randomPower, powerOf2 });

    iAm(u8, 8);
    iAm(usize, 1903);
    iAm(f32, 3.14);

    // comptime operatörüne sahip türler tanımlayabiliriz. Bir nevi generic oluyor mu?
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
}

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
