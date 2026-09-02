-- ============================================================================
-- Pest Prediction Service: Migration 000002 DOWN
-- ============================================================================
DROP TABLE IF EXISTS pest_risk_maps CASCADE;
DROP TABLE IF EXISTS pest_observations CASCADE;
DROP TABLE IF EXISTS pest_species CASCADE;

DROP FUNCTION IF EXISTS trg_pest_risk_maps_updated_at();
DROP FUNCTION IF EXISTS trg_pest_observations_updated_at();
DROP FUNCTION IF EXISTS trg_pest_species_updated_at();
