-- name: CreateStressAlert :one
INSERT INTO stress_alerts (
    uuid, tenant_id, farm_id, field_id, processing_job_id,
    stress_type, severity, confidence, affected_area_hectares,
    affected_percentage, bbox_geojson, description, recommendation,
    acknowledged, detected_at, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, $11, $12, $13,
    FALSE, $14, TRUE, $15, NOW()
)
RETURNING *;

-- name: GetStressAlertByUUID :one
SELECT * FROM stress_alerts
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListStressAlerts :many
SELECT * FROM stress_alerts
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('stress_type')::stress_type IS NULL OR stress_type = sqlc.narg('stress_type')::stress_type)
    AND (sqlc.narg('min_severity')::severity_level IS NULL OR severity >= sqlc.narg('min_severity')::severity_level)
    AND (sqlc.narg('unacknowledged_only')::BOOLEAN IS NULL OR sqlc.narg('unacknowledged_only')::BOOLEAN = FALSE OR acknowledged = FALSE)
ORDER BY detected_at DESC
LIMIT $2 OFFSET $3;

-- name: CountStressAlerts :one
SELECT COUNT(*) FROM stress_alerts
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('stress_type')::stress_type IS NULL OR stress_type = sqlc.narg('stress_type')::stress_type)
    AND (sqlc.narg('min_severity')::severity_level IS NULL OR severity >= sqlc.narg('min_severity')::severity_level)
    AND (sqlc.narg('unacknowledged_only')::BOOLEAN IS NULL OR sqlc.narg('unacknowledged_only')::BOOLEAN = FALSE OR acknowledged = FALSE);

-- name: AcknowledgeStressAlert :exec
UPDATE stress_alerts SET
    acknowledged = TRUE,
    acknowledged_at = NOW(),
    acknowledged_by = $3,
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListStressAlertsByProcessingJob :many
SELECT * FROM stress_alerts
WHERE processing_job_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY severity DESC, detected_at DESC;

-- name: CountActiveStressAlerts :one
SELECT COUNT(*) FROM stress_alerts
WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3
    AND is_active = TRUE AND deleted_at IS NULL AND acknowledged = FALSE;

-- name: GetDominantStressType :one
SELECT stress_type FROM stress_alerts
WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3
    AND is_active = TRUE AND deleted_at IS NULL AND acknowledged = FALSE
GROUP BY stress_type
ORDER BY COUNT(*) DESC
LIMIT 1;

-- name: CreateTemporalAnalysis :one
INSERT INTO temporal_analyses (
    uuid, tenant_id, farm_id, field_id, analysis_type,
    metric_name, trend_slope, trend_r_squared, current_value,
    baseline_value, deviation_percent, period_start, period_end,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, $11, $12, $13,
    TRUE, $14, NOW()
)
RETURNING *;

-- name: GetTemporalAnalysisByUUID :one
SELECT * FROM temporal_analyses
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: GetLatestTemporalAnalysis :one
SELECT * FROM temporal_analyses
WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3
    AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 1;

-- name: ListTemporalAnalysesByField :many
SELECT * FROM temporal_analyses
WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3
    AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $4 OFFSET $5;
