-- ============================================================================
-- Satellite Service: Initial Schema Migration (DOWN)
-- ============================================================================
DROP TRIGGER IF EXISTS trg_satellite_alerts_set_updated_at ON satellite_alerts;
DROP FUNCTION IF EXISTS trg_satellite_alerts_updated_at();
DROP TABLE IF EXISTS satellite_alerts;

DROP TRIGGER IF EXISTS trg_satellite_images_set_updated_at ON satellite_images;
DROP FUNCTION IF EXISTS trg_satellite_images_updated_at();
DROP TABLE IF EXISTS satellite_images;
