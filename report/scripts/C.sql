--For each country, print the place where it won its first medal.

SELECT c1.name as country, g.host_city, g.year 
FROM games g, countries c1, representant_participates_event p
WHERE g.id = p.games_id AND c1.id = p.country_id AND year = (
	SELECT MIN(g.year) 
	FROM games g, representant_participates_event p
	WHERE g.id = p.games_id AND p.ranking != 0)
GROUP BY p.country_id;