-- ============================================================================
-- Satellite Service: Add is_active, deleted_by, created_by, updated_by
-- columns to all tables
-- ============================================================================

-- satellite_images
ALTER TABLE satellite_images ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE satellite_images ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE satellite_images ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE satellite_images ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);

-- satellite_alerts
ALTER TABLE satellite_alerts ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE satellite_alerts ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE satellite_alerts ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE satellite_alerts ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);

-- vegetation_indices
ALTER TABLE vegetation_indices ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE vegetation_indices ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE vegetation_indices ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE vegetation_indices ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);

-- satellite_tasks
ALTER TABLE satellite_tasks ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE satellite_tasks ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE satellite_tasks ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE satellite_tasks ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);
