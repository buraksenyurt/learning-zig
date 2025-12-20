const std = @import("std"); // standart kütüphaneyi kullanacağımızı belirtiyoruz

// En basit haliyle kendi tanımladığımız bir struct türü
const Date = struct {
    year: i32,
    month: u8,
    day: u8,
};

// Bazı kaynaklarda struct'ın kendisi üzerinde okuma veya değiştirme işlemleri yapan fonksiyonlarda
// ilk parametre olarak self, this gibi isimlendirmelerin kullanıldığını ama veri tipi olarak @This() ifadesinin
// tercih edildiğini görüyoruz. Buna göre örneğin Date veri yapısının biraz daha genişletilmiş bir versiyonu aşağıdaki
// gibi de oluşturulabilir.

const Date2 = struct {
    year: i32,
    month: u8,
    day: u8,

    // Dönüş türü olarak @This() kullanımı
    fn new(year: i32, month: u8, day: u8) @This() {
        return .{
            .year = year,
            .month = month,
            .day = day,
        };
    }

    // Struct adı yerine @This() kullanımı
    fn print(self: @This()) void {
        std.debug.print("{d}-{d}-{d}\n", .{
            self.year,
            self.month,
            self.day,
        });
    }

    // Veri yapısından değişiklik yapan bir fonksiyonda @This() kullanımı
    fn nextDay(self: *@This()) void {
        self.day += 1;
        // Basitlik açısından tabii ki ay sonu ve yıl sonu kontrolleri yok :D
    }
};

pub fn main() void {
    // En basit haliyle kendi tanımladığımız bir struct türünden olan değişken tanımlarını aşağıdaki gibi yapabiliriz
    const today: Date = Date{ .year = 2025, .month = 12, .day = 20 };
    std.debug.print("Today is {}\n", .{today});
    // Sağ tarafta açıkça tür ismi belirtmesekte . sonrasındaki alanlar birebir Date struct ile uyumlu olduğundan
    // derleyici bunu anlayacaktır
    const birthday: Date = .{ .year = 1976, .month = 12, .day = 4 };
    std.debug.print("Birthday is {}\n", .{birthday});
    const someDate = Date2.new(2025, 12, 20);
    someDate.print();
    var mutableDate = someDate;
    mutableDate.nextDay();
    mutableDate.print();

    // Player struct' ı türünden bir değişken tanımı
    // Burada Velocity değerlerini atarken x değerini atamadığımıza dikkat edelim.
    // Velocity içerisinde x ve y alanları default değerlere sahip. Bu nedenle x için ilk değer vermesek dahi derleme hatası almayız.
    // zira normal şartlarda struct'ın tüm alanlarına değer atanması beklenir.
    // Aksi durumda aşağıdaki julyet örneğindeki gibi derleme hatası alınır
    const draga = Player{
        .nick = "Ivan Dragaa",
        .power = 85,
        .level = -300,
        .velocity = Velocity2D{ .y = 1.0 },
    };

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

    // create fonksiyonunu kullanarak bir Player değişkeninin oluşturulması
    // julyet'in değerlerinde değişiklik yapacağımız için var ile tanımladık
    // Değişikliği changeVelocity fonksiyonu yapmakta.
    // const ile tanımlarsak derleme hatası alırız.
    var julyet = Player.create(
        "Juli-Et",
        10,
        190,
        Velocity2D{ .x = 0.5, .y = 0.8 },
    );
    julyet.print();
    julyet.changeVelocity(1.5, 2.0); // changeVelocity fonksiyonu ile hız değerlerinin değiştirilmesi
    std.debug.print("After move:\n", .{});
    julyet.print();

    // print fonksiyonunda da sıklıkla kullanılan Tuple türünden değişkenler de birer struct olarak düşünülebilir.
    // Örneğin aşağıdaki game değişkeni beş farklı türden alanı barındıran bir tuple türü.
    const game = .{ "Adventure of Zig", 2025, "Strategy, RPG", 7.9, "$19.99" };
    std.debug.print("Game Info:\n", .{}); // Tüm içeriğini doğrudan yazdırabiliriz
    std.debug.print("Title: {s}\n", .{game[0]}); // Ya da indislerle ulaşabiliriz
    std.debug.print("Release Year: {d}\n", .{game.@"1"}); // Ya da @"indis" şeklinde erişim sağlayabiliriz
    std.debug.print("Genres: {s}\n", .{game[2]});
    std.debug.print("Length of tuple is {d}\n", .{game.len}); // Bir tuple'ın byte cinsinden uzunluğu

    // // tuple türü ile ilgili önemli bir diğer husus da iç elemanlarını nasıl değiştirebileceğimizdir.
    // var origin = .{ 0.0, 0.0 };
    // std.debug.print("Origin type: {}\n", .{@TypeOf(origin)});
    // origin[0] = 10.0; // Burada derleme hatası alınır. error: cannot assign to constant
    // // Öncelikli olarak origin var ile tanımlanmalıdır ancak bu yeterli olmaz.
    // // Zira var ile tanımlasak bile derleyici bu kez şöyle bir hata verir
    // // error: value stored in comptime field does not match the default value of the field
    // // Bu son derece doğaldır çünkü tuple içeriğindeki elemanlar değiştirilemez comptime sabitlerdir.
    // // Burada çözüm olarak tuple içerisinde değiştirilebilir (mutable) olması beklenen elemanları dışarıdan verebiliriz.
    var x: i32 = 0.0;
    _ = &x;
    var origin = .{ x, 0.0 };
    std.debug.print("Origin type: {}\n", .{@TypeOf(origin)}); // x değişkeni artık comptime int değil i32 türündendir
    origin[0] = 10.0; // Artık derleme hatası alınmaz
    std.debug.print("Origin after change: ({d}, {d})\n", .{ origin[0], origin[1] });

    // Tuple'ları birbirleriyle birleştirebiliriz (concatenation)
    // Bunun için ++ operatörü kullanılır
    // Ya da kendisini tekrar ettirecek şekilde çoklayabiliriz. Bunun için de ** operatörü kullanılır
    const points = .{ 10, 20, 30 };
    const names = .{ "Jonathan", "Anderson", "Eva" };
    const combined = points ++ names;
    std.debug.print("Points and Names: {}\n", .{combined});

    const repeated = points ** 3;
    std.debug.print("Repeated Points: {}\n", .{repeated});
}

