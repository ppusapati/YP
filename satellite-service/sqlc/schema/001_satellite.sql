-- 001_satellite.sql  –  Satellite-service schema
-- Requires PostGIS extension for geospatial operations.

CREATE EXTENSION IF NOT EXISTS postgis;

-- ---------------------------------------------------------------------------
-- satellite_images
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS satellite_images (
    id                  BIGSERIAL    PRIMARY KEY,
    uuid                VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id           VARCHAR(26)  NOT NULL,
    field_id            VARCHAR(26)  NOT NULL,
    farm_id             VARCHAR(26)  NOT NULL,
    satellite_provider  VARCHAR(20)  NOT NULL DEFAULT 'SENTINEL2',
    acquisition_date    TIMESTAMPTZ  NOT NULL,
    cloud_cover_pct     DOUBLE PRECISION NOT NULL DEFAULT 0,
    resolution_meters   DOUBLE PRECISION NOT NULL DEFAULT 10,
    bands               TEXT[]       NOT NULL DEFAULT '{}',
    bbox                geometry(Polygon, 4326),
    image_url           TEXT         NOT NULL DEFAULT '',
    processing_status   VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    version             INTEGER      NOT NULL DEFAULT 1,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by          VARCHAR(26)  NOT NULL DEFAULT '',
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by          VARCHAR(26),
    updated_at          TIMESTAMPTZ,
    deleted_by          VARCHAR(26),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_satellite_images_tenant     ON satellite_images (tenant_id);
CREATE INDEX idx_satellite_images_field      ON satellite_images (field_id);
CREATE INDEX idx_satellite_images_farm       ON satellite_images (farm_id);
CREATE INDEX idx_satellite_images_status     ON satellite_images (processing_status);
CREATE INDEX idx_satellite_images_acq_date   ON satellite_images (acquisition_date);
CREATE INDEX idx_satellite_images_bbox       ON satellite_images USING GIST (bbox);

-- ---------------------------------------------------------------------------
-- vegetation_indices
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS vegetation_indices (
    id          BIGSERIAL    PRIMARY KEY,
    uuid        VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id   VARCHAR(26)  NOT NULL,
    image_id    VARCHAR(26)  NOT NULL,
    field_id    VARCHAR(26)  NOT NULL,
    index_type  VARCHAR(10)  NOT NULL,  -- NDVI, NDWI, EVI
    min_value   DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_value   DOUBLE PRECISION NOT NULL DEFAULT 0,
    mean_value  DOUBLE PRECISION NOT NULL DEFAULT 0,
    std_dev     DOUBLE PRECISION NOT NULL DEFAULT 0,
    raster_url  TEXT         NOT NULL DEFAULT '',
    computed_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    version     INTEGER      NOT NULL DEFAULT 1,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(26)  NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by  VARCHAR(26),
    updated_at  TIMESTAMPTZ,
    deleted_by  VARCHAR(26),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_vegetation_indices_tenant     ON vegetation_indices (tenant_id);
CREATE INDEX idx_vegetation_indices_image      ON vegetation_indices (image_id);
CREATE INDEX idx_vegetation_indices_field      ON vegetation_indices (field_id);
CREATE INDEX idx_vegetation_indices_type       ON vegetation_indices (index_type);
CREATE UNIQUE INDEX idx_vegetation_indices_image_type ON vegetation_indices (image_id, index_type) WHERE deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- crop_stress_alerts
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS crop_stress_alerts (
    id                BIGSERIAL    PRIMARY KEY,
    uuid              VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id         VARCHAR(26)  NOT NULL,
    field_id          VARCHAR(26)  NOT NULL,
    image_id          VARCHAR(26)  NOT NULL,
    stress_detected   BOOLEAN      NOT NULL DEFAULT FALSE,
    stress_type       VARCHAR(20)  NOT NULL DEFAULT 'WATER',
    stress_severity   DOUBLE PRECISION NOT NULL DEFAULT 0,
    affected_area_pct DOUBLE PRECISION NOT NULL DEFAULT 0,
    description       TEXT         NOT NULL DEFAULT '',
    recommendation    TEXT         NOT NULL DEFAULT '',
    affected_bbox     geometry(Polygon, 4326),
    version           INTEGER      NOT NULL DEFAULT 1,
    detected_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by        VARCHAR(26)  NOT NULL DEFAULT '',
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by        VARCHAR(26),
    updated_at        TIMESTAMPTZ,
    deleted_by        VARCHAR(26),
    deleted_at        TIMESTAMPTZ
);

CREATE INDEX idx_crop_stress_alerts_tenant   ON crop_stress_alerts (tenant_id);
CREATE INDEX idx_crop_stress_alerts_field    ON crop_stress_alerts (field_id);
CREATE INDEX idx_crop_stress_alerts_image    ON crop_stress_alerts (image_id);
CREATE INDEX idx_crop_stress_alerts_type     ON crop_stress_alerts (stress_type);
CREATE INDEX idx_crop_stress_alerts_bbox     ON crop_stress_alerts USING GIST (affected_bbox);

-- ---------------------------------------------------------------------------
-- temporal_analyses
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS temporal_analyses (
    id              BIGSERIAL    PRIMARY KEY,
    uuid            VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id       VARCHAR(26)  NOT NULL,
    field_id        VARCHAR(26)  NOT NULL,
    index_type      VARCHAR(10)  NOT NULL,
    start_date      TIMESTAMPTZ  NOT NULL,
    end_date        TIMESTAMPTZ  NOT NULL,
    data_points     JSONB        NOT NULL DEFAULT '[]',
    trend_slope     DOUBLE PRECISION NOT NULL DEFAULT 0,
    trend_direction VARCHAR(20)  NOT NULL DEFAULT 'stable',
    change_pct      DOUBLE PRECISION NOT NULL DEFAULT 0,
    version         INTEGER      NOT NULL DEFAULT 1,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26)  NOT NULL DEFAULT '',
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_temporal_analyses_tenant ON temporal_analyses (tenant_id);
CREATE INDEX idx_temporal_analyses_field  ON temporal_analyses (field_id);
CREATE INDEX idx_temporal_analyses_type   ON temporal_analyses (index_type);
CREATE INDEX idx_temporal_analyses_dates  ON temporal_analyses (start_date, end_date);

-- ---------------------------------------------------------------------------
-- satellite_tasks
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS satellite_tasks (
    id              BIGSERIAL    PRIMARY KEY,
    uuid            VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id       VARCHAR(26)  NOT NULL,
    field_id        VARCHAR(26)  NOT NULL,
    task_type       VARCHAR(30)  NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    input_image_id  VARCHAR(26)  NOT NULL DEFAULT '',
    result_id       VARCHAR(26)  NOT NULL DEFAULT '',
    error_message   TEXT         NOT NULL DEFAULT '',
    retry_count     INTEGER      NOT NULL DEFAULT 0,
    version         INTEGER      NOT NULL DEFAULT 1,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26)  NOT NULL DEFAULT '',
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_satellite_tasks_tenant ON satellite_tasks (tenant_id);
CREATE INDEX idx_satellite_tasks_field  ON satellite_tasks (field_id);
CREATE INDEX idx_satellite_tasks_status ON satellite_tasks (status);
CREATE INDEX idx_satellite_tasks_type   ON satellite_tasks (task_type);
