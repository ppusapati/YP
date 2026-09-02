-- Quality checkpoints: discrete quality inspections at supply chain points.

CREATE TABLE IF NOT EXISTS quality_checkpoints (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,
    record_id               CHAR(26)        NOT NULL REFERENCES traceability_records(id) ON DELETE CASCADE,
    supply_chain_event_id   CHAR(26)        REFERENCES supply_chain_events(id) ON DELETE SET NULL,

    -- inspection details
    check_type              TEXT            NOT NULL DEFAULT 'OTHER',
    result                  TEXT            NOT NULL DEFAULT 'PASS',
    inspector_id            CHAR(26)        NOT NULL,
    inspector_name          TEXT            NOT NULL,
    inspected_at            TIMESTAMPTZ     NOT NULL,
    location                TEXT            NOT NULL DEFAULT '',

    -- measurements
    measurement_value       DOUBLE PRECISION,
    measurement_unit        TEXT,
    min_threshold           DOUBLE PRECISION,
    max_threshold           DOUBLE PRECISION,

    -- evidence & notes
    notes                   TEXT,
    evidence_urls           TEXT[]          DEFAULT '{}',
    metadata                JSONB           DEFAULT '{}',

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE quality_checkpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_checkpoints FORCE ROW LEVEL SECURITY;

CREATE POLICY quality_checkpoints_select_policy ON quality_checkpoints
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY quality_checkpoints_insert_policy ON quality_checkpoints
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY quality_checkpoints_delete_policy ON quality_checkpoints
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_quality_checkpoints_tenant ON quality_checkpoints (tenant_id);
CREATE INDEX idx_quality_checkpoints_record ON quality_checkpoints (tenant_id, record_id);
CREATE INDEX idx_quality_checkpoints_event ON quality_checkpoints (tenant_id, supply_chain_event_id) WHERE supply_chain_event_id IS NOT NULL;
CREATE INDEX idx_quality_checkpoints_type ON quality_checkpoints (tenant_id, check_type);
CREATE INDEX idx_quality_checkpoints_result ON quality_checkpoints (tenant_id, result);
