-- ---------------------------------------------------------------------------
-- soil_samples
-- ---------------------------------------------------------------------------

-- name: CreateSoilSample :one
INSERT INTO soil_samples (
    uuid, tenant_id, field_id, farm_id,
    sample_location, sample_depth_cm, collection_date,
    ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
    calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
    zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
    texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
    collected_by, notes, created_by
) VALUES (
    $1, $2, $3, $4,
    ST_SetSRID(ST_MakePoint($5, $6), 4326), $7, $8,
    $9, $10, $11, $12, $13,
    $14, $15, $16, $17, $18,
    $19, $20, $21, $22,
    $23, $24, $25, $26,
    $27, $28, $29
) RETURNING id, uuid, tenant_id, field_id, farm_id,
    ST_Y(sample_location::geometry) AS latitude,
    ST_X(sample_location::geometry) AS longitude,
    sample_depth_cm, collection_date,
    ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
    calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
    zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
    texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
    collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version;

-- name: GetSoilSampleByUUID :one
SELECT id, uuid, tenant_id, field_id, farm_id,
    ST_Y(sample_location::geometry) AS latitude,
    ST_X(sample_location::geometry) AS longitude,
    sample_depth_cm, collection_date,
    ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
    calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
    zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
    texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
    collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version
FROM soil_samples
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListSoilSamples :many
SELECT id, uuid, tenant_id, field_id, farm_id,
    ST_Y(sample_location::geometry) AS latitude,
    ST_X(sample_location::geometry) AS longitude,
    sample_depth_cm, collection_date,
    ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
    calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
    zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
    texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
    collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version
FROM soil_samples
WHERE tenant_id = $1
    AND ($2::VARCHAR = '' OR field_id = $2)
    AND ($3::VARCHAR = '' OR farm_id = $3)
    AND is_active = TRUE
    AND deleted_at IS NULL
ORDER BY collection_date DESC
LIMIT $4 OFFSET $5;

-- name: CountSoilSamples :one
SELECT COUNT(*)
FROM soil_samples
WHERE tenant_id = $1
    AND ($2::VARCHAR = '' OR field_id = $2)
    AND ($3::VARCHAR = '' OR farm_id = $3)
    AND is_active = TRUE
    AND deleted_at IS NULL;

-- name: UpdateSoilSample :one
UPDATE soil_samples
SET
    ph = COALESCE($3, ph),
    organic_matter_pct = COALESCE($4, organic_matter_pct),
    nitrogen_ppm = COALESCE($5, nitrogen_ppm),
    phosphorus_ppm = COALESCE($6, phosphorus_ppm),
    potassium_ppm = COALESCE($7, potassium_ppm),
    notes = COALESCE($8, notes),
    updated_by = $9,
    updated_at = NOW(),
    version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING id, uuid, tenant_id, field_id, farm_id,
    ST_Y(sample_location::geometry) AS latitude,
    ST_X(sample_location::geometry) AS longitude,
    sample_depth_cm, collection_date,
    ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
    calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
    zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
    texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
    collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version;

-- name: DeleteSoilSample :exec
UPDATE soil_samples
SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- soil_analyses
-- ---------------------------------------------------------------------------

-- name: CreateSoilAnalysis :one
INSERT INTO soil_analyses (
    uuid, tenant_id, sample_id, field_id, farm_id,
    status, analysis_type, soil_health_score, health_category,
    recommendations, analyzed_by, analyzed_at, summary, created_by
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, $11, $12, $13, $14
) RETURNING id, uuid, tenant_id, sample_id, field_id, farm_id,
    status, analysis_type, soil_health_score, health_category,
    recommendations, analyzed_by, analyzed_at, summary,
    is_active, created_by, created_at, updated_by, updated_at, version;

-- name: GetSoilAnalysisByUUID :one
SELECT id, uuid, tenant_id, sample_id, field_id, farm_id,
    status, analysis_type, soil_health_score, health_category,
    recommendations, analyzed_by, analyzed_at, summary,
    is_active, created_by, created_at, updated_by, updated_at, version
FROM soil_analyses
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListSoilAnalyses :many
SELECT id, uuid, tenant_id, sample_id, field_id, farm_id,
    status, analysis_type, soil_health_score, health_category,
    recommendations, analyzed_by, analyzed_at, summary,
    is_active, created_by, created_at, updated_by, updated_at, version
FROM soil_analyses
WHERE tenant_id = $1
    AND ($2::VARCHAR = '' OR field_id = $2)
    AND ($3::VARCHAR = '' OR farm_id = $3)
    AND ($4::VARCHAR = '' OR sample_id = $4)
    AND is_active = TRUE
    AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $5 OFFSET $6;

-- name: CountSoilAnalyses :one
SELECT COUNT(*)
FROM soil_analyses
WHERE tenant_id = $1
    AND ($2::VARCHAR = '' OR field_id = $2)
    AND ($3::VARCHAR = '' OR farm_id = $3)
    AND ($4::VARCHAR = '' OR sample_id = $4)
    AND is_active = TRUE
    AND deleted_at IS NULL;

