-- ========================================
-- SUPABASE DATA IMPORT - Ancient World Stories
-- ========================================
-- Tüm civilizations, stories ve chapters'ları ekler
-- Kullanım: Supabase SQL Editor'de çalıştırın

-- 1. CIVILIZATIONS
INSERT INTO civilizations (id, name, era_start, era_end, region, description) VALUES
('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Ancient Mesopotamia', '3500 BC', '539 BC', 'Middle East', 'The cradle of civilization, home to the Sumerians, Akkadians, Babylonians, and Assyrians.'),
('550e8400-e29b-41d4-a716-446655440000', 'Ancient Egypt', '3100 BC', '30 BC', 'North Africa', 'Land of the pharaohs, pyramids, and hieroglyphs.'),
('6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'Ancient Greece', '800 BC', '146 BC', 'Mediterranean', 'Birthplace of democracy, philosophy, and Olympic games.')
ON CONFLICT (id) DO NOTHING;

-- 2. STORIES
INSERT INTO stories (id, civilization_id, title, summary, chapters_count) VALUES
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', 'The Scribe of Uruk', 'A young scribe discovers ancient texts that could change the course of history.', 12),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', '550e8400-e29b-41d4-a716-446655440000', 'Pharaoh''s Dream', 'A royal architect navigates palace intrigue while building monuments to the gods.', 10),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', '6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'The Oracle''s Vision', 'A priestess receives visions that challenge everything she believes.', 8)
ON CONFLICT (id) DO NOTHING;

-- 3. CHAPTERS (30 total)

