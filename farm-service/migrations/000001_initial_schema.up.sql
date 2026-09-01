-- ============================================================================
-- Farm Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: farms
-- ============================================================================
CREATE TABLE IF NOT EXISTS farms (
    id              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       CHAR(26)        NOT NULL,

    -- core fields
    name            TEXT            NOT NULL,
    description     TEXT,
    total_area_hectares DOUBLE PRECISION,

    -- location
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION,
    elevation_meters DOUBLE PRECISION,
    address         TEXT,
    region          TEXT,
    country         TEXT,

    -- classification
    farm_type       TEXT            NOT NULL DEFAULT 'FARM_TYPE_UNSPECIFIED',
    status          TEXT            NOT NULL DEFAULT 'FARM_STATUS_ACTIVE',
    soil_type       TEXT            NOT NULL DEFAULT 'SOIL_TYPE_UNSPECIFIED',
    climate_zone    TEXT            NOT NULL DEFAULT 'CLIMATE_ZONE_UNSPECIFIED',

    -- boundary (embedded from FarmBoundary)
    boundary_geojson    TEXT,
    boundary_area_hectares   DOUBLE PRECISION,
    boundary_perimeter_meters DOUBLE PRECISION,

    -- metadata / versioning
    metadata        JSONB           DEFAULT '{}',
    version         BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by      CHAR(26)        NOT NULL,
    updated_by      CHAR(26),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- RLS
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms FORCE ROW LEVEL SECURITY;

CREATE POLICY farms_select_policy ON farms
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY farms_insert_policy ON farms
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY farms_update_policy ON farms
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY farms_delete_policy ON farms
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_farms_tenant_id ON farms (tenant_id);
CREATE INDEX idx_farms_status ON farms (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_farms_farm_type ON farms (tenant_id, farm_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_farms_region ON farms (tenant_id, region) WHERE deleted_at IS NULL;
CREATE INDEX idx_farms_country ON farms (tenant_id, country) WHERE deleted_at IS NULL;
CREATE INDEX idx_farms_climate_zone ON farms (tenant_id, climate_zone) WHERE deleted_at IS NULL;
CREATE INDEX idx_farms_name ON farms (tenant_id, name) WHERE deleted_at IS NULL;
CREATE INDEX idx_farms_created_at ON farms (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_farms_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_farms_set_updated_at
    BEFORE UPDATE ON farms
    FOR EACH ROW
    EXECUTE FUNCTION trg_farms_updated_at();
