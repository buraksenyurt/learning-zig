const std = @import("std");

// Herhangi bir anda sadece tek bir field'ın aktif olabileceği bir veri yapısının tasarımı için
// union enstrümanı kullanılabilir.

pub fn main() void {
    // // Aşağıdaki örneğe dikkat edelim.
    // // Bu örnek çalışma zamanında bir paniğe sebep olur ve uygulama çöker.
    // // Çünkü union'ın v1 alanına bir i64 değeri atandıktan sonra v2 alanına bir f64 değeri atanmaya çalışılıyor.
    // // union yapısında sadece tek bir alan aktif olabilir.
    // // Bu nedenle v1 alanına atanan i64 değeri üzerine v2 alanına f64 değeri atanmaya çalışıldığında bellek bozulur
    // // Aşağıdaki kod için üretilen bir hata : thread 11376 panic: access of union field 'v2' while field 'v1' is active

    // const Result2 = union {
    //     v1: i64,
    //     v2: f64,
    //     v3: bool,
    // };
    // var result2 = Result2{ .v1 = 1234 };
    // // result2.v2 = 12.34;
    // // Yukarıdaki kullanım yerine aşağıdaki gibi yeni bir atama yaparsak sorun olmaz
    // result2 = Result2{ .v3 = true };

    // Şimdi biraz daha gerçekçi bir örneğe bakalım.
    // Şöyle bir senaryo düşünelim. Bir IoT konnektörüne farklı sensörler takılabiliyor olsun.
    // Sıcaklık, nem, ivme gibi değerleri farklı sensörlerden okuyabiliyoru ama bir t anında sadece bir tanesi söz konusu.

    var tempSensor = SensorFactory{ .Temperature = 18.9 };
    logSensorData(tempSensor);
    tempSensor = SensorFactory{ .Humidity = 75 };
    logSensorData(tempSensor);
    tempSensor = SensorFactory{ .Acceleration = Acceleration{ .x = 0.0, .y = 9.81, .z = 0.0 } };
    logSensorData(tempSensor);

    // NullableInt union türünü deneyelim
    var theValue: NullableInt = NullableInt{ .Some = 42 };
    if (theValue.isSome()) {
        const value = theValue.unwrap();
        std.debug.print("NullableInt has value: {d}\n", .{value});
    } else {
        std.debug.print("NullableInt is None\n", .{});
    }

    theValue = NullableInt{ .None = {} };
    if (theValue.isSome()) {
        const value = theValue.unwrap();
        std.debug.print("NullableInt has value: {d}\n", .{value});
    } else {
        std.debug.print("NullableInt is None\n", .{});
    }
}

// Sensör türlerini aşağıdaki gibi bir enum türü olarak tanımlayabiliriz
const SensorType = enum { Temperature, Humidity, Acceleration };

// İvme için x,y,z değerlerini tutan bir struct
const Acceleration = struct { x: f32, y: f32, z: f32 };

// Tagged Uninon;
// Burada union ile SensorType enum değerlerini tek çatı altında birleştirdik.
// union'a bir tag eklediğimizi söyleyebiliriz. SensorType dışında bir seçenek ekleyemeyiz.
// Burada sıralama önemli. Eğer enum içerisindeki sıralamayı değiştirir ama aşağıdaki union tanımında aynı sıralamayı korumazsak
// derleme zamanı hatası alırız. error: union field 'Acceleration' ordered differently than corresponding enum field gibi
const SensorFactory = union(SensorType) {
    Temperature: f32,
    Humidity: u8,
    Acceleration: Acceleration,
};

fn logSensorData(sensor: SensorFactory) void {
    switch (sensor) {
        .Temperature => |value| {
            std.debug.print("Temperature value is {}\n", .{value});
        },
        .Humidity => |value| {
            std.debug.print("Humidity value is {}\n", .{value});
        },
        .Acceleration => |value| {
            std.debug.print("Acceleration value is x:{d:.2}, y:{d:.2}, z:{d:.2}\n", .{ value.x, value.y, value.z });
        },
    }

    // Normal bir union tanımını aşağıdaki gibi yapabiliriz
    const Result = union(enum) {
        Success: void, // herhangi bir veri taşımayan durum
        Error: u8, // hata kodu taşıyan durum
    };
    var result: Result = Result{ .Success = {} };
    switch (result) {
        .Success => {
            std.debug.print("Operation was successful\n", .{});
        },
        .Error => |*errCode| { // Hata kodunu pointer olarak çıkartıp
            errCode.* += 1; // dereference edip 1 artırdık
            std.debug.print("Operation failed with error code: {d}\n", .{errCode.*});
        },
    }
}

// Union türleri de normal struct ve enum türleri gibi değişkenler ve fonksiyonlar içerebilirler.
// Örnek olarak nullable bir integer türünü union olarak tanımlayabiliriz
// Sadece tek bir değeri kullanılabileceğinden bu oldukça mantıklı ;)
// Buna bazı yardımcı fonksiyonlar da ekleyebiliriz. Rust'a benzettik gibi :D
const NullableInt = union(enum) {
    Some: i32,
    None: void,

    pub fn isSome(self: NullableInt) bool {
        return switch (self) {
            .Some => true,
            .None => false,
        };
    }

    pub fn unwrap(self: NullableInt) i32 {
        return switch (self) {
            .Some => |value| value,
            .None => @panic("Called unwrap on a None value"),
        };
    }
};
