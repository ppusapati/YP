-- 001_processing.sql
-- Schema for the satellite-processing-service: processing_jobs

-- Enum types
CREATE TYPE processing_status AS ENUM (
    'QUEUED',
    'PREPROCESSING',
    'ATMOSPHERIC_CORRECTION',
    'CLOUD_MASKING',
    'ORTHORECTIFICATION',
    'BAND_MATH',
    'COMPLETED',
    'FAILED'
);

CREATE TYPE processing_level AS ENUM (
    'L1C',
    'L2A',
    'L3'
);

CREATE TYPE correction_algorithm AS ENUM (
    'SEN2COR',
    'LASRC',
    'FLAASH',
    'DOS'
);

-- Processing jobs table
CREATE TABLE processing_jobs (
    id                          BIGSERIAL PRIMARY KEY,
    uuid                        VARCHAR(26) NOT NULL UNIQUE,
    tenant_id                   VARCHAR(26) NOT NULL,
    ingestion_task_uuid         VARCHAR(26) NOT NULL,
    farm_uuid                   VARCHAR(26) NOT NULL,
    status                      processing_status NOT NULL DEFAULT 'QUEUED',
    input_level                 processing_level NOT NULL DEFAULT 'L1C',
    output_level                processing_level NOT NULL DEFAULT 'L2A',
    algorithm                   correction_algorithm NOT NULL DEFAULT 'SEN2COR',
    input_s3_key                TEXT NOT NULL,
    output_s3_key               TEXT,
    cloud_mask_threshold        DOUBLE PRECISION NOT NULL DEFAULT 0.3,
    apply_atmospheric_correction BOOLEAN NOT NULL DEFAULT TRUE,
    apply_cloud_masking         BOOLEAN NOT NULL DEFAULT TRUE,
    apply_orthorectification    BOOLEAN NOT NULL DEFAULT FALSE,
    output_resolution_meters    INTEGER NOT NULL DEFAULT 10,
    output_crs                  VARCHAR(50) NOT NULL DEFAULT 'EPSG:4326',
    error_message               TEXT,
    processing_time_seconds     DOUBLE PRECISION,
    is_active                   BOOLEAN NOT NULL DEFAULT TRUE,
    created_by                  VARCHAR(26) NOT NULL,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by                  VARCHAR(26),
    updated_at                  TIMESTAMPTZ,
    completed_at                TIMESTAMPTZ,
    deleted_by                  VARCHAR(26),
    deleted_at                  TIMESTAMPTZ
);

-- Indexes for processing_jobs
CREATE INDEX idx_processing_jobs_tenant_id ON processing_jobs(tenant_id);
CREATE INDEX idx_processing_jobs_farm_uuid ON processing_jobs(farm_uuid);
CREATE INDEX idx_processing_jobs_ingestion_task_uuid ON processing_jobs(ingestion_task_uuid);
CREATE INDEX idx_processing_jobs_status ON processing_jobs(tenant_id, status);
CREATE INDEX idx_processing_jobs_created_at ON processing_jobs(tenant_id, created_at DESC);
CREATE INDEX idx_processing_jobs_active ON processing_jobs(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;
