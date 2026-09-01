-- ============================================================================
-- Yield Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_yield_records_set_updated_at ON yield_records;
DROP FUNCTION IF EXISTS trg_yield_records_updated_at();
DROP TABLE IF EXISTS yield_records;

DROP TRIGGER IF EXISTS trg_yield_predictions_set_updated_at ON yield_predictions;
DROP FUNCTION IF EXISTS trg_yield_predictions_updated_at();
DROP TABLE IF EXISTS yield_predictions;
