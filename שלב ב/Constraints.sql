-- Constraint 1: NOT NULL for employee name
ALTER TABLE employee
ALTER COLUMN name SET NOT NULL;

-- Constraint 2: CHECK constraint to ensure numbottls is not negative
ALTER TABLE finalproduct_
ADD CONSTRAINT check_positive_bottles CHECK (numbottls >= 0);

-- Constraint 3: DEFAULT value for equipment status
ALTER TABLE productionequipment_
ALTER COLUMN status_ SET DEFAULT 'Available';