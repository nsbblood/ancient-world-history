# 00 — CONTENT SPEC (her çağrıya enjekte edilir)

Bu dosya tek başına prompt değil. Aşağıdaki her prompt'un başına **aynen** eklenir.
Buradaki kurallar uygulamanın koduyla birebir eşleşiyor; ihlal edilirse içerik ya
görünmez ya da yanlış görünür.

---

## Ürün nedir

**Ancient World Stories** — antik medeniyetleri, ders kitabı gibi değil, **sinematik
anlatı** olarak veren bir iOS okuma/dinleme uygulaması. Kullanıcı bir medeniyet seçer,
o medeniyetin hikâyelerini bölüm bölüm okur ya da sesli dinler.

Hiyerarşi: **Civilization → Story → Chapter**

İçerik hem *okunur* hem *sesli okunur* (AVSpeechSynthesizer). Hem *doğru* olmalı hem
*sürükleyici*. Kullanıcı bir bölümü bitirdiğinde hem "vay be" demeli hem gerçekten bir
şey öğrenmiş olmalı.

---

## Uygulamanın metni nerede ve nasıl gösterdiği (kritik)

Bunlar kodun gerçek davranışı. Prompt yazarken bunlara göre yazılır.

### 1. İlk 25 kelime = pazarlama metni
`Chapter.excerpt` bölüm metninin **ilk 25 kelimesini** alıp sonuna "..." koyuyor. Bu metin
ana ekrandaki kartlarda ve **Günün Hikâyesi** kartında görünüyor.

→ Açılış cümlesi kendi başına ayakta durmalı. Referansı olmayan zamir olmaz
("O, kapıyı açtı" — kim?). 25. kelimede cümle ortasında kesilse bile anlamlı kalmalı.
Açılış cümlesi bir soru uyandırmalı, sahne kurmalı, isim vermeli.

### 2. Bölüm 1 tek ücretsiz bölüm
Kural kodda sabit: `orderNo == 1` ücretsiz, gerisi premium. Bölüm 1 aynı zamanda
**Günün Hikâyesi** olarak seçilen havuz. Yani bölüm 1 tüm satın alma dönüşümünü tek
başına taşıyor.

→ Bölüm 1 çözülmemiş bir soruyla bitmeli. Okuyucu "sonra ne oldu" demeden bırakmamalı.
Ama ucuz cliffhanger değil — bir karar anı, bir açığa çıkma, bir tehdit.

### 3. Alıntı kartı
Kullanıcı bölümden bir görsel alıntı kartı üretip paylaşabiliyor.

→ Her bölümde bağlamdan koparıldığında bile anlamlı, **≤ 200 karakter** tek bir cümle
olmalı. Aforizma değil; sahneden doğan, içinde imge olan bir cümle.

### 4. Sesli okuma (TTS) — metin makineye okutulacak
`AVSpeechSynthesizer` metni **harfi harfine** okur. Aşağıdakiler sesli okumada bozuluyor:

| Yazma | Neden olmaz | Yerine |
|---|---|---|
| `c. 1450 BCE` | "c nokta" diye okur | `yaklaşık 1450 BC` / `about 1450 BC` |
| `(bugünkü Irak)` | parantez duraklama yaratmaz, cümle karışır | virgülle bağla |
| `1.677 mil` | rakam okuması dilden dile bozuk | cümleyi yeniden kur ya da yaz |
| `—` üst üste | nefes ritmi çöker | bölümde en fazla 3 tane |
| `*vurgu*`, `#`, `- madde` | markdown sembollerini okur | düz nesir, madde işareti YOK |
| `"iç içe 'tırnak'"` | JSON'da da kaçış sorunu | tipografik `“ ”` ve `‘ ’` kullan |
| dipnot, kaynakça | okunur | metnin içine doğal cümleyle göm |

→ **Çıktı düz nesirdir.** Başlık yok, madde yok, markdown yok. Sadece paragraflar.
→ Her paragraf 3–6 cümle. Tek cümlelik paragraf sadece vurgu için, bölümde en fazla 2 kez.

### 5. Zaman formatı — parse ediliyor
`Civilization.parseYear` şunu yapıyor: boşluğa böl, ilk parçayı `Int`'e çevir,
metinde "BC" geçiyorsa negatifle. Başarısız olursa **sessizce 0 döner** ve medeniyet
zaman çizelgesinde yanlış yere düşer.

→ `era_start` / `era_end` **kesinlikle** `"<tamsayı> BC"` veya `"<tamsayı> AD"` formatında.
✅ `"3100 BC"`, `"476 AD"`  ❌ `"c. 3100 BC"`, `"MÖ 3100"`, `"3100–2900 BC"`, `"3100 BCE"`

### 6. Medeniyet ismi = harita pini
`Civilization.coordinate` isme göre **sabit bir switch**. Listede olmayan isim
varsayılan olarak (30.0, 35.0) — yani Ortadoğu'da rastgele bir noktaya düşer.

→ `name` alanı aşağıdaki 52 isimden **birebir** biri olmalı (harf harf aynı):

