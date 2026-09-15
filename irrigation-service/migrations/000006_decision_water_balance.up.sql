-- Water-balance provenance on irrigation decisions.
ALTER TABLE irrigation_decisions
    ADD COLUMN IF NOT EXISTS output_method               TEXT             NOT NULL DEFAULT 'heuristic',
    ADD COLUMN IF NOT EXISTS output_recommended_depth_mm DOUBLE PRECISION NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS output_crop_coefficient     DOUBLE PRECISION NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS output_et0_mm_day           DOUBLE PRECISION NOT NULL DEFAULT 0;
