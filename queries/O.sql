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

-- For all disciplines, compute the country which waited the most between two successive medals.

CREATE VIEW DelayByCountryByDiscipline AS (
  SELECT p1.discipline_id as discipline_id, g1.year-g2.year as time_waited, p1.country_id as country_id
  FROM representant_participates_event p1, representant_participates_event p2, games g1, games g2
  WHERE p1.country_id = p2.country_id AND p1.games_id = g1.id AND p2.games_id = g2.id AND g1.year > g2.year
  AND p1.ranking != 0 AND p2.ranking != 0 AND p1.discipline_id = p2.discipline_id
  GROUP BY p1.discipline_id
);

SELECT d.name as discipline, c.name as country, join2.max_delay as number_of_years_waited
FROM DelayByCountryByDiscipline join1, Disciplines d, Countries c, (
  SELECT MAX(time_waited) as max_delay, discipline_id
  FROM DelayByCountryByDiscipline
  GROUP BY discipline_id
) join2
WHERE join1.discipline_id = join2.discipline_id AND join1.time_waited = join2.max_delay AND join1.discipline_id = d.id
AND join1.country_id = c.id
