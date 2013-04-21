CREATE TABLE Athletes_represent_Countries (
   athlete_id              integer,
   country_id              integer,
   PRIMARY KEY (athlete_id, country_id),
   FOREIGN KEY (athlete_id) REFERENCES Athletes (id),
   FOREIGN KEY (country_id) REFERENCES Countries (id)
);

CREATE TABLE Disciplines_event_Games (
   discipline_id           integer,
   games_id                integer,
   PRIMARY KEY (discipline_id, games_id),
   FOREIGN KEY (discipline_id) REFERENCES Disciplines (id),
   FOREIGN KEY (games_id) REFERENCES Games (id)
);

-- Here Event is a shortcut to table Disciplines_event_Games

CREATE TABLE Representant_participates_Event (
   athlete_id              integer,
   country_id              integer,
   discipline_id           integer,
   games_id                integer,
   ranking                 tinyint(2),
      PRIMARY KEY (athlete_id, country_id, games_id),
   -- PRIMARY KEY (athlete_id, country_id, discipline_id, games_id),
   FOREIGN KEY (athlete_id, country_id) REFERENCES Athletes_represent_Countries (athlete_id, country_id),
   FOREIGN KEY (discipline_id, games_id) REFERENCES Disciplines_event_Games (discipline_id, games_id)
);