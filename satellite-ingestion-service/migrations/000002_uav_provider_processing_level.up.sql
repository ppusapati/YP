-- UAV/drone orthomosaics flow through the same ingestion pipeline as satellite scenes.
ALTER TYPE satellite_provider ADD VALUE IF NOT EXISTS 'UAV';

-- Radiometric processing level of the product (L1C, L2A, L1TP, L2SP, SR, TOA, UNKNOWN).
-- Downstream index computation flags anything that is not surface reflectance.
ALTER TABLE ingestion_tasks
    ADD COLUMN IF NOT EXISTS processing_level TEXT NOT NULL DEFAULT 'UNKNOWN';

CREATE INDEX IF NOT EXISTS idx_ingestion_tasks_processing_level
    ON ingestion_tasks (tenant_id, processing_level) WHERE is_active = TRUE AND deleted_at IS NULL;
