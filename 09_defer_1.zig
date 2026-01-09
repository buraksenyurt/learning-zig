const std = @import("std");

pub fn main() !void {
    // defer ifadesi, bir fonksiyon veya blok sona erdiğinde çalıştırılacak kod parçalarını tanımlamak için kullanılır.
    // Genellikle kaynak yönetimi için kullanılır, örneğin bellek serbest bırakma, dosya kapama gibi işlemlerde sıklıkla görürüz.
    // Temel çalışma mantığını ele alalım.
    // defer bildirimleri program içerisinde birden çok noktada yapılabilir. Bunların bir çalışma sırası vardır.
    // Aşağıdaki örneğin çalışma zamanı çıktısı şöyle olur.
    // Yani defer ifadesenin ters sırada işletildiğini söyleyebiliriz.

    // // ❯  zig run .\09_defer_1.zig
    // // [Main] Some code works.
    // // [FN] Doing something important...
    // // [FN] Finished important task.
    // // [Main] Inside main function.
    // // [Main] End of main function reached.
    // // [Defer] 02- Inner block defer executed.
    // // [Defer] 01- Shuting down
    // // [Defer] 00- Closing main function.
    defer std.debug.print("[Defer] 00- Closing main function.\n", .{});
    defer std.debug.print("[Defer] 01- Shuting down\n", .{});

    std.debug.print("[Main] Some code works.\n", .{});

    doSomething();

    defer {
        std.debug.print("[Defer] 02- Inner block defer executed.\n", .{});
    }

    std.debug.print("[Main] Inside main function.\n", .{});
    std.debug.print("[Main] End of main function reached.\n", .{});
}

fn doSomething() void {
    defer std.debug.print("[FN] Finished important task.\n", .{});
    std.debug.print("[FN] Doing something important...\n", .{});
}
