DROP TABLE IF EXISTS activity_events;
DROP TRIGGER IF EXISTS trg_crop_cycles_set_updated_at ON crop_cycles;
DROP FUNCTION IF EXISTS trg_crop_cycles_updated_at();
DROP TABLE IF EXISTS crop_cycles;
