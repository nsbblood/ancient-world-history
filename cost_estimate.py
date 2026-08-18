#!/usr/bin/env python3
"""Icerik uretim hattinin maliyet tahmini. Fiyatlar: developers.openai.com/api/docs/pricing"""

PRICE = {  # $ / 1M token
    "gpt-5":        {"in": 1.25, "cached": 0.125, "out": 10.00},
    "gpt-5-mini":   {"in": 0.25, "cached": 0.025, "out":  2.00},
    "gpt-5.4-mini": {"in": 0.75, "cached": 0.075, "out":  4.50},
}

CIVS, STORIES_PER_CIV, CHAPTERS = 12, 2, 6
STORIES  = CIVS * STORIES_PER_CIV
CHAPTERS_TOTAL = STORIES * CHAPTERS
REVISE = 1.3          # QA'den donup yeniden yazilanlar
SPEC_TOKENS = 1800    # her cagrinin basina eklenen 00-SPEC.md -> onbellege girer

# adim: (cagri sayisi, onbelleklenmeyen giris, cikis[akil yurutme dahil], model)
STEPS = [
    ("01 katalog",   1,                      1200, 13000, "gpt-5"),
    ("02 incil",     STORIES,                2500,  4000, "gpt-5"),
    ("03 yazar",     CHAPTERS_TOTAL*REVISE,  4500,  3000, "gpt-5"),
    ("04 QA",        CHAPTERS_TOTAL*REVISE,  4200,  1500, "gpt-5-mini"),
]

def run(steps, label):
    print(f"\n{label}")
    print(f"{'adim':14}{'cagri':>7}{'giris':>12}{'cikis':>12}{'maliyet':>10}")
    print("-"*55)
    total = 0.0
    for name, n, tin, tout, model in steps:
        p = PRICE[model]
        cost = (n*SPEC_TOKENS*p["cached"] + n*tin*p["in"] + n*tout*p["out"]) / 1_000_000
        total += cost
        print(f"{name:14}{int(n):>7}{int(n*(tin+SPEC_TOKENS)):>12,}{int(n*tout):>12,}{'$'+format(cost,'.2f'):>10}")
    print("-"*55)
    print(f"{'TOPLAM':14}{'':>7}{'':>12}{'':>12}{'$'+format(total,'.2f'):>10}")
    return total

print(f"Faz 1: {CIVS} medeniyet x {STORIES_PER_CIV} hikaye x {CHAPTERS} bolum = {CHAPTERS_TOTAL} bolum")
print(f"(~{CHAPTERS_TOTAL*1050:,} kelime — mevcut icerigin ~{CHAPTERS_TOTAL*1050//3300}x'i)")
base = run(STEPS, "== KARMA: yazim gpt-5, QA gpt-5-mini ==")

allbig = [(n, c, i, o, "gpt-5") for n, c, i, o, _ in STEPS]
big = run(allbig, "== HEPSI gpt-5 ==")

allmini = [(n, c, i, o, "gpt-5-mini") for n, c, i, o, _ in STEPS]
mini = run(allmini, "== HEPSI gpt-5-mini (sadece hat testi icin) ==")

tr = [("05 ceviri", CHAPTERS_TOTAL, 3000, 2500, "gpt-5-mini")]
print()
t = run(tr, "== 05 CEVIRI (dil basina) ==")

print(f"\n{'='*55}")
print(f"Faz 1 icerik (karma)          : ${base:,.2f}")
print(f"  + 3 dile ceviri             : ${t*3:,.2f}")
print(f"  TOPLAM                      : ${base+t*3:,.2f}")
print(f"\nBolum basina birim maliyet    : ${base/CHAPTERS_TOTAL:.3f}")
print(f"Tek hikaye pilotu (6 bolum)   : ${base/STORIES:.2f}")
