-- ============================================================================
-- Auth Service: Hash refresh tokens for secure storage
-- ============================================================================

-- Rename column to make the storage semantics explicit.
ALTER TABLE sessions RENAME COLUMN refresh_token TO refresh_token_hash;

-- Drop the old partial index (column name changed).
DROP INDEX IF EXISTS idx_sessions_refresh_token;

-- Recreate with the new column name.
CREATE INDEX idx_sessions_refresh_token_hash ON sessions (refresh_token_hash) WHERE is_revoked = false;
