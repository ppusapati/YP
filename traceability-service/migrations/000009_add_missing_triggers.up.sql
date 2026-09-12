-- ============================================================================
-- Traceability Service: Add missing updated_at trigger on supply_chain_events
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_supply_chain_events_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_supply_chain_events_set_updated_at
    BEFORE UPDATE ON supply_chain_events
    FOR EACH ROW
    EXECUTE FUNCTION trg_supply_chain_events_updated_at();
