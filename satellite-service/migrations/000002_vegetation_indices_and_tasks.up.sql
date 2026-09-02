-- ============================================================================
-- Satellite Service: Vegetation Indices & Tasks Migration (UP)
-- ============================================================================

-- ============================================================================
-- Table: vegetation_indices
-- ============================================================================
CREATE TABLE IF NOT EXISTS vegetation_indices (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    image_id                CHAR(26)        REFERENCES satellite_images(id),
    field_id                CHAR(26),

    -- index data
    index_type              TEXT            NOT NULL,
    min_value               DOUBLE PRECISION,
    max_value               DOUBLE PRECISION,
    mean_value              DOUBLE PRECISION,
    std_dev                 DOUBLE PRECISION,
    raster_url              TEXT,
    computed_at             TIMESTAMPTZ,

    -- versioning
    version                 INTEGER         NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
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
CREATE INDEX idx_vegetation_indices_image_id ON vegetation_indices (tenant_id, image_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_vegetation_indices_field_index_type ON vegetation_indices (tenant_id, field_id, index_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_vegetation_indices_computed_at ON vegetation_indices (tenant_id, field_id, computed_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_vegetation_indices_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_vegetation_indices_set_updated_at
    BEFORE UPDATE ON vegetation_indices
    FOR EACH ROW
    EXECUTE FUNCTION trg_vegetation_indices_updated_at();

-- ============================================================================
-- Table: satellite_tasks
-- ============================================================================
CREATE TABLE IF NOT EXISTS satellite_tasks (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    field_id                CHAR(26),

    -- task info
    task_type               TEXT            NOT NULL,
    status                  TEXT            NOT NULL DEFAULT 'PROCESSING_STATUS_PENDING',
    input_image_id          CHAR(26),
    result_id               CHAR(26),
    error_message           TEXT,
    retry_count             INTEGER         DEFAULT 0,

    -- versioning
    version                 INTEGER         NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE satellite_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE satellite_tasks FORCE ROW LEVEL SECURITY;

CREATE POLICY satellite_tasks_select_policy ON satellite_tasks
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY satellite_tasks_insert_policy ON satellite_tasks
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY satellite_tasks_update_policy ON satellite_tasks
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY satellite_tasks_delete_policy ON satellite_tasks
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_satellite_tasks_tenant_id ON satellite_tasks (tenant_id);
CREATE INDEX idx_satellite_tasks_field_id ON satellite_tasks (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_tasks_status ON satellite_tasks (tenant_id, status) WHERE deleted_at IS NULL;
