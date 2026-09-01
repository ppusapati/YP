-- ============================================================================
-- Soil Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: soil_samples
-- ============================================================================
CREATE TABLE IF NOT EXISTS soil_samples (
    id                          CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                   CHAR(26)        NOT NULL,

    -- relationships
    field_id                    CHAR(26),
    farm_id                     CHAR(26),

    -- sample location
    sample_latitude             DOUBLE PRECISION,
    sample_longitude            DOUBLE PRECISION,
    sample_depth_cm             DOUBLE PRECISION,
    collection_date             TIMESTAMPTZ,

    -- primary measurements
    ph                          DOUBLE PRECISION,
    organic_matter_pct          DOUBLE PRECISION,
    moisture_pct                DOUBLE PRECISION,
    texture                     TEXT            NOT NULL DEFAULT 'SOIL_TEXTURE_UNSPECIFIED',
    bulk_density                DOUBLE PRECISION,
    cation_exchange_capacity    DOUBLE PRECISION,
    electrical_conductivity     DOUBLE PRECISION,

    -- macronutrients (ppm)
    nitrogen_ppm                DOUBLE PRECISION,
    phosphorus_ppm              DOUBLE PRECISION,
    potassium_ppm               DOUBLE PRECISION,
    calcium_ppm                 DOUBLE PRECISION,
    magnesium_ppm               DOUBLE PRECISION,
    sulfur_ppm                  DOUBLE PRECISION,

    -- micronutrients (ppm)
    iron_ppm                    DOUBLE PRECISION,
    manganese_ppm               DOUBLE PRECISION,
    zinc_ppm                    DOUBLE PRECISION,
    copper_ppm                  DOUBLE PRECISION,
    boron_ppm                   DOUBLE PRECISION,

    -- collection info
    collected_by                TEXT,
    notes                       TEXT,

    -- versioning
    version                     BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ
);

-- RLS
ALTER TABLE soil_samples ENABLE ROW LEVEL SECURITY;
ALTER TABLE soil_samples FORCE ROW LEVEL SECURITY;

CREATE POLICY soil_samples_select_policy ON soil_samples
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY soil_samples_insert_policy ON soil_samples
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_samples_update_policy ON soil_samples
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_samples_delete_policy ON soil_samples
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_soil_samples_tenant_id ON soil_samples (tenant_id);
CREATE INDEX idx_soil_samples_field_id ON soil_samples (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_samples_farm_id ON soil_samples (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_samples_collection_date ON soil_samples (tenant_id, collection_date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_samples_texture ON soil_samples (tenant_id, texture) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_soil_samples_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soil_samples_set_updated_at
    BEFORE UPDATE ON soil_samples
    FOR EACH ROW
    EXECUTE FUNCTION trg_soil_samples_updated_at();

-- ============================================================================
-- Table: soil_analyses
-- ============================================================================
CREATE TABLE IF NOT EXISTS soil_analyses (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    sample_id               CHAR(26)        NOT NULL REFERENCES soil_samples(id) ON DELETE CASCADE,
    field_id                CHAR(26),
    farm_id                 CHAR(26),

    -- analysis details
    status                  TEXT            NOT NULL DEFAULT 'ANALYSIS_STATUS_PENDING',
    analysis_type           TEXT,
    soil_health_score       DOUBLE PRECISION,
    health_category         TEXT            NOT NULL DEFAULT 'HEALTH_CATEGORY_UNSPECIFIED',
    recommendations         TEXT[],
    analyzed_by             TEXT,
    analyzed_at             TIMESTAMPTZ,
    summary                 TEXT,

    -- versioning
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE soil_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE soil_analyses FORCE ROW LEVEL SECURITY;

CREATE POLICY soil_analyses_select_policy ON soil_analyses
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY soil_analyses_insert_policy ON soil_analyses
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_analyses_update_policy ON soil_analyses
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY soil_analyses_delete_policy ON soil_analyses
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_soil_analyses_tenant_id ON soil_analyses (tenant_id);
CREATE INDEX idx_soil_analyses_sample_id ON soil_analyses (tenant_id, sample_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_analyses_field_id ON soil_analyses (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_analyses_farm_id ON soil_analyses (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_analyses_status ON soil_analyses (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_soil_analyses_health_category ON soil_analyses (tenant_id, health_category) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_soil_analyses_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soil_analyses_set_updated_at
    BEFORE UPDATE ON soil_analyses
    FOR EACH ROW
    EXECUTE FUNCTION trg_soil_analyses_updated_at();
