DROP INDEX IF EXISTS idx_crop_cycles_management_unit;
ALTER TABLE crop_cycles DROP COLUMN IF EXISTS management_unit_id;
