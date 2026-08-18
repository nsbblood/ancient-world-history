# Ancient World Stories — Ideas & Notes

## 🔴 P1 — sıradaki iş (kod tarafı)

- **İçerik hacmi** — Bundle'da 8 medeniyet / 9 hikâye / **15 bölüm** var, bölüm başına ~200 kelime.
  Toplam ≈ 3.300 kelime ≈ 20 dakika okuma. Yıllık $39.99 abonelik bunun üstüne satılıyor.
  Ücretsiz kullanıcı 9 bölüm görüyor, premium sadece **6 bölüm** daha açıyor.
  → OpenAI ile üretim: `.env` hazır (`OPENAI_API_KEY`). Hedef: 900–1200 kelime/bölüm, 6 bölüm/hikâye.
- **İçerik tek dilde** — Bundle'daki her kayıt `language_code: "en"`. UI 15 dil, içerik 1 dil.
  `filteredCivilizations` sessizce İngilizce'ye düşüyor.
- **Analytics gerçekten boş** — `AnalyticsManager` sadece `print()`; Facebook/TikTok/Mixpanel üçü de `// TODO`.
  Onboarding → paywall → purchase funnel kör. Paid acquisition öncesi şart.
- **Okuma süresi ölçümü yalan** — `markAsRead()` `onAppear`'da anında tetikleniyor ve gerçek süre yerine
  `chapter.duration`'ı ekliyor. Bölümü açıp kapatmak streak'i artırıyor. Analytics'e `reading_time_seconds: 0` gidiyor.
- **`UIBackgroundModes: audio` yok** — TTS ekran kilitlenince duruyor. "Listen mode" için önce bu +
  `MPNowPlayingInfoCenter` gerekiyor.
- **TTS sesleri sadece İngilizce** — `VoiceType` 4 sabit `en-US`/`en-GB` sesi. Çok dilli içerik gelince
  yanlış dilde okuyacak. Ayrıca ses seçici ekran hiç yok (`voiceSelectorOpened` event'i var, ekranı yok).
- **Koleksiyonlar sahte** — "Epic Battles" / "Myth & Legend" / "Great Leaders" başlıkları alfabetik
  ilk 3 / orta 3 / son 3 hikâyeye atanıyor (`ContentLoader.collections`). Başlıklar da lokalize değil.
- **`stories.json` fallback'i boş** — Bundle decode hata verirse fallback de boş, kullanıcı direkt error ekranı görür.
- **Test yok** — Boş bir `example()`. En azından `parseYear` ("27 BC"→-27), `getDailyChapter` determinizmi,
  bundle decode testi. `parseYear` lokalize string gelirse sessizce 0 döner.

## 🟡 P2 — okuma deneyimi & retention

- **Reader'da tipografi ayarı yok** — font boyutu / sepia-açık tema / satır aralığı yok.
  Tüm fontlar sabit `.system(size:)` → Dynamic Type desteklenmiyor, VoiceOver etiketi yok.
- **Scroll pozisyonu kaydedilmiyor** — uzun bölümde çıkıp girince başa dönüyor.
- **Continue Reading card** — `lastReadDate` var ama `lastReadChapterId` yok. ProfileManager'a tek alan
  eklemek yeter, en ucuz retention işi.
- **Reading reminder (local push)** — `UNUserNotificationCenter` hiç yok, izin akışı sıfırdan.
- **Home Screen Widget: Daily Story** — Widget target yok; yeni target + App Group + bundle paylaşımı gerekli.
- **AI "Ask the Historian"** — Bölüm sonunda kısa Q&A.
- **Family Sharing / bir hafta hediye et** — Viral / referral.
- **Landscape layout** — iPhone/iPad'de landscape açık ama layout portrait'e göre
  (`geometry.size.height - 80` gibi sabitler).

## ✅ Yapıldı (2026-08-18)

- **Paywall deliği kapatıldı** — `ChapterReaderView`'daki Next/Previous Chapter butonlarında hiç premium
  kontrolü yoktu; ücretsiz kullanıcı bölüm 1'den başlayıp tüm kilitli bölümleri okuyabiliyordu.
  Artık liste ekranlarıyla aynı kural (`orderNo > 1 && !isPremium`) + kilit ikonu + paywall.
- **Lokalizasyon 15 dilde senkronlandı** —
  `home.daily_story` hiçbir dosyada yoktu (her dilde ham anahtar görünüyordu);
  `home.collections` + `reading_path.*` sadece en/tr'de vardı (13 dilde ham anahtar);
  ölü Almanca anahtarlar (`tab.startseite`/`tab.erkunden`/`tab.profil`) ve duplikeler temizlendi.
- **Sabit metinler lokalize edildi** — Home'daki Türkçe hardcode ("Kişisel Okuma Yolu"), reader'daki
  Share Quote / Previous / Next / Back / Chapter N, Free Today, Premium rozeti,
  "Explore Ancient Civilizations", "%d chapters", "stories", "Skip".
- **Deployment target 26.0 → 17.0** — app sadece iOS 26 cihazlara yüklenebiliyordu.
- **Premium durumu artık bayatlamıyor** — `customerInfoStream` ile canlı takip +
  foreground'a dönüşte `checkPremiumStatus()`. Önce sadece launch'ta bir kez bakılıyordu.
- **`ITSAppUsesNonExemptEncryption = NO`** — her yüklemedeki export compliance sorusu kalktı.
- **Sürüm numarası** Settings'te hardcode `"1.0.0"` idi → `CFBundleShortVersionString` + build no.
- **Ölü kod silindi** — `AppCoordinator.swift` (hiç kullanılmıyordu, ikinci bir RevenueCat key kopyası
  içeriyordu), `ProfileManager.canAccessContent()` (hiç çağrılmıyordu).
- **`.env` / `.env.example`** eklendi, `.gitignore`'a girdi.

## Daha önce düzeltilmişti

- Profile / read progress launch'ta yükleniyor
- Paywall'daki RevenueCat race yumuşatıldı
- Collections her render'da yeniden karılmıyor
- Daily Story sadece ücretsiz (order 1) bölümleri seçiyor
- Boş içerik → sonsuz loading yerine error + retry
- Reader'da `AVSpeechSynthesizer` ile temel TTS
- Explore harita zoom + boş time-travel guard
- Medeniyetler gerçek `startYear`'a göre sıralı
