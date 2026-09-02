-- ============================================================================
-- Crop Service: Growth Stages, Requirements, Recommendations Migration (UP)
-- ============================================================================

-- ============================================================================
-- Alter: crops
-- ============================================================================
ALTER TABLE crops ADD COLUMN IF NOT EXISTS status     TEXT    NOT NULL DEFAULT 'active';
ALTER TABLE crops ADD COLUMN IF NOT EXISTS is_active  BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE crops ADD COLUMN IF NOT EXISTS created_by CHAR(26);
ALTER TABLE crops ADD COLUMN IF NOT EXISTS updated_by CHAR(26);
ALTER TABLE crops ADD COLUMN IF NOT EXISTS deleted_by CHAR(26);

CREATE INDEX IF NOT EXISTS idx_crops_status ON crops (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_crops_is_active ON crops (tenant_id, is_active) WHERE deleted_at IS NULL;

-- ============================================================================
-- Alter: crop_varieties
-- ============================================================================
ALTER TABLE crop_varieties ADD COLUMN IF NOT EXISTS is_active  BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE crop_varieties ADD COLUMN IF NOT EXISTS created_by CHAR(26);
ALTER TABLE crop_varieties ADD COLUMN IF NOT EXISTS updated_by CHAR(26);

CREATE INDEX IF NOT EXISTS idx_crop_varieties_is_active ON crop_varieties (tenant_id, crop_id) WHERE deleted_at IS NULL AND is_active = TRUE;

-- ============================================================================
-- Table: crop_growth_stages
-- ============================================================================
CREATE TABLE IF NOT EXISTS crop_growth_stages (
    id                      CHAR(26)            PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)            NOT NULL,

    -- relationships
    crop_id                 CHAR(26)            NOT NULL REFERENCES crops(id) ON DELETE CASCADE,

    -- stage details
    name                    TEXT                NOT NULL,
    stage_order             INTEGER             NOT NULL DEFAULT 0,
    duration_days           INTEGER             NOT NULL DEFAULT 0,
    water_requirement_mm    DOUBLE PRECISION    NOT NULL DEFAULT 0,
    nutrient_requirements   TEXT                NOT NULL DEFAULT '',
    description             TEXT                NOT NULL DEFAULT '',
    optimal_temp_min        DOUBLE PRECISION    NOT NULL DEFAULT 0,
    optimal_temp_max        DOUBLE PRECISION    NOT NULL DEFAULT 0,

    -- versioning
    version                 INTEGER             NOT NULL DEFAULT 1,
    is_active               BOOLEAN             NOT NULL DEFAULT TRUE,

    -- audit
    created_by              CHAR(26)            NOT NULL DEFAULT '',
    created_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_by              CHAR(26),
    updated_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE crop_growth_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_growth_stages FORCE ROW LEVEL SECURITY;

CREATE POLICY crop_growth_stages_select_policy ON crop_growth_stages
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY crop_growth_stages_insert_policy ON crop_growth_stages
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_growth_stages_update_policy ON crop_growth_stages
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_growth_stages_delete_policy ON crop_growth_stages
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_crop_growth_stages_tenant_id ON crop_growth_stages (tenant_id);
CREATE INDEX idx_crop_growth_stages_crop_id ON crop_growth_stages (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_growth_stages_order ON crop_growth_stages (tenant_id, crop_id, stage_order) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_crop_growth_stages_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crop_growth_stages_set_updated_at
    BEFORE UPDATE ON crop_growth_stages
    FOR EACH ROW
    EXECUTE FUNCTION trg_crop_growth_stages_updated_at();

-- ============================================================================
-- Table: crop_requirements
-- ============================================================================
CREATE TABLE IF NOT EXISTS crop_requirements (
    id                              CHAR(26)            PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                       CHAR(26)            NOT NULL,

    -- relationships
    crop_id                         CHAR(26)            NOT NULL UNIQUE REFERENCES crops(id) ON DELETE CASCADE,

    -- requirement details
    optimal_temp_min                DOUBLE PRECISION    NOT NULL DEFAULT 0,
    optimal_temp_max                DOUBLE PRECISION    NOT NULL DEFAULT 0,
    optimal_humidity_min            DOUBLE PRECISION    NOT NULL DEFAULT 0,
    optimal_humidity_max            DOUBLE PRECISION    NOT NULL DEFAULT 0,
    optimal_soil_ph_min             DOUBLE PRECISION    NOT NULL DEFAULT 0,
    optimal_soil_ph_max             DOUBLE PRECISION    NOT NULL DEFAULT 0,
    water_requirement_mm_per_day    DOUBLE PRECISION    NOT NULL DEFAULT 0,
    sunlight_hours                  DOUBLE PRECISION    NOT NULL DEFAULT 0,
    frost_tolerant                  BOOLEAN             NOT NULL DEFAULT FALSE,
    drought_tolerant                BOOLEAN             NOT NULL DEFAULT FALSE,
    soil_type_preference            TEXT                NOT NULL DEFAULT '',
    nutrient_requirements           TEXT                NOT NULL DEFAULT '',

    -- versioning
    version                         INTEGER             NOT NULL DEFAULT 1,
    is_active                       BOOLEAN             NOT NULL DEFAULT TRUE,

    -- audit
    created_by                      CHAR(26)            NOT NULL DEFAULT '',
    created_at                      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_by                      CHAR(26),
    updated_at                      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_by                      CHAR(26),
    deleted_at                      TIMESTAMPTZ
);

-- RLS
ALTER TABLE crop_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_requirements FORCE ROW LEVEL SECURITY;

CREATE POLICY crop_requirements_select_policy ON crop_requirements
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY crop_requirements_insert_policy ON crop_requirements
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_requirements_update_policy ON crop_requirements
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_requirements_delete_policy ON crop_requirements
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_crop_requirements_tenant_id ON crop_requirements (tenant_id);
CREATE INDEX idx_crop_requirements_crop_id ON crop_requirements (tenant_id, crop_id) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_crop_requirements_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crop_requirements_set_updated_at
    BEFORE UPDATE ON crop_requirements
    FOR EACH ROW
    EXECUTE FUNCTION trg_crop_requirements_updated_at();

-- ============================================================================
-- Table: crop_recommendations
-- ============================================================================
CREATE TABLE IF NOT EXISTS crop_recommendations (
    id                          CHAR(26)            PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                   CHAR(26)            NOT NULL,

    -- relationships
    crop_id                     CHAR(26)            NOT NULL REFERENCES crops(id) ON DELETE CASCADE,

    -- recommendation details
    recommendation_type         TEXT                NOT NULL DEFAULT '',
    title                       TEXT                NOT NULL DEFAULT '',
    description                 TEXT                NOT NULL DEFAULT '',
    severity                    TEXT                NOT NULL DEFAULT '',
    confidence_score            DOUBLE PRECISION    NOT NULL DEFAULT 0,
    parameters                  TEXT                NOT NULL DEFAULT '',
    applicable_growth_stage     TEXT                NOT NULL DEFAULT '',
    valid_from                  TIMESTAMPTZ,
    valid_until                 TIMESTAMPTZ,

    -- versioning
    version                     INTEGER             NOT NULL DEFAULT 1,
    is_active                   BOOLEAN             NOT NULL DEFAULT TRUE,

    -- audit
    created_by                  CHAR(26)            NOT NULL DEFAULT '',
    created_at                  TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_by                  CHAR(26),
    updated_at                  TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_by                  CHAR(26),
    deleted_at                  TIMESTAMPTZ
);

-- RLS
ALTER TABLE crop_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_recommendations FORCE ROW LEVEL SECURITY;

CREATE POLICY crop_recommendations_select_policy ON crop_recommendations
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY crop_recommendations_insert_policy ON crop_recommendations
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_recommendations_update_policy ON crop_recommendations
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_recommendations_delete_policy ON crop_recommendations
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_crop_recommendations_tenant_id ON crop_recommendations (tenant_id);
CREATE INDEX idx_crop_recommendations_crop_id ON crop_recommendations (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_recommendations_type ON crop_recommendations (tenant_id, recommendation_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_recommendations_validity ON crop_recommendations (valid_from, valid_until) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_crop_recommendations_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crop_recommendations_set_updated_at
    BEFORE UPDATE ON crop_recommendations
    FOR EACH ROW
    EXECUTE FUNCTION trg_crop_recommendations_updated_at();
