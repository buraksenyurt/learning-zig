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
    // Yukarıdaki örneğin tersine aşağıdaki kullanımda önce heap bellek bölgesinde 16 mb'lık bir yer ayrılıyor.
    // Sonrasında bir FixedBufferAllocator bu alan ile çalışacak şekilde oluşturuluyor.
    const heap = std.heap.page_allocator;
    const tempBuffer = try heap.alloc(u8, 16 * 1024 * 1024); // Heap üzerinde 16 MB'lık alan tahsisi
    defer heap.free(tempBuffer); // Tahsis edilen alanın serbest kalması için defer bildirimi yapılıyor
    var combinedFixedAllocator = std.heap.FixedBufferAllocator.init(tempBuffer);
    const combinedAlloc = combinedFixedAllocator.allocator();
    const largeData = try combinedAlloc.alloc(u8, 8 * 1024 * 1024); // FixedBufferAllocator kullanılarak 8 MB'lık bir yer tahsis ediliyor
    defer combinedAlloc.free(largeData); // Tahsis edilen yerin serbest bırakılması için defer bildirimi yapılıyor
    std.debug.print("\nCombined Allocator allocated {d} bytes.\n", .{largeData.len});

    // SAMPLE 04: Arena Allocator Kullanımı;
    // Go dilindeki Arena yapısına benzer şekilde çalışan bir allocator türüdür.
    // Bu allocator ile n defa bellek tahsisi yapıp, tek seferde hepsini serbest bırakmak mümkündür.
    // Oluştururken başka bir Allocator gerektirir ki aşağıdaki örnekte kodun üst kısmında tanımladığımız
    // GeneralPurposeAllocator kullanılmakta.
    var arenaAllocator = std.heap.ArenaAllocator.init(allocator);
    defer arenaAllocator.deinit(); // Tüm tahsis edilen bellek bloklarını serbest bırakmak için deinit çağrısı
    const arenaAlloc = arenaAllocator.allocator();
    const firstBlock = try arenaAlloc.alloc(u8, 128); // Arena üzerinden 128 byte'lık bir yer tahsisi
    const secondBlock = try arenaAlloc.alloc(u8, 256); // Arena üzerinden 256 byte'lık bir yer tahsisi
    const thirdBlock = try arenaAlloc.alloc(u8, 512); // Arena üzerinden 512 byte'lık bir yer tahsisi
    _ = thirdBlock; // Üçüncü blok kullanılmıyor, sadece tahsis ediliyor
    std.debug.print("Arena Allocator allocated blocks of sizes: {d} and {d} bytes.\n", .{ firstBlock.len, secondBlock.len });

    // SAMPLE 05: alloc ve free metodlarının kullanımı;
    // Aşağıdaki örnek kod parçasında kullanıcının girdiği bir ifade için alloc ve free metodları kullanılıyor.
    var inputGpa = std.heap.GeneralPurposeAllocator(.{}){};
    const inputAllocator = inputGpa.allocator();
    const userInput = try inputAllocator.alloc(u8, 128); // 128 byte uzunluğunda bir yer tahsisi yaptık
    defer inputAllocator.free(userInput); // Tahsis edilen yerin serbest bırakılması için defer bildirimi
    for (0..userInput.len) |i| {
        userInput[i] = 0; // Bellek bölgesini sıfırlıyoruz
    }
    std.debug.print("Please enter your name: ", .{});
    const reader = std.io.getStdIn().reader();
    _ = try reader.readUntilDelimiterOrEof(userInput, '\n');
    std.debug.print("Hello, {s}How are you :)\n", .{userInput});

    // SAMPLE 06: Sadece yeteri kadar bellek tahisi yapmak istersek;
    // Örneğin kategori bilgisini taşıyan bir struct için heap üzerinde gerektiği kadar yer tahsisi yapmak istediğimiz düşünelim.
    // Bu durumda create ve destroy metodlarını alloc ve free yerine tercih etmek daha doğru olacaktır.
    var categoryAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    const catAlloc = categoryAllocator.allocator();
    const category = try catAlloc.create(Category); // Sadece Category struct'ı için yeterli bellek tahsisi yapılıyor
    defer catAlloc.destroy(category); // Tahsis edilen bellek bölgesinin serbest bırakılması için destroy çağrısı
    category.* = Category.init(1, "Computer Parts");
    std.debug.print("Category ID: {d}, Name: {s}\n", .{ category.id, category.name });
    std.debug.print("The size of the category struct is {d} bytes.\n", .{@sizeOf(Category)});
}

const Category = struct {
    id: usize,
    name: []const u8,

    pub fn init(id: usize, name: []const u8) @This() {
        return .{
            .id = id,
            .name = name,
        };
    }
};
