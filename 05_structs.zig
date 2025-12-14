const std = @import("std"); // standart kütüphaneyi kullanacağımızı belirtiyoruz

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

    // create fonksiyonunu kullanarak bir Player değişkeninin oluşturulması
    // julyet'in değerlerinde değişiklik yapacağımız için var ile tanımladık
    // Değişikliği changeVelocity fonksiyonu yapmakta.
    // const ile tanımlarsak derleme hatası alırız.
    var julyet = Player.create("Juli-Et", 10, 190, Velocity2D{ .x = 0.5, .y = 0.8 });
    julyet.print();
    julyet.changeVelocity(1.5, 2.0); // changeVelocity fonksiyonu ile hız değerlerinin değiştirilmesi
    std.debug.print("After move:\n", .{});
    julyet.print();
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
const Velocity2D = struct { x: f32 = 0.0, y: f32 = 0.0 };
