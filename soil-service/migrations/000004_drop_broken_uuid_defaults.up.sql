-- Drop broken gen_random_uuid() defaults on CHAR(26) primary key columns.
-- gen_random_uuid() returns 36-char UUIDs which PostgreSQL silently truncates
-- to 26 chars. The application always provides ULID IDs, so the default is
-- both unnecessary and incorrect.
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

