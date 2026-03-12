-- name: CreateYieldPrediction :one
INSERT INTO yield_predictions (
    uuid, tenant_id, farm_id, field_id, crop_id, season, year,
    predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
    status, soil_quality_score, weather_score, irrigation_score,
    pest_pressure_score, nutrient_score, management_score,
    is_active, version, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7,
    $8, $9, $10,
    $11, $12, $13, $14,
    $15, $16, $17,
    TRUE, 1, $18, NOW()
) RETURNING *;

-- name: GetYieldPredictionByUUID :one
SELECT * FROM yield_predictions
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE;

-- name: ListYieldPredictions :many
SELECT * FROM yield_predictions
WHERE tenant_id = $1
  AND is_active = TRUE
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('crop_id')::VARCHAR IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('season')::VARCHAR IS NULL OR season = sqlc.narg('season'))
  AND (sqlc.narg('year')::INTEGER IS NULL OR year = sqlc.narg('year'))
  AND (sqlc.narg('status')::VARCHAR IS NULL OR status = sqlc.narg('status'))
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountYieldPredictions :one
SELECT COUNT(*) FROM yield_predictions
WHERE tenant_id = $1
  AND is_active = TRUE
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('crop_id')::VARCHAR IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('season')::VARCHAR IS NULL OR season = sqlc.narg('season'))
  AND (sqlc.narg('year')::INTEGER IS NULL OR year = sqlc.narg('year'))
  AND (sqlc.narg('status')::VARCHAR IS NULL OR status = sqlc.narg('status'));

-- name: UpdateYieldPredictionStatus :one
UPDATE yield_predictions
SET status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE
RETURNING *;

-- name: CreateYieldRecord :one
INSERT INTO yield_records (
    uuid, tenant_id, farm_id, field_id, crop_id, season, year,
    actual_yield_kg_per_hectare, total_area_harvested_hectares, total_yield_kg,
    harvest_quality_grade, moisture_content_pct, harvest_date,
    revenue_per_hectare, cost_per_hectare, profit_per_hectare,
    prediction_id, is_active, version, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7,
    $8, $9, $10,
    $11, $12, $13,
    $14, $15, $16,
    $17, TRUE, 1, $18, NOW()
) RETURNING *;

-- name: GetYieldRecordByUUID :one
SELECT * FROM yield_records
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE;

-- name: ListYieldRecords :many
SELECT * FROM yield_records
WHERE tenant_id = $1
  AND is_active = TRUE
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('crop_id')::VARCHAR IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('from_year')::INTEGER IS NULL OR year >= sqlc.narg('from_year'))
  AND (sqlc.narg('to_year')::INTEGER IS NULL OR year <= sqlc.narg('to_year'))
ORDER BY year DESC, harvest_date DESC
LIMIT $2 OFFSET $3;

-- name: CountYieldRecords :one
SELECT COUNT(*) FROM yield_records
WHERE tenant_id = $1
  AND is_active = TRUE
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('crop_id')::VARCHAR IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('from_year')::INTEGER IS NULL OR year >= sqlc.narg('from_year'))
  AND (sqlc.narg('to_year')::INTEGER IS NULL OR year <= sqlc.narg('to_year'));

-- name: GetAverageYieldForCrop :one
SELECT COALESCE(AVG(actual_yield_kg_per_hectare), 0)::DOUBLE PRECISION AS avg_yield
FROM yield_records
WHERE tenant_id = $1
  AND crop_id = $2
  AND is_active = TRUE;

-- name: GetRegionalAverageYield :one
SELECT COALESCE(AVG(actual_yield_kg_per_hectare), 0)::DOUBLE PRECISION AS avg_yield
FROM yield_records
WHERE tenant_id = $1
  AND crop_id = $2
  AND season = $3
  AND is_active = TRUE;

-- name: GetHistoricalAverageYield :one
SELECT COALESCE(AVG(actual_yield_kg_per_hectare), 0)::DOUBLE PRECISION AS avg_yield
FROM yield_records
WHERE tenant_id = $1
  AND farm_id = $2
  AND field_id = $3
  AND crop_id = $4
  AND is_active = TRUE;

