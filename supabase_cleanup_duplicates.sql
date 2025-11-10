-- =========================================================
-- CLEANUP: Remove Duplicate Civilizations
-- =========================================================
-- Keep only one copy of each civilization (the first one)
-- =========================================================

-- First, let's see the duplicates
SELECT name, COUNT(*) as count
FROM civilizations
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY count DESC;

-- Delete duplicates, keep the oldest (first inserted)
DELETE FROM civilizations a USING civilizations b
WHERE a.id > b.id
  AND a.name = b.name;

-- Verify the count
SELECT COUNT(*) as total_civilizations FROM civilizations;

-- Show all unique civilizations
SELECT name, region, era_start, era_end
FROM civilizations
ORDER BY region, name;
