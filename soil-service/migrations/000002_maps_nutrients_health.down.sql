-- ============================================================================
-- Soil Service: Maps, Nutrients, Health Scores + Audit Columns (DOWN)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_soil_health_scores_set_updated_at ON soil_health_scores;
DROP FUNCTION IF EXISTS trg_soil_health_scores_updated_at();
DROP TABLE IF EXISTS soil_health_scores;

DROP TRIGGER IF EXISTS trg_soil_nutrients_set_updated_at ON soil_nutrients;
DROP FUNCTION IF EXISTS trg_soil_nutrients_updated_at();
DROP TABLE IF EXISTS soil_nutrients;

DROP TRIGGER IF EXISTS trg_soil_maps_set_updated_at ON soil_maps;
DROP FUNCTION IF EXISTS trg_soil_maps_updated_at();
DROP TABLE IF EXISTS soil_maps;

DROP INDEX IF EXISTS idx_soil_analyses_is_active;
ALTER TABLE soil_analyses
    DROP COLUMN IF EXISTS deleted_by,
    DROP COLUMN IF EXISTS updated_by,
    DROP COLUMN IF EXISTS created_by,
    DROP COLUMN IF EXISTS is_active;

DROP INDEX IF EXISTS idx_soil_samples_is_active;
ALTER TABLE soil_samples
    DROP COLUMN IF EXISTS deleted_by,
    DROP COLUMN IF EXISTS updated_by,
    DROP COLUMN IF EXISTS created_by,
    DROP COLUMN IF EXISTS is_active;
