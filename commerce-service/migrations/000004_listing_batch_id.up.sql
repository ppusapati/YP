-- Link marketplace listings to specific traceability batches.
ALTER TABLE marketplace_listings
  ADD COLUMN batch_id CHAR(26);

CREATE INDEX idx_marketplace_listings_batch
  ON marketplace_listings (tenant_id, batch_id)
  WHERE batch_id IS NOT NULL;
