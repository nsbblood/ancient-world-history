# Minimax Neural TTS Setup Guide

Fal AI Minimax Speech 2.6 Turbo modelini Ancient World Stories uygulamasında kullanmak için setup talimatları.

## 🎯 Özellikler

- **Doğal Neural TTS**: 6 farklı karakter sesi (Wise Woman, Deep Voice Man, vb.)
- **Çoklu dil desteği**: 40+ dil (English, Spanish, Arabic, vb.)
- **Hız kontrolü**: 0.5x - 2.0x
- **Premium özellik**: Sadece premium kullanıcılar için
- **Güvenli API**: Supabase Edge Function ile API key sunucuda

---

## 📋 Kurulum Adımları

### 1. Supabase Edge Function Oluştur

```bash
# Supabase CLI ile Edge Function oluştur
cd your-supabase-project
supabase functions new minimax-tts
```

### 2. Edge Function Kodunu Kopyala

`SUPABASE_TTS_SETUP.sql` dosyasındaki Edge Function kodunu kopyala ve `supabase/functions/minimax-tts/index.ts` dosyasına yapıştır.

### 3. Supabase Secret Ekle

```bash
# Fal AI API key'i secret olarak ekle
supabase secrets set FAL_AI_API_KEY="5e273259-94de-4902-b148-902bfbf4571f:df6051fa08db3c6e98bd97dca8585118"
```

### 4. Edge Function'ı Deploy Et

```bash
supabase functions deploy minimax-tts
```

### 5. iOS Uygulamasını Güncelle

`MinimaxTTSService.swift` dosyasındaki placeholder'ları güncelle:

```swift
private let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
```

Bu bilgileri Supabase Dashboard → Settings → API'den alabilirsin.

---

## 🎙️ Kullanım

### TTS Engine Seçimi

```swift
// Sistem TTS (ücretsiz)
AudioManager.shared.setEngine(.system)

// Minimax Neural TTS (premium)
AudioManager.shared.setEngine(.minimax)
```

### Ses Seçimi

```swift
// Minimax sesi seç
AudioManager.shared.setMinimaxVoice(.wiseWoman)
AudioManager.shared.setMinimaxVoice(.deepVoiceMan)
AudioManager.shared.setMinimaxVoice(.calmWoman)
```

### Konuşma

```swift
// Otomatik olarak seçilen engine'i kullanır
AudioManager.shared.speak(text: "Hello from Ancient World!")
```

---

## 🎨 Mevcut Sesler

| Voice ID | Karakter | Açıklama |
|----------|----------|----------|
| `Wise_Woman` | Bilge Kadın | Tecrübeli, sakin anlatıcı |
| `Deep_Voice_Man` | Derin Ses Adam | Güçlü, otoriter anlatıcı |
| `Calm_Woman` | Sakin Kadın | Huzurlu, rahatlatıcı |
| `Casual_Guy` | Rahat Adam | Arkadaşça, günlük |
| `Friendly_Person` | Dost | Sıcak, samimi |
| `Inspirational_girl` | İlham Verici Kız | Enerjik, motive edici |

---

## 🔒 Güvenlik

✅ **API key sunucuda** - Client'ta hiç görünmez
✅ **Supabase Authentication** - RLS ile korunmuş
✅ **CORS koruması** - Sadece izinli domainler
✅ **Rate limiting** - Supabase Edge Function otomatik

---

## 💰 Maliyet

- **Fal AI Minimax**: Pay-per-use model
- **Supabase Edge Function**: 500K istek/ay ücretsiz
- **Öneri**: Premium kullanıcılara özel, kullanım limitli

---

## 🧪 Test

### Edge Function'ı Test Et

```bash
curl -X POST \
  https://YOUR_PROJECT_ID.supabase.co/functions/v1/minimax-tts \
  -H "apikey: YOUR_SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Hello from Ancient World Stories!",
    "voice_id": "Wise_Woman",
    "speed": 1.0,
    "language": "en"
  }'
```

Başarılı response:
```json
{
  "audio_url": "https://fal.ai/files/...",
  "duration_ms": 2500
}
```

---

## 🐛 Troubleshooting

### "Invalid API Key" hatası
- Supabase secret'ının doğru set edildiğinden emin ol
- Edge Function'ı yeniden deploy et

### "Audio download failed"
- Internet bağlantısını kontrol et
- Fal AI API limitlerini kontrol et

### "Premium required" hatası
- Kullanıcının premium subscription'ı olduğundan emin ol
- `ProfileManager.shared.isPremium` değerini kontrol et

---

## 📚 Kaynaklar

- [Fal AI Minimax Docs](https://fal.ai/models/fal-ai/minimax/speech-2.6-turbo/api)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Minimax TTS Demo](https://fal.ai/models/fal-ai/minimax/speech-2.6-turbo)

---

## ✅ Checklist

- [ ] Supabase Edge Function oluşturuldu
- [ ] FAL_AI_API_KEY secret'ı eklendi
- [ ] Edge Function deploy edildi
- [ ] MinimaxTTSService.swift'te URL/KEY güncellendi
- [ ] Premium kullanıcılarla test edildi
- [ ] Ses kalitesi onaylandı
- [ ] Fallback sistem TTS çalışıyor
