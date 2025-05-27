# DBProject
# 🍷 פרויקט בסיס נתונים – יקב חכם

## 👩‍💻 מגישות:
- ריקי רובין 326380359
- איילה כהן 327519161

## 📚 מבוא:
הפרויקט מתאר מערכת לניהול כולל של יקב. כל אחת מהמשתתפות בפרויקט אחראית על מחלקה שונה מתוך המערכת.  
המערכת שלנו מתמקדת במחלקת **הייצור** של היין – תהליך הליבה של פעילות היקב – ואנו אחראיות על עיצוב ויישום בסיס הנתונים שלה.

מערכת מחלקת הייצור עוקבת אחר שלבי הפקת היין: החל מבציר הענבים, דרך תהליכי הייצור השונים (כגון תסיסה, יישון וערבוב), וכלה ביצירת מוצר סופי.  
המערכת מתעדת את העובדים, הציוד, חומרי הגלם, הענבים והמיכלים הנדרשים לתהליך, וכן מאפשרת מעקב מדויק אחרי כל אצוות הייצור (Batch).

---

## 🧱 ישויות עיקריות במערכת:

| ישות | תיאור |
|------|--------|
| **Employee** | עובד ייצור המפעיל ציוד ומבצע תהליכים |
| **ProductionProcess** | שלב בתהליך הייצור (תסיסה, סינון, יישון, ערבוב) |
| **Grapes** | אצוות ענבים שנבצרו לשימוש בייצור |
| **RawMaterials** | חומרים נוספים כגון שמרים, חומרים משמרים וכו' |
| **Containers** | מיכלים וחביות ליישון היין |
| **ProductionEquipment** | ציוד ומכונות בשימוש |
| **FinalProduct** | ליין מוצרים סופי – כולל סוג יין וכמות בקבוקים |

---

## 🔄 קשרים עיקריים בין הישויות:

- כל תהליך מבוצע ע"י עובד אחד.
- כל תהליך משתמש במספר סוגי ציוד, חומרים, ענבים ומיכלים (קשרים M:N).
- כל 4 תהליכים מובילים ל־FinalProduct אחד.

---

## 🖼️ תרשימים:

### ERD:
![ERD](./ERD/image%20(2).png)

### DSD:
![DSD](./DSD/image%20(3).png)

---

## 🧪 הכנסת נתונים – 3 שיטות:

### ✅ שיטה 1: קבצי CSV
בוצעה ייבוא של נתונים לקובץ דרך `Import` ב־pgAdmin:
- Grapes.csv
- containers.csv
- final_product.csv

### ✅ שיטה 2: קוד Python
קבצים שנוצרו על ידי סקריפטים והוזנו למסד הנתונים:
- productionprocess.csv
- process_equipment.csv
- process_materials.csv
- process_containers.csv
- ועוד...

### ✅ שיטה 3: SQL ידני
קובץ `insertTables.sql` 

---

## 💾 גיבוי:
בוצע גיבוי לדאטאבייס דרך pgAdmin.  
שם הקובץ: `backup_22042025.backup`  
נמצא בתיקייה `שלב א`.

DBProject/ ├── שלב א/ │ ├── createTables.sql │ ├── dropTables.sql │ ├── insertTables.sql │ ├── selectAll.sql │ ├── backup_22042025.backup │ ├── ERD/ │ ├── DSD/ │ ├── Programing/ │ ├── DataImportFiles/ │ └── mockarooFiles/


## 🧩 שלב ב – שאילתות, אילוצים ופעולות בסיס נתונים
## 📄 קבצים שנוצרו:
- `queries_select.sql` – קובץ עם שאילתות SELECT.
- `update_queries (1).sql` – קובץ עם שאילתות UPDATE.
- `delete_queries.sql` – קובץ עם שאילתות DELETE.
- `Constraints.sql` – קובץ עם שלושה אילוצים (ALTER TABLE).
- `RollbackCommit.sql` – הדגמות של פעולות ROLLBACK ו־COMMIT.
- `images/` – תיקיית תמונות עם תיעוד תוצאות השאילתות.

