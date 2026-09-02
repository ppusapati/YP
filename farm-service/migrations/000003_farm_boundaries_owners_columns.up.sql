-- ============================================================================
-- Farm Service: Farm Boundaries, Farm Owners, and missing farms columns (UP)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- farms: add columns the postgres adapter relies on
-- ----------------------------------------------------------------------------
ALTER TABLE farms ADD COLUMN IF NOT EXISTS is_active  BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE farms ADD COLUMN IF NOT EXISTS deleted_by CHAR(26);

CREATE INDEX IF NOT EXISTS idx_farms_is_active ON farms (tenant_id, is_active) WHERE deleted_at IS NULL;

-- ============================================================================
-- Table: farm_boundaries
-- ============================================================================
CREATE TABLE IF NOT EXISTS farm_boundaries (
    id              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       CHAR(26)        NOT NULL,

    -- relationship (farms.id IS the farm's UUID — no separate farm_uuid column)
    farm_id         CHAR(26)        NOT NULL REFERENCES farms(id) ON DELETE CASCADE,

    -- boundary data
    geojson              TEXT            NOT NULL,
    area_hectares        DOUBLE PRECISION,
    perimeter_meters     DOUBLE PRECISION,

    -- lifecycle
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_by      CHAR(26)        NOT NULL,
    updated_by      CHAR(26),
    deleted_by      CHAR(26),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- RLS
ALTER TABLE farm_boundaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_boundaries FORCE ROW LEVEL SECURITY;

CREATE POLICY farm_boundaries_select_policy ON farm_boundaries
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY farm_boundaries_insert_policy ON farm_boundaries
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY farm_boundaries_update_policy ON farm_boundaries
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY farm_boundaries_delete_policy ON farm_boundaries
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_farm_boundaries_tenant_id ON farm_boundaries (tenant_id);
-- One active boundary per farm.
CREATE UNIQUE INDEX idx_farm_boundaries_farm_id ON farm_boundaries (farm_id) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_farm_boundaries_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_farm_boundaries_set_updated_at
    BEFORE UPDATE ON farm_boundaries
    FOR EACH ROW
    EXECUTE FUNCTION trg_farm_boundaries_updated_at();

-- ============================================================================
-- Table: farm_owners
-- ============================================================================
CREATE TABLE IF NOT EXISTS farm_owners (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationship (farms.id IS the farm's UUID — no separate farm_uuid column)
    farm_id             CHAR(26)        NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    user_id             CHAR(26)        NOT NULL,

    -- ownership details
    owner_name          TEXT            NOT NULL,
    email               TEXT,
    phone               TEXT,
    is_primary          BOOLEAN         NOT NULL DEFAULT FALSE,
    ownership_percentage DOUBLE PRECISION NOT NULL DEFAULT 0,
    acquired_at         TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- lifecycle
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_by          CHAR(26)        NOT NULL,
    updated_by          CHAR(26),
    deleted_by          CHAR(26),
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE farm_owners ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_owners FORCE ROW LEVEL SECURITY;

CREATE POLICY farm_owners_select_policy ON farm_owners
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY farm_owners_insert_policy ON farm_owners
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY farm_owners_update_policy ON farm_owners
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY farm_owners_delete_policy ON farm_owners
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_farm_owners_tenant_id ON farm_owners (tenant_id);
CREATE INDEX idx_farm_owners_farm_id ON farm_owners (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_farm_owners_user_id ON farm_owners (tenant_id, user_id) WHERE deleted_at IS NULL;
-- One active primary owner per farm.
CREATE UNIQUE INDEX idx_farm_owners_unique_primary ON farm_owners (farm_id) WHERE is_primary = TRUE AND is_active = TRUE AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_farm_owners_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_farm_owners_set_updated_at
    BEFORE UPDATE ON farm_owners
    FOR EACH ROW
    EXECUTE FUNCTION trg_farm_owners_updated_at();
