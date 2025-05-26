-- תוכנית ראשית: main_bottles_and_material
-- תיאור: התוכנית מבצעת שתי פעולות:
-- 1. קריאה לפונקציה get_bottle_count_by_type כדי לחשב את כמות הבקבוקים מסוג 'Merlot'.
-- 2. קריאה לפרוצדורה add_material_if_not_exists כדי להוסיף חומר גלם אם הוא לא קיים.

DO $$
DECLARE
  bottle_count INTEGER;
BEGIN
  -- קריאה לפונקציה שמחזירה מספר בקבוקים לפי סוג יין
  bottle_count := get_bottle_count_by_type('Merlot');
  RAISE NOTICE 'Total bottles for Merlot: %', bottle_count;

  -- קריאה לפרוצדורה שמוסיפה חומר גלם אם הוא לא קיים
  CALL add_material_if_not_exists(1002, 'Oak Wood', 150, 1);
END $$;
