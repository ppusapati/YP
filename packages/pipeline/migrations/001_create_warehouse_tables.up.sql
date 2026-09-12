-- E-007: Data Pipeline & Analytics Warehouse schema
-- All tables include tenant_id for row-level security.

BEGIN;

-- Daily aggregated yield data per field.
CREATE TABLE IF NOT EXISTS daily_yield_summaries (
    id            BIGSERIAL    PRIMARY KEY,
    tenant_id     TEXT         NOT NULL,
    field_id      TEXT         NOT NULL,
    date          DATE         NOT NULL,
    crop          TEXT         NOT NULL,
    min_yield     DOUBLE PRECISION NOT NULL DEFAULT 0,
    avg_yield     DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_yield     DOUBLE PRECISION NOT NULL DEFAULT 0,
    total_area    DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, field_id, date, crop)
);

CREATE INDEX idx_daily_yield_tenant       ON daily_yield_summaries (tenant_id);
CREATE INDEX idx_daily_yield_field_date   ON daily_yield_summaries (tenant_id, field_id, date);
CREATE INDEX idx_daily_yield_date_range   ON daily_yield_summaries (tenant_id, date);

-- Weekly soil metric trends per field.
CREATE TABLE IF NOT EXISTS weekly_soil_trends (
    id              BIGSERIAL    PRIMARY KEY,
    tenant_id       TEXT         NOT NULL,
    field_id        TEXT         NOT NULL,
    week_start      DATE         NOT NULL,
    avg_moisture    DOUBLE PRECISION NOT NULL DEFAULT 0,
    avg_ph          DOUBLE PRECISION NOT NULL DEFAULT 0,
    avg_nitrogen    DOUBLE PRECISION NOT NULL DEFAULT 0,
    avg_phosphorus  DOUBLE PRECISION NOT NULL DEFAULT 0,
    avg_potassium   DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, field_id, week_start)
);

CREATE INDEX idx_weekly_soil_tenant       ON weekly_soil_trends (tenant_id);
CREATE INDEX idx_weekly_soil_field_week   ON weekly_soil_trends (tenant_id, field_id, week_start);
CREATE INDEX idx_weekly_soil_week_range   ON weekly_soil_trends (tenant_id, week_start);

-- Seasonal crop performance analytics.
CREATE TABLE IF NOT EXISTS seasonal_crop_performance (
    id               BIGSERIAL    PRIMARY KEY,
    tenant_id        TEXT         NOT NULL,
    field_id         TEXT         NOT NULL,
    season           TEXT         NOT NULL,
    crop             TEXT         NOT NULL,
    total_yield      DOUBLE PRECISION NOT NULL DEFAULT 0,
    total_input_cost DOUBLE PRECISION NOT NULL DEFAULT 0,
    yield_per_hectare DOUBLE PRECISION NOT NULL DEFAULT 0,
    roi              DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, field_id, season, crop)
);

CREATE INDEX idx_seasonal_perf_tenant       ON seasonal_crop_performance (tenant_id);
CREATE INDEX idx_seasonal_perf_field_season ON seasonal_crop_performance (tenant_id, field_id, season);
CREATE INDEX idx_seasonal_perf_crop         ON seasonal_crop_performance (tenant_id, crop);

-- Monthly min/max/avg for sensor readings per field.
CREATE TABLE IF NOT EXISTS monthly_sensor_stats (
    id            BIGSERIAL    PRIMARY KEY,
    tenant_id     TEXT         NOT NULL,
    field_id      TEXT         NOT NULL,
    sensor_type   TEXT         NOT NULL,
    month         DATE         NOT NULL,
    min_value     DOUBLE PRECISION NOT NULL DEFAULT 0,
    avg_value     DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_value     DOUBLE PRECISION NOT NULL DEFAULT 0,
    reading_count BIGINT       NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, field_id, sensor_type, month)
);

CREATE INDEX idx_monthly_sensor_tenant       ON monthly_sensor_stats (tenant_id);
CREATE INDEX idx_monthly_sensor_field_month  ON monthly_sensor_stats (tenant_id, field_id, month);
CREATE INDEX idx_monthly_sensor_type         ON monthly_sensor_stats (tenant_id, sensor_type, month);

-- Data quality audit trail.
CREATE TABLE IF NOT EXISTS data_quality_reports (
    id            BIGSERIAL    PRIMARY KEY,
    tenant_id     TEXT         NOT NULL,
    job_name      TEXT         NOT NULL,
    run_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    total_records BIGINT       NOT NULL DEFAULT 0,
    passed        BIGINT       NOT NULL DEFAULT 0,
    failed        BIGINT       NOT NULL DEFAULT 0,
    details       JSONB        NOT NULL DEFAULT '{}',
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quality_report_tenant   ON data_quality_reports (tenant_id);
CREATE INDEX idx_quality_report_job      ON data_quality_reports (tenant_id, job_name);
CREATE INDEX idx_quality_report_run_at   ON data_quality_reports (tenant_id, run_at);

COMMIT;
