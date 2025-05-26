-- פונקציה: get_bottle_count_by_type
-- תיאור: הפונקציה מקבלת סוג יין (VARCHAR) ומחזירה את מספר הבקבוקים שיוצרו מסוג זה.
-- הפונקציה משתמשת ב־Cursor מפורש (explicit), לולאה (LOOP), תנאי (IF), משתנה מסוג RECORD, וטיפול בשגיאות (EXCEPTION).

CREATE OR REPLACE FUNCTION get_bottle_count_by_type(winetype_input VARCHAR)
RETURNS INTEGER AS $$
DECLARE
  rec RECORD;
  bottle_count INTEGER := 0;
  cur CURSOR FOR 
    SELECT numbottls 
    FROM finalproduct_ 
    WHERE winetype_ = winetype_input;
BEGIN
  OPEN cur;

  LOOP
    FETCH cur INTO rec;
    EXIT WHEN NOT FOUND;

    IF rec.numbottls IS NOT NULL THEN
      bottle_count := bottle_count + rec.numbottls;
    END IF;
  END LOOP;

  CLOSE cur;

  RAISE NOTICE 'Total bottles for %: %', winetype_input, bottle_count;
  RETURN bottle_count;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error in function: %', SQLERRM;
    RETURN -1;
END;
$$ LANGUAGE plpgsql;
