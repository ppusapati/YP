-- ============================================================================
-- Irrigation Service: Controllers, Decisions, Water Usage Migration (UP)
-- ============================================================================

-- ============================================================================
-- Table: water_controllers
-- ============================================================================
CREATE TABLE IF NOT EXISTS water_controllers (
    id                              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                       CHAR(26)        NOT NULL,

    -- relationships
    zone_id                         CHAR(26)        REFERENCES irrigation_zones(id),
    field_id                        CHAR(26),
    farm_id                         CHAR(26),

    -- controller details
    name                            TEXT            NOT NULL,
    model                           TEXT,
    firmware_version                TEXT,
    controller_type                 TEXT            NOT NULL DEFAULT 'CONTROLLER_TYPE_UNSPECIFIED',
    protocol                        TEXT            NOT NULL DEFAULT 'PROTOCOL_UNSPECIFIED',
    status                          TEXT            NOT NULL DEFAULT 'CONTROLLER_STATUS_OFFLINE',
    endpoint                        TEXT,
    max_flow_rate_liters_per_hour   DOUBLE PRECISION,
    last_heartbeat                  TIMESTAMPTZ,

    -- state
    is_active                       BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_by                      CHAR(26),
    created_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                      TIMESTAMPTZ
);

-- RLS
ALTER TABLE water_controllers ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_controllers FORCE ROW LEVEL SECURITY;

CREATE POLICY water_controllers_select_policy ON water_controllers
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY water_controllers_insert_policy ON water_controllers
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY water_controllers_update_policy ON water_controllers
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY water_controllers_delete_policy ON water_controllers
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_water_controllers_tenant_id ON water_controllers (tenant_id);
CREATE INDEX idx_water_controllers_zone_id ON water_controllers (tenant_id, zone_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_water_controllers_field_id ON water_controllers (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_water_controllers_farm_id ON water_controllers (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_water_controllers_status ON water_controllers (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_water_controllers_is_active ON water_controllers (tenant_id, is_active) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_water_controllers_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_water_controllers_set_updated_at
    BEFORE UPDATE ON water_controllers
    FOR EACH ROW
    EXECUTE FUNCTION trg_water_controllers_updated_at();

-- ============================================================================
-- Table: irrigation_decisions
-- ============================================================================
CREATE TABLE IF NOT EXISTS irrigation_decisions (
    id                              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                       CHAR(26)        NOT NULL,

    -- relationships
    zone_id                         CHAR(26)        REFERENCES irrigation_zones(id),
    field_id                        CHAR(26),
    schedule_id                     CHAR(26)        REFERENCES irrigation_schedules(id),

    -- decision inputs
    input_soil_moisture             DOUBLE PRECISION,
    input_temperature               DOUBLE PRECISION,
    input_humidity                  DOUBLE PRECISION,
    input_rainfall_forecast_mm      DOUBLE PRECISION,
    input_wind_speed                DOUBLE PRECISION,
    input_crop_type                 TEXT,
    input_growth_stage              TEXT,
    input_evapotranspiration_mm     DOUBLE PRECISION,

    -- decision output
    output_should_irrigate          BOOLEAN         NOT NULL DEFAULT FALSE,
    output_water_quantity_liters    DOUBLE PRECISION,
    output_duration_minutes         INTEGER,
    output_optimal_time             TIMESTAMPTZ,
    output_reasoning                TEXT,
    output_confidence_score         DOUBLE PRECISION,

    -- state
    decided_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    applied                         BOOLEAN         NOT NULL DEFAULT FALSE,

    -- audit
    created_by                      CHAR(26),
    created_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                      TIMESTAMPTZ
);

-- RLS
ALTER TABLE irrigation_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_decisions FORCE ROW LEVEL SECURITY;

CREATE POLICY irrigation_decisions_select_policy ON irrigation_decisions
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY irrigation_decisions_insert_policy ON irrigation_decisions
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_decisions_update_policy ON irrigation_decisions
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_decisions_delete_policy ON irrigation_decisions
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_irrigation_decisions_tenant_id ON irrigation_decisions (tenant_id);
CREATE INDEX idx_irrigation_decisions_zone_id ON irrigation_decisions (tenant_id, zone_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_decisions_field_id ON irrigation_decisions (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_decisions_schedule_id ON irrigation_decisions (tenant_id, schedule_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_decisions_decided_at ON irrigation_decisions (tenant_id, decided_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_irrigation_decisions_applied ON irrigation_decisions (tenant_id, applied) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_irrigation_decisions_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_irrigation_decisions_set_updated_at
    BEFORE UPDATE ON irrigation_decisions
    FOR EACH ROW
    EXECUTE FUNCTION trg_irrigation_decisions_updated_at();

-- ============================================================================
-- Table: water_usage_logs
-- ============================================================================
CREATE TABLE IF NOT EXISTS water_usage_logs (
    id                          CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                   CHAR(26)        NOT NULL,

    -- relationships
    zone_id                     CHAR(26)        REFERENCES irrigation_zones(id),
    controller_id                CHAR(26)        REFERENCES water_controllers(id),

    -- usage data
    water_liters                DOUBLE PRECISION NOT NULL DEFAULT 0,
    recorded_at                 TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    period_start                TIMESTAMPTZ     NOT NULL,
    period_end                  TIMESTAMPTZ     NOT NULL,

    -- audit
    created_by                  CHAR(26),
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ
);

-- RLS
ALTER TABLE water_usage_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_usage_logs FORCE ROW LEVEL SECURITY;

CREATE POLICY water_usage_logs_select_policy ON water_usage_logs
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY water_usage_logs_insert_policy ON water_usage_logs
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY water_usage_logs_update_policy ON water_usage_logs
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY water_usage_logs_delete_policy ON water_usage_logs
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_water_usage_logs_tenant_id ON water_usage_logs (tenant_id);
CREATE INDEX idx_water_usage_logs_zone_id ON water_usage_logs (tenant_id, zone_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_water_usage_logs_controller_id ON water_usage_logs (tenant_id, controller_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_water_usage_logs_period ON water_usage_logs (tenant_id, zone_id, period_start, period_end) WHERE deleted_at IS NULL;
CREATE INDEX idx_water_usage_logs_recorded_at ON water_usage_logs (tenant_id, recorded_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_water_usage_logs_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_water_usage_logs_set_updated_at
    BEFORE UPDATE ON water_usage_logs
    FOR EACH ROW
    EXECUTE FUNCTION trg_water_usage_logs_updated_at();
