ALTER TABLE temporal_analyses DROP COLUMN IF EXISTS details;
-- Enum values cannot be dropped in PostgreSQL; 'PHENOLOGY' is left in place.
