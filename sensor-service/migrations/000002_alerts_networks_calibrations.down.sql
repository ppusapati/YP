-- ============================================================================
-- Sensor Service: Alerts, Networks, Calibrations Migration (DOWN)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_sensor_calibrations_set_updated_at ON sensor_calibrations;
DROP FUNCTION IF EXISTS trg_sensor_calibrations_updated_at();
DROP TABLE IF EXISTS sensor_calibrations;

DROP TRIGGER IF EXISTS trg_sensor_networks_set_updated_at ON sensor_networks;
DROP FUNCTION IF EXISTS trg_sensor_networks_updated_at();
DROP TABLE IF EXISTS sensor_networks;

DROP TRIGGER IF EXISTS trg_sensor_alerts_set_updated_at ON sensor_alerts;
DROP FUNCTION IF EXISTS trg_sensor_alerts_updated_at();
DROP TABLE IF EXISTS sensor_alerts;

ALTER TABLE sensor_readings RENAME COLUMN recorded_at TO "timestamp";

ALTER TABLE sensors DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE sensors DROP COLUMN IF EXISTS updated_by;
ALTER TABLE sensors DROP COLUMN IF EXISTS created_by;
ALTER TABLE sensors DROP COLUMN IF EXISTS is_active;
