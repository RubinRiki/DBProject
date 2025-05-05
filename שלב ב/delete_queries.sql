-- שאילתה 1: מחיקת תהליכי ייצור שהסתיימו לפני יותר מ־10 שנים
-- פעולה זו מנקה מהמערכת תהליכים ישנים מאוד שאינם רלוונטיים יותר לייצור פעיל.

DELETE FROM productionprocess_
WHERE enddate_ < CURRENT_DATE - INTERVAL '10 years';


-- שאילתה 2: מחיקת חומרי גלם שכמעט נגמרו ושלא נעשה בהם שימוש לאחרונה
-- חומרי גלם שהכמות הזמינה שלהם נמוכה מ־1 ולא היו בשימוש בשנתיים האחרונות נמחקים מהמלאי.

DELETE FROM materials_
WHERE quantityavailable_ < 1
AND materials_.materialid_ NOT IN (
    SELECT DISTINCT materialid_
    FROM process_materials pm
    JOIN productionprocess_ p ON pm.processid_ = p.processid_
    WHERE p.startdate_ > CURRENT_DATE - INTERVAL '2 years'
);


--השאילתה מוחקת תהליכי ייצור שהחלו בין התאריכים 1 במאי ל־4 במאי 2025, ועדיין לא הושלמו (כלומר, אין להם תאריך סיום).
 --מטרת הפעולה היא להסיר תהליכים שהוזנו אך לא המשיכו בפועל, לצורך ניקוי מידע לא פעיל מהמערכת.
DELETE FROM ProductionProcess_
WHERE StartDate_ BETWEEN '2025-05-01' AND '2025-05-04'
  AND EndDate_ IS NULL;