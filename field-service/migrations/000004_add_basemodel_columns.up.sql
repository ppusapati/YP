-- ============================================================================
-- Field Service: Add is_active and deleted_by columns to fields table
-- ============================================================================

ALTER TABLE fields ADD COLUMN IF NOT EXISTS is_active  BOOLEAN  NOT NULL DEFAULT TRUE;
ALTER TABLE fields ADD COLUMN IF NOT EXISTS deleted_by CHAR(26);

CREATE INDEX IF NOT EXISTS idx_fields_is_active ON fields (tenant_id, is_active) WHERE deleted_at IS NULL;
