const std = @import("std"); // standart kütüphaneyi kullanacağımız belirtiyoruz

pub fn main() void {
    // Player struct' ı türünden bir değişken tanımı
    // Burada Velocity değerlerini atarken x değerini atamadığımıza dikkat edelim.
    // Velocity içerisinde x ve y alanları default değerlere sahip. Bu nedenle x için ilk değer vermesekte derleme hatası almayız.
    // zira normal şartlarda struct'ın tüm alanlarına değer atanması beklenir.
    // Aksi durumda aşağıdaki julyet örneğindeki gibi derleme hatası alınır
    const draga = Player{ .nick = "Ivan Dragaa", .power = 85, .level = -300, .velocity = Velocity2D{ .y = 1.0 } };

    // terminal çıktısı almak için print metodu kullanılıyor
    // s, metinsel ifadeleri, d sayısal ifadeleri işaret eden placeholder'lar
    // ikini parametre bir tuple olarak ifade ediliyor ve placeholder yerine gelecek değerler burada yazılıyor
    std.debug.print("{s} ({d})\n", .{ draga.nick, draga.level });

    // std.debug.print("\n"); // Bu şekilde kullanamıyoruz
    std.debug.print("\n", .{}); // Şeklinde boş bir tuple vermek gerekiyor.

    // Player veri yapısında tanımlanan print fonksiyonu ile içeriğini ekrana yazdırıyoruz
    draga.print();

    // // Bir struct oluşturulurken mutlaka tüm değerlerine atama yapılması gerekir.
    // // Örneğin aşağıdaki kullanım şöyle bir derleme hatasına neden olur
    // // error: missing struct field: velocity
    // // const julyet = Player{

    // const julyet = Player{
    //     .nick = "Juli-Et",
    //     .power = 10,
    //     .level = 190,
    // };
    // julyet.print();

    // Rust tip sisteminde de güçlü olan enum enstrümanı Zig'de de mevcut.
    // Örneğin GameLevel isimli bir enum tanımlayalım
    const GameLevel = enum {
        Easy,
        Medium,
        Hard,
        Insane,
    };
    const currentLevel = GameLevel.Hard;
    std.debug.print("Current game level: {}\n", .{currentLevel});

    // Enum'larda integer türünden tag değerleri de kullanılabilir
    // Örneğin HttpStatusCode enum'ındaki her bir durum kodu u16 türünden bir değer ile ifade ediliyor
    const HttpStatusCode = enum(u16) {
        Ok = 200,
        Created = 201,
        Accepted = 202,
        NoContent = 204,
    };
    var status = HttpStatusCode.Created;
    // status değişkeni enum türünden bir değer olduğundan direkt olarak integer türüne çevrilemez
    // Bunun için @intFromEnum fonksiyonu kullanılır
    std.debug.print("{}:{d}\n", .{ status, @intFromEnum(status) });

    // Enum türlerinde switch-case yapısı da kullanılabilir
    // Rust dilindeki match ifadesine benzer bir kullanım söz konusu ve burada da tüm olasılıkların ele alınması gerekir
    // Herhangi bir durumun ele alınmaması derleme hatasına neden olur:
    // Örneğin aşağıdaki kullanımda NoContent durumunu kapatırsak şöyle bir hata alırız:
    // unhandled enumeration value: 'NoContent',
    status = HttpStatusCode.Accepted;
    switch (status) {
        .Ok => std.debug.print("Request succeeded with 200 OK\n", .{}),
        .Created => std.debug.print("Resource created successfully with 201 Created\n", .{}),
        .Accepted => std.debug.print("Request accepted with 202 Accepted\n", .{}),
        .NoContent => std.debug.print("No content to send back with 204 No Content\n", .{}),
    }

    // Enum türlerindeki değerlerin bellekte kapladığı alanı küçültmek için
    // daha küçük bir integer türü de kullanılabilir. Bu oldukça enteresan geldi.
    // integer tag types olarak geçen bir mevzu.
    // Aşağıdaki örnek kullanım kayda değer. u2 kullandığımız için dördüncü bir eleman ekleyip 4 değerini veremiyoruz.
    // Yani 0,1,2,3 değerlerini temsil edebilen bir tür kullanabiliyoruz.
    // , Fourth = 4  değerini eklemeye çalışırsak derleme hatası alırız:
    // error: type 'u2' cannot represent integer value '4'
    const SmallEnum = enum(u2) { First = 1, Second = 2, Third = 3 };
    const smallValue = SmallEnum.Third;
    std.debug.print("Small enum value: {} with int value {d}\n", .{ smallValue, @intFromEnum(smallValue) });

    // Benzer şekilde u5 türünden bir enum tanımlayalım
    // u5 türü 0-31 aralığındaki değerleri temsil edebilir
    const v = enum(u5) {
        Alpha = 1,
        Beta = 2,
        Gamma = 3,
        Delta = 4,
        Epsilon = 31, // 32 olamaz
    };
    const vValue = v.Delta;
    std.debug.print("v enum value: {} with int value {d}\n", .{ vValue, @intFromEnum(vValue) });

    // Enum'larda var veya const deklerasyonlar da kullanılabilir
    // Örneğin aşağıdaki enum tanımında yer alan Some alanını var ile tanımladık
    // Bu değere enum değişkeni üzerinden erişip değiştirebiliriz
    // Rust'taki Option enum türüne benzetmeye çalıştım ama aynı şey değildir elbette.
    const option = enum {
        var Some: u32 = 0;
        None,
    };
    const opt1 = option.None;
    std.debug.print("Option 1: {}\n", .{opt1});
    option.Some = 23;
    std.debug.print("Option Some value updated: {d}\n", .{option.Some});

    const someError = RequestError.NotFound;
    std.debug.print("Is someError a client error? {}\n", .{someError.isClientError()});
}

// Enum veri türünün çok güçlü olduğunu söylemiştim.
// Fonksiyonlarda içerebilir. Örneğin;
const RequestError = enum {
    NotFound,
    Unauthorized,
    ServerError,
    Timeout,
    BadRequest,

    fn isClientError(self: RequestError) bool {
        return switch (self) {
            .NotFound, .Unauthorized => true,
            else => false,
        };
    }
};

// Bir veri yapısı tanımı
const Player = struct {
    nick: []const u8, // String türü yok onun yerine u8 türünden bir aray söz konusu
    power: u8, // Pozitif 8 bit tam sayı
    level: i32, // pozitif/negatif aralıklı 32 bit integer
    velocity: Velocity2D, // Kendi tanımladığımı bir struct'ı da alan olarak kullanabiliriz.

    // Struct içerisinde fonksiyon tanımlanabilir
    // Dikkat edileceği üzere
    // self ile Player nesnesinin o anki referansına erişiliyor diye düşünüyorum(Rust'ta benzer bir kullanım var)
    fn print(self: Player) void {
        std.debug.print("{s} ({d}) - Power:{d}\n", .{ self.nick, self.level, self.power });
        // {d:.2} ile float değer için noktadan sonra 2 hane göstereceğini belirtiyoruz
        std.debug.print("V->({d:.2} x {d:.2})\n", .{ self.velocity.x, self.velocity.y });
    }
};

// Field'lara istenirse default değerler atanabilir
const Velocity2D = struct { x: f32 = 0.0, y: f32 = 0.0 };
