-- ============================================================================
-- Satellite Processing Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_processing_jobs_set_updated_at ON processing_jobs;
DROP FUNCTION IF EXISTS trg_processing_jobs_updated_at();
DROP TABLE IF EXISTS processing_jobs;
DROP TYPE IF EXISTS correction_algorithm;
DROP TYPE IF EXISTS processing_level;
DROP TYPE IF EXISTS processing_status;
