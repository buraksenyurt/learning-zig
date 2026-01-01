const std = @import("std");
const utility = @import("utility.zig");
const rand = @import("rand.zig");

pub fn main() !void {
    const myPoint = 55;
    const yourPoint = 60;
    if (myPoint > yourPoint) {
        std.debug.print("Congrats! You win with `{}` point.\n", .{yourPoint});
    } else {
        std.debug.print("I win with `{}` point.\n", .{myPoint});
    }

    const yourScore = 55;
    if (yourScore > 50 and yourScore < 50) {
        std.debug.print("Not passed. Your point is F.\n", .{});
    } else if (yourScore >= 50 and yourScore < 70) {
        std.debug.print("Passed with C.\n", .{});
    } else if (yourScore >= 70 and yourScore < 90) {
        std.debug.print("Passed with B.\n", .{});
    } else if (yourScore >= 90 and yourScore <= 100) {
        std.debug.print("Passed with A.\n", .{});
    } else {
        std.debug.print("What a score huh!\n", .{});
    }

    // ?: Ternary operator Zig'de yok ama benzer bir işlevi if-else ile yapabiliyoruz
    const age: u8 = 20;
    const canVote = if (age >= 18) true else false;
    std.debug.print("Can vote: {}\n", .{canVote});

    // if karak yapılarında Conditional Binding de yapabiliriz
    // Aşağıdaki örnek kod parçasında maybeValue değişkeni ? operatörü ile optional bir i32 türünde tanımlanmıştır
    // Yani değişken ya bir i32 değeri tutar ya da null
    const maybeValue: ?i32 = 42;
    if (maybeValue) |value| { //value ile maybeValue değerine erişebiliriz
        std.debug.print("The value is: {d}\n", .{value});
    } else { // Burası maybeValue null ise çalışıyor
        std.debug.print("No value present.\n", .{});
    }
    // Hatta * operatörü ile pointer üzerinden de conditional binding yapabiliriz.
    var lastScore: ?i32 = 65;
    const bonusPoint = 5;
    if (lastScore) |*numberPointer| {
        std.debug.print("Before: {d}\n", .{numberPointer.*});
        numberPointer.* += bonusPoint;
        std.debug.print("After: {d}\n", .{numberPointer.*});
    }

    // bool türlerin kontrolü dışında error union türleri de conditional if ile ele alınabilir
    // Ancak bu kullanımda mutlaka else bloğu olmalıdır.
    var anyError: anyerror!u8 = error.FileNotFound;
    _ = &anyError;
    if (anyError) |err| {
        std.debug.print("An error occurred: {}\n", .{err});
    } else |err| {
        std.debug.print("Error is '{}'\n", .{err});
    }

    // if blokları expression olarak ele alınabilir.
    // Labeling kullanılarak bloklardan dönen değerlerin bir değişkene atanması mümkün olabilir.
    // Aşağıdaki söz dizimi, semantiğinden daha karmaşık geldi gözüme.
    const roomHeat: f32 = 25.0;
    const comfort =
        if (roomHeat < 18.0) cold: {
            break :cold "Too cold to work";
        } else if (roomHeat >= 18.0 and roomHeat < 23.0) good: {
            break :good "Ideal for programming";
        } else if (roomHeat >= 23.0 and roomHeat < 27.0) hot: {
            break :hot "A bit warm but acceptable";
        } else "Not ideal for working.";
    std.debug.print("The room condition is: '{s}'\n", .{comfort});

    // SWITCH KULLANIM ÖRNEKLERİ:

    // if dışında switch yapısı da var. Hem statment hem de expression olarak kullanılabiliyor.
    // Yukarıdaki not sistemi için bir switch ifadesi(expression) aşağıdaki gibi yazılabilir.
    const grade: u8 = 85;
    const gradeLetter = switch (grade) {
        0...49 => 'F', // Rust'ta .. ile gösterilen aralık Zig'de ... ile gösteriliyor anladığım kadarıyla
        50...69 => 'C',
        70...89 => 'B',
        90...100 => 'A',
        else => '?', // Eğer hiçbir koşul sağlanmazsa '?' dönecek
    };
    std.debug.print("Your grade letter is: {c}\n", .{gradeLetter});

    // switch enstrümanını bir de statment olarak kullanalım
    const signal = 2;
    switch (signal) {
        0 => std.debug.print("Red signal: Stop!\n", .{}),
        1 => std.debug.print("Yellow signal: Get ready!\n", .{}),
        2 => std.debug.print("Green signal: Go ahead!\n", .{}),
        else => std.debug.print("Unknown signal!\n", .{}),
    }

    // switch ifadelerinde range ile karmaşık durumlar da ele alınabilir
    const arrivalTime: u16 = 28;
    switch (arrivalTime) {
        0 => std.debug.print("On time!\n", .{}),
        1, 2 => std.debug.print("Just a bit late!\n", .{}),
        3...10 => std.debug.print("Quite late!\n", .{}),
        11...30 => std.debug.print("Very late!\n", .{}),
        else => std.debug.print("Extremely late!\n", .{}),
    }

    // // switch bloklarında her durum ele alınmalıdır. Aksi halde derleme hatası alınır.
    // // Aşağıdaki kod parçası derleme hatası verecektir.
    // // error: switch must handle all possibilities
    // // unhandled enumeration value: 'Guest'
    // const Role = enum {
    //     Admin,
    //     User,
    //     Guest,
    //     Bot,
    // };
    // const userRole = Role.User;
    // switch (userRole) {
    //     .Admin => std.debug.print("Admin role!\n", .{}),
    //     .User, .Bot => std.debug.print("User or Bot role!\n", .{}),
    //     // .Guest durumu ele alınmadığı için derleme hatası alınır
    // }

    // switch ifadelerinde labeling de kullanılabilir.
    // Aşağıdaki örnek çok anlamlı değil, sadece syntax'ı göstermek için yazdım.
    // Hangi senaryolarda işe yarar düşünelim.
    const temperature: u8 = 15;
    level: switch (temperature) {
        0...18 => {
            std.debug.print("It's cold!\n", .{});
            continue :level 19; // Burada tekrar level isimli yazan yere dönüyor ve switch ifades 19 sayısı için yeniden değerlendiriliyor
        },
        19...25 => {
            std.debug.print("It's comfortable.\n", .{});
            continue :level 26; // Bu sefer 26 sayısı için yeniden değerlendirilecek şekilde level isimli yere dönüyoruz
        },
        26...40 => {
            std.debug.print("It's hot!\n", .{});
            continue :level 41;
        },
        else => {
            std.debug.print("Extreme temperature!\n", .{});
        },
    }
    // Bu kullanımlda dikkatli olmak lazım zira sonsuz döngüye girebiliriz.

    // Swtich branch değeleri hesaplamalı olabilir veya bir değişkenden gelebilir
    const randomNumber = try rand.getFromRange(1, 100);
    std.debug.print("Random number is: {d}\n", .{randomNumber});
    const sixtySeven = 67;
    switch (randomNumber) {
        0 => std.debug.print("Zero\n", .{}),
        1 => std.debug.print("One\n", .{}),
        2...50 => std.debug.print("Between 2 and 50\n", .{}),
        50 + 1 => std.debug.print("Above 50\n", .{}), // Branch değeri buradaki gibi hesaplamalı olabilir(tür uyumlu olmalı)
        sixtySeven => std.debug.print("It's sixty seven!\n", .{}), // veya değeri bilinen bir değişken de olabilir
        68...100 => std.debug.print("Between 68 and 100\n", .{}),
        else => std.debug.print("Out of scope\n", .{}),
    }

    // Sonraki bölümlerde union ve tagged union örnekleri var.
    // Bunları da switch bloklarında kullanabiliriz.
    // Aşağıdaki örnekte bir takım değişken türlerini enum gibi ele alan bir union tanımı söz konusu.
    // union kısmında ele alıyoruz ama burada da belirtelim. Bir union nesne sadece tek bir türde değeri tutabilir.
    const ValueObject = union(enum) {
        Int32: i32,
        Float32: f32,
        Text: []const u8,
    };
    const integer: ValueObject = .{ .Int32 = 51 };
    switch (integer) {
        .Int32 => |intVal| {
            std.debug.print("Integer value: {d}\n", .{intVal});
        },
        .Float32 => |floatVal| {
            std.debug.print("Float value: {f}\n", .{floatVal});
        },
        .Text => |textVal| {
            std.debug.print("Text value: {s}\n", .{textVal});
        },
    }

    // Yukarıdaki örnekte integer isimli değişken const türündendir.
    // var ile tanımlarsak bu, üzerinde değişiklik yapmak istediğimiz anlamına gelir.
    // Bu durumda ilgili branch'te pointer ile değere erişebilir ve dereference yaparak da değiştirebiliriz.
    var piValue: ValueObject = .{ .Float32 = 3.14 };
    switch (piValue) {
        .Int32 => |intVal| {
            std.debug.print("Integer value: {d}\n", .{intVal});
        },
        .Float32 => |*floatVal| {
            floatVal.* += 0.00159; // Pointer üzerinden değere erişip değiştirebiliyoruz
        },
        .Text => |textVal| {
            std.debug.print("Text value: {s}\n", .{textVal});
        },
    }
    std.debug.print("Updated pi value: {d}\n", .{piValue.Float32});
}
