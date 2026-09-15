-- ============================================================================
-- Finance Service: Initial Schema Migration (UP)
-- ============================================================================

CREATE TABLE IF NOT EXISTS insurance_quotes (
    id                      CHAR(26)         PRIMARY KEY,
    tenant_id               CHAR(26)         NOT NULL,
    field_id                CHAR(26)         NOT NULL,
    farm_id                 CHAR(26)         NOT NULL DEFAULT '',

    crop                    TEXT             NOT NULL,
    category                TEXT             NOT NULL DEFAULT '',
    season                  TEXT             NOT NULL DEFAULT '',
    year                    INTEGER          NOT NULL,

    area_hectares           DOUBLE PRECISION NOT NULL,
    sum_insured_per_hectare DOUBLE PRECISION NOT NULL,
    total_sum_insured       DOUBLE PRECISION NOT NULL,

    indemnity_level         DOUBLE PRECISION NOT NULL,
    threshold_yield_kg_ha   DOUBLE PRECISION NOT NULL DEFAULT 0,

    -- The premium breakdown as it was priced. Stored rather than recomputed:
    -- a quote is an offer, and an offer that silently reprices when the
    -- emission factors or the yield history move is not an offer.
    lines                   JSONB            NOT NULL DEFAULT '[]',

    actuarial_premium       DOUBLE PRECISION NOT NULL DEFAULT 0,
    actuarial_rate          DOUBLE PRECISION NOT NULL DEFAULT 0,
    farmer_premium          DOUBLE PRECISION NOT NULL DEFAULT 0,
    subsidy                 DOUBLE PRECISION NOT NULL DEFAULT 0,

    -- Whether the rate came from this field's own record or from a crop
    -- benchmark. Persisted so no screen can show the price without it.
    confidence              TEXT             NOT NULL DEFAULT '',
    history_seasons         INTEGER          NOT NULL DEFAULT 0,
    basis                   TEXT             NOT NULL DEFAULT '',

    quoted_at               TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    expires_at              TIMESTAMPTZ      NOT NULL,

    CONSTRAINT chk_quotes_area CHECK (area_hectares > 0),
    CONSTRAINT chk_quotes_year CHECK (year BETWEEN 2000 AND 2100)
);

CREATE INDEX IF NOT EXISTS idx_quotes_field ON insurance_quotes (tenant_id, field_id, year DESC);
CREATE INDEX IF NOT EXISTS idx_quotes_farm  ON insurance_quotes (tenant_id, farm_id, year DESC);

CREATE TABLE IF NOT EXISTS credit_assessments (
    id                      CHAR(26)         PRIMARY KEY,
    tenant_id               CHAR(26)         NOT NULL,
    farm_id                 CHAR(26)         NOT NULL,

    status                  TEXT             NOT NULL,
    -- Zero when the status is INSUFFICIENT_HISTORY. A thin file must not be
    -- stored as a low score, because a low score is what a bad file looks like.
    score                   INTEGER          NOT NULL DEFAULT 0,
    band                    TEXT             NOT NULL DEFAULT '',

    -- Every factor with its own points, kept so an assessment can be taken
    -- apart months later. A credit reading nobody can contest is the kind that
    -- excludes people for reasons nobody can name.
    factors                 JSONB            NOT NULL DEFAULT '[]',

    seasons_considered      INTEGER          NOT NULL DEFAULT 0,
    mean_yield_kg_ha        DOUBLE PRECISION NOT NULL DEFAULT 0,
    yield_variability       DOUBLE PRECISION NOT NULL DEFAULT 0,
    mean_profit_per_hectare DOUBLE PRECISION NOT NULL DEFAULT 0,
    indicative_limit        DOUBLE PRECISION NOT NULL DEFAULT 0,

    caveat                  TEXT             NOT NULL DEFAULT '',
    assessed_at             TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_credit_farm ON credit_assessments (tenant_id, farm_id, assessed_at DESC);

CREATE TABLE IF NOT EXISTS claims (
    id                     CHAR(26)         PRIMARY KEY,
    tenant_id              CHAR(26)         NOT NULL,
    quote_id               CHAR(26)         NOT NULL,
    field_id               CHAR(26)         NOT NULL,
    farm_id                CHAR(26)         NOT NULL DEFAULT '',
    crop                   TEXT             NOT NULL DEFAULT '',
    season                 TEXT             NOT NULL DEFAULT '',
    year                   INTEGER          NOT NULL DEFAULT 0,

    cause                  TEXT             NOT NULL,
    loss_started_on        TIMESTAMPTZ      NOT NULL,
    loss_ended_on          TIMESTAMPTZ,
    description            TEXT             NOT NULL DEFAULT '',

    status                 TEXT             NOT NULL DEFAULT 'DRAFT',

    claimed_area_hectares  DOUBLE PRECISION NOT NULL,
    reported_yield_kg_ha   DOUBLE PRECISION NOT NULL DEFAULT 0,
    -- Copied from the quote at filing time. The policy was written on this
    -- figure, and re-reading it from a quote that was later re-priced would
    -- assess the claim against terms nobody agreed to.
    threshold_yield_kg_ha  DOUBLE PRECISION NOT NULL DEFAULT 0,
    indicated_payout       DOUBLE PRECISION NOT NULL DEFAULT 0,

    evidence               JSONB            NOT NULL DEFAULT '[]',
    evidence_summary       TEXT             NOT NULL DEFAULT '',

    submitted_by           TEXT             NOT NULL DEFAULT '',
    submitted_at           TIMESTAMPTZ,
    created_at             TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    version                BIGINT           NOT NULL DEFAULT 1,

    CONSTRAINT chk_claims_area CHECK (claimed_area_hectares > 0)
);

CREATE INDEX IF NOT EXISTS idx_claims_field ON claims (tenant_id, field_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_claims_farm  ON claims (tenant_id, farm_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_claims_quote ON claims (tenant_id, quote_id);

ALTER TABLE insurance_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_quotes FORCE ROW LEVEL SECURITY;
CREATE POLICY insurance_quotes_tenant_policy ON insurance_quotes
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

ALTER TABLE credit_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_assessments FORCE ROW LEVEL SECURITY;
CREATE POLICY credit_assessments_tenant_policy ON credit_assessments
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

ALTER TABLE claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE claims FORCE ROW LEVEL SECURITY;
CREATE POLICY claims_tenant_policy ON claims
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
