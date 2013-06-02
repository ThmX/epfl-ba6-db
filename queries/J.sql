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

-- For each sport, list the 3 nations which have won the most medals.

-- 1 - For each discipline, we see how many medals are there
-- 2 - Then we add them to get the number of medals per sports
-- 3 - Afterwards we select only the TOP3 for each of them

SELECT S.id, COUNT(*) as first,COUNT(*) as second,COUNT(*) as third
FROM Sports S


SELECT S.id as sport_id, SUM(P.nb_medals) as nb_medals_per_sport
FROM Sports S, (
  SELECT P1.discipline_id, COUNT(P1.ranking) as nb_medals
  FROM Representant_participates_Event P1
  INNER JOIN Disciplines D ON P1.discipline_id = D.id
  GROUP BY P1.discipline_id
) P, Disciplines D
WHERE P.discipline_id = D.id AND S.id = D.sport_id
GROUP BY S.id
















 