-- =========================================================
-- ANCIENT WORLD STORIES — COMPLETE SETUP (All-in-One)
-- =========================================================
-- Author: Enes & Claude
-- Date: 2025-11-10
-- Run this ONCE on a fresh Supabase project
-- =========================================================

------------------------------------------------------------
-- 0️⃣ Helper Functions
------------------------------------------------------------
CREATE OR REPLACE FUNCTION _touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _log_regeneration_attempt()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.generation_status = 'completed' THEN
    RAISE WARNING 'Regenerating completed content: % (lang=%)', NEW.id, NEW.language_code;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- 1️⃣ Supported Languages
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS supported_languages (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  native_name TEXT NOT NULL,
  is_t1 BOOLEAN DEFAULT false,
  priority INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO supported_languages (code, name, native_name, is_t1, priority) VALUES
  ('en', 'English', 'English', true, 1),
  ('tr', 'Turkish', 'Türkçe', true, 2),
  ('de', 'German', 'Deutsch', true, 3),
  ('fr', 'French', 'Français', true, 4),
  ('es', 'Spanish', 'Español', true, 5),
  ('it', 'Italian', 'Italiano', true, 6),
  ('ja', 'Japanese', '日本語', true, 7),
  ('ko', 'Korean', '한국어', true, 8),
  ('nl', 'Dutch', 'Nederlands', true, 9),
  ('ar', 'Arabic', 'العربية', true, 10),
  ('sv', 'Swedish', 'Svenska', true, 11),
  ('no', 'Norwegian', 'Norsk', true, 12),
  ('da', 'Danish', 'Dansk', true, 13),
  ('fi', 'Finnish', 'Suomi', true, 14),
  ('pt', 'Portuguese', 'Português', true, 15)
ON CONFLICT (code) DO NOTHING;


------------------------------------------------------------
-- 2️⃣ Civilizations (master table)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS civilizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  region TEXT,
  era_start TEXT,
  era_end TEXT,
  era_start_year INT,
  era_end_year INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_civilizations_slug ON civilizations(slug);
CREATE INDEX IF NOT EXISTS idx_civilizations_region ON civilizations(region);


------------------------------------------------------------
-- 3️⃣ Civilization Translations
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS civilization_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  civilization_id UUID REFERENCES civilizations(id) ON DELETE CASCADE,
  language_code TEXT NOT NULL REFERENCES supported_languages(code),
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(civilization_id, language_code)
);

CREATE INDEX IF NOT EXISTS idx_civ_tr_lang ON civilization_translations(language_code);
CREATE INDEX IF NOT EXISTS idx_civ_tr_civ ON civilization_translations(civilization_id);

DROP TRIGGER IF EXISTS trg_civ_tr_touch ON civilization_translations;
CREATE TRIGGER trg_civ_tr_touch
BEFORE UPDATE ON civilization_translations
FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();


------------------------------------------------------------
-- 4️⃣ Stories
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  civilization_id UUID REFERENCES civilizations(id) ON DELETE CASCADE,
  title_key TEXT,
  summary TEXT,
  chapters_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stories_civ ON stories(civilization_id);

DROP TRIGGER IF EXISTS trg_stories_touch ON stories;
CREATE TRIGGER trg_stories_touch
BEFORE UPDATE ON stories
FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();


------------------------------------------------------------
-- 5️⃣ Story Translations (AUDIO CACHE HERE)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS story_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  language_code TEXT NOT NULL REFERENCES supported_languages(code),
  title TEXT NOT NULL,
  content TEXT,
  audio_url TEXT,
  audio_duration_seconds INT,
  generation_status TEXT DEFAULT 'pending',
  generated_at TIMESTAMPTZ,
  generation_cost_usd DECIMAL(10,4),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(story_id, language_code)
);

CREATE INDEX IF NOT EXISTS idx_story_tr_story ON story_translations(story_id);
CREATE INDEX IF NOT EXISTS idx_story_tr_lang ON story_translations(language_code);
CREATE INDEX IF NOT EXISTS idx_story_tr_status ON story_translations(generation_status);

DROP TRIGGER IF EXISTS trg_story_tr_touch ON story_translations;
CREATE TRIGGER trg_story_tr_touch
BEFORE UPDATE ON story_translations
FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();

DROP TRIGGER IF EXISTS trg_story_tr_no_regen ON story_translations;
CREATE TRIGGER trg_story_tr_no_regen
BEFORE UPDATE ON story_translations
FOR EACH ROW
WHEN (OLD.generation_status = 'completed')
EXECUTE FUNCTION _log_regeneration_attempt();


