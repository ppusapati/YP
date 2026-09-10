-- ============================================================================
-- Satellite Analytics Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Custom Enum Types
-- ============================================================================
CREATE TYPE stress_type AS ENUM (
    'WATER',
    'NUTRIENT',
    'DISEASE',
    'PEST',
    'HEAT',
    'FROST'
);

CREATE TYPE severity_level AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);

CREATE TYPE analysis_type AS ENUM (
    'STRESS_DETECTION',
    'CHANGE_DETECTION',
    'TEMPORAL_TREND',
    'ANOMALY_DETECTION',
    'CROP_CLASSIFICATION'
);

-- ============================================================================
-- Table: stress_alerts
-- ============================================================================
CREATE TABLE IF NOT EXISTS stress_alerts (
    id                      BIGSERIAL       PRIMARY KEY,
    uuid                    CHAR(26)        NOT NULL UNIQUE,
    tenant_id               CHAR(26)        NOT NULL,
    farm_id                 CHAR(26)        NOT NULL,
    field_id                CHAR(26)        NOT NULL,
    processing_job_id       CHAR(26),
    stress_type             stress_type     NOT NULL,
    severity                severity_level  NOT NULL,
    confidence              DOUBLE PRECISION NOT NULL,
    affected_area_hectares  DOUBLE PRECISION NOT NULL DEFAULT 0,
    affected_percentage     DOUBLE PRECISION NOT NULL DEFAULT 0,
    bbox_geojson            TEXT,
    description             TEXT,
    recommendation          TEXT,
    acknowledged            BOOLEAN         NOT NULL DEFAULT FALSE,
    acknowledged_at         TIMESTAMPTZ,
    acknowledged_by         CHAR(26),
    detected_at             TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by              CHAR(26)        NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by              CHAR(26),
    updated_at              TIMESTAMPTZ,
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE stress_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE stress_alerts FORCE ROW LEVEL SECURITY;

CREATE POLICY stress_alerts_select_policy ON stress_alerts
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY stress_alerts_insert_policy ON stress_alerts
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY stress_alerts_update_policy ON stress_alerts
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY stress_alerts_delete_policy ON stress_alerts
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_stress_alerts_tenant_id ON stress_alerts (tenant_id);
CREATE INDEX idx_stress_alerts_uuid ON stress_alerts (uuid);
CREATE INDEX idx_stress_alerts_farm_id ON stress_alerts (tenant_id, farm_id) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_stress_alerts_field_id ON stress_alerts (tenant_id, farm_id, field_id) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_stress_alerts_stress_type ON stress_alerts (tenant_id, stress_type) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_stress_alerts_severity ON stress_alerts (tenant_id, severity) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_stress_alerts_detected_at ON stress_alerts (tenant_id, detected_at DESC) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_stress_alerts_processing_job ON stress_alerts (processing_job_id, tenant_id) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_stress_alerts_unacknowledged ON stress_alerts (tenant_id, farm_id, field_id) WHERE is_active = TRUE AND deleted_at IS NULL AND acknowledged = FALSE;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_stress_alerts_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stress_alerts_set_updated_at
    BEFORE UPDATE ON stress_alerts
    FOR EACH ROW
    EXECUTE FUNCTION trg_stress_alerts_updated_at();

-- ============================================================================
-- Table: temporal_analyses
-- ============================================================================
CREATE TABLE IF NOT EXISTS temporal_analyses (
    id                      BIGSERIAL       PRIMARY KEY,
    uuid                    CHAR(26)        NOT NULL UNIQUE,
    tenant_id               CHAR(26)        NOT NULL,
    farm_id                 CHAR(26)        NOT NULL,
    field_id                CHAR(26)        NOT NULL,
    analysis_type           analysis_type   NOT NULL,
    metric_name             TEXT            NOT NULL,
    trend_slope             DOUBLE PRECISION NOT NULL DEFAULT 0,
    trend_r_squared         DOUBLE PRECISION NOT NULL DEFAULT 0,
    current_value           DOUBLE PRECISION NOT NULL DEFAULT 0,
    baseline_value          DOUBLE PRECISION NOT NULL DEFAULT 0,
    deviation_percent       DOUBLE PRECISION NOT NULL DEFAULT 0,
    period_start            TIMESTAMPTZ     NOT NULL,
    period_end              TIMESTAMPTZ     NOT NULL,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by              CHAR(26)        NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by              CHAR(26),
    updated_at              TIMESTAMPTZ,
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE temporal_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE temporal_analyses FORCE ROW LEVEL SECURITY;

CREATE POLICY temporal_analyses_select_policy ON temporal_analyses
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY temporal_analyses_insert_policy ON temporal_analyses
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY temporal_analyses_update_policy ON temporal_analyses
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY temporal_analyses_delete_policy ON temporal_analyses
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_temporal_analyses_tenant_id ON temporal_analyses (tenant_id);
CREATE INDEX idx_temporal_analyses_uuid ON temporal_analyses (uuid);
CREATE INDEX idx_temporal_analyses_farm_id ON temporal_analyses (tenant_id, farm_id) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_temporal_analyses_field_id ON temporal_analyses (tenant_id, farm_id, field_id) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_temporal_analyses_analysis_type ON temporal_analyses (tenant_id, analysis_type) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_temporal_analyses_created_at ON temporal_analyses (tenant_id, created_at DESC) WHERE is_active = TRUE AND deleted_at IS NULL;
