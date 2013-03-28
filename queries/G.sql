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

-- For each Olympic Games print the name of the country with the most participants.

-- SELECT max_country
-- FROM (	
-- 	SELECT RPE.country AS max_country, COUNT(RPE.country) AS nb_participants_for_country, RPE.olympics
-- 	FROM Representant_participates_Event RPE
-- 	GROUP BY RPE.country, RPE.olympics
-- 	ORDER BY nb_participants_for_country DESC
-- ) AS max_country_table