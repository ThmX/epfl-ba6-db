--Names of athletes who won medals at both summer and winter Olympics.

SELECT a.name 
FROM (
	SELECT p.athlete_id as medalist_id 
	FROM representant_participates_event p, games g 
	WHERE p.ranking != 0 AND p.games_id = g.id AND g.is_summer = 0) m1, (
		SELECT p.athlete_id as medalist_id 
		FROM representant_participates_event p, games g 
		WHERE p.ranking != 0 AND p.games_id = g.id AND g.is_summer = 1) m2, athletes a
WHERE m1.medalist_id = m2.medalist_id AND a.id = m1.medalist_id;