// Zig programlamada verileri JSON formatında serileştirmek
// için std.json modülünü kullanabiliriz.
const std = @import("std");
const json = @import("std").json;

// Öncek örnek bir struct tanımlayalım.
// Burada sembolik olarak oyun bilgilerini tutuyoruz.
const Game = struct {
    title: []const u8,
    genre: []const u8,
    releaseYear: u16,
    onSale: bool,
};

pub fn main() !void {
    // Serileştirme işlemlerinde Allocator'lar kullanarak heap'de alanlar açmamız gerekiyor.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const games = [_]Game{
        Game{
            .title = "Pac Man",
            .genre = "Arcade",
            .releaseYear = 1980,
            .onSale = true,
        },
        Game{
            .title = "The Legend of Zelda",
            .genre = "Adventure",
            .releaseYear = 1986,
            .onSale = false,
        },
        Game{
            .title = "Super Mario Bros.",
            .genre = "Platformer",
            .releaseYear = 1985,
            .onSale = true,
        },
    };

    // JSON'a serileştirme kısmı. Burada u8 türünden bir ArrayList kullandık.
    // ArrayList dinamik olarak büyüyebilen bir dizi yapısı gibi düşünülebilir
    // Bu nedenle heap'te yer açmak için allocator kullanıyoruz.
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit(); // Çıkarken kaynakları serbest bırak

    // JSON Serileştirme işinin yapıldığı yer burası
    // İlk parametre serileştirilecek değişken,
    // İkinci parametre bazı opsiyonel ayarlar. Örneğin girinti değeri 3 karaketer
    // Son parametre de serileştirilmiş içeriği yazacağımız buffer ki bu da allocator
    // yoluyla heap'te açılmış bir ArrayList.
    try json.stringify(
        games,
        .{ .whitespace = .indent_3 },
        buffer.writer(),
    );
    // Buffer içeriğini ekrana yazdırıp bir görelim
    std.debug.print("Serialized JSON:\n{s}\n", .{buffer.items});

    // Burada da içeriği bir dosyaya yazmaya çalışıyoruz.
    const filePath = "game_info.json";
    var file = try std.fs.cwd().createFile(
        filePath,
        .{ .truncate = true }, // Her seferinde dosyayı sıfırlıyoruz
    );
    defer file.close();
    // buffer içeriğini dosyaya writeAll fonksiyonu ile aktardık
    try file.writeAll(buffer.items);
    // std.debug.print("JSON data written to {s}\n", .{filePath});

    // Şimdi de deneysel çalışmaya dosyadan içeriği okuma adımı ile devam ediyoruz
    const readFile = try std.fs.cwd().openFile(filePath, .{});
    defer readFile.close();

    // Dosta içeriğini okurken maksimum 1 MB lık bir buffer kullandık
    // ki bizim örnek için epey fazla. Daha büyük boyutlar için nasıl bir ayarlama yapılır
    // incelemek lazım.
    const jsonData = try readFile.readToEndAlloc(
        allocator,
        1024 * 1024,
    );
    defer allocator.free(jsonData);

    // Şimdi de dosyadan okunan içeriği parseFromSlice metodu yardımıyla
    // Game türünden bir diziye dönüştürüyoruz.
    // İlk parametre dönüştürülecek veri yapısı, ikinci parametre allocator nesnemiz,
    // üçüncü parametre JSON verisi, dördüncü parametre ise opsiyonel ayarlar yer alıyor.
    const parsedJson = try json.parseFromSlice(
        []Game,
        allocator,
        jsonData,
        .{},
    );
    defer parsedJson.deinit();

    std.debug.print("\nGames:\n", .{});
    for (parsedJson.value) |game| {
        std.debug.print("{s},{s},{d},{}\n", .{
            game.title,
            game.genre,
            game.releaseYear,
            game.onSale,
        });
    }
}
