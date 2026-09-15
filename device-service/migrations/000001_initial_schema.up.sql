-- ============================================================================
-- Device Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Table: devices
--
-- `status` is deliberately NOT a column. A device that stops reporting never
-- writes "offline" — that is exactly what it has stopped doing — so a stored
-- status is only ever as fresh as the last thing that wrote it. Status is
-- derived from last_seen_at, fault and retired_at on read.
-- ============================================================================
CREATE TABLE IF NOT EXISTS devices (
    id                    CHAR(26)         PRIMARY KEY,
    tenant_id             CHAR(26)         NOT NULL,

    serial                TEXT             NOT NULL,
    name                  TEXT             NOT NULL DEFAULT '',
    kind                  TEXT             NOT NULL,

    farm_id               CHAR(26)         NOT NULL DEFAULT '',
    field_id              CHAR(26)         NOT NULL DEFAULT '',
    fleet                 TEXT             NOT NULL DEFAULT 'default',

    firmware_version      TEXT             NOT NULL DEFAULT '',
    hardware_revision     TEXT             NOT NULL DEFAULT '',

    latitude              DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude             DOUBLE PRECISION NOT NULL DEFAULT 0,

    provisioned_at        TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    last_seen_at          TIMESTAMPTZ,
    battery_percent       DOUBLE PRECISION NOT NULL DEFAULT 0,
    signal_dbm            INTEGER          NOT NULL DEFAULT 0,
    fault                 TEXT             NOT NULL DEFAULT '',

    -- The enrolment token is stored as a hash, the same way a password is. A
    -- fleet database that leaks should not hand somebody the credentials to
    -- every irrigation valve in it.
    enrolment_token_hash  TEXT             NOT NULL DEFAULT '',

    retired_at            TIMESTAMPTZ,
    retired_reason        TEXT             NOT NULL DEFAULT '',

    created_at            TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_devices_tenant_serial UNIQUE (tenant_id, serial),
    CONSTRAINT chk_devices_battery CHECK (battery_percent BETWEEN 0 AND 100),
    CONSTRAINT chk_devices_lat CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT chk_devices_lon CHECK (longitude BETWEEN -180 AND 180)
);

CREATE INDEX IF NOT EXISTS idx_devices_fleet ON devices (tenant_id, fleet);
CREATE INDEX IF NOT EXISTS idx_devices_field ON devices (tenant_id, field_id);
-- Partial: the fleet view's most common question is "what has gone quiet",
-- and the retired devices are the bulk of an old fleet.
CREATE INDEX IF NOT EXISTS idx_devices_last_seen
    ON devices (tenant_id, last_seen_at) WHERE retired_at IS NULL;

ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices FORCE ROW LEVEL SECURITY;

CREATE POLICY devices_tenant_policy ON devices
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: firmware_rollouts
-- ============================================================================
CREATE TABLE IF NOT EXISTS firmware_rollouts (
    id                 CHAR(26)         PRIMARY KEY,
    tenant_id          CHAR(26)         NOT NULL,

    fleet              TEXT             NOT NULL,
    kind               TEXT             NOT NULL,

    version            TEXT             NOT NULL,
    artifact_url       TEXT             NOT NULL,
    -- Both required. A URL with no checksum means a device installs whatever
    -- is served at that address.
    artifact_sha256    TEXT             NOT NULL,

    state              TEXT             NOT NULL DEFAULT 'PENDING',
    stage_percent      INTEGER          NOT NULL DEFAULT 10,
    failure_threshold  DOUBLE PRECISION NOT NULL DEFAULT 0.10,

    offered            INTEGER          NOT NULL DEFAULT 0,
    succeeded          INTEGER          NOT NULL DEFAULT 0,
    failed             INTEGER          NOT NULL DEFAULT 0,

    halted_reason      TEXT             NOT NULL DEFAULT '',
    created_by         TEXT             NOT NULL DEFAULT 'system',
    created_at         TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_rollouts_stage CHECK (stage_percent BETWEEN 1 AND 100),
    CONSTRAINT chk_rollouts_threshold CHECK (failure_threshold > 0 AND failure_threshold <= 1),
    CONSTRAINT chk_rollouts_artifact CHECK (artifact_url <> '' AND artifact_sha256 <> '')
);

CREATE INDEX IF NOT EXISTS idx_rollouts_fleet ON firmware_rollouts (tenant_id, fleet, created_at DESC);

ALTER TABLE firmware_rollouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE firmware_rollouts FORCE ROW LEVEL SECURITY;

CREATE POLICY firmware_rollouts_tenant_policy ON firmware_rollouts
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: device_updates
--
-- One row per device per rollout, so a device that reports DOWNLOADING then
-- FAILED leaves one record of where it got to rather than a log to reduce.
-- ============================================================================
CREATE TABLE IF NOT EXISTS device_updates (
    device_id   CHAR(26)    NOT NULL,
    rollout_id  CHAR(26)    NOT NULL,
    tenant_id   CHAR(26)    NOT NULL,
    state       TEXT        NOT NULL,
    detail      TEXT        NOT NULL DEFAULT '',
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (rollout_id, device_id)
);

CREATE INDEX IF NOT EXISTS idx_device_updates_rollout
    ON device_updates (tenant_id, rollout_id, state);

ALTER TABLE device_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_updates FORCE ROW LEVEL SECURITY;

CREATE POLICY device_updates_tenant_policy ON device_updates
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
