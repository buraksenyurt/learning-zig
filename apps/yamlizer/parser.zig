const std = @import("std");
const models = @import("models.zig");
const utility = @import("utility.zig");

pub fn deserialize(filePath: []const u8) !models.service {
    const content = try utility.readFileContent(std.heap.page_allocator, filePath);
    // Burada YAML içeriğini parse edip models.service yapısına dönüştürme işlemi
    // Extra bir kütüphane kullanmadan yapılacak. Adım adım ilerleyelim.
    var service = models.service.init(std.heap.page_allocator);
    // Dosyadan okunan içeriği satır satır okuyarak ilerleyelim.
    // Bunun için bir SplitIterator kullanıyoruz. Satır sonu karakterine göre bölümleme yapılıyor.
    var lines = std.mem.splitSequence(u8, content, "\n");
    // Satırları next() ile dolaşalım.
    while (lines.next()) |line| {
        // Eğer varsa satır başındaki boşlukları temizlemek iyi bir fikir olabilir.
        const trimmedLine = std.mem.trimLeft(u8, line, " ");
        // Şimdi trimmedLine'ı inceleyelim ve hangi alan olduğunu belirleyelim
        if (std.mem.startsWith(u8, trimmedLine, "service_name:")) {
            const value = std.mem.trimLeft(
                u8,
                trimmedLine["service_name:".len..],
                " ",
            );
            service.serviceName = value;
        } else if (std.mem.startsWith(u8, trimmedLine, "domain:")) {
            const value = std.mem.trimLeft(
                u8,
                trimmedLine["domain:".len..],
                " ",
            );
            service.domain = value;
        }
    }
    return service;
}
