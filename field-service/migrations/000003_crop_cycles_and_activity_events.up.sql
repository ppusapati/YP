-- ============================================================================
-- Field Service: Crop Cycles and Activity Events
-- ============================================================================

-- ============================================================================
-- Table: crop_cycles
-- A season-level aggregate tying together a field's crop assignment, growth
-- stages, inputs, and yield into a single lifecycle record.
-- ============================================================================

CREATE TABLE IF NOT EXISTS crop_cycles (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    field_id                CHAR(26)        NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
    crop_id                 CHAR(26)        NOT NULL,
    crop_assignment_id      CHAR(26)        REFERENCES crop_assignments(id) ON DELETE SET NULL,

    -- cycle metadata
    season                  TEXT            NOT NULL,
    cycle_year              INTEGER         NOT NULL,
    name                    TEXT,

    -- dates
    planned_planting_date   TIMESTAMPTZ,
    actual_planting_date    TIMESTAMPTZ,
    planned_harvest_date    TIMESTAMPTZ,
    actual_harvest_date     TIMESTAMPTZ,

    -- status
    status                  TEXT            NOT NULL DEFAULT 'CYCLE_STATUS_PLANNED',

    -- yield
    target_yield_per_hectare    DOUBLE PRECISION,
    actual_yield_per_hectare    DOUBLE PRECISION,
    yield_unit                  TEXT,

    -- costs and revenue (in smallest currency unit)
    total_input_cost        BIGINT          DEFAULT 0,
    total_revenue           BIGINT          DEFAULT 0,
    currency                TEXT            DEFAULT 'INR',

    notes                   TEXT,

    -- versioning
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by              CHAR(26)        NOT NULL,
    updated_by              CHAR(26),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE crop_cycles ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_cycles FORCE ROW LEVEL SECURITY;

CREATE POLICY crop_cycles_select_policy ON crop_cycles
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY crop_cycles_insert_policy ON crop_cycles
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_cycles_update_policy ON crop_cycles
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_cycles_delete_policy ON crop_cycles
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_crop_cycles_tenant_id ON crop_cycles (tenant_id);
CREATE INDEX idx_crop_cycles_field_id ON crop_cycles (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_cycles_crop_id ON crop_cycles (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_cycles_season ON crop_cycles (tenant_id, season, cycle_year) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_cycles_status ON crop_cycles (tenant_id, status) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_crop_cycles_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crop_cycles_set_updated_at
    BEFORE UPDATE ON crop_cycles
    FOR EACH ROW
    EXECUTE FUNCTION trg_crop_cycles_updated_at();

-- ============================================================================
-- Table: activity_events
-- Immutable log of actions taken on a field: planting, spraying, irrigation,
-- fertilizing, harvesting, scouting, soil sampling, etc.
-- ============================================================================

CREATE TABLE IF NOT EXISTS activity_events (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    field_id            CHAR(26)        NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
    crop_cycle_id       CHAR(26)        REFERENCES crop_cycles(id) ON DELETE SET NULL,
    performed_by        CHAR(26)        NOT NULL,

    -- event classification
    activity_type       TEXT            NOT NULL,
    category            TEXT            NOT NULL DEFAULT 'CATEGORY_UNSPECIFIED',

    -- timing
    started_at          TIMESTAMPTZ     NOT NULL,
    completed_at        TIMESTAMPTZ,
    duration_minutes    INTEGER,

    -- details
    description         TEXT,
    notes               TEXT,
    metadata            JSONB           DEFAULT '{}',

    -- inputs used (e.g. fertilizer amount, spray volume)
    input_product_id    CHAR(26),
    input_quantity      DOUBLE PRECISION,
    input_unit          TEXT,
    input_cost          BIGINT          DEFAULT 0,
    currency            TEXT            DEFAULT 'INR',

    -- area covered
    area_hectares       DOUBLE PRECISION,

    -- weather at time of activity
    weather_temp_celsius    DOUBLE PRECISION,
    weather_humidity_pct    DOUBLE PRECISION,
    weather_wind_speed_kmh  DOUBLE PRECISION,
    weather_conditions      TEXT,

    -- audit (immutable — no updated_at, no soft delete)
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE activity_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_events FORCE ROW LEVEL SECURITY;

CREATE POLICY activity_events_select_policy ON activity_events
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY activity_events_insert_policy ON activity_events
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_activity_events_tenant_id ON activity_events (tenant_id);
CREATE INDEX idx_activity_events_field_id ON activity_events (tenant_id, field_id);
CREATE INDEX idx_activity_events_crop_cycle ON activity_events (tenant_id, crop_cycle_id) WHERE crop_cycle_id IS NOT NULL;
CREATE INDEX idx_activity_events_type ON activity_events (tenant_id, activity_type);
CREATE INDEX idx_activity_events_started_at ON activity_events (tenant_id, started_at DESC);
CREATE INDEX idx_activity_events_performed_by ON activity_events (tenant_id, performed_by);
