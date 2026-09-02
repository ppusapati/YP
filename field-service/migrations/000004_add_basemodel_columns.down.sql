DROP INDEX IF EXISTS idx_fields_is_active;
ALTER TABLE fields DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE fields DROP COLUMN IF EXISTS is_active;
