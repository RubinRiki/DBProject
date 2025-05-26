-- פרוצדורה: add_material_if_not_exists
-- תיאור: הפרוצדורה מקבלת מזהה, שם, כמות וספק של חומר גלם. אם החומר לא קיים בטבלת materials_ - מוסיפה אותו.
-- אם הוא כבר קיים – מדפיסה הודעה מתאימה.
-- כוללת שימוש ב־RECORD, הסתעפות (IF), פקודת INSERT, RAISE NOTICE ו־EXCEPTION.

CREATE OR REPLACE PROCEDURE add_material_if_not_exists(
  mat_id INT,
  mat_name VARCHAR,
  quantity FLOAT,
  supplier_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
  existing_material RECORD;
BEGIN
  SELECT * INTO existing_material FROM materials_ WHERE materialid_ = mat_id;

  IF NOT FOUND THEN
    INSERT INTO materials_ (materialid_, name_, quantityavailable_, supplierid_)
    VALUES (mat_id, mat_name, quantity, supplier_id);
    RAISE NOTICE 'New material added: %, Quantity: %', mat_name, quantity;
  ELSE
    RAISE NOTICE 'Material already exists: %', existing_material.name_;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error while adding material: %', SQLERRM;
END;
$$;
