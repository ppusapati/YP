DROP INDEX IF EXISTS idx_ingestion_tasks_processing_level;
ALTER TABLE ingestion_tasks DROP COLUMN IF EXISTS processing_level;
-- Enum values cannot be dropped in PostgreSQL; 'UAV' is left in place.