// Bir veri yapısı tanımı
const Player = struct {
    nick: []const u8, // String türü yok onun yerine u8 türünden bir aray söz konusu
    power: u8, // Pozitif 8 bit tam sayı
    level: i32, // pozitif/negatif aralıklı 32 bit integer
    velocity: Velocity2D, // Kendi tanımladığımı bir struct'ı da alan olarak kullanabiliriz.

    // Struct içerisinde metotlar da tanımlanabilir
    // Dikkat edileceği üzere
    // self ile Player nesnesinin o anki referansına erişiliyor diye düşünüyorum(Rust'ta benzer bir kullanım var)
    // self tabii değişken adı. Rust'taki ile karıştırmayalım. Hatta self yerine "kendim" isimlendirmesi ile deneyebilirsiniz, çalışır.
    fn print(self: Player) void {
        std.debug.print("{s} ({d}) - Power:{d}\n", .{ self.nick, self.level, self.power });
        // {d:.2} ile float değer için noktadan sonra 2 hane göstereceğini belirtiyoruz
        std.debug.print("V->({d:.2} x {d:.2})\n", .{ self.velocity.x, self.velocity.y });
    }

    // Pek tabii aşağıdaki gibi bu struct türünden nesneleri oluşturmayı kolaylaştıracak fonksiyonlar da tanımlanabilir
    fn create(nick: []const u8, power: u8, level: i32, velocity: Velocity2D) Player {
        return .{
            .nick = nick,
            .power = power,
            .level = level,
            .velocity = velocity,
        };
    }

    // changeVelocity fonksiyonu oyuncunun hızını (velocity) değiştirmek için kullanılıyor.
    // Burada dikkat edilmesi gereken husus self parametresinin pointer türünde tanımlanmış olması.
    // Yani fonksiyon çağrıldığında struct'ın bir kopyası değil, orijinal nesnenin adresi geçiliyor.
    // Böylece fonksiyon içerisinde yapılan değişiklikler orijinal nesne üzerinde etkili oluyor.
    fn changeVelocity(self: *Player, deltaX: f32, deltaY: f32) void {
        self.velocity.x += deltaX;
        self.velocity.y += deltaY;
    }
};

// Field'lara istenirse default değerler atanabilir
const Velocity2D = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
};
