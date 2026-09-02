-- ============================================================================
-- Auth Service: Initial Schema Migration (UP)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: users
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id              CHAR(26)        PRIMARY KEY,
    tenant_id       CHAR(26)        NOT NULL,
    email           TEXT            NOT NULL,
    password_hash   TEXT            NOT NULL,
    name            TEXT            NOT NULL DEFAULT '',
    role            TEXT            NOT NULL DEFAULT 'viewer',
    is_active       BOOLEAN         NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_users_email ON users (email) WHERE is_active = true;
CREATE INDEX idx_users_tenant_id ON users (tenant_id);

-- ============================================================================
-- Table: sessions
-- ============================================================================
CREATE TABLE IF NOT EXISTS sessions (
    id              CHAR(26)        PRIMARY KEY,
    user_id         CHAR(26)        NOT NULL REFERENCES users(id),
    refresh_token   TEXT            NOT NULL UNIQUE,
    ip_address      TEXT,
    user_agent      TEXT,
    expires_at      TIMESTAMPTZ     NOT NULL,
    is_revoked      BOOLEAN         NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON sessions (user_id);
CREATE INDEX idx_sessions_refresh_token ON sessions (refresh_token) WHERE is_revoked = false;

-- Trigger: auto-update updated_at on users
CREATE OR REPLACE FUNCTION trg_users_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trg_users_updated_at();
