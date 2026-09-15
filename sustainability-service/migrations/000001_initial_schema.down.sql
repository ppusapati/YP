-- ============================================================================
-- Sustainability Service: Initial Schema Migration (DOWN)
-- ============================================================================

DROP POLICY IF EXISTS footprints_tenant_policy ON footprints;
DROP POLICY IF EXISTS input_uses_tenant_policy ON input_uses;

DROP INDEX IF EXISTS idx_footprints_farm;
DROP TABLE IF EXISTS footprints;

DROP INDEX IF EXISTS idx_input_uses_field_year;
DROP INDEX IF EXISTS idx_input_uses_field_date;
DROP TABLE IF EXISTS input_uses;
