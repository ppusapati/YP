-- ============================================================================
-- Plant Diagnosis Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TABLE IF EXISTS diagnosis_results;

DROP TRIGGER IF EXISTS trg_diagnosis_requests_set_updated_at ON diagnosis_requests;
DROP FUNCTION IF EXISTS trg_diagnosis_requests_updated_at();
DROP TABLE IF EXISTS diagnosis_requests;
