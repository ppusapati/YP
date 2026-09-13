ALTER TABLE irrigation_decisions
    DROP COLUMN IF EXISTS output_method,
    DROP COLUMN IF EXISTS output_recommended_depth_mm,
    DROP COLUMN IF EXISTS output_crop_coefficient,
    DROP COLUMN IF EXISTS output_et0_mm_day;
