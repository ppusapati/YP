-- ============================================================================
-- Satellite Analytics Service: Add missing updated_at trigger on temporal_analyses
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_temporal_analyses_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_temporal_analyses_set_updated_at
    BEFORE UPDATE ON temporal_analyses
    FOR EACH ROW
    EXECUTE FUNCTION trg_temporal_analyses_updated_at();
