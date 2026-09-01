-- ============================================================================
-- Farm Service: Management Units (zones / blocks within a farm)
-- ============================================================================

CREATE TABLE IF NOT EXISTS management_units (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    farm_id             CHAR(26)        NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    parent_unit_id      CHAR(26)        REFERENCES management_units(id) ON DELETE SET NULL,

    -- core
    name                TEXT            NOT NULL,
    description         TEXT,
    unit_type           TEXT            NOT NULL DEFAULT 'UNIT_TYPE_UNSPECIFIED',
    area_hectares       DOUBLE PRECISION,
    boundary_geojson    TEXT,

    -- operational
    manager_id          CHAR(26),
    status              TEXT            NOT NULL DEFAULT 'UNIT_STATUS_ACTIVE',

    -- versioning
    version             BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by          CHAR(26)        NOT NULL,
    updated_by          CHAR(26),
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE management_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE management_units FORCE ROW LEVEL SECURITY;

CREATE POLICY management_units_select_policy ON management_units
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY management_units_insert_policy ON management_units
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY management_units_update_policy ON management_units
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY management_units_delete_policy ON management_units
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_management_units_tenant_id ON management_units (tenant_id);
CREATE INDEX idx_management_units_farm_id ON management_units (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_management_units_parent ON management_units (tenant_id, parent_unit_id) WHERE deleted_at IS NULL AND parent_unit_id IS NOT NULL;
CREATE INDEX idx_management_units_type ON management_units (tenant_id, unit_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_management_units_name ON management_units (tenant_id, farm_id, name) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_management_units_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_management_units_set_updated_at
    BEFORE UPDATE ON management_units
    FOR EACH ROW
    EXECUTE FUNCTION trg_management_units_updated_at();

-- ============================================================================
-- Junction: management_unit_fields (assign fields to management units)
-- ============================================================================

CREATE TABLE IF NOT EXISTS management_unit_fields (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,
    management_unit_id  CHAR(26)        NOT NULL REFERENCES management_units(id) ON DELETE CASCADE,
    field_id            CHAR(26)        NOT NULL,

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    UNIQUE (management_unit_id, field_id)
);

ALTER TABLE management_unit_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE management_unit_fields FORCE ROW LEVEL SECURITY;

CREATE POLICY management_unit_fields_select_policy ON management_unit_fields
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY management_unit_fields_insert_policy ON management_unit_fields
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY management_unit_fields_delete_policy ON management_unit_fields
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE INDEX idx_mu_fields_unit ON management_unit_fields (management_unit_id);
CREATE INDEX idx_mu_fields_field ON management_unit_fields (field_id);
