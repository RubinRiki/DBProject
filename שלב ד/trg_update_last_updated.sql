-- טריגר: trg_update_last_updated
-- תיאור: טריגר שמתעדכן בכל פעם שמחיר מוצר משתנה. הפעולה מתבצעת על טבלת product_local.
-- אם יש שינוי בשדה price, העמודה last_updated תקבל את התאריך והשעה הנוכחיים.
-- כולל: ALTER TABLE להוספת העמודה, פונקציית טריגר, ופקודת CREATE TRIGGER.

-- הוספת עמודה last_updated לטבלה (אם לא קיימת)
ALTER TABLE product_local ADD COLUMN IF NOT EXISTS last_updated TIMESTAMP;

-- פונקציית הטריגר
CREATE OR REPLACE FUNCTION update_last_updated()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- יצירת הטריגר
CREATE TRIGGER trg_update_last_updated
BEFORE UPDATE OF price ON product_local
FOR EACH ROW
EXECUTE FUNCTION update_last_updated();
