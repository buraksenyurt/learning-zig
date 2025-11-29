# Space Invaders Game in Zig

[Code with Cypert](https://www.youtube.com/@CodeWithCypert) youtube kanalında Zig programlama dilini kullanarak Space Invaders oyununu yazmış. Bu öğretiyi takip ederek Zig programlama dilini daha yakından tanımayı hedefliyorum. Oyunu yazmak için C ile yazılmış popüler raylib oyun kütüphanesinin Zig dilinen bind ediliği bir sürümü kullanılıyor.

Kod Zig'in 0.15.1 sürümü ile yazılmış. Chocolatey ile Windows'a Zig kurulumu için:

```bash
choco install zig
```

yazmak yeterli ama buradaki güncel ve geçerli sürüm 0.14. Dolayısıyla 0.15.1'i makineye indirdikten sonra C:\zig-0.15.1\ dizine açtım ve oradaki zig.exe dosyasını kullanarak projeyi başlatıp, derledim.

````bash
# Projeyi oluşturmak için
mkdir space-invaders
cd space-invaders

# Zig projesi başlatmak için
zig init

# Raylib kütüphanesine Zig binding eklemek için
zig fetch --save git+https://github.com/raylib-zig/raylib-zig#devel

# projeyi çalıştırmak için
zig build run
```
