# ⚡ Supabase Hızlı Başlangıç

## Bana Şunları Verin, Gerisini Ben Hallederim! 🚀

---

## ✅ Seçenek 1: Hızlı Kurulum (Önerilen)

Eğer Supabase hesabınız VARSA:

### Bana Gereken Bilgiler:

1. **Project URL**
   ```
   https://xxxxxxxxxxxx.supabase.co
   ```

2. **Anon Key** (public key)
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey...
   ```

**Nereden bulunur:**
- Supabase Dashboard → Settings → API

**Bu bilgileri verirseniz:**
- ✅ Xcode'a otomatik eklerim
- ✅ Test ederim
- ✅ Çalışır halde teslim ederim

---

## 🆕 Seçenek 2: Sıfırdan Kurulum

Eğer Supabase hesabınız YOKSA:

### Adım 1: Hesap Oluşturun
1. https://supabase.com
2. "Start your project" → GitHub ile giriş
3. Email onaylayın

### Adım 2: Proje Oluşturun
1. Dashboard → "New Project"
2. Name: `ancient-world-stories`
3. Database Password: **Güçlü şifre seçin** (kaydedin!)
4. Region: Size en yakın
5. "Create new project" tıklayın
6. 2 dakika bekleyin

### Adım 3: SQL Çalıştırın

1. Sol menü → **SQL Editor**
2. "New query" tıklayın
3. **`import_all_data.sql`** dosyasının içeriğini yapıştırın
   - (Proje klasöründe bulabilirsiniz)
4. **"Run"** butonuna basın
5. Başarı mesajı göreceksiniz!

### Adım 4: API Anahtarlarını Bana Verin

1. Settings → API
2. Şunları kopyalayın:
   - **Project URL**
   - **anon public key**

Bana gönderin, Xcode'a eklerim!

---

## 📁 Hazırladığım Dosyalar

Proje klasöründe şunları bulacaksınız:

1. **`import_all_data.sql`**
   - 3 civilization
   - 3 story
   - 30 chapter
   - Hepsi tek SQL dosyasında!

2. **`SUPABASE_SETUP_GUIDE.md`**
   - Detaylı adım adım rehber
   - Ekran görüntülü anlatım
   - Sorun giderme

---

## ⏱️ Ne Kadar Sürer?

### Hesap VARSA:
- Bilgileri verirsiniz: **2 dakika**
- Ben Xcode'a eklerim: **1 dakika**
- **Toplam: 3 dakika**

### Hesap YOKSA:
- Hesap oluşturma: **5 dakika**
- Proje kurulum: **3 dakika**
- SQL çalıştırma: **2 dakika**
- API anahtarları verme: **2 dakika**
- **Toplam: 12 dakika**

---

## 🎯 Sonuç

Backend hazır olunca:
- ✅ App Supabase'den veri çekecek
- ✅ Offline mod hala çalışacak (fallback)
- ✅ 3 civilization, 3 story, 30 chapter
- ✅ Gelecekte kolayca içerik eklenebilir
- ✅ Ücretsiz tier (500MB + 1GB bandwidth)

---

## 💬 Şimdi Ne Yapmalısınız?

### Seçenek A: Bilgilerim Hazır!
```
Bana şunları gönderin:
1. Project URL
2. Anon Key
```

### Seçenek B: Hesap Kuracağım
```
1. SUPABASE_SETUP_GUIDE.md'yi açın
2. Adımları takip edin
3. SQL dosyasını çalıştırın
4. API anahtarlarını bana gönderin
```

### Seçenek C: Şimdilik Lokal Kalacağım
```
Tamam! App zaten stories.json ile çalışıyor.
İstediğiniz zaman Supabase ekleyebiliriz.
```

---

## 🔐 Güvenlik

- Anon key **public**, sorun yok
- Service role key **ASLA** paylaşmayın
- GitHub'a API anahtarları push etmeyin
- Production'da environment variables kullanın

---

**Hangi seçeneği tercih ediyorsunuz?**
