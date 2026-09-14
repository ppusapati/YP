-- ============================================================================
-- Alert Service: Initial Schema (UP)
--
-- The service had no schema at all. Its handlers returned fabricated protos —
-- acknowledging an alert built a response saying it was acknowledged and wrote
-- nothing — so every alert this platform raised was lost the moment it was
-- logged.
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Table: alerts
--
-- One row per alert, whatever raised it. Weather, sensor and pest alerts land
-- in the same table on purpose: a farmer wants one list of what needs
-- attention on a field, not three lists to reconcile.
-- ============================================================================
CREATE TABLE IF NOT EXISTS alerts (
    id               CHAR(26)     PRIMARY KEY,
    tenant_id        CHAR(26)     NOT NULL,
    field_id         CHAR(26)     NOT NULL,
    farm_id          CHAR(26),
    field_name       TEXT         NOT NULL DEFAULT '',

    alert_type       TEXT         NOT NULL,
    severity         TEXT         NOT NULL,
    status           TEXT         NOT NULL DEFAULT 'ACTIVE',
    title            TEXT         NOT NULL,
    message          TEXT         NOT NULL DEFAULT '',
    read             BOOLEAN      NOT NULL DEFAULT FALSE,
    action_url       TEXT         NOT NULL DEFAULT '',

    -- Which service raised it, and that service's own id for it.
    --
    -- The pair is what makes the Kafka consumer safe. Delivery is at-least-once
    -- and a rebalance replays whatever was in flight, so without a uniqueness
    -- constraint the same frost warning would appear in the farmer's list three
    -- or four times and the list would stop being trusted. The consumer relies
    -- on this index rather than on checking first, because checking first races
    -- against a second consumer in the same group.
    source           TEXT         NOT NULL DEFAULT 'alert-service',
    source_alert_id  TEXT,

    metric_value     DOUBLE PRECISION NOT NULL DEFAULT 0,
    threshold_value  DOUBLE PRECISION NOT NULL DEFAULT 0,
    metrics          JSONB        NOT NULL DEFAULT '{}'::JSONB,
    recommendations  TEXT[]       NOT NULL DEFAULT ARRAY[]::TEXT[],

    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    acknowledged_at  TIMESTAMPTZ,
    acknowledged_by  TEXT         NOT NULL DEFAULT '',
    resolved_at      TIMESTAMPTZ,
    resolved_by      TEXT         NOT NULL DEFAULT '',
    expires_at       TIMESTAMPTZ,

    CONSTRAINT chk_alerts_severity CHECK (
        severity IN ('INFO', 'WARNING', 'CRITICAL', 'EMERGENCY')),
    CONSTRAINT chk_alerts_status CHECK (
        status IN ('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED', 'EXPIRED'))
);

-- Partial, because an alert raised through the API has no upstream id and
-- several such rows would otherwise collide on a shared NULL under some
-- collation settings. Only externally-sourced alerts need deduplicating.
CREATE UNIQUE INDEX IF NOT EXISTS uq_alerts_source_id
    ON alerts (tenant_id, source, source_alert_id)
    WHERE source_alert_id IS NOT NULL;

