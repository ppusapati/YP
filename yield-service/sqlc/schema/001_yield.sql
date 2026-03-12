-- Yield Predictions table
CREATE TABLE IF NOT EXISTS yield_predictions (
    id                          BIGSERIAL PRIMARY KEY,
    uuid                        VARCHAR(26) NOT NULL UNIQUE,
    tenant_id                   VARCHAR(26) NOT NULL,
    farm_id                     VARCHAR(26) NOT NULL,
    field_id                    VARCHAR(26) NOT NULL,
    crop_id                     VARCHAR(26) NOT NULL,
    season                      VARCHAR(50) NOT NULL,
    year                        INTEGER NOT NULL,
    predicted_yield_kg_per_hectare DOUBLE PRECISION NOT NULL DEFAULT 0,
    prediction_confidence_pct   DOUBLE PRECISION NOT NULL DEFAULT 0,
    prediction_model_version    VARCHAR(50) NOT NULL DEFAULT 'v1.0',
    status                      VARCHAR(30) NOT NULL DEFAULT 'pending',
    -- Yield factors stored as individual columns for query flexibility
    soil_quality_score          DOUBLE PRECISION NOT NULL DEFAULT 0,
    weather_score               DOUBLE PRECISION NOT NULL DEFAULT 0,
    irrigation_score            DOUBLE PRECISION NOT NULL DEFAULT 0,
    pest_pressure_score         DOUBLE PRECISION NOT NULL DEFAULT 0,
    nutrient_score              DOUBLE PRECISION NOT NULL DEFAULT 0,
    management_score            DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_active                   BOOLEAN NOT NULL DEFAULT TRUE,
    version                     BIGINT NOT NULL DEFAULT 1,
    created_by                  VARCHAR(26) NOT NULL,
    updated_by                  VARCHAR(26),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ,
    deleted_by                  VARCHAR(26),
    deleted_at                  TIMESTAMPTZ
);

CREATE INDEX idx_yield_predictions_tenant ON yield_predictions(tenant_id);
CREATE INDEX idx_yield_predictions_farm ON yield_predictions(farm_id);
CREATE INDEX idx_yield_predictions_field ON yield_predictions(field_id);
CREATE INDEX idx_yield_predictions_crop ON yield_predictions(crop_id);
CREATE INDEX idx_yield_predictions_season_year ON yield_predictions(season, year);
CREATE INDEX idx_yield_predictions_status ON yield_predictions(status);

-- Yield Records table (actual harvest data)
CREATE TABLE IF NOT EXISTS yield_records (
    id                          BIGSERIAL PRIMARY KEY,
    uuid                        VARCHAR(26) NOT NULL UNIQUE,
    tenant_id                   VARCHAR(26) NOT NULL,
    farm_id                     VARCHAR(26) NOT NULL,
    field_id                    VARCHAR(26) NOT NULL,
    crop_id                     VARCHAR(26) NOT NULL,
    season                      VARCHAR(50) NOT NULL,
    year                        INTEGER NOT NULL,
    actual_yield_kg_per_hectare DOUBLE PRECISION NOT NULL DEFAULT 0,
    total_area_harvested_hectares DOUBLE PRECISION NOT NULL DEFAULT 0,
    total_yield_kg              DOUBLE PRECISION NOT NULL DEFAULT 0,
    harvest_quality_grade       VARCHAR(10) NOT NULL DEFAULT 'B',
    moisture_content_pct        DOUBLE PRECISION NOT NULL DEFAULT 0,
    harvest_date                TIMESTAMPTZ,
    revenue_per_hectare         DOUBLE PRECISION NOT NULL DEFAULT 0,
    cost_per_hectare            DOUBLE PRECISION NOT NULL DEFAULT 0,
    profit_per_hectare          DOUBLE PRECISION NOT NULL DEFAULT 0,
    prediction_id               VARCHAR(26),
    is_active                   BOOLEAN NOT NULL DEFAULT TRUE,
    version                     BIGINT NOT NULL DEFAULT 1,
    created_by                  VARCHAR(26) NOT NULL,
    updated_by                  VARCHAR(26),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ,
    deleted_by                  VARCHAR(26),
    deleted_at                  TIMESTAMPTZ
);