------------------------------------------------------------
-- 6️⃣ Chapters
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  title TEXT,
  order_no INT NOT NULL,
  text TEXT,
  duration INT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_story_chapter_order UNIQUE (story_id, order_no)
);

CREATE INDEX IF NOT EXISTS idx_chapters_story ON chapters(story_id);
CREATE INDEX IF NOT EXISTS idx_chapters_order ON chapters(order_no);


------------------------------------------------------------
-- 7️⃣ Chapter Translations (AUDIO CACHE HERE)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chapter_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  language_code TEXT NOT NULL REFERENCES supported_languages(code),
  title TEXT,
  text TEXT,
  audio_url TEXT,
  audio_duration_seconds INT,
  generation_status TEXT DEFAULT 'pending',
  generated_at TIMESTAMPTZ,
  generation_cost_usd DECIMAL(10,4),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(chapter_id, language_code)
);

CREATE INDEX IF NOT EXISTS idx_chapter_tr_chapter ON chapter_translations(chapter_id);
CREATE INDEX IF NOT EXISTS idx_chapter_tr_lang ON chapter_translations(language_code);
CREATE INDEX IF NOT EXISTS idx_chapter_tr_status ON chapter_translations(generation_status);

DROP TRIGGER IF EXISTS trg_chapter_tr_touch ON chapter_translations;
CREATE TRIGGER trg_chapter_tr_touch
BEFORE UPDATE ON chapter_translations
FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();

DROP TRIGGER IF EXISTS trg_chapter_tr_no_regen ON chapter_translations;
CREATE TRIGGER trg_chapter_tr_no_regen
BEFORE UPDATE ON chapter_translations
FOR EACH ROW
WHEN (OLD.generation_status = 'completed')
EXECUTE FUNCTION _log_regeneration_attempt();


------------------------------------------------------------
-- 8️⃣ User Listening Progress
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_listening_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  language_code TEXT REFERENCES supported_languages(code),
  current_time_seconds INT DEFAULT 0,
  total_duration_seconds INT,
  completed BOOLEAN DEFAULT false,
  completion_percentage INT DEFAULT 0,
  first_played_at TIMESTAMPTZ DEFAULT NOW(),
  last_played_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, story_id, chapter_id, language_code)
);

CREATE INDEX IF NOT EXISTS idx_user_progress_user ON user_listening_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_story ON user_listening_progress(story_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_completed ON user_listening_progress(completed);


------------------------------------------------------------
-- 9️⃣ User Favorites
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, story_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON user_favorites(user_id);


------------------------------------------------------------
-- 🔟 Story Metrics (Analytics)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS story_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  language_code TEXT REFERENCES supported_languages(code),
  total_plays INT DEFAULT 0,
  unique_listeners INT DEFAULT 0,
  average_completion_rate DECIMAL(5,2) DEFAULT 0.0,
  total_generation_cost_usd DECIMAL(10,4) DEFAULT 0.0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(story_id, language_code)
);

CREATE INDEX IF NOT EXISTS idx_metrics_story ON story_metrics(story_id);

DROP TRIGGER IF EXISTS trg_story_metrics_touch ON story_metrics;
CREATE TRIGGER trg_story_metrics_touch
BEFORE UPDATE ON story_metrics
FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();


------------------------------------------------------------
-- 1️⃣1️⃣ Fetch Helper Functions
------------------------------------------------------------

-- Fetch civilization translation (with fallback to English)
CREATE OR REPLACE FUNCTION fetch_civilization_tr(p_slug TEXT, p_lang TEXT)
RETURNS TABLE (
  civilization_id UUID,
  language_code TEXT,
  name TEXT,
  description TEXT
)
AS $$
  SELECT
    ct.civilization_id,
    ct.language_code,
    ct.name,
    ct.description
  FROM civilization_translations ct
  JOIN civilizations c ON c.id = ct.civilization_id
  WHERE c.slug = p_slug
    AND ct.language_code IN (p_lang, 'en')
  ORDER BY CASE WHEN ct.language_code = p_lang THEN 0 ELSE 1 END
  LIMIT 1;
$$ LANGUAGE sql STABLE;

