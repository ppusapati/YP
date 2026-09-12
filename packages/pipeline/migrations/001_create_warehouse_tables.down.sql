-- E-007: Reverse warehouse schema creation.

BEGIN;

DROP TABLE IF EXISTS data_quality_reports;
DROP TABLE IF EXISTS monthly_sensor_stats;
DROP TABLE IF EXISTS seasonal_crop_performance;
DROP TABLE IF EXISTS weekly_soil_trends;
DROP TABLE IF EXISTS daily_yield_summaries;

COMMIT;
