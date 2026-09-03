-- ============================================================================
-- Plant Diagnosis Service: Migration 002 — diseases + treatment_plans (DOWN)
-- ============================================================================

DROP TRIGGER IF EXISTS trg_treatment_plans_set_updated_at ON treatment_plans;
DROP FUNCTION IF EXISTS trg_treatment_plans_updated_at();
DROP TABLE IF EXISTS treatment_plans;

DROP TRIGGER IF EXISTS trg_diseases_set_updated_at ON diseases;
DROP FUNCTION IF EXISTS trg_diseases_updated_at();
DROP TABLE IF EXISTS diseases;
