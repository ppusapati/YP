-- ============================================================================
-- Planning Service: Initial Schema Migration (UP)
-- ============================================================================

CREATE TABLE IF NOT EXISTS season_plans (
    id                     CHAR(26)         PRIMARY KEY,
    tenant_id              CHAR(26)         NOT NULL,
    field_id               CHAR(26)         NOT NULL,
    farm_id                CHAR(26)         NOT NULL DEFAULT '',

    season                 TEXT             NOT NULL,
    year                   INTEGER          NOT NULL,

    crop                   TEXT             NOT NULL,
    variety                TEXT             NOT NULL DEFAULT '',
    area_hectares          DOUBLE PRECISION NOT NULL,

    status                 TEXT             NOT NULL DEFAULT 'DRAFT',

    -- The window, the rotation verdict and the budget are computed together
    -- when a plan is created and are what the plan *is*. Stored as written
    -- rather than recomputed on read: the crop calendar and the input prices
    -- both move, and a committed plan has to keep saying what it said when
    -- the seed was ordered against it.
    sowing_window          JSONB            NOT NULL DEFAULT '{}',
    rotation_check         JSONB            NOT NULL DEFAULT '{}',
    budget                 JSONB            NOT NULL DEFAULT '{}',

    target_yield_tonnes_ha DOUBLE PRECISION NOT NULL DEFAULT 0,
    notes                  TEXT             NOT NULL DEFAULT '',

    created_by             TEXT             NOT NULL DEFAULT 'system',
    created_at             TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    version                BIGINT           NOT NULL DEFAULT 1,

    -- One plan per field per season. Two plans for the same ground in the same
    -- months is a double-booking of seed, labour and water that nothing
    -- downstream would catch.
    CONSTRAINT uq_season_plans UNIQUE (tenant_id, field_id, season, year),
    CONSTRAINT chk_season_plans_area CHECK (area_hectares > 0),
    CONSTRAINT chk_season_plans_year CHECK (year BETWEEN 2000 AND 2100)
);

CREATE INDEX IF NOT EXISTS idx_season_plans_farm
    ON season_plans (tenant_id, farm_id, year DESC, season);
CREATE INDEX IF NOT EXISTS idx_season_plans_field_history
    ON season_plans (tenant_id, field_id, year DESC);

ALTER TABLE season_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE season_plans FORCE ROW LEVEL SECURITY;

CREATE POLICY season_plans_tenant_policy ON season_plans
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
