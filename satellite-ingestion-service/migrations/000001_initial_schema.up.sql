-- ============================================================================
-- Satellite Ingestion Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================================
-- Custom Enum Types
-- ============================================================================
CREATE TYPE satellite_provider AS ENUM (
    'SENTINEL2',
    'LANDSAT',
    'PLANETSCOPE'
);

CREATE TYPE ingestion_status AS ENUM (
    'QUEUED',
    'DOWNLOADING',
    'VALIDATING',
    'STORED',
    'FAILED'
);

-- ============================================================================
-- Table: ingestion_tasks
-- ============================================================================
CREATE TABLE IF NOT EXISTS ingestion_tasks (
    id                      BIGSERIAL       PRIMARY KEY,
    uuid                    CHAR(26)        NOT NULL UNIQUE,
    tenant_id               CHAR(26)        NOT NULL,
    farm_id                 BIGINT          NOT NULL,
    farm_uuid               CHAR(26)        NOT NULL,
    provider                satellite_provider NOT NULL,
    scene_id                TEXT            NOT NULL,
    status                  ingestion_status NOT NULL DEFAULT 'QUEUED',
    s3_bucket               TEXT,
    s3_key                  TEXT,
    cloud_cover_percent     DOUBLE PRECISION NOT NULL DEFAULT 0,
    resolution_meters       DOUBLE PRECISION NOT NULL DEFAULT 0,
    bands                   TEXT[]          NOT NULL DEFAULT '{}',
    bbox                    GEOMETRY,
    file_size_bytes         BIGINT          NOT NULL DEFAULT 0,
    checksum_sha256         TEXT,
    error_message           TEXT,
    retry_count             INTEGER         NOT NULL DEFAULT 0,
    acquisition_date        TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    version                 BIGINT          NOT NULL DEFAULT 1,
    created_by              CHAR(26)        NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by              CHAR(26),
    updated_at              TIMESTAMPTZ,
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE ingestion_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingestion_tasks FORCE ROW LEVEL SECURITY;

CREATE POLICY ingestion_tasks_select_policy ON ingestion_tasks
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY ingestion_tasks_insert_policy ON ingestion_tasks
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY ingestion_tasks_update_policy ON ingestion_tasks
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY ingestion_tasks_delete_policy ON ingestion_tasks
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_ingestion_tasks_tenant_id ON ingestion_tasks (tenant_id);
CREATE INDEX idx_ingestion_tasks_uuid ON ingestion_tasks (uuid);
CREATE INDEX idx_ingestion_tasks_farm_uuid ON ingestion_tasks (tenant_id, farm_uuid) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_ingestion_tasks_provider ON ingestion_tasks (tenant_id, provider) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_ingestion_tasks_status ON ingestion_tasks (tenant_id, status) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_ingestion_tasks_created_at ON ingestion_tasks (tenant_id, created_at DESC) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_ingestion_tasks_scene_id ON ingestion_tasks (tenant_id, scene_id) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_ingestion_tasks_bbox ON ingestion_tasks USING GIST (bbox) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_ingestion_tasks_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ingestion_tasks_set_updated_at
    BEFORE UPDATE ON ingestion_tasks
    FOR EACH ROW
    EXECUTE FUNCTION trg_ingestion_tasks_updated_at();
