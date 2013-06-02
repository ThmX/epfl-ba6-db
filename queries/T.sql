-- List names of all athletes who won gold in team sports, but only won silvers or bronzes individually.

SELECT a.id as athlete_id, a.name as athlete_name
FROM (
    SELECT DISTINCT(a.id) as athlete_id
    FROM representant_participates_event p, athletes a, disciplines d, games g
    WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND (p.ranking = 2 OR p.ranking = 3)
    GROUP BY d.id, g.id, p.country_id, p.ranking
    HAVING COUNT(*) = 1) indidual_medalist,
    (SELECT DISTINCT(a.id) as athlete_id
    FROM representant_participates_event p, athletes a, disciplines d, games g
    WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 1
    GROUP BY d.id, g.id, p.country_id, p.ranking
    HAVING COUNT(*) > 1) team_medalist,
athletes a
WHERE indidual_medalist.athlete_id = team_medalist.athlete_id AND indidual_medalist.athlete_id = a.id