עדכונים ושינויים:  
* שדה winetype_ הכיל ערכים מספריים ולכן עודכן ל־varchar(30)  
* עודכנו הערכים הבעייתיים ידנית לפי סוגי הענבים מתוך טבלה שנוצרה במיוחד (grape_varieties).  

## שאילתות SELECT

1️⃣ מספר עובדים וכמות תהליכים שהובילו  
מטרת השאילתה: להציג עבור כל עובד את מספר תהליכי הייצור שהוא הוביל.  
מאפשר לדעת מי מהעובדים יותר פעיל בתהליכים – אינדיקציה לניסיון או לעומס עבודה.  
<img src="שלב ב/images/select1.jpg" width="300" height="200"/>

2️⃣ מוצרים סופיים שבוקבקו ברבעון הראשון  
מטרת השאילתה: לשלוף מוצרים סופיים שבוקבקו בין ינואר למרץ, כולל תאריך הביקבוק וכמות הבקבוקים.  
עוזר לנתח זמני ייצור ולבדוק תפוקה לפי רבעון.  
<img src="שלב ב/images/select2.jpg" width="300" height="200"/>

3️⃣ כמות חומרי גלם בכל תהליך  
מטרת השאילתה: לבדוק כמה סוגים שונים של חומרי גלם שימשו בכל תהליך ייצור.  
שימושי לבדיקת מורכבות התהליכים – תהליך עם יותר חומרים עשוי להיות מורכב יותר.  
<img src="שלב ב/images/select3.jpg" width="300" height="200"/>

4️⃣ תהליכים לפי סוג ענבים  
מטרת השאילתה: להציג את כל התהליכים שבוצעו לפי סוג הענבים בהם נעשה שימוש.  
מאפשר מעקב אחר אילו ענבים משמשים באילו תהליכים – רלוונטי לניתוח איכות או התאמה.  
<img src="שלב ב/images/select4.jpg" width="300" height="200"/>

5️⃣ כמות הבקבוקים הסופיים לפי סוג ענבים  
מטרת השאילתה: לסכום את מספר הבקבוקים שיוצרו לפי סוג הענבים.  
עוזר לזהות אילו סוגי ענבים מובילים לתפוקה גבוהה יותר.  
<img src="שלב ב/images/select5.jpg" width="300" height="200"/>

6️⃣ תהליכים שהחלו בפברואר  
מטרת השאילתה: למצוא תהליכים שהחלו בחודש פברואר, כולל סוג הענבים ושם העובד שהוביל אותם.  
מאפשר ניתוח עונתי של התחלת תהליכים ומעקב אחרי פעילות עובדים לפי חודש.  
<img src="שלב ב/images/select6.jpg" width="300" height="200"/>

7️⃣ תהליכים עם הציוד שבו השתמשו  
מטרת השאילתה: להציג את הציוד שנעשה בו שימוש בכל תהליך, כולל סוג הציוד והסטטוס שלו.  
מאפשר לבדוק תקלות, עומס או תחזוקה לפי שימוש בציוד.  
<img src="שלב ב/images/select7.jpg" width="300" height="200"/>

8️⃣ תהליכי ייצור לפי חודש  
מטרת השאילתה: לקבץ את תהליכי הייצור לפי חודש התחלה ולספור כמה היו בכל חודש.  
מספק תמונת מצב של עומס עבודה לאורך זמן, רלוונטי לתכנון משאבים.  
<img src="שלב ב/images/select8.jpg" width="300" height="200"/>

## שאילתות UPDATE

1️⃣ עדכון סוג היין (winetype_) לפי סוג הענבים  
מעדכן את שדה winetype_ בטבלת finalproduct_ עבור מוצרים שעברו את כל 4 שלבי הייצור. נלקח ענב כלשהו מתוך התהליך.  
<img src="שלב ב/images/update1aa.jpg" width="300" height="200"/> <img src="שלב ב/images/update1a.jpg" width="300" height="200"/>

2️⃣ סגירת תהליך – עדכון enddate_ להיום  
עבור מוצרים שעברו את כל סוגי התהליך ועדיין אין להם enddate_.  
<img src="שלב ב/images/update2aa.jpg" width="300" height="200"/> <img src="שלב ב/images/update2a.jpg" width="300" height="200"/>

