const std = @import("std");

pub fn main() void {
    // null veri mi? Evet burada var sanıyorum ki.
    // Ancak resmi kaynağa göre null kullanımının diğer normal tür kullanımlarına göre
    // ekstra bir maliyeti yok zira null, 0 değerli bir pointer olarak tutulmakta

    // Buna optional deniyor. ?T olarak ifade edilen veri türleri null değer taşıyabiliyor.
    var quanta: ?i32 = null;
    std.debug.print("{?}\n", .{quanta});
    quanta = 23;
    std.debug.print("{?}\n", .{quanta});

    // // Aşağıdaki gibi bir kullanım söz konusu değil
    // // Buna derleyici şu hatayı veriyor:  error: expected type 'i32', found '@TypeOf(null)'
    // const value: i32 = null;
    // std.debug.print("{}", .{value});

    // Aşağıdaki kullanımda geriye optional döndüren bir fonksiyon kullanımı yer alıyor
    const numbers = [_]i32{ 1, 2, 56, 2, 6, 8, 0, 2, 3, 4, 1, 9, 19 };
    const index = getFirstIndex(&numbers, 0);
    std.debug.print("First index of 0 form left side is: {?}\n", .{index});

    // optional ailesinde orelse ve orelse unreachable gibi kavramlar da var.

    // Aşağıdaki fonksiyon çağrısı f32 türünden bir optional dönüyor.
    // Diyelim ki bazı şartlarda null değer alıyor
    const xValue: ?f32 = getRandomX();
    // Asıl işin yürütüldüğü kısımda null olması halinde default bir değer ataması için
    // orelse operatörünü aşağıdaki gibi kullanabiliriz
    const realXValue: f32 = xValue orelse 1.0;
    std.debug.print("xValue is {?} and realXValue is {}\n", .{ xValue, realXValue });

    // Eğer optional bir değer kullanıldığında bunun null olma ihtimali imkansızsa
    // unreachable kullanarak çalışma zamanında panic oluşmasına neden olunabilir
    // Ben bunu null ise devam etmemeli o yüzden panik oluşsun veya ortama exception fırlatılsın diye yorumladım
    const yValue: ?f32 = null;
    const realYValue = yValue orelse unreachable;
    std.debug.print("{}", .{realYValue});
}

// Fonksiyon geriye bir optional döndürmekte.
// Ya usize olarak taşınabilir bir tam sayı dönecek ya da null
// Görevi, number'ın ilk görüldüğü index bilgisini döndürmek
fn getFirstIndex(numbers: []const i32, number: i32) ?usize {
    for (numbers, 0..numbers.len) |n, i| {
        if (n == number) return i;
    }
    return null;
}

fn getRandomX() ?f32 {
    // Bir takım şartlar oluştuğunda null dönüyor
    return null;
}
