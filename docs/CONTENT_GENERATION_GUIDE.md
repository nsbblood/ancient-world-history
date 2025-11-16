# Content Generation Guide

Bu kılavuz, Ancient World Stories uygulaması için otomatik hikaye ve bölüm üretimi hakkında bilgi içerir.

## Genel Bakış

`generate_content.py` scripti, Google Gemini AI kullanarak tüm medeniyetler için otomatik olarak hikayeler ve bölümler üretir ve bunları Supabase veritabanına kaydeder.

## Özellikler

- ✅ 50 medeniyet için otomatik hikaye üretimi
- ✅ Her hikaye için 10-12 bölüm üretimi
- ✅ Her bölüm 35-40 saniye sürecek şekilde optimize edilmiş (100-120 kelime)
- ✅ İlerleme takibi (progress tracking)
- ✅ Hata durumunda kaldığı yerden devam etme (resume capability)
- ✅ API rate limiting (dakikada 15 istek)
- ✅ Çok dilli destek
- ✅ Detaylı loglama

## Kurulum

### 1. Gerekli Paketleri Yükleyin

```bash
pip install -r requirements.txt
```

### 2. Yapılandırma

Script aşağıdaki bilgileri otomatik olarak kullanır:
- **Supabase URL**: Configuration.swift dosyasından alınır
- **Supabase Anon Key**: Configuration.swift dosyasından alınır
- **Google Gemini API Key**: Script içinde tanımlanmış

## Kullanım

### Temel Kullanım

Tüm medeniyetler için 3 hikaye ve her hikaye için 10 bölüm üret:

```bash
python generate_content.py
```

### Gelişmiş Kullanım

#### 1. Medeniyet başına hikaye sayısını özelleştir

```bash
python generate_content.py --stories-per-civ 5
```

#### 2. Hikaye başına bölüm sayısını özelleştir

```bash
python generate_content.py --chapters-per-story 12
```

#### 3. Belirli bir medeniyet için üret

```bash
python generate_content.py --civilization "Ancient Egypt"
```

#### 4. Farklı dilde üret

```bash
python generate_content.py --language tr
```

#### 5. Tamamlanan medeniyetleri atla (kaldığı yerden devam et)

```bash
python generate_content.py --skip-completed
```

#### 6. Tüm parametreleri birlikte kullan

```bash
python generate_content.py \
  --language en \
  --stories-per-civ 5 \
  --chapters-per-story 12 \
  --skip-completed
```

## Parametreler

| Parametre | Varsayılan | Açıklama |
|-----------|------------|----------|
| `--language` | `en` | Dil kodu (en, tr, es, vb.) |
| `--stories-per-civ` | `3` | Medeniyet başına hikaye sayısı |
| `--chapters-per-story` | `10` | Hikaye başına bölüm sayısı |
| `--skip-completed` | `False` | Tamamlanan medeniyetleri atla |
| `--civilization` | `None` | Sadece belirli bir medeniyeti işle |

## İlerleme Takibi

Script, ilerlemeyi `generation_progress.json` dosyasında saklar. Bu dosya şunları içerir:

```json
{
  "completed_civilizations": ["uuid1", "uuid2"],
  "current_civilization": "uuid3",
  "completed_stories": {
    "uuid1": ["story-uuid1", "story-uuid2"]
  },
  "total_stories_generated": 15,
  "total_chapters_generated": 150,
  "last_updated": "2025-11-13T23:50:00"
}
```

## Loglama

Tüm aktiviteler iki yere loglanır:
1. **Console**: Gerçek zamanlı çıktı
2. **content_generation.log**: Detaylı log dosyası

## İçerik Yapısı

### Hikaye Yapısı (Story)

Her hikaye şunları içerir:
- **Title**: Çekici ve merak uyandıran başlık
- **Summary**: 2-3 cümlelik özet
- **Chapters Count**: Bölüm sayısı
- **Language Code**: Dil kodu

### Bölüm Yapısı (Chapter)

Her bölüm şunları içerir:
- **Title**: Bölüm başlığı
- **Order No**: Sıra numarası (1, 2, 3...)
- **Text**: 100-120 kelimelik metin
- **Duration**: Süre (saniye olarak, 35-40 saniye arası)
- **Language Code**: Dil kodu

## AI Prompt Stratejisi

### Hikaye Üretimi

Script, her medeniyet için şunları dikkate alır:
- Medeniyetin dönemi (era_start - era_end)
- Bölge (region)
- Açıklama (description)
- Farklı temalar: günlük yaşam, savaş, din, ticaret, yenilikler

### Bölüm Üretimi

