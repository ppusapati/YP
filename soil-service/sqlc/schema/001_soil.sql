-- 001_soil.sql  --  Soil-service schema
-- Requires: uuid-ossp, PostGIS

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- ---------------------------------------------------------------------------
-- soil_samples
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS soil_samples (
    id                       BIGSERIAL    PRIMARY KEY,
    uuid                     VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id                VARCHAR(26)  NOT NULL,
    field_id                 VARCHAR(26)  NOT NULL,
    farm_id                  VARCHAR(26)  NOT NULL,
    sample_location          GEOMETRY(Point, 4326),
    sample_depth_cm          DOUBLE PRECISION NOT NULL DEFAULT 0,
    collection_date          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    ph                       DOUBLE PRECISION NOT NULL DEFAULT 0,
    organic_matter_pct       DOUBLE PRECISION NOT NULL DEFAULT 0,
    nitrogen_ppm             DOUBLE PRECISION NOT NULL DEFAULT 0,
    phosphorus_ppm           DOUBLE PRECISION NOT NULL DEFAULT 0,
    potassium_ppm            DOUBLE PRECISION NOT NULL DEFAULT 0,
    calcium_ppm              DOUBLE PRECISION NOT NULL DEFAULT 0,
    magnesium_ppm            DOUBLE PRECISION NOT NULL DEFAULT 0,
    sulfur_ppm               DOUBLE PRECISION NOT NULL DEFAULT 0,
    iron_ppm                 DOUBLE PRECISION NOT NULL DEFAULT 0,
    manganese_ppm            DOUBLE PRECISION NOT NULL DEFAULT 0,
    zinc_ppm                 DOUBLE PRECISION NOT NULL DEFAULT 0,
    copper_ppm               DOUBLE PRECISION NOT NULL DEFAULT 0,
    boron_ppm                DOUBLE PRECISION NOT NULL DEFAULT 0,
    moisture_pct             DOUBLE PRECISION NOT NULL DEFAULT 0,
    texture                  VARCHAR(20)  NOT NULL DEFAULT 'LOAMY',
    bulk_density             DOUBLE PRECISION NOT NULL DEFAULT 0,
    cation_exchange_capacity DOUBLE PRECISION NOT NULL DEFAULT 0,
    electrical_conductivity  DOUBLE PRECISION NOT NULL DEFAULT 0,
    collected_by             VARCHAR(26)  NOT NULL DEFAULT '',
    notes                    TEXT         NOT NULL DEFAULT '',
    is_active                BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by               VARCHAR(26)  NOT NULL DEFAULT '',
    created_at               TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by               VARCHAR(26),
    updated_at               TIMESTAMPTZ,
    deleted_by               VARCHAR(26),
    deleted_at               TIMESTAMPTZ,
    version                  BIGINT       NOT NULL DEFAULT 1
);

CREATE INDEX idx_soil_samples_tenant   ON soil_samples (tenant_id);
CREATE INDEX idx_soil_samples_field    ON soil_samples (field_id);
CREATE INDEX idx_soil_samples_farm     ON soil_samples (farm_id);
CREATE INDEX idx_soil_samples_location ON soil_samples USING GIST (sample_location);
CREATE INDEX idx_soil_samples_date     ON soil_samples (collection_date);

-- ---------------------------------------------------------------------------
-- soil_analyses
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS soil_analyses (
    id                BIGSERIAL    PRIMARY KEY,
    uuid              VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id         VARCHAR(26)  NOT NULL,
    sample_id         VARCHAR(26)  NOT NULL,
    field_id          VARCHAR(26)  NOT NULL,
    farm_id           VARCHAR(26)  NOT NULL,
    status            VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    analysis_type     VARCHAR(50)  NOT NULL DEFAULT 'STANDARD',
    soil_health_score DOUBLE PRECISION NOT NULL DEFAULT 0,
    health_category   VARCHAR(20)  NOT NULL DEFAULT 'UNSPECIFIED',
    recommendations   TEXT[]       NOT NULL DEFAULT '{}',
    analyzed_by       VARCHAR(26)  NOT NULL DEFAULT '',
    analyzed_at       TIMESTAMPTZ,
    summary           TEXT         NOT NULL DEFAULT '',
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by        VARCHAR(26)  NOT NULL DEFAULT '',
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by        VARCHAR(26),
    updated_at        TIMESTAMPTZ,
    deleted_by        VARCHAR(26),
    deleted_at        TIMESTAMPTZ,
    version           BIGINT       NOT NULL DEFAULT 1
);

CREATE INDEX idx_soil_analyses_tenant  ON soil_analyses (tenant_id);
CREATE INDEX idx_soil_analyses_sample  ON soil_analyses (sample_id);
CREATE INDEX idx_soil_analyses_field   ON soil_analyses (field_id);
CREATE INDEX idx_soil_analyses_farm    ON soil_analyses (farm_id);
CREATE INDEX idx_soil_analyses_status  ON soil_analyses (status);

