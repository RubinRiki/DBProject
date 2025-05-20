-- מבט 1: unified_employees (איחוד עובדים)
CREATE VIEW unified_employees AS
SELECT
  employeeid,
  name AS employeename,
  NULL::DATE AS hiredate,
  role AS role_description
FROM employee

UNION ALL

SELECT
  employeeid,
  employeename,
  hiredate,
  r.rolename AS role_description
FROM employee_stage3 e
JOIN role_stage3 r ON e.roleid = r.roleid;


-- מבט 2: finalproduct_with_info (קשר בין ייצור למוצר)
CREATE VIEW finalproduct_with_info AS
SELECT
  f.batchnumber_,
  f.productid,
  f.winetype_,
  f.bottlingdate_,
  f.numbottls,
  p.productname,
  p.brand,
  p.price,
  p.stockquantity
FROM finalproduct_ f
JOIN product_stage3 p
ON f.productid = p.productid;


-- מבט 3: materials_with_purchase (חומרי גלם מול רכישות)
CREATE VIEW materials_with_purchase AS
SELECT
  m.materialid_,
  m.name_,
  m.quantityavailable_,
  m.purchesid,
  p.paymentmethod
FROM materials_ m
JOIN purchase_stage3 p ON m.purchesid = p.purchesid;


-- מבט 4: procurement_orders_summary (רכש – סיכום הזמנות)
CREATE VIEW procurement_orders_summary AS
SELECT
  o.orderid,
  o.orderdate,
  s.suppliername,
  COUNT(oi.productid) AS products_count,
  SUM(oi.supplierprice * oi.quantity) AS total_order_price
FROM orders_stage3 o
JOIN supplier_stage3 s ON o.supplierid = s.supplierid
JOIN orderitems_stage3 oi ON o.orderid = oi.orderid
GROUP BY o.orderid, o.orderdate, s.suppliername;
