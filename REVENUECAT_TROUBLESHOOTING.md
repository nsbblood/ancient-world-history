# 🔍 RevenueCat Sorun Giderme Kontrol Listesi

## ❌ Sorun: Ürünler Yüklenmiyor

Ekranda "Failed to load subscriptions" hatası görünüyor. Bu kontrol listesini adım adım takip edin.

---

## 📋 ADIM 1: Console Loglarını Kontrol Et

### Xcode'da Console'u Açın
1. Xcode'da uygulamayı çalıştırın
2. **Console** sekmesini açın (⌘+⇧+Y)
3. Şu logları arayın:
   - `🔧 Configuring RevenueCat...`
   - `✅ RevenueCat configured successfully`
   - `🔄 Fetching RevenueCat offerings...`
   - `📦 Offerings received:`
   - `✅ Current offering:` veya `⚠️ No current offering found`

### Hangi Hatayı Görüyorsunuz?
- [ ] RevenueCat is not configured
- [ ] No current offering found
- [ ] Package not found (ancient.year / ancient.week)
- [ ] Network error
- [ ] API key error

---

## 📋 ADIM 2: RevenueCat Dashboard Kontrolleri

### 2.1 API Key Kontrolü
**Kodunuzdaki API Key:** `appl_QugKNOckInPdncYbLMcQxYPdvtm`

1. **RevenueCat Dashboard'a gidin:** https://app.revenuecat.com
2. **Projenizi seçin**
3. **Settings → API Keys** bölümüne gidin
4. **iOS App API Key** kontrol edin
   - ✅ Kodunuzdaki API key ile eşleşiyor mu?
   - ✅ Doğru projeden mi alındı?
   - ✅ Production key mi? (Sandbox test için sandbox key kullanın)

### 2.2 Products Kontrolü
1. **RevenueCat Dashboard → Products** bölümüne gidin
2. Şu ürünlerin olup olmadığını kontrol edin:
   - [ ] `ancient.year` - Var mı?
   - [ ] `ancient.week` - Var mı?

**Eğer yoksa:**
1. **Add Product** butonuna tıklayın
2. **Product ID:** `ancient.year` girin
3. **App Store Connect Product ID** ile eşleştirin
4. Aynı işlemi `ancient.week` için tekrarlayın

### 2.3 Entitlements Kontrolü
1. **RevenueCat Dashboard → Entitlements** bölümüne gidin
2. **`premium`** entitlement'ı var mı kontrol edin
   - [ ] Var mı?
   - [ ] İki product da bu entitlement'a bağlı mı?

**Eğer yoksa:**
1. **Create Entitlement** butonuna tıklayın
2. **Identifier:** `premium` girin
3. **Attach Products:** `ancient.year` ve `ancient.week` seçin
4. **Save** yapın

### 2.4 Offerings Kontrolü (EN ÖNEMLİ!)
1. **RevenueCat Dashboard → Offerings** bölümüne gidin
2. Bir offering var mı kontrol edin:
   - [ ] En az bir offering var mı?
   - [ ] Offering identifier'ı ne? (genellikle `default` olmalı)

**Eğer offering yoksa:**
1. **Create Offering** butonuna tıklayın
2. **Identifier:** `default` girin (veya istediğiniz bir isim)
3. **Packages** bölümüne gidin
4. **Add Package** butonuna tıklayın
   - Package Identifier: `ancient.year` (veya istediğiniz isim)
   - Product: `ancient.year` seçin
   - **Save**
5. Tekrar **Add Package** yapın
   - Package Identifier: `ancient.week` (veya istediğiniz isim)
   - Product: `ancient.week` seçin
   - **Save**
6. **Set as Current** butonuna tıklayın (ÇOK ÖNEMLİ!)
7. **Save Offering** yapın

**Önemli Not:** Package identifier'ları (`ancient.year`, `ancient.week`) kodunuzda kullandığınız identifier'larla EŞLEŞMELİ!

---

## 📋 ADIM 3: App Store Connect Kontrolleri

### 3.1 Ürünlerin Oluşturulması
1. **App Store Connect** → Uygulamanızı seçin
2. **Features → In-App Purchases** bölümüne gidin
3. Şu ürünlerin olup olmadığını kontrol edin:
   - [ ] `ancient.year` - Var mı? Durum nedir?
   - [ ] `ancient.week` - Var mı? Durum nedir?

**Ürün Durumları:**
- ✅ **Ready to Submit** - İdeal durum
- ⚠️ **Missing Metadata** - Eksik bilgiler var
- ⚠️ **Waiting for Review** - Onay bekliyor
- ❌ **Developer Removed** - Silinmiş

### 3.2 Ürün Detayları
Her ürün için kontrol edin:

**ancient.year:**
- [ ] Product ID: `ancient.year` (tam olarak)
- [ ] Type: Auto-renewable Subscription
- [ ] Duration: 1 Year
- [ ] Price: Ayarlanmış mı?
- [ ] Localization: En az bir dil (İngilizce) eklenmiş mi?

**ancient.week:**
- [ ] Product ID: `ancient.week` (tam olarak)
- [ ] Type: Auto-renewable Subscription
- [ ] Duration: 1 Week
- [ ] Price: Ayarlanmış mı?
- [ ] Free Trial: 3 days (opsiyonel)
- [ ] Localization: En az bir dil (İngilizce) eklenmiş mi?

### 3.3 RevenueCat Senkronizasyonu
1. **RevenueCat Dashboard → Products** bölümüne gidin
2. Her product için:
   - [ ] App Store Connect'teki product ile eşleşmiş mi?
   - [ ] Sync durumu: ✅ Synced mı?
   - [ ] Hata var mı? (kırmızı uyarı)

