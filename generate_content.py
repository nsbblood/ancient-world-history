#!/usr/bin/env python3
"""
Ancient World Stories — icerik uretim hatti.

  python3 generate_content.py --pilot            # 1 medeniyet / 1 hikaye / 6 bolum
  python3 generate_content.py --civs 12 --stories 2
  python3 generate_content.py --pilot --dry-run  # API cagirmadan promptlari yaz

Prompt'lar prompts/ altinda. Deterministik alanlar (id, duration, order_no,
chapters_count) burada hesaplanir — modele birakilmaz.
"""
import argparse, difflib, json, os, pathlib, re, sys, time, urllib.request, urllib.error, uuid

ROOT = pathlib.Path(__file__).parent
PROMPTS = ROOT / "prompts"
OUT = ROOT / "content"
API = "https://api.openai.com/v1/responses"
WPM = 155  # AVSpeechSynthesizer varsayilan hizi

REGIONS = {"North Africa","Middle East","Mediterranean","Europe","East Asia",
           "South & Central Asia","Americas","Oceania"}
ERA_RE = re.compile(r"^\d+ (BC|AD)$")

# ---------------------------------------------------------------- ortam

def load_env():
    env = {}
    f = ROOT / ".env"
    if f.exists():
        for line in f.read_text().splitlines():
            line = line.split("#")[0].strip() if not line.strip().startswith("#") else ""
            if "=" in line:
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip()
    for k, v in os.environ.items():
        if k.startswith(("OPENAI_", "CONTENT_", "CHAPTERS_", "WORDS_")):
            env[k] = v
    if not env.get("OPENAI_API_KEY"):
        sys.exit(".env icinde OPENAI_API_KEY yok.")
    return env

def canonical_civs():
    """Kanonik medeniyet isimlerini Civilization.swift'ten okur — listeler ayrisamaz."""
    src = ROOT / "Ancient World Stories/Models/Civilization.swift"
    body = src.read_text(encoding="utf-8").split("var coordinate")[1].split("var startYear")[0]
    names = set()
    for grp in re.findall(r'case ((?:"[^"]+"(?:,\s*)?)+):', body):
        names.update(n.strip().strip('"') for n in grp.split(","))
    return names


# ---------------------------------------------------------------- semalar

def _obj(props, req=None):
    return {"type":"object","properties":props,
            "required":req or list(props),"additionalProperties":False}

S_STORY = _obj({
    "title":{"type":"string"}, "summary":{"type":"string"},
    "archetype":{"type":"string"}, "pov":{"type":"string"},
    "scale":{"type":"string"}, "tone":{"type":"string"}, "premise":{"type":"string"},
    "historical_anchors":{"type":"array","items":{"type":"string"}},
    "hook_for_chapter_1":{"type":"string"}})

SCHEMAS = {
"catalog": _obj({
    "civilizations":{"type":"array","items":_obj({
        "name":{"type":"string"}, "era_start":{"type":"string"}, "era_end":{"type":"string"},
        "region":{"type":"string"}, "description":{"type":"string"},
        "why_this_one":{"type":"string"},
        "stories":{"type":"array","items":S_STORY}})},
    "diversity_audit":_obj({"violations":{"type":"array","items":{"type":"string"}}})}),

"bible": _obj({
    "cast":{"type":"array","items":_obj({
        "name":{"type":"string"},"age":{"type":"integer"},"role":{"type":"string"},
        "wants":{"type":"string"},"fears":{"type":"string"},
        "speech_tic":{"type":"string"},"real_person":{"type":"boolean"}})},
    "chapters":{"type":"array","items":_obj({
        "order_no":{"type":"integer"},"title":{"type":"string"},"function":{"type":"string"},
        "what_happens":{"type":"string"},"setting":{"type":"string"},
        "time_jump":{"type":"string"},"present":{"type":"array","items":{"type":"string"}},
        "historical_anchor":{"type":"string"},"sensory_signature":{"type":"string"},
        "quote_candidate":{"type":"string"},"opening_direction":{"type":"string"},
        "ends_on":{"type":"string"}})},
    "ledger":_obj({
        "verified":{"type":"array","items":_obj({"claim":{"type":"string"},"basis":{"type":"string"}})},
        "invented":{"type":"array","items":_obj({"element":{"type":"string"},"why_plausible":{"type":"string"}})}})}),

"chapter": _obj({
    "title":{"type":"string"},
    "text":{"type":"string"},
    "quote":{"type":"string"},
    "anchors_used":{"type":"array","items":{"type":"string"}}}),

"qa": _obj({
    "verdict":{"type":"string","enum":["pass","revise","reject"]},
    "blocking":{"type":"array","items":_obj({
        "category":{"type":"string"},"severity":{"type":"string"},
        "problem":{"type":"string"},"fix":{"type":"string"}})},
    "minor":{"type":"array","items":_obj({"problem":{"type":"string"},"fix":{"type":"string"}})}}),
}