-- name: CreateHarvestPlan :one
INSERT INTO harvest_plans (
    uuid, tenant_id, farm_id, field_id, crop_id, season, year,
    planned_start_date, planned_end_date, estimated_yield_kg,
    total_area_hectares, status, notes,
    is_active, version, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7,
    $8, $9, $10,
    $11, $12, $13,
    TRUE, 1, $14, NOW()
) RETURNING *;

-- name: GetHarvestPlanByUUID :one
SELECT * FROM harvest_plans
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE;

-- name: ListHarvestPlans :many
SELECT * FROM harvest_plans
WHERE tenant_id = $1
  AND is_active = TRUE
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('crop_id')::VARCHAR IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('season')::VARCHAR IS NULL OR season = sqlc.narg('season'))
  AND (sqlc.narg('year')::INTEGER IS NULL OR year = sqlc.narg('year'))
  AND (sqlc.narg('status')::VARCHAR IS NULL OR status = sqlc.narg('status'))
ORDER BY planned_start_date ASC
LIMIT $2 OFFSET $3;

-- name: CountHarvestPlans :one
SELECT COUNT(*) FROM harvest_plans
WHERE tenant_id = $1
  AND is_active = TRUE
  AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id'))
  AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id'))
  AND (sqlc.narg('crop_id')::VARCHAR IS NULL OR crop_id = sqlc.narg('crop_id'))
  AND (sqlc.narg('season')::VARCHAR IS NULL OR season = sqlc.narg('season'))
  AND (sqlc.narg('year')::INTEGER IS NULL OR year = sqlc.narg('year'))
  AND (sqlc.narg('status')::VARCHAR IS NULL OR status = sqlc.narg('status'));

-- name: UpdateHarvestPlanStatus :one
UPDATE harvest_plans
SET status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE
RETURNING *;

-- name: UpsertCropPerformance :one
INSERT INTO crop_performance (
    uuid, tenant_id, farm_id, field_id, crop_id, season, year,
    actual_yield_kg_per_hectare, predicted_yield_kg_per_hectare,
    yield_variance_pct, comparison_to_regional_avg_pct,
    comparison_to_historical_avg_pct, revenue_per_hectare,
    cost_per_hectare, profit_per_hectare,
    soil_quality_score, weather_score, irrigation_score,
    pest_pressure_score, nutrient_score, management_score,
    is_active, version, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7,
    $8, $9,
    $10, $11,
    $12, $13,
    $14, $15,
    $16, $17, $18,
    $19, $20, $21,
    TRUE, 1, NOW()
)
ON CONFLICT (tenant_id, farm_id, field_id, crop_id, season, year) DO UPDATE SET
    actual_yield_kg_per_hectare = EXCLUDED.actual_yield_kg_per_hectare,
    predicted_yield_kg_per_hectare = EXCLUDED.predicted_yield_kg_per_hectare,
    yield_variance_pct = EXCLUDED.yield_variance_pct,
    comparison_to_regional_avg_pct = EXCLUDED.comparison_to_regional_avg_pct,
    comparison_to_historical_avg_pct = EXCLUDED.comparison_to_historical_avg_pct,
    revenue_per_hectare = EXCLUDED.revenue_per_hectare,
    cost_per_hectare = EXCLUDED.cost_per_hectare,
    profit_per_hectare = EXCLUDED.profit_per_hectare,
    soil_quality_score = EXCLUDED.soil_quality_score,
    weather_score = EXCLUDED.weather_score,
    irrigation_score = EXCLUDED.irrigation_score,
    pest_pressure_score = EXCLUDED.pest_pressure_score,
    nutrient_score = EXCLUDED.nutrient_score,
    management_score = EXCLUDED.management_score,
    version = crop_performance.version + 1,
    updated_at = NOW()
RETURNING *;

-- name: GetCropPerformance :one
SELECT * FROM crop_performance
WHERE tenant_id = $1
  AND farm_id = $2
  AND field_id = $3
  AND crop_id = $4
  AND season = $5
  AND year = $6
  AND is_active = TRUE;

-- name: GetCropPerformanceByUUID :one
SELECT * FROM crop_performance
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE;
