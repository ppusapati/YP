-- ============================================================================
-- Soil Service: Maps, Nutrients, Health Scores + Audit Columns (UP)
-- ============================================================================

-- ============================================================================
-- Alter: soil_samples — add audit/soft-delete columns used by the adapter
-- ============================================================================
ALTER TABLE soil_samples
    ADD COLUMN IF NOT EXISTS is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_by  TEXT,
    ADD COLUMN IF NOT EXISTS updated_by  TEXT,
    ADD COLUMN IF NOT EXISTS deleted_by  TEXT;

-- deleted_at already exists on soil_samples (000001); nothing to do there.

CREATE INDEX IF NOT EXISTS idx_soil_samples_is_active
    ON soil_samples (tenant_id, is_active) WHERE deleted_at IS NULL;

-- ============================================================================
-- Alter: soil_analyses — add audit/soft-delete columns used by the adapter
-- ============================================================================
ALTER TABLE soil_analyses
    ADD COLUMN IF NOT EXISTS is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_by  TEXT,
    ADD COLUMN IF NOT EXISTS updated_by  TEXT,
    ADD COLUMN IF NOT EXISTS deleted_by  TEXT;

CREATE INDEX IF NOT EXISTS idx_soil_analyses_is_active
    ON soil_analyses (tenant_id, is_active) WHERE deleted_at IS NULL;

-- ============================================================================
-- Table: soil_maps
-- ============================================================================
CREATE TABLE IF NOT EXISTS soil_maps (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    field_id            CHAR(26),
    farm_id             CHAR(26),

    -- map data
    map_type            TEXT            NOT NULL DEFAULT 'SOIL_MAP_TYPE_UNSPECIFIED',
    raster_data         BYTEA,
    crs                 TEXT,
    resolution          DOUBLE PRECISION,
    bbox_min_lat        DOUBLE PRECISION,
    bbox_min_lng        DOUBLE PRECISION,
    bbox_max_lat        DOUBLE PRECISION,
    bbox_max_lng        DOUBLE PRECISION,
    generated_by        TEXT,
    generated_at        TIMESTAMPTZ,

    -- versioning
    version             BIGINT          NOT NULL DEFAULT 1,

    -- audit
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by          TEXT,
    updated_by          TEXT,
    deleted_by          TEXT,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE soil_maps ENABLE ROW LEVEL SECURITY;
ALTER TABLE soil_maps FORCE ROW LEVEL SECURITY;

CREATE POLICY soil_maps_select_policy ON soil_maps
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY soil_maps_insert_policy ON soil_maps
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_maps_update_policy ON soil_maps
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_maps_delete_policy ON soil_maps
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_soil_maps_tenant_id ON soil_maps (tenant_id);
CREATE INDEX idx_soil_maps_field_id ON soil_maps (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_maps_farm_id ON soil_maps (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_maps_field_type ON soil_maps (tenant_id, field_id, map_type, generated_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_soil_maps_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soil_maps_set_updated_at
    BEFORE UPDATE ON soil_maps
    FOR EACH ROW
    EXECUTE FUNCTION trg_soil_maps_updated_at();

-- ============================================================================
-- Table: soil_nutrients
-- ============================================================================
CREATE TABLE IF NOT EXISTS soil_nutrients (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    sample_id           CHAR(26)        NOT NULL REFERENCES soil_samples(id) ON DELETE CASCADE,

    -- nutrient data
    nutrient_name       TEXT            NOT NULL,
    value_ppm           DOUBLE PRECISION,
    level               TEXT            NOT NULL DEFAULT 'NUTRIENT_LEVEL_UNSPECIFIED',
    optimal_min         DOUBLE PRECISION,
    optimal_max         DOUBLE PRECISION,
    unit                TEXT,

    -- versioning
    version             BIGINT          NOT NULL DEFAULT 1,

    -- audit
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by          TEXT,
    updated_by          TEXT,
    deleted_by          TEXT,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE soil_nutrients ENABLE ROW LEVEL SECURITY;
ALTER TABLE soil_nutrients FORCE ROW LEVEL SECURITY;

CREATE POLICY soil_nutrients_select_policy ON soil_nutrients
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY soil_nutrients_insert_policy ON soil_nutrients
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_nutrients_update_policy ON soil_nutrients
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_nutrients_delete_policy ON soil_nutrients
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_soil_nutrients_tenant_id ON soil_nutrients (tenant_id);
CREATE INDEX idx_soil_nutrients_sample_id ON soil_nutrients (tenant_id, sample_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_nutrients_name ON soil_nutrients (tenant_id, sample_id, nutrient_name) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_soil_nutrients_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soil_nutrients_set_updated_at
    BEFORE UPDATE ON soil_nutrients
    FOR EACH ROW
    EXECUTE FUNCTION trg_soil_nutrients_updated_at();

-- ============================================================================
-- Table: soil_health_scores
-- ============================================================================
CREATE TABLE IF NOT EXISTS soil_health_scores (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    field_id            CHAR(26),
    farm_id             CHAR(26),

    -- score data
    overall_score        DOUBLE PRECISION,
    category             TEXT            NOT NULL DEFAULT 'HEALTH_CATEGORY_UNSPECIFIED',
    physical_score        DOUBLE PRECISION,
    chemical_score        DOUBLE PRECISION,
    biological_score      DOUBLE PRECISION,
    recommendations       TEXT[],
    assessed_at           TIMESTAMPTZ,

    -- versioning
    version             BIGINT          NOT NULL DEFAULT 1,

    -- audit
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by          TEXT,
    updated_by          TEXT,
    deleted_by          TEXT,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE soil_health_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE soil_health_scores FORCE ROW LEVEL SECURITY;

CREATE POLICY soil_health_scores_select_policy ON soil_health_scores
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY soil_health_scores_insert_policy ON soil_health_scores
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_health_scores_update_policy ON soil_health_scores
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_health_scores_delete_policy ON soil_health_scores
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_soil_health_scores_tenant_id ON soil_health_scores (tenant_id);
CREATE INDEX idx_soil_health_scores_field_id ON soil_health_scores (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_health_scores_farm_id ON soil_health_scores (tenant_id, farm_id, assessed_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_health_scores_category ON soil_health_scores (tenant_id, category) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_soil_health_scores_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soil_health_scores_set_updated_at
    BEFORE UPDATE ON soil_health_scores
    FOR EACH ROW
    EXECUTE FUNCTION trg_soil_health_scores_updated_at();