**Eğer sync yoksa:**
1. Product'ı manuel olarak silin
2. **Sync from App Store Connect** butonuna tıklayın
3. Product'ı tekrar ekleyin

---

## 📋 ADIM 4: Kod Kontrolleri

### 4.1 API Key Kontrolü
**Dosya:** `AncientWorldStoriesApp.swift`

```swift
Purchases.configure(withAPIKey: "appl_QugKNOckInPdncYbLMcQxYPdvtm")
```

- [ ] API key doğru mu?
- [ ] RevenueCat Dashboard'daki iOS API key ile eşleşiyor mu?

### 4.2 Package Identifier Kontrolü
**Dosya:** `PaywallView.swift`

Kodunuzda şu identifier'lar kullanılıyor:
- `ancient.year`
- `ancient.week`

- [ ] RevenueCat Dashboard'daki package identifier'ları ile eşleşiyor mu?

**Not:** Package identifier'ları Product ID'lerden farklı olabilir. Package identifier'ları Offering'deki package'lara verdiğiniz isimlerdir.

---

## 📋 ADIM 5: Test Ortamı Kontrolleri

### 5.1 Sandbox Test
1. **App Store Connect → Users and Access → Sandbox Testers**
   - [ ] En az bir sandbox tester oluşturulmuş mu?
   - [ ] Email ve şifre doğru mu?

2. **Cihazınızda:**
   - [ ] App Store'dan çıkış yaptınız mı?
   - Settings → App Store → Sign Out

3. **Uygulamayı çalıştırın:**
   - Sandbox tester hesabıyla giriş yapın
   - Ürünler yükleniyor mu?

### 5.2 StoreKit Configuration Dosyası
**Dosya:** `Configuration.storekit`

- [ ] StoreKit configuration dosyası var mı?
- [ ] Ürünler bu dosyada tanımlı mı?
- [ ] Xcode scheme'de StoreKit configuration seçili mi?

**Kontrol:**
1. Xcode → Edit Scheme → Run → Options
2. StoreKit Configuration: `Configuration.storekit` seçili mi?

---

## 📋 ADIM 6: Yaygın Sorunlar ve Çözümleri

### Sorun 1: "No current offering found"
**Çözüm:**
- RevenueCat Dashboard → Offerings → Offering'i **"Set as Current"** yapın
- Veya offering identifier'ını `default` olarak değiştirin

### Sorun 2: "Package identifier not found"
**Çözüm:**
- Package identifier'ları kodunuzdaki identifier'larla eşleştirin
- Offering'deki package identifier'ları kontrol edin

### Sorun 3: "Products not synced"
**Çözüm:**
- App Store Connect'te ürünler **Ready to Submit** durumunda olmalı
- RevenueCat Dashboard'da **Sync from App Store Connect** yapın
- Birkaç dakika bekleyin (sync zaman alabilir)

### Sorun 4: "API Key error"
**Çözüm:**
- Sandbox test için sandbox API key kullanın
- Production için production API key kullanın
- API key doğru projeden mi alındı kontrol edin

### Sorun 5: "Network error"
**Çözüm:**
- İnternet bağlantısını kontrol edin
- VPN kullanıyorsanız kapatın
- RevenueCat servislerinin çalışıp çalışmadığını kontrol edin: https://status.revenuecat.com

---

## 📋 ADIM 7: Debug Checklist

Uygulamayı çalıştırın ve console'da şunları kontrol edin:

```
✅ Kontrol Listesi:
[ ] 🔧 Configuring RevenueCat... görünüyor mu?
[ ] ✅ RevenueCat configured successfully görünüyor mu?
[ ] 🔄 Fetching RevenueCat offerings... görünüyor mu?
[ ] 📦 Offerings received: görünüyor mu?
[ ] ✅ Current offering: [identifier] görünüyor mu?
[ ] ✅ Yearly package found: [title] - [price] görünüyor mu?
[ ] ✅ Weekly package found: [title] - [price] görünüyor mu?
```

**Eğer hata görüyorsanız:**
- Hata mesajını not edin
- Hangi adımda olduğunu belirleyin
- Yukarıdaki ilgili bölüme bakın

---

## 📋 ADIM 8: Hızlı Kontrol Scripti

Console'da şu komutları çalıştırarak kontrol edebilirsiniz:

```swift
// RevenueCat yapılandırması kontrolü
print("RevenueCat configured: \(Purchases.isConfigured)")

// Offerings kontrolü
Task {
    do {
        let offerings = try await Purchases.shared.offerings()
        print("Offerings: \(offerings.all.keys)")
        print("Current offering: \(offerings.current?.identifier ?? "none")")
        if let current = offerings.current {
            print("Packages: \(current.availablePackages.map { $0.identifier })")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

---

## ✅ Başarı Kriterleri

Ürünler başarıyla yüklendiğinde:
- ✅ Console'da "Yearly package found" mesajı görünür
- ✅ Console'da "Weekly package found" mesajı görünür
- ✅ PaywallView'da ürün kartları görünür
- ✅ Fiyatlar doğru şekilde gösterilir
- ✅ "Continue" butonu aktif olur

---

## 📞 Yardım

Eğer tüm adımları kontrol ettikten sonra hala sorun varsa:
1. Console loglarını kaydedin
2. RevenueCat Dashboard ekran görüntülerini alın
3. Hangi adımda takıldığınızı belirtin

**Önemli:** RevenueCat'in ürünleri senkronize etmesi bazen 5-10 dakika sürebilir. Değişiklik yaptıktan sonra birkaç dakika bekleyin.