-- Story 1: The Scribe of Uruk (12 chapters)
INSERT INTO chapters (story_id, title, order_no, text, duration, language_code) VALUES
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The First Lesson', 1, 'The morning sun painted the ziggurat in hues of amber and gold. Young Nammu clutched his clay tablet, fingers trembling with anticipation. Today, he would learn his first cuneiform signs from Master Enki, the most renowned scribe in all of Uruk. The weight of tradition pressed upon his shoulders—his family had been scribes for seven generations.', 45, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The Sacred Signs', 2, 'Master Enki''s weathered hands moved with practiced grace across the wet clay. ''Each mark tells a story,'' he explained, his voice like distant thunder. ''The wedge is not merely a line—it is the voice of the gods made visible.'' Nammu watched in awe as the master created signs for water, life, and eternity.', 50, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'Temple Secrets', 3, 'The temple library was forbidden to novice scribes, yet here Nammu stood at midnight. Master Enki had given him a key and a warning: ''Some knowledge changes those who find it.'' By lamplight, Nammu discovered tablets far older than any he''d studied, speaking of times before the great flood.', 48, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The King''s Decree', 4, 'Nammu was summoned to the palace at dawn. King Ur-Nammu needed a scribe he could trust. ''The priests control what is written, what is remembered. I need someone who will record the truth.'' It was an honor—and a death sentence if the priests discovered his role.', 46, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'Betrayal at Dawn', 5, 'Nammu woke to find Master Enki''s quarters ransacked. ''They know you took the tablet,'' Enki said calmly. ''Because I told them—to protect you.'' The old master smiled once more, then was led away by guards into the morning light, taking the blame upon himself.', 52, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'A Scribe''s Duty', 6, 'Alone now, Nammu threw himself into palace work. A merchant approached in secret: ''The priests are altering temple records to humiliate the king.'' Nammu faced a choice—stay silent or create his own true accounting, even if it cost him everything.', 49, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The Public Trial', 7, 'The confrontation came at the temple steps before all of Uruk. Nammu stepped forward with his tablets: ''These are the true records.'' Master Enki emerged from the crowd, somehow freed. ''He is what every scribe should be—a servant of truth.'' The king examined both sets. Justice would prevail.', 51, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'New Beginnings', 8, 'The dishonest priests were exiled. The king offered Nammu wealth and prestige, but he asked instead to train a new generation of scribes. Not just technical skills, but the moral courage to use them wisely. His true legacy would be in the scribes he inspired.', 53, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The Student Becomes Master', 9, 'Years passed. Nammu''s hair grayed and his school flourished. Students came from all walks of life. ''What is most important to write?'' a young student asked. ''The truth,'' Nammu answered. ''Even when difficult. Especially when difficult. Words in clay can outlast empires.''', 48, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'Legacy in Clay', 10, 'On his final day, Nammu pressed his stylus into one last tablet: ''To whoever reads this, you hold the power of memory. Use it wisely. Use it justly. We write not for kings or gods, but for truth itself.'' He sealed it in the school''s foundation. Centuries later, archaeologists would marvel at this timeless wisdom.', 54, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'The Archive', 11, 'Before his passing, Nammu organized all his work into a great archive. Each tablet carefully labeled, each story preserved. His students helped catalog thousands of texts, creating the first library of Uruk.', 43, 'en-US'),
('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'Eternal Words', 12, 'The final tablet was placed. Nammu''s legacy was complete. The scribal school would continue for centuries, training generation after generation in the sacred art of writing truth.', 41, 'en-US')
ON CONFLICT (story_id, order_no) DO NOTHING;

-- Story 2: Pharaoh's Dream (10 chapters)
INSERT INTO chapters (story_id, title, order_no, text, duration, language_code) VALUES
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'The Architect''s Vision', 1, 'Ahmose stood before Pharaoh Thutmose III, his papyrus designs trembling. The proposed temple would be the largest ever built to Amun-Ra. ''Can it be done?'' the Pharaoh asked. ''Yes, Great One,'' Ahmose replied, though doubt gnawed at his heart. Success would bring glory, failure meant death.', 47, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'The Quarry Master''s Deal', 2, 'The limestone quarries at Tura held the finest stone in Egypt. Khenti the quarry master was known for his greed. Ahmose offered him something gold couldn''t buy: immortality through his name inscribed on temple walls.', 49, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'Divine Alignment', 3, 'The temple must align perfectly with the stars. Ahmose spent nights studying the heavens with the priests. Every calculation had to be perfect—the gods would know if even a finger''s width was wrong.', 46, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'Workers'' Revolt', 4, 'The heat was unbearable. Workers threatened to abandon the site. Ahmose faced a crisis—the Pharaoh''s deadline approached, but pushing harder might cause a riot. He had to find a way to inspire rather than intimidate.', 51, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'The First Column', 5, 'After months of preparation, the first massive column was raised. It took three hundred men and a complex system of ropes and levers. As it settled into place, perfectly vertical, Ahmose allowed himself a moment of hope.', 48, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'Palace Intrigue', 6, 'A rival architect whispered poison in the Pharaoh''s ear. ''The temple is behind schedule. Ahmose wastes resources.'' The accusation was both true and false. Ahmose had to defend his vision without offending the divine ruler.', 52, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'The Painted Walls', 7, 'Artists arrived to paint the interior walls with scenes of the gods. Ahmose watched as blank stone transformed into a riot of color—blues from lapis, golds from precious metals, reds from ochre. The temple was coming alive.', 50, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'The Dedication', 8, 'Ten years to the day from when he began, the temple was complete. Pharaoh Thutmose walked through its halls in silent awe. Ahmose held his breath. Finally, the Pharaoh spoke: ''You have made me immortal.''', 54, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'The Price of Glory', 9, 'In the celebration''s aftermath, Ahmose stood alone in the completed temple. He thought of the workers who died in construction, the families separated, the compromises made. Glory, he realized, always had a cost.', 49, 'en-US'),
('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'Eternal Stone', 10, 'Millennia would pass. Empires would rise and fall. But the temple would stand, a testament not to one Pharaoh''s glory, but to the thousands who labored to build it. Ahmose''s name, carved in a quiet corner, would endure.', 47, 'en-US')
ON CONFLICT (story_id, order_no) DO NOTHING;

-- Story 3: The Oracle's Vision (8 chapters)
INSERT INTO chapters (story_id, title, order_no, text, duration, language_code) VALUES
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'The First Vision', 1, 'Pythia drew in the sacred vapors rising from Apollo''s temple. The world dissolved into light and shadow. She saw armies marching, ships burning, Athens consumed by war. ''Beware the wooden horse,'' she whispered, though she had no idea what it meant.', 51, 'en-US'),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'The Athenian General', 2, 'General Themistocles arrived demanding clarity. ''What does Apollo say about the Persian invasion?'' But the gods spoke in riddles. Pythia struggled to make sense of her visions, knowing wrong advice could doom Athens.', 48, 'en-US'),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'Doubt and Faith', 3, 'Between visions, Pythia was just a woman named Theodora. She doubted herself, questioned the gods. Were the visions real or just vapors playing tricks on her mind? Yet thousands trusted her words to guide their fates.', 50, 'en-US'),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'The Wooden Walls', 4, 'The vision came clearer: ''Only wooden walls shall save Athens.'' Themistocles understood—not city walls, but ships! He would build a fleet. Pythia''s cryptic prophecy had just changed history.', 46, 'en-US'),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'The Sacred Madness', 5, 'The vapors took their toll. Each vision left Pythia weaker, more disconnected from reality. Other priestesses whispered that she was losing herself to the sacred madness. But the visions were clearer than ever.', 52, 'en-US'),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'Salamis', 6, 'News arrived: Athens had won! The wooden walls—the ships—had defeated the Persian fleet at Salamis. Pythia''s prophecy had saved Greece. But she felt no joy, only exhaustion and the weight of lives she''d helped end.', 49, 'en-US'),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'The Price of Sight', 7, 'Ten years as Pythia had aged her thirty. The vapors, the visions, the burden of prophecy—all took their toll. She asked the high priest to be released, but he refused. ''Apollo has chosen you. The choice is not yours to make.''', 53, 'en-US'),
('c3d4e5f6-a7b8-4c5d-9e0f-2a3b4c5d6e7f', 'The Final Prophecy', 8, 'On her last day, Pythia saw her own death in the vapors. She smiled—finally, clarity without riddles. She gave one final prophecy, then descended the temple steps for the last time, choosing her own path at last.', 47, 'en-US')
ON CONFLICT (story_id, order_no) DO NOTHING;

-- Verify import
SELECT 
    (SELECT COUNT(*) FROM civilizations) as civilizations_count,
    (SELECT COUNT(*) FROM stories) as stories_count,
    (SELECT COUNT(*) FROM chapters) as chapters_count;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Import completed successfully!';
    RAISE NOTICE 'Civilizations: 3, Stories: 3, Chapters: 30';
END $$;