-- The list a farmer opens: this field, newest first, unresolved.
CREATE INDEX IF NOT EXISTS idx_alerts_field_created
    ON alerts (tenant_id, field_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_farm_created
    ON alerts (tenant_id, farm_id, created_at DESC);

-- The unread badge. Partial so the index stays small as resolved alerts
-- accumulate — it only has to cover the rows the count actually looks at.
CREATE INDEX IF NOT EXISTS idx_alerts_unread
    ON alerts (tenant_id, farm_id)
    WHERE read = FALSE AND status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS idx_alerts_status
    ON alerts (tenant_id, status, created_at DESC);

-- Drives expiry without scanning the whole table.
CREATE INDEX IF NOT EXISTS idx_alerts_expiry
    ON alerts (expires_at)
    WHERE expires_at IS NOT NULL AND status = 'ACTIVE';

ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts FORCE ROW LEVEL SECURITY;

CREATE POLICY alerts_tenant_policy ON alerts
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: alert_rules
--
-- User-configurable thresholds. Distinct from the defaults compiled into the
-- Rust alert-engine: those are what a field gets before anyone has an opinion.
-- ============================================================================
CREATE TABLE IF NOT EXISTS alert_rules (
    id               CHAR(26)     PRIMARY KEY,
    tenant_id        CHAR(26)     NOT NULL,
    field_id         CHAR(26)     NOT NULL,
    farm_id          CHAR(26),

    alert_type       TEXT         NOT NULL DEFAULT '',
    metric           TEXT         NOT NULL,
    condition        TEXT         NOT NULL DEFAULT 'GT',
    threshold        DOUBLE PRECISION NOT NULL DEFAULT 0,
    severity         TEXT         NOT NULL DEFAULT 'WARNING',
    enabled          BOOLEAN      NOT NULL DEFAULT TRUE,
    threshold_json   TEXT         NOT NULL DEFAULT '',
    notify_channels  TEXT[]       NOT NULL DEFAULT ARRAY[]::TEXT[],

    -- Minutes before the same rule may fire again for the same field. Without
    -- it a sensor sitting just over its threshold raises an alert on every
    -- reading, and the farmer turns alerts off entirely.
    cooldown_minutes INTEGER      NOT NULL DEFAULT 60,
    last_fired_at    TIMESTAMPTZ,

    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at       TIMESTAMPTZ,

    CONSTRAINT chk_alert_rules_severity CHECK (
        severity IN ('INFO', 'WARNING', 'CRITICAL', 'EMERGENCY')),
    CONSTRAINT chk_alert_rules_cooldown CHECK (cooldown_minutes >= 0)
);

CREATE INDEX IF NOT EXISTS idx_alert_rules_field
    ON alert_rules (tenant_id, field_id)
    WHERE deleted_at IS NULL;

-- One rule per metric per field. Two rules on the same metric would both fire
-- and raise duplicate alerts for a single condition.
CREATE UNIQUE INDEX IF NOT EXISTS uq_alert_rules_field_metric
    ON alert_rules (tenant_id, field_id, metric)
    WHERE deleted_at IS NULL;

ALTER TABLE alert_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE alert_rules FORCE ROW LEVEL SECURITY;

CREATE POLICY alert_rules_tenant_policy ON alert_rules
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: field_risk_scores
--
-- The latest risk evaluation per field, one row each.
--
-- GetFieldRisk asks the AI gateway live, which is right for a single field a
-- user is looking at. ListFieldRisks cannot do that — a fan-out of one gateway
-- call per field to render a farm overview is slow and falls over when the
-- gateway does. This table is what that listing reads, refreshed as
-- evaluations happen.
-- ============================================================================
CREATE TABLE IF NOT EXISTS field_risk_scores (
    tenant_id        CHAR(26)     NOT NULL,
    field_id         CHAR(26)     NOT NULL,
    farm_id          CHAR(26),
    field_name       TEXT         NOT NULL DEFAULT '',

    overall_score    DOUBLE PRECISION NOT NULL DEFAULT 0,
    risk_factors     JSONB        NOT NULL DEFAULT '{}'::JSONB,
    trend            TEXT         NOT NULL DEFAULT '',

    calculated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    PRIMARY KEY (tenant_id, field_id),
    CONSTRAINT chk_field_risk_score CHECK (overall_score BETWEEN 0 AND 1)
);

CREATE INDEX IF NOT EXISTS idx_field_risk_farm
    ON field_risk_scores (tenant_id, farm_id, overall_score DESC);

ALTER TABLE field_risk_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_risk_scores FORCE ROW LEVEL SECURITY;

CREATE POLICY field_risk_scores_tenant_policy ON field_risk_scores
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
