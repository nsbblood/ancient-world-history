-- =========================================================
-- ANCIENT WORLD STORIES — FINAL SETUP (Basit + Çoklu Dil)
-- =========================================================
-- Eski basit yapı + Audio cache + Çoklu dil desteği
-- =========================================================

------------------------------------------------------------
-- 1️⃣ Supported Languages
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
-- 2️⃣ Civilizations (Basit Yapı - Eski Halini Koruyoruz)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS civilizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  era_start TEXT,
  era_end TEXT,
  region TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_civilizations_name ON civilizations(name);
CREATE INDEX IF NOT EXISTS idx_civilizations_region ON civilizations(region);


------------------------------------------------------------
-- 3️⃣ Stories (Basit Yapı)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  civilization_id UUID REFERENCES civilizations(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  summary TEXT,
  chapters_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stories_civ ON stories(civilization_id);


------------------------------------------------------------
-- 4️⃣ Chapters (Basit Yapı + language_code)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  order_no INT NOT NULL,
  text TEXT NOT NULL,
  duration INT,
  language_code TEXT DEFAULT 'en' REFERENCES supported_languages(code),
  audio_url TEXT,
  audio_duration_seconds INT,
  generation_status TEXT DEFAULT 'pending',
  generated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(story_id, order_no, language_code)
);

CREATE INDEX IF NOT EXISTS idx_chapters_story ON chapters(story_id);
CREATE INDEX IF NOT EXISTS idx_chapters_order ON chapters(order_no);
CREATE INDEX IF NOT EXISTS idx_chapters_lang ON chapters(language_code);
CREATE INDEX IF NOT EXISTS idx_chapters_status ON chapters(generation_status);


------------------------------------------------------------
-- 5️⃣ User Listening Progress
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


------------------------------------------------------------
-- 6️⃣ User Favorites
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
-- 7️⃣ Story Metrics
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
-- 8️⃣ RLS Policies
------------------------------------------------------------

-- Enable RLS
ALTER TABLE civilizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_listening_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_metrics ENABLE ROW LEVEL SECURITY;

-- Drop old policies
DROP POLICY IF EXISTS "public_read_civilizations" ON civilizations;
DROP POLICY IF EXISTS "public_read_stories" ON stories;
DROP POLICY IF EXISTS "public_read_chapters" ON chapters;
DROP POLICY IF EXISTS "public_read_story_metrics" ON story_metrics;
DROP POLICY IF EXISTS "auth_update_chapters" ON chapters;
DROP POLICY IF EXISTS "users_manage_own_progress" ON user_listening_progress;
DROP POLICY IF EXISTS "users_manage_own_favorites" ON user_favorites;

-- Public read access
CREATE POLICY "public_read_civilizations"
  ON civilizations FOR SELECT USING (true);

CREATE POLICY "public_read_stories"
  ON stories FOR SELECT USING (true);

CREATE POLICY "public_read_chapters"
  ON chapters FOR SELECT USING (true);

CREATE POLICY "public_read_story_metrics"
  ON story_metrics FOR SELECT USING (true);

-- Authenticated users can update (for AI generation)
CREATE POLICY "auth_update_chapters"
  ON chapters FOR UPDATE USING (auth.role() = 'authenticated');

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
-- 9️⃣ Seed Data: 50 Civilizations
------------------------------------------------------------
INSERT INTO civilizations (name, era_start, era_end, region, description) VALUES
-- AFRICA (5)
('Ancient Egypt', '3100 BC', '30 BC', 'Africa', 'One of the world''s oldest civilizations along the Nile River, famous for pyramids, pharaohs, and hieroglyphics.'),
('Kingdom of Kush', '1070 BC', '350 BC', 'Africa', 'Nubian kingdom known for powerful queens, pyramids, and trade with Egypt.'),
('Carthage', '814 BC', '146 BC', 'Africa', 'Phoenician city-state and maritime empire, rival of Rome in the Punic Wars.'),
('Kingdom of Aksum', '100 BC', '940 AD', 'Africa', 'Ancient African kingdom known for trade, unique architecture, and early Christianity.'),
('Ancient Ghana Empire', '300 AD', '1200 AD', 'Africa', 'West African empire controlling trans-Saharan gold and salt trade.'),