-- Fetch story translation (with fallback to English)
CREATE OR REPLACE FUNCTION fetch_story_tr(p_story UUID, p_lang TEXT)
RETURNS TABLE (
  story_id UUID,
  civilization_id UUID,
  language_code TEXT,
  title TEXT,
  content TEXT,
  audio_url TEXT,
  audio_duration_seconds INT,
  generation_status TEXT,
  chapters_count INT
)
AS $$
  SELECT
    st.story_id,
    s.civilization_id,
    st.language_code,
    st.title,
    st.content,
    st.audio_url,
    st.audio_duration_seconds,
    st.generation_status,
    s.chapters_count
  FROM story_translations st
  JOIN stories s ON s.id = st.story_id
  WHERE st.story_id = p_story
    AND st.language_code IN (p_lang, 'en')
  ORDER BY CASE WHEN st.language_code = p_lang THEN 0 ELSE 1 END
  LIMIT 1;
$$ LANGUAGE sql STABLE;

-- Fetch chapter translation (with fallback to English)
CREATE OR REPLACE FUNCTION fetch_chapter_tr(p_chapter UUID, p_lang TEXT)
RETURNS TABLE (
  chapter_id UUID,
  story_id UUID,
  order_no INT,
  language_code TEXT,
  title TEXT,
  text TEXT,
  audio_url TEXT,
  audio_duration_seconds INT,
  generation_status TEXT
)
AS $$
  SELECT
    ct.chapter_id,
    c.story_id,
    c.order_no,
    ct.language_code,
    ct.title,
    ct.text,
    ct.audio_url,
    ct.audio_duration_seconds,
    ct.generation_status
  FROM chapter_translations ct
  JOIN chapters c ON c.id = ct.chapter_id
  WHERE ct.chapter_id = p_chapter
    AND ct.language_code IN (p_lang, 'en')
  ORDER BY CASE WHEN ct.language_code = p_lang THEN 0 ELSE 1 END
  LIMIT 1;
$$ LANGUAGE sql STABLE;


------------------------------------------------------------
-- 1️⃣2️⃣ Row Level Security (RLS)
------------------------------------------------------------

-- Enable RLS on all tables
ALTER TABLE civilizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE civilization_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapter_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_listening_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_metrics ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (safe)
DROP POLICY IF EXISTS "public_read_civilizations" ON civilizations;
DROP POLICY IF EXISTS "public_read_civilization_translations" ON civilization_translations;
DROP POLICY IF EXISTS "public_read_stories" ON stories;
DROP POLICY IF EXISTS "public_read_story_translations" ON story_translations;
DROP POLICY IF EXISTS "public_read_chapters" ON chapters;
DROP POLICY IF EXISTS "public_read_chapter_translations" ON chapter_translations;
DROP POLICY IF EXISTS "public_read_story_metrics" ON story_metrics;
DROP POLICY IF EXISTS "auth_update_story_translations" ON story_translations;
DROP POLICY IF EXISTS "auth_update_chapter_translations" ON chapter_translations;
DROP POLICY IF EXISTS "auth_update_story_metrics" ON story_metrics;
DROP POLICY IF EXISTS "users_manage_own_progress" ON user_listening_progress;
DROP POLICY IF EXISTS "users_manage_own_favorites" ON user_favorites;

-- Public read policies (everyone can view content)
CREATE POLICY "public_read_civilizations"
  ON civilizations FOR SELECT USING (true);

CREATE POLICY "public_read_civilization_translations"
  ON civilization_translations FOR SELECT USING (true);

CREATE POLICY "public_read_stories"
  ON stories FOR SELECT USING (true);

CREATE POLICY "public_read_story_translations"
  ON story_translations FOR SELECT USING (true);

CREATE POLICY "public_read_chapters"
  ON chapters FOR SELECT USING (true);

CREATE POLICY "public_read_chapter_translations"
  ON chapter_translations FOR SELECT USING (true);

CREATE POLICY "public_read_story_metrics"
  ON story_metrics FOR SELECT USING (true);

-- Authenticated users can update (AI generation, metrics)
CREATE POLICY "auth_update_story_translations"
  ON story_translations FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "auth_update_chapter_translations"
  ON chapter_translations FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "auth_update_story_metrics"
  ON story_metrics FOR UPDATE USING (auth.role() = 'authenticated');

-- Users manage their own data
CREATE POLICY "users_manage_own_progress"
  ON user_listening_progress FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_manage_own_favorites"
  ON user_favorites FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


