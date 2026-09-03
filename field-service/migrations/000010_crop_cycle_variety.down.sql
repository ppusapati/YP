ALTER TABLE crop_cycles
  DROP COLUMN IF EXISTS seed_source,
  DROP COLUMN IF EXISTS crop_variety;
