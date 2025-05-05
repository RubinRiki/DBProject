-- 1. מספר עובדים וכמות תהליכים שהובילו (לפי employeeid)
SELECT 
    e.employeeid,
    e.name,
    COUNT(pp.processid_) AS num_processes
FROM 
    employee AS e
LEFT JOIN 
    productionprocess_ AS pp ON pp.employeeid = e.employeeid
GROUP BY 
    e.employeeid, e.name
ORDER BY 
    num_processes DESC;

-- 2. מוצרים סופיים שבוקבקו ברבעון הראשון
SELECT 
    batchnumber_,
    winetype_,
    bottlingdate_,
    numbottls
FROM 
    finalproduct_
WHERE 
    EXTRACT(MONTH FROM bottlingdate_) BETWEEN 1 AND 3
ORDER BY 
    bottlingdate_;

-- 3. כמות חומרי גלם בכל תהליך
SELECT 
    processid_,
    COUNT(DISTINCT materialid_) AS num_materials
FROM 
    process_materials
GROUP BY 
    processid_;

-- 4. תהליכים לפי סוג ענבים
SELECT 
    pp.processid_,
    g.variety,
    pp.startdate_,
    pp.enddate_
FROM 
    productionprocess_ AS pp
JOIN 
    grapes AS g ON pp.grapeid = g.grapeid
ORDER BY 
    g.variety;

-- 5. כמות הבקבוקים הסופיים שהופקו לפי סוג ענבים
SELECT 
    g.variety,
    SUM(fp.numbottls) AS total_bottles
FROM 
    grapes AS g
JOIN 
    productionprocess_ AS pp ON pp.grapeid = g.grapeid
JOIN 
    finalproduct_ AS fp ON fp.batchnumber_ = pp.batchnumber_
GROUP BY 
    g.variety
ORDER BY 
    total_bottles DESC;

-- 6. תהליכים שהחלו בפברואר
SELECT 
    pp.processid_,
    g.variety,
    e.name AS employee_name,
    pp.startdate_
FROM 
    productionprocess_ AS pp
JOIN 
    grapes AS g ON pp.grapeid = g.grapeid
JOIN 
    employee AS e ON pp.employeeid = e.employeeid
WHERE 
    EXTRACT(MONTH FROM pp.startdate_) = 2;

-- 7. תהליכים עם הציוד שבו השתמשו
SELECT 
    pp.processid_,
    peq.equipmentid_,
    pe.type_,
    pe.status_
FROM 
    process_equipment AS peq
JOIN 
    productionprocess_ AS pp ON peq.processid_ = pp.processid_
JOIN 
    productionequipment_ AS pe ON pe.equipmentid_ = peq.equipmentid_;

-- 8. תהליכי ייצור מקובצים לפי חודש התחלה, כולל כמות
SELECT 
    EXTRACT(YEAR FROM startdate_) AS year,
    EXTRACT(MONTH FROM startdate_) AS month,
    COUNT(*) AS num_processes
FROM 
    productionprocess_
GROUP BY 
    EXTRACT(YEAR FROM startdate_), EXTRACT(MONTH FROM startdate_)
ORDER BY 
    year, month;

