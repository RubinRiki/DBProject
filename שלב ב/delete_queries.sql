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


-- שאילתה 3: מחיקת תהליכים שסומנו בטעות עם תאריך סיום עתידי
-- במערכת תקינה לא אמור להיות תהליך שמסתיים בעתיד, ולכן נמחקים תהליכים כאלו.

DELETE FROM productionprocess_
WHERE enddate_ > CURRENT_DATE;