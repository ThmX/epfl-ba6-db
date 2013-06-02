-- List names of all athletes who won medals both in individual and team sports.

-- We used the same idea fir this query as request T.

SELECT a.id as athlete_id, a.name as athlete_name
FROM (
      SELECT DISTINCT(a.id) as athlete_id
      FROM representant_participates_event p, athletes a, disciplines d, games g
      WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
      GROUP BY d.id, g.id, p.country_id, p.ranking
      HAVING COUNT(*) = 1
     ) indidual_medalist,
    (
      SELECT DISTINCT(a.id) as athlete_id
      FROM representant_participates_event p, athletes a, disciplines d, games g
      WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
      GROUP BY d.id, g.id, p.country_id, p.ranking
      HAVING COUNT(*) > 1
    ) team_medalist,
athletes a
WHERE indidual_medalist.athlete_id = team_medalist.athlete_id AND indidual_medalist.athlete_id = a.id