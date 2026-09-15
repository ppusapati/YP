-- ============================================================================
-- Auth Service: Add RLS to users and sessions tables
-- ============================================================================

-- Add tenant_id to sessions (backfill existing rows with empty string, then NOT NULL)
ALTER TABLE sessions ADD COLUMN tenant_id CHAR(26) DEFAULT '';
UPDATE sessions SET tenant_id = (SELECT tenant_id FROM users WHERE users.id = sessions.user_id);
ALTER TABLE sessions ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE sessions ALTER COLUMN tenant_id DROP DEFAULT;

-- ============================================================================
-- RLS on users
-- ============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE users FORCE ROW LEVEL SECURITY;

CREATE POLICY users_select_policy ON users
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
        AND deleted_at IS NULL
    );

CREATE POLICY users_insert_policy ON users
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY users_update_policy ON users
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY users_delete_policy ON users
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- ============================================================================
-- RLS on sessions
-- ============================================================================
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions FORCE ROW LEVEL SECURITY;

CREATE POLICY sessions_select_policy ON sessions
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sessions_insert_policy ON sessions
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sessions_update_policy ON sessions
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY sessions_delete_policy ON sessions
    FOR DELETE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- Index
CREATE INDEX idx_sessions_tenant_id ON sessions (tenant_id);
