-- 001_analytics.sql
-- Schema for the satellite-analytics-service: stress_alerts, temporal_analyses

-- Enum types
CREATE TYPE stress_type AS ENUM ('WATER', 'NUTRIENT', 'DISEASE', 'PEST', 'HEAT', 'FROST');
CREATE TYPE severity_level AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
CREATE TYPE analysis_type AS ENUM ('STRESS_DETECTION', 'CHANGE_DETECTION', 'TEMPORAL_TREND', 'ANOMALY_DETECTION', 'CROP_CLASSIFICATION');

-- Stress alerts table
CREATE TABLE stress_alerts (
    id                      BIGSERIAL PRIMARY KEY,
    uuid                    VARCHAR(26) NOT NULL UNIQUE,
    tenant_id               VARCHAR(26) NOT NULL,
    farm_id                 VARCHAR(26) NOT NULL,
    field_id                VARCHAR(26) NOT NULL,
    processing_job_id       VARCHAR(26),
    stress_type             stress_type NOT NULL,
    severity                severity_level NOT NULL DEFAULT 'LOW',
    confidence              DOUBLE PRECISION NOT NULL DEFAULT 0,
    affected_area_hectares  DOUBLE PRECISION NOT NULL DEFAULT 0,
    affected_percentage     DOUBLE PRECISION NOT NULL DEFAULT 0,
    bbox_geojson            TEXT,
    description             TEXT,
    recommendation          TEXT,
    acknowledged            BOOLEAN NOT NULL DEFAULT FALSE,
    acknowledged_at         TIMESTAMPTZ,
    acknowledged_by         VARCHAR(26),
    detected_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_by              VARCHAR(26) NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by              VARCHAR(26),
    updated_at              TIMESTAMPTZ,
    deleted_by              VARCHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- Temporal analyses table
CREATE TABLE temporal_analyses (
    id                  BIGSERIAL PRIMARY KEY,
    uuid                VARCHAR(26) NOT NULL UNIQUE,
    tenant_id           VARCHAR(26) NOT NULL,
    farm_id             VARCHAR(26) NOT NULL,
    field_id            VARCHAR(26) NOT NULL,
    analysis_type       analysis_type NOT NULL,
    metric_name         VARCHAR(255) NOT NULL,
    trend_slope         DOUBLE PRECISION NOT NULL DEFAULT 0,
    trend_r_squared     DOUBLE PRECISION NOT NULL DEFAULT 0,
    current_value       DOUBLE PRECISION NOT NULL DEFAULT 0,
    baseline_value      DOUBLE PRECISION NOT NULL DEFAULT 0,
    deviation_percent   DOUBLE PRECISION NOT NULL DEFAULT 0,
    period_start        TIMESTAMPTZ NOT NULL,
    period_end          TIMESTAMPTZ NOT NULL,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_by          VARCHAR(26) NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by          VARCHAR(26),
    updated_at          TIMESTAMPTZ,
    deleted_by          VARCHAR(26),
    deleted_at          TIMESTAMPTZ
);

-- Indexes for stress_alerts
CREATE INDEX idx_stress_alerts_tenant_id ON stress_alerts(tenant_id);
CREATE INDEX idx_stress_alerts_uuid ON stress_alerts(uuid);
CREATE INDEX idx_stress_alerts_farm_id ON stress_alerts(tenant_id, farm_id);
CREATE INDEX idx_stress_alerts_field_id ON stress_alerts(tenant_id, farm_id, field_id);
CREATE INDEX idx_stress_alerts_stress_type ON stress_alerts(tenant_id, stress_type);
CREATE INDEX idx_stress_alerts_severity ON stress_alerts(tenant_id, severity);
CREATE INDEX idx_stress_alerts_acknowledged ON stress_alerts(tenant_id, acknowledged) WHERE acknowledged = FALSE;
CREATE INDEX idx_stress_alerts_detected_at ON stress_alerts(tenant_id, detected_at DESC);
CREATE INDEX idx_stress_alerts_processing_job ON stress_alerts(processing_job_id);
CREATE INDEX idx_stress_alerts_active ON stress_alerts(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Indexes for temporal_analyses
CREATE INDEX idx_temporal_analyses_tenant_id ON temporal_analyses(tenant_id);
CREATE INDEX idx_temporal_analyses_uuid ON temporal_analyses(uuid);
CREATE INDEX idx_temporal_analyses_farm_id ON temporal_analyses(tenant_id, farm_id);
CREATE INDEX idx_temporal_analyses_field_id ON temporal_analyses(tenant_id, farm_id, field_id);
CREATE INDEX idx_temporal_analyses_analysis_type ON temporal_analyses(tenant_id, analysis_type);
CREATE INDEX idx_temporal_analyses_period ON temporal_analyses(tenant_id, period_start, period_end);
CREATE INDEX idx_temporal_analyses_created_at ON temporal_analyses(tenant_id, created_at DESC);
CREATE INDEX idx_temporal_analyses_active ON temporal_analyses(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;
