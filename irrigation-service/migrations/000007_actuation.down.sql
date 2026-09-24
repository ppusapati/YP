-- ============================================================================
-- Irrigation Service: Actuation Migration (DOWN)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_irrigation_commands_set_updated_at ON irrigation_commands;
DROP FUNCTION IF EXISTS trg_irrigation_commands_updated_at();
DROP TABLE IF EXISTS irrigation_commands;

ALTER TABLE irrigation_zones
    DROP COLUMN IF EXISTS max_run_minutes,
    DROP COLUMN IF EXISTS min_rest_minutes,
    DROP COLUMN IF EXISTS max_daily_minutes,
    DROP COLUMN IF EXISTS automatic;