3️⃣ הורדת מלאי חומרי גלם  
אם הסכום הכולל של שימוש בחומר מסוים עבר 50 יחידות – מפחיתים 10 מהמלאי.  
<img src="שלב ב/images/update3aa.jpg" width="300" height="200"/> <img src="שלב ב/images/update3a.jpg" width="300" height="200"/>

## שאילתות DELETE  
התמונות יהיו אחת ליד השנייה – לפני, הרצה ותהליך

1️⃣ השאילתה מוחקת תהליכי ייצור שהסתיימו לפני יותר מ־10 שנים, במטרה לנקות תהליכים ישנים שכבר אינם רלוונטיים למעקב שוטף.  
<img src="שלב ב/images/delete1b.jpg" width="300" height="200"/> <img src="שלב ב/images/delete1.jpg" width="300" height="200"/> <img src="שלב ב/images/delete1a.jpg" width="300" height="200"/>  

2️⃣ השאילתה מוחקת חומרי גלם שהכמות הזמינה שלהם קטנה מ־1, ושלא נעשה בהם שימוש בשנתיים האחרונות, כדי לשמור על מלאי מעודכן ויעיל.  
<img src="שלב ב/images/delete2b.jpg" width="300" height="200"/> <img src="שלב ב/images/delete2.jpg" width="300" height="200"/> <img src="שלב ב/images/delete2a.jpg" width="300" height="200"/>  

3️⃣ השאילתה מוחקת תהליכי ייצור שהחלו בין התאריכים 1 במאי ל־4 במאי 2025, ועדיין לא הושלמו (כלומר, אין להם תאריך סיום). מטרת הפעולה היא להסיר תהליכים שהוזנו אך לא המשיכו בפועל, לצורך ניקוי מידע לא פעיל מהמערכת.  
<img src="שלב ב/images/delete3b.jpg" width="300" height="200"/> <img src="שלב ב/images/delete3.jpg" width="300" height="200"/> <img src="שלב ב/images/delete3a.jpg" width="300" height="200"/>  

## שימוש ב־ROLLBACK  
תיאור:  
ביצעתי הכנסת עובד זמני (ID = 999) בתוך טרנזקציה שלא אושרה. הפעולה בוטלה עם ROLLBACK, ולכן העובד לא נשמר בבסיס הנתונים.  

🔧 שלבי הפעולה:  
בדיקת קיום מקדים:  
<img src="שלב ב/images/rolb.JPG" width="300" height="200"/>  

תחילת טרנזקציה + הוספה:  
BEGIN;  
INSERT INTO employee (employeeid, role, name) VALUES (999, 'Tester', 'Temp');  

בדיקה לפני ביטול:  
<img src="שלב ב/images/rol.JPG" width="300" height="200"/>  

ביטול הפעולה:  
ROLLBACK;  

בדיקה אחרי ביטול:  
<img src="שלב ב/images/rola.JPG" width="300" height="200"/>  

## שימוש ב־COMMIT  
תיאור:  
ביצעתי הכנסת עובד חדש (ID = 888) בתוך טרנזקציה שאושרה עם COMMIT, ולכן הנתונים נשמרו בבסיס הנתונים לצמיתות.  

🔧 שלבי הפעולה:  
בדיקת קיום מקדים:  
SELECT * FROM employee WHERE employeeid = 888;  
<img src="שלב ב/images/comB.JPG" width="300" height="200"/>  

תחילת טרנזקציה + הוספה:  
BEGIN;  
INSERT INTO employee (employeeid, role, name) VALUES (888, 'qa', 'garry');  

בדיקה לפני אישור:  
SELECT * FROM employee WHERE employeeid = 888;  
<img src="שלב ב/images/com.JPG" width="300" height="200"/>  

אישור הפעולה:  
COMMIT;  

בדיקה לאחר אישור:  
SELECT * FROM employee WHERE employeeid = 888;  
<img src="שלב ב/images/comA.JPG" width="300" height="200"/>  

## אילוצים (Constraints)

