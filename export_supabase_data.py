#!/usr/bin/env python3
"""
Supabase Data Export Script
Exports all civilizations, stories, and chapters with proper pagination.
Handles Supabase's 1000 row limit per request.
"""

import json
import requests
from datetime import datetime
from typing import Any

# Supabase Configuration
SUPABASE_URL = "https://njpjehnphsceepechadv.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qcGplaG5waHNjZWVwZWNoYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMDk5MTEsImV4cCI6MjA3NzU4NTkxMX0.deAvavILAyoKDFR9K3Rw5FwO_lJ1r7_GKoE9WHjiVx0"

# Output path
OUTPUT_PATH = "Ancient World Stories/Resources/stories_bundle.json"

def fetch_with_pagination(table: str, order_by: str = "created_at") -> list[dict[str, Any]]:
    """
    Fetch all rows from a table with pagination to bypass 1000 row limit.
    """
    all_rows = []
    offset = 0
    limit = 1000  # Supabase max rows per request

    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Content-Type": "application/json",
        "Prefer": "count=exact"
    }

    while True:
        url = f"{SUPABASE_URL}/rest/v1/{table}?select=*&order={order_by}.asc&limit={limit}&offset={offset}"

        response = requests.get(url, headers=headers)

        # 200 = OK, 206 = Partial Content (normal for pagination)
        if response.status_code not in [200, 206]:
            print(f"Error fetching {table}: {response.status_code}")
            print(response.text)
            break

        rows = response.json()
        all_rows.extend(rows)

        print(f"  Fetched {len(rows)} rows from {table} (offset: {offset}, total: {len(all_rows)})")

        # Check if we got less than limit (meaning we're done)
        if len(rows) < limit:
            break

        # Move to next page
        offset += limit

    return all_rows

def validate_relationships(civilizations: list, stories: list, chapters: list) -> bool:
    """
    Validate that all IDs are properly linked.
    """
    print("\n🔍 Validating relationships...")

    # Create ID sets
    civ_ids = {c["id"] for c in civilizations}
    story_ids = {s["id"] for s in stories}

    # Check stories -> civilizations
    orphan_stories = []
    for story in stories:
        if story["civilization_id"] not in civ_ids:
            orphan_stories.append(story["id"])

    if orphan_stories:
        print(f"  ⚠️  {len(orphan_stories)} stories have invalid civilization_id")
    else:
        print(f"  ✅ All stories linked to valid civilizations")

    # Check chapters -> stories
    orphan_chapters = []
    for chapter in chapters:
        if chapter["story_id"] not in story_ids:
            orphan_chapters.append(chapter["id"])

    if orphan_chapters:
        print(f"  ⚠️  {len(orphan_chapters)} chapters have invalid story_id")
    else:
        print(f"  ✅ All chapters linked to valid stories")

    return len(orphan_stories) == 0 and len(orphan_chapters) == 0

def get_language_stats(items: list) -> dict[str, int]:
    """
    Count items per language.
    """
    stats = {}
    for item in items:
        lang = item.get("language_code", "unknown")
        stats[lang] = stats.get(lang, 0) + 1
    return dict(sorted(stats.items()))

def main():
    print("=" * 60)
    print("📦 Supabase Data Export")
    print("=" * 60)
    print(f"URL: {SUPABASE_URL}")
    print(f"Output: {OUTPUT_PATH}")
    print("=" * 60)

    # Fetch all data with pagination
    print("\n📥 Fetching civilizations...")
    civilizations = fetch_with_pagination("civilizations", "era_start")
    print(f"  Total civilizations: {len(civilizations)}")

    print("\n📥 Fetching stories...")
    stories = fetch_with_pagination("stories", "created_at")
    print(f"  Total stories: {len(stories)}")

    print("\n📥 Fetching chapters (this may take a while)...")
    chapters = fetch_with_pagination("chapters", "order_no")
    print(f"  Total chapters: {len(chapters)}")

    # Validate relationships
    is_valid = validate_relationships(civilizations, stories, chapters)

    if not is_valid:
        print("\n⚠️  WARNING: Some relationships are invalid!")
        print("    Continuing anyway, but please check the data.")

    # Language statistics
    print("\n📊 Language Statistics:")
    print("\n  Civilizations:")
    for lang, count in get_language_stats(civilizations).items():
        print(f"    {lang}: {count}")

    print("\n  Stories:")
    for lang, count in get_language_stats(stories).items():
        print(f"    {lang}: {count}")

    print("\n  Chapters:")
    for lang, count in get_language_stats(chapters).items():
        print(f"    {lang}: {count}")

    # Create bundle
    bundle = {
        "version": "1.0",
        "exported_at": datetime.utcnow().isoformat() + "Z",
        "total_civilizations": len(civilizations),
        "total_stories": len(stories),
        "total_chapters": len(chapters),
        "civilizations": civilizations,
        "stories": stories,
        "chapters": chapters
    }

    # Save to file
    print(f"\n💾 Saving to {OUTPUT_PATH}...")
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(bundle, f, ensure_ascii=False, indent=2)

    # File size
    import os
    file_size = os.path.getsize(OUTPUT_PATH)
    size_mb = file_size / (1024 * 1024)
    print(f"  File size: {size_mb:.2f} MB")

    print("\n" + "=" * 60)
    print("✅ Export completed successfully!")
    print("=" * 60)

    # Summary
    print(f"""
📋 Summary:
   - Civilizations: {len(civilizations)}
   - Stories: {len(stories)}
   - Chapters: {len(chapters)}
   - File size: {size_mb:.2f} MB

🔗 Relationships validated: {'✅ All valid' if is_valid else '⚠️  Some invalid'}

📍 Next steps:
   1. Review the exported data
   2. Update ContentLoader to use bundle
   3. Test the app with bundled data
""")

if __name__ == "__main__":
    main()
