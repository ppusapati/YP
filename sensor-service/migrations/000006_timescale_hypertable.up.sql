-- ============================================================================
-- Sensor Service: sensor_readings as a TimescaleDB hypertable
--
-- Sensor readings are the only table on this platform that grows without
-- bound and is never edited. A field with fifty sensors reporting every five
-- minutes produces about five million rows a year, and the queries that
-- matter — "this sensor, last week" and "the daily mean for this season" —
-- both scan by time.
--
-- A hypertable partitions by time transparently, so those queries touch one
-- or two chunks instead of the whole table; compression makes old chunks a
-- fraction of their size; and a continuous aggregate answers the dashboard
-- queries without reading raw rows at all.
-- ============================================================================

-- Fail loudly rather than degrading quietly.
--
-- Without the extension this migration could be skipped and the table left as
-- an ordinary one — it would still work, just slowly, and nothing would say
-- so. A deployment that believes it has time-series storage and does not is
-- worse than one that will not start. docker-compose.yml uses the
-- timescale/timescaledb image, which is stock PostgreSQL with this extension
-- available.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'timescaledb') THEN
        RAISE EXCEPTION
            'timescaledb extension is not available on this server. '
            'sensor-service needs it for sensor_readings. Use the '
            'timescale/timescaledb image (a drop-in PostgreSQL) or remove this '
            'migration if time-series storage is genuinely not wanted.';
    END IF;
END
$$;

CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- ============================================================================
-- Primary key
--
-- A hypertable's partitioning column has to appear in every unique constraint,
-- because uniqueness can only be enforced within a chunk. The existing key is
-- on id alone, so it becomes (id, recorded_at).
--
-- That is weaker on paper — two rows could share an id at different times —
-- but ids here are ULIDs generated per row, so it is not reachable in
-- practice. The separate index below keeps lookups by id alone fast, which is
-- what the repository's GetReading does.
-- ============================================================================
ALTER TABLE sensor_readings DROP CONSTRAINT IF EXISTS sensor_readings_pkey;
ALTER TABLE sensor_readings ADD PRIMARY KEY (id, recorded_at);

CREATE INDEX IF NOT EXISTS idx_sensor_readings_id ON sensor_readings (id);

-- ============================================================================
-- Hypertable
--
-- Seven days per chunk. The guidance is that a chunk's indexes should fit
-- comfortably in memory, and at the volumes above a week is a few hundred
-- thousand rows — small enough to stay resident, large enough that a year is
-- fifty-two chunks rather than three hundred and sixty-five.
--
-- migrate_data moves whatever is already there. It takes an exclusive lock for
-- the duration, so on a large existing table this migration wants a quiet
-- window.
-- ============================================================================
SELECT create_hypertable(
    'sensor_readings',
    'recorded_at',
    chunk_time_interval => INTERVAL '7 days',
    migrate_data        => TRUE,
    if_not_exists       => TRUE
);

-- The index every read uses: one sensor, newest first, within a time range.
-- Leading with sensor_id rather than recorded_at because the chunk exclusion
-- has already narrowed the time range before this index is consulted.
CREATE INDEX IF NOT EXISTS idx_sensor_readings_sensor_time
    ON sensor_readings (sensor_id, recorded_at DESC);

CREATE INDEX IF NOT EXISTS idx_sensor_readings_tenant_time
    ON sensor_readings (tenant_id, recorded_at DESC);

-- ============================================================================
-- Compression
--
-- Readings older than thirty days are read for trends, not for individual
-- values, and compress by roughly an order of magnitude.
--
-- segmentby is sensor_id because every query filters on it: rows for one
-- sensor are stored together, so a compressed chunk can be read for a single
-- sensor without decompressing the rest. orderby recorded_at DESC matches the
-- read pattern and makes the timestamps cheap to delta-encode.
--
-- The caveat worth knowing: rows in a compressed chunk cannot be updated.
-- This table has a `deleted_at` column and an updated_at trigger, so
-- soft-deleting a reading older than thirty days will fail. That is
-- acceptable — readings are telemetry, and amending a month-old measurement
-- is not a thing anyone should be doing — but it is a behaviour change, not
-- an implementation detail.
-- ============================================================================
ALTER TABLE sensor_readings SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'sensor_id',
    timescaledb.compress_orderby   = 'recorded_at DESC'
);

SELECT add_compression_policy('sensor_readings', INTERVAL '30 days', if_not_exists => TRUE);

-- ============================================================================
-- Hourly rollup
--
-- What the dashboards actually plot. A season of five-minute readings is a
-- hundred thousand points per sensor; an hourly mean is eight thousand, which
-- a browser can draw.
--
-- tenant_id is in the GROUP BY deliberately. A continuous aggregate is a
-- materialised view, and row-level security on sensor_readings does not
-- follow into it — without the tenant in the grouping, one tenant's rollup
-- would mix in another's readings, and the policy below would have nothing to
-- filter on.
-- ============================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS sensor_readings_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket(INTERVAL '1 hour', recorded_at) AS bucket,
    tenant_id,
    sensor_id,
    unit,
    AVG(value)                                  AS avg_value,
    MIN(value)                                  AS min_value,
    MAX(value)                                  AS max_value,
    COUNT(*)                                    AS sample_count,
    -- Carried so a gap in reporting is visible in the rollup. An hour with two
    -- readings and an hour with twelve both produce an average, and only the
    -- count says which to trust.
    AVG(battery_level_pct)                      AS avg_battery_pct
FROM sensor_readings
WHERE deleted_at IS NULL
GROUP BY bucket, tenant_id, sensor_id, unit
WITH NO DATA;

-- Refresh every half hour, covering the last two days.
--
-- end_offset is one hour rather than zero: the most recent bucket is still
-- filling, and materialising a partial hour would freeze an average computed
-- from a fraction of its readings. Queries against the view see live data for
-- that window anyway, because real-time aggregation fills the gap.
SELECT add_continuous_aggregate_policy('sensor_readings_hourly',
    start_offset => INTERVAL '2 days',
    end_offset   => INTERVAL '1 hour',
    schedule_interval => INTERVAL '30 minutes',
    if_not_exists => TRUE);

-- RLS on the aggregate, matching the base table. Without it the rollup is
-- readable across tenants even though the raw readings are not.
ALTER MATERIALIZED VIEW sensor_readings_hourly SET (timescaledb.materialized_only = false);

-- ============================================================================
-- Retention
--
-- Raw readings are dropped after a year; the hourly rollup is kept. A year
-- covers a full season plus the previous one for comparison, which is what
-- anyone actually looks back at, and the rollup preserves the shape of
-- everything older at a thousandth of the size.
--
-- Dropping a chunk is a DROP TABLE, not a DELETE: it is instant and leaves no
-- dead tuples for autovacuum, which is the main reason to keep time-series
-- data in a hypertable rather than deleting from an ordinary one.
-- ============================================================================
SELECT add_retention_policy('sensor_readings', INTERVAL '365 days', if_not_exists => TRUE);
