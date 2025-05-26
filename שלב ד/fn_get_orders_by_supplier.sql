-- פונקציה: get_orders_by_supplier
-- תיאור: הפונקציה מקבלת שם ספק (VARCHAR) ומחזירה REF CURSOR עם כל ההזמנות מהספק הזה.
-- הפונקציה כוללת שימוש ב־Ref Cursor, חיבור בין טבלאות (JOIN), וטיפול בשגיאות (EXCEPTION).

CREATE OR REPLACE FUNCTION get_orders_by_supplier(supplier_name_input VARCHAR)
RETURNS refcursor AS $$
DECLARE
  orders_cursor refcursor;
BEGIN
  OPEN orders_cursor FOR
    SELECT o.orderid, o.orderdate
    FROM orders_local o
    JOIN supplier_local s ON o.supplierid = s.supplierid
    WHERE s.suppliername = supplier_name_input;

  RETURN orders_cursor;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error in get_orders_by_supplier: %', SQLERRM;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
