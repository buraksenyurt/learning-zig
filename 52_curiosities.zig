const std = @import("std");

// Bu örnekte Windows işletim sistemine özel bir durum ele alınıyor.
// Zig'de tüm global değişkenler derleme zamanında initialize edilmelidir.
// Ancak örneğin Windows'ta standart output'a erişim runtime zamanında mümkündür.
// Bu nedenle aşağıdaki örneği windows platformunda çalıştırmak istediğimizde
// derleme zamanı hatası alırız; error: unable to evaluate comptime expression
// const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    // Windows OS tarafında bunu aşmak için stdout değişkenini main fonksiyonu
    // içerisine alınır. Bu durumda bir sorun olmaz zira Zig dilinde fonksiyon içerisindeki
    // ifadeler(expressions) runtime'da  değerlendirilir.
    const stdout = std.io.getStdOut().writer();
    _ = try stdout.print(
        "Curiosities in Zig Language: \n\tAll global variables must be initialized at compile time.\n",
        .{},
    );
}
