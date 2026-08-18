#!/usr/bin/env python3
PRICE = {
    "gpt-5":        {"in":1.25,"cached":0.125,"out":10.00},
    "gpt-5.4-mini": {"in":0.75,"cached":0.075,"out": 4.50},
    "gpt-5-mini":   {"in":0.25,"cached":0.025,"out": 2.00},
    "gpt-4.1-mini": {"in":0.40,"cached":0.100,"out": 1.60},
}
CIVS,SPC,CH = 12,2,6
STORIES=CIVS*SPC; TOTAL=STORIES*CH; REV=1.3; SPEC=1800
# (adim, cagri, giris, cikis)
S = [("01 katalog",1,1200,13000),("02 incil",STORIES,2500,4000),
     ("03 yazar",TOTAL*REV,4500,3000),("04 QA",TOTAL*REV,4200,1500)]

def cost(assign):
    t=0
    for (name,n,tin,tout) in S:
        p=PRICE[assign[name]]
        t+=(n*SPEC*p["cached"]+n*tin*p["in"]+n*tout*p["out"])/1_000_000
    return t

CONFIGS = {
 "A  hepsi gpt-5":                  {"01 katalog":"gpt-5","02 incil":"gpt-5","03 yazar":"gpt-5","04 QA":"gpt-5"},
 "B  yazim gpt-5 / QA mini":        {"01 katalog":"gpt-5","02 incil":"gpt-5","03 yazar":"gpt-5","04 QA":"gpt-5-mini"},
 "C  plan gpt-5 / yazim 5.4-mini":  {"01 katalog":"gpt-5","02 incil":"gpt-5","03 yazar":"gpt-5.4-mini","04 QA":"gpt-5-mini"},
 "D  hepsi gpt-5.4-mini":           {"01 katalog":"gpt-5.4-mini","02 incil":"gpt-5.4-mini","03 yazar":"gpt-5.4-mini","04 QA":"gpt-5-mini"},
 "E  hepsi gpt-5-mini":             {"01 katalog":"gpt-5-mini","02 incil":"gpt-5-mini","03 yazar":"gpt-5-mini","04 QA":"gpt-5-mini"},
}
print(f"Faz 1 = {TOTAL} bolum / ~{TOTAL*1050:,} kelime\n")
print(f"{'konfigurasyon':34}{'Faz 1':>9}{'pilot':>9}{'bolum':>9}")
print("-"*61)
base=None
for k,v in CONFIGS.items():
    c=cost(v)
    if base is None: base=c
    print(f"{k:34}{'$'+format(c,'.2f'):>9}{'$'+format(c/STORIES,'.2f'):>9}{'$'+format(c/TOTAL,'.3f'):>9}")
print("-"*61)
print(f"\nA -> C tasarruf: ${cost(CONFIGS['A  hepsi gpt-5'])-cost(CONFIGS['C  plan gpt-5 / yazim 5.4-mini']):.2f}")
print(f"A -> E tasarruf: ${cost(CONFIGS['A  hepsi gpt-5'])-cost(CONFIGS['E  hepsi gpt-5-mini']):.2f}")
print(f"\nKarsilastirma: 1 yillik abonelik = $39.99")
