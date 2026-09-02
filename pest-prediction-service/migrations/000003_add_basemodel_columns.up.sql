-- ============================================================================
-- Pest Prediction Service: Add is_active, deleted_by, and missing audit
-- columns to all tables
-- ============================================================================

-- pest_predictions (already has created_by)
ALTER TABLE pest_predictions ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE pest_predictions ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE pest_predictions ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);

-- pest_alerts
ALTER TABLE pest_alerts ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE pest_alerts ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE pest_alerts ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE pest_alerts ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);

-- pest_species
ALTER TABLE pest_species ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE pest_species ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE pest_species ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE pest_species ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);

-- pest_observations
ALTER TABLE pest_observations ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE pest_observations ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE pest_observations ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE pest_observations ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);

-- pest_risk_maps
ALTER TABLE pest_risk_maps ADD COLUMN IF NOT EXISTS is_active   BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE pest_risk_maps ADD COLUMN IF NOT EXISTS created_by  CHAR(26);
ALTER TABLE pest_risk_maps ADD COLUMN IF NOT EXISTS updated_by  CHAR(26);
ALTER TABLE pest_risk_maps ADD COLUMN IF NOT EXISTS deleted_by  CHAR(26);
