
INSERT INTO Employee (employeeid, role, name) VALUES (1, 'op', 'Itay');
INSERT INTO Employee (employeeid, role, name) VALUES (2, 'wrk', 'Gal');
INSERT INTO Employee (employeeid, role, name) VALUES (3, 'mnt', 'Tamar');

INSERT INTO Grapes (GrapeID, Variety, HarvestDate, SugarLevel) VALUES (1, 'Merlot', '2023-08-10', 23.5);
INSERT INTO Grapes (GrapeID, Variety, HarvestDate, SugarLevel) VALUES (2, 'Cabernet', '2023-08-11', 24.1);
INSERT INTO Grapes (GrapeID, Variety, HarvestDate, SugarLevel) VALUES (3, 'Shiraz', '2023-08-12', 22.8);

INSERT INTO Materials (MaterialID, Name, SupplierID, QuantityAvailable) VALUES (1, 'Yeast', 101, 50.0);
INSERT INTO Materials (MaterialID, Name, SupplierID, QuantityAvailable) VALUES (2, 'Sugar', 102, 70.5);
INSERT INTO Materials (MaterialID, Name, SupplierID, QuantityAvailable) VALUES (3, 'Tannin', 103, 30.0);

INSERT INTO Containers (ContainerID, Type, CapacityL) VALUES (1, 'Oak Barrel', 225);
INSERT INTO Containers (ContainerID, Type, CapacityL) VALUES (2, 'Steel Tank', 1000);
INSERT INTO Containers (ContainerID, Type, CapacityL) VALUES (3, 'Clay Jar', 150);

INSERT INTO FinalProduct (BatchNumber, quantityOfBottle, WineType, BottlingDate, numBottles)
VALUES ('BN1001', 750, 'Red', '2024-02-01', 1200);
INSERT INTO FinalProduct (BatchNumber, quantityOfBottle, WineType, BottlingDate, numBottles)
VALUES ('BN1002', 1000, 'White', '2024-01-15', 850);
INSERT INTO FinalProduct (BatchNumber, quantityOfBottle, WineType, BottlingDate, numBottles)
VALUES ('BN1003', 750, 'Rose', '2024-03-10', 950);

INSERT INTO ProductionProcess (ProcessID, Type, StartDate, EndDate, GrapeID, EmployeeID, BatchNumber)
VALUES (1, 'Fermentation', '2023-11-01', '2023-11-10', 1, 1, 'BN1001');
INSERT INTO ProductionProcess (ProcessID, Type, StartDate, EndDate, GrapeID, EmployeeID, BatchNumber)
VALUES (2, 'Aging', '2023-11-11', '2023-11-20', 2, 2, 'BN1002');
INSERT INTO ProductionProcess (ProcessID, Type, StartDate, EndDate, GrapeID, EmployeeID, BatchNumber)
VALUES (3, 'Blending', '2023-11-21', '2023-11-25', 3, 3, 'BN1003');
