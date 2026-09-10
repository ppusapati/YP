-- ============================================================================
-- Vegetation Index Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_compute_tasks_set_updated_at ON compute_tasks;
DROP FUNCTION IF EXISTS trg_compute_tasks_updated_at();
DROP TABLE IF EXISTS vegetation_indices;
DROP TABLE IF EXISTS compute_tasks;
DROP TYPE IF EXISTS compute_status;
DROP TYPE IF EXISTS vegetation_index_type;
