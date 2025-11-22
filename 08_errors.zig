const std = @import("std");
const expect = std.testing.expect;

// Rust gibi Zig dilinde de exception gibi bir kavram yok.
// Hatalar birer değer(value) olarak ele alınıyor.
// Kendi error setlerimizi tanımlama şansımız var.

// Örneğin aşağıdaki gibir HTTP istek hatalarıni ifade edecek bir error set türü tanımlayabiliriz
const RequestError = error{ Unauthorized, NotFound, Timeout, InternalServerError, BadRequest };
// Enum türüne yeniden döneriz ama bu senaryoda işe yarar gibi duruyor
const HttpStatusCode = enum(u16) {
    Ok = 200,
    Created = 201,
    Accepted = 202,
    NoContent = 204,
};

pub fn main() !void {
    // ! operatörü ile Error Union Type olarak ifade edilen bir hata türü tanımlanabiliyor
    // Bu operatör ilgili değerin ya bir hata olduğunu ya da başka bir tür olduğunu belirtmekte

    // // Aşağıdaki örneği ele alalım.
    // // curl fonksiyonu bir URL alıyor ve RequestError türünden bir hata fırlatabilir
    // // Eğer hata fırlatmazsa HttpStatusCode enum türünden bir değer döndürüyor.
    // const address = "https://nowhere";
    // _ = try curl(address); // _ ile dönüş değerini hesaba katmadığımızı ifade ediyoruz.
    // std.debug.print("...", .{}); // Senaryoya göre bu satır işletilmeyecek zira curl fonksiyonu hata fırlatacak

    // Aşağıdaki kullanımda ise hata fırlatmayacak bir URL ile fonksiyonu çağırıyoruz
    // Dönüş değeri HttpStatusCode türünden bir değer olacaktır.
    const address2 = "google.com";
    const status = try curl(address2);
    std.debug.print("Status of curl command: {}\n", .{status});
    std.debug.print("...\n", .{});

    // Zig dokümantasyonunda try ve catch kullanımlarının, diğer dillerdeki try-catch bloklarına benzetilmemesi gerektiği belirtiliyor.
    // Çünkü Zig'de hata yönetimi değerler üzerinden yapılıyor.
    // Yani try ifadesi hata fırlatabilecek bir fonksiyon çağrısını sarmalıyor ve eğer bir hata oluşursa bu hatayı çağıran yere iletiyor.
    // catch ifadesi ise bir hata oluştuğunda alternatif bir değer döndürmek için kullanılıyor.
    // Aşağıdaki örnekte divideBy fonksiyonu 0'a bölünme durumu için bir hata fırlatıyor.
    // catch ifadesi ile bu hatayı yakalayıp 0.0 değerini döndürüyoruz.

    // catch kullanıldığında fonksiyonun dönüş türü artık Error Union Type olmuyor
    // Hatta dikkat edileceği üzere çağrının başında try ifadesi de yer almıyor
    const result = divideBy(10.0, 0.0) catch 0.0;
    std.debug.print("10.0/0.0 division accepted by catch: {d}\n", .{result});

    // İstersek catch bloğunda hata detayını da yakalayabiliriz.
    // Aşağıdaki kullanımda hata detayı catch ifadesi arkasından gelen |err| bloğunda yakalanıyor.
    const result2 = divideBy(20.0, 0.0) catch |err| {
        // Normal bir fonksiyon bloğundayız
        std.debug.print("Error occurred during division: {}\n", .{err});
        return; // Tabii burada fonksiyondan ve içinde olduğumuz main'den ve dolayısıyla programdan çıkıyoruz
    };
    std.debug.print("20.0/0.0 division accepted by catch with error details: {d}\n", .{result2});
}

// Bu dummy curl fonksiyonu URL bilgisine göre ya hata fırlatıyor ya da başarılı bir durum kodu döndürüyor
fn curl(url: []const u8) RequestError!HttpStatusCode {
    if (std.mem.eql(u8, url, "https://nowhere")) { // sembolik olarak böyle bir URL belirledik
        return RequestError.NotFound;
    }
    return HttpStatusCode.Ok; // Her şey yolundaymış taklidi yap
}

test "curl returns NotFound error for invalid URL" {
    const address = "https://nowhere";
    const result = curl(address);
    try expect(result == RequestError.NotFound);
}

test "curl returns Ok status for valid URL" {
    const address = "google.com";
    const result = try curl(address);
    try expect(result == HttpStatusCode.Ok);
}

// İstersek fonksiyondan dönecek Error Union Type tanımını hemen orada yapabiliriz
// Aşağıdaki örnekte 0'a bölünme durumu için özel bir hata tanımladık.
fn divideBy(numerator: f64, denominator: f64) error{DivideByZero}!f64 {
    if (denominator == 0.0) {
        return error.DivideByZero;
    }
    return numerator / denominator;
}

test "divideBy returns DivideByZero error when denominator is zero" {
    const result = divideBy(10.0, 0.0);
    try expect(result == error.DivideByZero);
}

test "errors are values test" {
    // Bir error türünün bir value olduğunu sanırım aşağıdaki gibi gösterebiliriz
    // err değişkenine RequestError.NotFound değerini atıyoruz
    const err: RequestError = RequestError.NotFound;
    try expect(err == RequestError.NotFound);
}
