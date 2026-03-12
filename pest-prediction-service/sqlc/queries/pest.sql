-- ============================================================================
-- Pest Species Queries
-- ============================================================================

-- name: CreatePestSpecies :one
INSERT INTO pest_species (
    uuid, tenant_id, common_name, scientific_name, family,
    description, affected_crops, favorable_conditions, image_url,
    version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    1, TRUE, $10, NOW()
)
RETURNING *;

-- name: GetPestSpeciesByUUID :one
SELECT * FROM pest_species
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListPestSpecies :many
SELECT * FROM pest_species
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('search')::VARCHAR IS NULL OR
         common_name ILIKE '%' || sqlc.narg('search')::VARCHAR || '%' OR
         scientific_name ILIKE '%' || sqlc.narg('search')::VARCHAR || '%')
ORDER BY common_name ASC
LIMIT $2 OFFSET $3;

-- name: CountPestSpecies :one
SELECT COUNT(*) FROM pest_species
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('search')::VARCHAR IS NULL OR
         common_name ILIKE '%' || sqlc.narg('search')::VARCHAR || '%' OR
         scientific_name ILIKE '%' || sqlc.narg('search')::VARCHAR || '%');

-- ============================================================================
-- Pest Predictions Queries
-- ============================================================================

-- name: CreatePestPrediction :one
INSERT INTO pest_predictions (
    uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
    prediction_date, risk_level, risk_score, confidence_pct,
    temperature_celsius, humidity_pct, rainfall_mm, wind_speed_kmh,
    crop_type, growth_stage, geographic_risk_factor, historical_occurrence_count,
    predicted_onset_date, predicted_peak_date,
    treatment_window_start, treatment_window_end,
    recommended_treatments,
    version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    NOW(), $7, $8, $9,
    $10, $11, $12, $13,
    $14, $15, $16, $17,
    $18, $19,
    $20, $21,
    $22,
    1, TRUE, $23, NOW()
)
RETURNING *;

-- name: GetPestPredictionByUUID :one
SELECT * FROM pest_predictions
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListPestPredictions :many
SELECT * FROM pest_predictions
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id')::VARCHAR)
    AND (sqlc.narg('pest_species_uuid')::VARCHAR IS NULL OR pest_species_uuid = sqlc.narg('pest_species_uuid')::VARCHAR)
    AND (sqlc.narg('min_risk_level')::risk_level IS NULL OR risk_level >= sqlc.narg('min_risk_level')::risk_level)
ORDER BY prediction_date DESC
LIMIT $2 OFFSET $3;

-- name: CountPestPredictions :one
SELECT COUNT(*) FROM pest_predictions
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id')::VARCHAR)
    AND (sqlc.narg('pest_species_uuid')::VARCHAR IS NULL OR pest_species_uuid = sqlc.narg('pest_species_uuid')::VARCHAR)
    AND (sqlc.narg('min_risk_level')::risk_level IS NULL OR risk_level >= sqlc.narg('min_risk_level')::risk_level);

-- name: GetHistoricalOccurrenceCount :one
SELECT COUNT(*) FROM pest_predictions
WHERE tenant_id = $1
    AND farm_id = $2
    AND pest_species_uuid = $3
    AND risk_level IN ('MODERATE', 'HIGH', 'CRITICAL')
    AND is_active = TRUE
    AND deleted_at IS NULL;

-- ============================================================================
-- Pest Alerts Queries
-- ============================================================================

-- name: CreatePestAlert :one
INSERT INTO pest_alerts (
    uuid, tenant_id, prediction_id, prediction_uuid, farm_id, field_id,
    pest_species_id, pest_species_uuid, risk_level, status,
    title, message,
    version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, 'ACTIVE',
    $10, $11,
    1, TRUE, $12, NOW()
)
RETURNING *;

-- name: ListPestAlerts :many
SELECT * FROM pest_alerts
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id')::VARCHAR)
    AND (sqlc.narg('status')::alert_status IS NULL OR status = sqlc.narg('status')::alert_status)
    AND (sqlc.narg('min_risk_level')::risk_level IS NULL OR risk_level >= sqlc.narg('min_risk_level')::risk_level)
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountPestAlerts :one
SELECT COUNT(*) FROM pest_alerts
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id')::VARCHAR)
    AND (sqlc.narg('status')::alert_status IS NULL OR status = sqlc.narg('status')::alert_status)
    AND (sqlc.narg('min_risk_level')::risk_level IS NULL OR risk_level >= sqlc.narg('min_risk_level')::risk_level);

