-- Note : Could not force the participation constraint to Disciplines.
CREATE TABLE Athletes (
   name                  char(20),
   PRIMARY KEY (name)
);

-- Note : Could not force the participation constraint to Athletes.
CREATE TABLE Countries (
   name                  char(20),
   ioc_code              char(6),
   PRIMARY KEY (name)
);

-- Note : Could not force the participation constraint to Disciplines.
CREATE TABLE Sports (
   name                  char(20),
   PRIMARY KEY (name)

);

CREATE TABLE Games (
   name                  char(20),
   host_country          char(20) NOT NULL,
   host_city             char(20) NOT NULL,
   number_of_countries   integer(6),
   number_of_athletes    integer(6),
   number_of_events      integer(6),
   PRIMARY KEY (name),
   FOREIGN KEY (host_country) REFERENCES Countries (name)
);

CREATE TABLE Disciplines (
   name                  char(20),
   sport                 char(20),
   PRIMARY KEY (name, sport),
   FOREIGN KEY (sport) REFERENCES Sports (name)
      ON DELETE CASCADE
);