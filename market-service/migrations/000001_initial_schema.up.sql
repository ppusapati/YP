-- ============================================================================
-- Market Service: Initial Schema Migration (UP)
-- ============================================================================

-- ============================================================================
-- Table: markets
--
-- A mandi yard or exchange. Tenant-scoped like everything else: two tenants
-- trading at the same physical yard keep their own records of it, because the
-- external reference they use to reconcile with a price feed differs.
-- ============================================================================
CREATE TABLE IF NOT EXISTS markets (
    id            CHAR(26)         PRIMARY KEY,
    tenant_id     CHAR(26)         NOT NULL,
    name          TEXT             NOT NULL,
    kind          TEXT             NOT NULL DEFAULT 'MANDI',
    state         TEXT             NOT NULL DEFAULT '',
    district      TEXT             NOT NULL DEFAULT '',
    latitude      DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude     DOUBLE PRECISION NOT NULL DEFAULT 0,
    external_ref  TEXT             NOT NULL DEFAULT '',
    created_at    TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_markets_lat CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT chk_markets_lon CHECK (longitude BETWEEN -180 AND 180)
);

CREATE INDEX IF NOT EXISTS idx_markets_tenant_region ON markets (tenant_id, state, district);
CREATE UNIQUE INDEX IF NOT EXISTS uq_markets_tenant_external
    ON markets (tenant_id, external_ref) WHERE external_ref <> '';

ALTER TABLE markets ENABLE ROW LEVEL SECURITY;
ALTER TABLE markets FORCE ROW LEVEL SECURITY;

CREATE POLICY markets_tenant_policy ON markets
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: price_quotes
--
-- One commodity's price at one market on one day.
--
-- price_per_quintal is stored rather than computed on read. Mandi feeds quote
-- per quintal, exchanges per tonne and farm-gate offers per kilogram, and a
-- statistic computed across a mix of units is wrong by a factor of a hundred
-- while looking entirely plausible. Normalising once at ingest means every
-- query downstream works in one unit.
-- ============================================================================
CREATE TABLE IF NOT EXISTS price_quotes (
    id                 CHAR(26)         PRIMARY KEY,
    tenant_id          CHAR(26)         NOT NULL,
    commodity          TEXT             NOT NULL,
    variety            TEXT             NOT NULL DEFAULT '',
    market_id          CHAR(26)         NOT NULL,
    market_name        TEXT             NOT NULL DEFAULT '',

    min_price          DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_price          DOUBLE PRECISION NOT NULL DEFAULT 0,
    modal_price        DOUBLE PRECISION NOT NULL,
    unit               TEXT             NOT NULL,
    currency           TEXT             NOT NULL DEFAULT 'INR',
    price_per_quintal  DOUBLE PRECISION NOT NULL,

    arrivals_tonnes    DOUBLE PRECISION NOT NULL DEFAULT 0,
    quoted_on          DATE             NOT NULL,
    source             TEXT             NOT NULL DEFAULT '',
    created_at         TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    -- One quote per commodity, variety, market and day. A feed replayed after
    -- an outage must correct the day's price rather than add a second one that
    -- doubles its weight in every average.
    CONSTRAINT uq_price_quotes UNIQUE (tenant_id, market_id, commodity, variety, quoted_on),
    CONSTRAINT chk_price_quotes_positive CHECK (modal_price >= 0 AND price_per_quintal >= 0)
);

CREATE INDEX IF NOT EXISTS idx_price_quotes_lookup
    ON price_quotes (tenant_id, commodity, market_id, quoted_on DESC);

ALTER TABLE price_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_quotes FORCE ROW LEVEL SECURITY;

CREATE POLICY price_quotes_tenant_policy ON price_quotes
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

-- ============================================================================
-- Table: price_alerts
-- ============================================================================
CREATE TABLE IF NOT EXISTS price_alerts (
    id                    CHAR(26)         PRIMARY KEY,
    tenant_id             CHAR(26)         NOT NULL,
    commodity             TEXT             NOT NULL,
    market_id             CHAR(26)         NOT NULL,
    direction             TEXT             NOT NULL,
    threshold_per_quintal DOUBLE PRECISION NOT NULL,
    enabled               BOOLEAN          NOT NULL DEFAULT TRUE,

    -- last_fired_price is what makes an alert fire on a crossing rather than
    -- on a state. Without it an alert re-fires on every quote while the price
    -- stays past its threshold, which is twenty notifications for one event
    -- and teaches a farmer to turn alerts off.
    last_fired_at         TIMESTAMPTZ,
    last_fired_price      DOUBLE PRECISION NOT NULL DEFAULT 0,

    created_by            TEXT             NOT NULL DEFAULT 'system',
    created_at            TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_price_alerts_threshold CHECK (threshold_per_quintal > 0),
    CONSTRAINT chk_price_alerts_direction CHECK (direction IN ('ABOVE', 'BELOW'))
);

CREATE INDEX IF NOT EXISTS idx_price_alerts_lookup
    ON price_alerts (tenant_id, commodity, market_id) WHERE enabled;

ALTER TABLE price_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_alerts FORCE ROW LEVEL SECURITY;

CREATE POLICY price_alerts_tenant_policy ON price_alerts
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
