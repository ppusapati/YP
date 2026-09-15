-- Per-scene quality, carried with the index it produced.
--
-- An index computed over a cloudy scene is not wrong so much as meaningless:
-- the arithmetic succeeds on whatever reflectance the cloud tops returned and
-- the result is reported with the same confidence as a clear day. Storing how
-- much of the scene was usable lets a reader tell the two apart, and lets the
-- service drop the ones that are not worth keeping.
--
-- Defaults describe a scene ingested before masking existed: nothing known to
-- be cloud, everything assumed valid. That is the same assumption those rows
-- were already computed under, made explicit rather than left as NULL.
ALTER TABLE vegetation_indices
    ADD COLUMN IF NOT EXISTS cloud_fraction DOUBLE PRECISION NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS valid_pixel_fraction DOUBLE PRECISION NOT NULL DEFAULT 1;

COMMENT ON COLUMN vegetation_indices.cloud_fraction IS
    'Share of scene pixels masked as cloud, shadow or snow (0..1).';
COMMENT ON COLUMN vegetation_indices.valid_pixel_fraction IS
    'Share of scene pixels that survived masking and contributed to the index (0..1).';

-- Finding the usable history for a field is the common query once scenes can
-- be partly cloud.
CREATE INDEX IF NOT EXISTS idx_vegetation_indices_valid_pixels
    ON vegetation_indices (tenant_id, field_uuid, valid_pixel_fraction)
    WHERE deleted_at IS NULL;
