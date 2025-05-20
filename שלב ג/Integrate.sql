-- שלב 1: יצירת ההרחבה
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- שלב 2: יצירת שרת חיצוני ל-satge3
CREATE SERVER satge3_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'satge3', port '5432');

-- שלב 3: מיפוי משתמש
CREATE USER MAPPING FOR current_user
SERVER satge3_server
OPTIONS (user 'riki', password '1234');

-- שלב 4: ALTER TABLE לפי אינטגרציה

-- הוספת productid ל־FinalProduct
ALTER TABLE finalproduct_
ADD COLUMN productid INT;

-- הוספת purchesid ל־Materials
ALTER TABLE materials_
ADD COLUMN purchesid INT;
