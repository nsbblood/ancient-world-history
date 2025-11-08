# 🔧 RevenueCat Sorunu Çözüm Rehberi

## ❌ Sorun

Loglarınızdan görünen sorun:
```
ERROR: None of the products registered in the RevenueCat dashboard could be fetched from App Store Connect
⚠️ ancient.week: Status (READY_TO_SUBMIT) - App Store Connect'te onay bekliyor
⚠️ ancient.year: Status (READY_TO_SUBMIT) - App Store Connect'te onay bekliyor
```

Ürünler App Store Connect'te **Ready to Submit** durumunda, ancak henüz **onaylanmamış**. Bu yüzden test ortamında çekilemiyor.

---

## ✅ Çözüm 1: StoreKit Configuration Kullanın (Test İçin - HEMEN)

### Adım 1: Xcode'da StoreKit Configuration'ı Aktif Et

1. **Xcode'da** projenizi açın
2. **Product → Scheme → Edit Scheme...** (veya ⌘+<)
3. **Run** sekmesini seçin (sol menüden)
4. **Options** sekmesine gidin
5. **StoreKit Configuration** bölümünü bulun
6. Dropdown'dan **Configuration.storekit** seçin
7. **Close** yapın

### Adım 2: Uygulamayı Yeniden Çalıştırın

1. Uygulamayı durdurun (⌘+.)
2. Uygulamayı tekrar çalıştırın (⌘+R)
3. Console'da artık ürünlerin yüklendiğini görmelisiniz

### Adım 3: Kontrol

Console'da şunları görmelisiniz:
```
✅ Yearly package found: [title] - [price]
✅ Weekly package found: [title] - [price]
```

**Not:** StoreKit Configuration yalnızca **test için** kullanılır. Production için App Store Connect'te ürünleri onaylamanız gerekir.

---

## ✅ Çözüm 2: App Store Connect'te Ürünleri Onaylayın (Production İçin)

### Adım 1: App Store Connect'e Gidin

1. **App Store Connect** → Uygulamanızı seçin
2. **Features → In-App Purchases** bölümüne gidin

### Adım 2: Ürünleri Kontrol Edin

Her ürün için:
- [ ] `ancient.year` - Durum: Ready to Submit mi?
- [ ] `ancient.week` - Durum: Ready to Submit mi?

### Adım 3: Ürünleri Onaylayın

1. Her ürünü seçin
2. **Submit for Review** butonuna tıklayın
3. Gerekli bilgileri doldurun (açıklama, ekran görüntüsü vs.)
4. **Submit** yapın

### Adım 4: Onay Bekleme

- Apple'ın ürünleri onaylaması **24-48 saat** sürebilir
- Onaylandıktan sonra ürünler test ortamında kullanılabilir olur

### Adım 5: Test

1. **Sandbox Tester** hesabı oluşturun (App Store Connect → Users and Access → Sandbox Testers)
2. Cihazınızda **Settings → App Store → Sign Out** yapın
3. Uygulamayı çalıştırın
4. Sandbox tester hesabıyla giriş yapın
5. Ürünler artık yüklenmeli

---

## 📋 Mevcut Durum Kontrolü

### ✅ Doğru Olanlar:
- ✅ RevenueCat yapılandırması başarılı
- ✅ API key doğru
- ✅ Package identifier'ları doğru (`$rc_annual`, `$rc_weekly`)
- ✅ Offering identifier: `premium` (kod alternatif offering'leri de kontrol ediyor)
- ✅ StoreKit Configuration dosyası var ve ürünler tanımlı

### ❌ Sorun:
- ❌ Ürünler App Store Connect'ten çekilemiyor (READY_TO_SUBMIT durumunda)
- ❌ StoreKit Configuration aktif değil (test için)

---

## 🎯 Önerilen Çözüm Sırası

### Test İçin (Hemen):
1. ✅ **StoreKit Configuration'ı aktif edin** (Çözüm 1)
2. ✅ Uygulamayı test edin
3. ✅ Ürünler yüklenmeli

### Production İçin (Uzun Vadeli):
1. ✅ **App Store Connect'te ürünleri onaylayın** (Çözüm 2)
2. ✅ Apple'ın onayını bekleyin (24-48 saat)
3. ✅ Sandbox tester ile test edin
4. ✅ StoreKit Configuration'ı kapatın (production için)

---

## ⚠️ Önemli Notlar

1. **StoreKit Configuration** yalnızca test için kullanılır
2. **Production** için App Store Connect'te ürünlerin onaylanması gerekir
3. **Sandbox test** için App Store Connect'te ürünlerin onaylanması gerekir (StoreKit Configuration alternatif)
4. Ürünler onaylandıktan sonra **RevenueCat Dashboard**'da senkronize olmalı

---

## 🔍 Sorun Devam Ederse

Eğer StoreKit Configuration'ı aktif ettikten sonra hala sorun varsa:

1. **Console loglarını kontrol edin:**
   - `✅ Yearly package found` görünüyor mu?
   - `✅ Weekly package found` görünüyor mu?

2. **StoreKit Configuration dosyasını kontrol edin:**
   - `Configuration.storekit` dosyası projede var mı?
   - Ürünler tanımlı mı?

3. **Xcode scheme'yi kontrol edin:**
   - StoreKit Configuration seçili mi?
   - Doğru dosya seçili mi?

---

## 📞 Sonuç

**En hızlı çözüm:** StoreKit Configuration'ı aktif edin ve test edin. Bu, App Store Connect'te ürünlerin onaylanmasını beklemeden test yapmanıza olanak sağlar.

**Production çözümü:** App Store Connect'te ürünleri onaylayın ve sandbox test yapın.







