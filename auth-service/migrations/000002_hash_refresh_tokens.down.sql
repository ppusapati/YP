DROP INDEX IF EXISTS idx_sessions_refresh_token_hash;
ALTER TABLE sessions RENAME COLUMN refresh_token_hash TO refresh_token;
CREATE INDEX idx_sessions_refresh_token ON sessions (refresh_token) WHERE is_revoked = false;
