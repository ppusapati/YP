-- 001_crops.sql - Schema for crop-service tables
-- Manages crop catalog, varieties, growth stages, requirements, and recommendations

CREATE TABLE IF NOT EXISTS crops (
    id                      BIGSERIAL PRIMARY KEY,
    uuid                    VARCHAR(26) NOT NULL UNIQUE,
    tenant_id               VARCHAR(26) NOT NULL,
    name                    VARCHAR(255) NOT NULL,
    scientific_name         VARCHAR(255) NOT NULL DEFAULT '',
    family                  VARCHAR(128) NOT NULL DEFAULT '',
    category                VARCHAR(32) NOT NULL DEFAULT 'UNSPECIFIED',
    description             TEXT NOT NULL DEFAULT '',
    image_url               TEXT NOT NULL DEFAULT '',
    disease_susceptibilities TEXT[] NOT NULL DEFAULT '{}',
    companion_plants        TEXT[] NOT NULL DEFAULT '{}',
    rotation_group          VARCHAR(128) NOT NULL DEFAULT '',
    version                 INTEGER NOT NULL DEFAULT 1,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_by              VARCHAR(26) NOT NULL DEFAULT '',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by              VARCHAR(26),
    updated_at              TIMESTAMPTZ,
    deleted_by              VARCHAR(26),
    deleted_at              TIMESTAMPTZ,

    CONSTRAINT uq_crops_tenant_name UNIQUE (tenant_id, name)
);

CREATE INDEX idx_crops_tenant_id ON crops (tenant_id);
CREATE INDEX idx_crops_category ON crops (category);
CREATE INDEX idx_crops_tenant_category ON crops (tenant_id, category);
CREATE INDEX idx_crops_name_search ON crops USING gin (name gin_trgm_ops);

CREATE TABLE IF NOT EXISTS crop_varieties (
    id                              BIGSERIAL PRIMARY KEY,
    uuid                            VARCHAR(26) NOT NULL UNIQUE,
    crop_id                         BIGINT NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
    tenant_id                       VARCHAR(26) NOT NULL,
    name                            VARCHAR(255) NOT NULL,
    description                     TEXT NOT NULL DEFAULT '',
    maturity_days                   INTEGER NOT NULL DEFAULT 0,
    yield_potential_kg_per_hectare  DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_hybrid                       BOOLEAN NOT NULL DEFAULT FALSE,
    disease_resistance              TEXT NOT NULL DEFAULT '',
    suitable_regions                TEXT NOT NULL DEFAULT '',
    seed_rate_kg_per_hectare        VARCHAR(64) NOT NULL DEFAULT '',
    is_active                       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by                      VARCHAR(26) NOT NULL DEFAULT '',
    created_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by                      VARCHAR(26),
    updated_at                      TIMESTAMPTZ,
    deleted_by                      VARCHAR(26),
    deleted_at                      TIMESTAMPTZ,

    CONSTRAINT uq_crop_varieties_crop_name UNIQUE (crop_id, name)
);

CREATE INDEX idx_crop_varieties_crop_id ON crop_varieties (crop_id);
CREATE INDEX idx_crop_varieties_tenant_id ON crop_varieties (tenant_id);

CREATE TABLE IF NOT EXISTS crop_growth_stages (
    id                     BIGSERIAL PRIMARY KEY,
    uuid                   VARCHAR(26) NOT NULL UNIQUE,
    crop_id                BIGINT NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
    tenant_id              VARCHAR(26) NOT NULL,
    name                   VARCHAR(128) NOT NULL,
    stage_order            INTEGER NOT NULL DEFAULT 0,
    duration_days          INTEGER NOT NULL DEFAULT 0,
    water_requirement_mm   DOUBLE PRECISION NOT NULL DEFAULT 0,
    nutrient_requirements  TEXT NOT NULL DEFAULT '',
    description            TEXT NOT NULL DEFAULT '',
    optimal_temp_min       DOUBLE PRECISION NOT NULL DEFAULT 0,
    optimal_temp_max       DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_active              BOOLEAN NOT NULL DEFAULT TRUE,
    created_by             VARCHAR(26) NOT NULL DEFAULT '',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by             VARCHAR(26),
    updated_at             TIMESTAMPTZ,
    deleted_by             VARCHAR(26),
    deleted_at             TIMESTAMPTZ,

    CONSTRAINT uq_growth_stage_crop_name UNIQUE (crop_id, name)
);

