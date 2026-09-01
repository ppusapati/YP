-- ============================================================================
-- Plant Diagnosis Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: diagnosis_requests
-- ============================================================================
CREATE TABLE IF NOT EXISTS diagnosis_requests (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    farm_id             CHAR(26),
    field_id            CHAR(26),
    plant_species_id    CHAR(26),

    -- request details
    status              TEXT            NOT NULL DEFAULT 'DIAGNOSIS_STATUS_PENDING',
    notes               TEXT,

    -- images stored as JSONB array of {image_url, image_type, size_bytes, mime_type, checksum}
    images              JSONB           DEFAULT '[]',

    -- versioning
    version             INTEGER         NOT NULL DEFAULT 1,

    -- audit
    created_by          CHAR(26),
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE diagnosis_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnosis_requests FORCE ROW LEVEL SECURITY;

CREATE POLICY diagnosis_requests_select_policy ON diagnosis_requests
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY diagnosis_requests_insert_policy ON diagnosis_requests
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY diagnosis_requests_update_policy ON diagnosis_requests
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY diagnosis_requests_delete_policy ON diagnosis_requests
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_diagnosis_requests_tenant_id ON diagnosis_requests (tenant_id);
CREATE INDEX idx_diagnosis_requests_farm_id ON diagnosis_requests (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_requests_field_id ON diagnosis_requests (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_requests_status ON diagnosis_requests (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_requests_created_at ON diagnosis_requests (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_diagnosis_requests_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_diagnosis_requests_set_updated_at
    BEFORE UPDATE ON diagnosis_requests
    FOR EACH ROW
    EXECUTE FUNCTION trg_diagnosis_requests_updated_at();

-- ============================================================================
-- Table: diagnosis_results
-- ============================================================================
CREATE TABLE IF NOT EXISTS diagnosis_results (
    id                          CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id                   CHAR(26)        NOT NULL,

    -- relationships
    diagnosis_request_id        CHAR(26)        NOT NULL REFERENCES diagnosis_requests(id) ON DELETE CASCADE,

    -- species identification
    identified_species          JSONB,

    -- diagnosis findings (stored as JSONB arrays)
    detected_diseases           JSONB           DEFAULT '[]',
    nutrient_deficiencies       JSONB           DEFAULT '[]',
    pest_damage                 JSONB           DEFAULT '[]',
    treatment_recommendations   TEXT[],

    -- AI metadata
    ai_model_version            TEXT,
    processing_time_ms          BIGINT,

    -- overall assessment
    overall_health_score        DOUBLE PRECISION,
    summary                     TEXT,

    -- audit
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ
);

-- RLS
ALTER TABLE diagnosis_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnosis_results FORCE ROW LEVEL SECURITY;

CREATE POLICY diagnosis_results_select_policy ON diagnosis_results
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY diagnosis_results_insert_policy ON diagnosis_results
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY diagnosis_results_update_policy ON diagnosis_results
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY diagnosis_results_delete_policy ON diagnosis_results
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_diagnosis_results_tenant_id ON diagnosis_results (tenant_id);
CREATE INDEX idx_diagnosis_results_request_id ON diagnosis_results (tenant_id, diagnosis_request_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_results_health_score ON diagnosis_results (tenant_id, overall_health_score) WHERE deleted_at IS NULL;
CREATE INDEX idx_diagnosis_results_created_at ON diagnosis_results (tenant_id, created_at DESC) WHERE deleted_at IS NULL;