# ---------------------------------------------------------------- API

class Budget:
    def __init__(self):
        self.rows = []
    PRICE = {"gpt-5":(1.25,.125,10.0), "gpt-5.4-mini":(.75,.075,4.5),
             "gpt-5-mini":(.25,.025,2.0), "gpt-4.1-mini":(.40,.10,1.60)}
    def add(self, step, model, usage):
        i = usage.get("input_tokens", 0); o = usage.get("output_tokens", 0)
        cached = usage.get("input_tokens_details", {}).get("cached_tokens", 0)
        pin, pc, po = self.PRICE.get(model, (0, 0, 0))
        cost = ((i - cached) * pin + cached * pc + o * po) / 1e6
        self.rows.append((step, model, i, cached, o, cost))
        return cost
    def report(self):
        print(f"\n{'adim':22}{'model':15}{'giris':>10}{'onbellek':>10}{'cikis':>10}{'$':>9}")
        print("-" * 76)
        for s, m, i, c, o, k in self.rows:
            print(f"{s:22}{m:15}{i:>10,}{c:>10,}{o:>10,}{'$'+format(k,'.4f'):>9}")
        print("-" * 76)
        ti = sum(r[2] for r in self.rows); to = sum(r[4] for r in self.rows)
        tc = sum(r[5] for r in self.rows)
        print(f"{'TOPLAM':22}{'':15}{ti:>10,}{'':>10}{to:>10,}{'$'+format(tc,'.4f'):>9}")
        return tc

