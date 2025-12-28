const std = @import("std");
const builtin = @import("builtin");

// !void ifadesine şimdilik takılmayalım.
// Kodun akan kısmında try ile kullanılan bir ifade var. Bu nedenle main fonksiyonu
// !void olarak işaretlendi. Yani hata döndürebilir anlamında.
pub fn main() !void {
    // Zig dilinde doğrudan string veri türü olmasa da metinsel ifadeler byte array olarak ifade edilebilirler.
    // İki string nesne türü söz konusudur. String Literal ve String Object.
    // Aşağıdaki örnekte greeting için String Object kavramını kullanabiliriz.
    // "Wellcome aboard. This is a Zig world!" ifadesi de bir String Literal olarak adlandırılabilir.
    const greeting: []const u8 = "Welcome aboard. This is a Zig world!";
    std.debug.print("{s}\n", .{greeting});

    // String literal değerleri null-terminated özelliği olan bir byte dizisine işaret eden pointer olarak düşünebiliriz.
    // Ancak bunun yanında string uzunluğu bilgisi de tutulur. Bunu daha iyi anlamak için @TypeOf ile türü inceleyebiliriz.
    // Aşağıdaki ifade Type of literalString is: *const [25:0]u8 çıktısını verir.
    // Dikkat edileceği üzere string literal ifadenin uzunluğu da tip bilgisinde yer almakta.
    // Dolayısıyla derleme zamanında da biliniyor.
    const literalString = "This is a string literal.";
    std.debug.print("Type of literalString is: {}\n", .{@TypeOf(literalString)});

    // Aynı şekilde yukarıdaki greeting değişkeninin türünü bakalım.
    // Bu sefer ekrana Type of greeting is: []const u8 çıktısı verilir. Dalayısıyla tipik bir byte array ele alınmakta.
    // Bu nedenle len özelliği ile string uzunluğunu bulmak da oldukça kolay.
    // C dilinde uzunluğu bulmak için null değerini (yani '\0' değerini) bulana kadar bir sayaç atırmak gerekirdi sanırım.
    std.debug.print("Type of greeting is: {}\n. And the lenght of this string is {}", .{
        @TypeOf(greeting),
        greeting.len,
    });

    std.debug.print("\n", .{});

    const lesson: []const u8 = "Zig is fun!";
    // String ifadelerde slicing de mümkündür.
    const sliced = lesson[0..3];
    std.debug.print("Sliced string: {s}\n", .{sliced});

    // Oluşan sliced string'in türüne de bir bakalım.
    // Type of sliced string is: []const u8 çıktısını verecektir.
    // Yani uzunluğu bilinen bir constant pointer söz konusudur.
    std.debug.print("Type of sliced string is: {}\n", .{@TypeOf(sliced)});

    // Zig string içindeki byte'ların UTF-8 karakter setine uygun olduğunu varsayar.
    // Aşağıdaki örnekte string içindeki karakterleri tek tek okuyup ekrana yazdırıyoruz.
    // Her bir karakter için karakterin kendisi, hexadecimal ve decimal gösterimini aşağıdaki döngü yardımıyla görebiliriz.
    for (lesson) |char| {
        std.debug.print("({}, {X}, {c})\n", .{
            char,
            char,
            char,
        });
    }
    // Tabii bazı karakterler birden fazla byte ile ifade edilebilir. Özellikle 255 üzeri karakterler için böyledir.
    // Aşağıdaki Japonca harflerden oluşuan Hello ifadesini inceleyelim.

    // Windows işletim sistemi terminalinde japonca karakterlerin doğru görüntülenmesi için
    // konsol kod sayfasını UTF-8 olarak ayarlamamız gerekiyormuş.
    if (builtin.os.tag == .windows) {
        _ = std.os.windows.kernel32.SetConsoleOutputCP(65001);
    }

    const japaneseHello = "こんにちは"; // "Konnichiwa"
    std.debug.print("\n{s}\n", .{japaneseHello});
    std.debug.print("Length of Japanese Hello string is: {d}\n", .{japaneseHello.len});
    // Yukarıdaki ifadenin uzunluğu 15 olarak bulunur. Bu çok normaldedir zira her bir karakter 3 byte ile ifade edilebilir.
    for (japaneseHello) |char| {
        std.debug.print("{X}:{d},", .{
            char,
            char,
        });
    }

    //Utf8View fonksiyonu ile string içindeki karakterleri dolaşabileceğimi bir iterator elde edebiliriz.
    // Bu iterator ile gireceğimi bir while döngüsünde de Japonca bir harfin
    // byte dizisi gösterimini hexadecimal formatta ekrana yazdırabiliriz ve hatta tek harf için oluşan
    // 3 byte'lık dizi parçalarını daha kolay görebiliriz.
    var utf8View = try std.unicode.Utf8View.init(japaneseHello);
    var iterator = utf8View.iterator();
    while (iterator.nextCodepointSlice()) |codePoint| {
        std.debug.print("{},", .{std.fmt.fmtSliceHexUpper(codePoint)});
    }

    // Birkaç latin karakterine de bakalım. Alpha, beta, gamma, pi gibi.
    const greekLetters = "ɑβγπ";
    std.debug.print("\n{s}\n", .{greekLetters});
    std.debug.print("Length of Greek letters string is: {d}\n", .{greekLetters.len});
    for (greekLetters) |char| {
        std.debug.print("{X}:{d},", .{
            char,
            char,
        });
    }
}
