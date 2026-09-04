-- Link batch records to crop cycles, yield records, and add weight tracking.
ALTER TABLE batch_records
  ADD COLUMN crop_cycle_id   CHAR(26),
  ADD COLUMN yield_record_id CHAR(26),
  ADD COLUMN weight_kg       DOUBLE PRECISION NOT NULL DEFAULT 0;

CREATE INDEX idx_batch_records_crop_cycle
  ON batch_records (tenant_id, crop_cycle_id)
  WHERE crop_cycle_id IS NOT NULL;

-- Allow quality checkpoints to be scoped to individual batches.
ALTER TABLE quality_checkpoints
  ADD COLUMN batch_id CHAR(26);

CREATE INDEX idx_quality_checkpoints_batch
  ON quality_checkpoints (tenant_id, batch_id)
  WHERE batch_id IS NOT NULL;
