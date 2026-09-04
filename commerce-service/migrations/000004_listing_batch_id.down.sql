DROP INDEX IF EXISTS idx_marketplace_listings_batch;
ALTER TABLE marketplace_listings DROP COLUMN IF EXISTS batch_id;
