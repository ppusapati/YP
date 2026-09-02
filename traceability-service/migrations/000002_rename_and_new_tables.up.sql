-- ============================================================================
-- Traceability Service: Rename Tables to Match Adapter + New Tables (UP)
-- ============================================================================
-- The initial schema created trace_chains/trace_events, but the postgres
-- adapter (internal/adapters/outbound/postgres/traceability_repository.go)
-- queries traceability_records/supply_chain_events (with an event_timestamp
-- column) and four additional tables that never got a migration:
-- certifications, batch_records, qr_codes, compliance_reports.
-- ============================================================================

-- ============================================================================
-- Rename: trace_chains -> traceability_records
-- ============================================================================
ALTER TABLE trace_chains RENAME TO traceability_records;

ALTER POLICY trace_chains_select_policy ON traceability_records RENAME TO traceability_records_select_policy;
ALTER POLICY trace_chains_insert_policy ON traceability_records RENAME TO traceability_records_insert_policy;
ALTER POLICY trace_chains_update_policy ON traceability_records RENAME TO traceability_records_update_policy;
ALTER POLICY trace_chains_delete_policy ON traceability_records RENAME TO traceability_records_delete_policy;

ALTER INDEX idx_trace_chains_tenant_id RENAME TO idx_traceability_records_tenant_id;
ALTER INDEX idx_trace_chains_farm_id RENAME TO idx_traceability_records_farm_id;
ALTER INDEX idx_trace_chains_crop_id RENAME TO idx_traceability_records_crop_id;
ALTER INDEX idx_trace_chains_batch_number RENAME TO idx_traceability_records_batch_number;
ALTER INDEX idx_trace_chains_product_type RENAME TO idx_traceability_records_product_type;
ALTER INDEX idx_trace_chains_compliance_status RENAME TO idx_traceability_records_compliance_status;
ALTER INDEX idx_trace_chains_origin_country RENAME TO idx_traceability_records_origin_country;
ALTER INDEX idx_trace_chains_blockchain_hash RENAME TO idx_traceability_records_blockchain_hash;
ALTER INDEX idx_trace_chains_created_at RENAME TO idx_traceability_records_created_at;

ALTER FUNCTION trg_trace_chains_updated_at() RENAME TO trg_traceability_records_updated_at;
ALTER TRIGGER trg_trace_chains_set_updated_at ON traceability_records RENAME TO trg_traceability_records_set_updated_at;

-- ============================================================================
-- Rename: trace_events -> supply_chain_events (+ timestamp -> event_timestamp)
-- ============================================================================
ALTER TABLE trace_events RENAME TO supply_chain_events;
ALTER TABLE supply_chain_events RENAME COLUMN "timestamp" TO event_timestamp;

ALTER POLICY trace_events_select_policy ON supply_chain_events RENAME TO supply_chain_events_select_policy;
ALTER POLICY trace_events_insert_policy ON supply_chain_events RENAME TO supply_chain_events_insert_policy;
ALTER POLICY trace_events_update_policy ON supply_chain_events RENAME TO supply_chain_events_update_policy;
ALTER POLICY trace_events_delete_policy ON supply_chain_events RENAME TO supply_chain_events_delete_policy;

ALTER INDEX idx_trace_events_tenant_id RENAME TO idx_supply_chain_events_tenant_id;
ALTER INDEX idx_trace_events_record_id RENAME TO idx_supply_chain_events_record_id;
ALTER INDEX idx_trace_events_event_type RENAME TO idx_supply_chain_events_event_type;
ALTER INDEX idx_trace_events_timestamp RENAME TO idx_supply_chain_events_event_timestamp;

ALTER TABLE supply_chain_events RENAME CONSTRAINT fk_trace_events_record_id TO fk_supply_chain_events_record_id;

-- The adapter's CreateSupplyChainEvent never sets tenant_id (the domain
-- model has no TenantID field for events -- it's implied by the parent
-- record), so derive it from the parent traceability_records row on insert
-- to keep the NOT NULL constraint and RLS policies satisfied.
CREATE OR REPLACE FUNCTION trg_supply_chain_events_set_tenant() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tenant_id IS NULL THEN
        SELECT tenant_id INTO NEW.tenant_id FROM traceability_records WHERE id = NEW.record_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_supply_chain_events_set_tenant_before_insert
    BEFORE INSERT ON supply_chain_events
    FOR EACH ROW
    EXECUTE FUNCTION trg_supply_chain_events_set_tenant();

