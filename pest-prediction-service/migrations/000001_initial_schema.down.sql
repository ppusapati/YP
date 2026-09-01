-- ============================================================================
-- Pest Prediction Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_pest_alerts_set_updated_at ON pest_alerts;
DROP FUNCTION IF EXISTS trg_pest_alerts_updated_at();
DROP TABLE IF EXISTS pest_alerts;

DROP TRIGGER IF EXISTS trg_pest_predictions_set_updated_at ON pest_predictions;
DROP FUNCTION IF EXISTS trg_pest_predictions_updated_at();
DROP TABLE IF EXISTS pest_predictions;
