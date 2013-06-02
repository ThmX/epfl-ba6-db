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


















