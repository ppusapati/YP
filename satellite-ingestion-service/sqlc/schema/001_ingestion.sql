-- 001_ingestion.sql
-- Schema for the satellite-ingestion-service: ingestion_tasks

-- Enable PostGIS extension for geometry support
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enum types
CREATE TYPE satellite_provider AS ENUM ('SENTINEL2', 'LANDSAT', 'PLANETSCOPE');
CREATE TYPE ingestion_status AS ENUM ('QUEUED', 'DOWNLOADING', 'VALIDATING', 'STORED', 'FAILED');
CREATE TYPE spectral_band AS ENUM ('BLUE', 'GREEN', 'RED', 'NIR', 'SWIR1', 'SWIR2', 'RED_EDGE1', 'RED_EDGE2', 'RED_EDGE3');

-- Ingestion tasks table
CREATE TABLE ingestion_tasks (
    id                  BIGSERIAL PRIMARY KEY,
    uuid                CHAR(26) NOT NULL UNIQUE,
    tenant_id           VARCHAR(26) NOT NULL,
    farm_id             BIGINT NOT NULL,
    farm_uuid           VARCHAR(26) NOT NULL,
    provider            satellite_provider NOT NULL,
    scene_id            VARCHAR(255) NOT NULL,
    status              ingestion_status NOT NULL DEFAULT 'QUEUED',
    s3_bucket           VARCHAR(255),
    s3_key              VARCHAR(1024),
    cloud_cover_percent DOUBLE PRECISION NOT NULL DEFAULT 0,
    resolution_meters   DOUBLE PRECISION NOT NULL DEFAULT 0,
    bands               spectral_band[] NOT NULL DEFAULT '{}',
    bbox                GEOMETRY(Polygon, 4326),
    file_size_bytes     BIGINT NOT NULL DEFAULT 0,
    checksum_sha256     VARCHAR(64),
    error_message       TEXT,
    retry_count         INTEGER NOT NULL DEFAULT 0,
    acquisition_date    TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    version             BIGINT NOT NULL DEFAULT 1,
    created_by          VARCHAR(26) NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by          VARCHAR(26),
    updated_at          TIMESTAMPTZ,
    deleted_by          VARCHAR(26),
    deleted_at          TIMESTAMPTZ
);

-- Indexes for ingestion_tasks
CREATE INDEX idx_ingestion_tasks_tenant_id ON ingestion_tasks(tenant_id);
CREATE INDEX idx_ingestion_tasks_farm_uuid ON ingestion_tasks(farm_uuid);
CREATE INDEX idx_ingestion_tasks_provider ON ingestion_tasks(tenant_id, provider);
CREATE INDEX idx_ingestion_tasks_status ON ingestion_tasks(tenant_id, status);
CREATE INDEX idx_ingestion_tasks_scene_id ON ingestion_tasks(scene_id);
CREATE INDEX idx_ingestion_tasks_acquisition_date ON ingestion_tasks(tenant_id, acquisition_date DESC);
CREATE INDEX idx_ingestion_tasks_bbox ON ingestion_tasks USING GIST(bbox);
CREATE INDEX idx_ingestion_tasks_active ON ingestion_tasks(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_ingestion_tasks_farm_provider ON ingestion_tasks(farm_uuid, provider, status);
CREATE INDEX idx_ingestion_tasks_created_at ON ingestion_tasks(tenant_id, created_at DESC);
