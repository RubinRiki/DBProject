-- תוכנית ראשית: main_orders_and_prices
-- תיאור: התוכנית מבצעת שתי פעולות:
-- 1. קריאה לפרוצדורה increase_prices_by_supplier כדי להעלות מחירים של ספק בשם 'Tara'.
-- 2. קריאה לפונקציה get_orders_by_supplier שמחזירה קורסור עם כל ההזמנות מהספק 'Tara', והדפסתן.

DO $$
DECLARE
  my_cursor refcursor;
  rec RECORD;
BEGIN
  -- קריאה לפרוצדורה שמעלה מחירים של מוצרים מספק מסוים
  CALL increase_prices_by_supplier('Tara', 7);

  -- קריאה לפונקציה שמחזירה REF CURSOR עם הזמנות מספק
  my_cursor := get_orders_by_supplier('Tara');

  -- מעבר על תוצאות הקורסור
  LOOP
    FETCH my_cursor INTO rec;
    EXIT WHEN NOT FOUND;
    RAISE NOTICE 'Order ID: %, Date: %', rec.orderid, rec.orderdate;
  END LOOP;

  CLOSE my_cursor;
END $$;