-- ---------------------------------------------------------------------------
-- soil_maps
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS soil_maps (
    id            BIGSERIAL    PRIMARY KEY,
    uuid          VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id     VARCHAR(26)  NOT NULL,
    field_id      VARCHAR(26)  NOT NULL,
    farm_id       VARCHAR(26)  NOT NULL,
    map_type      VARCHAR(50)  NOT NULL DEFAULT '',
    raster_data   RASTER,
    crs           VARCHAR(20)  NOT NULL DEFAULT 'EPSG:4326',
    resolution    DOUBLE PRECISION NOT NULL DEFAULT 0,
    bbox_min_lat  DOUBLE PRECISION NOT NULL DEFAULT 0,
    bbox_min_lng  DOUBLE PRECISION NOT NULL DEFAULT 0,
    bbox_max_lat  DOUBLE PRECISION NOT NULL DEFAULT 0,
    bbox_max_lng  DOUBLE PRECISION NOT NULL DEFAULT 0,
    generated_by  VARCHAR(26)  NOT NULL DEFAULT '',
    generated_at  TIMESTAMPTZ,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by    VARCHAR(26)  NOT NULL DEFAULT '',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by    VARCHAR(26),
    updated_at    TIMESTAMPTZ,
    deleted_by    VARCHAR(26),
    deleted_at    TIMESTAMPTZ,
    version       BIGINT       NOT NULL DEFAULT 1
);

CREATE INDEX idx_soil_maps_tenant ON soil_maps (tenant_id);
CREATE INDEX idx_soil_maps_field  ON soil_maps (field_id);
CREATE INDEX idx_soil_maps_farm   ON soil_maps (farm_id);
CREATE INDEX idx_soil_maps_type   ON soil_maps (map_type);

-- ---------------------------------------------------------------------------
-- soil_nutrients
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS soil_nutrients (
    id            BIGSERIAL       PRIMARY KEY,
    uuid          VARCHAR(26)     NOT NULL UNIQUE,
    tenant_id     VARCHAR(26)     NOT NULL,
    sample_id     VARCHAR(26)     NOT NULL,
    nutrient_name VARCHAR(50)     NOT NULL,
    value_ppm     DOUBLE PRECISION NOT NULL DEFAULT 0,
    level         VARCHAR(20)     NOT NULL DEFAULT 'ADEQUATE',
    optimal_min   DOUBLE PRECISION NOT NULL DEFAULT 0,
    optimal_max   DOUBLE PRECISION NOT NULL DEFAULT 0,
    unit          VARCHAR(20)     NOT NULL DEFAULT 'ppm',
    is_active     BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by    VARCHAR(26)     NOT NULL DEFAULT '',
    created_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by    VARCHAR(26),
    updated_at    TIMESTAMPTZ,
    deleted_by    VARCHAR(26),
    deleted_at    TIMESTAMPTZ
);

CREATE INDEX idx_soil_nutrients_tenant  ON soil_nutrients (tenant_id);
CREATE INDEX idx_soil_nutrients_sample  ON soil_nutrients (sample_id);
CREATE INDEX idx_soil_nutrients_name    ON soil_nutrients (nutrient_name);

-- ---------------------------------------------------------------------------
-- soil_health_scores
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS soil_health_scores (
    id               BIGSERIAL       PRIMARY KEY,
    uuid             VARCHAR(26)     NOT NULL UNIQUE,
    tenant_id        VARCHAR(26)     NOT NULL,
    field_id         VARCHAR(26)     NOT NULL,
    farm_id          VARCHAR(26)     NOT NULL,
    overall_score    DOUBLE PRECISION NOT NULL DEFAULT 0,
    category         VARCHAR(20)     NOT NULL DEFAULT 'FAIR',
    physical_score   DOUBLE PRECISION NOT NULL DEFAULT 0,
    chemical_score   DOUBLE PRECISION NOT NULL DEFAULT 0,
    biological_score DOUBLE PRECISION NOT NULL DEFAULT 0,
    recommendations  TEXT[]          NOT NULL DEFAULT '{}',
    assessed_at      TIMESTAMPTZ,
    is_active        BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by       VARCHAR(26)     NOT NULL DEFAULT '',
    created_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by       VARCHAR(26),
    updated_at       TIMESTAMPTZ,
    deleted_by       VARCHAR(26),
    deleted_at       TIMESTAMPTZ,
    version          BIGINT          NOT NULL DEFAULT 1
);

CREATE INDEX idx_soil_health_scores_tenant ON soil_health_scores (tenant_id);
CREATE INDEX idx_soil_health_scores_field  ON soil_health_scores (field_id);
CREATE INDEX idx_soil_health_scores_farm   ON soil_health_scores (farm_id);
