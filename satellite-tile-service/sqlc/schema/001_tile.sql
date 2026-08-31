-- 001_tile.sql
-- Schema for the satellite-tile-service: tilesets

-- Enum types
CREATE TYPE tile_format AS ENUM ('PNG', 'JPEG', 'WEBP', 'MVT');
CREATE TYPE tileset_status AS ENUM ('QUEUED', 'GENERATING', 'COMPLETED', 'FAILED');
CREATE TYPE tile_layer AS ENUM ('RGB', 'NDVI', 'NDWI', 'EVI', 'STRESS', 'FALSE_COLOR', 'THERMAL');

-- Tilesets table
CREATE TABLE tilesets (
    id                  BIGSERIAL PRIMARY KEY,
    uuid                VARCHAR(26) NOT NULL UNIQUE,
    tenant_id           VARCHAR(26) NOT NULL,
    farm_id             VARCHAR(26) NOT NULL,
    processing_job_id   VARCHAR(26) NOT NULL,
    layer               tile_layer NOT NULL,
    format              tile_format NOT NULL DEFAULT 'PNG',
    status              tileset_status NOT NULL DEFAULT 'QUEUED',
    min_zoom            INTEGER NOT NULL DEFAULT 10,
    max_zoom            INTEGER NOT NULL DEFAULT 18,
    s3_prefix           TEXT,
    total_tiles         BIGINT NOT NULL DEFAULT 0,
    bbox_geojson        TEXT,
    error_message       TEXT,
    acquisition_date    TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_by          VARCHAR(26) NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by          VARCHAR(26),
    updated_at          TIMESTAMPTZ,
    deleted_by          VARCHAR(26),
    deleted_at          TIMESTAMPTZ
);

-- Indexes for tilesets
CREATE INDEX idx_tilesets_tenant_id ON tilesets(tenant_id);
CREATE INDEX idx_tilesets_uuid ON tilesets(uuid);
CREATE INDEX idx_tilesets_farm_id ON tilesets(tenant_id, farm_id);
CREATE INDEX idx_tilesets_processing_job ON tilesets(tenant_id, processing_job_id);
CREATE INDEX idx_tilesets_layer ON tilesets(tenant_id, layer);
CREATE INDEX idx_tilesets_status ON tilesets(tenant_id, status);
CREATE INDEX idx_tilesets_created_at ON tilesets(tenant_id, created_at DESC);
CREATE INDEX idx_tilesets_active ON tilesets(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_tilesets_farm_layer ON tilesets(tenant_id, farm_id, layer) WHERE is_active = TRUE AND deleted_at IS NULL;
