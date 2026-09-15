DROP INDEX IF EXISTS idx_vegetation_indices_valid_pixels;
ALTER TABLE vegetation_indices
    DROP COLUMN IF EXISTS valid_pixel_fraction,
    DROP COLUMN IF EXISTS cloud_fraction;
