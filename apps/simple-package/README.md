# Simple Package

Zig ile bir paket nasıl oluşturulur sorusunun cevaplandığı örnek projedir. Bir paketi **import** komutu ile başka bir zig projesinde kullanabiliriz. Diğer birçok platformdaki paket sistemine benzer bir yaklaşım vardır. Kütüphane kodlarını içeren zig dosyaları, geçerli bir Readme, build aşamalarını ve module bağlamlarını içeren enstrümanların tasarlanması yeterlidi.

## Klasör Yapısı

Paketteki içeriği aşağıdaki gibi özetleyebiliriz.

- `common.zig`: Kütüphane kodlarını içeren zig dosyası. Paket içerisine dahil etmek istediğimiz temel fonksiyonlar örnek senaryoda burada yer alır. Elbette pakette birden fazla kod dosyası olabilir.
- `build.zig`: Paketin nasıl derleneceğini tanımlayan build scripti. Bu dosya, paketin nasıl inşa edileceği ve hangi kaynak dosyaların dahil edileceği gibi bilgileri içerir.
- `build.zig.zon`: Paketin meta bilgilerini içeren bir zon dosyası. Paket adı, versiyonu, gerekli en düşük zig sürümü ve paket içeriği gibi bilgiler burada yer alır.
- `README.md`: Paketin ne işe yaradığını, nasıl kullanılacağını ve diğer önemli bilgileri içeren klasik **markdown** formatındaki dosyadır. Buradaki gibi değil de, paketin ne işe yaradığını anlatır türden bir içeriği olur.
- `.gitignore`: Git tarafından takip edilmeyecek dosya ve klasörleri belirten dosyadır. Çoğu zaman derleme çıktıları, geçici *(temp)* dosyalar ve IDE konfigürasyonları gibi içerikler eklenir ve **push** sırasında hariç tutulurlar.

## Paket Hazırlama Adımları

Dikkat edilmesi gereken kısımlardan birisi zig.zon dosyasındaki **fingerprint** değeridir. Bu değeri ezbere oluşturmak zordur. O nedenle genellikle 0x1234 gibi hatalı bir değer verilip,

```bash
zig build run
```

ile oluşan hata mesajında önerilen değere güncellenir. Bu sayede paketimizin benzersiz bir kimliğe sahip olması sağlanır. Bir paket hazırladığımızda, içerisindeki kodların mutlaka çalışır olduğundan emin olmakta fayda vardır. Bu nedenle birim testleri yazmak ve çalıştırmak önemlidi. Testler'den eminsek ve build başarılı olmuşsa github için gerekli initialization işlemini yaparak devam edebiliriz.

```bash
zig build test
git init
```

## Peki, paketi nasıl kullanacağız?

Paket tasarlandıktan sonra github'a yüklenir. Herhangibir projede bu paketi kullanmak istersek, zig ortamına indirilmesi gerekir. Bunun için aşağıdaki komut kullanılabilir.

```bash
zig fetch --save paketin_github_adresi
```

Bu işlem tek başına yeterli değil. Paketi kullanacağımız projenin build.zig dosyasına da ekleme yapmak gerekir. Örneğin aşağıdaki gibi;

```zig
exe.root_module.addImport("trigo-zig", trigoZig.module("trigo-zig"));
```

Kullanım ile ilgili olarak [şuradaki paket ve örnek uygulama](https://github.com/buraksenyurt/trigo-zig) incelenebilir.
