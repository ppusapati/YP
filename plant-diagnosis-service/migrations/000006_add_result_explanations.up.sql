-- Model explanations for a stored diagnosis.
--
-- A confidence score says how sure the model was; an explanation says what it
-- looked at, which is what lets someone revisit an old diagnosis and judge it
-- rather than take it on trust. Grad-CAM heatmaps travel as base64 PNGs inside
-- this array: a map is a few kilobytes at feature resolution, small next to the
-- detection JSON already stored here, and keeping it alongside the result means
-- a history view needs no second round trip.
--
-- Nullable and defaulted: results written before this column existed, and
-- results from models that cannot explain themselves, simply carry no
-- explanation rather than an empty-looking fabricated one.
ALTER TABLE diagnosis_results
    ADD COLUMN IF NOT EXISTS explanations JSONB DEFAULT '[]';

COMMENT ON COLUMN diagnosis_results.explanations IS
    'Per-image model explanations (Grad-CAM heatmap, focus region, summary). Empty when the serving model cannot explain itself.';

-- One result per request.
--
-- The sqlc schema and the read path both assume a single result per request,
-- but no constraint enforced it and nothing ever inserted one. Making it unique
-- means a re-analysis replaces the previous answer rather than leaving two rows
-- that disagree about the same photo. Partial, so a soft-deleted result does
-- not block a fresh one.
CREATE UNIQUE INDEX IF NOT EXISTS uq_diagnosis_results_request
    ON diagnosis_results (diagnosis_request_id)
    WHERE deleted_at IS NULL;
