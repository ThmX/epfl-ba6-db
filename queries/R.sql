-- CREATE TABLE Athletes (
--    id                    integer AUTO_INCREMENT,
--    name                  char(255),
--    PRIMARY KEY (id)
-- );
-- 
-- CREATE TABLE Countries (
--    id                    integer AUTO_INCREMENT,
--    name                  char(60),
--    ioc_code              char(6),
--    PRIMARY KEY (id)
-- );
-- 
-- CREATE TABLE Sports (
--    id                    integer AUTO_INCREMENT,
--    name                  char(60),
--    PRIMARY KEY (id)
-- 
-- );
-- 
-- CREATE TABLE Games (
--    id                    integer AUTO_INCREMENT,
--    year                  integer(4),
--    is_summer             tinyint(1),
--    host_country          integer NOT NULL,
--    host_city             char(60) NOT NULL,
--    PRIMARY KEY (id),
--    FOREIGN KEY (host_country) REFERENCES Countries (id)
-- );
-- 
-- CREATE TABLE Disciplines (
--    id                    integer AUTO_INCREMENT,
--    name                  char(100),
--    sport                 integer NOT NULL,
--    PRIMARY KEY (id),
--    FOREIGN KEY (sport) REFERENCES Sports (id)
--       ON DELETE CASCADE
-- );

-- CREATE TABLE Athletes_represent_Countries (
--    athlete_id              integer,
--    country_id              integer,
--    PRIMARY KEY (athlete_id, country_id),
--    FOREIGN KEY (athlete_id) REFERENCES Athletes (id),
--    FOREIGN KEY (country_id) REFERENCES Countries (id)
-- );
-- 
-- CREATE TABLE Disciplines_event_Games (
--    discipline_id           integer,
--    games_id                integer,
--    PRIMARY KEY (discipline_id, games_id),
--    FOREIGN KEY (discipline_id) REFERENCES Disciplines (id),
--    FOREIGN KEY (games_id) REFERENCES Games (id)
-- );
-- 
-- -- Here Event is a shortcut to table Disciplines_event_Games
-- 
-- CREATE TABLE Representant_participates_Event (
--    athlete_id              integer,
--    country_id              integer,
--    discipline_id           integer,
--    games_id                integer,
--    ranking                 tinyint(2),
--    PRIMARY KEY (athlete_id, country_id, discipline_id, games_id),
--    FOREIGN KEY (athlete_id, country_id) REFERENCES Athletes_represent_Countries (athlete_id, country_id),
--    FOREIGN KEY (discipline_id, games_id) REFERENCES Disciplines_event_Games (discipline_id, games_id)
-- );

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

-- Liste des athlete en individuel
SELECT DISTINCT(a.id) as athlete_id
FROM representant_participates_event p, athletes a, disciplines d, games g
WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
GROUP BY d.id, g.id, p.country_id, p.ranking
HAVING COUNT(*) = 1

-- Liste des athlete en équipe
SELECT DISTINCT(a.id) as athlete_id
FROM representant_participates_event p, athletes a, disciplines d, games g
WHERE p.athlete_id = a.id AND p.discipline_id = d.id AND p.games_id = g.id AND p.ranking != 0
GROUP BY d.id, g.id, p.country_id, p.ranking
HAVING COUNT(*) != 1


















