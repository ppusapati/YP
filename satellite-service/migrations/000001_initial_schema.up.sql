-- ============================================================================
-- Satellite Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: satellite_images
-- ============================================================================
CREATE TABLE IF NOT EXISTS satellite_images (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    field_id                CHAR(26),
    farm_id                 CHAR(26),

    -- satellite info
    satellite_provider      TEXT            NOT NULL DEFAULT 'SATELLITE_PROVIDER_UNSPECIFIED',
    acquisition_date        TIMESTAMPTZ,
    cloud_cover_pct         DOUBLE PRECISION,
    resolution_meters       DOUBLE PRECISION,
    bands                   TEXT[],

    -- bounding box
    bbox_min_lat            DOUBLE PRECISION,
    bbox_min_lon            DOUBLE PRECISION,
    bbox_max_lat            DOUBLE PRECISION,
    bbox_max_lon            DOUBLE PRECISION,

    -- storage
    image_url               TEXT,
    processing_status       TEXT            NOT NULL DEFAULT 'PROCESSING_STATUS_PENDING',

    -- versioning
    version                 INTEGER         NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE satellite_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE satellite_images FORCE ROW LEVEL SECURITY;

CREATE POLICY satellite_images_select_policy ON satellite_images
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY satellite_images_insert_policy ON satellite_images
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY satellite_images_update_policy ON satellite_images
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY satellite_images_delete_policy ON satellite_images
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_satellite_images_tenant_id ON satellite_images (tenant_id);
CREATE INDEX idx_satellite_images_field_id ON satellite_images (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_images_farm_id ON satellite_images (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_images_provider ON satellite_images (tenant_id, satellite_provider) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_images_acquisition_date ON satellite_images (tenant_id, acquisition_date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_images_processing_status ON satellite_images (tenant_id, processing_status) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_satellite_images_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_satellite_images_set_updated_at
    BEFORE UPDATE ON satellite_images
    FOR EACH ROW
    EXECUTE FUNCTION trg_satellite_images_updated_at();

-- ============================================================================
-- Table: satellite_alerts (crop stress alerts)
-- ============================================================================
CREATE TABLE IF NOT EXISTS satellite_alerts (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    field_id                CHAR(26),
    image_id                CHAR(26)        REFERENCES satellite_images(id),

    -- stress detection
    stress_detected         BOOLEAN         NOT NULL DEFAULT FALSE,
    stress_type             TEXT            NOT NULL DEFAULT 'STRESS_TYPE_UNSPECIFIED',
    stress_severity         DOUBLE PRECISION,
    affected_area_pct       DOUBLE PRECISION,
    description             TEXT,
    recommendation          TEXT,

    -- affected bounding box
    affected_bbox_min_lat   DOUBLE PRECISION,
    affected_bbox_min_lon   DOUBLE PRECISION,
    affected_bbox_max_lat   DOUBLE PRECISION,
    affected_bbox_max_lon   DOUBLE PRECISION,

    -- detection time
    detected_at             TIMESTAMPTZ,

    -- versioning
    version                 INTEGER         NOT NULL DEFAULT 1,

    -- audit
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE satellite_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE satellite_alerts FORCE ROW LEVEL SECURITY;

CREATE POLICY satellite_alerts_select_policy ON satellite_alerts
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY satellite_alerts_insert_policy ON satellite_alerts
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY satellite_alerts_update_policy ON satellite_alerts
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY satellite_alerts_delete_policy ON satellite_alerts
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_satellite_alerts_tenant_id ON satellite_alerts (tenant_id);
CREATE INDEX idx_satellite_alerts_field_id ON satellite_alerts (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_alerts_image_id ON satellite_alerts (tenant_id, image_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_alerts_stress_type ON satellite_alerts (tenant_id, stress_type) WHERE deleted_at IS NULL AND stress_detected = TRUE;
CREATE INDEX idx_satellite_alerts_detected_at ON satellite_alerts (tenant_id, detected_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_satellite_alerts_stress_detected ON satellite_alerts (tenant_id, stress_detected) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_satellite_alerts_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_satellite_alerts_set_updated_at
    BEFORE UPDATE ON satellite_alerts
    FOR EACH ROW
    EXECUTE FUNCTION trg_satellite_alerts_updated_at();
