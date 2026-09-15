-- ============================================================================
-- Satellite Ingestion Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_ingestion_tasks_set_updated_at ON ingestion_tasks;
DROP FUNCTION IF EXISTS trg_ingestion_tasks_updated_at();
DROP TABLE IF EXISTS ingestion_tasks;
DROP TYPE IF EXISTS ingestion_status;
DROP TYPE IF EXISTS satellite_provider;