-- name: AcknowledgePestAlert :one
UPDATE pest_alerts SET
    status = 'ACKNOWLEDGED',
    acknowledged_at = NOW(),
    acknowledged_by = $3,
    updated_by = $3,
    updated_at = NOW(),
    version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND status = 'ACTIVE'
    AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- ============================================================================
-- Pest Observations Queries
-- ============================================================================

-- name: CreatePestObservation :one
INSERT INTO pest_observations (
    uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
    pest_count, damage_level, trap_type, image_url,
    location, latitude, longitude, notes,
    observed_by, observed_at,
    version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10,
    CASE WHEN $12::DOUBLE PRECISION IS NOT NULL AND $13::DOUBLE PRECISION IS NOT NULL
        THEN ST_SetSRID(ST_MakePoint($13::DOUBLE PRECISION, $12::DOUBLE PRECISION), 4326)
        ELSE NULL
    END,
    $12, $13, $11,
    $14, NOW(),
    1, TRUE, $14, NOW()
)
RETURNING *;

-- name: ListPestObservations :many
SELECT * FROM pest_observations
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id')::VARCHAR)
    AND (sqlc.narg('pest_species_uuid')::VARCHAR IS NULL OR pest_species_uuid = sqlc.narg('pest_species_uuid')::VARCHAR)
ORDER BY observed_at DESC
LIMIT $2 OFFSET $3;

-- name: CountPestObservations :one
SELECT COUNT(*) FROM pest_observations
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('field_id')::VARCHAR IS NULL OR field_id = sqlc.narg('field_id')::VARCHAR)
    AND (sqlc.narg('pest_species_uuid')::VARCHAR IS NULL OR pest_species_uuid = sqlc.narg('pest_species_uuid')::VARCHAR);

-- name: GetRecentObservationsBySpecies :many
SELECT * FROM pest_observations
WHERE tenant_id = $1
    AND farm_id = $2
    AND pest_species_uuid = $3
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND observed_at >= NOW() - INTERVAL '90 days'
ORDER BY observed_at DESC
LIMIT 50;

-- ============================================================================
-- Pest Treatments Queries
-- ============================================================================

-- name: CreatePestTreatment :one
INSERT INTO pest_treatments (
    uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
    prediction_id, prediction_uuid, treatment_type, product_name,
    application_rate, application_method, cost, effectiveness_rating,
    applied_by, applied_at, notes,
    version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5, $6,
    $7, $8, $9, $10,
    $11, $12, $13, $14,
    $15, NOW(), $16,
    1, TRUE, $15, NOW()
)
RETURNING *;

-- name: ListPestTreatmentsByPrediction :many
SELECT * FROM pest_treatments
WHERE prediction_uuid = $1 AND tenant_id = $2
    AND is_active = TRUE AND deleted_at IS NULL
ORDER BY applied_at DESC;

-- ============================================================================
-- Pest Risk Maps Queries
-- ============================================================================

-- name: CreatePestRiskMap :one
INSERT INTO pest_risk_maps (
    uuid, tenant_id, pest_species_id, pest_species_uuid,
    region, overall_risk_level, geojson,
    boundary, valid_from, valid_until,
    version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4,
    $5, $6, $7,
    ST_GeomFromGeoJSON($7), $8, $9,
    1, TRUE, $10, NOW()
)
RETURNING *;

-- name: GetPestRiskMap :one
SELECT * FROM pest_risk_maps
WHERE tenant_id = $1
    AND pest_species_uuid = $2
    AND region = $3
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND valid_from <= NOW()
    AND valid_until >= NOW()
ORDER BY created_at DESC
LIMIT 1;

-- name: UpsertPestRiskMap :one
INSERT INTO pest_risk_maps (
    uuid, tenant_id, pest_species_id, pest_species_uuid,
    region, overall_risk_level, geojson,
    boundary, valid_from, valid_until,
    version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4,
    $5, $6, $7,
    ST_GeomFromGeoJSON($7), $8, $9,
    1, TRUE, $10, NOW()
)
ON CONFLICT (uuid) DO UPDATE SET
    overall_risk_level = EXCLUDED.overall_risk_level,
    geojson = EXCLUDED.geojson,
    boundary = ST_GeomFromGeoJSON(EXCLUDED.geojson),
    valid_from = EXCLUDED.valid_from,
    valid_until = EXCLUDED.valid_until,
    version = pest_risk_maps.version + 1,
    updated_by = $10,
    updated_at = NOW()
RETURNING *;
