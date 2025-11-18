#!/usr/bin/env python3
"""
Clean invalid chapters from the exported bundle.
Removes chapters that reference non-existent stories.
"""

import json
from datetime import datetime, timezone

INPUT_PATH = "Ancient World Stories/Resources/stories_bundle.json"
OUTPUT_PATH = "Ancient World Stories/Resources/stories_bundle.json"

def main():
    print("🧹 Cleaning invalid chapters from bundle...")

    # Load bundle
    with open(INPUT_PATH, "r", encoding="utf-8") as f:
        bundle = json.load(f)

    civilizations = bundle["civilizations"]
    stories = bundle["stories"]
    chapters = bundle["chapters"]

    print(f"  Original: {len(civilizations)} civs, {len(stories)} stories, {len(chapters)} chapters")

    # Get valid story IDs
    story_ids = {s["id"] for s in stories}

    # Filter chapters
    valid_chapters = [c for c in chapters if c["story_id"] in story_ids]
    invalid_count = len(chapters) - len(valid_chapters)

    print(f"  Removed {invalid_count} invalid chapters")
    print(f"  Remaining: {len(valid_chapters)} chapters")

    # Update bundle
    bundle["chapters"] = valid_chapters
    bundle["total_chapters"] = len(valid_chapters)
    bundle["exported_at"] = datetime.now(timezone.utc).isoformat()
    bundle["cleaned"] = True

    # Save
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(bundle, f, ensure_ascii=False, indent=2)

    import os
    file_size = os.path.getsize(OUTPUT_PATH)
    size_mb = file_size / (1024 * 1024)
    print(f"  File size: {size_mb:.2f} MB")

    print("\n✅ Bundle cleaned successfully!")

if __name__ == "__main__":
    main()