1️⃣ אילוץ NOT NULL בטבלת employee  
בוצע על העמודה name כדי לוודא שלא ניתן להוסיף עובד ללא שם.  
ALTER TABLE employee ALTER COLUMN name SET NOT NULL;  
<img src="שלב ב/images/con1E.JPG" width="300" height="200"/>  

2️⃣ אילוץ 2 – CHECK על finalproduct_.numbottls  
המטרה:  אילוץ CHECK שמבטיח שכמות הבקבוקים numbottls לא תהיה שלילית. זה מגן על נתונים לא הגיוניים בדיווחי ייצור.  
ALTER TABLE finalproduct_ ADD CONSTRAINT check_positive_bottles CHECK (numbottls >= 0);  
<img src="שלב ב/images/con2E.JPG" width="300" height="200"/>  

3️⃣ אילוץ FOREIGN KEY בטבלת productionprocess_ על employeeid  
המטרה: לוודא שכל employeeid בתהליך יפנה לעובד קיים בטבלת employee  
ALTER TABLE productionprocess_ ADD CONSTRAINT fk_employee FOREIGN KEY (employeeid) REFERENCES employee(employeeid);  
<img src="שלב ב/images/con3E.JPG" width="300" height="200"/>


## 🧩 שלב ג – אינטגרציה ומבטים

קובץ הגיבוי לשלב זה נמצא בתקיה הראשית של הפרוייקט תחת השם backupStage3
### החלטות אינטגרציה:
✅ FinalProduct ←→ Product
הקשר ביניהם הוא 1:1, כך שכל FinalProduct משויך למוצר אחד בלבד מתוך Product.
לכן הוספנו את העמודה productid בטבלת finalproduct_, וקישרנו ל־product_local באמצעות FOREIGN KEY.

✅ עובדים (Employee)
מיזגנו את הטבלאות employee ו־employee_local לטבלה אחת בשם employee_merge.
כל הטבלאות שעבדו מול employee_local עודכנו כך שהקשר יהיה מול employee_merge.

✅ חומרי גלם והזמנות (Materials ←→ Orders)
יצרנו טבלה חדשה בשם ordermaterials_local שמייצגת קשר M:N בין חומרי גלם (materials_) להזמנות (orders_local).
כל שורה בטבלה כוללת orderid, materialid, quantity, ו־supplierprice.
בוצע קשר FOREIGN KEY מול שתי הטבלאות.
לאחר מכן הוזנו הזמנות חדשות עם חומרי גלם, והטבלה עודכנה.

✅ עדכון מלאי
לאחר הזנת החומרים להזמנות, עודכנה עמודת quantityavailable_ בטבלת materials_ בהתאם להגעת החומר.

✅ שימוש ב־VIEWים בלבד מול טבלאות stage3
לא השתמשנו ב־FOREIGN KEY מול טבלאות FOREIGN מ־stage3, אלא חיברנו באמצעות VIEWים להצגה ואינטגרציה.

✅ שינויים בסכמה
כל ההתאמות נעשו באמצעות ALTER TABLE, ללא יצירת טבלאות חדשות, פרט ל־ordermaterials_local.



### פקודות עיקריות שבוצעו: 

```sql

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER satge3_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'satge3', port '5432');

CREATE USER MAPPING FOR current_user
SERVER satge3_server
OPTIONS (user 'riki', password '1234');

ALTER TABLE finalproduct_
ADD COLUMN productid INT;

ALTER TABLE materials_
ADD COLUMN purchesid INT;

כל פקודות אלו נמצאים בקובץ: Integrate
```


תמונות התרשימים נמצאים בתקית השלב:
האגף שלנו:
<img src="/שלב ג/Procces_ERD.png" width="300" height="200"/> 

האגף שניתן לנו:
<img src="/שלב ג/DSD_stage3.png" width="300" height="200"/> 
<img src="/שלב ג/grocery_ERD.png" width="300" height="200"/>  

האגף המשולב:
<img src="/שלב ג/DSD_mixed.png" width="300" height="200"/> 
<img src="/שלב ג/ERD_mix.png" width="300" height="200"/>  

---

### 📊 VIEWים שנוצרו:

