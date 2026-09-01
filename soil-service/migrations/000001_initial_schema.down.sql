-- ============================================================================
-- Soil Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_soil_analyses_set_updated_at ON soil_analyses;
DROP FUNCTION IF EXISTS trg_soil_analyses_updated_at();
DROP TABLE IF EXISTS soil_analyses;

DROP TRIGGER IF EXISTS trg_soil_samples_set_updated_at ON soil_samples;
DROP FUNCTION IF EXISTS trg_soil_samples_updated_at();
DROP TABLE IF EXISTS soil_samples;
