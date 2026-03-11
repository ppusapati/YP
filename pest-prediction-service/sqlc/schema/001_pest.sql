-- 001_pest.sql
-- Schema for pest-prediction-service: predictions, alerts, species, treatments, observations, risk_maps

-- Enable PostGIS extension for geometry support
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enum types
CREATE TYPE risk_level AS ENUM ('NONE', 'LOW', 'MODERATE', 'HIGH', 'CRITICAL');
CREATE TYPE treatment_type AS ENUM ('CHEMICAL', 'BIOLOGICAL', 'CULTURAL', 'MECHANICAL');
CREATE TYPE alert_status AS ENUM ('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED', 'EXPIRED');
CREATE TYPE damage_level AS ENUM ('NONE', 'LIGHT', 'MODERATE', 'SEVERE', 'DEVASTATING');
CREATE TYPE growth_stage AS ENUM ('GERMINATION', 'SEEDLING', 'VEGETATIVE', 'FLOWERING', 'FRUITING', 'MATURATION', 'HARVEST');

-- Pest species catalogue
CREATE TABLE pest_species (
    id              BIGSERIAL PRIMARY KEY,
    uuid            VARCHAR(26) NOT NULL UNIQUE,
    tenant_id       VARCHAR(26) NOT NULL,
    common_name     VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255) NOT NULL,
    family          VARCHAR(255),
    description     TEXT,
    affected_crops  JSONB DEFAULT '[]',
    favorable_conditions JSONB DEFAULT '[]',
    image_url       TEXT,
    version         BIGINT NOT NULL DEFAULT 1,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

-- Pest predictions
CREATE TABLE pest_predictions (
    id                         BIGSERIAL PRIMARY KEY,
    uuid                       VARCHAR(26) NOT NULL UNIQUE,
    tenant_id                  VARCHAR(26) NOT NULL,
    farm_id                    VARCHAR(26) NOT NULL,
    field_id                   VARCHAR(26) NOT NULL,
    pest_species_id            BIGINT NOT NULL REFERENCES pest_species(id),
    pest_species_uuid          VARCHAR(26) NOT NULL,
    prediction_date            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    risk_level                 risk_level NOT NULL DEFAULT 'NONE',
    risk_score                 INTEGER NOT NULL DEFAULT 0 CHECK (risk_score >= 0 AND risk_score <= 100),
    confidence_pct             DOUBLE PRECISION NOT NULL DEFAULT 0 CHECK (confidence_pct >= 0 AND confidence_pct <= 100),
    temperature_celsius        DOUBLE PRECISION,
    humidity_pct               DOUBLE PRECISION,
    rainfall_mm                DOUBLE PRECISION,
    wind_speed_kmh             DOUBLE PRECISION,
    crop_type                  VARCHAR(100) NOT NULL,
    growth_stage               growth_stage,
    geographic_risk_factor     DOUBLE PRECISION NOT NULL DEFAULT 0,
    historical_occurrence_count INTEGER NOT NULL DEFAULT 0,
    predicted_onset_date       TIMESTAMPTZ,
    predicted_peak_date        TIMESTAMPTZ,
    treatment_window_start     TIMESTAMPTZ,
    treatment_window_end       TIMESTAMPTZ,
    recommended_treatments     JSONB DEFAULT '[]',
    version                    BIGINT NOT NULL DEFAULT 1,
    is_active                  BOOLEAN NOT NULL DEFAULT TRUE,
    created_by                 VARCHAR(26) NOT NULL,
    created_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by                 VARCHAR(26),
    updated_at                 TIMESTAMPTZ,
    deleted_by                 VARCHAR(26),
    deleted_at                 TIMESTAMPTZ
);

