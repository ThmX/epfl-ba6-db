-- List all events for which all medals are won by athletes from the same country.

SELECT d.id as discipline_id, d.name as discipline_name, c.name as country_name
FROM representant_participates_event p
INNER JOIN disciplines d ON p.discipline_id = d.id
INNER JOIN countries c   ON p.country_id = c.id
GROUP BY d.id
HAVING COUNT(DISTINCT p.ranking != 1) = (
  SELECT COUNT(*)
  FROM representant_participates_event p1
  WHERE p1.discipline_id = d.id
)