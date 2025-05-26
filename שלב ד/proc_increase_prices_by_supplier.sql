-- פרוצדורה: increase_prices_by_supplier
-- תיאור: הפרוצדורה מקבלת שם ספק ואחוז העלאה, ומעדכנת את מחירי המוצרים של הספק בהתאם.
-- הפרוצדורה כוללת: לולאה (FOR), שימוש ברשומות (RECORD), פקודת UPDATE, טיפול בשגיאות (EXCEPTION),
-- הדפסת נתונים עם RAISE NOTICE, וספירת כמות המוצרים שעודכנו.

CREATE OR REPLACE PROCEDURE increase_prices_by_supplier(supplier_name_input VARCHAR, percent_increase NUMERIC)
LANGUAGE plpgsql AS $$
DECLARE
  prod RECORD;
  updated_count INTEGER := 0;
BEGIN
  FOR prod IN
    SELECT p.productid, p.price
    FROM product_local p
    JOIN orders_local o ON o.supplierid = (SELECT supplierid FROM supplier_local WHERE suppliername = supplier_name_input)
    JOIN orderitems_local oi ON o.orderid = oi.orderid AND oi.productid = p.productid
  LOOP
    UPDATE product_local
    SET price = price * (1 + percent_increase / 100)
    WHERE productid = prod.productid;

    updated_count := updated_count + 1;
    RAISE NOTICE 'Updated product %: new price set', prod.productid;
  END LOOP;

  RAISE NOTICE 'Total products updated: %', updated_count;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error during price update: %', SQLERRM;
END;
$$;
