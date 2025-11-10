-- =========================================================
-- CHAPTERS PACK 1: Ancient Egypt Stories (18 Chapters Total)
-- =========================================================
-- Story 1: The Young Pharaoh's Decision (8 chapters)
-- Story 2: The Architect's Dream (10 chapters)
-- =========================================================

DO $$
DECLARE
  story1_id UUID; -- The Young Pharaoh's Decision
  story2_id UUID; -- The Architect's Dream
BEGIN
  -- Get story IDs
  SELECT id INTO story1_id FROM stories WHERE title = 'The Young Pharaoh''s Decision' LIMIT 1;
  SELECT id INTO story2_id FROM stories WHERE title = 'The Architect''s Dream' LIMIT 1;

  -- ========================================
  -- STORY 1: The Young Pharaoh's Decision
  -- ========================================

  INSERT INTO chapters (story_id, title, order_no, text, duration, language_code, generation_status) VALUES

  (story1_id, 'The Throne Room', 1,
   'The golden throne felt too large for fifteen-year-old Tutankhamun. Just three months since his father''s death, and already the priests demanded answers he didn''t have. High Priest Amenhotep''s voice echoed through the vast chamber: "Great Pharaoh, the Nile floods grow weaker each year. The people starve. The old gods are angry." Tut gripped the carved armrests. His father had abandoned the old gods for Aten alone. Should he continue that path, or return to tradition? Outside, thousands awaited his decision.',
   52, 'en', 'pending'),

  (story1_id, 'The Royal Adviser', 2,
   'General Horemheb had served three pharaohs. His weathered face showed no emotion as Tut asked for counsel. "Your father''s reforms divided Egypt, young majesty. The priests hold real power—deny them at your peril." But Tut''s mother had whispered different advice before she died: "Power lies not in pleasing everyone, but in choosing wisely what you stand for." At night, Tut studied scrolls by lamplight, searching for wisdom beyond his years.',
   49, 'en', 'pending'),

  (story1_id, 'Among the People', 3,
   'Disguised in simple linen, Tut slipped past the guards. In Memphis'' dusty streets, he heard what his advisers never told him. A mother mourned her starving child. Merchants complained of unfair taxes. An old priest blessed families at a small shrine to Osiris—worship his father had forbidden. "The boy-king doesn''t understand," one farmer said. "We don''t hate change. We hate chaos." Tut finally understood: the people didn''t want revolution or tradition. They wanted stability.',
   54, 'en', 'pending'),

  (story1_id, 'The Dream of the Gods', 4,
   'That night, fever gripped the young pharaoh. In his dreams, he stood in a vast temple. The god Amun-Ra appeared as blinding light: "I do not demand you abandon truth for tradition. I ask only that you see your people." His father appeared next, looking sad: "I tried to force change too quickly. Learn from my mistake." When Tut woke, his decision was clear—but executing it would be dangerous.',
   48, 'en', 'pending'),

  (story1_id, 'The Announcement', 5,
   'Tut called both the old priests and his father''s reformed advisers to the throne room. His voice cracked as he spoke, but his words were firm: "We will honor all gods, old and new. Temples will reopen, but we will not destroy what my father built. Change will come slowly, with wisdom." High Priest Amenhotep smiled victoriously. General Horemheb looked concerned. But Tut saw something else—hope in the eyes of the common scribes and servants.',
   51, 'en', 'pending'),

  (story1_id, 'The First Test', 6,
   'Two weeks later, a crisis. Nomadic raiders attacked a border village. Horemheb demanded military response. The priests suggested prayer and tribute. Tut proposed a third way: negotiate, but station troops nearby as deterrent. "Show strength through wisdom," he said. The plan worked. The raiders accepted a trade agreement. For the first time, his advisers looked at him not as a child, but as a pharaoh.',
   53, 'en', 'pending'),

  (story1_id, 'The Harvest Festival', 7,
   'Six months into his reign, the Nile''s flood returned—not as strong as ancient times, but adequate. During the harvest festival, Tut walked among his people without disguise. Children reached up to touch his hand. An old woman blessed him: "You gave us back our gods without taking away our future." That night, alone in his chambers, the young pharaoh finally felt the weight of the crown not as burden, but as purpose.',
   50, 'en', 'pending'),

  (story1_id, 'Legacy', 8,
   'Years later, Tutankhamun would be remembered more for his tomb than his reign. But those who lived through those first crucial years knew the truth. The boy-king who could have torn Egypt apart instead chose to heal it. His greatest monument wasn''t gold or stone—it was wisdom beyond his years, and the courage to forge a new path between the old and new. Egypt endured because a teenager learned to listen before commanding.',
   55, 'en', 'pending');

  -- ========================================
  -- STORY 2: The Architect's Dream
  -- ========================================

  INSERT INTO chapters (story_id, title, order_no, text, duration, language_code, generation_status) VALUES

  (story2_id, 'The Impossible Dream', 1,
   'Imhotep stood before the sand model he''d built in secret for three years. A tomb, yes—but unlike any Egypt had seen. Not a flat mastaba, but steps ascending to the sky. A mountain made by human hands. His master, the royal architect, laughed when Imhotep finally showed him. "The gods will not allow it. Stone cannot be stacked so high without collapsing." But Pharaoh Djoser needed a tomb that would surpass all others. Tomorrow, Imhotep would present his impossible design.',
   56, 'en', 'pending'),

  (story2_id, 'The Presentation', 2,
   'The court fell silent as Imhotep unveiled the model. Six massive steps, each smaller than the one below, creating a stairway to heaven. "It can''t be done," said the High Priest. "The weight alone would crush the lower levels." Imhotep had prepared for this. He showed calculations based on new techniques—internal buttressing, weight distribution, a revolutionary design. Pharaoh Djoser leaned forward, eyes gleaming. "How long?" he asked. "Twenty years, Great One." "You have fifteen. Begin."',
   51, 'en', 'pending'),

  (story2_id, 'The Quarry Master''s Doubt', 3,
   'At the Tura limestone quarries, Imhotep faced his first challenge. The quarry master, a man twice his age, crossed his arms. "I''ve cut stone for thirty years. Your design requires blocks three times heavier than we''ve ever moved. It''s suicide for my workers." Imhotep didn''t argue. Instead, he showed the master his designs for new sledges, rollers made from palm logs, and ramps that would evolve as the structure rose. "Trust me," Imhotep said. "We''ll invent new methods together."',
   54, 'en', 'pending'),

  (story2_id, 'The Foundation', 4,
   'The first year was spent on what no one would see—the foundation. Imhotep insisted on digging deep into bedrock, creating a base that could support unimaginable weight. Workers grumbled. The Pharaoh sent messages demanding visible progress. But Imhotep refused to rush. "A pyramid built on sand will crumble. One built on stone will outlast empires." When the foundation was finally complete, even the skeptics admitted it was the most solid structure they''d ever seen.',
   52, 'en', 'pending'),

  (story2_id, 'The First Step', 5,
   'Three years in, the first platform was complete. For the first time, Imhotep''s vision became real—a massive square of limestone, perfectly level, gleaming white in the sun. The dedication ceremony drew thousands. Even Imhotep''s former master attended, shaking his head in wonder. "I doubted you," he admitted. "I still don''t fully understand how it stands." Imhotep smiled. "Neither do I, completely. We''re learning as we build. This is only the beginning."',
   49, 'en', 'pending'),

  (story2_id, 'The Crisis', 6,
   'Year seven brought disaster. Heavy rains—rare in Egypt—weakened part of the third level. At dawn, workers heard a terrible crack. A section of the northern face collapsed, killing twelve men. The court demanded Imhotep''s head. But the architect climbed into the damaged structure, studying how it failed. For three days, he didn''t sleep. Then he emerged with new designs—internal support walls, hidden chambers that would distribute weight more safely. The Pharaoh gave him one more chance.',
   55, 'en', 'pending'),

  (story2_id, 'The Fifth Step', 7,
   'Year twelve. Five of six steps complete. The pyramid now dominated the Saqqara plateau, visible from miles away. Merchants came from distant lands just to witness it. Other architects begged Imhotep to share his techniques. He refused no one, training a generation of builders who would transform Egypt. But privately, he worried. The final step was the most dangerous—the smallest platform at the pyramid''s peak, where one mistake could topple everything below.',
   53, 'en', 'pending'),

  (story2_id, 'The Final Block', 8,
   'Year fourteen, three months. Only the capstone remained. Pharaoh Djoser had grown old, his health failing. The entire kingdom held its breath. Using a system of ramps that had taken months to construct, workers hauled the final limestone block to the summit. Imhotep himself guided it into place. When it settled—perfectly level, completing the step pyramid—a roar erupted from ten thousand throats. Egypt had its first true pyramid. Architecture would never be the same.',
   51, 'en', 'pending'),

  (story2_id, 'The Teacher', 9,
   'Imhotep spent his final years not building, but teaching. Students came from across Egypt to study with the master. He shared everything—his failures as openly as his successes. "The pyramid''s real lesson," he told them, "isn''t that we built something tall. It''s that we believed impossible things could become possible through careful thought, persistent effort, and willingness to learn from mistakes." His students would build the great pyramids of Giza. But it started here, with one man''s dream.',
   57, 'en', 'pending'),

  (story2_id, 'Eternal Steps', 10,
   'Four thousand years later, Djoser''s step pyramid still stands at Saqqara—the oldest large-scale stone structure in the world. Tourists marvel at the pyramids of Giza, not knowing they were made possible by Imhotep''s first bold experiment. The architect himself was deified after death, worshipped as a god of wisdom and medicine. But his true immortality lives in every ambitious builder who looks at the impossible and thinks: "I can find a way." The steps still reach toward heaven.',
   58, 'en', 'pending');

  RAISE NOTICE 'Successfully added 18 chapters for 2 Egyptian stories!';
END $$;

-- Verify the chapters
SELECT
  s.title as story,
  COUNT(c.id) as chapter_count,
  c.language_code
FROM stories s
LEFT JOIN chapters c ON c.story_id = s.id
WHERE s.title IN ('The Young Pharaoh''s Decision', 'The Architect''s Dream')
GROUP BY s.title, c.language_code
ORDER BY s.title;
