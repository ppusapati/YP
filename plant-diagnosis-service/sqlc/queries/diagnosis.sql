-- ─────────────────────────────────────────────────────────────────────────────
-- Diagnosis Requests
-- ─────────────────────────────────────────────────────────────────────────────

-- name: CreateDiagnosisRequest :one
INSERT INTO diagnosis_requests (
    uuid, tenant_id, farm_id, field_id, plant_species_id,
    status, notes, version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, 1, TRUE, $8, NOW()
) RETURNING *;

-- name: GetDiagnosisRequestByUUID :one
SELECT * FROM diagnosis_requests
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: GetDiagnosisRequestByID :one
SELECT * FROM diagnosis_requests
WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListDiagnosisRequests :many
SELECT * FROM diagnosis_requests
WHERE tenant_id = $1
  AND deleted_at IS NULL
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('status')::diagnosis_status IS NULL OR status = sqlc.narg('status'))
ORDER BY
  CASE WHEN sqlc.arg('sort_desc')::BOOLEAN THEN created_at END DESC,
  CASE WHEN NOT sqlc.arg('sort_desc')::BOOLEAN THEN created_at END ASC
LIMIT $2 OFFSET $3;

-- name: CountDiagnosisRequests :one
SELECT COUNT(*) FROM diagnosis_requests
WHERE tenant_id = $1
  AND deleted_at IS NULL
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('status')::diagnosis_status IS NULL OR status = sqlc.narg('status'));

-- name: UpdateDiagnosisRequestStatus :one
UPDATE diagnosis_requests
SET status     = $3,
    updated_by = $4,
    updated_at = NOW(),
    version    = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteDiagnosisRequest :exec
UPDATE diagnosis_requests
SET deleted_by = $3,
    deleted_at = NOW(),
    is_active  = FALSE
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- Diagnosis Images
-- ─────────────────────────────────────────────────────────────────────────────

-- name: CreateDiagnosisImage :one
INSERT INTO diagnosis_images (
    uuid, diagnosis_request_id, image_url, image_type,
    size_bytes, mime_type, checksum, uploaded_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, NOW()
) RETURNING *;

-- name: ListDiagnosisImages :many
SELECT * FROM diagnosis_images
WHERE diagnosis_request_id = $1
ORDER BY uploaded_at ASC;

-- name: DeleteDiagnosisImages :exec
DELETE FROM diagnosis_images
WHERE diagnosis_request_id = $1;

-- ─────────────────────────────────────────────────────────────────────────────
-- Diagnosis Results
-- ─────────────────────────────────────────────────────────────────────────────

-- name: CreateDiagnosisResult :one
INSERT INTO diagnosis_results (
    uuid, diagnosis_request_id, identified_species_id,
    identified_species_name, identified_species_conf,
    detected_diseases, nutrient_deficiencies, pest_damage,
    treatment_recommendations, ai_model_version, processing_time_ms,
    overall_health_score, summary, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, NOW()
) RETURNING *;

-- name: GetDiagnosisResultByRequestID :one
SELECT * FROM diagnosis_results
WHERE diagnosis_request_id = $1;

-- name: GetDiagnosisResultByUUID :one
SELECT * FROM diagnosis_results
WHERE uuid = $1;

-- ─────────────────────────────────────────────────────────────────────────────
-- Disease Catalog
-- ─────────────────────────────────────────────────────────────────────────────

-- name: GetDiseaseByUUID :one
SELECT * FROM disease_catalog
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListDiseases :many
SELECT * FROM disease_catalog
WHERE tenant_id = $1
  AND deleted_at IS NULL
  AND (sqlc.narg('search_term')::VARCHAR IS NULL
       OR disease_name ILIKE '%' || sqlc.narg('search_term') || '%'
       OR scientific_name ILIKE '%' || sqlc.narg('search_term') || '%')
ORDER BY disease_name ASC
LIMIT $2 OFFSET $3;

-- name: CountDiseases :one
SELECT COUNT(*) FROM disease_catalog
WHERE tenant_id = $1
  AND deleted_at IS NULL
  AND (sqlc.narg('search_term')::VARCHAR IS NULL
       OR disease_name ILIKE '%' || sqlc.narg('search_term') || '%'
       OR scientific_name ILIKE '%' || sqlc.narg('search_term') || '%');

-- name: CreateDisease :one
INSERT INTO disease_catalog (
    uuid, tenant_id, disease_name, scientific_name, description,
    symptoms, treatment_options, prevention, affected_species,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, TRUE, $10, NOW()
) RETURNING *;

-- ─────────────────────────────────────────────────────────────────────────────
-- Nutrient Deficiency Catalog
-- ─────────────────────────────────────────────────────────────────────────────

-- name: GetNutrientDeficiencyByUUID :one
SELECT * FROM nutrient_deficiency_catalog
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListNutrientDeficiencies :many
SELECT * FROM nutrient_deficiency_catalog
WHERE tenant_id = $1 AND deleted_at IS NULL
ORDER BY nutrient ASC
LIMIT $2 OFFSET $3;

-- ─────────────────────────────────────────────────────────────────────────────
-- Pest Catalog
-- ─────────────────────────────────────────────────────────────────────────────

-- name: GetPestByUUID :one
SELECT * FROM pest_catalog
WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListPests :many
SELECT * FROM pest_catalog
WHERE tenant_id = $1 AND deleted_at IS NULL
ORDER BY pest_name ASC
LIMIT $2 OFFSET $3;

-- ─────────────────────────────────────────────────────────────────────────────
-- Treatment Plans
-- ─────────────────────────────────────────────────────────────────────────────

-- name: CreateTreatmentPlan :one
INSERT INTO treatment_plans (
    uuid, diagnosis_request_id, title, description,
    priority, steps, estimated_cost, estimated_days,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, TRUE, $9, NOW()
) RETURNING *;

-- name: GetTreatmentPlanByDiagnosisID :one
SELECT * FROM treatment_plans
WHERE diagnosis_request_id = $1 AND deleted_at IS NULL;

-- name: GetTreatmentPlanByUUID :one
SELECT * FROM treatment_plans
WHERE uuid = $1 AND deleted_at IS NULL;

-- name: ListTreatmentPlansByDiagnosisID :many
SELECT * FROM treatment_plans
WHERE diagnosis_request_id = $1 AND deleted_at IS NULL
ORDER BY created_at DESC;