-- name: UpdateSoilAnalysisStatus :one
UPDATE soil_analyses
SET
    status = $3,
    soil_health_score = $4,
    health_category = $5,
    recommendations = $6,
    analyzed_by = $7,
    analyzed_at = $8,
    summary = $9,
    updated_by = $10,
    updated_at = NOW(),
    version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING id, uuid, tenant_id, sample_id, field_id, farm_id,
    status, analysis_type, soil_health_score, health_category,
    recommendations, analyzed_by, analyzed_at, summary,
    is_active, created_by, created_at, updated_by, updated_at, version;

-- ---------------------------------------------------------------------------
-- soil_maps
-- ---------------------------------------------------------------------------

-- name: CreateSoilMap :one
INSERT INTO soil_maps (
    uuid, tenant_id, field_id, farm_id, map_type,
    crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
    generated_by, generated_at, created_by
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9, $10, $11,
    $12, $13, $14
) RETURNING id, uuid, tenant_id, field_id, farm_id, map_type,
    crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
    generated_by, generated_at,
    is_active, created_by, created_at, updated_by, updated_at, version;

-- name: GetSoilMapByFieldAndType :one
SELECT id, uuid, tenant_id, field_id, farm_id, map_type,
    crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
    generated_by, generated_at,
    is_active, created_by, created_at, updated_by, updated_at, version
FROM soil_maps
WHERE field_id = $1 AND tenant_id = $2 AND map_type = $3
    AND is_active = TRUE AND deleted_at IS NULL
ORDER BY generated_at DESC
LIMIT 1;

-- ---------------------------------------------------------------------------
-- soil_nutrients
-- ---------------------------------------------------------------------------

-- name: CreateSoilNutrient :one
INSERT INTO soil_nutrients (
    uuid, tenant_id, sample_id, nutrient_name,
    value_ppm, level, optimal_min, optimal_max, unit, created_by
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING id, uuid, tenant_id, sample_id, nutrient_name,
    value_ppm, level, optimal_min, optimal_max, unit,
    is_active, created_by, created_at;

-- name: ListNutrientsBySample :many
SELECT id, uuid, tenant_id, sample_id, nutrient_name,
    value_ppm, level, optimal_min, optimal_max, unit,
    is_active, created_by, created_at
FROM soil_nutrients
WHERE sample_id = $1 AND tenant_id = $2
    AND is_active = TRUE AND deleted_at IS NULL
ORDER BY nutrient_name ASC;

-- name: DeleteNutrientsBySample :exec
UPDATE soil_nutrients
SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
WHERE sample_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- soil_health_scores
-- ---------------------------------------------------------------------------

-- name: CreateSoilHealthScore :one
INSERT INTO soil_health_scores (
    uuid, tenant_id, field_id, farm_id,
    overall_score, category, physical_score, chemical_score, biological_score,
    recommendations, assessed_at, created_by
) VALUES (
    $1, $2, $3, $4,
    $5, $6, $7, $8, $9,
    $10, $11, $12
) RETURNING id, uuid, tenant_id, field_id, farm_id,
    overall_score, category, physical_score, chemical_score, biological_score,
    recommendations, assessed_at,
    is_active, created_by, created_at, updated_by, updated_at, version;

-- name: GetLatestSoilHealthScore :one
SELECT id, uuid, tenant_id, field_id, farm_id,
    overall_score, category, physical_score, chemical_score, biological_score,
    recommendations, assessed_at,
    is_active, created_by, created_at, updated_by, updated_at, version
FROM soil_health_scores
WHERE field_id = $1 AND tenant_id = $2
    AND is_active = TRUE AND deleted_at IS NULL
ORDER BY assessed_at DESC
LIMIT 1;

-- name: UpdateSoilHealthScore :one
UPDATE soil_health_scores
SET
    overall_score = $3,
    category = $4,
    physical_score = $5,
    chemical_score = $6,
    biological_score = $7,
    recommendations = $8,
    assessed_at = $9,
    updated_by = $10,
    updated_at = NOW(),
    version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING id, uuid, tenant_id, field_id, farm_id,
    overall_score, category, physical_score, chemical_score, biological_score,
    recommendations, assessed_at,
    is_active, created_by, created_at, updated_by, updated_at, version;

-- name: ListSoilHealthScoresByFarm :many
SELECT id, uuid, tenant_id, field_id, farm_id,
    overall_score, category, physical_score, chemical_score, biological_score,
    recommendations, assessed_at,
    is_active, created_by, created_at, updated_by, updated_at, version
FROM soil_health_scores
WHERE farm_id = $1 AND tenant_id = $2
    AND is_active = TRUE AND deleted_at IS NULL
ORDER BY assessed_at DESC;
