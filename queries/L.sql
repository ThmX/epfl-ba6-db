-- List top 10 nations according to their success in team sports.

SELECT medalists.country_name
FROM (
  -- Gets the number of medalists
    SELECT COUNT(*) as number_of_medalists, c.name as country_name, c.id as country_id
    FROM Representant_participates_Event p, Countries c, Disciplines d
    WHERE p.country_id = c.id AND p.discipline_id = d.id AND p.ranking != 0
    GROUP BY c.id
  ) medalists,
    (
  -- Gets the number of medals
    SELECT COUNT(DISTINCT d.id) as number_of_medals, c.name as country_name, c.id as country_id
    FROM Representant_participates_Event p, Countries c, Disciplines d
    WHERE p.country_id = c.id AND p.discipline_id = d.id AND p.ranking != 0
    GROUP BY c.id
  ) medals
WHERE medalists.country_id = medals.country_id
ORDER BY (medalists.number_of_medalists/medals.number_of_medals)
LIMIT 0, 10