-- =========================================================
-- ANCIENT WORLD STORIES — STRUCTURE UPGRADE SCRIPT (v2.1)
-- =========================================================
-- Author: Enes & Claude
-- Date: 2025-11-10
-- Safe to run on existing DB (adds/updates only)
-- =========================================================

------------------------------------------------------------
-- 1️⃣ Safer Regeneration Logging (instead of hard block)
------------------------------------------------------------
DROP FUNCTION IF EXISTS _prevent_redundant_generation CASCADE;

CREATE OR REPLACE FUNCTION _log_regeneration_attempt()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.generation_status = 'completed' THEN
    RAISE WARNING 'Regenerating completed content: % (lang=%)', NEW.id, NEW.language_code;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_story_tr_no_regen ON story_translations;
CREATE TRIGGER trg_story_tr_no_regen
BEFORE UPDATE ON story_translations
FOR EACH ROW
WHEN (OLD.generation_status = 'completed')
EXECUTE FUNCTION _log_regeneration_attempt();

DROP TRIGGER IF EXISTS trg_chapter_tr_no_regen ON chapter_translations;
CREATE TRIGGER trg_chapter_tr_no_regen
BEFORE UPDATE ON chapter_translations
FOR EACH ROW
WHEN (OLD.generation_status = 'completed')
EXECUTE FUNCTION _log_regeneration_attempt();


------------------------------------------------------------
-- 2️⃣ Improved fetch functions (with joins)
------------------------------------------------------------
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
-- 3️⃣ Chapters: unique order per story
------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'unique_story_chapter_order'
  ) THEN
    ALTER TABLE chapters
    ADD CONSTRAINT unique_story_chapter_order UNIQUE (story_id, order_no);
  END IF;
END $$;


------------------------------------------------------------
-- 4️⃣ User Listening Progress (tracking playback)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_listening_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
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

-- Foreign key to auth.users
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_user_listening_progress_user'
  ) THEN
    ALTER TABLE user_listening_progress
    ADD CONSTRAINT fk_user_listening_progress_user
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;


------------------------------------------------------------
-- 5️⃣ User Favorites (wishlist system)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, story_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON user_favorites(user_id);

-- Foreign key to auth.users
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_user_favorites_user'
  ) THEN
    ALTER TABLE user_favorites
    ADD CONSTRAINT fk_user_favorites_user
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;


------------------------------------------------------------
-- 6️⃣ Story Metrics (analytics)
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


------------------------------------------------------------
-- 7️⃣ Civilizations: numeric era years for sorting
------------------------------------------------------------
ALTER TABLE civilizations
ADD COLUMN IF NOT EXISTS era_start_year INT,
ADD COLUMN IF NOT EXISTS era_end_year INT;


------------------------------------------------------------
-- 8️⃣ Complete RLS (Row Level Security) setup
------------------------------------------------------------
-- Enable RLS on all tables
ALTER TABLE story_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapter_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE civilizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE civilization_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_listening_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_metrics ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (safe, won't error if they don't exist)
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

-- Public read access (everyone can view content)
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

-- Authenticated users can update translations (AI regeneration)
CREATE POLICY "auth_update_story_translations"
  ON story_translations FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "auth_update_chapter_translations"
  ON chapter_translations FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "auth_update_story_metrics"
  ON story_metrics FOR UPDATE USING (auth.role() = 'authenticated');

-- Users can manage their own progress and favorites
CREATE POLICY "users_manage_own_progress"
  ON user_listening_progress FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_manage_own_favorites"
  ON user_favorites FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


------------------------------------------------------------
-- 9️⃣ Updated_at trigger for new tables
------------------------------------------------------------
CREATE OR REPLACE FUNCTION _touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_story_metrics_touch ON story_metrics;
CREATE TRIGGER trg_story_metrics_touch
BEFORE UPDATE ON story_metrics
FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();


------------------------------------------------------------
-- 🎉 SETUP COMPLETE
------------------------------------------------------------
-- Next steps:
-- 1. Run the main civilization seed SQL (50 civilizations)
-- 2. Add civilization_translations for each language
-- 3. Create stories + story_translations
-- 4. Configure Supabase Storage for audio files
------------------------------------------------------------
