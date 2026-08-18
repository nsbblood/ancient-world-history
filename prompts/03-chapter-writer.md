# 03 — BÖLÜM YAZARI

> Bu prompt'un başına `00-SPEC.md` aynen eklenir.

Bölüm başına bir kez çalışır. Tek işi: **~1050 kelimelik nesir**.

⚠️ **Uzunluk bir öneri değil, sınır.** Hedef 1050 kelime; 1200 kelime **üst sınırdır**,
aşarsan bölüm reddedilir ve yeniden yazdırılır. Deneyimle sabit: bu görevde doğal eğilim
1500 kelimeye taşmak. Bitirdiğinde geri dön ve kırp — tekrar eden cümle yapılarını,
aynı fikri iki kez söyleyen paragrafları, okuyucunun zaten anladığını açıklayan kapanışı at.

---

## GİRDİ

```
MEDENİYET:  {{CIV_NAME}} — {{ERA_START}} → {{ERA_END}}, {{REGION}}
HİKÂYE:     {{TITLE}} — {{SUMMARY}}
TON:        {{TONE}} | BAKIŞ: {{POV}} | ÖLÇEK: {{SCALE}}
KADRO:      {{CAST}}
DEFTER:     {{LEDGER}}

BU BÖLÜM:   {{ORDER_NO}} / 6 — "{{CHAPTER_TITLE}}"
İŞLEV:      {{FUNCTION}}
NE OLUYOR:  {{WHAT_HAPPENS}}
MEKÂN:      {{SETTING}} ({{TIME_JUMP}})
ORADAKİLER: {{PRESENT}}
ÇIPA:       {{HISTORICAL_ANCHOR}}
DUYU İMZASI:{{SENSORY_SIGNATURE}}
ALINTI:     {{QUOTE_CANDIDATE}}
AÇILIŞ YÖNÜ:{{OPENING_DIRECTION}}
BİTİŞ:      {{ENDS_ON}}

ÖNCEKİ BÖLÜMÜN SON PARAGRAFI:
{{PREVIOUS_TAIL}}

ŞİMDİYE KADAR OLANLAR:
{{STORY_SO_FAR}}
```

---

## YAZIM YÖNERGESİ

**Ses.** Üçüncü şahıs sınırlı, geçmiş zaman. Sinematik ama süslü değil. Cümle uzunluğu
değişken — kısa cümle vurgu içindir, arka arkaya üç kısa cümle bağırmak olur.

**Açılış.** İlk cümle sahnenin **içinde** başlar. "Antik Mısır'da hayat zordu" gibi
ısınma cümlesi yok. İlk 25 kelime kart metni olacak (SPEC §1) — isim geçsin, mekân
sezilsin, bir gerilim kurulsun.

**Duyu.** Her bölümün kendi duyusal imzası var. Kokuyu, sesi, dokuyu kullan; görselde
kalma. Klişe malzemeden kaçın: "toz", "altın ışık", "kadim taşlar" bu türün otomatik
üretiminde aşınmış.

**Diyalog.** Metnin en fazla üçte biri. Dönem insanları ne modern argo ne sahte arkaik
("Vallahi efendim, hakikaten öyle" değil) konuşur. Sade, doğrudan, dönemin kendi
kaygılarıyla. Tipografik tırnak: “ ”

**Tarih.** Çıpayı bir *ders* olarak değil bir *eylem* olarak göster. Su kemerinin nasıl
çalıştığını anlatma; birinin onu tamir etmesini yaz. Ansiklopedi paragrafı yasak.

**Anakronizm kontrolü.** Yazarken bu bölümdeki her nesneyi ve kavramı geç: bu çağda bu
metal var mıydı, bu bitki bu kıtada mıydı, bu hayvan evcilleştirilmiş miydi, bu fikir
düşünülebilir miydi.

**Bitiş.** `{{ENDS_ON}}` ne diyorsa oraya var. Bölüm 1 ise: çözülmemiş bir soruyla bırak,
ama sorunun kendisi bölümün içinde kurulmuş olsun — dışarıdan yapıştırılmış tehdit değil.

**Alıntı cümlesi.** `{{QUOTE_CANDIDATE}}` fikrini metnin içine doğal bir cümle olarak
yerleştir. Ayrıca işaretleme, dışarı çıkarma — metnin içinde yaşasın; JSON'da ayrıca
raporlarsın.

---

## SESLİ OKUMA KONTROLÜ

Yazdıktan sonra metni **kendi kendine sesli okunuyormuş gibi** geç. SPEC §4'teki tablo
burada uygulanır: kısaltma yok, parantez yok, markdown yok, madde işareti yok, dipnot yok,
üç taneden fazla uzun tire yok. Bir cümlede takılıyorsan yeniden kur.

---

## ÇIKTI

Sadece JSON. `text` alanı düz nesir, paragraflar `\n\n` ile ayrılır.

```json
{
  "title": "2-5 kelime",
  "text": "900-1200 kelime düz nesir, paragraflar \n\n ile ayrılır",
  "quote": "≤200 karakter, metnin içinden BİREBİR alıntı",
  "anchors_used": ["bu bölümde geçen doğrulanabilir unsurlar"]
}
```

Çıktı vermeden önce kendin kontrol et:
- Kelime sayısı 900–1200 arasında mı? (script sayacak, tolerans yok)
- `quote` metnin içinde **birebir** geçiyor mu? Kopyala-yapıştır yap, yeniden yazma.
- Metnin ilk 25 kelimesi tek başına bir kart olarak duruyor mu? (SPEC §1)
- SPEC §4'teki TTS listesi temiz mi?
