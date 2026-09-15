-- ============================================================================
-- Satellite Service: Add missing updated_at trigger on satellite_tasks
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_satellite_tasks_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_satellite_tasks_set_updated_at
    BEFORE UPDATE ON satellite_tasks
    FOR EACH ROW
    EXECUTE FUNCTION trg_satellite_tasks_updated_at();