CREATE INDEX idx_crop_growth_stages_crop_id ON crop_growth_stages (crop_id);
CREATE INDEX idx_crop_growth_stages_order ON crop_growth_stages (crop_id, stage_order);

CREATE TABLE IF NOT EXISTS crop_requirements (
    id                          BIGSERIAL PRIMARY KEY,
    uuid                        VARCHAR(26) NOT NULL UNIQUE,
    crop_id                     BIGINT NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
    tenant_id                   VARCHAR(26) NOT NULL,
    optimal_temp_min            DOUBLE PRECISION NOT NULL DEFAULT 0,
    optimal_temp_max            DOUBLE PRECISION NOT NULL DEFAULT 0,
    optimal_humidity_min        DOUBLE PRECISION NOT NULL DEFAULT 0,
    optimal_humidity_max        DOUBLE PRECISION NOT NULL DEFAULT 0,
    optimal_soil_ph_min         DOUBLE PRECISION NOT NULL DEFAULT 0,
    optimal_soil_ph_max         DOUBLE PRECISION NOT NULL DEFAULT 0,
    water_requirement_mm_per_day DOUBLE PRECISION NOT NULL DEFAULT 0,
    sunlight_hours              DOUBLE PRECISION NOT NULL DEFAULT 0,
    frost_tolerant              BOOLEAN NOT NULL DEFAULT FALSE,
    drought_tolerant            BOOLEAN NOT NULL DEFAULT FALSE,
    soil_type_preference        VARCHAR(128) NOT NULL DEFAULT '',
    nutrient_requirements       TEXT NOT NULL DEFAULT '',
    is_active                   BOOLEAN NOT NULL DEFAULT TRUE,
    created_by                  VARCHAR(26) NOT NULL DEFAULT '',
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by                  VARCHAR(26),
    updated_at                  TIMESTAMPTZ,
    deleted_by                  VARCHAR(26),
    deleted_at                  TIMESTAMPTZ,

    CONSTRAINT uq_crop_requirements_crop UNIQUE (crop_id)
);

CREATE INDEX idx_crop_requirements_crop_id ON crop_requirements (crop_id);

CREATE TABLE IF NOT EXISTS crop_recommendations (
    id                       BIGSERIAL PRIMARY KEY,
    uuid                     VARCHAR(26) NOT NULL UNIQUE,
    crop_id                  BIGINT NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
    tenant_id                VARCHAR(26) NOT NULL,
    recommendation_type      VARCHAR(64) NOT NULL DEFAULT '',
    title                    VARCHAR(255) NOT NULL DEFAULT '',
    description              TEXT NOT NULL DEFAULT '',
    severity                 VARCHAR(32) NOT NULL DEFAULT 'info',
    confidence_score         DOUBLE PRECISION NOT NULL DEFAULT 0,
    parameters               JSONB NOT NULL DEFAULT '{}',
    applicable_growth_stage  VARCHAR(128) NOT NULL DEFAULT '',
    valid_from               TIMESTAMPTZ,
    valid_until              TIMESTAMPTZ,
    is_active                BOOLEAN NOT NULL DEFAULT TRUE,
    created_by               VARCHAR(26) NOT NULL DEFAULT '',
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by               VARCHAR(26),
    updated_at               TIMESTAMPTZ,
    deleted_by               VARCHAR(26),
    deleted_at               TIMESTAMPTZ
);

CREATE INDEX idx_crop_recommendations_crop_id ON crop_recommendations (crop_id);
CREATE INDEX idx_crop_recommendations_tenant_id ON crop_recommendations (tenant_id);
CREATE INDEX idx_crop_recommendations_type ON crop_recommendations (recommendation_type);
CREATE INDEX idx_crop_recommendations_validity ON crop_recommendations (valid_from, valid_until);
