-- Insert into employee
INSERT INTO employee (employeeid, role, name)
VALUES
  (1, 'Admin', 'Noa'),
  (2, 'Tech', 'Riki'),
  (3, 'Lab', 'Dana');

-- Insert into grapes
INSERT INTO grapes (grapeid, variety, harvestdate_)
VALUES
  (101, 1, '2024-09-01'),
  (102, 2, '2024-09-05');

-- Insert into materials_
INSERT INTO materials_ (materialid_, name_, supplierid_, quantityavailable_)
VALUES
  (1, 'Sugar', 501, 100.0),
  (2, 'Yeast', 502, 200.0);

-- Insert into containers_
INSERT INTO containers_ (containerid_, type_, capacityl_)
VALUES
  (11, 1, 50.0),
  (12, 2, 75.0);

-- Insert into finalproduct_
INSERT INTO finalproduct_ (quntityofbottle, batchnumber_, winetype_, bottlingdate_, numbottls)
VALUES
  (500.0, 1001, 'Red', '2024-12-01', 100),
  (300.0, 1002, 'White', '2024-12-05', 60);

-- Insert into productionprocess_
INSERT INTO productionprocess_ (processid_, type_, startdate_, enddate_, seqnumber, grapeid, employeeid, batchnumber_)
VALUES
  (201, 1, '2024-10-01', '2024-10-02', 1, 101, 1, 1001),
  (202, 2, '2024-10-03', '2024-10-04', 2, 101, 2, 1001),
  (203, 3, '2024-10-05', '2024-10-06', 3, 101, 3, 1001),
  (204, 4, '2024-10-07', '2024-10-08', 4, 101, 1, 1001);

-- Insert into productionequipment_
INSERT INTO productionequipment_ (equipmentid_, type_, status_)
VALUES
  (301, 'Filter', 'Active'),
  (302, 'Ferment', 'Inactive');

-- Insert into process_equipment
INSERT INTO process_equipment (equipmentid_, processid_)
VALUES
  (301, 201),
  (302, 202);

-- Insert into process_materials
INSERT INTO process_materials (usageamount, processid_, materialid_)
VALUES
  (10, 201, 1),
  (5, 202, 2);

-- Insert into processcontainers
INSERT INTO processcontainers (containerid_, processid_)
VALUES
  (11, 201),
  (12, 202);
