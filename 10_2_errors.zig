const std = @import("std");
const rand = @import("rand.zig");

// Kendi error nesnelerimizi tanımlayabiliriz.
const ServiceError = error{ NotFound, Unauthorized, ServerError, BadRequest, Timeout, Unknown };
const FileSystemError = error{ FileNotFound, PermissionDenied, DiskFull, ReadError, WriteError, Unknown };
pub fn main() !void { // Kodun akan kısmında try ile hata fırlatılabilir ifadeler var. Bu yüzden !void şeklinde tanımlandı.
    // Error nesnelerine sayısal birer değer atanır. Bu değerleri @intFromError ile alabiliriz.
    std.debug.print("NotFound error {} ({}).\n", .{ ServiceError.NotFound, @intFromError(ServiceError.NotFound) });
    std.debug.print("Unauthorized error {} ({}).\n", .{ ServiceError.Unauthorized, @intFromError(ServiceError.Unauthorized) });

    // Aynı isimli error nesneleri farklı türlerde olsalar birer Identical olarak kabul edilirler.
    std.debug.print(
        "ServiceError.Unknown is identical to FileSystemError.Unknown: {}\n",
        .{ServiceError.Unknown == FileSystemError.Unknown},
    );

    // Yukarıda tanımlamış olduğumuz hatalara error keyword üzerinden de erişebiliriz.
    // Bir nevi kısayol gibi düşünülebilir.
    const serverError = error.ServerError;
    std.debug.print("Server error code is: {} ({})\n", .{ serverError, @intFromError(serverError) });

    // Error Union türünden değişkenler oluşturabilir.
    var anError: FileSystemError!u8 = error.DiskFull;
    std.debug.print("Initial error is: {!}\n", .{anError});
    anError = error.PermissionDenied; // ve değiştirebiliriz. Pek tabii aynı türde olmak kaydıyla.
    // print fonksiyonunda bu hata türü bilgisini göstermek için ! operatörünü kullanıyoruz
    std.debug.print("Error is now: {!}\n", .{anError});

    // Error union türleri hata türü veya normal türde bir değer tutar.
    anError = 42; // Şimdi union tanımlında belirttiğimiz gibi u8 türünden bir değer atadık.
    std.debug.print("Now the value is: {!}\n", .{anError});

    // Error union türlerinde tabii hata mı taşıyor yoksa değer mi tutuyor anlamak için if yapısı aşağıdaki gibi kullanılabiliyor.
    if (anError) |errValue| { // Eğer hata taşıyorsa errValue ile hata değerine erişiyoruz
        std.debug.print("Error contains a value {}\n", .{errValue});
    } else |value| { // Aksi durumda normal değer taşıyordur.
        std.debug.print("Error is an error: {}\n", .{value});
    }

    anError = error.ReadError; // Tekrar bir hata atayalım
    if (anError) |errValue| {
        std.debug.print("Error contains a value {}\n", .{errValue});
    } else |value| {
        std.debug.print("Error is an error: {}\n", .{value});
    }

    // Error union türlerinde catch ifadesi de kullanılabilir.
    // Eğer değişken bir hata taşıyorsa catch bloğu işlettirilebilir.
    var finalValue = anError catch 0; // Hata varsa 0 değeri atanacak
    std.debug.print("Final value after catch: {}\n", .{finalValue});

    // Ama hata yoksa da değer direkt atanır.
    anError = 100;
    std.debug.print("Final value after catch when no error: {}\n", .{anError catch 0});

    // Pek tabii error union türünde try ifadesi ile hata fırlatılması da sağlanabilir.
    // Bu kullanımı rust tarafındaki unwrap'a benzetebiliriz.
    finalValue = try anError; // Eğer anError bir hata taşıyorsa bu ifade hata fırlatır ve fonksiyondan çıkılır.
    std.debug.print("Final value after try when no error: {}\n", .{finalValue});

    // anError = error.WriteError;
    // // Aşağıdaki ifade anError bir hata taşıdığı için hata fırlatır ve fonksiyondan çıkılır.
    // finalValue = try anError;
    // std.debug.print("This line will not be executed due to error in try: {}\n", .{finalValue});

    // Rust'taki anyError crate'ini hatırlar mıyız? Zig'de anyerror diye tür var ve tüm türleri kapsayabiliyor.
    var genericError: anyerror!u8 = ServiceError.BadRequest;
    std.debug.print("Generic error initial value: {!}\n", .{genericError});
    genericError = error.FileNotFound;
    std.debug.print("Generic error after change: {!}\n", .{genericError});
    genericError = FileSystemError.PermissionDenied;
    std.debug.print("Generic error after another change: {!}\n", .{genericError});
    genericError = 255;
    std.debug.print("Generic error after assigning normal value: {!}\n", .{genericError});
}
