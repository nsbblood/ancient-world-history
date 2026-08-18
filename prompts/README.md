# İçerik Üretim Hattı

Ancient World Stories için hikâye üretim promptları. Sırayla çalışır; her adım bir
öncekinin doğrulanmış çıktısını alır.

```
01 katalog planlayıcı        → tüm katalog iskeleti + çeşitlilik denetimi   (1 çağrı)
        ↓
02 hikâye incili             → 6 bölümlük yay, kadro, gerçek/kurgu defteri  (hikâye başına 1)
        ↓
03 bölüm yazarı              → 900-1200 kelime nesir                        (bölüm başına 1)
        ↓
04 QA / düşmanca inceleme    → pass / revise / reject                       (bölüm başına 1, AYRI çağrı)
        ↓  (revise → 03'e geri dön, en fazla 2 tur)
05 çevirmen                  → hedef dil                                    (bölüm × dil)
```

`00-SPEC.md` prompt değil — **her çağrının başına aynen eklenir.** Şema, TTS kuralları,
kanonik isim listeleri ve uygulamanın metni nasıl gösterdiği orada.

---

## Modelin uydurmayacağı alanlar — script hesaplar

Bunları prompt'a bırakma, deterministik üret:

| Alan | Nasıl |
|---|---|
| `id` (3 seviyede) | `uuid4()` |
| `duration` | `round(kelime_sayısı / 155 * 60)` — saniye |
| `chapters_count` | gerçek bölüm sayısı |
| `order_no` | döngü indeksi, 1'den |
| `language_code` | üretim parametresi |

`.env`'den okunur: `OPENAI_API_KEY`, `OPENAI_MODEL`, `CHAPTERS_PER_STORY`,
`WORDS_PER_CHAPTER`, `CONTENT_LANGUAGES`.

---

## Neden 4 ayrı adım

**Neden plan önce (01):** 60 hikâye tek tek üretilirse hepsi "genç çırak ustanın sırrını
keşfeder" olur — mevcut 9 hikâyenin ikisi zaten bu. Çeşitlilik yazım anında değil, plan
anında zorlanır.

**Neden hikâye incili (02):** 6 bölüm ayrı çağrılarda üretilir. Ortak bir belge olmazsa
karakterin adı 3. bölümde, yaşı 5. bölümde kayar.

**Neden QA ayrı çağrı (04):** Kendi yazdığını aynı çağrıda denetleyen model kendi
hatasını görmez. Ayrı geçiş, düşmanca rol.

**Neden çeviri en son (05):** Hatalı bir bölümü 14 dile kopyalamak hatayı 14'e katlar.

---

## Ölçek ve maliyet

Bölüm ≈ 1000 kelime ≈ 1.400 token çıktı. 02+03+04 birlikte bölüm başına kabaca
**6–8k token** (girdi bağlamı dahil).

| Faz | Kapsam | Bölüm | Yaklaşık çıktı |
|---|---|---|---|
| Faz 1 | 12 medeniyet × 2 hikâye | 144 | ~150k kelime |
| Faz 2 | +8 medeniyet × 2 hikâye | +96 | ~100k kelime |
| Faz 3 | ilk 3 dile çeviri | ×3 | — |

Faz 1 bile mevcut içeriğin **45 katı** (şu an 15 bölüm / ~3.3k kelime). Önce **tek bir
hikâyeyi** uçtan uca geçir (01 → 05), tonu beğen, sonra ölçekle.

---

## Kabul kriteri

Bir bölüm ancak şunların hepsi doğruysa bundle'a girer:

- [ ] 04 verdict = `pass`
- [ ] kelime sayısı 900–1200 (script sayar, modele güvenme)
- [ ] `quote` metnin içinde birebir geçiyor, ≤200 karakter
- [ ] ilk 25 kelime bağlamsız kart olarak duruyor
- [ ] bölüm 1 çözülmemiş soruyla bitiyor
- [ ] TTS taraması temiz: `c.` `ca.` `BCE` `(` `*` `#` `- ` yok, uzun tire ≤3
- [ ] `name` 52 kanonik medeniyet isminden biri (birebir)
- [ ] `region` 8 kanonik bölgeden biri
- [ ] `era_start`/`era_end` `"<tamsayı> BC|AD"` formatında
- [ ] JSON şeması snake_case ve tam

Son üçü **build'i bozmaz ama içeriği görünmez/yanlış yapar** — harita pini Ortadoğu'ya
düşer, zaman çizelgesi 0 yılına gider, medeniyet dil filtresine takılır. Script bunları
bundle'a yazmadan önce doğrulamalı.

---

## Mevcut içerikle ne yapılacak

15 eski bölüm (~200 kelime) yeni hedefin (900-1200) çok altında ve `duration` alanları
yanlış (229 kelimeye 450 saniye = dakikada 30 kelime).

Öneri: eski bölümleri **silmeyin**, yeni hikâyelerin yanında bırakın ama
`duration` alanlarını doğru formülle yeniden hesaplayın. Faz 1 bittiğinde eski 9 hikâye
katalogun %10'undan azı olur; o noktada ya 6 bölüme genişletilir ya çıkarılır.

Ayrıca yayındaki **"The Royal Road"** bölümünde gerçek bir tarih hatası var
(Pheidippides Pers kraliyet habercisi olarak yazılmış — Atinalı bir koşucuydu).
`00-SPEC.md` ve `04-qa-reviewer.md` bunu kalibrasyon örneği olarak kullanıyor.
