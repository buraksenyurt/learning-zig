// Bu örnekte farklı thread'lerin aynı veri üzerinde yazma işlemi yapmasını ele alıyoruz.
// Bu ilk versiyondaki bir amacımız da mutex ihtacını ortaya koymak.
const std = @import("std");

pub fn main() !void {
    // sharedData i32 türünden bir değişken.
    // Bu değişkenin değerini artırabileceğimiz incrementSharedData isimli bir fonksiyon yer alıyor.
    // İlgili fonskiyon ileri yönlü bir iterasyona sahip ve belli bir duraksama süresini baz alarak değeri artırıyor.
    // Parametrenin i32 türünden bir pointer nesnesi olduğuna dikkat edelim.
    var sharedData: i32 = 0;

    // handle1 ve handle2 isimli iki thread oluşturuluyor.
    // Her birisi incrementSharedData fonksiyonunu çağırıyor ve sharedData değişkeninin adresini parametre olarak iletiyor.
    // Dolayısıyla main thread haricinde çalışan iki thread' imiz bu veri üzerinden artım işlemi yapıyor.
    const handle1 = try std.Thread.spawn(
        .{},
        incrementSharedData,
        .{&sharedData},
    );
    const handle2 = try std.Thread.spawn(
        .{},
        incrementSharedData,
        .{&sharedData},
    );

    // main thread sonlanmadan önce diğer iki thread'in tamamlanmasını bekliyoruz.
    handle1.join();
    handle2.join();

    // Burada aynı veri üzerinden çalışan thread'ler her çalışma da farklı toplamlar üretebilir.
    // Kendi sistemimde bunu denerken 200, 197, 198, 199 gibi farklı sonuçlar elde ettim.
    // Eğer bu tip bir senaryoda thread'lerin ortak kullanacağı mutable veri üzerinden bir senkronizasyona ihtiyaç varsa
    // bu durumda mutex yapısından yararlanılabilir.
    // Aynı örneğin mutex kullanan versiyonu 20_threads_3.zig dosyasında yer alıyor.
    std.debug.print("Final shared data value: {}\n", .{sharedData});
}

fn incrementSharedData(data: *i32) void {
    for (0..100) |_| {
        std.time.sleep(25 * std.time.ns_per_ms);
        data.* += 1;
    }
}
