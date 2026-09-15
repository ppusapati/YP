-- ============================================================================
-- Field Service: Add missing updated_at trigger on field_boundaries
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_field_boundaries_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_field_boundaries_set_updated_at
    BEFORE UPDATE ON field_boundaries
    FOR EACH ROW
    EXECUTE FUNCTION trg_field_boundaries_updated_at();
