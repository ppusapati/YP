ALTER TABLE harvest_plans DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE harvest_plans DROP COLUMN IF EXISTS is_active;

ALTER TABLE yield_records DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE yield_records DROP COLUMN IF EXISTS is_active;

ALTER TABLE yield_predictions DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE yield_predictions DROP COLUMN IF EXISTS is_active;
