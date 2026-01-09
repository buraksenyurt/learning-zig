const std = @import("std");

pub fn main() void {
    var salary: f64 = 5000.0;
    const bonusRate: f64 = 0.10;
    // std.debug.print("Initial Salary: {d}\n", .{salary});
    // calculateBonus(salary, bonusRate);
    // std.debug.print("After calculateBonus call, Salary: {d}\n", .{salary});

    std.debug.print("\nInitial Salary: {d}\n", .{salary});
    calculateBonus2(&salary, bonusRate);
    std.debug.print("After calculateBonus2 call, Salary: {d}\n", .{salary});

    // pointer'lar da mutabla ve constant olarak iki şekilde ele alınır.
    // salary değişkeni var ile tanımlandığı için fonksiyona gönderilen pointer'da otomatik olarak mutable' dır.
    // Birde aşağıdaki duruma bakalım;
    // Bu durumda çalışma zamanında aşağıdaki hatayı alırız,
    // // error: expected type '*f64', found '*const f64'
    // //   calculateBonus2(ptrOtherSalary, bonusRate); // error: cannot pass constant pointer to mutable parameter
    // Bu çok normal bir durum zira salary var ile mutable olarak tanımlanmışken, otherSalary const ile tanımlanmıştır.
    // Yani diğer bir deyişle otherSalary'nin değeri değiştirilemez.
    // const otherSalary: f64 = 7000.0;
    // const ptrOtherSalary = &otherSalary;
    // calculateBonus2(ptrOtherSalary, bonusRate); // error: cannot pass constant pointer to mutable parameter

    // // string literal'lar constant array' dir ve bu nedenle mutable pointer olarak da ele alınamazlar.
    // var ptrLiteral: *u8 = "Hello, Zig!";
    // // ptrLiteral.* = "Hello Rust";
    // std.debug.print("\nString Literal via Pointer: {*}\n", .{ptrLiteral});

    const numberTwo: u8 = 2;
    const ptrNumberTwo: *const u8 = &numberTwo;
    printAddress(ptrNumberTwo);

    var mutableNumber: u8 = 10;
    const ptrMutableNumber: *u8 = &mutableNumber;
    printAddress(ptrMutableNumber);

    // Single Item Pointer
    // Struct, array gibi türleri işaret eden pointer'lar single item pointer olarak da adlandırılırlar.
    // Bu pointer türünde unwrap işlemi zorunlu değildir.
    const princeOfPersia: Game = Game{
        .title = "Prince of Persia",
        .releaseYear = 1989,
        .userRating = 9.5,
    };
    const ptrGame = &princeOfPersia;
    std.debug.print("\n{s} - {}({})\n", .{
        ptrGame.*.title, // * ile erişebiliriz ama zorun değildir. Aşağıdaki alanlar da olduğu gibi de erişebiliriz.
        ptrGame.releaseYear,
        ptrGame.userRating,
    });

    // Many Item Pointer
    // Birden fazla pointer öğesini işaret eden pointer'lar olarak düşünebiliriz.
    // Örneğin bir dizinin elemanlarına ait adresleri tutan bir many item pointer aşağıdaki gibi tanımlanabilir.
    var xLocations = [_]u16{ 100, 200, 300, 400, 100, 250, 300 };
    const ptrXLocations: [*]u16 = &xLocations;
    std.debug.print("\n[0]-{} x location: {}\n", .{ &ptrXLocations[3], ptrXLocations[3] });

    // // Many item pointer'larda dizi boyutu bilinmez! Buna dikkat etmek gerekiyor.
    // // Söz gelimi yukarıdaki xLocations dizisi 7 elemanlı olmasına rağmen 10ncu elemana gitmeyi deneyebiliriz.
    // // Derleyici bir hata vermez ve çalışma zamanında belirsiz bir değer elde etme ihtimalimiz yüksektir.
    // // Ne var ki geçersiz veya erişemeyeceğimiz bir adrese gitmeye çalışırsak da program çökebilir.
    // std.debug.print("[10]-{} x location: {}\n", .{ &ptrXLocations[10], ptrXLocations[10] });

    // Many Item pointer'larda var ile mutable olarak tanımlanmış içerikleri değiştirebilir.
    ptrXLocations[1] = 250;
    std.debug.print("After modification, [1]-{}-{} x location: {}\n", .{
        &ptrXLocations[1],
        @intFromPtr(&ptrXLocations[1]),
        ptrXLocations[1],
    });
    // Yine dikkat edilmesi gereken bir husu da mutable many-item pointer'larda yine sınır dışı bir değer değiştirmeye
    // teşebbüs edebileceğimizdir.
    ptrXLocations[10] = 999; // Alakasız bir adres değerini değiştirdik veya segmentation fault'a neden olduk.
    std.debug.print("After out-of-bounds modification, [10]-{} x location: {}\n", .{ &ptrXLocations[10], ptrXLocations[10] });

    // Daha önceden gördüğümüz slice'lar many-item pointer'dır. Bunu ispat etmek için bir slice'ın türüne bakalabiliriz.
    var yLocations = [_]u16{ 50, 150, 250, 350, 450, 550, 650, 60, 0, 80, 90 };
    const sliceYLocations = yLocations[1..3];
    std.debug.print("Type of array is {}\n", .{@TypeOf(yLocations)});
    std.debug.print("Type of slice is {}\n", .{@TypeOf(sliceYLocations)}); // *[2]u16 türündedir

    // Ancak burada önemli bir nokta var.
    // Slice'ın başlangıç indeksini bir pointer olarak ele alırsak slice'ın tipi değişir.
    const numbers = [8]u8{ 1, 3, 5, 8, 13, 20, 40, 80 };
    var index: u8 = 0;
    _ = &index;
    const sliceNumbers = numbers[index..3];
    std.debug.print("Type of numbers is {}\n", .{@TypeOf(numbers)});
    std.debug.print("Type of sliceNumbers is {}\n", .{@TypeOf(sliceNumbers)}); // []const u8 türündedir
    std.debug.print("Element at [0] is {}\n", .{sliceNumbers[0]});

    // Bir fonksiyon içerisinde veya dönüşünde pointer kullanımı mümkündür ama çok tercih edilmez.
    // Zira fonksiyon scope'u sonlandığında, o scope içinde tanımlı pointer düşer.
    // Eğer fonksiyondan illa bir pointer döndürülmesi gerekiyorsa, Allocator enstrümanları kullanılmalıdır.
}