Her bölüm için:
- 100-120 kelime uzunluğunda (35-40 saniye)
- İlgi çekici ve anlatıyı ilerletici
- Canlı betimlemeler, diyaloglar ve aksiyon
- Tarihi doğruluk + eğlence dengesi
- Her bölüm sonunda devam ettirici bir hook

## Performans ve Maliyet

### API Rate Limiting

- Dakikada 15 istek (Google Gemini free tier)
- Otomatik rate limiting ve bekleme
- Hata durumunda yeniden deneme

### Tahmini Süre

50 medeniyet × 3 hikaye × 10 bölüm = 1500 AI isteği

Rate limit ile: ~100 dakika (1.5-2 saat)

### Maliyet Tahmini

Google Gemini API (free tier):
- Günlük limit: 1500 istek
- Aylık limit: Genelde yeterli

**Önemli**: Büyük ölçekli üretim için API limitlerini kontrol edin.

## Hata Yönetimi

### Fallback Mekanizması

AI başarısız olursa, script otomatik olarak şablon içerik üretir:
- Genel hikaye şablonları
- Genel bölüm metinleri

### Resume Özelliği

Hata durumunda:
1. Script duracaktır
2. İlerleme `generation_progress.json` dosyasında saklanır
3. `--skip-completed` parametresi ile kaldığı yerden devam eder

```bash
python generate_content.py --skip-completed
```

## Örnek Çalışma Akışı

### Senaryo 1: İlk Kez Çalıştırma

```bash
# 1. Paketleri yükle
pip install -r requirements.txt

# 2. İlk 10 medeniyet için test et
python generate_content.py --stories-per-civ 2 --chapters-per-story 5

# 3. Supabase'de kontrol et

# 4. Her şey OK ise tüm medeniyetler için çalıştır
python generate_content.py --stories-per-civ 3 --chapters-per-story 10
```

### Senaryo 2: Belirli Bir Medeniyet İçin

```bash
# Sadece Ancient Egypt için 5 hikaye üret
python generate_content.py \
  --civilization "Ancient Egypt" \
  --stories-per-civ 5 \
  --chapters-per-story 12
```

### Senaryo 3: Türkçe İçerik Üretimi

```bash
# Tüm medeniyetler için Türkçe içerik
python generate_content.py --language tr
```

### Senaryo 4: Hata Sonrası Devam

```bash
# Script bir hata ile durdu, kaldığı yerden devam et
python generate_content.py --skip-completed
```

## Veritabanı Yapısı

### civilizations tablosu
```sql
id: UUID
name: TEXT
era_start: TEXT
era_end: TEXT
region: TEXT
description: TEXT
created_at: TIMESTAMP
```

### stories tablosu
```sql
id: UUID
civilization_id: UUID (FK -> civilizations.id)
title: TEXT
summary: TEXT
chapters_count: INT
language_code: TEXT
created_at: TIMESTAMP
```

### chapters tablosu
```sql
id: UUID
story_id: UUID (FK -> stories.id)
title: TEXT
order_no: INT
text: TEXT
duration: INT (seconds)
language_code: TEXT
audio_url: TEXT (nullable)
created_at: TIMESTAMP
```

## Troubleshooting

### Problem: "No civilizations found in database"

**Çözüm**: Supabase'de civilizations tablosunda veri olduğundan emin olun.

```sql
SELECT COUNT(*) FROM civilizations;
```

### Problem: API rate limit hatası

**Çözüm**: Script otomatik olarak bekler, ancak manuel kontrol için:

```bash
# Daha az hikaye ile başla
python generate_content.py --stories-per-civ 1
```

### Problem: JSON parse hatası

**Çözüm**: AI bazen yanlış format döndürür, fallback mekanizması devreye girer. Logları kontrol edin:

```bash
tail -f content_generation.log
```

### Problem: Supabase bağlantı hatası

**Çözüm**: Credentials'ları kontrol edin:

```bash
# Supabase connection test
python -c "from supabase import create_client; \
client = create_client('URL', 'KEY'); \
print(client.table('civilizations').select('id').limit(1).execute())"
```

## Gelecek İyileştirmeler

- [ ] Otomatik çeviri desteği
- [ ] Görsel üretimi (DALL-E integration)
- [ ] Ses üretimi (TTS integration)
- [ ] Batch processing optimization
- [ ] Daha gelişmiş prompt engineering
- [ ] A/B testing için multiple versions

## Destek

Sorular veya sorunlar için:
- Log dosyasını kontrol edin: `content_generation.log`
- Progress dosyasını kontrol edin: `generation_progress.json`
- Supabase dashboard'dan verileri kontrol edin

## Lisans

Bu script, Ancient World Stories uygulaması için özel olarak geliştirilmiştir.
