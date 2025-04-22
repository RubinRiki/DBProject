CREATE TABLE Grapes
(
  GrapeID INT ,
  Variety INT,
  HarvestDate_ DATE ,
  PRIMARY KEY (GrapeID)
);

CREATE TABLE Materials_
(
  MaterialID_ INT ,
  Name_ VARCHAR(10) ,
  SupplierID_ INT ,
  QuantityAvailable_ FLOAT,
  PRIMARY KEY (MaterialID_)
);

CREATE TABLE ProductionEquipment_
(
  EquipmentID_ INT ,
  Type_ INT ,
  Status_ VARCHAR(10) ,
  PRIMARY KEY (EquipmentID_)
);

CREATE TABLE FinalProduct_
(
  quntityofBottle FLOAT ,
  BatchNumber_ INT ,
  WineType_ VARCHAR(10),
  BottlingDate_ DATE ,
  numBottls INT NOT NULL,
  PRIMARY KEY (BatchNumber_)
);

CREATE TABLE Containers_
(
  ContainerID_ INT,
  Type_ INT ,
  CapacityL_ FLOAT ,
  PRIMARY KEY (ContainerID_)
);

CREATE TABLE Employee
(
  EmployeeID INT ,
  Role VARCHAR(6),
  Name VARCHAR(10) ,
  PRIMARY KEY (EmployeeID)
);

CREATE TABLE ProductionProcess_
(
  ProcessID_ INT ,
  Type_ INT,
  StartDate_ DATE ,
  EndDate_ DATE ,
  seqNumber INT ,
  GrapeID INT ,
  EmployeeID INT ,
  BatchNumber_ INT ,
  PRIMARY KEY (ProcessID_),
  FOREIGN KEY (GrapeID) REFERENCES Grapes(GrapeID),
  FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
  FOREIGN KEY (BatchNumber_) REFERENCES FinalProduct_(BatchNumber_)
);

CREATE TABLE Process_Equipment
(
  EquipmentID_ INT ,
  ProcessID_ INT ,
  PRIMARY KEY (EquipmentID_, ProcessID_),
  FOREIGN KEY (EquipmentID_) REFERENCES ProductionEquipment_(EquipmentID_),
  FOREIGN KEY (ProcessID_) REFERENCES ProductionProcess_(ProcessID_)
);

CREATE TABLE Process_Materials
(
  UsageAmount INT ,
  ProcessID_ INT ,
  MaterialID_ INT ,
  PRIMARY KEY (ProcessID_, MaterialID_),
  FOREIGN KEY (ProcessID_) REFERENCES ProductionProcess_(ProcessID_),
  FOREIGN KEY (MaterialID_) REFERENCES Materials_(MaterialID_)
);

CREATE TABLE processContainers
(
  ContainerID_ INT ,
  ProcessID_ INT ,
  PRIMARY KEY (ContainerID_, ProcessID_),
  FOREIGN KEY (ContainerID_) REFERENCES Containers_(ContainerID_),
  FOREIGN KEY (ProcessID_) REFERENCES ProductionProcess_(ProcessID_)
);
