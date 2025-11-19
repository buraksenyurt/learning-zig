# Zig Programlama Dili

Zig programlama dilini öğrenmek, araştırmak için açılmış repodur.

## Platform

Örnek çalışmaları Windows 11 platformunda, Visual Studio Code IDE üzerinden yapıyorum.

## Kurulum

Öncelikle [Zig Download](https://ziglang.org/download/) adresinden Windows x86_64 zip platformu için olan zip dosyasını indirdim ve sisteme açtım. Sonrasında ortam değişkenlerinden *(Environment Variables)* **path**'e **zig.exe**'nin olduğu klasör yolunu ekledim.

## İlk Proje

```bash
# chapter-00 klasöründe aşağıdaki komutla bir proje açıldı
zig init

# Build işlemleri build.zig dosyasında tanımlanır

# programı build edip çalıştırmak için
zig build run

# root.zig çıkartıldı.
# program kodunu build etmek için
# --summary all parametresi ile build çıktısı özetlenir
zig build --summary all

# build işlemi sonrası oluşan executable dosyayı çalıştırma için (Windows 11)
./zig-out/bin/chapter-00.exe
```

## Dilin Genel Özellikleri

> EKLENECEK

## Örnekler

> EKLENECEK
