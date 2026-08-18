# 05 — ÇEVİRMEN

> Bu prompt'un başına `00-SPEC.md` aynen eklenir.

Uygulamanın arayüzü 15 dilde, içeriği tek dilde. Bu adım içeriği diğer dillere taşır.
İçerik doğrulandıktan (**04 → pass**) sonra çalışır — hatalı içeriği 14 dile kopyalamak
hatayı 14'e katlar.

---

## GİRDİ

```
KAYNAK DİL: {{SOURCE_LANG}}
HEDEF DİL:  {{TARGET_LANG}} ({{TARGET_NAME}})
MEDENİYET:  {{CIV_JSON}}
HİKÂYE:     {{STORY_JSON}}
BÖLÜMLER:   {{CHAPTERS_JSON}}
```

---

## YÖNERGE

**Çeviri değil, yeniden yazım.** Kelime kelime çeviri sesli okumada ölür. Hedef dilde
o dilde yazılmış gibi okunmalı; cümle yapısını hedef dilin ritmine göre kur.

**Değişmeyecekler:**
- `id`, `story_id`, `civilization_id`, `order_no` — birebir aynı
- `name` (medeniyet adı) — **çevirme.** Kanonik 52 isimden biri, kod harita pinini buna
  göre buluyor (SPEC §6). `"Ancient Egypt"` her dilde `"Ancient Egypt"` kalır.
- `region` — **çevirme.** Kanonik 8 değerden biri, gruplama anahtarı (SPEC §7).
- `era_start` / `era_end` — **çevirme.** `parseYear` `"3100 BC"` formatını parse ediyor;
  `"MÖ 3100"` yazarsan sessizce 0 döner (SPEC §5).
- `duration` — aynı kalır (script yeniden hesaplayacak)
- Özel isimler (kişi, yer, tanrı) — hedef dilde yerleşik bir karşılığı varsa onu kullan
  (Marcus Aurelius → Marcus Aurelius; Alexander → İskender), yoksa dokunma.
- `language_code` — hedef dilin kodu olur

**Değişecekler:** `title`, `summary`, `description`, `text`

**Uzunluk:** Hedef dilde ±%15 sapma normal. Ama **ilk 25 kelime kuralı hedef dilde de
geçerli** (SPEC §1) — çeviri sonrası ilk 25 kelime kart olarak tek başına durmalı.
Durmuyorsa açılış cümlesini hedef dile göre yeniden kur.

**TTS:** SPEC §4 hedef dilde de geçerli. Hedef dilin kendi tuzakları var — Almanca'da
bileşik kelime uzunluğu, Japonca'da sayı sayaçları, Arapça'da rakam yönü. Sesli okunduğunda
takılan yeri yeniden kur.

**Alıntı:** `quote` çevrildikten sonra çevrilmiş `text` içinde **birebir** geçmeli.
Önce metni çevir, sonra alıntıyı çevrilmiş metnin içinden **kopyala** — ayrı çevirme.

---

## ÇIKTI

Kaynakla birebir aynı yapıda JSON:

```json
{
  "civilization": {"id":"", "name":"DEĞİŞMEDİ", "era_start":"DEĞİŞMEDİ", "era_end":"DEĞİŞMEDİ",
                   "region":"DEĞİŞMEDİ", "description":"çevrildi", "language_code":"{{TARGET_LANG}}"},
  "story": {"id":"", "civilization_id":"", "title":"çevrildi", "summary":"çevrildi",
            "chapters_count":6, "language_code":"{{TARGET_LANG}}"},
  "chapters": [{"id":"", "story_id":"", "title":"çevrildi", "order_no":1,
                "text":"çevrildi", "duration":0, "language_code":"{{TARGET_LANG}}",
                "quote":"çevrilmiş metinden birebir", "opening_25_words":"çevrilmiş metnin ilk 25 kelimesi"}]
}
```
