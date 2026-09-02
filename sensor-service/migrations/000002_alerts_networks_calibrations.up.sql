-- ============================================================================
-- Sensor Service: Alerts, Networks, Calibrations Migration (UP)
-- ============================================================================

-- ============================================================================
-- sensors: add audit / status columns used by the postgres adapter
-- ============================================================================
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS is_active  BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS created_by CHAR(26);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS updated_by CHAR(26);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS deleted_by CHAR(26);

-- Note: location is represented with the existing plain latitude/longitude
-- columns rather than a PostGIS geography column, so no PostGIS extension
-- is required by this service.

-- ============================================================================
-- sensor_readings: align column name with the adapter/domain (recorded_at)
-- ============================================================================
ALTER TABLE sensor_readings RENAME COLUMN "timestamp" TO recorded_at;

-- ============================================================================
-- Table: sensor_alerts
-- ============================================================================
CREATE TABLE IF NOT EXISTS sensor_alerts (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    sensor_id               CHAR(26)        NOT NULL REFERENCES sensors(id) ON DELETE CASCADE,
    field_id                CHAR(26)        NOT NULL DEFAULT '',

    -- alert data
    sensor_type             TEXT            NOT NULL DEFAULT 'SENSOR_TYPE_UNSPECIFIED',
    threshold                DOUBLE PRECISION NOT NULL,
    actual_value            DOUBLE PRECISION NOT NULL,
    condition               TEXT            NOT NULL,
    severity                TEXT            NOT NULL DEFAULT 'LOW',
    message                 TEXT            NOT NULL DEFAULT '',

    -- acknowledgement
    acknowledged            BOOLEAN         NOT NULL DEFAULT FALSE,
    acknowledged_by         CHAR(26),
    acknowledged_at         TIMESTAMPTZ,

    -- status
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_by              CHAR(26),
    updated_by               CHAR(26),
    created_at               TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_by               CHAR(26),
    deleted_at               TIMESTAMPTZ
);

-- RLS
ALTER TABLE sensor_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_alerts FORCE ROW LEVEL SECURITY;

CREATE POLICY sensor_alerts_select_policy ON sensor_alerts
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY sensor_alerts_insert_policy ON sensor_alerts
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_alerts_update_policy ON sensor_alerts
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_alerts_delete_policy ON sensor_alerts
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_sensor_alerts_tenant_id ON sensor_alerts (tenant_id);
CREATE INDEX idx_sensor_alerts_sensor_id ON sensor_alerts (tenant_id, sensor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensor_alerts_field_id ON sensor_alerts (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensor_alerts_severity ON sensor_alerts (tenant_id, severity) WHERE deleted_at IS NULL;
CREATE INDEX idx_sensor_alerts_unacknowledged ON sensor_alerts (sensor_id, acknowledged) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_sensor_alerts_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sensor_alerts_set_updated_at
    BEFORE UPDATE ON sensor_alerts
    FOR EACH ROW
    EXECUTE FUNCTION trg_sensor_alerts_updated_at();

-- ============================================================================
-- Table: sensor_networks
-- ============================================================================
CREATE TABLE IF NOT EXISTS sensor_networks (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    farm_id                 CHAR(26)        NOT NULL,

    -- network data
    name                    TEXT            NOT NULL,
    description             TEXT            NOT NULL DEFAULT '',
    protocol                TEXT            NOT NULL DEFAULT 'SENSOR_PROTOCOL_UNSPECIFIED',
    gateway_id              TEXT            NOT NULL DEFAULT '',
    sensor_ids              TEXT[]          NOT NULL DEFAULT '{}',
    total_sensors           INTEGER         NOT NULL DEFAULT 0,
    active_sensors          INTEGER         NOT NULL DEFAULT 0,

    -- status
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_by              CHAR(26),
    updated_by              CHAR(26),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE sensor_networks ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_networks FORCE ROW LEVEL SECURITY;

CREATE POLICY sensor_networks_select_policy ON sensor_networks
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY sensor_networks_insert_policy ON sensor_networks
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_networks_update_policy ON sensor_networks
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_networks_delete_policy ON sensor_networks
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_sensor_networks_tenant_id ON sensor_networks (tenant_id);
CREATE INDEX idx_sensor_networks_farm_id ON sensor_networks (tenant_id, farm_id) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_sensor_networks_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sensor_networks_set_updated_at
    BEFORE UPDATE ON sensor_networks
    FOR EACH ROW
    EXECUTE FUNCTION trg_sensor_networks_updated_at();

-- ============================================================================
-- Table: sensor_calibrations
-- ============================================================================
CREATE TABLE IF NOT EXISTS sensor_calibrations (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    sensor_id               CHAR(26)        NOT NULL REFERENCES sensors(id) ON DELETE CASCADE,

    -- calibration data
    offset_value            DOUBLE PRECISION NOT NULL DEFAULT 0,
    scale_factor            DOUBLE PRECISION NOT NULL DEFAULT 1,
    calibration_date        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    next_calibration_date   TIMESTAMPTZ,
    calibrated_by           CHAR(26),
    notes                   TEXT            NOT NULL DEFAULT '',

    -- status
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_by              CHAR(26),
    created_at               TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_by               CHAR(26),
    deleted_at               TIMESTAMPTZ
);

-- RLS
ALTER TABLE sensor_calibrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_calibrations FORCE ROW LEVEL SECURITY;

CREATE POLICY sensor_calibrations_select_policy ON sensor_calibrations
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY sensor_calibrations_insert_policy ON sensor_calibrations
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_calibrations_update_policy ON sensor_calibrations
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sensor_calibrations_delete_policy ON sensor_calibrations
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_sensor_calibrations_tenant_id ON sensor_calibrations (tenant_id);
CREATE INDEX idx_sensor_calibrations_sensor_id ON sensor_calibrations (sensor_id, calibration_date DESC) WHERE deleted_at IS NULL;
