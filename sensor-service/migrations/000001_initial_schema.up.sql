-- ============================================================================
-- Sensor Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: sensors
-- ============================================================================
CREATE TABLE IF NOT EXISTS sensors (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    field_id                CHAR(26),
    farm_id                 CHAR(26),

    -- device info
    sensor_type             TEXT            NOT NULL DEFAULT 'SENSOR_TYPE_UNSPECIFIED',
    device_id               TEXT            NOT NULL,
    manufacturer            TEXT,
    model                   TEXT,
    firmware_version        TEXT,

    -- location
    latitude                DOUBLE PRECISION,
    longitude               DOUBLE PRECISION,
    elevation_m             DOUBLE PRECISION,

    -- operational
    installation_date       TIMESTAMPTZ,
    last_reading_at         TIMESTAMPTZ,
    battery_level_pct       DOUBLE PRECISION,
    signal_strength_dbm     DOUBLE PRECISION,
    status                  TEXT            NOT NULL DEFAULT 'SENSOR_STATUS_ACTIVE',
    protocol                TEXT            NOT NULL DEFAULT 'SENSOR_PROTOCOL_UNSPECIFIED',
    reading_interval_seconds INTEGER,

    -- metadata / versioning
    metadata                JSONB           DEFAULT '{}',
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE sensors ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensors FORCE ROW LEVEL SECURITY;

CREATE POLICY sensors_select_policy ON sensors
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY sensors_insert_policy ON sensors
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensors_update_policy ON sensors
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensors_delete_policy ON sensors
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_sensors_tenant_id ON sensors (tenant_id);
CREATE INDEX idx_sensors_field_id ON sensors (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensors_farm_id ON sensors (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensors_device_id ON sensors (tenant_id, device_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensors_sensor_type ON sensors (tenant_id, sensor_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensors_status ON sensors (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensors_protocol ON sensors (tenant_id, protocol) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_sensors_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sensors_set_updated_at
    BEFORE UPDATE ON sensors
    FOR EACH ROW
    EXECUTE FUNCTION trg_sensors_updated_at();

-- ============================================================================
-- Table: sensor_readings
-- ============================================================================
CREATE TABLE IF NOT EXISTS sensor_readings (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    sensor_id               CHAR(26)        NOT NULL REFERENCES sensors(id) ON DELETE CASCADE,

    -- reading data
    value                   DOUBLE PRECISION NOT NULL,
    unit                    TEXT            NOT NULL,
    timestamp               TIMESTAMPTZ     NOT NULL,
    quality                 TEXT            NOT NULL DEFAULT 'READING_QUALITY_UNSPECIFIED',

    -- device state at reading time
    battery_level_pct       DOUBLE PRECISION,
    signal_strength_dbm     DOUBLE PRECISION,

    -- metadata
    metadata                JSONB           DEFAULT '{}',

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_readings FORCE ROW LEVEL SECURITY;

CREATE POLICY sensor_readings_select_policy ON sensor_readings
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY sensor_readings_insert_policy ON sensor_readings
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_readings_update_policy ON sensor_readings
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_readings_delete_policy ON sensor_readings
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_sensor_readings_tenant_id ON sensor_readings (tenant_id);
CREATE INDEX idx_sensor_readings_sensor_id ON sensor_readings (sensor_id, timestamp DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensor_readings_timestamp ON sensor_readings (tenant_id, timestamp DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensor_readings_quality ON sensor_readings (tenant_id, quality) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensor_readings_sensor_time_range ON sensor_readings (sensor_id, timestamp) WHERE deleted_at IS NULL;
