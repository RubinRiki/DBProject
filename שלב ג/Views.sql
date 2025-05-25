מבטים ושאילתות:

מבט 1- מנקודת המבט של מחלקת היין
מבט זה מציג מידע על תהליך ייצור היין – כמה בקבוקים נוצרו, באיזה מיכל הם נשמרו, ומה הייתה קיבולת המיכל.

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


🔹שאילתה 1: זיהוי תהליכים שבהם קיבולת המיכל הייתה גדולה משמעותית מהצורך
SELECT *
FROM view_production_bottling_summary
WHERE container_capacity >= numbottls * 2;


🔹שאילתה 2: ממוצע כמות בקבוקים לפי סוג יין

SELECT winetype_, AVG(numbottls) AS avg_bottles
FROM view_production_bottling_summary
GROUP BY winetype_;

מבט שני- מנקודת המבט של המכולת
המבט מחבר בין טבלת ההזמנות (orders) לבין טבלת הספקים (supplier) ומאפשר לראות מתי הוזמן משהו, וממי.

CREATE VIEW view_order_supplier_summary AS
SELECT
  o.orderid,
  o.orderdate,
  s.suppliername
FROM orders o
JOIN supplier s ON o.supplierid = s.supplierid;




 שאילתה 1: כל ההזמנות שבוצעו מספק בשם 'אביב טכנולוגי'
SELECT *
FROM view_order_supplier_summary
WHERE suppliername = 'אביב טכנולוגי';


 שאילתה 2: מספר ההזמנות שביצע כל ספק
SELECT suppliername, COUNT(*) AS total_orders
FROM view_order_supplier_summary
GROUP BY suppliername;






