## Sorry for the names guys. We surely will change them when implementing the DB.

################# TABLES #################

# Note : Could not force the participation constraint to Disciplines.
CREATE TABLE Athletes (
   name                  char(20),
   PRIMARY KEY (name)
)

# Note : Could not force the participation constraint to Athletes.
CREATE TABLE Countries (
   name                  char(20),
   ioc_code              char(6),
   PRIMARY KEY (name)
)

# Note : Could not force the participation constraint to Disciplines.
CREATE TABLE Sports (
   name                  char(20),
   PRIMARY KEY (name)

)

CREATE TABLE Games (
   name                  char(20),
   host_country          char(20) NOT NULL,
   host_city             char(20) NOT NULL,
   number_of_countries   integer(6),
   number_of_athletes    integer(6),
   number_of_events      integer(6),
   PRIMARY KEY (name),
   FOREIGN KEY (host_country) REFERENCES Countries (name)
)

CREATE TABLE Disciplines (
   name                  char(20),
   sport                char(20),
   PRIMARY KEY (sport, name),
   FOREIGN KEY (sport) REFERENCES Sports (name)
      ON DELETE CASCADE
)

################# RELATIONS #################

CREATE TABLE Athletes_represent_Countries (
   athlete_name         char(20),
   country_name         char(20),
   PRIMARY KEY (athlete_name, country_name),
   FOREIGN KEY (athlete_name) REFERENCES Athletes (name),
   FOREIGN KEY (country_name) REFERENCES Countries (name)
)

CREATE TABLE Athletes_performs_Discipline (
   athlete_name         char(20),
   discipline_name      char(20),
   PRIMARY KEY (athlete_name, discipline_name),
   FOREIGN KEY (athlete_name) REFERENCES Athletes (name),
   FOREIGN KEY (discipline_name) REFERENCES Disciplines (name)
)

CREATE TABLE Disciplines_event_Games (
   name                 char(20),
   discipline           char(20),
   games                char(20),
   PRIMARY KEY (discipline, games),
   FOREIGN KEY (discipline) REFERENCES Disciplines (name),
   FOREIGN KEY (games) REFERENCES Games (name)
)

# Ternary relationship
CREATE TABLE Representant_participates_Sports_and_Games (
   athlete              char(20),
   country              char(20),
   sport                char(20),
   olympics             char(20),
   PRIMARY KEY (athlete, country_name, sport, olympics),
   FOREIGN KEY (athlete_name, country_name) REFERENCES Athletes_represent_Countries (athlete_name, country_name),
   FOREIGN KEY (olympics) REFERENCES Games (name),
   FOREIGN KEY (sport) REFERENCES Sports (name)
)

# Here event is a shortcut to table Disciplines_event_Games
# Note : There is no "event" field here.
CREATE TABLE Representant_medal_Event (
   medalist             char(20),
   country              char(20),
   medal                char(20),
   discipline_name      char(20),
   olympics             char(20),
   PRIMARY KEY (medalist, country, discipline_name, olympics),
   FOREIGN KEY (medalist, country) REFERENCES Athletes_represent_Countries (athlete_name, country_name),
   FOREIGN KEY (discipline_name, olympics) REFERENCES Disciplines_event_Games (discipline, games)
)