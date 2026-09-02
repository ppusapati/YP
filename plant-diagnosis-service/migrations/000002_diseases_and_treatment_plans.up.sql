-- ============================================================================
-- Plant Diagnosis Service: Migration 002 — diseases + treatment_plans
-- ============================================================================

-- ============================================================================
-- Table: diseases (reference data)
-- ============================================================================
CREATE TABLE IF NOT EXISTS diseases (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    disease_name        TEXT            NOT NULL,
    scientific_name     TEXT,
    confidence_score    DOUBLE PRECISION DEFAULT 0,
    severity            TEXT            DEFAULT 'SEVERITY_UNSPECIFIED',
    description         TEXT,
    symptoms            TEXT,
    treatment_options   TEXT[],
    prevention          TEXT,

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE diseases ENABLE ROW LEVEL SECURITY;
ALTER TABLE diseases FORCE ROW LEVEL SECURITY;

CREATE POLICY diseases_select_policy ON diseases
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY diseases_insert_policy ON diseases
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY diseases_update_policy ON diseases
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY diseases_delete_policy ON diseases
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_diseases_tenant_id ON diseases (tenant_id);
CREATE INDEX idx_diseases_name ON diseases (tenant_id, disease_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_diseases_scientific_name ON diseases (tenant_id, scientific_name) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_diseases_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_diseases_set_updated_at
    BEFORE UPDATE ON diseases
    FOR EACH ROW
    EXECUTE FUNCTION trg_diseases_updated_at();

-- ============================================================================
-- Table: treatment_plans
-- ============================================================================
CREATE TABLE IF NOT EXISTS treatment_plans (
    id                  CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           CHAR(26)        NOT NULL,

    diagnosis_id        CHAR(26)        NOT NULL REFERENCES diagnosis_requests(id),

    title               TEXT,
    description         TEXT,
    priority            TEXT            DEFAULT 'SEVERITY_UNSPECIFIED',
    steps               JSONB           DEFAULT '[]',
    estimated_cost      TEXT,
    estimated_days      INTEGER,

    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- RLS
ALTER TABLE treatment_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatment_plans FORCE ROW LEVEL SECURITY;

CREATE POLICY treatment_plans_select_policy ON treatment_plans
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY treatment_plans_insert_policy ON treatment_plans
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY treatment_plans_update_policy ON treatment_plans
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY treatment_plans_delete_policy ON treatment_plans
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_treatment_plans_tenant_id ON treatment_plans (tenant_id);
CREATE INDEX idx_treatment_plans_diagnosis_id ON treatment_plans (tenant_id, diagnosis_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_treatment_plans_created_at ON treatment_plans (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_treatment_plans_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_treatment_plans_set_updated_at
    BEFORE UPDATE ON treatment_plans
    FOR EACH ROW
    EXECUTE FUNCTION trg_treatment_plans_updated_at();
