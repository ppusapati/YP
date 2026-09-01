-- ============================================================================
-- Yield Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: yield_predictions
-- ============================================================================
CREATE TABLE IF NOT EXISTS yield_predictions (
    id                              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                       CHAR(26)        NOT NULL,

    -- relationships
    farm_id                         CHAR(26)        NOT NULL,
    field_id                        CHAR(26)        NOT NULL,
    crop_id                         CHAR(26)        NOT NULL,

    -- prediction context
    season                          TEXT,
    year                            INTEGER,

    -- prediction output
    predicted_yield_kg_per_hectare  DOUBLE PRECISION,
    prediction_confidence_pct       DOUBLE PRECISION,
    prediction_model_version        TEXT,
    status                          TEXT            NOT NULL DEFAULT 'PREDICTION_STATUS_PENDING',

    -- yield factors (stored as individual columns for queryability)
    factor_soil_quality_score       DOUBLE PRECISION,
    factor_weather_score            DOUBLE PRECISION,
    factor_irrigation_score         DOUBLE PRECISION,
    factor_pest_pressure_score      DOUBLE PRECISION,
    factor_nutrient_score           DOUBLE PRECISION,
    factor_management_score         DOUBLE PRECISION,

    -- versioning
    version                         BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by                      CHAR(26),
    updated_by                      CHAR(26),
    created_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                      TIMESTAMPTZ
);

-- RLS
ALTER TABLE yield_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE yield_predictions FORCE ROW LEVEL SECURITY;

CREATE POLICY yield_predictions_select_policy ON yield_predictions
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY yield_predictions_insert_policy ON yield_predictions
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY yield_predictions_update_policy ON yield_predictions
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY yield_predictions_delete_policy ON yield_predictions
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_yield_predictions_tenant_id ON yield_predictions (tenant_id);
CREATE INDEX idx_yield_predictions_farm_id ON yield_predictions (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_predictions_field_id ON yield_predictions (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_predictions_crop_id ON yield_predictions (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_predictions_season_year ON yield_predictions (tenant_id, season, year) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_predictions_status ON yield_predictions (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_predictions_created_at ON yield_predictions (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_yield_predictions_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_yield_predictions_set_updated_at
    BEFORE UPDATE ON yield_predictions
    FOR EACH ROW
    EXECUTE FUNCTION trg_yield_predictions_updated_at();

-- ============================================================================
-- Table: yield_records
-- ============================================================================
CREATE TABLE IF NOT EXISTS yield_records (
    id                              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                       CHAR(26)        NOT NULL,

    -- relationships
    farm_id                         CHAR(26)        NOT NULL,
    field_id                        CHAR(26)        NOT NULL,
    crop_id                         CHAR(26)        NOT NULL,
    prediction_id                   CHAR(26),

    -- harvest context
    season                          TEXT,
    year                            INTEGER,
    harvest_date                    TIMESTAMPTZ,

    -- yield data
    actual_yield_kg_per_hectare     DOUBLE PRECISION,
    total_area_harvested_hectares   DOUBLE PRECISION,
    total_yield_kg                  DOUBLE PRECISION,
    harvest_quality_grade           TEXT            NOT NULL DEFAULT 'HARVEST_QUALITY_GRADE_UNSPECIFIED',
    moisture_content_pct            DOUBLE PRECISION,

    -- economics
    revenue_per_hectare             DOUBLE PRECISION,
    cost_per_hectare                DOUBLE PRECISION,
    profit_per_hectare              DOUBLE PRECISION,

    -- versioning
    version                         BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by                      CHAR(26),
    updated_by                      CHAR(26),
    created_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                      TIMESTAMPTZ
);

-- RLS
ALTER TABLE yield_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE yield_records FORCE ROW LEVEL SECURITY;

CREATE POLICY yield_records_select_policy ON yield_records
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY yield_records_insert_policy ON yield_records
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY yield_records_update_policy ON yield_records
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY yield_records_delete_policy ON yield_records
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_yield_records_tenant_id ON yield_records (tenant_id);
CREATE INDEX idx_yield_records_farm_id ON yield_records (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_records_field_id ON yield_records (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_records_crop_id ON yield_records (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_records_prediction_id ON yield_records (tenant_id, prediction_id) WHERE deleted_at IS NULL AND prediction_id IS NOT NULL;
CREATE INDEX idx_yield_records_season_year ON yield_records (tenant_id, season, year) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_records_harvest_date ON yield_records (tenant_id, harvest_date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_yield_records_quality_grade ON yield_records (tenant_id, harvest_quality_grade) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_yield_records_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_yield_records_set_updated_at
    BEFORE UPDATE ON yield_records
    FOR EACH ROW
    EXECUTE FUNCTION trg_yield_records_updated_at();
