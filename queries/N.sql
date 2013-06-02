-- List all nations whose first medal was gold, all nations whose first medal was silver and all nations whose first medal was bronze

SELECT c.id as country_id, c.name as country_name, g.year, p.ranking
FROM representant_participates_event p
INNER JOIN Countries c ON c.id = p.country_id
INNER JOIN Games     g ON g.id = p.games_id
WHERE g.year = (
    SELECT MIN(g1.year)
    FROM Games g1
    INNER JOIN representant_participates_event p1 ON p1.games_id = g1.id
    WHERE p1.country_id = g.id AND p1.ranking != 0
  )
GROUP BY c.id
ORDER BY p.ranking