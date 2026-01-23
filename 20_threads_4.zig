// Veriyi ortaklaşa kullanan çoklu thread yapılarında senkronizasyon için mutex kullanımı yaygındır
// Ancak veride değişiklik yapıldığı kadar sadece okuma amacıyla erişimler de söz konusu olabilir.
// Bu gibi senaryolar için Zig'de RwLock (Read-Write Lock) yapısı bulunmaktadır.
const std = @import("std");

pub fn main() !void {
    // RwLock nesnesini tanımladık
    var rwlock = std.Thread.RwLock{};
    var sharedData: i32 = 0;

    // Sembolik olarak yazma işlemini yapan bir thread var
    const writerHandle = try std.Thread.spawn(
        .{},
        writeSharedData,
        .{ &sharedData, &rwlock },
    );

    // Burası da okuma işlemini icra ediyor.
    // Sadece okuma yapan 8 adet thread tanımladık.
    var readerHandles: [8]std.Thread = undefined;
    for (0..readerHandles.len) |i| {
        readerHandles[i] = try std.Thread.spawn(
            .{},
            readSharedData,
            .{ &sharedData, &rwlock, i },
        );
    }

    // main thread sonlanmadan önce tüm thread'lerin tamamlanmasını bekliyoruz.
    writerHandle.join();
    for (readerHandles) |handle| {
        handle.join();
    }

    std.debug.print("Final shared data value: {}\n", .{sharedData});
}

fn writeSharedData(data: *i32, rwlock: *std.Thread.RwLock) void {
    for (0..100) |_| {
        std.time.sleep(25 * std.time.ns_per_ms);
        rwlock.lock(); // Yazma işlemi öncesi klasik bir kilitleme yapılır
        data.* += 1; // veri değiştirilir
        rwlock.unlock(); // ve kilit serbest bırakılır
    }
}

fn readSharedData(data: *const i32, rwlock: *std.Thread.RwLock, id: usize) void {
    for (0..100) |_| {
        std.time.sleep(25 * std.time.ns_per_ms);
        rwlock.lockShared(); // Okuma işlemi öncesi paylaşımlı kilit alınır
        defer rwlock.unlockShared(); // defer ile fonksiyon sonlanmadan önce kilit serbest bırakılır

        std.debug.print("Reader {}: {}\n", .{ id, data.* });
    }
}
