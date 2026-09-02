-- Outbox events table for transactional event publishing
CREATE TABLE IF NOT EXISTS outbox_events (
    id          BIGSERIAL   PRIMARY KEY,
    topic       TEXT        NOT NULL,
    event_key   TEXT        NOT NULL,
    payload     BYTEA       NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_outbox_events_created_at ON outbox_events (created_at);
