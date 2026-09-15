-- ============================================================================
-- Irrigation Service: Add missing updated_at trigger on irrigation_events
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_irrigation_events_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_irrigation_events_set_updated_at
    BEFORE UPDATE ON irrigation_events
    FOR EACH ROW
    EXECUTE FUNCTION trg_irrigation_events_updated_at();