```
Aboriginal Cultures, Achaemenid Empire, Akkadian Empire, Ancient Athens, Ancient China,
Ancient Egypt, Ancient Greece, Ancient Mesopotamia, Ancient Polynesia, Ancient Sparta,
Ancient Thrace, Assyria, Aztec Empire, Babylonia, Byzantine Empire, Carthage,
Celtic Tribes, Etruscan Civilization, Ghana Empire, Gupta Empire, Han Dynasty,
Hittite Empire, Inca Empire, Indus Valley Civilization, Jomon Period, Khmer Empire,
Kingdom of Aksum, Kingdom of Kush, Kingdom of Urartu, Macedonian Empire, Maurya Empire,
Maya Civilization, Minoan Civilization, Moche Civilization, Mycenaean Greece,
Nazca Civilization, Olmec Civilization, Parthian Empire, Persian Empire, Phoenicia,
Qin Dynasty, Rapa Nui, Roman Empire, Scythian Empire, Shang Dynasty, Silk Road Kingdoms,
Silla Kingdom, Sumer, Toltec Civilization, Vikings, Xiongnu Confederation, Zhou Dynasty
```

### 7. Bölge (region) — gruplama anahtarı
Explore ekranı `region` string'ine göre grupluyor. Serbest metin olduğu için tutarsızlık
gruplamayı parçalar. **Sadece bu 8 değer** kullanılır:

```
North Africa | Middle East | Mediterranean | Europe | East Asia | South & Central Asia | Americas | Oceania
```
(Mevcut içerikteki `"Mediterranean & Europe"` ve `"Northern Europe"` bu listeye taşınacak.)

### 8. Süre (duration) — saniye
Kartlarda "7m 30s" diye gösteriliyor ve toplam okuma süresi istatistiğine ekleniyor.

⚠️ Mevcut içerikte bu alan **yanlış**: 229 kelimelik bölüme 450 saniye yazılmış
(dakikada 30 kelime — kimse o hızda okumaz/okuyamaz). Yeni içerikte formül:

```
duration = round(kelime_sayısı / 155 * 60)
```
(155 kelime/dakika ≈ AVSpeechSynthesizer varsayılan hızı. 1000 kelimelik bölüm ≈ 387 sn ≈ 6.5 dk.)

Bu alanı model uydurmaz — **script hesaplar**.

---

## Uzunluk hedefi

| | Mevcut | Hedef |
|---|---|---|
| Bölüm başına kelime | ~200 | **900–1200** |
| Hikâye başına bölüm | 1–3 | **6** |
| Hikâye başına süre | ~5 dk | **~45 dk** |

900'ün altı kısa, 1200'ün üstü tek oturumda ağır. Bu aralığın dışına çıkma.

---

## Tarihsel doğruluk sözleşmesi

Bu bir eğitim-bitişik ürün. Uydurma karakter serbest, uydurma **tarih** değil.

**Her bölüm en az 2 doğrulanabilir çıpaya oturur:** gerçek bir yer, gerçek bir nesne
ya da teknik, gerçek bir uygulama/gelenek, gerçek bir olay ya da tarih.

**Kurgu serbestisi:** isimsiz sıradan insanlar, iç dünyaları, diyalog, günlük detay,
küçük olaylar. Bunlar dönemin bilinen gerçekliğiyle **çelişmemeli**.

**Yasak:** gerçek tarihî kişiye yapmadığı bir şeyi yaptırmak; iki farklı yüzyılın
insanını aynı sahnede buluşturmak; anakronik nesne (yanlış çağda demir, kağıt, at üzengisi,
mısır/patates/domates Eski Dünya'da vb.); modern ahlaki sözlükle konuşturmak.

> **Kalibrasyon örneği — mevcut içerikteki gerçek hata:**
> Yayındaki "The Royal Road" bölümünde **Pheidippides** bir *Pers* kraliyet habercisi
> (angareion) olarak Darius'un mektubunu Sparta'ya taşıyor. Pheidippides Atinalı bir
> koşucudur ve Maraton'la anılır; Pers postasının bir çalışanı değildir. Bu, isim
> tanıdık geldiği için kaçan tam da o hata sınıfı. QA aşaması bunu yakalamalı.
> İsimsiz bir Pers habercisi uydurmak tamamen serbesttir — gerçek bir Yunan'ı Pers
> memuru yapmak değil.

**Belirsizliği sakla, silme.** Tartışmalı bir konuda tek bir kesin anlatı sunma; anlatı
içinde "öyle söylerlerdi", "kimse emin değildi" gibi doğal ifadelerle belirsizliği koru.

---

## JSON şeması (bundle ile birebir)

Üretilen içerik sonunda `stories_bundle.json` içine bu şekilde girer. Alan isimleri
**snake_case** — kod `CodingKeys` ile bunları bekliyor.

```json
{
  "civilizations": [{
    "id": "<UUID v4>",
    "name": "<52 kanonik isimden biri>",
    "era_start": "3100 BC",
    "era_end": "30 BC",
    "region": "<8 kanonik bölgeden biri>",
    "description": "<40-60 kelime, sinematik, ansiklopedi kuru değil>",
    "language_code": "en"
  }],
  "stories": [{
    "id": "<UUID v4>",
    "civilization_id": "<civilization.id>",
    "title": "<3-5 kelime, imgeli>",
    "summary": "<25-40 kelime, spoiler yok, merak uyandırır>",
    "chapters_count": 6,
    "language_code": "en"
  }],
  "chapters": [{
    "id": "<UUID v4>",
    "story_id": "<story.id>",
    "title": "<2-5 kelime>",
    "order_no": 1,
    "text": "<900-1200 kelime düz nesir>",
    "duration": 387,
    "language_code": "en"
  }]
}
```

Sabit kurallar:
- `order_no` 1'den başlar, boşluksuz artar.
- `story.chapters_count` gerçek bölüm sayısıyla eşit olmalı.
- Üç seviyede de `language_code` aynı olmalı — kod bu alana göre filtreliyor.
- `id` alanlarını **script üretir**, model uydurmaz.
