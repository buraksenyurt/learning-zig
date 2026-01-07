const std = @import("std");

pub fn main() !void {
    // Case 001: Global değişkenlerin derleme zamanında initialize edilmesi
    // Bu örnekte Windows işletim sistemine özel bir durum ele alınıyor.
    // Zig'de tüm global değişkenler derleme zamanında initialize edilmelidir.
    // Ancak örneğin Windows'ta standart output'a erişim runtime zamanında mümkündür.
    // Bu nedenle aşağıdaki örneği windows platformunda çalıştırmak istediğimizde
    // derleme zamanı hatası alırız; error: unable to evaluate comptime expression
    // const stdout = std.io.getStdOut().writer();
    // Windows OS tarafında bunu aşmak için stdout değişkenini main fonksiyonu
    // içerisine alınır. Bu durumda bir sorun olmaz zira Zig dilinde fonksiyon içerisindeki
    // ifadeler(expressions) runtime'da  değerlendirilir. Taa ki comptime olarak işaretlenmedikçe.
    const stdout = std.io.getStdOut().writer();
    _ = try stdout.print(
        "Curiosities in Zig Language: \n\tAll global variables must be initialized at compile time.\n",
        .{},
    );

    // Case 002: "Invalid Pointer to stack variable" durumu
    const invoiceAmountPtr = calculateInvoiceAmount(100.0, 0.18);
    // Aşağıdaki satır çalıştırıldığında hata alırız.
    // Çünkü, calculateInvoiceAmount fonksiyonu stack üzerinde tanımlanan total değişkeninin pointer'ını döndürmektedir.
    // Scope sonlandığında fonksiyon stack'ten düşer ve sahip olduğu değişkenler serbest bırakılır.
    // Fonksiyondan dönen pointer da undefined olarak kalır. Bu yüzden bu pointer'ı kullanmak runtime hatasına sebep olur.
    _ = try stdout.print("Invoice Amount: {d}\n", .{*invoiceAmountPtr});
}

// Case 002: "Invalid Pointer to stack variable" durumu
fn calculateInvoiceAmount(price: f64, taxRate: f64) *const f64 {
    const tax = price * taxRate;
    const total = price + tax;
    return &total;
}
