-- Note : Could not force the participation constraint to Disciplines.
CREATE TABLE Athletes (
   id                    integer AUTO_INCREMENT,
   name                  char(255),
   PRIMARY KEY (id)
);

-- Note : Could not force the participation constraint to Athletes.
CREATE TABLE Countries (
   id                    integer AUTO_INCREMENT,
   name                  char(60),
   ioc_code              char(6),
   PRIMARY KEY (id)
);

-- Note : Could not force the participation constraint to Disciplines.
CREATE TABLE Sports (
   id                    integer AUTO_INCREMENT,
   name                  char(60),
   PRIMARY KEY (id)

);

CREATE TABLE Games (
   id                    integer AUTO_INCREMENT,
   year                  integer(4),
   is_summer             boolean,
   host_country          integer NOT NULL,
   host_city             char(60) NOT NULL,
   PRIMARY KEY (id),
   FOREIGN KEY (host_country) REFERENCES Countries (id)
);

CREATE TABLE Disciplines (
   id                    integer AUTO_INCREMENT,
   name                  char(100),
   sport                 integer NOT NULL,
   PRIMARY KEY (id),
   FOREIGN KEY (sport) REFERENCES Sports (id)
      ON DELETE CASCADE
);