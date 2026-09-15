-- ============================================================================
-- Satellite Tile Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Custom Enum Types
-- ============================================================================
CREATE TYPE tile_format AS ENUM (
    'PNG',
    'JPEG',
    'WEBP',
    'MVT'
);

CREATE TYPE tileset_status AS ENUM (
    'QUEUED',
    'GENERATING',
    'COMPLETED',
    'FAILED'
);

CREATE TYPE tile_layer AS ENUM (
    'RGB',
    'NDVI',
    'NDWI',
    'EVI',
    'STRESS',
    'FALSE_COLOR',
    'THERMAL'
);

-- ============================================================================
-- Table: tilesets
-- ============================================================================
CREATE TABLE IF NOT EXISTS tilesets (
    id                      BIGSERIAL       PRIMARY KEY,
    uuid                    CHAR(26)        NOT NULL UNIQUE,
    tenant_id               CHAR(26)        NOT NULL,
    farm_id                 CHAR(26)        NOT NULL,
    processing_job_id       CHAR(26)        NOT NULL,
    layer                   tile_layer      NOT NULL,
    format                  tile_format     NOT NULL,
    status                  tileset_status  NOT NULL DEFAULT 'QUEUED',
    min_zoom                INTEGER         NOT NULL DEFAULT 0,
    max_zoom                INTEGER         NOT NULL DEFAULT 18,
    s3_prefix               TEXT,
    total_tiles             BIGINT          NOT NULL DEFAULT 0,
    bbox_geojson            TEXT,
    error_message           TEXT,
    acquisition_date        TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by              CHAR(26)        NOT NULL,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by              CHAR(26),
    updated_at              TIMESTAMPTZ,
    deleted_by              CHAR(26),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE tilesets ENABLE ROW LEVEL SECURITY;
ALTER TABLE tilesets FORCE ROW LEVEL SECURITY;

CREATE POLICY tilesets_select_policy ON tilesets
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY tilesets_insert_policy ON tilesets
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY tilesets_update_policy ON tilesets
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY tilesets_delete_policy ON tilesets
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_tilesets_tenant_id ON tilesets (tenant_id);
CREATE INDEX idx_tilesets_uuid ON tilesets (uuid);
CREATE INDEX idx_tilesets_farm_id ON tilesets (tenant_id, farm_id) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_tilesets_layer ON tilesets (tenant_id, layer) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_tilesets_status ON tilesets (tenant_id, status) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_tilesets_created_at ON tilesets (tenant_id, created_at DESC) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_tilesets_processing_job_layer ON tilesets (processing_job_id, tenant_id, layer) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_tilesets_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tilesets_set_updated_at
    BEFORE UPDATE ON tilesets
    FOR EACH ROW
    EXECUTE FUNCTION trg_tilesets_updated_at();
