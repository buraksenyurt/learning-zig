const std = @import("std");
// utility.zig dosyası main ile aynı klasörde yer alıyor ve aşağıdaki gibi import edilebiliyor
const utility = @import("utility.zig");

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

    // Import ettiğimiz utility modülünden bir fonksiyon çağrırıyoruz
    // Fonksiyon geriye bir u8 dizi dönüyor(metinsel bir ifade)
    const message = utility.ping();
    std.debug.print("{s}\n", .{message});

    const s = totalOf(&.{ 1, 3, 5, 7, 9 });
    std.debug.print("Total is {d}\n", .{s});

    const s2 = totalOf(&.{ 10, 20, 30 });
    std.debug.print("Total2 is {d}\n", .{s2});

    prints(&.{ "Hello, ", "this ", "is ", "a ", "variadic ", "like ", "function!\n" });

    // anytype parametreli generic fonksiyon çağrıları
    displayValue(123);
    displayValue("A string value");
    displayValue(45.67);
    displayValue(true);
    const location = struct { x: i32, y: i32 }{ .x = 10, .y = 20 };
    displayValue(location);

    // anyerror parametreli fonksiyon çağrısı için örnekler
    logError(error.FileNotFound);
    logError(error.InvalidInput);
    logError(error.OutOfMemory);
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

// Zig dilinde C# daki Console.WriteLine veya Python'daki print gibi
// değişken sayıda parametre alan fonksiyonlar varsayılan olarak yok.
// Ancak diziler ile benzer bir işlevsellik sağlanabilir
fn totalOf(numbers: []const i32) i32 {
    var total: i32 = 0;
    for (numbers) |n| {
        total += n;
    }
    return total;
}

fn prints(parts: []const []const u8) void {
    for (parts) |part| {
        std.debug.print("{s}", .{part});
    }
}

// Sonsuz döngü içerecek fonksiyonlardan dönüş türü olarak 'noreturn' kullanılabilir
fn infiniteLoop() noreturn {
    while (true) {
        std.debug.print("This loop runs forever!\n", .{});
    }
}

// anytype türünden parametreler ile generic fonksiyonlar yazabiliriz
// Örneğin herhangi bir türden parametre alıp ekrana basan bir fonksiyon
// ya da log bırakan bir fonksiyon buna örnek olarak verilebilir.
fn displayValue(value: anytype) void {
    // anytype türündeki parametreyi ekrana basarken {any} şeklinde placeholder kullanılır
    std.debug.print("Value: {any}\n", .{value});
}

// anytype benzeri bir de anyerror türü vardır
// Bunu da herhangi bir hata türünü temsil etmek için kullanabiliriz
fn logError(err: anyerror) void {
    std.debug.print("ERROR!: {any}\n", .{err});
}
