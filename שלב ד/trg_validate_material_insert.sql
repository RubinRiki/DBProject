-- טריגר: trg_validate_material_insert
-- תיאור: מונע הכנסת חומר גלם עם כמות שלילית לטבלת materials_.
-- הטריגר פועל לפני כל INSERT, ואם הכמות קטנה מ-0, הוא זורק חריגה.
-- כולל שימוש בתנאי IF, חריגה (EXCEPTION) והפניה ל-NEW.

-- פונקציית הטריגר
CREATE OR REPLACE FUNCTION validate_material_quantity()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.quantityavailable_ < 0 THEN
    RAISE EXCEPTION 'Cannot insert material with negative quantity';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- יצירת הטריגר
CREATE TRIGGER trg_validate_material_insert
BEFORE INSERT ON materials_
FOR EACH ROW
EXECUTE FUNCTION validate_material_quantity();
