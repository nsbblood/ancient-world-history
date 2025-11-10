-- =========================================================
-- SAMPLE STORIES - Starter Pack (5 Civilizations x 3 Stories)
-- =========================================================
-- Popüler medeniyetler için başlangıç hikayeleri
-- Her birinin chapters'ı AI ile generate edilecek
-- =========================================================

-- Get civilization IDs (we'll use them in stories)
DO $$
DECLARE
  egypt_id UUID;
  greece_id UUID;
  rome_id UUID;
  maya_id UUID;
  vikings_id UUID;
BEGIN
  -- Get IDs
  SELECT id INTO egypt_id FROM civilizations WHERE name = 'Ancient Egypt' LIMIT 1;
  SELECT id INTO greece_id FROM civilizations WHERE name = 'Ancient Greece' LIMIT 1;
  SELECT id INTO rome_id FROM civilizations WHERE name = 'Roman Empire' LIMIT 1;
  SELECT id INTO maya_id FROM civilizations WHERE name = 'Maya Civilization' LIMIT 1;
  SELECT id INTO vikings_id FROM civilizations WHERE name = 'Vikings' LIMIT 1;

  -- ANCIENT EGYPT STORIES (3)
  INSERT INTO stories (civilization_id, title, summary, chapters_count) VALUES
  (egypt_id, 'The Young Pharaoh''s Decision', 'A teenage pharaoh must choose between tradition and innovation as he faces his first major crisis.', 8),
  (egypt_id, 'The Architect''s Dream', 'A visionary architect designs the first true pyramid, defying centuries of tradition.', 10),
  (egypt_id, 'Secrets of the Scribe', 'A royal scribe discovers ancient texts that could change Egypt''s destiny.', 12);

  -- ANCIENT GREECE STORIES (3)
  INSERT INTO stories (civilization_id, title, summary, chapters_count) VALUES
  (greece_id, 'The Philosopher''s Question', 'A young student in Athens questions everything, even the gods themselves.', 9),
  (greece_id, 'Olympic Champion', 'An underdog athlete trains for glory in the ancient Olympic Games.', 8),
  (greece_id, 'The Oracle''s Prophecy', 'A priestess at Delphi receives a vision that could prevent war—or start one.', 10);

  -- ROMAN EMPIRE STORIES (3)
  INSERT INTO stories (civilization_id, title, summary, chapters_count) VALUES
  (rome_id, 'Gladiator''s Honor', 'A captured warrior fights not just for survival, but for freedom and dignity.', 11),
  (rome_id, 'The Senator''s Dilemma', 'A Roman senator must choose between loyalty to Caesar and the Republic.', 9),
  (rome_id, 'Roads of Empire', 'An engineer''s ambitious project connects distant provinces, changing Rome forever.', 10);

  -- MAYA CIVILIZATION STORIES (3)
  INSERT INTO stories (civilization_id, title, summary, chapters_count) VALUES
  (maya_id, 'The Calendar Keeper', 'A brilliant mathematician discovers a celestial event that will change Maya understanding of time.', 12),
  (maya_id, 'Jaguar Warrior', 'A young warrior must prove himself in battle to protect his city from rival kingdoms.', 10),
  (maya_id, 'The Sacred Ball Game', 'A champion player discovers the ball game is more than sport—it''s a matter of life and death.', 8);

  -- VIKINGS STORIES (3)
  INSERT INTO stories (civilization_id, title, summary, chapters_count) VALUES
  (vikings_id, 'Voyage to Vinland', 'A bold expedition sails west, discovering lands beyond anyone''s imagination.', 11),
  (vikings_id, 'The Shield Maiden', 'A woman warrior defies tradition to lead her own raiding party.', 9),
  (vikings_id, 'Skald''s Tale', 'A storyteller must remember and recite his people''s history before it''s lost forever.', 10);

  RAISE NOTICE 'Successfully added 15 sample stories across 5 civilizations!';
END $$;

-- Verify
SELECT
  c.name as civilization,
  COUNT(s.id) as story_count
FROM civilizations c
LEFT JOIN stories s ON s.civilization_id = c.id
WHERE c.name IN ('Ancient Egypt', 'Ancient Greece', 'Roman Empire', 'Maya Civilization', 'Vikings')
GROUP BY c.name
ORDER BY c.name;
