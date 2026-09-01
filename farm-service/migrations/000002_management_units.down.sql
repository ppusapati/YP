DROP TABLE IF EXISTS management_unit_fields;
DROP TRIGGER IF EXISTS trg_management_units_set_updated_at ON management_units;
DROP FUNCTION IF EXISTS trg_management_units_updated_at();
DROP TABLE IF EXISTS management_units;
