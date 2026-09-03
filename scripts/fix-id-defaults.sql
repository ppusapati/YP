-- Fix CHAR(26) DEFAULT gen_random_uuid() across all service databases.
-- gen_random_uuid() produces 36-char UUIDs for 26-char ULID columns.
-- The application always provides IDs via ulid.NewString(), so we drop
-- the broken default rather than installing pg_ulid (which may not be
-- available in all environments).
--
-- Run this once per database:
--   psql -v ON_ERROR_STOP=1 -d <db_name> -f scripts/fix-id-defaults.sql

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_schema, table_name, column_name
        FROM information_schema.columns
        WHERE data_type = 'character'
          AND character_maximum_length = 26
          AND column_default LIKE '%gen_random_uuid()%'
          AND table_schema = 'public'
    LOOP
        EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I DROP DEFAULT',
                       r.table_schema, r.table_name, r.column_name);
        RAISE NOTICE 'Dropped gen_random_uuid() default from %.%.%',
                     r.table_schema, r.table_name, r.column_name;
    END LOOP;
END $$;
