-- ============================================================================
-- Agronomy Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP INDEX IF EXISTS idx_outbox_events_created_at;
DROP TABLE IF EXISTS outbox_events;

DROP TRIGGER IF EXISTS trg_inspections_set_updated_at ON inspections;
DROP FUNCTION IF EXISTS trg_inspections_updated_at();
DROP TABLE IF EXISTS inspections;

DROP TRIGGER IF EXISTS trg_advisories_set_updated_at ON advisories;
DROP FUNCTION IF EXISTS trg_advisories_updated_at();
DROP TABLE IF EXISTS advisories;
