const std = @import("std");

pub fn main() void {
    // Vector türünü matematikteki vektör ya da Rust dilindeki vec kavramı ile karıştırmamak lazım. Aynı şey değil.
    // Zig dilindeki vector türü sabit uzunlukta ve aynı türden elemanlardan oluşan bir veri yapısıdır ama
    // SIMD (Single Instruction, Multiple Data) işlemlerini destekler.
    // Tek bir işlem ile birden fazla veri üzerinde işlem yapabilmeyi ifade ediyor desek yeridir.
    // Zig, vector türleri SIMD işlemlerini destekliyor. SIMD'nin avantajı paralel işlem yapabilmesi.
    // SIMD yaklaşımı Zig diline özgü değil. C ve Rust gibi dillerde de benzer destekler bulunuyor.
    // Ağırlıklı olarak grafik işleme, oyun programlama ve bilimsel hesaplamalar gibi performansın kritik olduğu alanlarda kullanılıyor.

    const numbers: @Vector(4, i32) = .{ 1, 3, 5, 7 };
    std.debug.print("Numbers: {}\n", .{numbers});
    const otherNumbers: @Vector(4, i32) = .{ 10, 20, 30, 40 };
    std.debug.print("Other Numbers: {}\n", .{otherNumbers});
    // Vector türlerinde toplama işlemi aşağıdaki gibi yapılabilir
    const sum: @Vector(4, i32) = numbers + otherNumbers;
    std.debug.print("Sum: {}\n", .{sum});

    // Bir array içeriğini doğrudan vector türüne atamak da mümkün
    const arr: [4]i32 = .{ 2, 4, 6, 8 };
    const vec1: @Vector(4, i32) = arr;
    std.debug.print("Vector from Array: {}\n", .{vec1});

    // @splat fonksiyonu ile tek bir değerden oluşan bir vector oluşturulabilir
    // Örneğin tüm elemanları 9 olan bir vector aşağıdaki gibi oluşturulabilir
    const splatVec: @Vector(8, u8) = @splat(9);
    std.debug.print("Splat Vector: {}\n", .{splatVec});

    // Vectorler üzerinde birçok matematiksel işlem gerçekleştirilebilir
    // Bu işlemler grafik işleme, oyun programlama, simülasyon ve bilimsel hesaplamalarda çokça kullanılır.
    // @log fonksiyonu ile bir vector içeriğinin logaritması alınabilir
    const floatVec: @Vector(4, f32) = .{ 1.0, 10.0, 100.0, 1000.0 };
    const logVec: @Vector(4, f32) = @log(floatVec);
    std.debug.print("Log Vector: {}\n", .{logVec});

    // @shuffle fonksiyonu kullanımı.
    // Oldukça ilginç bir fonksiyon. İlk parametrede veri türünü belirtiyoruz.
    // İkinci ve üçüncü parametrelerde iki farklı vector veriyoruz.
    // Dördüncü parametrede ise bir maske veriyoruz.
    // Maske elemanları pozitif ve negatif değerler olabilir.
    // Pozitif değerler ikinci vector'den, negatif değerler ise birinci vector'den eleman alır.
    // Aşağıdaki örnekte kullanılan maskeye göre 0ncı indis vec3'ten 1 değerinin alınmasını,
    // -1nci indis vec4'ten 6 değerinin alınmasını,
    // 3ncü indis vec3'ten 4 değerinin alınmasını,
    // -2nci indis vec4'ten 7 değerinin alınmasını ifade eder.
    // Bir başka deyişle pozitif maske indisleri ilk vektörden gelirken,
    // negatif maske indisleri ikinci vektörden gelir.
    const vec3: @Vector(4, i32) = .{ 1, 2, 3, 4 };
    const vec4: @Vector(4, i32) = .{ 5, 6, 7, 8 };
    const mask = [4]i8{ 0, -1, 3, -2 }; // Elemanların yerlerini değiştirecek maske
    const shuffledVec: @Vector(4, i32) = @shuffle(i32, vec3, vec4, mask);
    std.debug.print("Shuffled Vector: {}\n", .{shuffledVec});

    // Bitwise operatörde vector türlerinde kullanılabilir
    // Örneğin RGBA renk kanallarını temsil eden iki vector üzerinde AND işlemi yapalım
    const red: @Vector(4, u8) = .{ 255, 0, 0, 255 }; // Kırmızı renk
    const green: @Vector(4, u8) = .{ 0, 255, 0, 255 }; // Yeşil renk
    const andResult: @Vector(4, u8) = red & green;
    std.debug.print("Bitwise AND Result: {}\n", .{andResult});

    // Bitleri sağa veya sola kaydırma da sık ihtihaç duyulan işlemlerden biridir
    const originalVec: @Vector(4, u8) = .{ 1, 2, 4, 8 };
    const rate: @Vector(4, u8) = @splat(1);
    const shiftedLeft: @Vector(4, u8) = originalVec << rate;
    std.debug.print("Shifted Left: {}\n", .{shiftedLeft});
    const shiftedRight: @Vector(4, u8) = originalVec >> rate;
    std.debug.print("Shifted Right: {}\n", .{shiftedRight});

    // Çok doğal olarak toplama, çarpma gibi işlemler de desteklenir
    const a: @Vector(4, i32) = .{ 1, 2, 3, 4 };
    const b: @Vector(4, i32) = .{ 5, 6, 7, 8 };
    const sumOfVectors: @Vector(4, i32) = a + b;
    std.debug.print("Sum of vectors: {}\n", .{sumOfVectors});

    // Vector türünde kullanılabilecek faydalı enstrümanlardan birisi de reduce fonksiyonudur.
    const ReduceOp = @import("std").builtin.ReduceOp;
    // Örneğin bir vektör içindeki maksimum veya minimum değeri bulmak için reduce kullanılabilir
    const vecForReduce: @Vector(4, i32) = .{ 10, 3, 25, 7 };
    const maxValue: i32 = @reduce(ReduceOp.Max, vecForReduce);
    std.debug.print("Maximum value in vector: {}\n", .{maxValue});
    const minValue: i32 = @reduce(ReduceOp.Min, vecForReduce);
    std.debug.print("Minimum value in vector: {}\n", .{minValue});
    // ReduceOp bir enum türüdür ve farklı işlemler için kullanılabilir.

    // Söz gelimi yukarıdaki vektördeki sayısal değerlerini toplamını Add işlemi ile bulabiliriz
    const totalSum: i32 = @reduce(ReduceOp.Add, vecForReduce);
    std.debug.print("Total sum of vector elements: {}\n", .{totalSum});

    // ReduceOp.Mul örneği. Vektörün tüm elemanlarını birbiri ile çarpar
    // Olayı kolayca anlamak için basit bir vektör tanımlayıp kullanalım.
    const candidate = @Vector(4, i32){ 1, 1, 1, 2 };
    const multiplyOfProducts: i32 = @reduce(ReduceOp.Mul, candidate);
    std.debug.print("Multiply of vector elements: {}\n", .{multiplyOfProducts});

    // Vektörler ile ilgili enteresan bir nokta da uzunluk bilgisi için doğrudan bir fonksiyonun olmaması.
    // Uzunluk bilgisini amak için tür bilgisine inmek gerekebilir.
    const vecType = @TypeOf(vecForReduce);
    const vectTypeInfo = @typeInfo(vecType);
    std.debug.print("Vector type info: {}\n", .{vectTypeInfo});
    std.debug.print("Vector length is: {}\n", .{vectTypeInfo.vector.len});

    // // Peki bir vektör içindeki tüm elemanları dolaşmak istersek.
    // // Standart bir for döngüsü deneyelim.
    // // Aşağıdaki kullanım derleme zamaında şu hatayı verir: error: type '@Vector(4, i32)' does not support field access
    // for (vecForReduce) |value| {
    //     std.debug.print("{}\n", .{value});
    // }

    // O halde index operatörü ile dönelim
    for (0..vectTypeInfo.vector.len) |i| {
        std.debug.print("{d}:{d}\n", .{ i, vecForReduce[i] });
    }
}
