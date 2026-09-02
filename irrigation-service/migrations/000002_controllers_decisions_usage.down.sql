-- ============================================================================
-- Irrigation Service: Controllers, Decisions, Water Usage Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_water_usage_logs_set_updated_at ON water_usage_logs;
DROP FUNCTION IF EXISTS trg_water_usage_logs_updated_at();
DROP TABLE IF EXISTS water_usage_logs;

DROP TRIGGER IF EXISTS trg_irrigation_decisions_set_updated_at ON irrigation_decisions;
DROP FUNCTION IF EXISTS trg_irrigation_decisions_updated_at();
DROP TABLE IF EXISTS irrigation_decisions;

DROP TRIGGER IF EXISTS trg_water_controllers_set_updated_at ON water_controllers;
DROP FUNCTION IF EXISTS trg_water_controllers_updated_at();
DROP TABLE IF EXISTS water_controllers;