#### 1️⃣ view_production_bottling_summary  
מציג את תהליכי ייצור היין – כולל מזהה התהליך, תאריך התחלה, מספר האצווה, סוג היין, כמות בקבוקים, וקיבולת המיכל שבו נשמרו.

```sql
CREATE VIEW view_production_bottling_summary AS
SELECT
  pp.processid_,
  pp.startdate_,
  fp.batchnumber_,
  fp.winetype_,
  fp.numbottls,
  c.capacityl_ AS container_capacity
FROM productionprocess_ pp
JOIN finalproduct_ fp ON pp.batchnumber_ = fp.batchnumber_
JOIN processcontainers pc ON pp.processid_ = pc.processid_
JOIN containers_ c ON pc.containerid_ = c.containerid_;
```


#### 2️⃣ view_order_supplier_summary  
מחבר בין הזמנות לספקים – מציג את מזהה ההזמנה, תאריך ההזמנה, ושם הספק.

```sql
CREATE VIEW view_order_supplier_summary AS
SELECT
  o.orderid,
  o.orderdate,
  s.suppliername
FROM orders o
JOIN supplier s ON o.supplierid = s.supplierid;
```


###  שאילתות על VIEWים:

#### 🔍 view_production_bottling_summary – שאילתה 1: מיכלים לא יעילים  
**תיאור:** השאילתה בודקת תהליכים שבהם קיבולת המיכל גדולה לפחות פי 2 מכמות הבקבוקים – מצב של חוסר ניצול משאבים.

```sql
SELECT *
FROM view_production_bottling_summary
WHERE container_capacity >= numbottls * 2;
```

<img src="/שלב ג/img/V1S1.png" width="300" height="200"/>  

---

#### 📊 view_production_bottling_summary – שאילתה 2: ממוצע בקבוקים לפי סוג יין  
**תיאור:** מחשבת את ממוצע מספר הבקבוקים שיוצרו עבור כל סוג יין.

```sql
SELECT winetype_, AVG(numbottls) AS avg_bottles
FROM view_production_bottling_summary
GROUP BY winetype_;
```

<img src="/שלב ג/img/V1S2.png" width="300" height="200"/>  

---

#### 📦 view_order_supplier_summary – שאילתה 1: הזמנות מ"אביב טכנולוגי"  
**תיאור:** מציגה את כל ההזמנות שבוצעו מול ספק בשם "אביב טכנולוגי".

```sql
SELECT *
FROM view_order_supplier_summary
WHERE suppliername = 'אביב טכנולוגי';
```

<img src="/שלב ג/img/V2S1.png" width="300" height="200"/>  

---

#### 📈 view_order_supplier_summary – שאילתה 2: מספר הזמנות לכל ספק  
**תיאור:** מציגה את מספר ההזמנות שביצע כל ספק במערכת.

```sql
SELECT suppliername, COUNT(*) AS total_orders
FROM view_order_supplier_summary
GROUP BY suppliername;
```

<img src="/שלב ג/img/V2S2.png" width="300" height="200"/>  


# 🧩 שלב ד – תכנות | פרויקט מסדי נתונים

בשלב זה התמקדנו ביצירת פונקציות, פרוצדורות, טריגרים ותוכניות ראשיות באמצעות PL/pgSQL, בהתאם לסכמת הנתונים המורחבת שבנינו בשלבים הקודמים.

---

## 📌 תוכן הקבצים

- `fn_get_bottle_count_by_type.sql` – פונקציה 1
- `fn_get_orders_by_supplier.sql` – פונקציה 2
- `proc_increase_prices_by_supplier.sql` – פרוצדורה 1
- `proc_add_material_if_not_exists.sql` – פרוצדורה 2
- `trg_update_last_updated.sql` – טריגר 1
- `trg_validate_material_insert.sql` – טריגר 2
- `trg_complete_batch_bottling.sql` – טריגר 3
- `main_bottles_and_material.sql` – תוכנית ראשית 1
- `main_orders_and_prices.sql` – תוכנית ראשית 2
- `AlterTable.sql` – כל שינויי הטבלאות
- תיקיית `img/` – כל הוכחות ההרצה (צילומי מסך)