------------------------------------------------------------
-- 1️⃣3️⃣ Seed Data: 50 Civilizations
------------------------------------------------------------
INSERT INTO civilizations (slug, region, era_start, era_end) VALUES
-- AFRICA (5)
('ancient-egypt',        'Africa',      '3100 BC', '30 BC'),
('kingdom-of-kush',      'Africa',      '1070 BC', '350 BC'),
('carthage',             'Africa',      '814 BC',  '146 BC'),
('aksum-empire',         'Africa',      '100 BC',  '940 AD'),
('ghana-empire',         'Africa',      '300 AD',  '1200 AD'),

-- MESOPOTAMIA & MIDDLE EAST (8)
('sumer',                'Mesopotamia', '4500 BC', '1900 BC'),
('akkadian-empire',      'Mesopotamia', '2334 BC', '2154 BC'),
('babylonia',            'Mesopotamia', '1894 BC', '539 BC'),
('assyria',              'Mesopotamia', '2500 BC', '609 BC'),
('hittite-empire',       'Anatolia',    '1600 BC', '1178 BC'),
('phoenicia',            'Levant',      '1500 BC', '300 BC'),
('persian-empire',       'Persia',      '550 BC',  '330 BC'),
('urartu-kingdom',       'Armenia',     '860 BC',  '590 BC'),

-- EUROPE (12)
('ancient-greece',       'Europe',      '800 BC',  '146 BC'),
('roman-empire',         'Europe',      '27 BC',   '476 AD'),
('minoan-civilization',  'Europe',      '3000 BC', '1100 BC'),
('mycenaean-greece',     'Europe',      '1600 BC', '1100 BC'),
('etruscan-civilization','Europe',      '900 BC',  '27 BC'),
('celtic-tribes',        'Europe',      '1200 BC', '400 AD'),
('ancient-sparta',       'Europe',      '900 BC',  '192 BC'),
('ancient-athens',       'Europe',      '508 BC',  '322 BC'),
('macedonian-empire',    'Europe',      '808 BC',  '168 BC'),
('byzantine-empire',     'Europe',      '330 AD',  '1453 AD'),
('vikings',              'Europe',      '793 AD',  '1066 AD'),
('ancient-thrace',       'Europe',      '1000 BC', '46 BC'),

-- ASIA (15)
('shang-dynasty',        'Asia',        '1600 BC', '1046 BC'),
('zhou-dynasty',         'Asia',        '1046 BC', '256 BC'),
('qin-dynasty',          'Asia',        '221 BC',  '206 BC'),
('han-dynasty',          'Asia',        '206 BC',  '220 AD'),
('indus-valley',         'Asia',        '3300 BC', '1300 BC'),
('maurya-empire',        'Asia',        '322 BC',  '185 BC'),
('gupta-empire',         'Asia',        '320 AD',  '550 AD'),
('jomon-period',         'Asia',        '14000 BC','300 BC'),
('khmer-empire',         'Asia',        '802 AD',  '1431 AD'),
('silla-kingdom',        'Asia',        '57 BC',   '935 AD'),
('parthian-empire',      'Asia',        '247 BC',  '224 AD'),
('scythian-empire',      'Eurasia',     '900 BC',  '200 BC'),
('xiongnu-confederation','Asia',        '209 BC',  '93 AD'),
('silk-road-kingdoms',   'Asia',        '200 BC',  '1400 AD'),
('achaemenid-persia',    'Asia',        '550 BC',  '330 BC'),

-- AMERICAS (7)
('maya-civilization',    'Americas',    '2000 BC', '1500 AD'),
('aztec-empire',         'Americas',    '1345 AD', '1521 AD'),
('inca-empire',          'Americas',    '1438 AD', '1533 AD'),
('olmec-civilization',   'Americas',    '1500 BC', '400 BC'),
('moche-civilization',   'Americas',    '100 AD',  '800 AD'),
('toltec-civilization',  'Americas',    '900 AD',  '1168 AD'),
('nazca-civilization',   'Americas',    '100 BC',  '800 AD'),

-- OCEANIA & OTHER (3)
('ancient-polynesia',    'Oceania',     '1000 BC', '1800 AD'),
('easter-island',        'Oceania',     '300 AD',  '1600 AD'),
('aboriginal-australia', 'Oceania',     '50000 BC','Present')
ON CONFLICT (slug) DO NOTHING;


------------------------------------------------------------
-- 🎉 SETUP COMPLETE!
------------------------------------------------------------
-- Next steps:
-- 1. Add civilization_translations (names/descriptions for each language)
-- 2. Create stories and story_translations
-- 3. Configure Supabase Storage bucket for audio files
-- 4. Build your Swift app to consume this API!
------------------------------------------------------------
