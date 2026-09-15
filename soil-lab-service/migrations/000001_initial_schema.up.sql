-- ============================================================================
-- Soil Lab Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Table: labs
-- ============================================================================
CREATE TABLE IF NOT EXISTS labs (
    id             CHAR(26)    PRIMARY KEY,
    tenant_id      CHAR(26)    NOT NULL,
    name           TEXT        NOT NULL,
    accreditation  TEXT        NOT NULL DEFAULT '',
    contact_email  TEXT        NOT NULL DEFAULT '',

    -- Every lab names its columns differently — "Avail. P (kg/ha)", "P2O5",
    -- "Phosphorus". Storing the mapping means nobody has to rename headers
    -- before each upload, which is the step somebody eventually gets wrong.
    column_aliases JSONB       NOT NULL DEFAULT '{}',

    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_labs_tenant_name UNIQUE (tenant_id, name)
);

ALTER TABLE labs ENABLE ROW LEVEL SECURITY;
ALTER TABLE labs FORCE ROW LEVEL SECURITY;

CREATE POLICY labs_tenant_policy ON labs
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: lab_reports
--
-- The parsed rows live in JSONB rather than a child table. They are read as a
-- unit — a person reviewing an import wants the whole file — and never queried
-- across reports, so a second table would buy joins and nothing else.
-- ============================================================================
CREATE TABLE IF NOT EXISTS lab_reports (
    id               CHAR(26)    PRIMARY KEY,
    tenant_id        CHAR(26)    NOT NULL,
    lab_id           CHAR(26)    NOT NULL,
    lab_name         TEXT        NOT NULL DEFAULT '',

    format           TEXT        NOT NULL,
    filename         TEXT        NOT NULL DEFAULT '',
    storage_url      TEXT        NOT NULL DEFAULT '',

    -- Keyed on the bytes, not the filename: the same results get re-sent as
    -- "results.csv", "results (1).csv" and "results-final.csv", and three sets
    -- of soil samples from one set of readings would triple a field's history.
    content_sha256   TEXT        NOT NULL,

    status           TEXT        NOT NULL DEFAULT 'RECEIVED',

    row_count        INTEGER     NOT NULL DEFAULT 0,
    applied_count    INTEGER     NOT NULL DEFAULT 0,
    blocked_count    INTEGER     NOT NULL DEFAULT 0,

    rows             JSONB       NOT NULL DEFAULT '[]',

    uploaded_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    applied_at       TIMESTAMPTZ,
    uploaded_by      TEXT        NOT NULL DEFAULT 'system',
    rejection_reason TEXT        NOT NULL DEFAULT '',

    CONSTRAINT uq_lab_reports_content UNIQUE (tenant_id, content_sha256)
);

CREATE INDEX IF NOT EXISTS idx_lab_reports_lab
    ON lab_reports (tenant_id, lab_id, uploaded_at DESC);
-- Partial: the review queue is the common read, and it is a small slice of a
-- long history.
CREATE INDEX IF NOT EXISTS idx_lab_reports_review
    ON lab_reports (tenant_id, status) WHERE status = 'NEEDS_REVIEW';

ALTER TABLE lab_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE lab_reports FORCE ROW LEVEL SECURITY;

CREATE POLICY lab_reports_tenant_policy ON lab_reports
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
