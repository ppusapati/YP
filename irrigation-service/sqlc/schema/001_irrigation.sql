-- ==========================================================================
-- Irrigation Service Schema
-- ==========================================================================

CREATE TABLE IF NOT EXISTS irrigation_zones (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        CHAR(26)     NOT NULL UNIQUE,
    tenant_id   VARCHAR(64)  NOT NULL,
    field_id    VARCHAR(64)  NOT NULL,
    farm_id     VARCHAR(64)  NOT NULL,
    name        VARCHAR(255) NOT NULL,
    description TEXT         DEFAULT '',
    area_hectares     DOUBLE PRECISION NOT NULL DEFAULT 0,
    soil_type         VARCHAR(100) NOT NULL DEFAULT '',
    crop_type         VARCHAR(100) NOT NULL DEFAULT '',
    crop_growth_stage VARCHAR(100) NOT NULL DEFAULT '',
    latitude          DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude         DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(64)  NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(64),
    updated_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(64),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_irrigation_zones_tenant ON irrigation_zones(tenant_id);
CREATE INDEX idx_irrigation_zones_field  ON irrigation_zones(tenant_id, field_id);
CREATE INDEX idx_irrigation_zones_farm   ON irrigation_zones(tenant_id, farm_id);

-- --------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS water_controllers (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        CHAR(26)     NOT NULL UNIQUE,
    tenant_id   VARCHAR(64)  NOT NULL,
    zone_id     VARCHAR(64)  NOT NULL DEFAULT '',
    field_id    VARCHAR(64)  NOT NULL DEFAULT '',
    farm_id     VARCHAR(64)  NOT NULL DEFAULT '',
    name        VARCHAR(255) NOT NULL,
    model       VARCHAR(255) NOT NULL DEFAULT '',
    firmware_version VARCHAR(100) NOT NULL DEFAULT '',
    controller_type  VARCHAR(50)  NOT NULL DEFAULT 'DRIP',
    protocol         VARCHAR(50)  NOT NULL DEFAULT 'MQTT',
    status           VARCHAR(50)  NOT NULL DEFAULT 'OFFLINE',
    endpoint         TEXT         NOT NULL DEFAULT '',
    max_flow_rate_liters_per_hour DOUBLE PRECISION NOT NULL DEFAULT 0,
    last_heartbeat TIMESTAMPTZ,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(64)  NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(64),
    updated_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(64),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_water_controllers_tenant ON water_controllers(tenant_id);
CREATE INDEX idx_water_controllers_zone   ON water_controllers(tenant_id, zone_id);
CREATE INDEX idx_water_controllers_status ON water_controllers(tenant_id, status);

-- --------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS irrigation_schedules (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        CHAR(26)     NOT NULL UNIQUE,
    tenant_id   VARCHAR(64)  NOT NULL,
    field_id    VARCHAR(64)  NOT NULL,
    farm_id     VARCHAR(64)  NOT NULL,
    zone_id     VARCHAR(64)  NOT NULL DEFAULT '',
    name        VARCHAR(255) NOT NULL DEFAULT '',
    description TEXT         DEFAULT '',
    schedule_type   VARCHAR(50)  NOT NULL DEFAULT 'FIXED',
    start_time      TIMESTAMPTZ  NOT NULL,
    end_time        TIMESTAMPTZ,
    duration_minutes  INT        NOT NULL DEFAULT 0,
    water_quantity_liters  DOUBLE PRECISION NOT NULL DEFAULT 0,
    flow_rate_liters_per_hour DOUBLE PRECISION NOT NULL DEFAULT 0,
    frequency       VARCHAR(50)  NOT NULL DEFAULT 'DAILY',
    soil_moisture_threshold_pct DOUBLE PRECISION NOT NULL DEFAULT 0,
    weather_adjusted BOOLEAN     NOT NULL DEFAULT FALSE,
    crop_growth_stage VARCHAR(100) NOT NULL DEFAULT '',
    controller_id    VARCHAR(64)  NOT NULL DEFAULT '',
    status           VARCHAR(50)  NOT NULL DEFAULT 'SCHEDULED',
    version          BIGINT       NOT NULL DEFAULT 1,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(64)  NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(64),
    updated_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(64),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_irrigation_schedules_tenant   ON irrigation_schedules(tenant_id);
CREATE INDEX idx_irrigation_schedules_field    ON irrigation_schedules(tenant_id, field_id);
CREATE INDEX idx_irrigation_schedules_zone     ON irrigation_schedules(tenant_id, zone_id);
CREATE INDEX idx_irrigation_schedules_status   ON irrigation_schedules(tenant_id, status);
CREATE INDEX idx_irrigation_schedules_time     ON irrigation_schedules(tenant_id, start_time, end_time);

-- --------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS irrigation_events (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        CHAR(26)     NOT NULL UNIQUE,
    tenant_id   VARCHAR(64)  NOT NULL,
    schedule_id VARCHAR(64)  NOT NULL DEFAULT '',
    zone_id     VARCHAR(64)  NOT NULL DEFAULT '',
    controller_id VARCHAR(64) NOT NULL DEFAULT '',
    status      VARCHAR(50)  NOT NULL DEFAULT 'SCHEDULED',
    started_at  TIMESTAMPTZ,
    ended_at    TIMESTAMPTZ,
    actual_duration_minutes INT NOT NULL DEFAULT 0,
    actual_water_liters DOUBLE PRECISION NOT NULL DEFAULT 0,
    soil_moisture_before_pct DOUBLE PRECISION NOT NULL DEFAULT 0,
    soil_moisture_after_pct  DOUBLE PRECISION NOT NULL DEFAULT 0,
    failure_reason TEXT DEFAULT '',
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(64)  NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(64),
    updated_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(64),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_irrigation_events_tenant     ON irrigation_events(tenant_id);
CREATE INDEX idx_irrigation_events_schedule   ON irrigation_events(tenant_id, schedule_id);
CREATE INDEX idx_irrigation_events_zone       ON irrigation_events(tenant_id, zone_id);
CREATE INDEX idx_irrigation_events_controller ON irrigation_events(tenant_id, controller_id);
CREATE INDEX idx_irrigation_events_status     ON irrigation_events(tenant_id, status);
CREATE INDEX idx_irrigation_events_time       ON irrigation_events(tenant_id, started_at);

-- --------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS irrigation_decisions (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        CHAR(26)     NOT NULL UNIQUE,
    tenant_id   VARCHAR(64)  NOT NULL,
    zone_id     VARCHAR(64)  NOT NULL DEFAULT '',
    field_id    VARCHAR(64)  NOT NULL DEFAULT '',
    schedule_id VARCHAR(64)  NOT NULL DEFAULT '',
    -- Input fields
    input_soil_moisture         DOUBLE PRECISION NOT NULL DEFAULT 0,
    input_temperature           DOUBLE PRECISION NOT NULL DEFAULT 0,
    input_humidity              DOUBLE PRECISION NOT NULL DEFAULT 0,
    input_rainfall_forecast_mm  DOUBLE PRECISION NOT NULL DEFAULT 0,
    input_wind_speed            DOUBLE PRECISION NOT NULL DEFAULT 0,
    input_crop_type             VARCHAR(100) NOT NULL DEFAULT '',
    input_growth_stage          VARCHAR(100) NOT NULL DEFAULT '',
    input_evapotranspiration_mm DOUBLE PRECISION NOT NULL DEFAULT 0,
    -- Output fields
    output_should_irrigate      BOOLEAN NOT NULL DEFAULT FALSE,
    output_water_quantity_liters DOUBLE PRECISION NOT NULL DEFAULT 0,
    output_duration_minutes     INT NOT NULL DEFAULT 0,
    output_optimal_time         TIMESTAMPTZ,
    output_reasoning            TEXT NOT NULL DEFAULT '',
    output_confidence_score     DOUBLE PRECISION NOT NULL DEFAULT 0,
    decided_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    applied     BOOLEAN      NOT NULL DEFAULT FALSE,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(64)  NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(64),
    updated_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(64),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_irrigation_decisions_tenant ON irrigation_decisions(tenant_id);
CREATE INDEX idx_irrigation_decisions_zone   ON irrigation_decisions(tenant_id, zone_id);
CREATE INDEX idx_irrigation_decisions_field  ON irrigation_decisions(tenant_id, field_id);

-- --------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS water_usage_logs (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        CHAR(26)     NOT NULL UNIQUE,
    tenant_id   VARCHAR(64)  NOT NULL,
    zone_id     VARCHAR(64)  NOT NULL DEFAULT '',
    controller_id VARCHAR(64) NOT NULL DEFAULT '',
    water_liters DOUBLE PRECISION NOT NULL DEFAULT 0,
    recorded_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    period_start TIMESTAMPTZ NOT NULL,
    period_end   TIMESTAMPTZ NOT NULL,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(64)  NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(64),
    updated_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(64),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_water_usage_logs_tenant     ON water_usage_logs(tenant_id);
CREATE INDEX idx_water_usage_logs_zone       ON water_usage_logs(tenant_id, zone_id);
CREATE INDEX idx_water_usage_logs_controller ON water_usage_logs(tenant_id, controller_id);
CREATE INDEX idx_water_usage_logs_period     ON water_usage_logs(tenant_id, period_start, period_end);
