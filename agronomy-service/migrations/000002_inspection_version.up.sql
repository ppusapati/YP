-- A version column for inspections, so an edit can say what it was based on.
--
-- Two agronomists can now hold the same draft open — one in the field, one at
-- a desk — and the real-time session versions each form field so the loser of
-- a race is told rather than silently overwritten. That check is only worth
-- anything if it survives the round trip to the database: without a stored
-- version, a client that reloads starts from version zero and its next write
-- replaces whatever arrived while it was away.
--
-- Starts at 1 rather than 0, so "I am writing this for the first time"
-- (version 0) cannot match an inspection that already exists.
ALTER TABLE inspections
    ADD COLUMN IF NOT EXISTS version BIGINT NOT NULL DEFAULT 1;
