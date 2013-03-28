-- Athletes (name : char(20), PRIMARY KEY (name))
-- Countries (name : char(20ß), ioc_code : char(6), PRIMARY KEY (name))
-- Sports (name : char(20), PRIMARY KEY (name))
-- 
-- Games (
-- 	name                  char(20),
-- 	host_country          char(20) NOT NULL,
-- 	host_city             char(20) NOT NULL,
-- 	number_of_countries   integer(6),
-- 	number_of_athletes    integer(6),
-- 	number_of_events      integer(6),
-- 	PRIMARY KEY (name),
-- 	FOREIGN KEY (host_country) REFERENCES Countries (name)
-- )
-- 
-- Disciplines (name : char(20), sport : char(20),
-- 	PRIMARY KEY (name, sport),
-- 	FOREIGN KEY (sport) REFERENCES Sports (name) ON DELETE CASCADE
-- )
-- 
-- Athletes_represent_Countries (
--    athlete              char(20),
--    country              char(20),
--    PRIMARY KEY (athlete, country),
--    FOREIGN KEY (athlete) REFERENCES Athletes (name),
--    FOREIGN KEY (country) REFERENCES Countries (name)
-- )
-- 
-- Athletes_performs_Discipline (
--    athlete              char(20),
--    discipline           char(20),
--    sport                char(20),
--    PRIMARY KEY (athlete, discipline, sport),
--    FOREIGN KEY (athlete) REFERENCES Athletes (name),
--    FOREIGN KEY (discipline, sport) REFERENCES Disciplines (name, sport)
-- )
-- 
-- Disciplines_event_Games (
--    name                 char(20),
--    discipline           char(20),
--    sport                char(20),
--    games                char(20),
--    PRIMARY KEY (discipline, sport, games),
--    FOREIGN KEY (discipline, sport) REFERENCES Disciplines (name, sport),
--    FOREIGN KEY (games) REFERENCES Games (name)
-- )
-- 
-- Representant_participates_Event (
--    athlete              char(20),
--    country              char(20),
--    discipline           char(20),
--    sport                char(20),
--    olympics             char(20),
--    PRIMARY KEY (athlete, country, discipline, olympics),
--    FOREIGN KEY (athlete, country) REFERENCES Athletes_represent_Countries (athlete, country),
--    FOREIGN KEY (discipline, sport, olympics) REFERENCES Disciplines_event_Games (discipline, sport, games)
-- )
-- 
-- Representant_medal_Event (
--    medalist             char(20),
--    country              char(20),
--    medal                char(20),
--    discipline           char(20),
--    sport                char(20),
--    olympics             char(20),
--    PRIMARY KEY (medalist, country, discipline, olympics),
--    FOREIGN KEY (medalist, country) REFERENCES Athletes_represent_Countries (athlete, country),
--    FOREIGN KEY (discipline, sport, olympics) REFERENCES Disciplines_event_Games (discipline, sport, games)
-- )

-- List all countries which didn’t ever win a medal.

SELECT C.name
FROM Countries C
WHERE C.name NOT IN (
	SELECT C2.name
	FROM Countries C2
	INNER JOIN Representant_medal_Event RME ON RME.country = C2.name
)