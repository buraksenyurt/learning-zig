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

    // std library'de yer alan ve string operasyonlar için kullanabileceğimiz birkaç fonksiyon örneği
    // Metinsel ifadeleri karşılaştırma
    const title = "Programming in Zig";
    std.debug.print(
        "\nAre the strings equal? {any}\n",
        .{std.mem.eql(u8, title, "Programming in Zig")},
    );

    // splitScalar ile bir delimeter karakterine göre string parçalayabiliriz.
    // Örneğin bir CSV içeriğinden gelen satırı virgül karakterine göre ayırmak istediğimizi düşünelim.
    // splitScalar bir iterator döndürür ve bunu bir while döngüsünde kullanabiliriz.
    const csvLine = "Jan,Cey,Rambo,30,Special Forces";
    var parts = std.mem.splitScalar(
        u8,
        csvLine,
        ',',
    );
    while (parts.next()) |part| { // Döngü koşulu olarak bir sonraki parça var mı diye kontrol ediyoruz
        std.debug.print("{s}\n", .{part});
    }

    // splitSequence ile birden fazla karakterden oluşan delimiter'lar da kullanılabilir.
    // Aslında burada delimeter bir subString olarak düşünülebilir.
    // Aşağıdaki örnekte çift noktalı virgül (;; ) karakterine göre string parçalama işlemi yapılıyor.
    const text = "apple;;banana;;orange;;grape";
    var multiParts = std.mem.splitSequence(u8, text, ";;");
    while (multiParts.next()) |part| { // Burada da takip eden bir parça var mı kontrolü yapılıyor
        std.debug.print("{s}\n", .{part});
    }

    // startsWith ve endsWith fonksiyonları da oldukça kullanışlıdır.
    const filename = "SalaryReport.rdl";
    std.debug.print("\nDoes the filename start with 'Salary'? {any}\n", .{
        std.mem.startsWith(u8, filename, "Salary"),
    });
    std.debug.print("Does the filename end with '.rdl'? {any}\n", .{
        std.mem.endsWith(u8, filename, ".rdl"),
    });

    // String'leri birleştirmek için concat(concatenate) fonksiyonundan yararlanabiliriz.
    // Ancak bu işlem sanıldığı kadar kolay olmayabilir.
    // Zira fonksiyon ilk parametre ile bir allocator alır.
    // Aşağıdaki örnekte genel amaçlı bir allocator oluşturuluyor ve bunun allocator özelliği kullanılıyor.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit(); // scope sonunda allocator kaynaklarının serbest bırakılmasını belirttik
    const allocator = gpa.allocator();

    const firstName = "Jan";
    const middleName = "Claude";
    const lastLastName = "Van";
    const lastLastLastName = "Damme";
    const nameParts = &[_][]const u8{
        firstName,
        middleName,
        lastLastName,
        lastLastLastName,
    };
    // İlk parametre allocator, ikinci parametre ise string türü, üçüncü parametre ise birleştirilecek string dizisi.
    const fullName2 = try std.mem.concat(allocator, u8, nameParts);
    defer allocator.free(fullName2);

    std.debug.print("\nFull name is: {s} :D\n", .{fullName2});

    // Tabii daha basit birleştirme için ++ operatörünü de kullanabiliriz de :D
    const statetment = firstName ++ " " ++ middleName ++ " " ++ lastLastName ++ " " ++ lastLastLastName;
    std.debug.print("Full name using ++ operator is: {s} :D\n", .{statetment});

    // Bir diğer kullanışlı olabilecek fonksiyon da replace'dir.
    // Birkaç satırdan oluşan bir metinsel içerikte karakter değiştirme işlemi yapalım.
    const content =
        \\ <html>
        \\    <head>
        \\       <title>Sample Page -&gt; Zig Lang</title>
        \\   </head>
        \\   <body>
        \\      <h1>Hell0 -&gt; W0rld!</h1>
        \\  </body>
        \\ </html>
    ;
    // replace fonksiyonu orijinal içeriği değiştirmez. Sonuç yeni bir buffer içine yazılır.
    // Bu nedenle yeterli büyüklükte bir buffer tanımlıyoruz.
    var buffer: [content.len]u8 = undefined;
    const repCount = std.mem.replace(
        u8,
        content,
        "0",
        "o",
        buffer[0..],
    );
    std.debug.print("\nReplaced content:\n{s}\nReplaced: {d}", .{
        buffer,
        repCount,
    });
    // Şimdi buffer içeriğinden yeni bir string literal oluşturalım.
    const finalContent = buffer[0..];
    // ve şimdi de bu içerikteki &gt; karakterlerini > karakteri ile değiştirelim.
    var finalBuffer: [buffer.len]u8 = undefined;
    const finalRepCount = std.mem.replace(
        u8,
        finalContent,
        "&gt;",
        ">",
        finalBuffer[0..],
    );

    std.debug.print("\nFinal replaced content:\n{s}\nReplaced: {d}", .{
        finalBuffer,
        finalRepCount,
    });
    // Tabii yukarıdaki son kullanımda gizemli bir durum var.
    // 4 karakterlik bir ifadeyi 1 karakterlik bir ifade ile değiştirdik ama yeni buffer
    // uzunluğu orijinal buffer uzunluğuna eşit tanımlandı.
    // Bu durumda finalBuffer'da fazladan boşluk kalacaktır.
    // Bunu önlemek için dinamik bir buffer kullanılabilir ama bunu ileride,
    // allocator konusunu daha iyi öğrendiğimde ele alacağım.
}
