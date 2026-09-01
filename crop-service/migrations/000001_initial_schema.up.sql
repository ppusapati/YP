-- ============================================================================
-- Crop Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: crops
-- ============================================================================
CREATE TABLE IF NOT EXISTS crops (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- core fields
    name                    TEXT            NOT NULL,
    scientific_name         TEXT,
    family                  TEXT,
    category                TEXT            NOT NULL DEFAULT 'CROP_CATEGORY_UNSPECIFIED',
    description             TEXT,
    image_url               TEXT,

    -- agronomic data
    disease_susceptibilities TEXT[],
    companion_plants        TEXT[],
    rotation_group          TEXT,

    -- versioning
    version                 INTEGER         NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE crops ENABLE ROW LEVEL SECURITY;
ALTER TABLE crops FORCE ROW LEVEL SECURITY;

CREATE POLICY crops_select_policy ON crops
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY crops_insert_policy ON crops
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crops_update_policy ON crops
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crops_delete_policy ON crops
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_crops_tenant_id ON crops (tenant_id);
CREATE INDEX idx_crops_category ON crops (tenant_id, category) WHERE deleted_at IS NULL;
CREATE INDEX idx_crops_name ON crops (tenant_id, name) WHERE deleted_at IS NULL;
CREATE INDEX idx_crops_scientific_name ON crops (tenant_id, scientific_name) WHERE deleted_at IS NULL AND scientific_name IS NOT NULL;
CREATE INDEX idx_crops_family ON crops (tenant_id, family) WHERE deleted_at IS NULL AND family IS NOT NULL;
CREATE INDEX idx_crops_rotation_group ON crops (tenant_id, rotation_group) WHERE deleted_at IS NULL AND rotation_group IS NOT NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_crops_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crops_set_updated_at
    BEFORE UPDATE ON crops
    FOR EACH ROW
    EXECUTE FUNCTION trg_crops_updated_at();

-- ============================================================================
-- Table: crop_varieties
-- ============================================================================
CREATE TABLE IF NOT EXISTS crop_varieties (
    id                              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                       CHAR(26)        NOT NULL,

    -- relationships
    crop_id                         CHAR(26)        NOT NULL REFERENCES crops(id) ON DELETE CASCADE,

    -- variety details
    name                            TEXT            NOT NULL,
    description                     TEXT,
    maturity_days                   INTEGER,
    yield_potential_kg_per_hectare  DOUBLE PRECISION,
    is_hybrid                       BOOLEAN         NOT NULL DEFAULT FALSE,
    disease_resistance              TEXT,
    suitable_regions                TEXT,
    seed_rate_kg_per_hectare        TEXT,

    -- audit
    created_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                      TIMESTAMPTZ
);

-- RLS
ALTER TABLE crop_varieties ENABLE ROW LEVEL SECURITY;
ALTER TABLE crop_varieties FORCE ROW LEVEL SECURITY;

CREATE POLICY crop_varieties_select_policy ON crop_varieties
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY crop_varieties_insert_policy ON crop_varieties
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_varieties_update_policy ON crop_varieties
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY crop_varieties_delete_policy ON crop_varieties
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_crop_varieties_tenant_id ON crop_varieties (tenant_id);
CREATE INDEX idx_crop_varieties_crop_id ON crop_varieties (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_varieties_name ON crop_varieties (tenant_id, name) WHERE deleted_at IS NULL;
CREATE INDEX idx_crop_varieties_is_hybrid ON crop_varieties (tenant_id, is_hybrid) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_crop_varieties_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_crop_varieties_set_updated_at
    BEFORE UPDATE ON crop_varieties
    FOR EACH ROW
    EXECUTE FUNCTION trg_crop_varieties_updated_at();
