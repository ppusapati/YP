-- ============================================================================
-- Sustainability Service: Initial Schema Migration (UP)
-- ============================================================================

CREATE TABLE IF NOT EXISTS input_uses (
    id                CHAR(26)         PRIMARY KEY,
    tenant_id         CHAR(26)         NOT NULL,
    field_id          CHAR(26)         NOT NULL,
    crop              TEXT             NOT NULL DEFAULT '',
    year              INTEGER          NOT NULL,

    category          TEXT             NOT NULL,
    product           TEXT             NOT NULL DEFAULT '',
    quantity          DOUBLE PRECISION NOT NULL,
    unit              TEXT             NOT NULL DEFAULT 'kg',

    -- Nitrogen delivered, in kg. NULL means "not known", which is not the same
    -- as zero: an unknown nitrogen figure blocks a nutrient budget, while a
    -- zero one would quietly understate the N2O line.
    nitrogen_kg       DOUBLE PRECISION,

    applied_on        TIMESTAMPTZ,
    applied_by        TEXT             NOT NULL DEFAULT '',
    notes             TEXT             NOT NULL DEFAULT '',

    -- Judged against the standards in force on the day of application and
    -- stored, not recomputed on read. The permitted lists change, and a
    -- certificate has to be defensible against the rules that applied then.
    organic_permitted BOOLEAN          NOT NULL DEFAULT TRUE,

    created_at        TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_input_uses_quantity CHECK (quantity > 0),
    CONSTRAINT chk_input_uses_year CHECK (year BETWEEN 2000 AND 2100)
);

-- The certification check walks a field's whole history in date order, and the
-- footprint reads one field-year. Both are covered here.
CREATE INDEX IF NOT EXISTS idx_input_uses_field_date
    ON input_uses (tenant_id, field_id, applied_on);
CREATE INDEX IF NOT EXISTS idx_input_uses_field_year
    ON input_uses (tenant_id, field_id, year);

CREATE TABLE IF NOT EXISTS footprints (
    id                  CHAR(26)         PRIMARY KEY,
    tenant_id           CHAR(26)         NOT NULL,
    field_id            CHAR(26)         NOT NULL,
    farm_id             CHAR(26)         NOT NULL DEFAULT '',
    crop                TEXT             NOT NULL DEFAULT '',
    year                INTEGER          NOT NULL,

    area_hectares       DOUBLE PRECISION NOT NULL,
    water_regime        TEXT             NOT NULL DEFAULT '',

    -- The per-source breakdown as it was computed, including each line's
    -- completeness. Stored rather than recomputed on read: the emission
    -- factors are revised between IPCC reports, and a footprint that was
    -- reported to a buyer has to keep saying what it said.
    lines               JSONB            NOT NULL DEFAULT '[]',
    missing_sources     JSONB            NOT NULL DEFAULT '[]',

    total_kg_co2e       DOUBLE PRECISION NOT NULL DEFAULT 0,
    kg_co2e_per_hectare DOUBLE PRECISION NOT NULL DEFAULT 0,
    kg_co2e_per_tonne   DOUBLE PRECISION NOT NULL DEFAULT 0,
    yield_tonnes        DOUBLE PRECISION NOT NULL DEFAULT 0,

    -- False when any source had no activity data behind it. The figure is then
    -- a floor, not a total, and every surface that shows it has to show this.
    complete            BOOLEAN          NOT NULL DEFAULT FALSE,

    computed_at         TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    method              TEXT             NOT NULL DEFAULT '',

    -- One current footprint per field per year. Recomputing replaces it, which
    -- is what keeps a field from carrying three different answers for 2026.
    CONSTRAINT uq_footprints UNIQUE (tenant_id, field_id, year),
    CONSTRAINT chk_footprints_area CHECK (area_hectares > 0)
);

CREATE INDEX IF NOT EXISTS idx_footprints_farm
    ON footprints (tenant_id, farm_id, year DESC);

ALTER TABLE input_uses ENABLE ROW LEVEL SECURITY;
ALTER TABLE input_uses FORCE ROW LEVEL SECURITY;
CREATE POLICY input_uses_tenant_policy ON input_uses
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

ALTER TABLE footprints ENABLE ROW LEVEL SECURITY;
ALTER TABLE footprints FORCE ROW LEVEL SECURITY;
CREATE POLICY footprints_tenant_policy ON footprints
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
