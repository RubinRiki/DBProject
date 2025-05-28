-- שלב 1: יצירת הרחבה לעבודה עם שרת חיצוני
-- נדרשת כדי לאפשר שאילתות מול בסיס נתונים חיצוני (satge3)
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

--שלב 2: הגדרת שרת ומיפוי משתמש
-- מאפשר תקשורת עם מסד הנתונים המרוחק והרצת שאילתות על הטבלאות שבו
CREATE SERVER satge3_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'satge3', port '5432');

CREATE USER MAPPING FOR CURRENT_USER
SERVER satge3_server
OPTIONS (user 'riki', password '1234');

--  שלב 3: יצירת טבלאות מקומיות כעותק מהטבלאות המקוריות בשרת החיצוני
-- מאפשר עבודה מקומית על הנתונים
-- 🔹 1. supplier_local – ספקים
CREATE TABLE supplier_local (
  supplierid INT PRIMARY KEY,
  suppliername VARCHAR(100),
  phone VARCHAR(20)
);

INSERT INTO supplier_local
SELECT * FROM supplier_stage3;


-- 🔹 2. product_local – מוצרים
CREATE TABLE product_local (
  productid INT PRIMARY KEY,
  productname VARCHAR(100),
  price NUMERIC(10,2),
  brand VARCHAR(50),
  stockquantity INT
);

INSERT INTO product_local
SELECT * FROM product_stage3;


-- 🔹 3. purchase_local – רכישות
CREATE TABLE purchase_local (
  purchaseid INT PRIMARY KEY,
  purchasedate DATE,
  paymentterms VARCHAR(50),
  employeeid INT
);

INSERT INTO purchase_local
SELECT * FROM purchase_stage3;


-- 🔹 4. purchaseitems_local – פריטי רכישה
CREATE TABLE purchaseitems_local (
  purchaseid INT,
  productid INT,
  quantity INT,
  unitprice NUMERIC(10,2),
  PRIMARY KEY (purchaseid, productid)
);

INSERT INTO purchaseitems_local
SELECT * FROM purchaseitems_stage3;


-- 🔹 5. orders_local – הזמנות
CREATE TABLE orders_local (
  orderid INT PRIMARY KEY,
  orderdate DATE,
  paymentterms VARCHAR(50),
  supplierid INT
);

INSERT INTO orders_local
SELECT * FROM orders_stage3;


-- 🔹 6. orderitems_local – פריטי הזמנה
CREATE TABLE orderitems_local (
  orderid INT,
  productid INT,
  quantity INT,
  unitprice NUMERIC(10,2),
  PRIMARY KEY (orderid, productid)
);

INSERT INTO orderitems_local
SELECT * FROM orderitems_stage3;


-- 🔹 7. role_local – תפקידים
CREATE TABLE role_local (
  roleid INT PRIMARY KEY,
  rolename VARCHAR(100)
);

INSERT INTO role_local
SELECT * FROM role_stage3;


-- 🔹 8. employee_local – עובדים של אגף הרכש
CREATE TABLE employee_local (
  employeeid INT PRIMARY KEY,
  employeename VARCHAR(100),
  hiredate DATE,
  roleid INT
);

INSERT INTO employee_local
SELECT * FROM employee_stage3;


-- 🧩 שלב 4: מיזוג טבלאות עובדים משני האגפים לטבלה אחידה
-- יצירת טבלה ממוזגת
CREATE TABLE employee_merge (
    employeeid     SERIAL PRIMARY KEY,
    employeename   TEXT NOT NULL,
    hiredDate      DATE,
    roleid         INTEGER REFERENCES role_local(roleid)
);

-- הכנסת עובדים מהאגף החדש (employee_local)
INSERT INTO employee_merge (employeeid, employeename, hiredate, roleid)
SELECT employeeid, employeename, hiredate, roleid
FROM employee_local;

-- הכנסת עובדים מהאגף הישן לאחר תרגום תפקידים בהתאם לטבלת role_local
INSERT INTO employee_merge (employeeid, employeename, hiredDate, roleid)
SELECT 
    e.employeeid,
    e.name,
    NULL AS hiredDate,
    r.roleid
FROM employee e
JOIN role_local r ON
    CASE 
        WHEN e.role = 'clean' THEN 'עובד ניקיון'
        WHEN e.role = 'lab'   THEN 'כימאי מעבדה'
        WHEN e.role = 'lead'  THEN 'ראש צוות ייצור'
        WHEN e.role = 'mnt'   THEN 'טכנאי תחזוקה'
        WHEN e.role = 'op'    THEN 'מנהל שלב התססה'
        WHEN e.role = 'qa'    THEN 'בקר איכות'
        WHEN e.role = 'tech'  THEN 'טכנאי ציוד'
        WHEN e.role = 'wrk'   THEN 'עובד פס ייצור'
        ELSE e.role
    END = r.rolename
