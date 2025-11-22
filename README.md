# Zig Programlama Dili

Zig programlama dilini öğrenmek, araştırmak için açılmış repodur.

## Platform

Örnek çalışmaları Windows 11 platformunda, Visual Studio Code IDE üzerinden yapıyorum.

## Kurulum

İlk seferde [Zig Download](https://ziglang.org/download/) adresinden Windows x86_64 zip platformu için olan zip dosyasını indirdim ve sisteme açtım. Sonrasında ortam değişkenlerinden *(Environment Variables)* **path**'e **zig.exe**'nin olduğu klasör yolunu ekledim. Ancak bu bana çok fazla sorun çıkarttı. Son sürüm olduğu için kütüphane değişikliklerine dair güncel kaynaklar, yazılar bulmak zor. Stabil bir sürüm üzerinden çalışmak için global paket yöneticilerinden yüklemek daha doğru olabilir. Bu yüzden **chocolate** ile ilgili paketi tekrardan yükledim.

```bash
choco install zig
zig version
```

> Repoyu düzenlediğim tarih itibariyle manuel yüklemedeki development versiyonı **0.16.0-dev.1364+f0a3df98d** Ancak backward compatibility çok iyi değil gibi. O yüzden stabil sürüme geçtim. Şu anda **0.14.0** sürümü üzerinde çalışıyorum.

## Nasıl Çalıştırabiliriz?

Dilin genel özelliklerini anlamak için hiç zig uzantılı dosyalar hazırlayıp gerekli kodlamaları yaptıktan sonra aşağıdaki gibi çalıştırabiliriz.

```bash
zig run hello_world.zig
```

## Dille İlgili Bazı Notlar

- Genelde C dilinin modern bir alternatifi olarak tanımlanıyor. C türevli söz dizimine de sahip.
- **Strongly Typed** sistemini kullanan derlemeli bir dil.
- Herhangi bir **Garbage Collector** mekanizması içermiyor.
- **Generic** tip sistemini de destekliyor.
- **Meta programlama** kabiliyetleri var.
- **Rust** dili ile de büyük benzerlikler var ve hatta daha güzel bir syntax ile benzer işleri yaptığı iddia ediliyor. Söz gelimi fonksiyon dönüşlerini belirtirken **Rust** dilinde kullanılan **->** burada yok. *(Rust ile çalışmış kişilerin de kolayca adapte olabileceğini düşünüyorum)*
- **@** ifadesi ile başlayan fonksiyonlar **built-in** fonksiyonlar ve bunlar standart kütüphanenin aksine doğrudan derleyici tarafından sağlanıyorlar.
- Dosya bazlı modül yapısı kullanılıyor. Bu modülleri kullanmak için path bilgisi ile **import** edilmesi yeterli.
- Rust'tan aşina olduğumuz **pub keyword** burada da var. Dolayısıyla bir enstrümanı genel kullanıma açmak için **pub keyword** kullanılıyor diyebiliriz.
- Yorum satırları **//** ile yazılıyor ve birçok dilin aksine **multi-line comments** bulunmuyor. Yani `/* */` şeklinde bir kullanım yok. Rust dilindekine benzer şekilde **//!** ve **///** ile kod dokümantasyonu sağlanabiliyor.
- Executable'ların mutlaka bir **main** fonksiyonu içermesi gerekiyor.
- Rust dilindekine benzer primitive tipler söz konusu. **u8, i8, u16, i16, u32, i32, u64, i64, f32 ve f64** gibi. Ancak bunların haricinde **u47, i47, f16, f80 ve f128** gibi farklı sayısal türler de mevcut.
- Ama **String** diye bir tür yok. **String** aslında **u8** türünden bir dizi olarak ele alınıyor. Örneğin **fullName** isimli bir **struct** alanı, **fullName : []const u8** şeklinde tanımlanıyor.
- Fonksiyon parametreleri constant olarak geçiyor. Dolayısıyla metot içerisinde değerleri değiştirilemiyor *(İspat aranacak)*
- Fonksiyonların aşırı yüklenmesi *(Function Overloading)* söz konusu değil.
- comptime ???

> Keşfettikçe diğer özellikler de eklenecek
