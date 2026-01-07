const std = @import("std");

// Allocator bileşenleri, heap'de dinamik bellek tahsisi yönetimi için kullanılır.
// std.heap modülünde çeşitli allocator türleri bulunur.
// GeneralPurposeAllocator, FixedBufferAllocator, ArenaAllocator gibi.
// Bir fonksiyon kendi içinde heap üzerinde tutulacak veriler ile çalışacaksa bu fonksiyon bir allocator parametresi almalıdır.
// Bu sayede fonksiyon, çağıran tarafından sağlanan allocator'ı kullanarak bellek tahsisi yapabilir.
pub fn main() !void {
    // SAMPLE 00: GeneralPurposeAllocator kullanımı;
    // Genel amaçlı bir allocator enstrümanıdır ve her tür task için uygundur.
    // Aşağıdaki kod parçasında pi sayısını heap üzerinde tutmak için GeneralPurposeAllocator kullanılmakta.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const piValue = try allocator.create(f64); // Burada heap üzerinde bir f64 tipi için bellek tahsisi yapılıyor.
    defer allocator.destroy(piValue); // Metodun sonunda tahsis edilen bellek bölgesinin serbest bırakılması için destroy çağrı bildirimi

    piValue.* = 3.14159; // Değer atarken * operatöründen yararlanıldığına dikkat edelim. Zira heap'teki adrese erişiyoruz.
    std.debug.print("Value of Pi from heap: {d}\n", .{piValue.*});

    // SAMPLE 01: Page Allocator kullanımı;
    // PageAllocator, sayfa tabanlı bellek tahsisi yapar ve daha çok büyük veri blokları için kullanılır.
    // Çoğu işletim sisteminde sayfa boyutu 4KB'tır.
    // Hızlı bellek tahsisi için uygundur ancak küçük boyutlu veriler kullanacaksa çok fazla yer de harcayabilir.
    // Aşağıdaki akışta Heap'te 8 kilobyte'lık bir alan tahsis edilip içerisine dummy veriler ekliyoruz.
    var pageAllocator = std.heap.page_allocator;
    const largeBuffer = try pageAllocator.alloc(u8, 8192); // 8 Kilobyte boyutunda bir yer tahsis ediliyor
    defer pageAllocator.free(largeBuffer); // Tahsis edilen sayfanın serbest bırakılması için defer bildirimi

    for (largeBuffer) |*byte| {
        byte.* = 1; // Buffer içeriğini 1 ile dolduruyoruz
    }
    std.debug.print("Buffer size {d}.\nFirst 16 bytes of large buffer: ", .{largeBuffer.len});
    for (largeBuffer[0..16]) |byte| {
        std.debug.print("{x} ", .{byte});
    }

    // SAMPLE 02: FixedBufferAllocator Kullanımı;
    // Bu allocator, bir buffer ile çalışır ve bu buffer'ın boyutu önceden belirlenir.
    // Buna göre FixedBufferAllocator yer tahsisini ayrılan buffer içeriğine göre heap üzerinde veya stack üzerinde yapabilir.
    // Aşağıdaki örnekte 64 byte'lık bir buffer tanımlanıyor ve bunun 32 byte'lık kısmını ele alan bir Allocator nesnesi kullanılıyor.

    var miniBuffer: [64]u8 = undefined; // 64 byte'lık bir buffer tanımlandı. Bu buffer stack üzerinde durabilir.
    var fixedAllocator = std.heap.FixedBufferAllocator.init(&miniBuffer);
    const fixedAlloc = fixedAllocator.allocator();
    const input = try fixedAlloc.alloc(u8, 32); // 32 byte'lık bir yer tahsis ediliyor
    defer fixedAlloc.free(input); // Tahsis edilen yerin serbest bırakılması için defer bildirimi
    for (input, 0..) |*byte, idx| {
        byte.* = @intCast(idx); // Input buffer'ını index değerleri ile dolduruyoruz
    }
    std.debug.print("\nFixed Buffer Allocator content: ", .{});
    for (input) |byte| {
        std.debug.print("{x} ", .{byte});
    }

    // SAMPLE 03: Page Allocator ve Fixed Buffer Allocator'ın birlikte kullanımı;

    // SAMPLE 04: Arena Allocator Kullanımı;

    // SAMPLE 05: alloc ve free metodlarının kullanımı;

    // SAMPLE 06: Sadece yeteri kadar bellek tahisi yapmak istersek;
}
