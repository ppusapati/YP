-- ============================================================================
-- Yield Service: Add is_active and deleted_by columns to all tables
-- ============================================================================

-- yield_predictions
ALTER TABLE yield_predictions ADD COLUMN IF NOT EXISTS is_active  BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE yield_predictions ADD COLUMN IF NOT EXISTS deleted_by CHAR(26);

-- yield_records
ALTER TABLE yield_records ADD COLUMN IF NOT EXISTS is_active  BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE yield_records ADD COLUMN IF NOT EXISTS deleted_by CHAR(26);

-- harvest_plans
ALTER TABLE harvest_plans ADD COLUMN IF NOT EXISTS is_active  BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE harvest_plans ADD COLUMN IF NOT EXISTS deleted_by CHAR(26);
