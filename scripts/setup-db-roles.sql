-- Create non-superuser application roles for PostgreSQL.
-- The migration role owns schema objects; the application role has
-- restricted DML access and is subject to RLS policies.
--
-- Run as the PostgreSQL superuser (once per cluster):
--   psql -v ON_ERROR_STOP=1 -f scripts/setup-db-roles.sql

-- Migration role: owns tables, indexes, policies. Used only by migrate.sh.
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'yp_migrator') THEN
        CREATE ROLE yp_migrator LOGIN PASSWORD 'changeme_migrator';
    END IF;
END $$;

-- Application role: DML only. Services connect with this role at runtime.
-- RLS policies apply because this role is NOT a superuser.
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'yp_app') THEN
        CREATE ROLE yp_app LOGIN PASSWORD 'changeme_app';
    END IF;
END $$;

-- Grant the application role the ability to use the public schema
-- and select/insert/update/delete on all current and future tables.
GRANT USAGE ON SCHEMA public TO yp_app;
ALTER DEFAULT PRIVILEGES FOR ROLE yp_migrator IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO yp_app;
ALTER DEFAULT PRIVILEGES FOR ROLE yp_migrator IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO yp_app;

-- Grant the migration role full DDL on public schema.
GRANT ALL ON SCHEMA public TO yp_migrator;