-- MIDDLE EAST (8)
('Sumer', '4500 BC', '1900 BC', 'Mesopotamia', 'World''s first known civilization, inventors of writing, the wheel, and complex irrigation.'),
('Akkadian Empire', '2334 BC', '2154 BC', 'Mesopotamia', 'First ancient empire of Mesopotamia, ruled by Sargon the Great.'),
('Babylonia', '1894 BC', '539 BC', 'Mesopotamia', 'Mesopotamian empire famous for Hammurabi''s Code and the Hanging Gardens.'),
('Assyria', '2500 BC', '609 BC', 'Mesopotamia', 'Powerful military empire known for advanced warfare and impressive libraries.'),
('Hittite Empire', '1600 BC', '1178 BC', 'Anatolia', 'Ancient Anatolia civilization, early masters of iron working and chariot warfare.'),
('Phoenicia', '1500 BC', '300 BC', 'Levant', 'Maritime civilization famous for creating the alphabet and purple dye trade.'),
('Persian Empire', '550 BC', '330 BC', 'Persia', 'Vast empire stretching from India to Greece, known for tolerance and advanced administration.'),
('Kingdom of Urartu', '860 BC', '590 BC', 'Armenia', 'Ancient kingdom in Armenian highlands known for advanced metallurgy and fortresses.'),

-- EUROPE (12)
('Ancient Greece', '800 BC', '146 BC', 'Europe', 'Birthplace of democracy, philosophy, Olympic Games, and Western civilization.'),
('Roman Empire', '27 BC', '476 AD', 'Europe', 'One of history''s greatest empires, lasting over 1000 years with lasting cultural impact.'),
('Minoan Civilization', '3000 BC', '1100 BC', 'Europe', 'Bronze Age civilization on Crete, known for palaces, frescoes, and Linear A script.'),
('Mycenaean Greece', '1600 BC', '1100 BC', 'Europe', 'Bronze Age Greek civilization, setting of Trojan War legends.'),
('Etruscan Civilization', '900 BC', '27 BC', 'Europe', 'Pre-Roman Italian culture that influenced early Rome''s art, architecture, and religion.'),
('Celtic Tribes', '1200 BC', '400 AD', 'Europe', 'Iron Age peoples across Europe known for art, druidic religion, and warrior culture.'),
('Ancient Sparta', '900 BC', '192 BC', 'Europe', 'Greek city-state famous for military prowess and disciplined warrior society.'),
('Ancient Athens', '508 BC', '322 BC', 'Europe', 'Greek city-state, birthplace of democracy, philosophy, and classical arts.'),
('Macedonian Empire', '808 BC', '168 BC', 'Europe', 'Kingdom of Alexander the Great, spreading Hellenistic culture across three continents.'),
('Byzantine Empire', '330 AD', '1453 AD', 'Europe', 'Eastern Roman Empire preserving classical knowledge through the Middle Ages.'),
('Vikings', '793 AD', '1066 AD', 'Europe', 'Norse seafarers, explorers, and traders who reached America before Columbus.'),
('Ancient Thrace', '1000 BC', '46 BC', 'Europe', 'Balkan civilization known for skilled horsemen, gold craftsmanship, and Orpheus legends.'),

