-- ============================================================================
-- Field Service: Add field_segments table
-- ============================================================================

CREATE TABLE IF NOT EXISTS field_segments (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    field_id            CHAR(26)        NOT NULL REFERENCES fields(id) ON DELETE CASCADE,

    -- segment data
    name                TEXT            NOT NULL,
    boundary            JSONB,
    area_hectares       DOUBLE PRECISION,
    soil_type           TEXT            NOT NULL DEFAULT 'SOIL_TYPE_UNSPECIFIED',
    current_crop_id     CHAR(26),
    notes               TEXT,
    segment_index       INTEGER         NOT NULL DEFAULT 0,

    -- audit
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE field_segments ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_segments FORCE ROW LEVEL SECURITY;

CREATE POLICY field_segments_select_policy ON field_segments
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY field_segments_insert_policy ON field_segments
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY field_segments_update_policy ON field_segments
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY field_segments_delete_policy ON field_segments
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_field_segments_tenant_id ON field_segments (tenant_id);
CREATE INDEX idx_field_segments_field_id ON field_segments (tenant_id, field_id) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_field_segments_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_field_segments_set_updated_at
    BEFORE UPDATE ON field_segments
    FOR EACH ROW
    EXECUTE FUNCTION trg_field_segments_updated_at();