-- Pest alerts
CREATE TABLE pest_alerts (
    id                BIGSERIAL PRIMARY KEY,
    uuid              VARCHAR(26) NOT NULL UNIQUE,
    tenant_id         VARCHAR(26) NOT NULL,
    prediction_id     BIGINT NOT NULL REFERENCES pest_predictions(id),
    prediction_uuid   VARCHAR(26) NOT NULL,
    farm_id           VARCHAR(26) NOT NULL,
    field_id          VARCHAR(26) NOT NULL,
    pest_species_id   BIGINT NOT NULL REFERENCES pest_species(id),
    pest_species_uuid VARCHAR(26) NOT NULL,
    risk_level        risk_level NOT NULL,
    status            alert_status NOT NULL DEFAULT 'ACTIVE',
    title             VARCHAR(500) NOT NULL,
    message           TEXT NOT NULL,
    acknowledged_at   TIMESTAMPTZ,
    acknowledged_by   VARCHAR(26),
    version           BIGINT NOT NULL DEFAULT 1,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_by        VARCHAR(26) NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        VARCHAR(26),
    updated_at        TIMESTAMPTZ,
    deleted_by        VARCHAR(26),
    deleted_at        TIMESTAMPTZ
);

-- Pest treatments
CREATE TABLE pest_treatments (
    id                BIGSERIAL PRIMARY KEY,
    uuid              VARCHAR(26) NOT NULL UNIQUE,
    tenant_id         VARCHAR(26) NOT NULL,
    farm_id           VARCHAR(26) NOT NULL,
    field_id          VARCHAR(26) NOT NULL,
    pest_species_id   BIGINT NOT NULL REFERENCES pest_species(id),
    pest_species_uuid VARCHAR(26) NOT NULL,
    prediction_id     BIGINT REFERENCES pest_predictions(id),
    prediction_uuid   VARCHAR(26),
    treatment_type    treatment_type NOT NULL,
    product_name      VARCHAR(255) NOT NULL,
    application_rate  VARCHAR(255),
    application_method VARCHAR(255),
    cost              DOUBLE PRECISION DEFAULT 0,
    effectiveness_rating VARCHAR(50),
    applied_by        VARCHAR(26) NOT NULL,
    applied_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes             TEXT,
    version           BIGINT NOT NULL DEFAULT 1,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_by        VARCHAR(26) NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        VARCHAR(26),
    updated_at        TIMESTAMPTZ,
    deleted_by        VARCHAR(26),
    deleted_at        TIMESTAMPTZ
);

-- Pest observations
CREATE TABLE pest_observations (
    id                BIGSERIAL PRIMARY KEY,
    uuid              VARCHAR(26) NOT NULL UNIQUE,
    tenant_id         VARCHAR(26) NOT NULL,
    farm_id           VARCHAR(26) NOT NULL,
    field_id          VARCHAR(26) NOT NULL,
    pest_species_id   BIGINT NOT NULL REFERENCES pest_species(id),
    pest_species_uuid VARCHAR(26) NOT NULL,
    pest_count        INTEGER NOT NULL DEFAULT 0,
    damage_level      damage_level NOT NULL DEFAULT 'NONE',
    trap_type         VARCHAR(100),
    image_url         TEXT,
    location          GEOMETRY(Point, 4326),
    latitude          DOUBLE PRECISION,
    longitude         DOUBLE PRECISION,
    notes             TEXT,
    observed_by       VARCHAR(26) NOT NULL,
    observed_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version           BIGINT NOT NULL DEFAULT 1,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_by        VARCHAR(26) NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        VARCHAR(26),
    updated_at        TIMESTAMPTZ,
    deleted_by        VARCHAR(26),
    deleted_at        TIMESTAMPTZ
);

-- Pest risk maps
CREATE TABLE pest_risk_maps (
    id                BIGSERIAL PRIMARY KEY,
    uuid              VARCHAR(26) NOT NULL UNIQUE,
    tenant_id         VARCHAR(26) NOT NULL,
    pest_species_id   BIGINT NOT NULL REFERENCES pest_species(id),
    pest_species_uuid VARCHAR(26) NOT NULL,
    region            VARCHAR(255) NOT NULL,
    overall_risk_level risk_level NOT NULL DEFAULT 'NONE',
    geojson           TEXT NOT NULL,
    boundary          GEOMETRY(Polygon, 4326),
    valid_from        TIMESTAMPTZ NOT NULL,
    valid_until       TIMESTAMPTZ NOT NULL,
    version           BIGINT NOT NULL DEFAULT 1,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_by        VARCHAR(26) NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by        VARCHAR(26),
    updated_at        TIMESTAMPTZ,
    deleted_by        VARCHAR(26),
    deleted_at        TIMESTAMPTZ
);

