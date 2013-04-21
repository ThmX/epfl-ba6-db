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

  
--Names of gold medalists in sports which appeared only once at the Olympics.

SELECT a.name as athlete, d.name as sport 
FROM athletes a, representant_participates_event p, disciplines d 
WHERE a.id = p.athlete_id AND p.ranking = 1 AND d.id = p.discipline_id AND d.sport IN (
	SELECT d.sport 
	FROM disciplines d, disciplines_event_games e
    WHERE d.id = e.discipline_id 
    GROUP BY d.sport
    HAVING COUNT(*) = 1);


--For each country, print the place where it won its first medal.

SELECT c1.name as country, g.host_city, g.year 
FROM games g, countries c1, representant_participates_event p
WHERE g.id = p.games_id AND c1.id = p.country_id AND year = (
	SELECT MIN(g.year) 
	FROM games g, representant_participates_event p
	WHERE g.id = p.games_id AND p.ranking != 0)
GROUP BY p.country_id;


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
                      
-- List all cities which hosted the Olympics more than once.

SELECT DISTINCT G.host_city
FROM Games G
WHERE EXISTS (
	SELECT *
	FROM Games G2
	WHERE G.id != G2.id AND G.host_city = G2.host_city
);


-- List names of all athletes who competed for more than one country.

SELECT A.name
FROM Athletes A
WHERE (
	SELECT COUNT(AC.country_id)
	FROM Athletes_represent_Countries AC
	WHERE A.id = AC.athlete_id
) > 1;


-- For each Olympic Games print the name of the country with the most participants.

SELECT G.year, C.name
FROM Games G, Countries C
WHERE C.id = (
	SELECT RE.country_id
	FROM Representant_participates_Event RE
	WHERE RE.games_id = G.id
	GROUP BY RE.country_id
	ORDER BY COUNT(RE.country_id) DESC LIMIT 1)
GROUP BY G.id;
  

-- List all countries which didn’t ever win a medal.

SELECT C.name
FROM Countries C
WHERE (
	SELECT SUM(RE.ranking)
	FROM Representant_participates_Event RE
	WHERE RE.country_id = C.id
) IS NULL OR (
	SELECT SUM(RE.ranking)
	FROM Representant_participates_Event RE
	WHERE RE.country_id = C.id
) = 0;

  

  
