--Print the name of the country which won the most medals in summer Olympics and the country which won the most medals in winter Olympics.

SELECT c.name 
FROM countries c
WHERE c.id IN (
	SELECT p.country_id
	FROM representant_participates_event p, games g 
	WHERE p.games_id = g.id AND g.is_summer = 0 AND p.ranking != 0
	GROUP BY p.country_id
	HAVING COUNT(*) >= ALL (
		SELECT COUNT(*)
		FROM representant_participates_event p1, games g1
		WHERE p1.games_id = g1.id AND g1.is_summer = 0 AND p1.ranking != 0
		GROUP BY p1.country_id)
	UNION
	SELECT p.country_id
	FROM representant_participates_event p, games g 
	WHERE p.games_id = g.id AND g.is_summer = 1 AND p.ranking != 0
	GROUP BY p.country_id
	HAVING COUNT(*) >= ALL (
		SELECT COUNT(*)
		FROM representant_participates_event p1, games g1
		WHERE p1.games_id = g1.id AND g1.is_summer = 1 AND p1.ranking != 0
		GROUP BY p1.country_id));