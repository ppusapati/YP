-- 001_fields.sql
-- Schema for the field-service: fields, boundaries, crop assignments, segments
-- Requires PostGIS extension for spatial data.

CREATE EXTENSION IF NOT EXISTS postgis;

-- -----------------------------------------------------------------------------
-- Table: fields
-- Primary entity representing an individual agricultural field within a farm.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fields (
    id                    VARCHAR(26)    PRIMARY KEY,
    tenant_id             VARCHAR(26)    NOT NULL,
    farm_id               VARCHAR(26)    NOT NULL,
    name                  VARCHAR(255)   NOT NULL,
    area_hectares         DOUBLE PRECISION NOT NULL DEFAULT 0,
    boundary              geometry(Polygon, 4326),
    current_crop_id       VARCHAR(26),
    planting_date         TIMESTAMPTZ,
    expected_harvest_date TIMESTAMPTZ,
    growth_stage          VARCHAR(50)    NOT NULL DEFAULT 'unspecified',
    soil_type             VARCHAR(50)    NOT NULL DEFAULT 'unspecified',
    irrigation_type       VARCHAR(50)    NOT NULL DEFAULT 'unspecified',
    field_type            VARCHAR(50)    NOT NULL DEFAULT 'unspecified',
    status                VARCHAR(50)    NOT NULL DEFAULT 'active',
    elevation_meters      DOUBLE PRECISION NOT NULL DEFAULT 0,
    slope_degrees         DOUBLE PRECISION NOT NULL DEFAULT 0,
    aspect_direction      VARCHAR(50)    NOT NULL DEFAULT 'unspecified',
    created_by            VARCHAR(26)    NOT NULL,
    updated_by            VARCHAR(26)    NOT NULL,
    created_at            TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    deleted_at            TIMESTAMPTZ,
    version               BIGINT         NOT NULL DEFAULT 1
);

-- Indexes for fields
CREATE INDEX IF NOT EXISTS idx_fields_tenant_id      ON fields (tenant_id);
CREATE INDEX IF NOT EXISTS idx_fields_farm_id        ON fields (farm_id);
CREATE INDEX IF NOT EXISTS idx_fields_status         ON fields (status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_fields_field_type     ON fields (field_type) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_fields_current_crop   ON fields (current_crop_id) WHERE current_crop_id IS NOT NULL AND deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_fields_tenant_farm    ON fields (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_fields_boundary_gist  ON fields USING GIST (boundary) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_fields_name_search    ON fields USING gin (name gin_trgm_ops) WHERE deleted_at IS NULL;

-- Composite unique: a field name must be unique within a farm for a tenant
CREATE UNIQUE INDEX IF NOT EXISTS uq_fields_tenant_farm_name
    ON fields (tenant_id, farm_id, name) WHERE deleted_at IS NULL;

-- -----------------------------------------------------------------------------
-- Table: field_boundaries
-- Stores historical boundary recordings for a field (e.g., GPS, satellite, drone).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS field_boundaries (
    id               VARCHAR(26)      PRIMARY KEY,
    field_id         VARCHAR(26)      NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
    polygon          geometry(Polygon, 4326) NOT NULL,
    area_hectares    DOUBLE PRECISION NOT NULL DEFAULT 0,
    perimeter_meters DOUBLE PRECISION NOT NULL DEFAULT 0,
    source           VARCHAR(100)     NOT NULL DEFAULT 'manual',
    recorded_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    created_at       TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_field_boundaries_field_id   ON field_boundaries (field_id);
CREATE INDEX IF NOT EXISTS idx_field_boundaries_polygon    ON field_boundaries USING GIST (polygon);

-- -----------------------------------------------------------------------------
-- Table: field_crop_assignments
-- Tracks the history of crops planted on a field across seasons.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS field_crop_assignments (
    id                    VARCHAR(26)      PRIMARY KEY,
    field_id              VARCHAR(26)      NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
    crop_id               VARCHAR(26)      NOT NULL,
    crop_variety          VARCHAR(255)     NOT NULL DEFAULT '',
    planting_date         TIMESTAMPTZ      NOT NULL,
    expected_harvest_date TIMESTAMPTZ,
    actual_harvest_date   TIMESTAMPTZ,
    growth_stage          VARCHAR(50)      NOT NULL DEFAULT 'unspecified',
    yield_per_hectare     DOUBLE PRECISION NOT NULL DEFAULT 0,
    notes                 TEXT             NOT NULL DEFAULT '',
    season                VARCHAR(50)      NOT NULL DEFAULT '',
    created_at            TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_crop_assignments_field_id     ON field_crop_assignments (field_id);
CREATE INDEX IF NOT EXISTS idx_crop_assignments_crop_id      ON field_crop_assignments (crop_id);
CREATE INDEX IF NOT EXISTS idx_crop_assignments_planting     ON field_crop_assignments (planting_date DESC);
CREATE INDEX IF NOT EXISTS idx_crop_assignments_field_season ON field_crop_assignments (field_id, season);

-- -----------------------------------------------------------------------------
-- Table: field_segments
-- Sub-divisions (zones) of a field for precision management.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS field_segments (
    id              VARCHAR(26)      PRIMARY KEY,
    field_id        VARCHAR(26)      NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
    name            VARCHAR(255)     NOT NULL,
    boundary        geometry(Polygon, 4326),
    area_hectares   DOUBLE PRECISION NOT NULL DEFAULT 0,
    soil_type       VARCHAR(50)      NOT NULL DEFAULT 'unspecified',
    current_crop_id VARCHAR(26),
    notes           TEXT             NOT NULL DEFAULT '',
    segment_index   INTEGER          NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_field_segments_field_id      ON field_segments (field_id);
CREATE INDEX IF NOT EXISTS idx_field_segments_boundary_gist ON field_segments USING GIST (boundary);
CREATE INDEX IF NOT EXISTS idx_field_segments_field_index   ON field_segments (field_id, segment_index);
