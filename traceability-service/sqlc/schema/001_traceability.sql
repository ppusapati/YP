-- Traceability Records: main table tracking produce from seed to shelf
CREATE TABLE IF NOT EXISTS traceability_records (
    id              TEXT PRIMARY KEY,
    tenant_id       TEXT NOT NULL,
    farm_id         TEXT NOT NULL,
    field_id        TEXT NOT NULL DEFAULT '',
    crop_id         TEXT NOT NULL DEFAULT '',
    batch_number    TEXT NOT NULL DEFAULT '',
    product_type    TEXT NOT NULL DEFAULT '',
    origin_country  TEXT NOT NULL DEFAULT '',
    origin_region   TEXT NOT NULL DEFAULT '',
    seed_source     TEXT NOT NULL DEFAULT '',
    planting_date   TIMESTAMPTZ,
    harvest_date    TIMESTAMPTZ,
    processing_date TIMESTAMPTZ,
    packaging_date  TIMESTAMPTZ,
    qr_code_data    TEXT NOT NULL DEFAULT '',
    blockchain_hash TEXT NOT NULL DEFAULT '',
    chain_of_custody TEXT[] NOT NULL DEFAULT '{}',
    compliance_status TEXT NOT NULL DEFAULT 'PENDING_REVIEW',
    metadata        JSONB NOT NULL DEFAULT '{}',
    version         BIGINT NOT NULL DEFAULT 1,
    created_by      TEXT NOT NULL DEFAULT '',
    updated_by      TEXT NOT NULL DEFAULT '',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_traceability_records_tenant ON traceability_records (tenant_id);
CREATE INDEX IF NOT EXISTS idx_traceability_records_farm ON traceability_records (tenant_id, farm_id);
CREATE INDEX IF NOT EXISTS idx_traceability_records_crop ON traceability_records (tenant_id, crop_id);
CREATE INDEX IF NOT EXISTS idx_traceability_records_batch ON traceability_records (tenant_id, batch_number);
CREATE INDEX IF NOT EXISTS idx_traceability_records_compliance ON traceability_records (tenant_id, compliance_status);
CREATE INDEX IF NOT EXISTS idx_traceability_records_product_type ON traceability_records (tenant_id, product_type);
CREATE INDEX IF NOT EXISTS idx_traceability_records_origin ON traceability_records (tenant_id, origin_country);

-- Supply Chain Events: individual events in the product lifecycle
CREATE TABLE IF NOT EXISTS supply_chain_events (
    id                TEXT PRIMARY KEY,
    record_id         TEXT NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,
    event_type        TEXT NOT NULL,
    event_timestamp   TIMESTAMPTZ NOT NULL,
    location          TEXT NOT NULL DEFAULT '',
    actor             TEXT NOT NULL DEFAULT '',
    details           TEXT NOT NULL DEFAULT '',
    verification_hash TEXT NOT NULL DEFAULT '',
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_supply_chain_events_record ON supply_chain_events (record_id);
CREATE INDEX IF NOT EXISTS idx_supply_chain_events_type ON supply_chain_events (record_id, event_type);
CREATE INDEX IF NOT EXISTS idx_supply_chain_events_timestamp ON supply_chain_events (record_id, event_timestamp);

-- Certifications: organic, fair-trade and other certifications
CREATE TABLE IF NOT EXISTS certifications (
    id          TEXT PRIMARY KEY,
    tenant_id   TEXT NOT NULL,
    record_id   TEXT NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,
    cert_type   TEXT NOT NULL,
    cert_number TEXT NOT NULL DEFAULT '',
    issued_by   TEXT NOT NULL DEFAULT '',
    issued_date TIMESTAMPTZ,
    expiry_date TIMESTAMPTZ,
    status      TEXT NOT NULL DEFAULT 'PENDING',
    verified_by TEXT NOT NULL DEFAULT '',
    verified_at TIMESTAMPTZ,
    metadata    JSONB NOT NULL DEFAULT '{}',
    version     BIGINT NOT NULL DEFAULT 1,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_certifications_tenant ON certifications (tenant_id);
CREATE INDEX IF NOT EXISTS idx_certifications_record ON certifications (record_id);
CREATE INDEX IF NOT EXISTS idx_certifications_type ON certifications (tenant_id, cert_type);
CREATE INDEX IF NOT EXISTS idx_certifications_status ON certifications (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_certifications_number ON certifications (tenant_id, cert_number);

-- Batch Records: batch-level tracking for groups of products
CREATE TABLE IF NOT EXISTS batch_records (
    id                  TEXT PRIMARY KEY,
    tenant_id           TEXT NOT NULL,
    record_id           TEXT NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,
    batch_number        TEXT NOT NULL,
    quantity            INTEGER NOT NULL DEFAULT 0,
    unit                TEXT NOT NULL DEFAULT '',
    production_date     TIMESTAMPTZ,
    expiry_date         TIMESTAMPTZ,
    storage_conditions  TEXT NOT NULL DEFAULT '',
    quality_grade       TEXT NOT NULL DEFAULT '',
    metadata            JSONB NOT NULL DEFAULT '{}',
    version             BIGINT NOT NULL DEFAULT 1,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_batch_records_tenant ON batch_records (tenant_id);
CREATE INDEX IF NOT EXISTS idx_batch_records_record ON batch_records (record_id);
CREATE INDEX IF NOT EXISTS idx_batch_records_number ON batch_records (tenant_id, batch_number);

-- QR Codes: generated QR codes for product scanning
CREATE TABLE IF NOT EXISTS qr_codes (
    id           TEXT PRIMARY KEY,
    record_id    TEXT NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,
    batch_id     TEXT NOT NULL DEFAULT '',
    qr_data      TEXT NOT NULL,
    qr_image_url TEXT NOT NULL DEFAULT '',
    scan_url     TEXT NOT NULL DEFAULT '',
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at   TIMESTAMPTZ,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_qr_codes_record ON qr_codes (record_id);
CREATE INDEX IF NOT EXISTS idx_qr_codes_batch ON qr_codes (batch_id);
CREATE INDEX IF NOT EXISTS idx_qr_codes_data ON qr_codes (qr_data);

-- Compliance Reports: audit and compliance reporting
CREATE TABLE IF NOT EXISTS compliance_reports (
    id              TEXT PRIMARY KEY,
    tenant_id       TEXT NOT NULL,
    record_id       TEXT NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,
    status          TEXT NOT NULL DEFAULT 'PENDING_REVIEW',
    report_type     TEXT NOT NULL DEFAULT '',
    findings        TEXT[] NOT NULL DEFAULT '{}',
    recommendations TEXT[] NOT NULL DEFAULT '{}',
    auditor         TEXT NOT NULL DEFAULT '',
    audit_date      TIMESTAMPTZ,
    next_audit_date TIMESTAMPTZ,
    compliance_score DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    metadata        JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_compliance_reports_tenant ON compliance_reports (tenant_id);
CREATE INDEX IF NOT EXISTS idx_compliance_reports_record ON compliance_reports (record_id);
CREATE INDEX IF NOT EXISTS idx_compliance_reports_status ON compliance_reports (tenant_id, status);
