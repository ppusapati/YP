-- ============================================================================
-- Satellite Tile Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_tilesets_set_updated_at ON tilesets;
DROP FUNCTION IF EXISTS trg_tilesets_updated_at();
DROP TABLE IF EXISTS tilesets;
DROP TYPE IF EXISTS tile_layer;
DROP TYPE IF EXISTS tileset_status;
DROP TYPE IF EXISTS tile_format;
