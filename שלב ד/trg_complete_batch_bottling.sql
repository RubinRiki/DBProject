-- טריגר: trg_complete_batch_bottling
-- תיאור: כאשר לאצווה מסוימת (BatchNumber_) הוזנו כל 4 סוגי התהליכים השונים בטבלת ProductionProcess_,
-- יתעדכן השדה BottlingDate בטבלת FinalProduct_ לאותה אצווה.
-- מתבצע לאחר כל INSERT ל-ProductionProcess_.
-- כולל בדיקה לפי COUNT(DISTINCT Type_), עדכון BottlingDate, ו-RAISE NOTICE.

-- פונקציית הטריגר
CREATE OR REPLACE FUNCTION update_bottling_date_if_completed()
RETURNS TRIGGER AS $$
DECLARE
  process_type_count INT;
BEGIN
  -- בדיקה כמה סוגי תהליך שונים בוצעו עבור האצווה
  SELECT COUNT(DISTINCT Type_) INTO process_type_count
  FROM ProductionProcess_
  WHERE BatchNumber_ = NEW.BatchNumber_;

  -- אם בוצעו כל 4 הסוגים - נעדכן את BottlingDate
  IF process_type_count = 4 THEN
    UPDATE FinalProduct_
    SET BottlingDate_ = NOW()
    WHERE BatchNumber_ = NEW.BatchNumber_;

    RAISE NOTICE 'All 4 process types completed. BottlingDate updated for batch %', NEW.BatchNumber_;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- יצירת הטריגר
CREATE TRIGGER trg_complete_batch_bottling
AFTER INSERT ON ProductionProcess_
FOR EACH ROW
EXECUTE FUNCTION update_bottling_date_if_completed();
