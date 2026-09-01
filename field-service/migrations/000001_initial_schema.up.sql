-- ============================================================================
-- Field Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: fields
-- ============================================================================
CREATE TABLE IF NOT EXISTS fields (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    farm_id             CHAR(26)        NOT NULL,

    -- core fields
    name                TEXT            NOT NULL,
    area_hectares       DOUBLE PRECISION,
    boundary            JSONB,

    -- crop tracking
    current_crop_id     CHAR(26),
    planting_date       TIMESTAMPTZ,
    expected_harvest_date TIMESTAMPTZ,
    growth_stage        TEXT            NOT NULL DEFAULT 'GROWTH_STAGE_UNSPECIFIED',

    -- classification
    soil_type           TEXT            NOT NULL DEFAULT 'SOIL_TYPE_UNSPECIFIED',
    irrigation_type     TEXT            NOT NULL DEFAULT 'IRRIGATION_TYPE_UNSPECIFIED',
    field_type          TEXT            NOT NULL DEFAULT 'FIELD_TYPE_UNSPECIFIED',
    status              TEXT            NOT NULL DEFAULT 'FIELD_STATUS_ACTIVE',

    -- terrain
    elevation_meters    DOUBLE PRECISION,
    slope_degrees       DOUBLE PRECISION,
    aspect_direction    TEXT            NOT NULL DEFAULT 'ASPECT_DIRECTION_UNSPECIFIED',

    -- versioning
    version             BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by          CHAR(26)        NOT NULL,
    updated_by          CHAR(26),
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE fields FORCE ROW LEVEL SECURITY;

CREATE POLICY fields_select_policy ON fields
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY fields_insert_policy ON fields
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY fields_update_policy ON fields
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY fields_delete_policy ON fields
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_fields_tenant_id ON fields (tenant_id);
CREATE INDEX idx_fields_farm_id ON fields (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_fields_status ON fields (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_fields_field_type ON fields (tenant_id, field_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_fields_current_crop_id ON fields (tenant_id, current_crop_id) WHERE deleted_at IS NULL AND current_crop_id IS NOT NULL;
CREATE INDEX idx_fields_name ON fields (tenant_id, name) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_fields_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fields_set_updated_at
    BEFORE UPDATE ON fields
    FOR EACH ROW
    EXECUTE FUNCTION trg_fields_updated_at();

-- ============================================================================
-- Table: field_boundaries
-- ============================================================================
CREATE TABLE IF NOT EXISTS field_boundaries (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    field_id            CHAR(26)        NOT NULL REFERENCES fields(id) ON DELETE CASCADE,

    -- boundary data
    polygon             JSONB           NOT NULL,
    area_hectares       DOUBLE PRECISION,
    perimeter_meters    DOUBLE PRECISION,
    source              TEXT,
    recorded_at         TIMESTAMPTZ,

    -- audit
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE field_boundaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_boundaries FORCE ROW LEVEL SECURITY;

CREATE POLICY field_boundaries_select_policy ON field_boundaries
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY field_boundaries_insert_policy ON field_boundaries
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY field_boundaries_update_policy ON field_boundaries
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY field_boundaries_delete_policy ON field_boundaries
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_field_boundaries_tenant_id ON field_boundaries (tenant_id);
CREATE INDEX idx_field_boundaries_field_id ON field_boundaries (tenant_id, field_id) WHERE deleted_at IS NULL;

-- ============================================================================
-- Table: crop_assignments
-- ============================================================================
CREATE TABLE IF NOT EXISTS crop_assignments (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    field_id                CHAR(26)        NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
    crop_id                 CHAR(26)        NOT NULL,

    -- assignment details
    crop_variety            TEXT,
    planting_date           TIMESTAMPTZ,
    expected_harvest_date   TIMESTAMPTZ,
    actual_harvest_date     TIMESTAMPTZ,
    growth_stage            TEXT            NOT NULL DEFAULT 'GROWTH_STAGE_UNSPECIFIED',
    yield_per_hectare       DOUBLE PRECISION,
    season                  TEXT,
    notes                   TEXT,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE crop_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_assignments FORCE ROW LEVEL SECURITY;

CREATE POLICY crop_assignments_select_policy ON crop_assignments
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY crop_assignments_insert_policy ON crop_assignments
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_assignments_update_policy ON crop_assignments
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_assignments_delete_policy ON crop_assignments
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_crop_assignments_tenant_id ON crop_assignments (tenant_id);
CREATE INDEX idx_crop_assignments_field_id ON crop_assignments (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_assignments_crop_id ON crop_assignments (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_assignments_season ON crop_assignments (tenant_id, season) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_assignments_planting_date ON crop_assignments (tenant_id, planting_date DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_crop_assignments_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crop_assignments_set_updated_at
    BEFORE UPDATE ON crop_assignments
    FOR EACH ROW
    EXECUTE FUNCTION trg_crop_assignments_updated_at();
