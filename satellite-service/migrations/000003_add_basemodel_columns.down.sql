ALTER TABLE satellite_tasks DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE satellite_tasks DROP COLUMN IF EXISTS updated_by;
ALTER TABLE satellite_tasks DROP COLUMN IF EXISTS created_by;
ALTER TABLE satellite_tasks DROP COLUMN IF EXISTS is_active;

ALTER TABLE vegetation_indices DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE vegetation_indices DROP COLUMN IF EXISTS updated_by;
ALTER TABLE vegetation_indices DROP COLUMN IF EXISTS created_by;
ALTER TABLE vegetation_indices DROP COLUMN IF EXISTS is_active;

ALTER TABLE satellite_alerts DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE satellite_alerts DROP COLUMN IF EXISTS updated_by;
ALTER TABLE satellite_alerts DROP COLUMN IF EXISTS created_by;
ALTER TABLE satellite_alerts DROP COLUMN IF EXISTS is_active;

ALTER TABLE satellite_images DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE satellite_images DROP COLUMN IF EXISTS updated_by;
ALTER TABLE satellite_images DROP COLUMN IF EXISTS created_by;
ALTER TABLE satellite_images DROP COLUMN IF EXISTS is_active;
