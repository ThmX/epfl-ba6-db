-- List all Olympians who won medals for multiple nations.

SELECT DISTINCT a.name, c1.country_id, c1.country_name, c2.country_id, c2.country_name
FROM athletes a, 
  (
    SELECT p.athlete_id as medalist_id, c.id as country_id, c.name as country_name 
    FROM representant_participates_event p, countries c
    WHERE p.ranking != 0 AND p.country_id = c.id
  ) c1,
  (
    SELECT p.athlete_id as medalist_id, c.id as country_id, c.name as country_name
    FROM representant_participates_event p, countries c 
    WHERE p.ranking != 0 AND p.country_id = c.id
  ) c2
WHERE c1.medalist_id = c2.medalist_id AND a.id = c1.medalist_id AND c1.country_id < c2.country_id