def call(env, model, prompt, budget, step, schema=None, max_out=16000, retries=6):
    payload = {"model": model, "input": prompt, "max_output_tokens": max_out}
    if schema:
        # Structured outputs: API gecerli JSON'u garanti eder. Uzun metinlerde model
        # elle JSON yazarken tirnak kacirip parse'i bozuyordu; bu onu tamamen kaldirir.
        payload["text"] = {"format": {"type": "json_schema", "name": "out",
                                      "schema": schema, "strict": True}}
    body = json.dumps(payload).encode()
    for attempt in range(retries):
        req = urllib.request.Request(API, data=body, headers={
            "Authorization": f"Bearer {env['OPENAI_API_KEY']}", "Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=300) as r:
                data = json.load(r)
            break
        except urllib.error.HTTPError as e:
            msg = e.read().decode()[:300]
            if e.code in (429, 500, 502, 503) and attempt < retries - 1:
                wait = int(e.headers.get("Retry-After") or 0) or min(15 * 2 ** attempt, 120)
                print(f"    {e.code} -> {wait}s bekleniyor ({attempt+1}/{retries})", flush=True)
                time.sleep(wait); continue
            sys.exit(f"HTTP {e.code} ({step}): {msg}")
    else:
        sys.exit(f"{step}: {retries} denemede basarisiz (rate limit)")
    budget.add(step, model, data.get("usage", {}))
    chunks = []
    for item in data.get("output", []):
        for c in item.get("content", []):
            if c.get("type") == "output_text":
                chunks.append(c["text"])
    text = "".join(chunks)
    if not text.strip():
        sys.exit(f"{step}: bos yanit (muhtemelen max_output_tokens akil yurutmeye gitti)")
    return text

def parse_json(text, step):
    """Once dogrudan dene. Fence ayiklamasi ancak duz parse basarisizsa devreye girer —
    ters sirada yanit icindeki bir backtick yanlis parcayi kapip {} donduruyordu."""
    (OUT / "_raw").mkdir(parents=True, exist_ok=True)
    n = 1
    while (OUT / "_raw" / f"{step}_{n}.txt").exists(): n += 1
    (OUT / "_raw" / f"{step}_{n}.txt").write_text(text, encoding="utf-8")

    def ok(v):
        return isinstance(v, dict) and len(v) > 0

    t = text.strip()
    try:
        v = json.loads(t)
        if ok(v): return v
    except json.JSONDecodeError:
        pass
    for m in re.finditer(r"```(?:json)?\s*(.*?)```", t, re.S):
        try:
            v = json.loads(m.group(1).strip())
            if ok(v): return v
        except json.JSONDecodeError:
            continue
    depth, start = 0, None            # en buyuk dengeli { } blogunu bul
    best = None
    for i, c in enumerate(t):
        if c == "{":
            if depth == 0: start = i
            depth += 1
        elif c == "}" and depth:
            depth -= 1
            if depth == 0 and start is not None:
                cand = t[start:i+1]
                if best is None or len(cand) > len(best): best = cand
    if best:
        try:
            v = json.loads(best)
            if ok(v): return v
        except json.JSONDecodeError:
            pass
    sys.exit(f"{step}: JSON parse edilemedi -> content/_raw/{step}.txt")

# ---------------------------------------------------------------- prompt

def spec():           return (PROMPTS / "00-SPEC.md").read_text(encoding="utf-8")
def tpl(name):        return (PROMPTS / name).read_text(encoding="utf-8")
def fill(t, **kw):
    for k, v in kw.items():
        t = t.replace("{{" + k + "}}", v if isinstance(v, str) else json.dumps(v, ensure_ascii=False))
    return t
LANG_NAMES = {"en":"English","tr":"Turkish","de":"German","fr":"French","es":"Spanish",
              "it":"Italian","pt":"Portuguese","nl":"Dutch","sv":"Swedish","no":"Norwegian",
              "da":"Danish","fi":"Finnish","ja":"Japanese","ko":"Korean","ar":"Arabic"}
OUTPUT_LANG = "en"

def lang_rule():
    n = LANG_NAMES.get(OUTPUT_LANG, OUTPUT_LANG)
    return (f"\n\n## ⚠️ ÜRETİM DİLİ — HER ŞEYDEN ÖNCE\n\n"
            f"Bu talimatlar Türkçe yazılmıştır. **Bu, üretilecek içeriğin dilini belirlemez.**\n\n"
            f"Tüm içerik alanları — `title`, `summary`, `description`, `text`, `quote` — "
            f"**{n}** ({OUTPUT_LANG}) dilinde yazılacak. Tek bir alan bile başka dilde olamaz.\n"
            f"Etiket/enum alanları (`archetype`, `pov`, `scale`, `tone`) talimattaki gibi kalır.\n")

def build(name, **kw):
    return spec() + lang_rule() + "\n\n---\n\n" + fill(tpl(name), **kw)

# ---------------------------------------------------------------- dogrulama

def validate_chapter(ch, order_no, canon):
    """Bundle'a girmeden once mekanik kontroller. Modelin raporuna guvenilmez."""
    p = []
    text = ch.get("text", "")
    words = len(text.split())
    if not (900 <= words <= 1200):
        p.append(f"kelime sayisi {words} (900-1200 disinda)")
    for pat, label in [(r"\bc\.\s", "c."), (r"\bca\.\s", "ca."), (r"\bBCE\b", "BCE"),
                       (r"\bCE\b", "CE"), (r"\bvb\.", "vb."), (r"[()]", "parantez"),
                       (r"[*#]", "markdown")]:
        if re.search(pat, text):
            p.append(f"TTS: '{label}' gecti")
    if re.search(r"^\s*[-•]\s", text, re.M):
        p.append("TTS: madde isareti")
    if text.count("—") > 3:
        p.append(f"TTS: {text.count('—')} uzun tire (max 3)")
    q = (ch.get("quote") or "").strip()
    if not q:
        p.append("quote yok")
    else:
        if q not in text:
            # Model neredeyse her zaman hafif parafraz ediyor. Yeniden yazdirmak yerine
            # metindeki en yakin cumleye oturt — sonuc her zaman birebir gecerli olur.
            sents = [x.strip() for x in re.split(r"(?<=[.!?\u201d])\s+", text) if 40 <= len(x.strip()) <= 200]
            best = difflib.get_close_matches(q, sents, n=1, cutoff=0.45)
            if best:
                ch["quote"] = best[0]; q = best[0]
            else:
                p.append("quote metinde yok, benzer cumle de bulunamadi")
        if len(q) > 200:
            p.append(f"quote {len(q)} karakter (max 200)")
    opening = " ".join(text.split()[:25])
    if re.match(r"^(O|He|She|It|They|Bu|Şu)\b", opening):
        p.append("acilis referanssiz zamirle basliyor")
    return p, words

def validate_civ(civ, canon):
    p = []
    if civ.get("name") not in canon:
        p.append(f"'{civ.get('name')}' kanonik 52 isimde yok -> harita pini Ortadogu'ya duser")
    if civ.get("region") not in REGIONS:
        p.append(f"region '{civ.get('region')}' kanonik degil")
    for k in ("era_start", "era_end"):
        if not ERA_RE.match(str(civ.get(k, ""))):
            p.append(f"{k}='{civ.get(k)}' format disi -> parseYear 0 doner")
    return p

# ---------------------------------------------------------------- hat

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pilot", action="store_true", help="1 medeniyet / 1 hikaye")
    ap.add_argument("--civs", type=int, default=12)
    ap.add_argument("--stories", type=int, default=2)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    env = load_env()
    canon = canonical_civs()
    OUT.mkdir(exist_ok=True)
    civs, spc = (1, 1) if a.pilot else (a.civs, a.stories)
    nch = int(env.get("CHAPTERS_PER_STORY", 6))
    lang = env.get("CONTENT_LANGUAGES", "en").split(",")[0].strip()
    M_PLAN  = env.get("OPENAI_MODEL_PLAN", "gpt-5.4-mini")
    M_WRITE = env.get("OPENAI_MODEL_WRITE", "gpt-5.4-mini")
    M_CHECK = env.get("OPENAI_MODEL_CHECK", "gpt-5.4-mini")
    globals()["OUTPUT_LANG"] = lang
    b = Budget()

    print(f"{civs} medeniyet x {spc} hikaye x {nch} bolum | dil={lang}")
    print(f"plan={M_PLAN} yazim={M_WRITE} qa={M_CHECK}")
    print(f"kanonik medeniyet ismi: {len(canon)}\n")

    # --- 01 katalog
    print("[01] katalog planlaniyor...")
    p = build("01-catalog-planner.md", CIV_COUNT=str(civs), STORIES_PER_CIV=str(spc),
              LANGUAGE=lang, EXISTING_CATALOG="(bos)")
    if a.dry_run:
        (OUT / "prompt_01.txt").write_text(p); print("  dry-run -> content/prompt_01.txt"); return
    cat = parse_json(call(env, M_PLAN, p, b, "01 katalog", SCHEMAS["catalog"]), "01")
    (OUT / "01_catalog.json").write_text(json.dumps(cat, ensure_ascii=False, indent=2))
    viol = cat.get("diversity_audit", {}).get("violations", [])
    print(f"  {len(cat['civilizations'])} medeniyet | cesitlilik ihlali: {viol or 'yok'}")

    civs_out, stories_out, chapters_out = [], [], []

    for civ in cat["civilizations"]:
        problems = validate_civ(civ, canon)
        if problems:
            print(f"  !! {civ.get('name')}: " + "; ".join(problems))
        cid = str(uuid.uuid4())
        civs_out.append({"id": cid, "name": civ["name"], "era_start": civ["era_start"],
                         "era_end": civ["era_end"], "region": civ["region"],
                         "description": civ["description"], "language_code": lang})

        for st in civ["stories"]:
            print(f"\n[02] incil: {civ['name']} / {st['title']}")
            p = build("02-story-bible.md", CIV_NAME=civ["name"], ERA_START=civ["era_start"],
                      ERA_END=civ["era_end"], REGION=civ["region"], TITLE=st["title"],
                      SUMMARY=st["summary"], ARCHETYPE=st["archetype"], POV=st["pov"],
                      SCALE=st["scale"], TONE=st["tone"], PREMISE=st["premise"],
                      HISTORICAL_ANCHORS=st["historical_anchors"],
                      HOOK=st.get("hook_for_chapter_1", ""))
            bible = parse_json(call(env, M_PLAN, p, b, "02 incil", SCHEMAS["bible"]), "02")
            sid = str(uuid.uuid4())
            so_far, prev_tail = [], "(ilk bolum)"

            for plan in bible["chapters"][:nch]:
                n = plan["order_no"]
                print(f"  [03] bolum {n}/{nch}: {plan['title']}", end="", flush=True)
                pw = build("03-chapter-writer.md",
                    CIV_NAME=civ["name"], ERA_START=civ["era_start"], ERA_END=civ["era_end"],
                    REGION=civ["region"], TITLE=st["title"], SUMMARY=st["summary"],
                    TONE=st["tone"], POV=st["pov"], SCALE=st["scale"],
                    CAST=bible["cast"], LEDGER=bible["ledger"], ORDER_NO=str(n),
                    CHAPTER_TITLE=plan["title"], FUNCTION=plan["function"],
                    WHAT_HAPPENS=plan["what_happens"], SETTING=plan["setting"],
                    TIME_JUMP=plan.get("time_jump", ""), PRESENT=plan.get("present", []),
                    HISTORICAL_ANCHOR=plan["historical_anchor"],
                    SENSORY_SIGNATURE=plan["sensory_signature"],
                    QUOTE_CANDIDATE=plan["quote_candidate"],
                    OPENING_DIRECTION=plan["opening_direction"], ENDS_ON=plan["ends_on"],
                    PREVIOUS_TAIL=prev_tail, STORY_SO_FAR="\n".join(so_far) or "(baslangic)")

                ch, prompt_now = None, pw
                for attempt in range(1, 4):
                    ch = parse_json(call(env, M_WRITE, prompt_now, b, f"03 bolum{n}",
                                         SCHEMAS["chapter"]), f"03_c{n}")
                    problems, words = validate_chapter(ch, n, canon)

                    # Mekanik sorun varsa QA'ye para harcama — once onu duzelt.
                    if problems:
                        print(f" -> {words}k, mekanik: {len(problems)}")
                        for x in problems: print(f"       ! {x}")
                        fixes = problems
                    else:
                        pq = build("04-qa-reviewer.md", CIV_NAME=civ["name"],
                            ERA_START=civ["era_start"], ERA_END=civ["era_end"],
                            LEDGER=bible["ledger"], CAST=bible["cast"],
                            STORY_SO_FAR="\n".join(so_far) or "(baslangic)",
                            CHAPTER_PLAN=plan, CHAPTER_JSON=ch)
                        qa = parse_json(call(env, M_CHECK, pq, b, f"04 qa{n}",
                                             SCHEMAS["qa"]), f"04_c{n}")
                        verdict = qa.get("verdict", "pass")
                        blocking = qa.get("blocking", [])
                        critical = [x for x in blocking if x.get("severity") == "critical"]
                        print(f" -> {words}k, {verdict}")
                        for x in blocking:
                            print(f"       ! [{x.get('category')}] {x.get('problem','')[:88]}")
                        if verdict == "pass":
                            break
                        # Son denemede kritik olmayan sorunla kabul et: her tur biraz daha
                        # iyilesen bir metni sonsuza kadar yeniden yazdirmak kaliteyi dusuruyor.
                        if attempt == 3 and not critical:
                            print("       kritik sorun yok, kabul edildi")
                            break
                        fixes = [x.get("fix", "") for x in blocking if x.get("fix")]

                    if attempt == 3:
                        print("       !! 3 denemede duzelmedi, son hali aliniyor")
                        break

                    # Sifirdan yeniden yazdirma: taslagi geri ver, HEDEFLI duzeltme iste.
                    # (Onceki surumde prompt'a ekleme yapiliyordu; her turda buyuyup
                    #  metni 1156 -> 1532 -> 1562 kelimeye sisiriyordu.)
                    cut = ""
                    if words > 1200:
                        cut = (f"\n\n**UZUNLUK — EN ONEMLI SORUN.** Bu taslak **{words} kelime**. "
                               f"Hedef **1050 kelime**. En az **{words-1100} kelime KISALTMAN** "
                               "gerekiyor. Nereden kisaltacagin:\n"
                               "- Ayni fikri iki kez soyleyen cumleler\n"
                               "- Tekrar eden cumle yapilari (\u201cHe had expected... He had expected...\u201d)\n"
                               "- Sahneyi ilerletmeyen betimleme yiginlari\n"
                               "- Okuyucunun zaten anladigini aciklayan kapanis cumleleri\n"
                               "Sahneyi, olaylari ve kadroyu koru; fazlaligi at.\n")
                    prompt_now = pw + (
                        "\n\n---\n\n## REVIZYON — DUZELTILMIS BOLUMU YENIDEN URET\n\n"
                        "Asagida senin onceki taslagin var ve reddedildi. Duzeltilmis TAM metni "
                        "uret. Taslagi oldugu gibi geri verme — sorunlar giderilmemis olur."
                        + cut +
                        "\n### Giderilecek sorunlar\n- " + "\n- ".join(fixes) +
                        "\n\n### Reddedilen taslak\n" + ch["text"])
                    print(f"       revizyon {attempt+1}/3...")

                words = len(ch["text"].split())
                chapters_out.append({"id": str(uuid.uuid4()), "story_id": sid,
                    "title": ch["title"], "order_no": n, "text": ch["text"],
                    "duration": round(words / WPM * 60), "language_code": lang})
                so_far.append(f"Bolum {n} ({ch['title']}): {plan['what_happens']}")
                prev_tail = ch["text"].strip().split("\n\n")[-1]

            stories_out.append({"id": sid, "civilization_id": cid, "title": st["title"],
                "summary": st["summary"], "chapters_count":
                sum(1 for c in chapters_out if c["story_id"] == sid), "language_code": lang})

    bundle = {"version": "2.0.0", "exported_at": None,
              "total_civilizations": len(civs_out), "total_stories": len(stories_out),
              "total_chapters": len(chapters_out), "civilizations": civs_out,
              "stories": stories_out, "chapters": chapters_out}
    out = OUT / ("pilot.json" if a.pilot else "generated_bundle.json")
    out.write_text(json.dumps(bundle, ensure_ascii=False, indent=2))

    wc = sum(len(c["text"].split()) for c in chapters_out)
    print(f"\n{len(civs_out)} medeniyet / {len(stories_out)} hikaye / {len(chapters_out)} bolum")
    print(f"{wc:,} kelime | ortalama {wc//max(len(chapters_out),1)} kelime/bolum")
    print(f"-> {out}")
    total = b.report()
    if chapters_out:
        print(f"\nBolum basina gercek maliyet: ${total/len(chapters_out):.4f}")
        print(f"144 bolume oranla tahmini    : ${total/len(chapters_out)*144:.2f}")

if __name__ == "__main__":
    main()
