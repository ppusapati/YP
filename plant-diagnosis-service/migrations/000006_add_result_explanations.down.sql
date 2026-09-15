DROP INDEX IF EXISTS uq_diagnosis_results_request;
ALTER TABLE diagnosis_results DROP COLUMN IF EXISTS explanations;
