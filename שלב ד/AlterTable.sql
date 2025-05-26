-- AlterTable.sql
-- קובץ זה כולל את כל פקודות ALTER TABLE ששימשו להוספת עמודות חדשות בטבלאות הקיימות.
-- הקובץ נדרש כחלק מההגשה של שלב 4 בפרויקט.

-- הוספת עמודה last_updated לטבלת product_local (עבור טריגר עדכון מחיר)
ALTER TABLE product_local ADD COLUMN IF NOT EXISTS last_updated TIMESTAMP;

-- הוספת עמודה BottlingDate לטבלת FinalProduct (עבור עדכון אוטומטי לאחר 4 תהליכים)
ALTER TABLE FinalProduct_ ADD COLUMN IF NOT EXISTS BottlingDate TIMESTAMP;
