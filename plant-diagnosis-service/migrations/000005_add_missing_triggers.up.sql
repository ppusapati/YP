-- ============================================================================
-- Plant Diagnosis Service: Add missing updated_at trigger on diagnosis_results
-- ============================================================================

CREATE OR REPLACE FUNCTION trg_diagnosis_results_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_diagnosis_results_set_updated_at
    BEFORE UPDATE ON diagnosis_results
    FOR EACH ROW
    EXECUTE FUNCTION trg_diagnosis_results_updated_at();
