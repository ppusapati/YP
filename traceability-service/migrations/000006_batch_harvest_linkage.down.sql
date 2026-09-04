DROP INDEX IF EXISTS idx_quality_checkpoints_batch;
ALTER TABLE quality_checkpoints DROP COLUMN IF EXISTS batch_id;

DROP INDEX IF EXISTS idx_batch_records_crop_cycle;
ALTER TABLE batch_records
  DROP COLUMN IF EXISTS weight_kg,
  DROP COLUMN IF EXISTS yield_record_id,
  DROP COLUMN IF EXISTS crop_cycle_id;
