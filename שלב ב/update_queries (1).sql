-- שאילתה 1: עדכון סוג היין לפי סוג הענבים (רק אם עבר את כל 4 סוגי התהליך)
-- השאילתה מעדכנת את סוג היין (winetype_) של מוצרים שהושלמו אחרי שעברו את כל ארבעת סוגי התהליך.
-- העדכון מתבצע לפי סוג הענבים ששימשו בתהליך.
UPDATE finalproduct_
SET winetype_ = (
    SELECT gv.name
    FROM productionprocess_ p
    JOIN grapes g ON p.grapeid = g.grapeid
    JOIN grape_varieties gv ON g.variety = gv.id
    WHERE p.batchnumber_ = finalproduct_.batchnumber_
    LIMIT 1
)
WHERE batchnumber_ IN (
    SELECT batchnumber_
    FROM productionprocess_
    GROUP BY batchnumber_
    HAVING COUNT(DISTINCT type_) = 4
);



-- שאילתה 2: סגירת תהליך – עדכון enddate להיום עבור תהליכים שהושלמו
-- השאילתה מעדכנת את שדה enddate לתאריך של היום, רק לתהליכים השייכים למוצר שעבר את כל ארבעת סוגי התהליך.
-- מתבצע רק אם enddate עדיין ריק (NULL), כדי לסמן שהתהליך הסתיים רשמית.

UPDATE productionprocess_
SET enddate_ = CURRENT_DATE
WHERE batchnumber_ IN (
    SELECT batchnumber_
    FROM productionprocess_
    GROUP BY batchnumber_
    HAVING COUNT(DISTINCT type_) = 4
)
AND enddate_ IS NULL;


-- שאילתה 3: הורדת מלאי חומרי גלם – אם השתמשו ביותר מ־50 יחידות
-- אם סך השימוש באחד מחומרי הגלם עבר 50 יחידות, נבצע הפחתה של 10 מהכמות הזמינה במלאי.
-- זה מדמה מערכת שמבצעת עדכון שוטף לפי צריכה בפועל.
UPDATE materials_
SET quantityavailable_ = quantityavailable_ - 10
WHERE materialid_ IN (
    SELECT materialid_
    FROM process_materials
    GROUP BY materialid_
    HAVING SUM(usageamount) > 50
);
