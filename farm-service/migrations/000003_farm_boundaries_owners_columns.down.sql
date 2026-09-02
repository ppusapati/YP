-- ============================================================================
-- Farm Service: Farm Boundaries, Farm Owners, and missing farms columns (DOWN)
-- ============================================================================

DROP TABLE IF EXISTS farm_owners CASCADE;
DROP FUNCTION IF EXISTS trg_farm_owners_updated_at();

DROP TABLE IF EXISTS farm_boundaries CASCADE;
DROP FUNCTION IF EXISTS trg_farm_boundaries_updated_at();

DROP INDEX IF EXISTS idx_farms_is_active;
ALTER TABLE farms DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE farms DROP COLUMN IF EXISTS is_active;
