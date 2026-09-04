-- Link crop cycles to management units (blocks/zones within a farm).
-- The column is nullable because not all fields belong to a management unit.
ALTER TABLE crop_cycles
  ADD COLUMN management_unit_id CHAR(26);

CREATE INDEX idx_crop_cycles_management_unit
  ON crop_cycles (tenant_id, management_unit_id)
  WHERE management_unit_id IS NOT NULL AND deleted_at IS NULL;
