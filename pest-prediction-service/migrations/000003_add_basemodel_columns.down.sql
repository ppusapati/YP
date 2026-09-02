ALTER TABLE pest_risk_maps DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE pest_risk_maps DROP COLUMN IF EXISTS updated_by;
ALTER TABLE pest_risk_maps DROP COLUMN IF EXISTS created_by;
ALTER TABLE pest_risk_maps DROP COLUMN IF EXISTS is_active;

ALTER TABLE pest_observations DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE pest_observations DROP COLUMN IF EXISTS updated_by;
ALTER TABLE pest_observations DROP COLUMN IF EXISTS created_by;
ALTER TABLE pest_observations DROP COLUMN IF EXISTS is_active;

ALTER TABLE pest_species DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE pest_species DROP COLUMN IF EXISTS updated_by;
ALTER TABLE pest_species DROP COLUMN IF EXISTS created_by;
ALTER TABLE pest_species DROP COLUMN IF EXISTS is_active;

ALTER TABLE pest_alerts DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE pest_alerts DROP COLUMN IF EXISTS updated_by;
ALTER TABLE pest_alerts DROP COLUMN IF EXISTS created_by;
ALTER TABLE pest_alerts DROP COLUMN IF EXISTS is_active;

ALTER TABLE pest_predictions DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE pest_predictions DROP COLUMN IF EXISTS updated_by;
ALTER TABLE pest_predictions DROP COLUMN IF EXISTS is_active;
