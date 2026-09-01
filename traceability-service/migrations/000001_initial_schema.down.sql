-- ============================================================================
-- Traceability Service: Initial Schema Migration (DOWN)
-- ============================================================================
ALTER TABLE trace_events DROP CONSTRAINT IF EXISTS fk_trace_events_record_id;

DROP TRIGGER IF EXISTS trg_trace_chains_set_updated_at ON trace_chains;
DROP FUNCTION IF EXISTS trg_trace_chains_updated_at();
DROP TABLE IF EXISTS trace_chains;

DROP TABLE IF EXISTS trace_events;
