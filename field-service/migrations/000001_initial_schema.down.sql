-- ============================================================================
-- Field Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_crop_assignments_set_updated_at ON crop_assignments;
DROP FUNCTION IF EXISTS trg_crop_assignments_updated_at();
DROP TABLE IF EXISTS crop_assignments;

DROP TABLE IF EXISTS field_boundaries;

DROP TRIGGER IF EXISTS trg_fields_set_updated_at ON fields;
DROP FUNCTION IF EXISTS trg_fields_updated_at();
DROP TABLE IF EXISTS fields;