WHERE e.employeeid IN (
    6,7,8,9,10,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,
    32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50
)
AND e.employeeid NOT IN (SELECT employeeid FROM employee_merge);

-- הכנסת עובדים ידנית למי שלא עבר התאמה אוטומטית
INSERT INTO employee_merge (employeeid, employeename, hiredDate, roleid) VALUES
(19, 'Itay', NULL, 7),
(25, 'Sarit', NULL, 7),
(29, 'Shai', NULL, 7),
(32, 'Avi', NULL, 8),
(37, 'Itay', NULL, 8),
(44, 'Yoni', NULL, 8),
(46, 'Lior', NULL, 7),
(48, 'Yael', NULL, 8);

-- 🔁 שלב 5: קישור מחדש של טבלאות המשתמשות בטבלת העובדים
-- עדכון טבלת purchase_local להשתמש בטבלת העובדים הממוזגת
ALTER TABLE purchase_local
DROP CONSTRAINT IF EXISTS purchase_local_employeeid_fkey;

ALTER TABLE purchase_local
ADD CONSTRAINT purchase_local_employeeid_fkey
FOREIGN KEY (employeeid)
REFERENCES employee_merge(employeeid);

-- גם טבלת תהליך ייצור (productionprocess_) עוברת לקשר חדש
ALTER TABLE productionprocess_
ADD CONSTRAINT productionprocess__employeeid_fkey
FOREIGN KEY (employeeid)
REFERENCES employee_merge(employeeid);

-- 🍷 שלב 6: קישור בין finalproduct_ לבין product_local
-- תחילה מוסיפים עמודת productid לטבלת finalproduct_
ALTER TABLE finalproduct_
ADD COLUMN productid INT;

-- לאחר מכן מוסיפים את הקשר עצמו
ALTER TABLE finalproduct_
ADD CONSTRAINT fk_finalproduct_productid
FOREIGN KEY (productid)
REFERENCES product_local(productid);

-- הכנסת מוצרים חדשים המתאימים למוצרים הסופיים שנוצרו
INSERT INTO product_local (productid, productname, brand, price, stockquantity) VALUES
(401, 'Barbera', 'Modernet', 32.5, 100),
(402, 'Dolcetto', 'Modernet', 28.0, 120),
(403, 'Gamay', 'Modernet', 29.9, 90),
(404, 'Malbec', 'Modernet', 33.0, 110),
(405, 'Merlot', 'Modernet', 31.0, 80);

-- קישור של מוצרים אלה ל־batchnumber בתוצר הסופי
UPDATE finalproduct_ SET productid = 401 WHERE batchnumber = 5;
UPDATE finalproduct_ SET productid = 402 WHERE batchnumber = 6;
UPDATE finalproduct_ SET productid = 403 WHERE batchnumber = 7;
UPDATE finalproduct_ SET productid = 404 WHERE batchnumber = 8;
UPDATE finalproduct_ SET productid = 405 WHERE batchnumber = 9;

-- 🧪 שלב 7: יצירת קשר בין חומרים להזמנות
-- יצירת טבלת קישור ordermaterials_local
CREATE TABLE ordermaterials_local (
    orderid INTEGER,
    materialid INTEGER,
    quantity INTEGER NOT NULL,
    supplierPrice NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (orderid, materialid),
    FOREIGN KEY (orderid) REFERENCES orders_local(orderid),
    FOREIGN KEY (materialid) REFERENCES materials_(materialid)
);

-- יצירת 5 הזמנות חדשות
INSERT INTO orders_local (orderid, orderdate, paymentterms, supplierid)
VALUES
  (51, '2025-05-21', 'שוטף +60', 1),
  (52, '2025-05-22', 'מזומן', 3),
  (53, '2025-05-23', 'תשלומים', 5),
  (54, '2025-05-24', 'אשראי', 7),
  (55, '2025-05-25', 'שוטף +30', 9);

-- הכנסת פריטים לטבלת ordermaterials_local
INSERT INTO ordermaterials_local (orderid, materialid, quantity, supplierprice)
VALUES
  (51, 1, 100, 2.50),
  (52, 2, 50, 1.70),
  (53, 3, 200, 0.90),
  (54, 4, 120, 5.30),
  (55, 5, 75, 4.20);

-- עדכון מלאי של חומרים בהתאם להזמנות
UPDATE materials_ SET quantityavailable_ = quantityavailable_ + 100 WHERE materialid_ = 1;
UPDATE materials_ SET quantityavailable_ = quantityavailable_ + 50 WHERE materialid_ = 2;
UPDATE materials_ SET quantityavailable_ = quantityavailable_ + 200 WHERE materialid_ = 3;
UPDATE materials_ SET quantityavailable_ = quantityavailable_ + 120 WHERE materialid_ = 4;
UPDATE materials_ SET quantityavailable_ = quantityavailable_ + 75 WHERE materialid_ = 5;
