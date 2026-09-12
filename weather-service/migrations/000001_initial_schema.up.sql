-- ============================================================================
-- Weather Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: field_locations
-- Polled cross-tenant by the background scheduler, so RLS is intentionally
-- not forced here; every query still filters by tenant_id explicitly.
-- ============================================================================
CREATE TABLE IF NOT EXISTS field_locations (
    id              CHAR(26)         PRIMARY KEY,
    tenant_id       CHAR(26)         NOT NULL,
    field_id        CHAR(26)         NOT NULL,
    farm_id         CHAR(26),
    latitude        DOUBLE PRECISION NOT NULL,
    longitude       DOUBLE PRECISION NOT NULL,
    elevation_m     DOUBLE PRECISION NOT NULL DEFAULT 0,
    timezone        TEXT             NOT NULL DEFAULT 'UTC',
    provider        TEXT             NOT NULL DEFAULT 'OPEN_METEO',
    last_polled_at  TIMESTAMPTZ,
    created_by      TEXT             NOT NULL DEFAULT 'system',
    created_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_field_locations_tenant_field UNIQUE (tenant_id, field_id),
    CONSTRAINT chk_field_locations_lat CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT chk_field_locations_lon CHECK (longitude BETWEEN -180 AND 180)
);

CREATE INDEX IF NOT EXISTS idx_field_locations_tenant_farm ON field_locations (tenant_id, farm_id);
CREATE INDEX IF NOT EXISTS idx_field_locations_last_polled ON field_locations (last_polled_at NULLS FIRST);

-- ============================================================================
-- Table: weather_observations (hourly)
-- ============================================================================
CREATE TABLE IF NOT EXISTS weather_observations (
    id                   CHAR(26)         PRIMARY KEY,
    tenant_id            CHAR(26)         NOT NULL,
    field_id             CHAR(26)         NOT NULL,
    observed_at          TIMESTAMPTZ      NOT NULL,
    temperature_c        DOUBLE PRECISION,
    humidity_pct         DOUBLE PRECISION,
    precipitation_mm     DOUBLE PRECISION NOT NULL DEFAULT 0,
    wind_speed_ms        DOUBLE PRECISION,
    wind_direction_deg   DOUBLE PRECISION,
    pressure_hpa         DOUBLE PRECISION,
    solar_radiation_wm2  DOUBLE PRECISION,
    cloud_cover_pct      DOUBLE PRECISION,
    dew_point_c          DOUBLE PRECISION,
    soil_temperature_c   DOUBLE PRECISION,
    soil_moisture_m3m3   DOUBLE PRECISION,
    provider             TEXT             NOT NULL,
    created_at           TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_weather_observations UNIQUE (tenant_id, field_id, observed_at)
);

CREATE INDEX IF NOT EXISTS idx_weather_observations_field_time
    ON weather_observations (tenant_id, field_id, observed_at DESC);

ALTER TABLE weather_observations ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_observations FORCE ROW LEVEL SECURITY;

CREATE POLICY weather_observations_tenant_policy ON weather_observations
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: weather_forecasts (daily, latest issue per date)
-- ============================================================================
CREATE TABLE IF NOT EXISTS weather_forecasts (
    id                   CHAR(26)         PRIMARY KEY,
    tenant_id            CHAR(26)         NOT NULL,
    field_id             CHAR(26)         NOT NULL,
    forecast_date        DATE             NOT NULL,
    issued_at            TIMESTAMPTZ      NOT NULL,
    temperature_min_c    DOUBLE PRECISION,
    temperature_max_c    DOUBLE PRECISION,
    temperature_mean_c   DOUBLE PRECISION,
    precipitation_mm     DOUBLE PRECISION NOT NULL DEFAULT 0,
    precipitation_prob   DOUBLE PRECISION,
    humidity_mean_pct    DOUBLE PRECISION,
    wind_speed_max_ms    DOUBLE PRECISION,
    solar_radiation_mj   DOUBLE PRECISION,
    et0_mm               DOUBLE PRECISION,
    condition            TEXT,
    provider             TEXT             NOT NULL,
    created_at           TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_weather_forecasts UNIQUE (tenant_id, field_id, forecast_date)
);

CREATE INDEX IF NOT EXISTS idx_weather_forecasts_field_date
    ON weather_forecasts (tenant_id, field_id, forecast_date);

ALTER TABLE weather_forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_forecasts FORCE ROW LEVEL SECURITY;

CREATE POLICY weather_forecasts_tenant_policy ON weather_forecasts
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: weather_daily_metrics (derived agronomic values, one row per field-day)
-- ============================================================================
CREATE TABLE IF NOT EXISTS weather_daily_metrics (
    tenant_id            CHAR(26)         NOT NULL,
    field_id             CHAR(26)         NOT NULL,
    date                 DATE             NOT NULL,
    temperature_min_c    DOUBLE PRECISION,
    temperature_max_c    DOUBLE PRECISION,
    temperature_mean_c   DOUBLE PRECISION,
    precipitation_mm     DOUBLE PRECISION NOT NULL DEFAULT 0,
    humidity_mean_pct    DOUBLE PRECISION,
    wind_speed_mean_ms   DOUBLE PRECISION,
    solar_radiation_mj   DOUBLE PRECISION,
    gdd                  DOUBLE PRECISION NOT NULL DEFAULT 0,
    et0_mm               DOUBLE PRECISION NOT NULL DEFAULT 0,
    chill_hours          DOUBLE PRECISION NOT NULL DEFAULT 0,
    rainfall_deficit_mm  DOUBLE PRECISION NOT NULL DEFAULT 0,
    observation_count    INTEGER          NOT NULL DEFAULT 0,
    updated_at           TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tenant_id, field_id, date)
);

ALTER TABLE weather_daily_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_daily_metrics FORCE ROW LEVEL SECURITY;

CREATE POLICY weather_daily_metrics_tenant_policy ON weather_daily_metrics
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: weather_alerts
-- ============================================================================
CREATE TABLE IF NOT EXISTS weather_alerts (
    id           CHAR(26)         PRIMARY KEY,
    tenant_id    CHAR(26)         NOT NULL,
    field_id     CHAR(26)         NOT NULL,
    alert_type   TEXT             NOT NULL,
    severity     TEXT             NOT NULL,
    message      TEXT             NOT NULL,
    value        DOUBLE PRECISION NOT NULL DEFAULT 0,
    threshold    DOUBLE PRECISION NOT NULL DEFAULT 0,
    valid_from   TIMESTAMPTZ      NOT NULL,
    valid_to     TIMESTAMPTZ      NOT NULL,
    created_at   TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_weather_alerts UNIQUE (tenant_id, field_id, alert_type, valid_from)
);

CREATE INDEX IF NOT EXISTS idx_weather_alerts_field_valid
    ON weather_alerts (tenant_id, field_id, valid_to DESC);

ALTER TABLE weather_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE weather_alerts FORCE ROW LEVEL SECURITY;

CREATE POLICY weather_alerts_tenant_policy ON weather_alerts
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: outbox_events (transactional event publishing)
-- ============================================================================
CREATE TABLE IF NOT EXISTS outbox_events (
    id          BIGSERIAL   PRIMARY KEY,
    topic       TEXT        NOT NULL,
    event_key   TEXT        NOT NULL,
    payload     BYTEA       NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_outbox_events_created_at ON outbox_events (created_at);
