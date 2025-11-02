# Supabase Backend Kurulum Rehberi

## 🎯 Genel Bakış

Bu rehber Supabase'de backend'i sıfırdan kurmanız için adım adım talimatlar içerir.

---

## 📝 Adım 1: Supabase Hesabı Oluşturma

1. **https://supabase.com** adresine gidin
2. **"Start your project"** butonuna tıklayın
3. GitHub hesabınızla giriş yapın (veya email ile kayıt olun)
4. Email onayı yapın

---

## 🏗️ Adım 2: Yeni Proje Oluşturma

1. Dashboard'da **"New Project"** butonuna tıklayın
2. Bir **Organization** seçin (yoksa yeni oluşturun)
3. Proje ayarları:
   - **Name:** `ancient-world-stories`
   - **Database Password:** Güçlü bir şifre belirleyin (kaydedin!)
   - **Region:** Size en yakın bölge (örn: `Europe (Frankfurt)` veya `US East`)
   - **Pricing Plan:** Free tier (başlangıç için yeterli)
4. **"Create new project"** butonuna tıklayın
5. Proje hazırlanırken bekleyin (~2 dakika)

---

## 🗄️ Adım 3: Veritabanı Tablolarını Oluşturma

### 3.1 SQL Editor'ü Açın

1. Sol menüden **SQL Editor** seçin
2. **"New query"** butonuna tıklayın

### 3.2 Civilizations Tablosu

Aşağıdaki SQL'i yapıştırıp **Run** butonuna basın:

```sql
-- Civilizations Table
CREATE TABLE civilizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    era_start TEXT NOT NULL,
    era_end TEXT NOT NULL,
    region TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_civilizations_name ON civilizations(name);
CREATE INDEX idx_civilizations_region ON civilizations(region);

-- Enable Row Level Security
ALTER TABLE civilizations ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access" ON civilizations
    FOR SELECT USING (true);
```

### 3.3 Stories Tablosu

Yeni bir query açıp şunu çalıştırın:

```sql
-- Stories Table
CREATE TABLE stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    civilization_id UUID NOT NULL REFERENCES civilizations(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    summary TEXT NOT NULL,
    chapters_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_stories_civilization_id ON stories(civilization_id);
CREATE INDEX idx_stories_title ON stories(title);

-- Enable Row Level Security
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access" ON stories
    FOR SELECT USING (true);
```

### 3.4 Chapters Tablosu

Yeni bir query açıp şunu çalıştırın:

```sql
-- Chapters Table
CREATE TABLE chapters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    order_no INTEGER NOT NULL,
    text TEXT NOT NULL,
    duration INTEGER NOT NULL, -- in seconds
    language_code TEXT DEFAULT 'en-US',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(story_id, order_no)
);

-- Create indexes
CREATE INDEX idx_chapters_story_id ON chapters(story_id);
CREATE INDEX idx_chapters_order ON chapters(story_id, order_no);

-- Enable Row Level Security
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read access" ON chapters
    FOR SELECT USING (true);
```

✅ **Kontrol:** Table Editor'e gidin, `civilizations`, `stories`, `chapters` tablolarını görmelisiniz.

---

## 📊 Adım 4: Örnek Veri Ekleme

### 4.1 Civilizations

```sql
INSERT INTO civilizations (id, name, era_start, era_end, region, description) VALUES
('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Ancient Mesopotamia', '3500 BC', '539 BC', 'Middle East', 'The cradle of civilization, home to the Sumerians, Akkadians, Babylonians, and Assyrians.'),
('550e8400-e29b-41d4-a716-446655440000', 'Ancient Egypt', '3100 BC', '30 BC', 'North Africa', 'Land of the pharaohs, pyramids, and hieroglyphs.'),
('6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'Ancient Greece', '800 BC', '146 BC', 'Mediterranean', 'Birthplace of democracy, philosophy, and Olympic games.');
```

### 4.2 Stories

```sql
INSERT INTO stories (id, civilization_id, title, summary, chapters_count) VALUES
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', 'The Scribe of Uruk', 'A young scribe discovers ancient texts that could change the course of history.', 12),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', '550e8400-e29b-41d4-a716-446655440000', 'Pharaoh''s Dream', 'A royal architect navigates palace intrigue while building monuments to the gods.', 10),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', '6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'The Oracle''s Vision', 'A priestess receives visions that challenge everything she believes.', 8);
```

### 4.3 Chapters (Örnek - 3 bölüm)