-- ============================================================================
-- Table: certifications
-- ============================================================================
CREATE TABLE IF NOT EXISTS certifications (
    id              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       CHAR(26)        NOT NULL,

    -- relationships
    record_id       CHAR(26)        NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,

    -- certification details
    cert_type       TEXT            NOT NULL DEFAULT 'CERTIFICATION_TYPE_UNSPECIFIED',
    cert_number     TEXT,
    issued_by       TEXT,
    issued_date     TIMESTAMPTZ,
    expiry_date     TIMESTAMPTZ,
    status          TEXT            NOT NULL DEFAULT 'PENDING',
    verified_by     TEXT,
    verified_at     TIMESTAMPTZ,

    -- metadata / versioning
    metadata        JSONB           DEFAULT '{}',
    version         BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

-- RLS
ALTER TABLE certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE certifications FORCE ROW LEVEL SECURITY;

CREATE POLICY certifications_select_policy ON certifications
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY certifications_insert_policy ON certifications
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY certifications_update_policy ON certifications
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY certifications_delete_policy ON certifications
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_certifications_tenant_id ON certifications (tenant_id);
CREATE INDEX idx_certifications_record_id ON certifications (tenant_id, record_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_certifications_cert_type ON certifications (tenant_id, cert_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_certifications_status ON certifications (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_certifications_created_at ON certifications (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_certifications_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_certifications_set_updated_at
    BEFORE UPDATE ON certifications
    FOR EACH ROW
    EXECUTE FUNCTION trg_certifications_updated_at();

-- ============================================================================
-- Table: batch_records
-- ============================================================================
CREATE TABLE IF NOT EXISTS batch_records (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    record_id           CHAR(26)        NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,

    -- batch details
    batch_number        TEXT,
    quantity             INTEGER,
    unit                 TEXT,
    production_date      TIMESTAMPTZ,
    expiry_date          TIMESTAMPTZ,
    storage_conditions   TEXT,
    quality_grade        TEXT,

    -- metadata / versioning
    metadata             JSONB           DEFAULT '{}',
    version               BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_at            TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at            TIMESTAMPTZ
);

-- RLS
ALTER TABLE batch_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_records FORCE ROW LEVEL SECURITY;

CREATE POLICY batch_records_select_policy ON batch_records
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY batch_records_insert_policy ON batch_records
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY batch_records_update_policy ON batch_records
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY batch_records_delete_policy ON batch_records
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_batch_records_tenant_id ON batch_records (tenant_id);
CREATE INDEX idx_batch_records_record_id ON batch_records (tenant_id, record_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_batch_records_batch_number ON batch_records (tenant_id, batch_number) WHERE deleted_at IS NULL AND batch_number IS NOT NULL;
CREATE INDEX idx_batch_records_created_at ON batch_records (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_batch_records_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_batch_records_set_updated_at
    BEFORE UPDATE ON batch_records
    FOR EACH ROW
    EXECUTE FUNCTION trg_batch_records_updated_at();

-- ============================================================================
-- Table: qr_codes
-- ============================================================================
CREATE TABLE IF NOT EXISTS qr_codes (
    id              CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       CHAR(26)        NOT NULL,

    -- relationships
    record_id       CHAR(26)        NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,
    batch_id        CHAR(26)        REFERENCES batch_records(id) ON DELETE SET NULL,

    -- QR code details
    qr_data         TEXT            NOT NULL,
    qr_image_url    TEXT,
    scan_url        TEXT,
    generated_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,

    -- audit
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT uq_qr_codes_qr_data UNIQUE (qr_data)
);

-- The adapter's CreateQRCode never sets tenant_id (the domain model has no
-- TenantID field for QR codes -- it's implied by the parent record), so
-- derive it from the parent traceability_records row on insert.
CREATE OR REPLACE FUNCTION trg_qr_codes_set_tenant() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tenant_id IS NULL THEN
        SELECT tenant_id INTO NEW.tenant_id FROM traceability_records WHERE id = NEW.record_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_qr_codes_set_tenant_before_insert
    BEFORE INSERT ON qr_codes
    FOR EACH ROW
    EXECUTE FUNCTION trg_qr_codes_set_tenant();

-- RLS
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_codes FORCE ROW LEVEL SECURITY;

CREATE POLICY qr_codes_select_policy ON qr_codes
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY qr_codes_insert_policy ON qr_codes
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY qr_codes_update_policy ON qr_codes
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY qr_codes_delete_policy ON qr_codes
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_qr_codes_tenant_id ON qr_codes (tenant_id);
CREATE INDEX idx_qr_codes_record_id ON qr_codes (tenant_id, record_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_qr_codes_batch_id ON qr_codes (tenant_id, batch_id) WHERE deleted_at IS NULL AND batch_id IS NOT NULL;
CREATE INDEX idx_qr_codes_generated_at ON qr_codes (tenant_id, generated_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_qr_codes_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_qr_codes_set_updated_at
    BEFORE UPDATE ON qr_codes
    FOR EACH ROW
    EXECUTE FUNCTION trg_qr_codes_updated_at();

-- ============================================================================
-- Table: compliance_reports
-- ============================================================================
CREATE TABLE IF NOT EXISTS compliance_reports (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    record_id           CHAR(26)        NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,

    -- report details
    status               TEXT            NOT NULL DEFAULT 'COMPLIANCE_STATUS_UNSPECIFIED',
    report_type          TEXT,
    findings              TEXT[],
    recommendations       TEXT[],
    auditor               TEXT,
    audit_date            TIMESTAMPTZ,
    next_audit_date       TIMESTAMPTZ,
    compliance_score      DOUBLE PRECISION,

    -- metadata
    metadata               JSONB           DEFAULT '{}',

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at               TIMESTAMPTZ
);

-- RLS
ALTER TABLE compliance_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE compliance_reports FORCE ROW LEVEL SECURITY;

CREATE POLICY compliance_reports_select_policy ON compliance_reports
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY compliance_reports_insert_policy ON compliance_reports
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY compliance_reports_update_policy ON compliance_reports
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY compliance_reports_delete_policy ON compliance_reports
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_compliance_reports_tenant_id ON compliance_reports (tenant_id);
CREATE INDEX idx_compliance_reports_record_id ON compliance_reports (tenant_id, record_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_compliance_reports_status ON compliance_reports (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_compliance_reports_created_at ON compliance_reports (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_compliance_reports_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compliance_reports_set_updated_at
    BEFORE UPDATE ON compliance_reports
    FOR EACH ROW
    EXECUTE FUNCTION trg_compliance_reports_updated_at();
