-- For all individual sports, compute the most top 10 countries according to their success score. Success
-- score of a country is sum of success points of all its medalists: gold medal is worth 3 points, silver 2
-- points, and bronze 1 point. Shared medal is worth half the points of the non-shared medal.

SELECT P.discipline_id, COUNT(case P.ranking when 1 then 3 when 2 then 2 when 3 then 1 else null end) AS score
FROM Representant_participates_Event P
WHERE P.discipline_id IS NOT NULL AND P.athlete_id IN (
  SELECT DISTINCT(a.id) as athlete_id
  FROM representant_participates_event p, athletes a, disciplines d, games g
  WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
  GROUP BY d.id, g.id, p.country_id, p.ranking
  HAVING COUNT(*) = 1
)
GROUP BY P.discipline_id
ORDER BY score DESC