---

## 🧮 פונקציה 1 – get_bottle_count_by_type

<img src="/שלב ד/img/proof_bottle_count_notice.JPG" width="300"/>
<br><sub>הרצת הפונקציה עם Merlot והחזרת NOTICE</sub>

---

## 🧾 פונקציה 2 – get_orders_by_supplier

<img src="/שלב ד/img/proof_orders_cursor_notice.JPG" width="300"/>
<br><sub>לולאה על תוצאות הפונקציה והצגת כל הזמנה</sub>

---

## 🛠 פרוצדורה 1 – increase_prices_by_supplier

<img src="/שלב ד/img/increase_prices_before.JPG" width="300"/>
<img src="/שלב ד/img/increase_prices_call.JPG" width="300"/>
<img src="/שלב ד/img/increase_prices_after.JPG" width="300"/>
<br><sub>לפני, במהלך ואחרי קריאה לפרוצדורה</sub>

---

## 🧪 פרוצדורה 2 – add_material_if_not_exists

<img src="/שלב ד/img/add_material_before.JPG" width="300"/>
<img src="/שלב ד/img/add_material_call.JPG" width="300"/>
<img src="/שלב ד/img/add_material_after.JPG" width="300"/>
<br><sub>בדיקה לפני, הפעלת הפרוצדורה, בדיקה אחרי</sub>

---

## 🧷 טריגר 1 – trg_update_last_updated

<img src="/שלב ד/img/proof_last_updated_before.JPG" width="300"/>
<img src="/שלב ד/img/last_updated_update.JPG" width="300"/>
<img src="/שלב ד/img/last_updated_after.JPG" width="300"/>
<br><sub>שדה מתעדכן אוטומטית לאחר UPDATE</sub>

---

## 🛡 טריגר 2 – trg_validate_material_insert

<img src="/שלב ד/img/validate_material_before.JPG" width="300"/>
<img src="/שלב ד/img/validate_material_insert_fail.JPG" width="300"/>
<img src="/שלב ד/img/validate_material_after.JPG" width="300"/>
<br><sub>בדיקה שהשורה לא התווספה בעקבות החריגה</sub>

---

## 🍷 טריגר 3 – trg_complete_batch_bottling

<img src="/שלב ד/img/bottlingdate_before.JPG" width="300"/>
<img src="/שלב ד/img/bottlingdate_insert_processes.JPG" width="300"/>
<img src="/שלב ד/img/bottlingdate_after.JPG" width="300"/>
<br><sub>עדכון אוטומטי של BottlingDate לאחר הוספת תהליך רביעי</sub>

---

## ▶️ תוכנית ראשית 1 – main_bottles_and_material

<img src="/שלב ד/img/main1_before.JPG" width="300"/>
<img src="/שלב ד/img/main1_execution.JPG" width="300"/>
<img src="/שלב ד/img/main1_after.JPG" width="300"/>
<br><sub>בדיקה לפני, הרצה עם NOTICE, בדיקה אחרי</sub>

---

## ▶️ תוכנית ראשית 2 – main_orders_and_prices

<img src="/שלב ד/img/main2_before.JPG" width="300"/>
<img src="/שלב ד/img/main2_execution.JPG" width="300"/>
<img src="/שלב ד/img/main2_after.JPG" width="300"/>
<br><sub>לפני-הרצה-אחרי כולל הודעות</sub>

---

## 📦 שינויי מבנה טבלאות (ALTER TABLE)

```sql
ALTER TABLE product_local ADD COLUMN last_updated TIMESTAMP;
ALTER TABLE FinalProduct_ ADD COLUMN BottlingDate TIMESTAMP;
```

---

## 💾 קובץ גיבוי

- `backup4` – גיבוי מלא למצב הנתונים לאחר שלב ד

---

## 🏁 סיכום

בשלב זה התמקדנו ביצירת לוגיקה מתקדמת באמצעות PL/pgSQL תוך שילוב:
- Cursor, Refcursor
- לולאות, תנאים, עדכונים
- חריגות (Exception)
- ושילוב מלא עם סכמת הנתונים שהוקמה בשלבים הקודמים.
