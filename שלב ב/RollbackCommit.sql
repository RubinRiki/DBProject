
-- 🔁 דוגמה 1: שימוש ב־ROLLBACK

-- בדיקה לפני - האם העובד כבר קיים
SELECT * FROM employee WHERE employeeid = 999;

-- התחלת טרנזקציה
BEGIN;

-- הכנסת עובד זמני
INSERT INTO employee (employeeid, role, name)
VALUES (999, 'Tester', 'Temp');

-- בדיקה שהעובד נוסף
SELECT * FROM employee WHERE employeeid = 999;

-- ביטול הפעולה
ROLLBACK;

-- בדיקה לאחר ROLLBACK - העובד אמור לא להופיע
SELECT * FROM employee WHERE employeeid = 999;



-- ✅ דוגמה 2: שימוש ב־COMMIT

-- בדיקה לפני - האם העובד כבר קיים
SELECT * FROM employee WHERE employeeid = 888;

-- התחלת טרנזקציה
BEGIN;

-- הכנסת עובד חדש
INSERT INTO employee (employeeid, role, name)
VALUES (888, 'Manager', 'CommitGuy');

-- בדיקה שהעובד נוסף
SELECT * FROM employee WHERE employeeid = 888;

-- אישור הפעולה
COMMIT;

-- בדיקה לאחר COMMIT - העובד אמור להופיע
SELECT * FROM employee WHERE employeeid = 888;