CREATE INDEX idx_yield_records_tenant ON yield_records(tenant_id);
CREATE INDEX idx_yield_records_farm ON yield_records(farm_id);
CREATE INDEX idx_yield_records_field ON yield_records(field_id);
CREATE INDEX idx_yield_records_crop ON yield_records(crop_id);
CREATE INDEX idx_yield_records_season_year ON yield_records(season, year);
CREATE INDEX idx_yield_records_harvest_date ON yield_records(harvest_date);
CREATE INDEX idx_yield_records_prediction ON yield_records(prediction_id);

-- Harvest Plans table
CREATE TABLE IF NOT EXISTS harvest_plans (
    id                      BIGSERIAL PRIMARY KEY,
    uuid                    VARCHAR(26) NOT NULL UNIQUE,
    tenant_id               VARCHAR(26) NOT NULL,
    farm_id                 VARCHAR(26) NOT NULL,
    field_id                VARCHAR(26) NOT NULL,
    crop_id                 VARCHAR(26) NOT NULL,
    season                  VARCHAR(50) NOT NULL,
    year                    INTEGER NOT NULL,
    planned_start_date      TIMESTAMPTZ NOT NULL,
    planned_end_date        TIMESTAMPTZ NOT NULL,
    estimated_yield_kg      DOUBLE PRECISION NOT NULL DEFAULT 0,
    total_area_hectares     DOUBLE PRECISION NOT NULL DEFAULT 0,
    status                  VARCHAR(30) NOT NULL DEFAULT 'draft',
    notes                   TEXT,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    version                 BIGINT NOT NULL DEFAULT 1,
    created_by              VARCHAR(26) NOT NULL,
    updated_by              VARCHAR(26),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ,
    deleted_by              VARCHAR(26),
    deleted_at              TIMESTAMPTZ
);

CREATE INDEX idx_harvest_plans_tenant ON harvest_plans(tenant_id);
CREATE INDEX idx_harvest_plans_farm ON harvest_plans(farm_id);
CREATE INDEX idx_harvest_plans_field ON harvest_plans(field_id);
CREATE INDEX idx_harvest_plans_status ON harvest_plans(status);
CREATE INDEX idx_harvest_plans_season_year ON harvest_plans(season, year);
CREATE INDEX idx_harvest_plans_dates ON harvest_plans(planned_start_date, planned_end_date);

-- Crop Performance analytics table
CREATE TABLE IF NOT EXISTS crop_performance (
    id                                  BIGSERIAL PRIMARY KEY,
    uuid                                VARCHAR(26) NOT NULL UNIQUE,
    tenant_id                           VARCHAR(26) NOT NULL,
    farm_id                             VARCHAR(26) NOT NULL,
    field_id                            VARCHAR(26) NOT NULL,
    crop_id                             VARCHAR(26) NOT NULL,
    season                              VARCHAR(50) NOT NULL,
    year                                INTEGER NOT NULL,
    actual_yield_kg_per_hectare         DOUBLE PRECISION NOT NULL DEFAULT 0,
    predicted_yield_kg_per_hectare      DOUBLE PRECISION NOT NULL DEFAULT 0,
    yield_variance_pct                  DOUBLE PRECISION NOT NULL DEFAULT 0,
    comparison_to_regional_avg_pct      DOUBLE PRECISION NOT NULL DEFAULT 0,
    comparison_to_historical_avg_pct    DOUBLE PRECISION NOT NULL DEFAULT 0,
    revenue_per_hectare                 DOUBLE PRECISION NOT NULL DEFAULT 0,
    cost_per_hectare                    DOUBLE PRECISION NOT NULL DEFAULT 0,
    profit_per_hectare                  DOUBLE PRECISION NOT NULL DEFAULT 0,
    -- Yield factors for this performance period
    soil_quality_score                  DOUBLE PRECISION NOT NULL DEFAULT 0,
    weather_score                       DOUBLE PRECISION NOT NULL DEFAULT 0,
    irrigation_score                    DOUBLE PRECISION NOT NULL DEFAULT 0,
    pest_pressure_score                 DOUBLE PRECISION NOT NULL DEFAULT 0,
    nutrient_score                      DOUBLE PRECISION NOT NULL DEFAULT 0,
    management_score                    DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_active                           BOOLEAN NOT NULL DEFAULT TRUE,
    version                             BIGINT NOT NULL DEFAULT 1,
    created_at                          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                          TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_crop_performance_unique ON crop_performance(tenant_id, farm_id, field_id, crop_id, season, year);
CREATE INDEX idx_crop_performance_farm ON crop_performance(farm_id);
CREATE INDEX idx_crop_performance_crop ON crop_performance(crop_id);
CREATE INDEX idx_crop_performance_season_year ON crop_performance(season, year);
