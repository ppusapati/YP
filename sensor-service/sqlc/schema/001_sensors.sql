-- 001_sensors.sql
-- Schema for sensor-service: IoT sensor networks for precision agriculture

-- Enable PostGIS for geospatial queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- =============================================================================
-- Table: sensors
-- Stores IoT sensor device registration and metadata
-- =============================================================================
CREATE TABLE IF NOT EXISTS sensors (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id   VARCHAR(26)  NOT NULL,
    field_id    VARCHAR(26)  NOT NULL,
    farm_id     VARCHAR(26)  NOT NULL,
    sensor_type VARCHAR(30)  NOT NULL CHECK (sensor_type IN (
        'SOIL_MOISTURE', 'SOIL_PH', 'TEMPERATURE', 'HUMIDITY',
        'RAINFALL', 'WIND_SPEED', 'WIND_DIRECTION', 'LIGHT_INTENSITY', 'LEAF_WETNESS'
    )),
    device_id          VARCHAR(255) NOT NULL,
    manufacturer       VARCHAR(255) NOT NULL DEFAULT '',
    model              VARCHAR(255) NOT NULL DEFAULT '',
    firmware_version   VARCHAR(100) NOT NULL DEFAULT '',
    location           GEOMETRY(Point, 4326),
    latitude           DOUBLE PRECISION,
    longitude          DOUBLE PRECISION,
    elevation_m        DOUBLE PRECISION DEFAULT 0,
    installation_date  TIMESTAMPTZ,
    last_reading_at    TIMESTAMPTZ,
    battery_level_pct  DOUBLE PRECISION DEFAULT 100,
    signal_strength_dbm DOUBLE PRECISION DEFAULT 0,
    status             VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN (
        'ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DECOMMISSIONED'
    )),
    protocol           VARCHAR(20) NOT NULL DEFAULT 'MQTT' CHECK (protocol IN (
        'MQTT', 'LORAWAN', 'ZIGBEE', 'WIFI', 'CELLULAR'
    )),
    reading_interval_seconds INTEGER NOT NULL DEFAULT 300,
    metadata           JSONB DEFAULT '{}',
    version            BIGINT NOT NULL DEFAULT 1,
    is_active          BOOLEAN NOT NULL DEFAULT true,
    created_by         VARCHAR(26) NOT NULL DEFAULT '',
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by         VARCHAR(26),
    updated_at         TIMESTAMPTZ,
    deleted_by         VARCHAR(26),
    deleted_at         TIMESTAMPTZ
);

CREATE INDEX idx_sensors_tenant_id ON sensors(tenant_id);
CREATE INDEX idx_sensors_field_id ON sensors(field_id);
CREATE INDEX idx_sensors_farm_id ON sensors(farm_id);
CREATE INDEX idx_sensors_device_id ON sensors(tenant_id, device_id);
CREATE INDEX idx_sensors_sensor_type ON sensors(tenant_id, sensor_type);
CREATE INDEX idx_sensors_status ON sensors(tenant_id, status);
CREATE INDEX idx_sensors_location ON sensors USING GIST(location);
CREATE INDEX idx_sensors_active ON sensors(tenant_id, is_active) WHERE is_active = true AND deleted_at IS NULL;

-- =============================================================================
-- Table: sensor_readings
-- Stores time-series sensor data. Designed for TimescaleDB hypertable conversion.
-- In production, run: SELECT create_hypertable('sensor_readings', 'recorded_at');
-- =============================================================================
CREATE TABLE IF NOT EXISTS sensor_readings (
    id                  BIGSERIAL,
    uuid                VARCHAR(26)      NOT NULL,
    sensor_id           VARCHAR(26)      NOT NULL,
    tenant_id           VARCHAR(26)      NOT NULL,
    value               DOUBLE PRECISION NOT NULL,
    unit                VARCHAR(30)      NOT NULL,
    recorded_at         TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    quality             VARCHAR(10)      NOT NULL DEFAULT 'GOOD' CHECK (quality IN ('GOOD', 'SUSPECT', 'BAD')),
    battery_level_pct   DOUBLE PRECISION,
    signal_strength_dbm DOUBLE PRECISION,
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, recorded_at)
);

-- TimescaleDB: SELECT create_hypertable('sensor_readings', 'recorded_at', chunk_time_interval => INTERVAL '1 day');
-- TimescaleDB: SELECT add_retention_policy('sensor_readings', INTERVAL '2 years');

CREATE INDEX idx_sensor_readings_sensor_time ON sensor_readings(sensor_id, recorded_at DESC);
CREATE INDEX idx_sensor_readings_tenant ON sensor_readings(tenant_id, recorded_at DESC);
CREATE INDEX idx_sensor_readings_quality ON sensor_readings(sensor_id, quality, recorded_at DESC);

