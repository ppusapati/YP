-- ============================================================================
-- Task Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Table: tasks
-- ============================================================================
CREATE TABLE IF NOT EXISTS tasks (
    id              CHAR(26)        PRIMARY KEY,
    tenant_id       CHAR(26)        NOT NULL,

    -- core fields
    title           TEXT            NOT NULL,
    description     TEXT,
    status          TEXT            NOT NULL DEFAULT 'TASK_STATUS_PENDING',
    priority        TEXT            NOT NULL DEFAULT 'TASK_PRIORITY_MEDIUM',
    assigned_to     CHAR(26),
    farm_id         CHAR(26)        NOT NULL,
    field_id        CHAR(26),
    due_date        TIMESTAMPTZ,

    -- audit
    created_by      CHAR(26)        NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE
);

-- RLS
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks FORCE ROW LEVEL SECURITY;

CREATE POLICY tasks_select_policy ON tasks
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY tasks_insert_policy ON tasks
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY tasks_update_policy ON tasks
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY tasks_delete_policy ON tasks
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Indexes
CREATE INDEX idx_tasks_tenant_id ON tasks (tenant_id);
CREATE INDEX idx_tasks_farm_id ON tasks (tenant_id, farm_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_assigned_to ON tasks (tenant_id, assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_status ON tasks (tenant_id, status) WHERE deleted_at IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_tasks_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tasks_set_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION trg_tasks_updated_at();

-- ============================================================================
-- Table: outbox_events (transactional outbox for event publishing)
-- ============================================================================
CREATE TABLE IF NOT EXISTS outbox_events (
    id          BIGSERIAL   PRIMARY KEY,
    topic       TEXT        NOT NULL,
    event_key   TEXT        NOT NULL,
    payload     BYTEA       NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_outbox_events_created_at ON outbox_events (created_at);
