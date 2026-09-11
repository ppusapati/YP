-- ============================================================================
-- Agronomy Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: advisories
-- ============================================================================
CREATE TABLE IF NOT EXISTS advisories (
    id              CHAR(26)        PRIMARY KEY,
    tenant_id       CHAR(26)        NOT NULL,

    -- advisory content
    title           TEXT            NOT NULL,
    content         TEXT            NOT NULL,
    crop_type       TEXT            NOT NULL DEFAULT '',
    severity        TEXT            NOT NULL DEFAULT 'LOW',
    region          TEXT            NOT NULL DEFAULT '',

    -- relationships
    farm_id         CHAR(26)        NOT NULL DEFAULT '',
    field_id        CHAR(26)        NOT NULL DEFAULT '',
    created_by      CHAR(26)        NOT NULL DEFAULT '',

    -- audit
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE
);

-- RLS
ALTER TABLE advisories ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisories FORCE ROW LEVEL SECURITY;

CREATE POLICY advisories_select_policy ON advisories
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY advisories_insert_policy ON advisories
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY advisories_update_policy ON advisories
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY advisories_delete_policy ON advisories
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_advisories_tenant_id ON advisories (tenant_id);
CREATE INDEX idx_advisories_farm_id ON advisories (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_advisories_field_id ON advisories (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_advisories_crop_type ON advisories (tenant_id, crop_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_advisories_severity ON advisories (tenant_id, severity) WHERE deleted_at IS NULL;
CREATE INDEX idx_advisories_region ON advisories (tenant_id, region) WHERE deleted_at IS NULL;
CREATE INDEX idx_advisories_created_at ON advisories (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_advisories_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_advisories_set_updated_at
    BEFORE UPDATE ON advisories
    FOR EACH ROW
    EXECUTE FUNCTION trg_advisories_updated_at();

-- ============================================================================
-- Table: inspections
-- ============================================================================
CREATE TABLE IF NOT EXISTS inspections (
    id                  CHAR(26)            PRIMARY KEY,
    tenant_id           CHAR(26)            NOT NULL,

    -- relationships
    field_id            CHAR(26)            NOT NULL DEFAULT '',
    farm_id             CHAR(26)            NOT NULL DEFAULT '',
    inspector_id        CHAR(26)            NOT NULL DEFAULT '',

    -- inspection data
    status              TEXT                NOT NULL DEFAULT 'DRAFT',
    findings            TEXT                NOT NULL DEFAULT '',
    photos              TEXT[]              NOT NULL DEFAULT '{}',
    recommendations     TEXT[]              NOT NULL DEFAULT '{}',
    issues              JSONB               NOT NULL DEFAULT '[]',
    health_score        DOUBLE PRECISION    NOT NULL DEFAULT 0,
    notes               TEXT                NOT NULL DEFAULT '',
    inspection_date     TIMESTAMPTZ,

    -- audit
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    is_active           BOOLEAN             NOT NULL DEFAULT TRUE
);

-- RLS
ALTER TABLE inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspections FORCE ROW LEVEL SECURITY;

CREATE POLICY inspections_select_policy ON inspections
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY inspections_insert_policy ON inspections
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY inspections_update_policy ON inspections
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY inspections_delete_policy ON inspections
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_inspections_tenant_id ON inspections (tenant_id);
CREATE INDEX idx_inspections_farm_id ON inspections (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inspections_field_id ON inspections (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inspections_inspector_id ON inspections (tenant_id, inspector_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inspections_status ON inspections (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_inspections_created_at ON inspections (tenant_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_inspections_inspection_date ON inspections (tenant_id, inspection_date DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_inspections_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inspections_set_updated_at
    BEFORE UPDATE ON inspections
    FOR EACH ROW
    EXECUTE FUNCTION trg_inspections_updated_at();

-- ============================================================================
-- Table: outbox_events
-- ============================================================================
CREATE TABLE IF NOT EXISTS outbox_events (
    id          BIGSERIAL   PRIMARY KEY,
    topic       TEXT        NOT NULL,
    event_key   TEXT        NOT NULL,
    payload     BYTEA       NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_outbox_events_created_at ON outbox_events (created_at);