-- =============================================================================
-- Table: sensor_alerts
-- Threshold-based alerts triggered by sensor readings
-- =============================================================================
CREATE TABLE IF NOT EXISTS sensor_alerts (
    id               BIGSERIAL   PRIMARY KEY,
    uuid             VARCHAR(26) NOT NULL UNIQUE,
    sensor_id        VARCHAR(26) NOT NULL,
    tenant_id        VARCHAR(26) NOT NULL,
    field_id         VARCHAR(26) NOT NULL DEFAULT '',
    sensor_type      VARCHAR(30) NOT NULL,
    threshold        DOUBLE PRECISION NOT NULL,
    actual_value     DOUBLE PRECISION NOT NULL,
    condition        VARCHAR(5)  NOT NULL CHECK (condition IN ('GT', 'LT', 'EQ', 'GTE', 'LTE')),
    severity         VARCHAR(10) NOT NULL DEFAULT 'MEDIUM' CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    message          TEXT NOT NULL DEFAULT '',
    acknowledged     BOOLEAN NOT NULL DEFAULT false,
    acknowledged_by  VARCHAR(26),
    acknowledged_at  TIMESTAMPTZ,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    created_by       VARCHAR(26) NOT NULL DEFAULT '',
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by       VARCHAR(26),
    updated_at       TIMESTAMPTZ,
    deleted_by       VARCHAR(26),
    deleted_at       TIMESTAMPTZ
);

CREATE INDEX idx_sensor_alerts_sensor_id ON sensor_alerts(sensor_id);
CREATE INDEX idx_sensor_alerts_tenant ON sensor_alerts(tenant_id);
CREATE INDEX idx_sensor_alerts_severity ON sensor_alerts(tenant_id, severity);
CREATE INDEX idx_sensor_alerts_unacknowledged ON sensor_alerts(tenant_id, acknowledged) WHERE acknowledged = false;
CREATE INDEX idx_sensor_alerts_field ON sensor_alerts(field_id);

-- =============================================================================
-- Table: sensor_networks
-- Groups of sensors sharing a gateway or protocol
-- =============================================================================
CREATE TABLE IF NOT EXISTS sensor_networks (
    id              BIGSERIAL    PRIMARY KEY,
    uuid            VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id       VARCHAR(26)  NOT NULL,
    farm_id         VARCHAR(26)  NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT NOT NULL DEFAULT '',
    protocol        VARCHAR(20)  NOT NULL DEFAULT 'MQTT' CHECK (protocol IN (
        'MQTT', 'LORAWAN', 'ZIGBEE', 'WIFI', 'CELLULAR'
    )),
    gateway_id      VARCHAR(255) NOT NULL DEFAULT '',
    sensor_ids      TEXT[] DEFAULT '{}',
    total_sensors   INTEGER NOT NULL DEFAULT 0,
    active_sensors  INTEGER NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_by      VARCHAR(26) NOT NULL DEFAULT '',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_sensor_networks_tenant ON sensor_networks(tenant_id);
CREATE INDEX idx_sensor_networks_farm ON sensor_networks(farm_id);

-- =============================================================================
-- Table: sensor_calibrations
-- Calibration history for sensor accuracy tracking
-- =============================================================================
CREATE TABLE IF NOT EXISTS sensor_calibrations (
    id                    BIGSERIAL    PRIMARY KEY,
    uuid                  VARCHAR(26)  NOT NULL UNIQUE,
    sensor_id             VARCHAR(26)  NOT NULL,
    tenant_id             VARCHAR(26)  NOT NULL,
    offset_value          DOUBLE PRECISION NOT NULL DEFAULT 0,
    scale_factor          DOUBLE PRECISION NOT NULL DEFAULT 1,
    calibration_date      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    next_calibration_date TIMESTAMPTZ,
    calibrated_by         VARCHAR(26)  NOT NULL DEFAULT '',
    notes                 TEXT NOT NULL DEFAULT '',
    is_active             BOOLEAN NOT NULL DEFAULT true,
    created_by            VARCHAR(26)  NOT NULL DEFAULT '',
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_by            VARCHAR(26),
    deleted_at            TIMESTAMPTZ
);

CREATE INDEX idx_sensor_calibrations_sensor ON sensor_calibrations(sensor_id);
CREATE INDEX idx_sensor_calibrations_tenant ON sensor_calibrations(tenant_id);
CREATE INDEX idx_sensor_calibrations_date ON sensor_calibrations(sensor_id, calibration_date DESC);
