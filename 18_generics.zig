const std = @import("std");

// Generic mimariyi karlşılamak için aşağıdaki gibi type kullanan fonksiyonlar kullanılmakta.
// Aşağıdaki örneğe göre comptime türünden T türünden bir Vector yapısı oluşturulmakta.
fn Vector(comptime T: type) type {
    return struct { x: T, y: T };
}

// Zig dilinde generic yapının kullanıldığı popüler örneklerden birisi Linked List yapısı.
// Aşağıdaki fonksiyon en ilkel haliyle bir generic list veri yapısı oluşturup döndürmekte.
fn LinkedList(comptime T: type) type {
    return struct {
        value: T,
        next: ?*LinkedList(T) = null, // @This de kullanılabilir
    };
}

pub fn main() void {
    // Dikkat edileceği üzere Vector fonksiyonu kullanılarak
    // i32, f64 ve u8 türlerinden Vector yapıları oluşturulmakta.
    // Bu sayede tek bir yapı tanımı ile farklı türlerde vektörler oluşturmak mümkün.
    // Bir nevi generic yapının sağlandığını ifade edebiliriz.
    const IntVector = Vector(i32);
    const vec: IntVector = .{ .x = 10, .y = -5 };
    std.debug.print("Vector x: {}, y: {}\n", .{ vec.x, vec.y });

    const FloatVector = Vector(f64);
    const fvec: FloatVector = .{ .x = 10.50, .y = -20 };
    std.debug.print("Vector x: {}, y: {}\n", .{ fvec.x, fvec.y });

    const U8Vector = Vector(u8);
    const u8vec: U8Vector = .{ .x = 200, .y = 55 };
    std.debug.print("Vector x: {}, y: {}\n", .{ u8vec.x, u8vec.y });

    // Generic Linked List yapısının kullanımına ait birkaç örnek
    const IntList = LinkedList(i32);
    var root = IntList{
        .value = 1,
    };
    var sibling = IntList{
        .value = 3,
    };
    root.next = &sibling;
    std.debug.print("Root node {}\n", .{root});

    const StrList = LinkedList([]const u8);
    var strRoot = StrList{
        .value = "html",
    };
    var strSibling = StrList{
        .value = "head",
    };
    strRoot.next = &strSibling;
    var strSibling2 = StrList{
        .value = "body",
    };
    strSibling.next = &strSibling2;
    std.debug.print("Root node {?:}\n", .{strRoot});
}
