-- ============================================================================
-- Pest Prediction Service: Migration 000002 — pest_species, pest_observations, pest_risk_maps
-- ============================================================================

-- ============================================================================
-- Table: pest_species
-- ============================================================================
CREATE TABLE IF NOT EXISTS pest_species (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    common_name             TEXT            NOT NULL,
    scientific_name         TEXT,
    family                  TEXT,
    description             TEXT,
    affected_crops          TEXT[],
    favorable_conditions    TEXT[],
    image_url               TEXT,

    -- versioning
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE pest_species ENABLE ROW LEVEL SECURITY;
ALTER TABLE pest_species FORCE ROW LEVEL SECURITY;

CREATE POLICY pest_species_select_policy ON pest_species
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY pest_species_insert_policy ON pest_species
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_species_update_policy ON pest_species
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_species_delete_policy ON pest_species
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_pest_species_tenant_id ON pest_species (tenant_id);
CREATE INDEX idx_pest_species_common_name ON pest_species (tenant_id, common_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_species_scientific_name ON pest_species (tenant_id, scientific_name) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_pest_species_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pest_species_set_updated_at
    BEFORE UPDATE ON pest_species
    FOR EACH ROW
    EXECUTE FUNCTION trg_pest_species_updated_at();

-- ============================================================================
-- Table: pest_observations
-- ============================================================================
CREATE TABLE IF NOT EXISTS pest_observations (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    farm_id                 CHAR(26),
    field_id                CHAR(26),
    pest_species_id         CHAR(26),

    -- observation data
    pest_count              INTEGER,
    damage_level            TEXT            NOT NULL DEFAULT 'DAMAGE_LEVEL_UNSPECIFIED',
    trap_type               TEXT,
    image_url               TEXT,
    latitude                DOUBLE PRECISION,
    longitude               DOUBLE PRECISION,
    notes                   TEXT,
    observed_by             CHAR(26),
    observed_at             TIMESTAMPTZ,

    -- versioning
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE pest_observations ENABLE ROW LEVEL SECURITY;
ALTER TABLE pest_observations FORCE ROW LEVEL SECURITY;

CREATE POLICY pest_observations_select_policy ON pest_observations
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY pest_observations_insert_policy ON pest_observations
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_observations_update_policy ON pest_observations
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_observations_delete_policy ON pest_observations
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_pest_observations_tenant_id ON pest_observations (tenant_id);
CREATE INDEX idx_pest_observations_farm_id ON pest_observations (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_observations_field_id ON pest_observations (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_observations_pest_species_id ON pest_observations (tenant_id, pest_species_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_observations_observed_at ON pest_observations (tenant_id, observed_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_pest_observations_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pest_observations_set_updated_at
    BEFORE UPDATE ON pest_observations
    FOR EACH ROW
    EXECUTE FUNCTION trg_pest_observations_updated_at();

-- ============================================================================
-- Table: pest_risk_maps
-- ============================================================================
CREATE TABLE IF NOT EXISTS pest_risk_maps (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    pest_species_id         CHAR(26),
    region                  TEXT,
    overall_risk_level      TEXT            NOT NULL DEFAULT 'RISK_LEVEL_UNSPECIFIED',
    geojson                 TEXT,
    valid_from              TIMESTAMPTZ,
    valid_until             TIMESTAMPTZ,

    -- versioning
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE pest_risk_maps ENABLE ROW LEVEL SECURITY;
ALTER TABLE pest_risk_maps FORCE ROW LEVEL SECURITY;

CREATE POLICY pest_risk_maps_select_policy ON pest_risk_maps
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY pest_risk_maps_insert_policy ON pest_risk_maps
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_risk_maps_update_policy ON pest_risk_maps
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY pest_risk_maps_delete_policy ON pest_risk_maps
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_pest_risk_maps_tenant_id ON pest_risk_maps (tenant_id);
CREATE INDEX idx_pest_risk_maps_pest_species_id ON pest_risk_maps (tenant_id, pest_species_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_risk_maps_region ON pest_risk_maps (tenant_id, region) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_risk_maps_valid_range ON pest_risk_maps (tenant_id, valid_from, valid_until) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_pest_risk_maps_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pest_risk_maps_set_updated_at
    BEFORE UPDATE ON pest_risk_maps
    FOR EACH ROW
    EXECUTE FUNCTION trg_pest_risk_maps_updated_at();
