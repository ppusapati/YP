-- ============================================================================
-- Irrigation Service: Actuation Migration (UP)
--
-- The two things the actuator needs and the schema did not have: somewhere to
-- record a command, and somewhere to keep a zone's safety limits.
--
-- Until now "turn on zone 3" was a row in irrigation_events written at start
-- time and never revised. Nothing dialled a controller, so there was no send
-- to record the outcome of, and no limits to check it against.
-- ============================================================================

-- ============================================================================
-- Table: irrigation_commands
--
-- One row per instruction sent to a controller, written BEFORE the send.
--
-- Written first because a send that times out otherwise leaves a valve that
-- may be open and no row saying so, which is the state nobody can reason about
-- afterwards. The outcome columns are filled in after, and stay NULL for a
-- command whose fate is genuinely unknown — that is information, not a gap.
-- ============================================================================
CREATE TABLE IF NOT EXISTS irrigation_commands (
    -- The command id doubles as the idempotency key the controller sees.
    -- Controllers are reached over lossy links, so a retry carries the same id
    -- and the controller recognises the repeat instead of opening the valve
    -- a second time.
    id                  CHAR(26)        PRIMARY KEY,
    tenant_id           CHAR(26)        NOT NULL,

    -- relationships
    zone_id             CHAR(26)        REFERENCES irrigation_zones(id),
    controller_id       CHAR(26),

    -- the instruction
    kind                TEXT            NOT NULL,
    duration_minutes    INTEGER         NOT NULL DEFAULT 0,
    liters_requested    DOUBLE PRECISION,

    -- why it was issued. An automatic command nobody can explain afterwards is
    -- indistinguishable from a malfunction, so this is NOT NULL.
    reason              TEXT            NOT NULL,
    issued_by           TEXT            NOT NULL,
    issued_at           TIMESTAMPTZ     NOT NULL,

    -- the outcome, filled in after the send.
    --
    -- accepted NULL means the send neither succeeded nor failed as far as this
    -- service knows — a timeout. Distinguished from FALSE, which is a
    -- controller that answered and said no.
    accepted            BOOLEAN,
    outcome_detail      TEXT,
    settled_at          TIMESTAMPTZ,

    -- audit
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE irrigation_commands ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_commands FORCE ROW LEVEL SECURITY;

CREATE POLICY irrigation_commands_select_policy ON irrigation_commands
    FOR SELECT USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_commands_insert_policy ON irrigation_commands
    FOR INSERT WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

CREATE POLICY irrigation_commands_update_policy ON irrigation_commands
    FOR UPDATE USING (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    ) WITH CHECK (
        tenant_id = current_setting('app.tenant_id', true)::CHAR(26)
    );

-- No delete policy, and that is deliberate. A command is a record of an
-- instruction sent to equipment on a real farm; it is the thing an operator
-- reads when asking why a field flooded at three in the morning.

-- Indexes
CREATE INDEX idx_irrigation_commands_tenant_id ON irrigation_commands (tenant_id);
CREATE INDEX idx_irrigation_commands_zone_id ON irrigation_commands (tenant_id, zone_id, issued_at DESC);
-- Partial, because the reconciliation that settles unknown sends looks only at
-- these and there are very few of them.
CREATE INDEX idx_irrigation_commands_unsettled ON irrigation_commands (tenant_id, issued_at)
    WHERE accepted IS NULL;

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION trg_irrigation_commands_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_irrigation_commands_set_updated_at
    BEFORE UPDATE ON irrigation_commands
    FOR EACH ROW
    EXECUTE FUNCTION trg_irrigation_commands_updated_at();

-- ============================================================================
-- Zone safety limits
--
-- Nullable rather than defaulted, so that "this zone has no override" is
-- distinguishable from "somebody set it to the same value the code uses". The
-- application substitutes the package defaults for NULL.
-- ============================================================================
ALTER TABLE irrigation_zones
    ADD COLUMN IF NOT EXISTS max_run_minutes   INTEGER,
    ADD COLUMN IF NOT EXISTS min_rest_minutes  INTEGER,
    ADD COLUMN IF NOT EXISTS max_daily_minutes INTEGER;

-- Automatic is NOT NULL DEFAULT FALSE, and the default is the point.
--
-- Unattended irrigation is something a farmer opts into for a zone they have
-- watched behave, not something that starts happening because a sensor was
-- installed. A nullable column read as "unset, so allow" would turn every
-- existing zone into an automatic one the moment this shipped.
ALTER TABLE irrigation_zones
    ADD COLUMN IF NOT EXISTS automatic BOOLEAN NOT NULL DEFAULT FALSE;
