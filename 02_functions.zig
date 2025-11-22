const std = @import("std");
// common.zig dosyası main ile aynı klasörde yer alıyor ve aşağıdaki gibi import edilebiliyor
const common = @import("common.zig");

pub fn main() void {
    // Aşağıdaki örnek kodda title içerisindeki karakterleri tek tek terminale yazdırıyoruz.
    const title = "The Legend of Zig";
    print_smart(title);

    // Burada da title içeriğinin ilk 10 karakterini alıp ekrana basıyoruz
    std.debug.print("{s}\n", .{title[0..10]});

    std.debug.print("Temperature Conversions:\n", .{});
    const celsius: f32 = 24.0;
    const fahrenheit: f32 = celciusToFahrenheit(celsius);
    std.debug.print("{d:.2} C is {d:.2} F\n", .{ celsius, fahrenheit });

    const celsius2: f32 = fahrenheitToCelcius(fahrenheit);
    std.debug.print("{d:.2} F is {d:.2} C\n", .{ fahrenheit, celsius2 });

    // Import ettiğimiz common modülünden bir fonksiyon çağrırıyoruz
    // Fonksiyon geriye bir u8 dizi dönüyor(metinsel bir ifade)
    const message= common.ping();
    std.debug.print("{s}\n", .{message});
}

// Fonksiyona parametre olarak u8 türünden bir dizi geçiliyor
// Tabii zig dilinde string diye bir terim olmadığından böyle bir tanım söz konusu
// Eğer const keyword kullanılmazsa build hatası alınıyor

// // 02_functions.zig:6:17: error: expected type '[]u8', found '*const [17:0]u8'
// //     print_smart(title);
// //                 ^~~~~
// // 02_functions.zig:6:17: note: cast discards const qualifier
// // 02_functions.zig:20:25: note: parameter type declared here
// // fn print_smart(message: []u8) void {

fn print_smart(message: []const u8) void {
    // title içeriği u8 türünden bir dilim (slice) olarak ifade ediliyor.
    for (message) |c| {
        std.debug.print("{c} ", .{c});
    }
    std.debug.print("\n", .{});
}

// Çok basit bir aritmetik fonksiyon tanımı
// i32 türünden iki parametre alıyor ve i32 türünden değer döndürüyor
fn sum(x: i32, y: i32) i32 {
    return x + y;
}

fn celciusToFahrenheit(celsius: f32) f32 {
    return (celsius * 9.0 / 5.0) + 32.0;
}

fn fahrenheitToCelcius(fahrenheit: f32) f32 {
    return (fahrenheit - 32.0) * 5.0 / 9.0;
}
