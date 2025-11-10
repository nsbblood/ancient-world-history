-- =========================================================
-- MIGRATION: Add Audio Cache + Multi-Language Support
-- =========================================================
-- Bu script mevcut tablolara yeni kolonlar ekler
-- Güvenli: Varolan data'yı bozmaz
-- =========================================================

------------------------------------------------------------
-- 1️⃣ Add supported_languages table (if not exists)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS supported_languages (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  native_name TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  priority INT DEFAULT 0
);

INSERT INTO supported_languages (code, name, native_name, is_active, priority) VALUES
  ('en', 'English', 'English', true, 1),
  ('tr', 'Turkish', 'Türkçe', true, 2),
  ('de', 'German', 'Deutsch', true, 3),
  ('fr', 'French', 'Français', true, 4),
  ('es', 'Spanish', 'Español', true, 5)
ON CONFLICT (code) DO NOTHING;


------------------------------------------------------------
-- 2️⃣ Add missing columns to chapters table
------------------------------------------------------------
-- Add language_code column (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='chapters' AND column_name='language_code'
  ) THEN
    ALTER TABLE chapters ADD COLUMN language_code TEXT DEFAULT 'en';

    -- Add foreign key constraint
    ALTER TABLE chapters
    ADD CONSTRAINT fk_chapters_language
    FOREIGN KEY (language_code) REFERENCES supported_languages(code);
  END IF;
END $$;

-- Add audio_url column (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='chapters' AND column_name='audio_url'
  ) THEN
    ALTER TABLE chapters ADD COLUMN audio_url TEXT;
  END IF;
END $$;

-- Add audio_duration_seconds column (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='chapters' AND column_name='audio_duration_seconds'
  ) THEN
    ALTER TABLE chapters ADD COLUMN audio_duration_seconds INT;
  END IF;
END $$;

-- Add generation_status column (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='chapters' AND column_name='generation_status'
  ) THEN
    ALTER TABLE chapters ADD COLUMN generation_status TEXT DEFAULT 'pending';
  END IF;
END $$;

-- Add generated_at column (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='chapters' AND column_name='generated_at'
  ) THEN
    ALTER TABLE chapters ADD COLUMN generated_at TIMESTAMPTZ;
  END IF;
END $$;

-- Add created_at column (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='chapters' AND column_name='created_at'
  ) THEN
    ALTER TABLE chapters ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
END $$;


------------------------------------------------------------
-- 3️⃣ Update unique constraint for multi-language support
------------------------------------------------------------
-- Drop old constraint (if exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chapters_story_id_order_no_key'
  ) THEN
    ALTER TABLE chapters DROP CONSTRAINT chapters_story_id_order_no_key;
  END IF;
END $$;

-- Add new constraint with language_code
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'unique_story_chapter_language'
  ) THEN
    ALTER TABLE chapters
    ADD CONSTRAINT unique_story_chapter_language
    UNIQUE (story_id, order_no, language_code);
  END IF;
END $$;


------------------------------------------------------------
-- 4️⃣ Add indexes for performance
------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_chapters_lang ON chapters(language_code);
CREATE INDEX IF NOT EXISTS idx_chapters_status ON chapters(generation_status);
CREATE INDEX IF NOT EXISTS idx_chapters_story ON chapters(story_id);


------------------------------------------------------------
-- 5️⃣ Create user_listening_progress table
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
-- 6️⃣ Create user_favorites table
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, story_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_story ON user_favorites(story_id);


------------------------------------------------------------
-- 7️⃣ Create story_metrics table
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
CREATE INDEX IF NOT EXISTS idx_metrics_lang ON story_metrics(language_code);


------------------------------------------------------------
-- 8️⃣ Enable RLS on new tables
------------------------------------------------------------
ALTER TABLE user_listening_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_metrics ENABLE ROW LEVEL SECURITY;

-- Drop old policies (safe)
DROP POLICY IF EXISTS "users_manage_own_progress" ON user_listening_progress;
DROP POLICY IF EXISTS "users_manage_own_favorites" ON user_favorites;
DROP POLICY IF EXISTS "public_read_story_metrics" ON story_metrics;

-- Users manage their own data
CREATE POLICY "users_manage_own_progress"
  ON user_listening_progress FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_manage_own_favorites"
  ON user_favorites FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Public can read metrics
CREATE POLICY "public_read_story_metrics"
  ON story_metrics FOR SELECT USING (true);


------------------------------------------------------------
-- 9️⃣ Update existing chapters to have default values
------------------------------------------------------------
-- Set default language_code for existing chapters
UPDATE chapters
SET language_code = 'en'
WHERE language_code IS NULL;

-- Set default generation_status
UPDATE chapters
SET generation_status = 'completed'
WHERE audio_url IS NOT NULL AND generation_status IS NULL;

UPDATE chapters
SET generation_status = 'pending'
WHERE audio_url IS NULL AND generation_status IS NULL;


------------------------------------------------------------
-- 🎉 MIGRATION COMPLETE!
------------------------------------------------------------
-- Your existing data is preserved
-- New features are now available:
-- - Multi-language support (language_code)
-- - Audio caching (audio_url, generation_status)
-- - User progress tracking
-- - User favorites
-- - Story metrics/analytics
------------------------------------------------------------
