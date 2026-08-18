# 02 — HİKÂYE İNCİLİ (story bible)

> Bu prompt'un başına `00-SPEC.md` aynen eklenir.

Hikâye başına bir kez çalışır. **Neden gerekli:** 6 bölüm ayrı ayrı üretilirse karakterin
adı, yaşı, mesleği ve olayların sırası bölümler arası kayar. Bu adım o kaymayı önler —
bölüm yazarı sadece bu belgeyi ve bir önceki bölümün özetini görür.

---

## GİRDİ

```
MEDENİYET: {{CIV_NAME}} — {{ERA_START}} → {{ERA_END}}, {{REGION}}
HİKÂYE:    {{TITLE}}
ÖZET:      {{SUMMARY}}
ETİKETLER: arketip={{ARCHETYPE}} bakış={{POV}} ölçek={{SCALE}} ton={{TONE}}
PREMİS:    {{PREMISE}}
ÇIPALAR:   {{HISTORICAL_ANCHORS}}
BÖLÜM 1 KANCASI: {{HOOK}}
```

---

## GÖREV

Bu hikâyenin 6 bölümlük iskeletini kur. **Nesir yazma** — sadece plan.

### Kadro
2–5 kişi. Her biri için: ad (dönem ve dile uygun, telaffuzu kolay — TTS okuyacak), yaş,
rol, ne istiyor, neyden korkuyor, konuşma tarzını ayıran tek bir alışkanlık.

⚠️ İsimler birbirine benzemesin (Nammu / Nanna / Namtar aynı hikâyede olmaz — sesli
dinleyen ayırt edemez). Baş harfleri farklı olsun.

⚠️ Gerçek tarihî kişi kullanıyorsan `real_person: true` işaretle ve o kişiye
**sadece kaynaklarda olan** şeyleri yaptır. İç dünyası ve replikleri kurgulanabilir,
eylemleri kurgulanamaz.

### Altı bölüm yayı

| # | İşlev | Bitiş |
|---|---|---|
| 1 | **Kanca.** Dünya + kahraman + dengeyi bozan şey. Okuyucu buraya bedava giriyor. | Çözülmemiş soru |
| 2 | **İniş.** Kahraman probleme bağlanır, ilk bedeli öder. | Yeni bir maliyet |
| 3 | **Genişleme.** Problem sanılandan büyük. Dünyanın kuralları burada açılır. | Kapsam değişimi |
| 4 | **Dönüş.** Bir açığa çıkma ya da ihanet, o ana kadarki anlamı ters çevirir. | Anlam kayması |
| 5 | **Kriz.** En kötü an. Kahraman iki değerinden birini seçmek zorunda. | Geri dönülmez seçim |
| 6 | **Çözülme + yankı.** Sonuç, sonra bugüne bağlanan kapanış. | Kapanış |

**Bölüm 6 özel kural:** Son paragraf anlatıdan çıkıp bugüne bağlanır — bu hikâyeden
geriye ne kaldı, hangi müzede, hangi harabede, hangi yazıtta. Ders verici olmaz, ama
okuyucuyu "bu gerçekti" duygusuyla bırakır. Bu, ürünün eğitim tarafının teslim edildiği yer.

**Bölüm 1 özel kural:** Tek ücretsiz bölüm ve tüm dönüşümü taşıyor. Kurulum yapmakla
vakit kaybetmez — dengeyi bozan olay bölümün ilk üçte birinde gerçekleşir.

### Her bölüm için

- **Ne oluyor** (2-3 cümle)
- **Nerede / ne zaman** (mekân + hikâye içi zaman atlaması)
- **Kim var**
- **Tarihsel çıpa** (en az 1, plandan gelen çıpalar 6 bölüme dağıtılmış olmalı)
- **Duyusal imza** — bu bölümü diğerlerinden ayıran bir koku, ses, doku. Altı bölümde
  altı farklı duyusal dünya olmalı, hepsi "toz ve güneş" olmasın.
- **Alıntı adayı** — bu bölümden çıkacak, tek başına anlamlı, ≤200 karakter cümle
- **Açılış yönü** — ilk 25 kelimenin nereye bakacağı (kart metni olacak, bkz. SPEC §1)

### Gerçek / kurgu defteri
Hikâyenin sonunda iki liste:
- `verified`: kaynaklara dayanan her unsur, tek satır açıklamayla
- `invented`: uydurulan her karakter ve olay + neden döneme aykırı olmadığı

Bu defter hem QA aşamasının kontrol listesi, hem ileride "bu hikâyenin arkasındaki tarih"
özelliği için hazır içerik.

---

## ÇIKTI

Sadece JSON:

```json
{
  "cast": [{"name":"", "age":0, "role":"", "wants":"", "fears":"", "speech_tic":"", "real_person":false}],
  "chapters": [{
    "order_no": 1,
    "title": "2-5 kelime",
    "function": "kanca",
    "what_happens": "",
    "setting": "",
    "time_jump": "önceki bölümden ne kadar sonra",
    "present": ["isim"],
    "historical_anchor": "",
    "sensory_signature": "",
    "quote_candidate": "",
    "opening_direction": "",
    "ends_on": ""
  }],
  "ledger": {
    "verified": [{"claim":"", "basis":""}],
    "invented": [{"element":"", "why_plausible":""}]
  }
}
```
