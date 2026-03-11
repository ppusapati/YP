-- Plant Diagnosis Service Schema
-- Migration 001: Core diagnosis tables

-- ─────────────────────────────────────────────────────────────────────────────
-- Enum types
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TYPE image_type AS ENUM (
    'LEAF', 'STEM', 'FRUIT', 'WHOLE_PLANT', 'ROOT'
);

CREATE TYPE diagnosis_status AS ENUM (
    'PENDING', 'ANALYZING', 'COMPLETED', 'FAILED'
);

CREATE TYPE severity_level AS ENUM (
    'MILD', 'MODERATE', 'SEVERE', 'CRITICAL'
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Disease catalog: reference data for known plant diseases
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE disease_catalog (
    id              BIGSERIAL    PRIMARY KEY,
    uuid            VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id       VARCHAR(26)  NOT NULL,
    disease_name    VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255),
    description     TEXT,
    symptoms        TEXT,
    treatment_options JSONB      DEFAULT '[]'::jsonb,
    prevention      TEXT,
    affected_species JSONB       DEFAULT '[]'::jsonb,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(26)  NOT NULL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by      VARCHAR(26),
    updated_at      TIMESTAMPTZ,
    deleted_by      VARCHAR(26),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_disease_catalog_tenant ON disease_catalog(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_disease_catalog_name   ON disease_catalog(disease_name) WHERE deleted_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- Nutrient deficiency catalog: reference data for nutrient deficiencies
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE nutrient_deficiency_catalog (
    id                     BIGSERIAL    PRIMARY KEY,
    uuid                   VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id              VARCHAR(26)  NOT NULL,
    nutrient               VARCHAR(100) NOT NULL,
    description            TEXT,
    visual_symptoms        TEXT,
    recommended_fertilizers JSONB       DEFAULT '[]'::jsonb,
    application_method     TEXT,
    affected_species       JSONB        DEFAULT '[]'::jsonb,
    is_active              BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by             VARCHAR(26)  NOT NULL,
    created_at             TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by             VARCHAR(26),
    updated_at             TIMESTAMPTZ,
    deleted_by             VARCHAR(26),
    deleted_at             TIMESTAMPTZ
);

CREATE INDEX idx_nutrient_deficiency_catalog_tenant ON nutrient_deficiency_catalog(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_nutrient_deficiency_catalog_nutrient ON nutrient_deficiency_catalog(nutrient) WHERE deleted_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- Pest catalog: reference data for known pests
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE pest_catalog (
    id               BIGSERIAL    PRIMARY KEY,
    uuid             VARCHAR(26)  NOT NULL UNIQUE,
    tenant_id        VARCHAR(26)  NOT NULL,
    pest_name        VARCHAR(255) NOT NULL,
    scientific_name  VARCHAR(255),
    description      TEXT,
    damage_pattern   TEXT,
    control_methods  JSONB        DEFAULT '[]'::jsonb,
    affected_species JSONB        DEFAULT '[]'::jsonb,
    is_active        BOOLEAN      NOT NULL DEFAULT TRUE,
    created_by       VARCHAR(26)  NOT NULL,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_by       VARCHAR(26),
    updated_at       TIMESTAMPTZ,
    deleted_by       VARCHAR(26),
    deleted_at       TIMESTAMPTZ
);

CREATE INDEX idx_pest_catalog_tenant ON pest_catalog(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_pest_catalog_name   ON pest_catalog(pest_name) WHERE deleted_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- Diagnosis requests: main diagnosis submissions
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE diagnosis_requests (
    id               BIGSERIAL       PRIMARY KEY,
    uuid             VARCHAR(26)     NOT NULL UNIQUE,
    tenant_id        VARCHAR(26)     NOT NULL,
    farm_id          VARCHAR(26)     NOT NULL,
    field_id         VARCHAR(26),
    plant_species_id VARCHAR(26),
    status           diagnosis_status NOT NULL DEFAULT 'PENDING',
    notes            TEXT,
    version          INTEGER         NOT NULL DEFAULT 1,
    is_active        BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by       VARCHAR(26)     NOT NULL,
    created_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_by       VARCHAR(26),
    updated_at       TIMESTAMPTZ,
    deleted_by       VARCHAR(26),
    deleted_at       TIMESTAMPTZ
);

CREATE INDEX idx_diagnosis_requests_tenant   ON diagnosis_requests(tenant_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_requests_farm     ON diagnosis_requests(tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_requests_field    ON diagnosis_requests(tenant_id, farm_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_requests_status   ON diagnosis_requests(tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_requests_created  ON diagnosis_requests(tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- Diagnosis images: images attached to a diagnosis request
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE diagnosis_images (
    id                   BIGSERIAL   PRIMARY KEY,
    uuid                 VARCHAR(26) NOT NULL UNIQUE,
    diagnosis_request_id BIGINT      NOT NULL REFERENCES diagnosis_requests(id) ON DELETE CASCADE,
    image_url            TEXT        NOT NULL,
    image_type           image_type  NOT NULL,
    size_bytes           BIGINT,
    mime_type            VARCHAR(100),
    checksum             VARCHAR(128),
    uploaded_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_diagnosis_images_request ON diagnosis_images(diagnosis_request_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- Diagnosis results: AI inference results for a diagnosis request
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE diagnosis_results (
    id                       BIGSERIAL   PRIMARY KEY,
    uuid                     VARCHAR(26) NOT NULL UNIQUE,
    diagnosis_request_id     BIGINT      NOT NULL REFERENCES diagnosis_requests(id) ON DELETE CASCADE,
    identified_species_id    VARCHAR(26),
    identified_species_name  VARCHAR(255),
    identified_species_conf  DOUBLE PRECISION,
    detected_diseases        JSONB       DEFAULT '[]'::jsonb,
    nutrient_deficiencies    JSONB       DEFAULT '[]'::jsonb,
    pest_damage              JSONB       DEFAULT '[]'::jsonb,
    treatment_recommendations JSONB      DEFAULT '[]'::jsonb,
    ai_model_version         VARCHAR(100) NOT NULL,
    processing_time_ms       BIGINT      NOT NULL DEFAULT 0,
    overall_health_score     DOUBLE PRECISION,
    summary                  TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_diagnosis_results_request ON diagnosis_results(diagnosis_request_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- Treatment plans: actionable treatment plans generated for a diagnosis
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE treatment_plans (
    id                   BIGSERIAL      PRIMARY KEY,
    uuid                 VARCHAR(26)    NOT NULL UNIQUE,
    diagnosis_request_id BIGINT         NOT NULL REFERENCES diagnosis_requests(id) ON DELETE CASCADE,
    title                VARCHAR(255)   NOT NULL,
    description          TEXT,
    priority             severity_level NOT NULL DEFAULT 'MODERATE',
    steps                JSONB          DEFAULT '[]'::jsonb,
    estimated_cost       VARCHAR(100),
    estimated_days       INTEGER,
    is_active            BOOLEAN        NOT NULL DEFAULT TRUE,
    created_by           VARCHAR(26)    NOT NULL,
    created_at           TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_by           VARCHAR(26),
    updated_at           TIMESTAMPTZ,
    deleted_by           VARCHAR(26),
    deleted_at           TIMESTAMPTZ
);

CREATE INDEX idx_treatment_plans_diagnosis ON treatment_plans(diagnosis_request_id) WHERE deleted_at IS NULL;
