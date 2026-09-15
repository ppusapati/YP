-- Phenology analyses and structured per-analysis outputs.
ALTER TYPE analysis_type ADD VALUE IF NOT EXISTS 'PHENOLOGY';

ALTER TABLE temporal_analyses
    ADD COLUMN IF NOT EXISTS details JSONB NOT NULL DEFAULT '{}'::jsonb;
