-- ============================================================================
-- Sensor Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TABLE IF EXISTS sensor_readings;

DROP TRIGGER IF EXISTS trg_sensors_set_updated_at ON sensors;
DROP FUNCTION IF EXISTS trg_sensors_updated_at();
DROP TABLE IF EXISTS sensors;
