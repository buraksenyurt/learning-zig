// Zig aynı zamanda bir C derleyicisidir.
// Bu nedenle C kodlarını doğrudan Zig içinde kullanabiliriz.
// Klasik bir yol olarak header dosyasını Zig'e import etmek ve ardından C fonksiyonlarını çağırmak mümkündür.
// Örneği çalıştırmak için şöyle ilerlemeliyiz:
// zig run 22_interop.zig mathy.c -lc -I .
// -lc parametresi C kütüphanesini linklememizi sağlar,
// -I . parametresi ise geçerli dizini include path olarak ekler.
const std = @import("std");

const c = @cImport({
    @cInclude("stdio.h"); // C'nin standart giriş çıkış kütüphanesini dahil ettik
    @cInclude("mathy.h"); // Bu dizinde yer alan header dosyasını dahil ettik
    @cInclude("string.h"); // C'nin string işlemleri için kullanılan kütüphanesini dahil ettik
});

pub fn main() void {
    _ = c.printf("Hello from C!\n");
    const sum = c.printf("Total value is %d\n", @as(c_int, 5 + 6));
    std.debug.print("Printed {d} characters from C printf\n", .{sum});

    const fact5 = c.factorial(5);
    std.debug.print("Factorial of 5 is {d}\n", .{fact5});

    const motto = "It's a great day for Zig!";
    const length = c.strlen(motto);
    std.debug.print("The length of the motto is {d}\n", .{length});
}
