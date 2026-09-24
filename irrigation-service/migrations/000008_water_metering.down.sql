-- ============================================================================
-- Irrigation Service: Water Metering Migration (DOWN)
-- ============================================================================

DROP INDEX IF EXISTS idx_water_usage_logs_source;
DROP INDEX IF EXISTS idx_water_usage_logs_zone_period;
DROP INDEX IF EXISTS idx_water_usage_logs_event;

ALTER TABLE water_usage_logs
    DROP COLUMN IF EXISTS source,
    DROP COLUMN IF EXISTS event_id;

ALTER TABLE irrigation_events
    DROP COLUMN IF EXISTS meter_start_liters,
    DROP COLUMN IF EXISTS meter_end_liters,
    DROP COLUMN IF EXISTS water_source;
