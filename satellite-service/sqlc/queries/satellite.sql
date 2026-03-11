-- ---------------------------------------------------------------------------
-- satellite_images
-- ---------------------------------------------------------------------------

-- name: CreateSatelliteImage :one
INSERT INTO satellite_images (
    uuid, tenant_id, field_id, farm_id, satellite_provider,
    acquisition_date, cloud_cover_pct, resolution_meters, bands,
    bbox, image_url, processing_status, version, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    ST_MakeEnvelope($10, $11, $12, $13, 4326),
    $14, $15, 1, $16, NOW()
)
RETURNING *;

-- name: GetSatelliteImageByUUID :one
SELECT * FROM satellite_images
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListSatelliteImagesByField :many
SELECT * FROM satellite_images
WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY acquisition_date DESC
LIMIT $3 OFFSET $4;

-- name: ListSatelliteImagesByFarm :many
SELECT * FROM satellite_images
WHERE tenant_id = $1 AND farm_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY acquisition_date DESC
LIMIT $3 OFFSET $4;

-- name: ListSatelliteImagesByTenant :many
SELECT * FROM satellite_images
WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY acquisition_date DESC
LIMIT $2 OFFSET $3;

-- name: CountSatelliteImagesByTenant :one
SELECT COUNT(*) FROM satellite_images
WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL;

-- name: CountSatelliteImagesByField :one
SELECT COUNT(*) FROM satellite_images
WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: CountSatelliteImagesByFarm :one
SELECT COUNT(*) FROM satellite_images
WHERE tenant_id = $1 AND farm_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: UpdateSatelliteImageStatus :one
UPDATE satellite_images
SET processing_status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: UpdateSatelliteImageURL :one
UPDATE satellite_images
SET image_url = $3, updated_by = $4, updated_at = NOW(), version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteSatelliteImage :exec
UPDATE satellite_images
SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- vegetation_indices
-- ---------------------------------------------------------------------------

-- name: CreateVegetationIndex :one
INSERT INTO vegetation_indices (
    uuid, tenant_id, image_id, field_id, index_type,
    min_value, max_value, mean_value, std_dev,
    raster_url, computed_at, version, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, NOW(), 1, $11, NOW()
)
RETURNING *;

-- name: GetVegetationIndexByUUID :one
SELECT * FROM vegetation_indices
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListVegetationIndicesByImage :many
SELECT * FROM vegetation_indices
WHERE tenant_id = $1 AND image_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: ListVegetationIndicesByField :many
SELECT * FROM vegetation_indices
WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY computed_at DESC;

-- name: ListVegetationIndicesByFieldAndType :many
SELECT * FROM vegetation_indices
WHERE tenant_id = $1 AND field_id = $2 AND index_type = $3 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY computed_at DESC;

-- name: GetVegetationIndexByImageAndType :one
SELECT * FROM vegetation_indices
WHERE image_id = $1 AND index_type = $2 AND tenant_id = $3 AND is_active = TRUE AND deleted_at IS NULL;

-- name: SoftDeleteVegetationIndex :exec
UPDATE vegetation_indices
SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- crop_stress_alerts
-- ---------------------------------------------------------------------------

-- name: CreateCropStressAlert :one
INSERT INTO crop_stress_alerts (
    uuid, tenant_id, field_id, image_id, stress_detected,
    stress_type, stress_severity, affected_area_pct,
    description, recommendation,
    affected_bbox,
    version, detected_at, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8,
    $9, $10,
    ST_MakeEnvelope($11, $12, $13, $14, 4326),
    1, NOW(), $15, NOW()
)
RETURNING *;

-- name: GetCropStressAlertByUUID :one
SELECT * FROM crop_stress_alerts
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListCropStressAlertsByField :many
SELECT * FROM crop_stress_alerts
WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY detected_at DESC
LIMIT $3 OFFSET $4;

-- name: ListCropStressAlertsByTenant :many
SELECT * FROM crop_stress_alerts
WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY detected_at DESC
LIMIT $2 OFFSET $3;

-- name: CountCropStressAlertsByField :one
SELECT COUNT(*) FROM crop_stress_alerts
WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: CountCropStressAlertsByTenant :one
SELECT COUNT(*) FROM crop_stress_alerts
WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListCropStressAlertsByImage :many
SELECT * FROM crop_stress_alerts
WHERE tenant_id = $1 AND image_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY detected_at DESC;

-- name: SoftDeleteCropStressAlert :exec
UPDATE crop_stress_alerts
SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- temporal_analyses
-- ---------------------------------------------------------------------------

-- name: CreateTemporalAnalysis :one
INSERT INTO temporal_analyses (
    uuid, tenant_id, field_id, index_type,
    start_date, end_date, data_points,
    trend_slope, trend_direction, change_pct,
    version, created_by, created_at
) VALUES (
    $1, $2, $3, $4,
    $5, $6, $7,
    $8, $9, $10,
    1, $11, NOW()
)
RETURNING *;

-- name: GetTemporalAnalysisByUUID :one
SELECT * FROM temporal_analyses
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: GetTemporalAnalysisByFieldAndType :one
SELECT * FROM temporal_analyses
WHERE tenant_id = $1 AND field_id = $2 AND index_type = $3
  AND start_date <= $4 AND end_date >= $5
  AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 1;

-- name: ListTemporalAnalysesByField :many
SELECT * FROM temporal_analyses
WHERE tenant_id = $1 AND field_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at DESC;

-- name: SoftDeleteTemporalAnalysis :exec
UPDATE temporal_analyses
SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- ---------------------------------------------------------------------------
-- satellite_tasks
-- ---------------------------------------------------------------------------

-- name: CreateSatelliteTask :one
INSERT INTO satellite_tasks (
    uuid, tenant_id, field_id, task_type, status,
    input_image_id, result_id, error_message, retry_count,
    version, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    1, $10, NOW()
)
RETURNING *;

-- name: GetSatelliteTaskByUUID :one
SELECT * FROM satellite_tasks
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: UpdateSatelliteTaskStatus :one
UPDATE satellite_tasks
SET status = $3, result_id = $4, error_message = $5,
    updated_by = $6, updated_at = NOW(), version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: IncrementSatelliteTaskRetry :one
UPDATE satellite_tasks
SET retry_count = retry_count + 1, updated_by = $3, updated_at = NOW(), version = version + 1
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: ListSatelliteTasksByTenant :many
SELECT * FROM satellite_tasks
WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: ListPendingSatelliteTasks :many
SELECT * FROM satellite_tasks
WHERE status = 'PENDING' AND is_active = TRUE AND deleted_at IS NULL
ORDER BY created_at ASC
LIMIT $1;
