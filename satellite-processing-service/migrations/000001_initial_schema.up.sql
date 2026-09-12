-- ============================================================================
-- Satellite Processing Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Custom Enum Types
-- ============================================================================
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

-- ============================================================================
-- Table: processing_jobs
-- ============================================================================
CREATE TABLE IF NOT EXISTS processing_jobs (
    id                              BIGSERIAL       PRIMARY KEY,
    uuid                            CHAR(26)        NOT NULL UNIQUE,
    tenant_id                       CHAR(26)        NOT NULL,
    ingestion_task_uuid             CHAR(26)        NOT NULL,
    farm_uuid                       CHAR(26)        NOT NULL,
    status                          processing_status NOT NULL DEFAULT 'QUEUED',
    input_level                     processing_level NOT NULL,
    output_level                    processing_level NOT NULL,
    algorithm                       correction_algorithm NOT NULL,
    input_s3_key                    TEXT            NOT NULL,
    output_s3_key                   TEXT,
    cloud_mask_threshold            DOUBLE PRECISION NOT NULL DEFAULT 0,
    apply_atmospheric_correction    BOOLEAN         NOT NULL DEFAULT FALSE,
    apply_cloud_masking             BOOLEAN         NOT NULL DEFAULT FALSE,
    apply_orthorectification        BOOLEAN         NOT NULL DEFAULT FALSE,
    output_resolution_meters        INTEGER         NOT NULL DEFAULT 10,
    output_crs                      TEXT            NOT NULL DEFAULT 'EPSG:4326',
    error_message                   TEXT,
    processing_time_seconds         DOUBLE PRECISION,
    is_active                       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by                      CHAR(26)        NOT NULL,
    created_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by                      CHAR(26),
    updated_at                      TIMESTAMPTZ,
    completed_at                    TIMESTAMPTZ,
    deleted_by                      CHAR(26),
    deleted_at                      TIMESTAMPTZ
);

-- RLS
ALTER TABLE processing_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE processing_jobs FORCE ROW LEVEL SECURITY;

CREATE POLICY processing_jobs_select_policy ON processing_jobs
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY processing_jobs_insert_policy ON processing_jobs
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY processing_jobs_update_policy ON processing_jobs
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY processing_jobs_delete_policy ON processing_jobs
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_processing_jobs_tenant_id ON processing_jobs (tenant_id);
CREATE INDEX idx_processing_jobs_uuid ON processing_jobs (uuid);
CREATE INDEX idx_processing_jobs_farm_uuid ON processing_jobs (tenant_id, farm_uuid) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_processing_jobs_status ON processing_jobs (tenant_id, status) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_processing_jobs_created_at ON processing_jobs (tenant_id, created_at DESC) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_processing_jobs_ingestion_task ON processing_jobs (tenant_id, ingestion_task_uuid) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_processing_jobs_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_processing_jobs_set_updated_at
    BEFORE UPDATE ON processing_jobs
    FOR EACH ROW
    EXECUTE FUNCTION trg_processing_jobs_updated_at();
