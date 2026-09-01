-- ============================================================================
-- Traceability Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: trace_events (supply chain events)
-- ============================================================================
CREATE TABLE IF NOT EXISTS trace_events (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    record_id           CHAR(26)        NOT NULL,

    -- event details
    event_type          TEXT            NOT NULL DEFAULT 'SUPPLY_CHAIN_EVENT_TYPE_UNSPECIFIED',
    timestamp           TIMESTAMPTZ     NOT NULL,
    location            TEXT,
    actor               TEXT,
    details             TEXT,
    verification_hash   TEXT,

    -- audit
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE trace_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE trace_events FORCE ROW LEVEL SECURITY;

CREATE POLICY trace_events_select_policy ON trace_events
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY trace_events_insert_policy ON trace_events
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY trace_events_update_policy ON trace_events
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY trace_events_delete_policy ON trace_events
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_trace_events_tenant_id ON trace_events (tenant_id);
CREATE INDEX idx_trace_events_record_id ON trace_events (tenant_id, record_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_trace_events_event_type ON trace_events (tenant_id, event_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_trace_events_timestamp ON trace_events (tenant_id, timestamp DESC) WHERE deleted_at IS NULL;

-- ============================================================================
-- Table: trace_chains (traceability records - seed to shelf)
-- ============================================================================
CREATE TABLE IF NOT EXISTS trace_chains (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    farm_id                 CHAR(26),
    field_id                CHAR(26),
    crop_id                 CHAR(26),

    -- product identification
    batch_number            TEXT,
    product_type            TEXT,

    -- origin
    origin_country          TEXT,
    origin_region           TEXT,
    seed_source             TEXT,

    -- lifecycle dates
    planting_date           TIMESTAMPTZ,
    harvest_date            TIMESTAMPTZ,
    processing_date         TIMESTAMPTZ,
    packaging_date          TIMESTAMPTZ,

    -- traceability
    qr_code_data            TEXT,
    blockchain_hash         TEXT,
    chain_of_custody        TEXT[],
    compliance_status       TEXT            NOT NULL DEFAULT 'COMPLIANCE_STATUS_UNSPECIFIED',

    -- metadata / versioning
    metadata                JSONB           DEFAULT '{}',
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by              CHAR(26),
    updated_by              CHAR(26),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE trace_chains ENABLE ROW LEVEL SECURITY;
ALTER TABLE trace_chains FORCE ROW LEVEL SECURITY;

CREATE POLICY trace_chains_select_policy ON trace_chains
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY trace_chains_insert_policy ON trace_chains
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY trace_chains_update_policy ON trace_chains
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY trace_chains_delete_policy ON trace_chains
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_trace_chains_tenant_id ON trace_chains (tenant_id);
CREATE INDEX idx_trace_chains_farm_id ON trace_chains (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_trace_chains_crop_id ON trace_chains (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_trace_chains_batch_number ON trace_chains (tenant_id, batch_number) WHERE deleted_at IS NULL AND batch_number IS NOT NULL;
CREATE INDEX idx_trace_chains_product_type ON trace_chains (tenant_id, product_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_trace_chains_compliance_status ON trace_chains (tenant_id, compliance_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_trace_chains_origin_country ON trace_chains (tenant_id, origin_country) WHERE deleted_at IS NULL;
CREATE INDEX idx_trace_chains_blockchain_hash ON trace_chains (blockchain_hash) WHERE deleted_at IS NULL AND blockchain_hash IS NOT NULL;
CREATE INDEX idx_trace_chains_created_at ON trace_chains (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_trace_chains_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trace_chains_set_updated_at
    BEFORE UPDATE ON trace_chains
    FOR EACH ROW
    EXECUTE FUNCTION trg_trace_chains_updated_at();

-- Add FK from trace_events to trace_chains now that both tables exist
ALTER TABLE trace_events
    ADD CONSTRAINT fk_trace_events_record_id
    FOREIGN KEY (record_id) REFERENCES trace_chains(id) ON DELETE CASCADE;
