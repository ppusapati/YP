-- ============================================================================
-- Auth Service: Remove RLS from users and sessions tables
-- ============================================================================

-- Drop sessions policies
DROP POLICY IF EXISTS sessions_select_policy ON sessions;
DROP POLICY IF EXISTS sessions_insert_policy ON sessions;
DROP POLICY IF EXISTS sessions_update_policy ON sessions;
DROP POLICY IF EXISTS sessions_delete_policy ON sessions;

ALTER TABLE sessions DISABLE ROW LEVEL SECURITY;

DROP INDEX IF EXISTS idx_sessions_tenant_id;
ALTER TABLE sessions DROP COLUMN IF EXISTS tenant_id;

-- Drop users policies
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
