// 20_threads_2.zig örneğindeki kodun mutex kullanan versiyonu
// Bu örneğin çalışmasında her zaman aynı toplam değerine ulaşıyoruz.
// Normal şartlarda elbette. Zira burada thread zehirlenmesi gibi bir durumu hesaba katmadık.
const std = @import("std");

pub fn main() !void {
    // Öncelikle bir mutex nesnesi tanımladık.
    var guard = std.Thread.Mutex{};
    var sharedData: i32 = 0;

    // Bu nesneyi dikkat edileceği üzere spawn fonksiyonu aracılığıyla incrementSharedData fonksiyonuna
    // parametre olarak aktarıyoruz.
    const handle1 = try std.Thread.spawn(
        .{},
        incrementSharedData,
        .{ &sharedData, &guard },
    );
    const handle2 = try std.Thread.spawn(
        .{},
        incrementSharedData,
        .{ &sharedData, &guard },
    );

    handle1.join();
    handle2.join();

    std.debug.print("Final shared data value: {}\n", .{sharedData});
}

fn incrementSharedData(data: *i32, guard: *std.Thread.Mutex) void {
    // Fonksiyondaki for döngüsü içerisinde data üzerinde artım işlemi yapılmadan önce
    // mutex ile bu veri kitleniyor ve başka bir thread'in üzerinde işlem yapması engelleniyor.
    // İşlem tamamlandıktan sonra ise unlock çağrısı yapılarak veri üzerindeki kilit kaldırılıyor.
    for (0..100) |_| {
        std.time.sleep(25 * std.time.ns_per_ms);
        guard.lock();
        data.* += 1;
        guard.unlock();
    }
}
