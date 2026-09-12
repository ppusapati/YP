-- ============================================================================
-- Vegetation Index Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Custom Enum Types
-- ============================================================================
CREATE TYPE vegetation_index_type AS ENUM (
    'NDVI',
    'NDWI',
    'EVI',
    'SAVI',
    'MSAVI',
    'NDRE',
    'GNDVI',
    'LAI'
);

CREATE TYPE compute_status AS ENUM (
    'QUEUED',
    'COMPUTING',
    'INTERSECTING',
    'COMPLETED',
    'FAILED'
);

-- ============================================================================
-- Table: compute_tasks
-- ============================================================================
CREATE TABLE IF NOT EXISTS compute_tasks (
    id                      BIGSERIAL       PRIMARY KEY,
    uuid                    CHAR(26)        NOT NULL UNIQUE,
    tenant_id               CHAR(26)        NOT NULL,
    processing_job_uuid     CHAR(26)        NOT NULL,
    farm_uuid               CHAR(26)        NOT NULL,
    index_types             vegetation_index_type[] NOT NULL,
    status                  compute_status  NOT NULL DEFAULT 'QUEUED',
    error_message           TEXT,
    compute_time_seconds    DOUBLE PRECISION,
    version                 BIGINT          NOT NULL DEFAULT 1,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by              CHAR(26)        NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by              CHAR(26),
    updated_at              TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    deleted_at              TIMESTAMPTZ,
    deleted_by              CHAR(26)
);

-- RLS
ALTER TABLE compute_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE compute_tasks FORCE ROW LEVEL SECURITY;

CREATE POLICY compute_tasks_select_policy ON compute_tasks
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY compute_tasks_insert_policy ON compute_tasks
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY compute_tasks_update_policy ON compute_tasks
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY compute_tasks_delete_policy ON compute_tasks
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_compute_tasks_tenant_id ON compute_tasks (tenant_id);
CREATE INDEX idx_compute_tasks_uuid ON compute_tasks (uuid);
CREATE INDEX idx_compute_tasks_farm_uuid ON compute_tasks (tenant_id, farm_uuid) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_compute_tasks_status ON compute_tasks (tenant_id, status) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_compute_tasks_created_at ON compute_tasks (tenant_id, created_at DESC) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_compute_tasks_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compute_tasks_set_updated_at
    BEFORE UPDATE ON compute_tasks
    FOR EACH ROW
    EXECUTE FUNCTION trg_compute_tasks_updated_at();

-- ============================================================================
-- Table: vegetation_indices
-- ============================================================================
CREATE TABLE IF NOT EXISTS vegetation_indices (
    id                      BIGSERIAL       PRIMARY KEY,
    uuid                    CHAR(26)        NOT NULL UNIQUE,
    tenant_id               CHAR(26)        NOT NULL,
    farm_uuid               CHAR(26)        NOT NULL,
    field_uuid              CHAR(26),
    processing_job_uuid     CHAR(26)        NOT NULL,
    compute_task_uuid       CHAR(26)        NOT NULL,
    index_type              vegetation_index_type NOT NULL,
    mean_value              DOUBLE PRECISION NOT NULL,
    min_value               DOUBLE PRECISION NOT NULL,
    max_value               DOUBLE PRECISION NOT NULL,
    std_deviation           DOUBLE PRECISION NOT NULL,
    median_value            DOUBLE PRECISION NOT NULL,
    pixel_count             BIGINT          NOT NULL,
    coverage_percent        DOUBLE PRECISION NOT NULL,
    raster_s3_key           TEXT,
    acquisition_date        TIMESTAMPTZ     NOT NULL,
    computed_at             TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by              CHAR(26)        NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    deleted_by              CHAR(26)
);

-- RLS
ALTER TABLE vegetation_indices ENABLE ROW LEVEL SECURITY;
ALTER TABLE vegetation_indices FORCE ROW LEVEL SECURITY;

CREATE POLICY vegetation_indices_select_policy ON vegetation_indices
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY vegetation_indices_insert_policy ON vegetation_indices
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY vegetation_indices_update_policy ON vegetation_indices
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY vegetation_indices_delete_policy ON vegetation_indices
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_vegetation_indices_tenant_id ON vegetation_indices (tenant_id);
CREATE INDEX idx_vegetation_indices_uuid ON vegetation_indices (uuid);
CREATE INDEX idx_vegetation_indices_farm_uuid ON vegetation_indices (tenant_id, farm_uuid) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_vegetation_indices_field_uuid ON vegetation_indices (tenant_id, field_uuid) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_vegetation_indices_index_type ON vegetation_indices (tenant_id, index_type) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_vegetation_indices_acquisition_date ON vegetation_indices (tenant_id, acquisition_date DESC) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_vegetation_indices_ndvi_timeseries ON vegetation_indices (tenant_id, farm_uuid, index_type, acquisition_date ASC) WHERE is_active = TRUE AND deleted_at IS NULL;
