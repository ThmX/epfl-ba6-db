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

-- For each Olympic Games print the name of the country with the most participants.

SELECT G.year, C.name
FROM Games G, Countries C
WHERE C.id = (
  SELECT RE.country_id
  FROM Representant_participates_Event RE
  WHERE RE.games_id = G.id
  GROUP BY RE.country_id
  ORDER BY COUNT(RE.country_id) DESC
  LIMIT 1
)
GROUP BY G.id