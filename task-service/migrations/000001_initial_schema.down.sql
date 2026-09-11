-- ============================================================================
-- Task Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_tasks_set_updated_at ON tasks;
DROP FUNCTION IF EXISTS trg_tasks_updated_at();
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS outbox_events;
