-- ============================================================================
-- Crop Service: Growth Stages, Requirements, Recommendations Migration (DOWN)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_crop_recommendations_set_updated_at ON crop_recommendations;
DROP FUNCTION IF EXISTS trg_crop_recommendations_updated_at();
DROP TABLE IF EXISTS crop_recommendations;

DROP TRIGGER IF EXISTS trg_crop_requirements_set_updated_at ON crop_requirements;
DROP FUNCTION IF EXISTS trg_crop_requirements_updated_at();
DROP TABLE IF EXISTS crop_requirements;

DROP TRIGGER IF EXISTS trg_crop_growth_stages_set_updated_at ON crop_growth_stages;
DROP FUNCTION IF EXISTS trg_crop_growth_stages_updated_at();
DROP TABLE IF EXISTS crop_growth_stages;

DROP INDEX IF EXISTS idx_crop_varieties_is_active;
ALTER TABLE crop_varieties DROP COLUMN IF EXISTS updated_by;
ALTER TABLE crop_varieties DROP COLUMN IF EXISTS created_by;
ALTER TABLE crop_varieties DROP COLUMN IF EXISTS is_active;

DROP INDEX IF EXISTS idx_crops_is_active;
DROP INDEX IF EXISTS idx_crops_status;
ALTER TABLE crops DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE crops DROP COLUMN IF EXISTS updated_by;
ALTER TABLE crops DROP COLUMN IF EXISTS created_by;
ALTER TABLE crops DROP COLUMN IF EXISTS is_active;
ALTER TABLE crops DROP COLUMN IF EXISTS status;
