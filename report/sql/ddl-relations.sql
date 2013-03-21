CREATE TABLE Athletes_represent_Countries (
   athlete              char(20),
   country              char(20),
   PRIMARY KEY (athlete, country),
   FOREIGN KEY (athlete) REFERENCES Athletes (name),
   FOREIGN KEY (country) REFERENCES Countries (name)
);

CREATE TABLE Athletes_performs_Discipline (
   athlete              char(20),
   discipline           char(20),
   sport                char(20),
   PRIMARY KEY (athlete, discipline, sport),
   FOREIGN KEY (athlete) REFERENCES Athletes (name),
   FOREIGN KEY (discipline, sport) REFERENCES Disciplines (name, sport)
);

CREATE TABLE Disciplines_event_Games (
   name                 char(20),
   discipline           char(20),
   sport                char(20),
   games                char(20),
   PRIMARY KEY (discipline, sport, games),
   FOREIGN KEY (discipline, sport) REFERENCES Disciplines (name, sport),
   FOREIGN KEY (games) REFERENCES Games (name)
);

-- Here Event is a shortcut to table Disciplines_event_Games

CREATE TABLE Representant_participates_Event (
   athlete             char(20),
   country              char(20),
   discipline           char(20),
   sport                char(20),
   olympics             char(20),
   PRIMARY KEY (athlete, country, discipline, olympics),
   FOREIGN KEY (athlete, country) REFERENCES Athletes_represent_Countries (athlete, country),
   FOREIGN KEY (discipline, sport, olympics) REFERENCES Disciplines_event_Games (discipline, sport, games)
);

CREATE TABLE Representant_medal_Event (
   medalist             char(20),
   country              char(20),
   medal                char(20),
   discipline           char(20),
   sport                char(20),
   olympics             char(20),
   PRIMARY KEY (medalist, country, discipline, olympics),
   FOREIGN KEY (medalist, country) REFERENCES Athletes_represent_Countries (athlete, country),
   FOREIGN KEY (discipline, sport, olympics) REFERENCES Disciplines_event_Games (discipline, sport, games)
);