-- Indexes for pest_species
CREATE INDEX idx_pest_species_tenant_id ON pest_species(tenant_id);
CREATE INDEX idx_pest_species_common_name ON pest_species(tenant_id, common_name);
CREATE INDEX idx_pest_species_scientific_name ON pest_species(tenant_id, scientific_name);
CREATE INDEX idx_pest_species_active ON pest_species(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Indexes for pest_predictions
CREATE INDEX idx_pest_predictions_tenant_id ON pest_predictions(tenant_id);
CREATE INDEX idx_pest_predictions_farm_id ON pest_predictions(tenant_id, farm_id);
CREATE INDEX idx_pest_predictions_field_id ON pest_predictions(tenant_id, field_id);
CREATE INDEX idx_pest_predictions_species ON pest_predictions(pest_species_id);
CREATE INDEX idx_pest_predictions_risk ON pest_predictions(tenant_id, risk_level);
CREATE INDEX idx_pest_predictions_date ON pest_predictions(tenant_id, prediction_date DESC);
CREATE INDEX idx_pest_predictions_active ON pest_predictions(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Indexes for pest_alerts
CREATE INDEX idx_pest_alerts_tenant_id ON pest_alerts(tenant_id);
CREATE INDEX idx_pest_alerts_farm_id ON pest_alerts(tenant_id, farm_id);
CREATE INDEX idx_pest_alerts_field_id ON pest_alerts(tenant_id, field_id);
CREATE INDEX idx_pest_alerts_status ON pest_alerts(tenant_id, status);
CREATE INDEX idx_pest_alerts_risk ON pest_alerts(tenant_id, risk_level);
CREATE INDEX idx_pest_alerts_prediction ON pest_alerts(prediction_id);
CREATE INDEX idx_pest_alerts_active ON pest_alerts(tenant_id, is_active) WHERE is_active = TRUE AND deleted_at IS NULL;

-- Indexes for pest_treatments
CREATE INDEX idx_pest_treatments_tenant_id ON pest_treatments(tenant_id);
CREATE INDEX idx_pest_treatments_farm_id ON pest_treatments(tenant_id, farm_id);
CREATE INDEX idx_pest_treatments_prediction ON pest_treatments(prediction_id);
CREATE INDEX idx_pest_treatments_species ON pest_treatments(pest_species_id);

-- Indexes for pest_observations
CREATE INDEX idx_pest_observations_tenant_id ON pest_observations(tenant_id);
CREATE INDEX idx_pest_observations_farm_id ON pest_observations(tenant_id, farm_id);
CREATE INDEX idx_pest_observations_field_id ON pest_observations(tenant_id, field_id);
CREATE INDEX idx_pest_observations_species ON pest_observations(pest_species_id);
CREATE INDEX idx_pest_observations_date ON pest_observations(tenant_id, observed_at DESC);
CREATE INDEX idx_pest_observations_location ON pest_observations USING GIST(location);

-- Indexes for pest_risk_maps
CREATE INDEX idx_pest_risk_maps_tenant_id ON pest_risk_maps(tenant_id);
CREATE INDEX idx_pest_risk_maps_species ON pest_risk_maps(pest_species_id);
CREATE INDEX idx_pest_risk_maps_region ON pest_risk_maps(tenant_id, region);
CREATE INDEX idx_pest_risk_maps_boundary ON pest_risk_maps USING GIST(boundary);
CREATE INDEX idx_pest_risk_maps_validity ON pest_risk_maps(valid_from, valid_until);
