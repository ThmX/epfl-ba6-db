CREATE TABLE Residence (
  address          char(128) NOT NULL,
  phone            char(20) NOT NULL,
  PRIMARY KEY (address, phone)
)

CREATE TABLE Musician (
  ssn              char(20) NOT NULL,
  name             char(20),
  res_address      char(128) NOT NULL,
  res_phone        char(20) NOT NULL,
  PRIMARY KEY (ssn),
  FOREIGN KEY (res_address, res_phone) REFERENCES Residence (address, phone)
    ON DELETE NO ACTION
)