// Zig'de fonksiyon argümanları mutable (değiştirilebilir) değildir.
// Dolayısıyla taşınan argümanda bir değişiklik yapmak istersek bunun tek yolu pointer kullanmaktır.
// Konuyu daha iyi anlamak için öncelikle aşağıdaki fonksiyonu ele alalım.
// Bu fonksiyonda parametre olarak gelen salary değerini bonusRate oranında artırmak istiyoruz.
// Ancak program çalışma zamanında aşağıdaki hatayı verecektir:
// error: cannot assign to constant
//     salary = salary + (salary * bonusRate);
fn calculateBonus(salary: f64, bonusRate: f64) void {
    salary = salary + (salary * bonusRate);
}

// Aşağıdaki kullanımda ise salary parametresi bir pointer olarak geçilmektedir.
// Dolasıyıla işaret ettiği değeri değiştirebiliriz.
fn calculateBonus2(salary: *f64, bonusRate: f64) void {
    // * operatörü ile pointer'ın işaret ettiği adresteki değere erişiriz.
    salary.* = salary.* + (salary.* * bonusRate);
}

fn printAddress(pointer: *const u8) void {
    std.debug.print("{}\n", .{@intFromPtr(pointer)});
}

const Game = struct {
    title: []const u8,
    releaseYear: u16,
    userRating: f32,
};
