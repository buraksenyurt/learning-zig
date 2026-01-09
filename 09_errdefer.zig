const std = @import("std");

// defer ile benzer şekilde kullanılabilecek bir diğer enstrüman da errdefer ifadesidir.
// defer'den farklı olarak sadece bulunduğu scope bir hata ile sonlanırsa işletilir.
// defer' de olduğu gibi errdefer ifadeleri de ters sırada çalışır.
pub fn main() !void {
    defer std.debug.print("[Defer] 00 is working...\n", .{});
    std.debug.print("Starting main function...\n", .{});

    for (0..5) |i| {
        defer std.debug.print("[Defer] 01 Cleanup for iteration: {}\n", .{i});
        errdefer std.debug.print("[ErrDefer] 00 Error occurred at iteration: {}\n", .{i});
        std.debug.print("Doing something with: {}\n", .{i});
        if (i == 2) {
            return error.LoopError; // Burada kasıtlı olarak bir hata fırlatıyoruz.
        }
    }

    std.debug.print("This line will not be printed if error occurs.\n", .{});
}
// // Program çalıştırıldığında aşağıdaki çıktıyı elde ederiz
// // Dikkat edileceği üzere döngü içerisinde kasıtlı olarak hata fırlattığımız bir indeks değeri var.
// // Bu durumda döngü de tanımladığımı errdefer ifadesi işletilir ancak hata alınana kadar sadece normal defer ifadeleri işletilir.
// // Tabii program hata ile sonlandığı için döngü tamamlanamaz ve sonrasında gelen print ifadesi çalıştırılmaz.

// // Starting main function...
// // Doing something with: 0
// // [Defer] 01 Cleanup for iteration: 0
// // Doing something with: 1
// // [Defer] 01 Cleanup for iteration: 1
// // Doing something with: 2
// // [ErrDefer] 00 Error occurred at iteration: 2
// // [Defer] 01 Cleanup for iteration: 2
// // [Defer] 00 is working...
// // error: LoopError
// // C:\Users\burak\Development\learning-zig\09_errdefer.zig:15:13: 0x7ff62d3be75e in main (09_errdefer.exe.obj)
// //             return error.LoopError;
