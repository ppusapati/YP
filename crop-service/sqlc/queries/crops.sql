-- name: CreateCrop :one
INSERT INTO crops (
    uuid, tenant_id, name, scientific_name, family, category,
    description, image_url, disease_susceptibilities, companion_plants,
    rotation_group, version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10,
    $11, $12, $13, $14, $15
) RETURNING *;

-- name: GetCropByUUID :one
SELECT * FROM crops
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: GetCropByID :one
SELECT * FROM crops
WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListCrops :many
SELECT * FROM crops
WHERE tenant_id = $1
  AND is_active = TRUE
  AND deleted_at IS NULL
  AND (sqlc.narg('category')::VARCHAR IS NULL OR category = sqlc.narg('category'))
  AND (sqlc.narg('search_term')::VARCHAR IS NULL OR name ILIKE '%' || sqlc.narg('search_term') || '%' OR scientific_name ILIKE '%' || sqlc.narg('search_term') || '%')
ORDER BY name ASC
LIMIT $2 OFFSET $3;

-- name: CountCrops :one
SELECT COUNT(*) FROM crops
WHERE tenant_id = $1
  AND is_active = TRUE
  AND deleted_at IS NULL
  AND (sqlc.narg('category')::VARCHAR IS NULL OR category = sqlc.narg('category'))
  AND (sqlc.narg('search_term')::VARCHAR IS NULL OR name ILIKE '%' || sqlc.narg('search_term') || '%' OR scientific_name ILIKE '%' || sqlc.narg('search_term') || '%');

-- name: UpdateCrop :one
UPDATE crops SET
    name = COALESCE(sqlc.narg('name'), name),
    scientific_name = COALESCE(sqlc.narg('scientific_name'), scientific_name),
    family = COALESCE(sqlc.narg('family'), family),
    category = COALESCE(sqlc.narg('category'), category),
    description = COALESCE(sqlc.narg('description'), description),
    image_url = COALESCE(sqlc.narg('image_url'), image_url),
    disease_susceptibilities = COALESCE(sqlc.narg('disease_susceptibilities'), disease_susceptibilities),
    companion_plants = COALESCE(sqlc.narg('companion_plants'), companion_plants),
    rotation_group = COALESCE(sqlc.narg('rotation_group'), rotation_group),
    version = version + 1,
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL AND version = $4
RETURNING *;

-- name: SoftDeleteCrop :exec
UPDATE crops SET
    is_active = FALSE,
    deleted_by = $3,
    deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: CheckCropExistsByName :one
SELECT EXISTS(
    SELECT 1 FROM crops
    WHERE tenant_id = $1 AND name = $2 AND is_active = TRUE AND deleted_at IS NULL
) AS exists;

-- name: CreateCropVariety :one
INSERT INTO crop_varieties (
    uuid, crop_id, tenant_id, name, description, maturity_days,
    yield_potential_kg_per_hectare, is_hybrid, disease_resistance,
    suitable_regions, seed_rate_kg_per_hectare, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9,
    $10, $11, $12, $13, $14
) RETURNING *;

-- name: ListVarietiesByCropID :many
SELECT * FROM crop_varieties
WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY name ASC
LIMIT $3 OFFSET $4;

-- name: CountVarietiesByCropID :one
SELECT COUNT(*) FROM crop_varieties
WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: GetGrowthStagesByCropID :many
SELECT * FROM crop_growth_stages
WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY stage_order ASC;

-- name: CreateGrowthStage :one
INSERT INTO crop_growth_stages (
    uuid, crop_id, tenant_id, name, stage_order, duration_days,
    water_requirement_mm, nutrient_requirements, description,
    optimal_temp_min, optimal_temp_max, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9,
    $10, $11, $12, $13, $14
) RETURNING *;

-- name: GetCropRequirementsByCropID :one
SELECT * FROM crop_requirements
WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: UpsertCropRequirements :one
INSERT INTO crop_requirements (
    uuid, crop_id, tenant_id, optimal_temp_min, optimal_temp_max,
    optimal_humidity_min, optimal_humidity_max, optimal_soil_ph_min, optimal_soil_ph_max,
    water_requirement_mm_per_day, sunlight_hours, frost_tolerant, drought_tolerant,
    soil_type_preference, nutrient_requirements, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, $11, $12, $13,
    $14, $15, $16, $17, $18
) ON CONFLICT (crop_id) DO UPDATE SET
    optimal_temp_min = EXCLUDED.optimal_temp_min,
    optimal_temp_max = EXCLUDED.optimal_temp_max,
    optimal_humidity_min = EXCLUDED.optimal_humidity_min,
    optimal_humidity_max = EXCLUDED.optimal_humidity_max,
    optimal_soil_ph_min = EXCLUDED.optimal_soil_ph_min,
    optimal_soil_ph_max = EXCLUDED.optimal_soil_ph_max,
    water_requirement_mm_per_day = EXCLUDED.water_requirement_mm_per_day,
    sunlight_hours = EXCLUDED.sunlight_hours,
    frost_tolerant = EXCLUDED.frost_tolerant,
    drought_tolerant = EXCLUDED.drought_tolerant,
    soil_type_preference = EXCLUDED.soil_type_preference,
    nutrient_requirements = EXCLUDED.nutrient_requirements,
    updated_by = EXCLUDED.created_by,
    updated_at = NOW()
RETURNING *;

-- name: CreateCropRecommendation :one
INSERT INTO crop_recommendations (
    uuid, crop_id, tenant_id, recommendation_type, title,
    description, severity, confidence_score, parameters,
    applicable_growth_stage, valid_from, valid_until,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, $11, $12,
    $13, $14, $15
) RETURNING *;

-- name: ListRecommendationsByCropID :many
SELECT * FROM crop_recommendations
WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;
