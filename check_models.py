#!/usr/bin/env python3
"""Bu API key'in hangi modellere erişebildiğini listeler.  Kullanım: python3 scripts_check_models.py"""
import json, os, sys, urllib.request, pathlib

env = pathlib.Path(__file__).parent / ".env"
key = os.environ.get("OPENAI_API_KEY")
if not key and env.exists():
    for line in env.read_text().splitlines():
        line = line.strip()
        if line.startswith("OPENAI_API_KEY=") and len(line) > 15:
            key = line.split("=", 1)[1].strip()

if not key:
    sys.exit("OPENAI_API_KEY boş. .env dosyasına yaz, sonra tekrar çalıştır.")

req = urllib.request.Request(
    "https://api.openai.com/v1/models",
    headers={"Authorization": f"Bearer {key}"},
)
try:
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.load(r)
except urllib.error.HTTPError as e:
    body = e.read().decode()[:400]
    sys.exit(f"HTTP {e.code}: {body}\n\n401 = key gecersiz · 403 = key/proje kisitli")

ids = sorted(m["id"] for m in data.get("data", []))
print(f"Bu key {len(ids)} modele erisiyor.\n")

groups = {"gpt-5": [], "gpt-4": [], "o-serisi": [], "diger": []}
for i in ids:
    if i.startswith("gpt-5"):      groups["gpt-5"].append(i)
    elif i.startswith("gpt-4"):    groups["gpt-4"].append(i)
    elif i.startswith(("o1", "o3", "o4")): groups["o-serisi"].append(i)
    else:                          groups["diger"].append(i)

for name, items in groups.items():
    if items:
        print(f"[{name}]")
        for i in items:
            print("   ", i)
        print()

want = os.environ.get("OPENAI_MODEL", "gpt-5")
print("-" * 50)
print(f".env'deki OPENAI_MODEL = {want}  ->  {'ERISILEBILIR' if want in ids else 'ERISILEMEZ (proje limitlerinden ac)'}")
