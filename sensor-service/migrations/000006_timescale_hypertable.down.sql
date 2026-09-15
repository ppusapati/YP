-- ============================================================================
-- Sensor Service: revert the hypertable conversion
--
-- Reversed in dependency order: policies, then the aggregate, then
-- compression, then the table itself.
--
-- Note that this does not turn the hypertable back into an ordinary table.
-- TimescaleDB has no such operation, and reconstructing one would mean copying
-- every row into a new table under an exclusive lock — which is a data
-- migration, not a rollback, and belongs in a deliberate step rather than in a
-- `migrate down`. What this does is remove the automation and the rollup, so
-- the table behaves like a plain one again and can be dealt with by hand.
-- ============================================================================

SELECT remove_retention_policy('sensor_readings', if_exists => TRUE);
SELECT remove_continuous_aggregate_policy('sensor_readings_hourly', if_not_exists => TRUE);

DROP MATERIALIZED VIEW IF EXISTS sensor_readings_hourly;

SELECT remove_compression_policy('sensor_readings', if_exists => TRUE);

-- Compressed chunks have to be decompressed before compression can be
-- disabled, or the setting is refused and the rollback stops half-applied.
DO $$
DECLARE
    chunk_name TEXT;
BEGIN
    FOR chunk_name IN
        SELECT format('%I.%I', chunk_schema, chunk_name)
        FROM timescaledb_information.chunks
        WHERE hypertable_name = 'sensor_readings' AND is_compressed
    LOOP
        EXECUTE format('SELECT decompress_chunk(%L)', chunk_name);
    END LOOP;
END
$$;

ALTER TABLE sensor_readings SET (timescaledb.compress = FALSE);

DROP INDEX IF EXISTS idx_sensor_readings_tenant_time;
DROP INDEX IF EXISTS idx_sensor_readings_sensor_time;
DROP INDEX IF EXISTS idx_sensor_readings_id;

-- The primary key stays as (id, recorded_at). Narrowing it back to id alone
-- would fail while the table is still a hypertable, and the pair is a superset
-- of the original guarantee for ULID ids.
