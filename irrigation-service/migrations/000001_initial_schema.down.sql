-- ============================================================================
-- Irrigation Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TABLE IF EXISTS irrigation_events;

DROP TRIGGER IF EXISTS trg_irrigation_schedules_set_updated_at ON irrigation_schedules;
DROP FUNCTION IF EXISTS trg_irrigation_schedules_updated_at();
DROP TABLE IF EXISTS irrigation_schedules;

DROP TRIGGER IF EXISTS trg_irrigation_zones_set_updated_at ON irrigation_zones;
DROP FUNCTION IF EXISTS trg_irrigation_zones_updated_at();
DROP TABLE IF EXISTS irrigation_zones;
