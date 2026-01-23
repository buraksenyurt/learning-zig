const std = @import("std");

fn doSomething(id: usize) void {
    std.time.sleep(1 * std.time.ns_per_s);
    std.debug.print("Working progress...{d}\n", .{id});
}
pub fn main() !void {
    // try singleThreaded();
    // try multiThreaded();
    // try multiThreadedWithDetach();
    try threadPoolExample();
}

// #3: Thread Pool kullanımı
fn threadPoolExample() !void {
    const coreCount = try std.Thread.getCpuCount();
    // Thread'leri gruplayarak yönetmenin yollarından birisi Thread Pool kullanımı.
    // Bunun için memory allocator'lardan yararlanıyoruz.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // genel amaçlı bir allocator tanımı
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var pool: std.Thread.Pool = undefined;
    try pool.init(.{ .allocator = allocator, .n_jobs = 4 }); // 4 thread'lik bir pool oluşturduk
    // n_jobs değerini vermek zorunda değiliz.
    defer pool.deinit();

    // Bendeki 12 çekirdekli senaryoya göre 12 iş 4 thread'den oluşan 3 gruba dağıtılıyor.
    // Eğer n_jobs sayısını çekirdek sayısına eşitlersek memory'de açılan havuz
    // 12 işi 12 çekirdekle tek seferde yürüterek daha hızlı sonuçlar almamızı sağlayabilir mi?
    for (0..coreCount) |i| {
        try pool.spawn(doSomething, .{i});
    }
}

// #2: Multi Thread senaryoda detach kullanımı
fn multiThreadedWithDetach() !void {
    for (0..12) |i| {
        var handle = try std.Thread.spawn(.{}, doSomething, .{i});
        handle.detach(); // detach ile thread'in main fonksiyonunun sonlanmasını beklemeden arka planda çalışmaya devam etmesini sağlanır.
    }

    // Burada dikkat edilmesi gereken nokta detach edilen threar'lerin tamamının biteceğinin join'de olduğu gibi garanti edilememesidir.
    // Genellikle sürekli çalışan arka plan işlemlerinde göz önünde bulundurulabilir.
}

// #1: Multi Thread Çalışma örneği
fn multiThreaded() !void {
    // Şimdi aynı işlemi çoklu thread (akış) üzerinde gerçekleştirelim.

    var handles: [12]std.Thread = undefined; // Burada mecburen eleman sayısını vermemiz gerekiyor.
    // Ancak çekirdek sayısının runtime' da öğrenilmesi gereken durumlarda allocator'lardan yararlanarak gerekli alanı tahsis edebiliriz.

    for (0..handles.len) |i| {
        // Bir thread oluşturmak için rust'a benzer şekilde burada da spawn isimli bir fonksiyon var.
        // 2nci parametre çağırılacak fonksiyon,
        // 3ncü parametre fonksiyona gönderilecek argümanları işaret eden tuple
        handles[i] = try std.Thread.spawn(.{}, doSomething, .{i});
    }

    // Tüm thread'lerin tamamlanmasını bekleyelim
    for (handles) |handle| {
        handle.join(); // ki bunu da klasik join fonksiyonu ile yapıyoruz.
    }
}

// #0: Single Thread Çalışma
fn singleThreaded() !void {
    // İlk olarak tek bir thread (akış) üzerinde çalışan bir kod bloğu oluşturalım.
    // Aşağıdaki kod bloğu 1 saniye aralıklarla çalışan ve çekirdek sayısı kadar yürütülen bir akışı temsil ediyor.
    const numCores = try std.Thread.getCpuCount();
    std.debug.print("Number of CPU cores: {d}\n", .{numCores});

    for (0..numCores) |i| {
        doSomething(i);
    }
}
