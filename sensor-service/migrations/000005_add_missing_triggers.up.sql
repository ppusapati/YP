-- ============================================================================
-- Sensor Service: Add missing updated_at trigger on sensor_readings
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_sensor_readings_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sensor_readings_set_updated_at
    BEFORE UPDATE ON sensor_readings
    FOR EACH ROW
    EXECUTE FUNCTION trg_sensor_readings_updated_at();
