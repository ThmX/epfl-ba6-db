-- I)
-- Medal table for the specific Olympic Games supplied by the user.
-- OK

SELECT COUNT(p.ranking = 1) as gold, COUNT(p.ranking = 2) as silver, COUNT(p.ranking = 3) as bronze, c.ioc_code
FROM Representant_participates_Event p, Countries c, Games g
WHERE p.games_id = g.id AND p.country_id = c.id AND g.year = '2008' AND g.is_summer = '1'
GROUP BY c.id
ORDER BY gold DESC, silver DESC, bronze DESC


-- J)
-- For each sport, list the 3 nations which have won the most medals.

  
    
-- K)
-- Compute which country in which Olympics has benefited the most from playing in front of the home crowd.

-- utiliser I)

      
-- L)
-- List top 10 nations according to their success in team sports.
-- A verifier

SELECT medalists.country_name
FROM (
    SELECT COUNT(*) as number_of_medalists, c.name as country_name, c.id as country_id
    FROM Representant_participates_Event p, Countries c, Disciplines d
    WHERE p.country_id = c.id AND p.discipline_id = d.id AND p.ranking != 0
    GROUP BY c.id) medalists,
    (SELECT COUNT(DISTINCT d.id) as number_of_medals, c.name as country_name, c.id as country_id
    FROM Representant_participates_Event p, Countries c, Disciplines d
    WHERE p.country_id = c.id AND p.discipline_id = d.id AND p.ranking != 0
    GROUP BY c.id) medals
WHERE medalists.country_id = medals.country_id
ORDER BY (medalists.number_of_medalists/medals.number_of_medals)
LIMIT 0, 10


-- M)
-- List all Olympians who won medals for multiple nations.
-- OK

SELECT DISTINCT a.name, c1.country_id, c1.country_name, c2.country_id, c2.country_name FROM (
    SELECT p.athlete_id as medalist_id, c.id as country_id, c.name as country_name 
    FROM representant_participates_event p, countries c
    WHERE p.ranking != 0 AND p.country_id = c.id) c1, (
    SELECT p.athlete_id as medalist_id, c.id as country_id, c.name as country_name
    FROM representant_participates_event p, countries c 
    WHERE p.ranking != 0 AND p.country_id = c.id) c2, athletes a
WHERE c1.medalist_id = c2.medalist_id AND a.id = c1.medalist_id AND c1.country_id < c2.country_id;


--N)
-- List all nations whose first medal was gold, all nations whose first medal was silver and all nations whose first medal was bronze

-- Marche presque:
SELECT c.id as country_id, c.name as country_name, g.year, p.ranking
FROM representant_participates_event p, Countries c, Games g
WHERE p.country_id = c.id AND p.games_id = g.id AND g.year = (SELECT MIN(g1.year)
    FROM Games g1, representant_participates_event p1
    WHERE p1.games_id = g1.id AND p1.country_id = g.id AND p1.ranking != 0)
GROUP BY c.id  
ORDER BY p.ranking

-- P)
-- List all events for which all medals are won by athletes from the same country.
-- A vérifier avec plus de données


SELECT d.id as discipline_id, d.name as discipline_name, c.name as country_name
FROM representant_participates_event p, disciplines d, countries c
WHERE p.discipline_id = d.id AND p.country_id = c.id
GROUP BY d.id
HAVING COUNT(DISTINCT p.ranking != 1) = (SELECT COUNT(*) FROM representant_participates_event p1 WHERE p1.discipline_id = d.id)


-- Q)
-- For each Olympic Games, list the name of the country which scored the largest percentage of the medals.

-- S)
-- List names of all athletes who won medals both in individual and team sports.
-- A vérifier

-- liste des athlete en individuel (en equipe mettre != au having)
SELECT DISTINCT(a.id) as athlete_id
FROM representant_participates_event p, athletes a, disciplines d, games g
WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
GROUP BY d.id, g.id, p.country_id, p.ranking
HAVING COUNT(*) = 1

-- Partie complète : 
SELECT a.id as athlete_id, a.name as athlete_name
FROM (
    SELECT DISTINCT(a.id) as athlete_id
    FROM representant_participates_event p, athletes a, disciplines d, games g
    WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
    GROUP BY d.id, g.id, p.country_id, p.ranking
    HAVING COUNT(*) = 1) indidual_medalist,
    (SELECT DISTINCT(a.id) as athlete_id
    FROM representant_participates_event p, athletes a, disciplines d, games g
    WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
    GROUP BY d.id, g.id, p.country_id, p.ranking
    HAVING COUNT(*) > 1) team_medalist,
athletes a
WHERE indidual_medalist.athlete_id = team_medalist.athlete_id AND indidual_medalist.athlete_id = a.id





-- T)
-- List names of all athletes who won gold in team sports, but only won silvers or bronzes individually.
-- A vérifier

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


-- U)
-- List names of all events and Olympic Games for which the individual or team has defended a title from the previous games.
-- Forum : check only if country defened title (not athlete)
-- A vérifier

SELECT d1.name as discipline, c1.name as winner_country, g2.host_city as first_games, g2.year, g1.host_city as second_games, g1.year
FROM representant_participates_event p1, disciplines d1, countries c1, games g1,
representant_participates_event p2, disciplines d2, countries c2, games g2
WHERE p1.discipline_id = d1.id AND p1.country_id = c1.id AND p1.games_id = g1.id AND p1.ranking = 1 AND
p2.discipline_id = d2.id AND p2.country_id = c2.id AND p2.games_id = g2.id AND p2.ranking = 1 AND d1.id = d2.id AND g1.id != g2.id
AND NOT EXISTS (SELECT * FROM games g WHERE g.year < g1.year AND g.year > g2.year)
GROUP BY d1.id      

-- V)
--


