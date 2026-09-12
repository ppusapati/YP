-- ============================================================================
-- Satellite Analytics Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_stress_alerts_set_updated_at ON stress_alerts;
DROP FUNCTION IF EXISTS trg_stress_alerts_updated_at();
DROP TABLE IF EXISTS temporal_analyses;
DROP TABLE IF EXISTS stress_alerts;
DROP TYPE IF EXISTS analysis_type;
DROP TYPE IF EXISTS severity_level;
DROP TYPE IF EXISTS stress_type;
