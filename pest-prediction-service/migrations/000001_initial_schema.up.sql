-- ============================================================================
-- Pest Prediction Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: pest_predictions
-- ============================================================================
CREATE TABLE IF NOT EXISTS pest_predictions (
    id                          CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                   CHAR(26)        NOT NULL,

    -- relationships
    farm_id                     CHAR(26),
    field_id                    CHAR(26),
    pest_species_id             CHAR(26),

    -- prediction output
    prediction_date             TIMESTAMPTZ,
    risk_level                  TEXT            NOT NULL DEFAULT 'RISK_LEVEL_UNSPECIFIED',
    risk_score                  INTEGER,
    confidence_pct              DOUBLE PRECISION,

    -- context
    crop_type                   TEXT,
    growth_stage                TEXT            NOT NULL DEFAULT 'GROWTH_STAGE_UNSPECIFIED',
    geographic_risk_factor      DOUBLE PRECISION,
    historical_occurrence_count INTEGER         DEFAULT 0,

    -- weather factors (embedded)
    weather_temperature_celsius DOUBLE PRECISION,
    weather_humidity_pct        DOUBLE PRECISION,
    weather_rainfall_mm         DOUBLE PRECISION,
    weather_wind_speed_kmh      DOUBLE PRECISION,

    -- timeline
    predicted_onset_date        TIMESTAMPTZ,
    predicted_peak_date         TIMESTAMPTZ,
    treatment_window_start      TIMESTAMPTZ,
    treatment_window_end        TIMESTAMPTZ,

    -- treatments stored as JSONB array of objects
    recommended_treatments      JSONB           DEFAULT '[]',

    -- versioning
    version                     BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by                  CHAR(26),
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ
);

-- RLS
ALTER TABLE pest_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pest_predictions FORCE ROW LEVEL SECURITY;

CREATE POLICY pest_predictions_select_policy ON pest_predictions
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY pest_predictions_insert_policy ON pest_predictions
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_predictions_update_policy ON pest_predictions
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_predictions_delete_policy ON pest_predictions
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_pest_predictions_tenant_id ON pest_predictions (tenant_id);
CREATE INDEX idx_pest_predictions_farm_id ON pest_predictions (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_predictions_field_id ON pest_predictions (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_predictions_pest_species_id ON pest_predictions (tenant_id, pest_species_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_predictions_risk_level ON pest_predictions (tenant_id, risk_level) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_predictions_prediction_date ON pest_predictions (tenant_id, prediction_date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_predictions_treatment_window ON pest_predictions (tenant_id, treatment_window_start, treatment_window_end) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_pest_predictions_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pest_predictions_set_updated_at
    BEFORE UPDATE ON pest_predictions
    FOR EACH ROW
    EXECUTE FUNCTION trg_pest_predictions_updated_at();

-- ============================================================================
-- Table: pest_alerts
-- ============================================================================
CREATE TABLE IF NOT EXISTS pest_alerts (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    prediction_id           CHAR(26)        REFERENCES pest_predictions(id),
    farm_id                 CHAR(26),
    field_id                CHAR(26),
    pest_species_id         CHAR(26),

    -- alert details
    risk_level              TEXT            NOT NULL DEFAULT 'RISK_LEVEL_UNSPECIFIED',
    status                  TEXT            NOT NULL DEFAULT 'ALERT_STATUS_ACTIVE',
    title                   TEXT            NOT NULL,
    message                 TEXT,

    -- acknowledgment
    acknowledged_at         TIMESTAMPTZ,
    acknowledged_by         CHAR(26),

    -- versioning
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE pest_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE pest_alerts FORCE ROW LEVEL SECURITY;

CREATE POLICY pest_alerts_select_policy ON pest_alerts
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY pest_alerts_insert_policy ON pest_alerts
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_alerts_update_policy ON pest_alerts
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_alerts_delete_policy ON pest_alerts
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_pest_alerts_tenant_id ON pest_alerts (tenant_id);
CREATE INDEX idx_pest_alerts_prediction_id ON pest_alerts (tenant_id, prediction_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_alerts_farm_id ON pest_alerts (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_alerts_field_id ON pest_alerts (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_alerts_status ON pest_alerts (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_alerts_risk_level ON pest_alerts (tenant_id, risk_level) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_alerts_created_at ON pest_alerts (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_pest_alerts_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pest_alerts_set_updated_at
    BEFORE UPDATE ON pest_alerts
    FOR EACH ROW
    EXECUTE FUNCTION trg_pest_alerts_updated_at();
