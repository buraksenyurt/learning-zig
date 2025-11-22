// standart kütüphaneyi kullanacağımızı belirtiyoruz
const std = @import("std");

// klasik main fonksiyonu
// exe olarak uygulamanın giriş noktası
// pub keyword'e sahip olduğuna göre public erişilebilir
// void olduğu için geriye bir şey döndürmediğini ifade edebiliriz.
pub fn main() void {
    // terminale bir bilgi yazdırıyoruz.
    // {s} string ifadelerin yerini alıyor
    // {d} decimal olduğunu düşünüyorum.
    // args: tarafında {} arasında bir tuple veri türü kullanıyoruz
    // \n , alt satıra geç anlamında (new line)
    std.debug.print("Hello there.\nMy name is {s}.\n{s}\n{s}!\nAnd my lucky number is {d}.\n", .{ "Dam", "Van Dam", "Claude Van Dam", 23 });

    // Person burada otomatik olarak bir struct veri türüne dönüşüyor
    // İçerisinde iki alan var: birincisi string, ikincisi integer
    // person değişkeni bu struct türünden bir örnek (instance) gibi
    const person = .{
        "John Doe", // bu constant string türünden oluştu *const [8:0]u8 şeklinde bir sabit gibi.
        23, // comptime_int, derlenme zamanında bilinen integer türünden anlamında
    };
    // person değişkeninin alanlarına erişim için indeksleme kullanılıyor
    // {d} ve {s} yer tutucularına sırasıyla person[1] ve person[0] değerleri atanıyor
    std.debug.print("Hello there.\nMy name is {s}.\nAnd my lucky number is {d}\n", .{ person[0], person[1] });
}
