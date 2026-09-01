-- ============================================================================
-- Crop Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_crop_varieties_set_updated_at ON crop_varieties;
DROP FUNCTION IF EXISTS trg_crop_varieties_updated_at();
DROP TABLE IF EXISTS crop_varieties;

DROP TRIGGER IF EXISTS trg_crops_set_updated_at ON crops;
DROP FUNCTION IF EXISTS trg_crops_updated_at();
DROP TABLE IF EXISTS crops;
