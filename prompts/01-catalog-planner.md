# 01 — KATALOG PLANLAYICI

> Bu prompt'un başına `00-SPEC.md` aynen eklenir.

Tek seferde çalışır. Bütün katalogu **önce** planlar, sonra yazım başlar. Amaç: 60 hikâye
yazıldığında hepsinin aynı hikâye olmadığından emin olmak. Çeşitlilik yazım anında değil,
plan anında garanti edilir.

---

## GÖREV

Aşağıdaki parametrelerle bir içerik katalogu planla. Metin **yazma** — sadece iskelet.

```
MEDENİYET SAYISI: {{CIV_COUNT}}
MEDENİYET BAŞINA HİKÂYE: {{STORIES_PER_CIV}}
HİKÂYE BAŞINA BÖLÜM: 6
DİL: {{LANGUAGE}}
ZATEN VAR OLAN (tekrar etme): {{EXISTING_CATALOG}}
```

---

## ÇEŞİTLİLİK EKSENLERİ — zorunlu

Her hikâye dört eksende etiketlenir. Kurallar aşağıda; ihlal edersen plan reddedilir.

### Eksen A — Arketip (12 seçenek)

| # | Arketip | Özü |
|---|---|---|
| A1 | **Keşif / yasak bilgi** | Biri görmemesi gereken şeyi görür |
| A2 | **Kuşatma / son direniş** | Askerî, kaybedileceği bilinen savunma |
| A3 | **Saray entrikası** | Veraset, zehir, sadakat sınavı |
| A4 | **Yolculuk / ticaret yolu** | Kervan, sefer, bilinmeyene gidiş |
| A5 | **Zanaat / çıraklık** | Bir şeyin nasıl yapıldığı: tunç, cam, su kemeri, mumya |
| A6 | **Felaket** | Sel, patlama, veba, çöküş |
| A7 | **İnanç / ritüel** | Rahiplik, kehanet, kurban, tapınak |
| A8 | **Suç ve adalet** | Bir yasa maddesinin uygulanışı, cinayet, mahkeme |
| A9 | **İcat / mühendislik** | Somut bir problemin çözülmesi |
| A10 | **Düşüş** | Bir hükümdarın kibirden çöküşü |
| A11 | **Sıradan hayat** | Fırıncının, askerin karısının, bir çocuğun bir günü |
| A12 | **Temas** | İki kültür karşılaşır; yanlış anlama ve sonuçları |

**Kural:** Aynı medeniyet içinde iki hikâye aynı arketipi kullanamaz.
Katalog genelinde hiçbir arketip toplamın **%15'ini** aşamaz.
A11 ve A12 katalogda en az birer kez geçmeli — en az kullanılan ama en taze olanlar.

### Eksen B — Bakış açısı

`yabancı/yeni gelen` · `alanın ustası` · `çocuk` · `iktidardaki kişi` · `hizmetli/köle` ·
`iki dönüşümlü anlatıcı` · `geriye bakan tarihçi`

**Kural:** Aynı medeniyette tekrar yok. Katalogda `iktidardaki kişi` %25'i aşamaz —
bu ürünün cazibesi sarayda değil, sıradan gözde.

### Eksen C — Ölçek

`mahrem` (tek oda, tek gün) · `kentsel` (bir şehir, bir mevsim) · `destansı` (bir imparatorluk, yıllar)

**Kural:** Her medeniyette en az bir `mahrem` hikâye. Katalogda `destansı` üçte biri aşamaz.

### Eksen D — Duygusal ton

`hayret` · `dehşet` · `yas` · `zafer` · `kuru mizah` · `şefkat` · `huşu`

**Kural:** Aynı medeniyette tekrar yok. `zafer` %20'yi aşamaz.

---

## COĞRAFYA VE ZAMAN DAĞILIMI

- Kanonik 8 bölgenin **en az 6'sı** temsil edilmeli. Akdeniz + Ortadoğu toplamı
  medeniyetlerin yarısını geçemez. (Mevcut katalog buradan kötü durumda: 8 medeniyetin
  5'i Akdeniz/Ortadoğu; Amerika 1, Okyanusya 0, Güney Asya 0.)
- Zaman aralığı MÖ 3000 öncesinden MS 1000 sonrasına yayılmalı; hepsi "klasik çağ"a yığılmasın.
- Az bilinen medeniyetler kataloğun **en az üçte biri** olmalı: Moche, Aksum, Urartu,
  Xiongnu, Jomon, Rapa Nui, Nazca, Silla, Ghana. Bunlar ürünün farklılaştığı yer —
  Roma ve Mısır her uygulamada var.

---

## KAÇINILACAK KLİŞELER

Bunlar bu türde otomatik üretimin sürüklendiği yer. Planda görürsen değiştir:

- "Genç çırak ustanın sırrını keşfeder" — mevcut katalogda zaten iki kez var
- Bilgeliği tek cümlelik aforizmayla konuşan yaşlı akil adam
- Zamanının çok ilerisinde, modern değerlere sahip kadın kahraman (dönemin kendi
  kadınları zaten ilginç — rahibe, tüccar, şifacı, kraliçe naibesi, dokumacı loncası)
- "Kehanet gerçekleşti" kapanışı
- Sonu tarihin bildiği olaya varan geri sayım (Vezüv, Thermopylae) — bir tane yeter,
  katalogda üçüncüsü olmasın
- Anlatının ortasında ders veren ansiklopedi paragrafı

---

## ÇIKTI FORMATI

Sadece JSON. Açıklama, ön söz, markdown bloğu yok.

```json
{
  "civilizations": [
    {
      "name": "Moche Civilization",
      "era_start": "100 AD",
      "era_end": "800 AD",
      "region": "Americas",
      "description": "40-60 kelime",
      "why_this_one": "Kataloga ne katıyor, hangi boşluğu dolduruyor (1 cümle)",
      "stories": [
        {
          "title": "3-5 kelime",
          "summary": "25-40 kelime, spoiler yok",
          "archetype": "A5",
          "pov": "alanın ustası",
          "scale": "mahrem",
          "tone": "huşu",
          "premise": "2-3 cümle: kim, ne istiyor, ne engelliyor",
          "historical_anchors": ["gerçek çıpa 1", "gerçek çıpa 2", "gerçek çıpa 3"],
          "hook_for_chapter_1": "Bölüm 1'in biteceği çözülmemiş soru (1 cümle)"
        }
      ]
    }
  ],
  "diversity_audit": {
    "archetype_counts": {"A1": 2, "A5": 3},
    "pov_counts": {},
    "scale_counts": {},
    "tone_counts": {},
    "region_counts": {},
    "lesser_known_ratio": 0.35,
    "violations": []
  }
}
```

`diversity_audit` kendi planını kendin denetlediğin yer. `violations` boş değilse planı
yayınlamadan önce **kendin düzelt**, sonra tekrar denetle. Boş dizi ile çık.
