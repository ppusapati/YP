-- ============================================================================
-- Yield Service: Harvest Plans Table Migration (UP)
-- ============================================================================

-- ============================================================================
-- Table: harvest_plans
-- ============================================================================
CREATE TABLE IF NOT EXISTS harvest_plans (
    id                      CHAR(26)        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               CHAR(26)        NOT NULL,

    -- relationships
    farm_id                 CHAR(26),
    field_id                CHAR(26),
    crop_id                 CHAR(26),

    -- plan context
    season                  TEXT,
    year                    INTEGER,

    -- plan details
    planned_start_date      TIMESTAMPTZ,
    planned_end_date        TIMESTAMPTZ,
    estimated_yield_kg      DOUBLE PRECISION,
    total_area_hectares     DOUBLE PRECISION,
    status                  TEXT            NOT NULL DEFAULT 'HARVEST_PLAN_STATUS_DRAFT',
    notes                   TEXT,

    -- versioning
    version                 BIGINT          NOT NULL DEFAULT 1,

    -- audit
    created_by              CHAR(26),
    updated_by              CHAR(26),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

-- RLS
ALTER TABLE harvest_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE harvest_plans FORCE ROW LEVEL SECURITY;

CREATE POLICY harvest_plans_select_policy ON harvest_plans
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY harvest_plans_insert_policy ON harvest_plans
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY harvest_plans_update_policy ON harvest_plans
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY harvest_plans_delete_policy ON harvest_plans
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_harvest_plans_tenant_id ON harvest_plans (tenant_id);
CREATE INDEX idx_harvest_plans_farm_id ON harvest_plans (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_harvest_plans_field_id ON harvest_plans (tenant_id, field_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_harvest_plans_crop_id ON harvest_plans (tenant_id, crop_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_harvest_plans_status ON harvest_plans (tenant_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_harvest_plans_created_at ON harvest_plans (tenant_id, created_at DESC) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_harvest_plans_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_harvest_plans_set_updated_at
    BEFORE UPDATE ON harvest_plans
    FOR EACH ROW
    EXECUTE FUNCTION trg_harvest_plans_updated_at();