```sql
INSERT INTO chapters (story_id, title, order_no, text, duration, language_code) VALUES
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The First Lesson', 1, 'The morning sun painted the ziggurat in hues of amber and gold. Young Nammu clutched his clay tablet, fingers trembling with anticipation. Today, he would learn his first cuneiform signs from Master Enki, the most renowned scribe in all of Uruk.', 45, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The Sacred Signs', 2, 'Master Enki''s weathered hands moved with practiced grace across the wet clay. Each mark tells a story, he explained. The wedge is not merely a line—it is the voice of the gods made visible.', 50, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'Temple Secrets', 3, 'The temple library was forbidden to novice scribes, yet here Nammu stood at midnight. Master Enki had given him a key and a warning: Some knowledge changes those who find it.', 48, 'en-US');
```

**Not:** stories.json'daki tüm 30 bölümü eklemek için dosya hazırladım (aşağıda).

---

## 🔑 Adım 5: API Anahtarlarını Alma

1. Sol menüden **Settings** → **API** seçin
2. Şu bilgileri kopyalayın:

### Project URL
```
https://xxxxxxxxxxxx.supabase.co
```

### Anon Key (public)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eHh4eHh4eHh4eCIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjc4ODg4ODg4LCJleHAiOjE5OTQ0NjQ4ODh9.xxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 📱 Adım 6: Xcode'a API Anahtarlarını Ekleme

### Yöntem 1: Info.plist (Önerilen)

1. Xcode'da projeyi açın
2. `Info.plist` dosyasına sağ tıklayın → **Open As** → **Source Code**
3. `</dict>` kapanış etiketinden önce ekleyin:

```xml
<key>SUPABASE_URL</key>
<string>https://xxxxxxxxxxxx.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...</string>
```

### Yöntem 2: Environment Variables

1. Xcode'da **Product** → **Scheme** → **Edit Scheme**
2. **Run** → **Arguments** sekmesi
3. **Environment Variables** altına ekleyin:
   - `SUPABASE_URL` = `https://xxxxxxxxxxxx.supabase.co`
   - `SUPABASE_ANON_KEY` = `eyJhbGci...`

---

## ✅ Adım 7: Test Etme

1. Xcode'da **⌘R** ile uygulamayı çalıştırın
2. Console'da şu mesajı görmeli:
   ```
   ✅ Successfully loaded X civilizations, Y stories, Z chapters from Supabase
   ```
3. Eğer hata alırsanız:
   ```
   ⚠️ Supabase failed, loading from local JSON
   ```
   - API anahtarlarını kontrol edin
   - Supabase Dashboard'da Tables'ı kontrol edin

---

## 📊 Veri Import Scripti (Tüm 30 Bölüm)

Bütün chapters'ları eklemek için bu SQL dosyasını kullanın:

**File: `import_all_chapters.sql`** (proje klasöründe oluşturuldu)

Supabase SQL Editor'de bu dosyayı çalıştırın.

---

## 🔒 Güvenlik Notları

### RLS (Row Level Security) Aktif
- Sadece okuma izni var (SELECT)
- Veri ekleme/silme için service_role key gerekli
- Şu an public read-only, üretim için yeterli

### Gelecekte Eklenebilir
- User authentication (Supabase Auth)
- User-specific favorites (RLS policies)
- Admin panel (service_role ile)

---

## 💰 Ücretsiz Tier Limitleri

Supabase Free Plan:
- ✅ 500 MB veritabanı
- ✅ 1 GB bandwidth/ay
- ✅ 50,000 monthly active users
- ✅ Row Level Security
- ✅ Otomatik backups (7 gün)

**Bu uygulama için yeterli!** (30 chapter ≈ 50KB)

---

## 🆘 Sorun Giderme

### "Failed to decode local JSON"
- stories.json'ı kontrol edin
- Geçerli JSON formatında mı?

### "Supabase connection failed"
- Internet bağlantısı var mı?
- API anahtarları doğru mu?
- Supabase projesi aktif mi?

### "No data returned"
- SQL Editor'de `SELECT * FROM civilizations;` çalıştırın
- Veri eklenmiş mi kontrol edin

### Tablolar görünmüyor
- SQL sorgularını tekrar çalıştırın
- Dashboard → Table Editor'e bakın

---

## 📞 Yardım

Sorun yaşarsanız:
1. Supabase Dashboard → Logs → Database bölümüne bakın
2. Xcode Console'da hata mesajlarını okuyun
3. SQL Editor'de manuel sorgu çalıştırıp test edin

---

**Tebrikler! Backend hazır! 🎉**

Artık uygulamanız cloud'dan veri çekiyor.
