-- Activity evidence: photos, documents, and other attachments linked to activity events.

CREATE TABLE IF NOT EXISTS activity_evidence (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,
    activity_event_id   CHAR(26)        NOT NULL REFERENCES activity_events(id) ON DELETE CASCADE,

    -- evidence metadata
    evidence_type       TEXT            NOT NULL DEFAULT 'EVIDENCE_TYPE_PHOTO',
    file_url            TEXT            NOT NULL,
    file_name           TEXT,
    file_size_bytes     BIGINT,
    mime_type           TEXT,
    thumbnail_url       TEXT,

    -- capture context
    caption             TEXT,
    latitude            DOUBLE PRECISION,
    longitude           DOUBLE PRECISION,
    captured_at         TIMESTAMPTZ,
    captured_by         CHAR(26)        NOT NULL,

    -- audit
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE activity_evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_evidence FORCE ROW LEVEL SECURITY;

CREATE POLICY activity_evidence_select_policy ON activity_evidence
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY activity_evidence_insert_policy ON activity_evidence
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY activity_evidence_delete_policy ON activity_evidence
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_activity_evidence_tenant ON activity_evidence (tenant_id);
CREATE INDEX idx_activity_evidence_event ON activity_evidence (tenant_id, activity_event_id);
CREATE INDEX idx_activity_evidence_type ON activity_evidence (tenant_id, evidence_type);
