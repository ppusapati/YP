-- ============================================================================
-- Irrigation Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: irrigation_zones
-- ============================================================================
CREATE TABLE IF NOT EXISTS irrigation_zones (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    field_id            CHAR(26),
    farm_id             CHAR(26),

    -- zone details
    name                TEXT            NOT NULL,
    description         TEXT,
    area_hectares       DOUBLE PRECISION,
    soil_type           TEXT,
    crop_type           TEXT,
    crop_growth_stage   TEXT,

    -- location
    latitude            DOUBLE PRECISION,
    longitude           DOUBLE PRECISION,

    -- state
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE irrigation_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_zones FORCE ROW LEVEL SECURITY;

CREATE POLICY irrigation_zones_select_policy ON irrigation_zones
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY irrigation_zones_insert_policy ON irrigation_zones
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_zones_update_policy ON irrigation_zones
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_zones_delete_policy ON irrigation_zones
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_irrigation_zones_tenant_id ON irrigation_zones (tenant_id);
CREATE INDEX idx_irrigation_zones_field_id ON irrigation_zones (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_zones_farm_id ON irrigation_zones (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_zones_is_active ON irrigation_zones (tenant_id, is_active) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_irrigation_zones_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_irrigation_zones_set_updated_at
    BEFORE UPDATE ON irrigation_zones
    FOR EACH ROW
    EXECUTE FUNCTION trg_irrigation_zones_updated_at();

-- ============================================================================
-- Table: irrigation_schedules
-- ============================================================================
CREATE TABLE IF NOT EXISTS irrigation_schedules (
    id                          CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                   CHAR(26)        NOT NULL,

    -- relationships
    field_id                    CHAR(26),
    farm_id                     CHAR(26),
    zone_id                     CHAR(26)        REFERENCES irrigation_zones(id),
    controller_id               CHAR(26),

    -- schedule info
    name                        TEXT,
    description                 TEXT,
    schedule_type               TEXT            NOT NULL DEFAULT 'SCHEDULE_TYPE_UNSPECIFIED',
    start_time                  TIMESTAMPTZ,
    end_time                    TIMESTAMPTZ,
    duration_minutes            INTEGER,
    water_quantity_liters       DOUBLE PRECISION,
    flow_rate_liters_per_hour   DOUBLE PRECISION,
    frequency                   TEXT            NOT NULL DEFAULT 'FREQUENCY_UNSPECIFIED',

    -- adaptive parameters
    soil_moisture_threshold_pct DOUBLE PRECISION,
    weather_adjusted            BOOLEAN         NOT NULL DEFAULT FALSE,
    crop_growth_stage           TEXT,

    -- state
    status                      TEXT            NOT NULL DEFAULT 'IRRIGATION_STATUS_SCHEDULED',

    -- versioning
    version                     BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by                  CHAR(26),
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ
);

-- RLS
ALTER TABLE irrigation_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_schedules FORCE ROW LEVEL SECURITY;

CREATE POLICY irrigation_schedules_select_policy ON irrigation_schedules
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY irrigation_schedules_insert_policy ON irrigation_schedules
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_schedules_update_policy ON irrigation_schedules
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_schedules_delete_policy ON irrigation_schedules
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_irrigation_schedules_tenant_id ON irrigation_schedules (tenant_id);
CREATE INDEX idx_irrigation_schedules_field_id ON irrigation_schedules (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_schedules_farm_id ON irrigation_schedules (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_schedules_zone_id ON irrigation_schedules (tenant_id, zone_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_schedules_status ON irrigation_schedules (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_schedules_start_time ON irrigation_schedules (tenant_id, start_time) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_irrigation_schedules_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_irrigation_schedules_set_updated_at
    BEFORE UPDATE ON irrigation_schedules
    FOR EACH ROW
    EXECUTE FUNCTION trg_irrigation_schedules_updated_at();

-- ============================================================================
-- Table: irrigation_events
-- ============================================================================
CREATE TABLE IF NOT EXISTS irrigation_events (
    id                          CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                   CHAR(26)        NOT NULL,

    -- relationships
    schedule_id                 CHAR(26)        REFERENCES irrigation_schedules(id),
    zone_id                     CHAR(26)        REFERENCES irrigation_zones(id),
    controller_id               CHAR(26),

    -- event data
    status                      TEXT            NOT NULL DEFAULT 'IRRIGATION_STATUS_SCHEDULED',
    started_at                  TIMESTAMPTZ,
    ended_at                    TIMESTAMPTZ,
    actual_duration_minutes     INTEGER,
    actual_water_liters         DOUBLE PRECISION,
    soil_moisture_before_pct    DOUBLE PRECISION,
    soil_moisture_after_pct     DOUBLE PRECISION,
    failure_reason              TEXT,

    -- audit
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ
);

-- RLS
ALTER TABLE irrigation_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_events FORCE ROW LEVEL SECURITY;

CREATE POLICY irrigation_events_select_policy ON irrigation_events
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY irrigation_events_insert_policy ON irrigation_events
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_events_update_policy ON irrigation_events
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_events_delete_policy ON irrigation_events
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_irrigation_events_tenant_id ON irrigation_events (tenant_id);
CREATE INDEX idx_irrigation_events_schedule_id ON irrigation_events (tenant_id, schedule_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_events_zone_id ON irrigation_events (tenant_id, zone_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_events_status ON irrigation_events (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_events_started_at ON irrigation_events (tenant_id, started_at DESC) WHERE deleted_at IS NULL;
