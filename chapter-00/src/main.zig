// standart kütüphaneyi kullanacağımızı belirtiyoruz
const std = @import("std");

// klasik main fonksiyonu
// exe olarak uygulamanın giriş noktası
// pub keyword'e sahip olduğuna göre public erişilebilir
// void (yani geriye bir sonuç döndürmüyor)
pub fn main() !void {
    // terminale bir bilgi yazdırıyoruz.
    // {s} string ifadelerin yerini alıyor
    // {d} decimal olduğunu düşünüyorum.
    // args: tarafında {} arasında bir tuple veri türü kullanıyoruz
    // \n , alt satıra geç anlamında (new line)
    std.debug.print("Hello there.\nMy name is {s}.\n{s}\n{s}!\nAnd my lucky number is {d}.\n", .{ "Dam", "Van Dam", "Claude Van Dam", 23 });

    var person = .{
        "John Doe",
        23,
    };
    std.debug.print("Hello there.\nMy name is {s}.\nAnd my lucky number is {d}", .{ person[0], person[1] });
}
