# Translation Guide - Ancient World Stories

This guide explains how to use the automated translation script to translate all stories and chapters to multiple languages.

## Overview

The `translate_stories.py` script automatically:
- Fetches all stories and chapters from Supabase (English version)
- Translates them to 14 different languages using Google AI Studio API (Gemini)
- Inserts translated content back into Supabase with appropriate language codes

## Supported Languages

The script supports translation to the following languages:

| Code | Language   | Code | Language   |
|------|------------|------|------------|
| `en` | English    | `fr` | French     |
| `tr` | Turkish    | `nl` | Dutch      |
| `de` | German     | `ar` | Arabic     |
| `es` | Spanish    | `sv` | Swedish    |
| `it` | Italian    | `no` | Norwegian  |
| `pt` | Portuguese | `da` | Danish     |
| `ja` | Japanese   | `fi` | Finnish    |
| `ko` | Korean     |      |            |

## Prerequisites

1. **Python 3.7+** installed on your system
2. **Google AI Studio API Key** (already configured in the script)
3. **Supabase credentials** (already configured in the script)

## Installation

1. Install required Python packages:
```bash
pip install -r requirements.txt
```

Or install directly:
```bash
pip install requests
```

## Usage

### Basic Usage - Translate to All Languages

To translate all stories and chapters to all supported languages:

```bash
cd "/Users/enesarikan/Desktop/Projects/ENES ARIKAN - appstore/Ancient World Stories"
python3 translate_stories.py
```

### Advanced Usage - Specific Languages

To translate only to specific languages, edit the script and modify the `main()` function:

```python
def main():
    # ... (existing code) ...

    # Translate only to Turkish, German, and Spanish
    target_languages = ["tr", "de", "es"]
    orchestrator.process_all_translations(target_languages=target_languages)
```

### Skip Already Translated Content

By default, the script skips stories that have already been translated to avoid duplicates. To force re-translation:

```python
orchestrator.process_all_translations(skip_existing=False)
```

## How It Works

### 1. Data Fetching
The script fetches all English stories and their chapters from Supabase:
```
stories table: id, title, summary, civilization_id, chapters_count, language_code
chapters table: id, title, text, story_id, order_no, duration, language_code
```

### 2. Translation Process
For each story and chapter:
- Uses Google AI Studio API (Gemini 1.5 Flash model)
- Maintains context about the content type (title, summary, narrative)
- Keeps translations natural and culturally appropriate

### 3. Data Insertion
Translated content is inserted with:
- **Same ID as original** (for easy reference and linking)
- Updated `language_code` field
- `audio_url` set to `null` (audio needs regeneration per language)

## Database Schema

### Stories Table
```sql
CREATE TABLE stories (
    id UUID PRIMARY KEY,
    civilization_id UUID,
    title TEXT,
    summary TEXT,
    chapters_count INT,
    language_code TEXT,
    created_at TIMESTAMP
);
```

### Chapters Table
```sql
CREATE TABLE chapters (
    id UUID PRIMARY KEY,
    story_id UUID,
    title TEXT,
    order_no INT,
    text TEXT,
    duration INT,
    language_code TEXT,
    audio_url TEXT
);
```

## Output Example

```
================================================================================
🌍 ANCIENT WORLD STORIES - TRANSLATION SCRIPT
================================================================================

🌍 Starting translation process
📝 Target languages: Turkish, German, Spanish, Italian, Portuguese, French, Dutch, Arabic, Swedish, Norwegian, Danish, Finnish, Japanese, Korean
⚡ Source language: English

📚 Found 50 stories in English

================================================================================
📖 Processing: The Scribe's Secret
================================================================================
  📄 Found 12 chapters

  🌐 Translating to Turkish (tr)
  ------------------------------------------------------------
  📖 Translating story: The Scribe's Secret
    ✅ Story translated successfully

  📚 Translating 12 chapters...
    📄 Chapter 1: The Morning Sun
      ✅ Chapter translated
    📄 Chapter 2: Master Enki's Lesson
      ✅ Chapter translated
    ...

  ✅ Completed Turkish translation
```

## Rate Limiting & Performance

- The script includes a 0.5-second delay between API calls
- Each translation typically takes 1-3 seconds
- Total time depends on content volume:
  - ~50 stories with 600 chapters = ~2-3 hours
  - Progress is saved incrementally to Supabase

## Error Handling

The script handles:
- Network timeouts
- API rate limits
- Translation failures (logged but doesn't stop the process)
- Duplicate content detection

All errors are logged with clear messages:
- ✅ Success indicators
- ❌ Error indicators
- 📊 Summary statistics at the end

## Troubleshooting

### API Key Issues
If you get authentication errors:
1. Verify your Google AI Studio API key is correct
2. Check API quota at: https://aistudio.google.com/

### Supabase Connection Issues
If database operations fail:
1. Verify Supabase URL and anon key in Configuration.swift
2. Check your internet connection
3. Verify Supabase project is active

### Translation Quality
To improve translations:
- Adjust the `temperature` parameter (currently 0.3) for more creative translations
- Modify the prompt in `translate_text()` method for specific tone/style

## Post-Translation Tasks

After running the translation script:

1. **Regenerate Audio**
   - Audio files need to be generated for each language
   - Use MinimaxTTSService with appropriate language codes
   - Update `audio_url` field in chapters table

2. **Test Translations**
   - Review a sample of translations in the app
   - Check for cultural appropriateness
   - Verify formatting and special characters

3. **Update Localization Strings**
   - The `.lproj` files contain UI strings
   - These are separate from story content
   - Use a different process for UI localization

## Cost Estimation

Google AI Studio API (Gemini 1.5 Flash):
- Free tier: 15 requests per minute
- Pricing: Check current rates at https://ai.google.dev/pricing

For ~50 stories with ~600 chapters:
- ~650 translations × 14 languages = ~9,100 API calls
- Within free tier if spread over time

## Script Configuration

Key variables in `translate_stories.py`:

```python
GOOGLE_API_KEY = "your-key-here"
SUPABASE_URL = "your-supabase-url"
SUPABASE_ANON_KEY = "your-anon-key"
SOURCE_LANGUAGE = "en"  # Language to translate from
```

## Support

For issues or questions:
1. Check the error messages in script output
2. Review this guide
3. Test with a small subset of languages first

## Example: Custom Translation Workflow

```python
# Initialize services
translator = TranslationService(GOOGLE_API_KEY)
supabase = SupabaseService(SUPABASE_URL, SUPABASE_ANON_KEY)
orchestrator = TranslationOrchestrator(translator, supabase)

# Option 1: Translate everything
orchestrator.process_all_translations()

# Option 2: Translate specific languages
orchestrator.process_all_translations(target_languages=["tr", "de", "es"])

# Option 3: Force re-translation
orchestrator.process_all_translations(skip_existing=False)

# Option 4: Translate only Turkish and Arabic
orchestrator.process_all_translations(target_languages=["tr", "ar"])
```

## Maintenance

The script is designed to be:
- **Idempotent**: Safe to run multiple times
- **Resumable**: Skips already-translated content
- **Extensible**: Easy to add new languages

To add a new language:
1. Add to `SUPPORTED_LANGUAGES` dictionary
2. Create corresponding `.lproj` folder
3. Run the script with the new language code
