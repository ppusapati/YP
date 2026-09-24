-- ============================================================================
-- Irrigation Service: Water Metering Migration (UP)
--
-- Until now `irrigation_events.actual_water_liters` held the schedule's
-- planned quantity, copied in at start time before water could have flowed,
-- and `water_usage_logs` had no writer at all — so GetWaterUsage returned an
-- empty list for every zone on every farm, which reads as a farm that has
-- never used water.
--
-- A volume can only be measured by reading the controller's cumulative meter
-- at the start of a run and again at the end. These columns are where those
-- two readings live, and where the record of which runs were measured lives.
-- ============================================================================

-- ── The two readings a run is metered from ──────────────────────────────────
--
-- Nullable, and the null is the point: a run on a panel with no meter has no
-- start reading, and that is a fact about the run worth keeping rather than a
-- zero to be subtracted from.
ALTER TABLE irrigation_events
    ADD COLUMN IF NOT EXISTS meter_start_liters DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS meter_end_liters   DOUBLE PRECISION;

-- water_source says where actual_water_liters came from, and without it the
-- column is a number with no provenance: a meter reading, arithmetic on a
-- measured flow rate, and a figure nobody measured are not interchangeable,
-- and an auditor or a farmer comparing two seasons needs to know which they
-- are looking at.
--
-- Existing rows are UNMETERED, which is the truth about every run recorded
-- before this: their actual_water_liters is the schedule's plan.
ALTER TABLE irrigation_events
    ADD COLUMN IF NOT EXISTS water_source TEXT NOT NULL DEFAULT 'UNMETERED';

-- ── Water usage ─────────────────────────────────────────────────────────────

ALTER TABLE water_usage_logs
    ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'UNMETERED',
    -- The run this measures. Without it a usage row cannot be traced back to
    -- the command that opened the valve, which is the first thing anybody
    -- asks when a figure looks wrong.
    ADD COLUMN IF NOT EXISTS event_id CHAR(26);

-- One usage row per run. The run is what was measured, so a second row for
-- the same run is a double count — and a daily or seasonal total is exactly
-- the query that would silently absorb one.
CREATE UNIQUE INDEX IF NOT EXISTS idx_water_usage_logs_event
    ON water_usage_logs (event_id) WHERE event_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_water_usage_logs_zone_period
    ON water_usage_logs (tenant_id, zone_id, period_start DESC) WHERE deleted_at IS NULL;

-- Partial, because the question "how much of this season was actually
-- measured" is the one that decides whether a total can be trusted, and on a
-- metered farm it touches only these rows.
CREATE INDEX IF NOT EXISTS idx_water_usage_logs_source
    ON water_usage_logs (tenant_id, source) WHERE deleted_at IS NULL;
