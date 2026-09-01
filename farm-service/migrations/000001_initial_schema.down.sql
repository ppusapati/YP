-- ============================================================================
-- Farm Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_farms_set_updated_at ON farms;
DROP FUNCTION IF EXISTS trg_farms_updated_at();
DROP TABLE IF EXISTS farms;
