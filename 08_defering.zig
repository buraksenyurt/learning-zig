const std = @import("std");

// defer, içinde bulunduğu scope sona erdiğinde çalıştırılacak ifadeleri tanımlamak için kullanılır.
// Genellikle kaynak yönetimi için kullanılır, örneğin dosya kapatma, bellek temizleme gibi işlemler için idealdir.

pub fn main() !void {
    // Aşağıdaki örnekte bir blok içinde bir sayı değişkeni tanımlanıyor ve bu blok sona erdiğinde defer ile tanımlanan ifade çalıştırılıyor.
    // Örneği çalıştırma zamanında yürüttüğümüzde döngü çalışıp içeriğindeki ifade ekrana basılır ancak
    // for döngüsü öncesinde tanımlı olan print ifadesi ancak blok sona erdiğinde çalıştırılır.
    var number: f32 = 0.0;
    {
        defer std.debug.print("Defer block executed. Final number is {d}\n", .{number});
        for (1..5) |_| {
            number += 1.5;
            std.debug.print("Current number is {d}\n", .{number});
        }
    }

    // Birde dosya okuma örneği yapalım
    // Dosya yoksa tabii bir hata fırlatılır ve program sonlanır. İleride hata yönetimine tekrardan döneceğim.
    // Şimdilik dosyadan sadece buffer özelinde okuma yapıyoruz.
    const file = try std.fs.cwd().openFile("games.dat", .{});
    defer file.close();
    var buffer: [1024]u8 = undefined;
    const read = try file.readAll(&buffer);
    std.debug.print("Read {} bytes\n", .{read});
}