-- ASIA (15)
('Shang Dynasty', '1600 BC', '1046 BC', 'Asia', 'Early Chinese dynasty known for bronze work, oracle bones, and early writing.'),
('Zhou Dynasty', '1046 BC', '256 BC', 'Asia', 'Longest-lasting Chinese dynasty, era of Confucius and philosophical development.'),
('Qin Dynasty', '221 BC', '206 BC', 'Asia', 'United China, built Great Wall, created Terracotta Army.'),
('Han Dynasty', '206 BC', '220 AD', 'Asia', 'Golden age of Chinese civilization, opened Silk Road trade.'),
('Indus Valley Civilization', '3300 BC', '1300 BC', 'Asia', 'Advanced Bronze Age urban civilization with sophisticated city planning.'),
('Maurya Empire', '322 BC', '185 BC', 'Asia', 'First Indian empire to unite most of the subcontinent under Ashoka the Great.'),
('Gupta Empire', '320 AD', '550 AD', 'Asia', 'Golden age of Indian culture, mathematics, astronomy, and arts.'),
('Jomon Period', '14000 BC', '300 BC', 'Asia', 'Ancient Japanese culture with world''s oldest pottery and hunter-gatherer society.'),
('Khmer Empire', '802 AD', '1431 AD', 'Asia', 'Southeast Asian empire that built Angkor Wat, world''s largest religious monument.'),
('Silla Kingdom', '57 BC', '935 AD', 'Asia', 'Korean kingdom known for gold crowns, Buddhism, and cultural achievements.'),
('Parthian Empire', '247 BC', '224 AD', 'Asia', 'Iranian empire that blocked Roman expansion and controlled Silk Road trade.'),
('Scythian Empire', '900 BC', '200 BC', 'Eurasia', 'Nomadic warriors and skilled horsemen of the Eurasian steppes.'),
('Xiongnu Confederation', '209 BC', '93 AD', 'Asia', 'Ancient nomadic confederation that challenged Han China and influenced Hun migrations.'),
('Silk Road Kingdoms', '200 BC', '1400 AD', 'Asia', 'City-states along the ancient trade route connecting East and West.'),
('Achaemenid Persia', '550 BC', '330 BC', 'Asia', 'First Persian Empire under Cyrus the Great, known for religious tolerance.'),

-- AMERICAS (7)
('Maya Civilization', '2000 BC', '1500 AD', 'Americas', 'Advanced Mesoamerican culture known for calendar, mathematics, and hieroglyphic writing.'),
('Aztec Empire', '1345 AD', '1521 AD', 'Americas', 'Powerful Mesoamerican empire with capital Tenochtitlan, advanced agriculture and architecture.'),
('Inca Empire', '1438 AD', '1533 AD', 'Americas', 'Largest pre-Columbian empire in Americas, master engineers and administrators.'),
('Olmec Civilization', '1500 BC', '400 BC', 'Americas', 'Mother culture of Mesoamerica, famous for colossal stone heads.'),
('Moche Civilization', '100 AD', '800 AD', 'Americas', 'Peruvian culture known for elaborate ceramics, irrigation, and pyramid temples.'),
('Toltec Civilization', '900 AD', '1168 AD', 'Americas', 'Mesoamerican culture that influenced later Aztecs, known for warrior traditions.'),
('Nazca Civilization', '100 BC', '800 AD', 'Americas', 'Peruvian culture famous for mysterious geoglyphs visible only from the air.'),

-- OCEANIA (3)
('Ancient Polynesia', '1000 BC', '1800 AD', 'Oceania', 'Master navigators who settled Pacific islands using stars and ocean currents.'),
('Rapa Nui (Easter Island)', '300 AD', '1600 AD', 'Oceania', 'Isolated island culture famous for massive moai stone statues.'),
('Aboriginal Australian Cultures', '50000 BC', 'Present', 'Oceania', 'World''s oldest continuous cultures with rich oral traditions and art.')
ON CONFLICT DO NOTHING;


------------------------------------------------------------
-- 🎉 SETUP COMPLETE!
------------------------------------------------------------
-- Next steps:
-- 1. Run this SQL in Supabase SQL Editor
-- 2. Import your stories and chapters
-- 3. For multi-language support, insert chapters with different language_code
-- 4. Audio URLs will be populated when first user plays each chapter
------------------------------------------------------------
