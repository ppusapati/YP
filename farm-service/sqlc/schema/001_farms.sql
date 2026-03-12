-- 001_farms.sql
-- Schema for the farm-service: farms, farm_boundaries, farm_owners

-- Enable PostGIS extension for geometry support
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enum types
CREATE TYPE farm_type AS ENUM ('CROP', 'LIVESTOCK', 'MIXED', 'AQUACULTURE');
CREATE TYPE farm_status AS ENUM ('ACTIVE', 'INACTIVE', 'PENDING', 'SUSPENDED', 'ARCHIVED');
CREATE TYPE soil_type AS ENUM ('CLAY', 'SANDY', 'LOAMY', 'SILT', 'PEAT', 'CHALKY', 'LATERITE', 'BLACK', 'RED', 'ALLUVIAL');
CREATE TYPE climate_zone AS ENUM ('TROPICAL', 'SUBTROPICAL', 'ARID', 'SEMIARID', 'TEMPERATE', 'CONTINENTAL', 'POLAR', 'MEDITERRANEAN', 'MONSOON');

-- Farms table
CREATE TABLE farms (
    id              BIGSERIAL PRIMARY KEY,
    uuid            VARCHAR(26) NOT NULL UNIQUE,
    tenant_id       VARCHAR(26) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    total_area_hectares DOUBLE PRECISION NOT NULL DEFAULT 0,
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION,
    elevation_meters DOUBLE PRECISION DEFAULT 0,
    farm_type       farm_type NOT NULL DEFAULT 'CROP',
    status          farm_status NOT NULL DEFAULT 'PENDING',
    soil_type       soil_type,
    climate_zone    climate_zone,
    address         TEXT,
    region          VARCHAR(255),
    country         VARCHAR(100),
    metadata        JSONB DEFAULT '{}',
    version         BIGINT NOT NULL DEFAULT 1,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

-- Farm boundaries table with PostGIS geometry
CREATE TABLE farm_boundaries (
    id              BIGSERIAL PRIMARY KEY,
    uuid            VARCHAR(26) NOT NULL UNIQUE,
    farm_id         BIGINT NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    farm_uuid       VARCHAR(26) NOT NULL,
    tenant_id       VARCHAR(26) NOT NULL,
    geojson         TEXT NOT NULL,
    boundary        GEOMETRY(Polygon, 4326),
    area_hectares   DOUBLE PRECISION NOT NULL DEFAULT 0,
    perimeter_meters DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

-- Farm owners table
CREATE TABLE farm_owners (
    id                    BIGSERIAL PRIMARY KEY,
    uuid                  VARCHAR(26) NOT NULL UNIQUE,
    farm_id               BIGINT NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    farm_uuid             VARCHAR(26) NOT NULL,
    tenant_id             VARCHAR(26) NOT NULL,
    user_id               VARCHAR(26) NOT NULL,
    owner_name            VARCHAR(255) NOT NULL,
    email                 VARCHAR(255),
    phone                 VARCHAR(50),
    is_primary            BOOLEAN NOT NULL DEFAULT FALSE,
    ownership_percentage  DOUBLE PRECISION NOT NULL DEFAULT 100.0,
    acquired_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_by            VARCHAR(26) NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by            VARCHAR(26),
    updated_at            TIMESTAMPTZ,
    deleted_by            VARCHAR(26),
    deleted_at            TIMESTAMPTZ
);

-- Indexes for farms
CREATE INDEX idx_farms_tenant_id ON farms(tenant_id);
CREATE INDEX idx_farms_uuid ON farms(uuid);
CREATE INDEX idx_farms_name ON farms(tenant_id, name);
CREATE INDEX idx_farms_status ON farms(tenant_id, status);
CREATE INDEX idx_farms_farm_type ON farms(tenant_id, farm_type);
CREATE INDEX idx_farms_region ON farms(tenant_id, region);
CREATE INDEX idx_farms_country ON farms(tenant_id, country);
CREATE INDEX idx_farms_climate_zone ON farms(tenant_id, climate_zone);
CREATE INDEX idx_farms_created_at ON farms(tenant_id, created_at DESC);
CREATE INDEX idx_farms_location ON farms(latitude, longitude);
CREATE INDEX idx_farms_active ON farms(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Indexes for farm_boundaries
CREATE INDEX idx_farm_boundaries_farm_id ON farm_boundaries(farm_id);
CREATE INDEX idx_farm_boundaries_farm_uuid ON farm_boundaries(farm_uuid);
CREATE INDEX idx_farm_boundaries_tenant_id ON farm_boundaries(tenant_id);
CREATE INDEX idx_farm_boundaries_boundary ON farm_boundaries USING GIST(boundary);

-- Indexes for farm_owners
CREATE INDEX idx_farm_owners_farm_id ON farm_owners(farm_id);
CREATE INDEX idx_farm_owners_farm_uuid ON farm_owners(farm_uuid);
CREATE INDEX idx_farm_owners_tenant_id ON farm_owners(tenant_id);
CREATE INDEX idx_farm_owners_user_id ON farm_owners(tenant_id, user_id);
CREATE INDEX idx_farm_owners_primary ON farm_owners(farm_id, is_primary) WHERE is_primary = TRUE AND is_active = TRUE;

-- Unique constraint: one primary owner per farm
CREATE UNIQUE INDEX idx_farm_owners_unique_primary ON farm_owners(farm_id) WHERE is_primary = TRUE AND is_active = TRUE AND deleted_at IS NULL;
