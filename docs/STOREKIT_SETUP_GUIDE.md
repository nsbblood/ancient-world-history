# 🛒 StoreKit Configuration Kılavuzu

## 📌 StoreKit Configuration Nedir?

StoreKit Configuration dosyası, Xcode'da **lokal test** için kullanılır. Gerçek App Store Connect ürünlerine ihtiyaç duymadan test edebilmenizi sağlar.

## ⚠️ Önemli: RevenueCat ile Kullanım

**RevenueCat kullanıyorsanız, StoreKit Configuration'a genellikle ihtiyacınız YOKTUR.**

Bunun yerine:
- ✅ **RevenueCat Dashboard** ayarlarını yapın
- ✅ **App Store Connect** ürünlerini oluşturun
- ✅ **Sandbox Tester** hesabıyla test edin

StoreKit Configuration sadece:
- RevenueCat kullanmıyorsanız
- Tamamen lokal test yapmak istiyorsanız
- StoreKit 2'yi direkt kullanıyorsanız

**faydalıdır.**

---

## 🔧 StoreKit Configuration Nasıl Eklenir?

### Adım 1: Dosya Kontrolü

Projenizde zaten `Configuration.storekit` dosyası var ve ürünler tanımlı:
- ✅ `ancient.year` - Annual Subscription ($39.99)
- ✅ `ancient.week` - Weekly Subscription ($4.99, 3-day trial)

### Adım 2: Xcode Scheme'de Aktif Etme

1. **Xcode'da** projenizi açın
2. **Product → Scheme → Edit Scheme...** (veya ⌘+<)
3. **Run** sekmesini seçin (sol menüden)
4. **Options** sekmesine gidin
5. **StoreKit Configuration** bölümünü bulun
6. Dropdown'dan **Configuration.storekit** seçin
7. **Close** yapın

**Görsel Yol:**
```
Xcode → Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration
```

### Adım 3: Kontrol

Xcode'da uygulamayı çalıştırdığınızda:
- Console'da StoreKit Configuration kullanıldığına dair log görürsünüz
- Ürünler lokal olarak test edilebilir

---

## ⚠️ RevenueCat ile Çakışma

**Dikkat:** StoreKit Configuration aktifken RevenueCat çalışmayabilir!

### Çözüm 1: StoreKit Configuration'ı Kapatın (Önerilen)

RevenueCat kullanıyorsanız:
1. **Edit Scheme → Run → Options**
2. **StoreKit Configuration** → **None** seçin
3. RevenueCat Dashboard ve Sandbox test kullanın

### Çözüm 2: İkisini Birlikte Kullanma

Eğer ikisini birlikte kullanmak istiyorsanız:
- RevenueCat **sandbox** modunda çalışır
- StoreKit Configuration **lokal** test için çalışır
- İkisi birlikte çalışabilir ama **karmaşık olabilir**

---

## 📋 Ne Zaman StoreKit Configuration Kullanılır?

### ✅ StoreKit Configuration Kullanın:
- RevenueCat kullanmıyorsanız
- Tamamen lokal test yapmak istiyorsanız
- StoreKit 2'yi direkt kullanıyorsanız
- Hızlı prototip/test yapıyorsanız

### ❌ StoreKit Configuration Kullanmayın:
- RevenueCat kullanıyorsanız (sizin durumunuz)
- Gerçek App Store Connect ürünlerini test etmek istiyorsanız
- Sandbox test yapıyorsanız

---

## 🎯 Sizin Durumunuz İçin Öneri

**RevenueCat kullanıyorsunuz, bu yüzden:**

1. **StoreKit Configuration'ı KAPATIN:**
   - Edit Scheme → Run → Options → StoreKit Configuration → **None**

2. **RevenueCat Dashboard'u Kullanın:**
   - Offerings oluşturun
   - Products senkronize edin
   - Sandbox test yapın

3. **App Store Connect Ürünlerini Oluşturun:**
   - `ancient.year`
   - `ancient.week`
   - Durum: Ready to Submit

---

## 🔍 StoreKit Configuration Dosyası Detayları

Mevcut `Configuration.storekit` dosyanız:

```json
{
  "subscriptionGroups": [
    {
      "name": "Ancient World Premium",
      "subscriptions": [
        {
          "productID": "ancient.year",
          "displayPrice": "39.99",
          "recurringSubscriptionPeriod": "P1Y"
        },
        {
          "productID": "ancient.week",
          "displayPrice": "4.99",
          "recurringSubscriptionPeriod": "P1W",
          "introductoryOffer": {
            "subscriptionPeriod": "P3D",
            "paymentMode": "free"
          }
        }
      ]
    }
  ]
}
```

Bu dosya doğru görünüyor, ancak RevenueCat kullanıyorsanız aktif etmenize gerek yok.

---

## ✅ Kontrol Listesi

- [ ] StoreKit Configuration dosyası var mı? ✅ (Var)
- [ ] Ürünler tanımlı mı? ✅ (Var)
- [ ] Xcode scheme'de aktif mi? ❓ (Kontrol etmeniz gerekiyor)
- [ ] RevenueCat kullanıyor musunuz? ✅ (Evet)
- [ ] StoreKit Configuration'ı kapatmalı mısınız? ✅ (Evet, önerilir)

---

## 📞 Sonuç

**Kısa Cevap:** StoreKit Configuration eklemenize **GEREK YOK**. RevenueCat kullanıyorsunuz, bu yüzden:

1. RevenueCat Dashboard'da ayarları yapın
2. App Store Connect'te ürünleri oluşturun
3. Sandbox test yapın

StoreKit Configuration'ı aktif etmek istiyorsanız, yukarıdaki adımları takip edin, ancak RevenueCat ile çalışırken genellikle gerekli değildir.













