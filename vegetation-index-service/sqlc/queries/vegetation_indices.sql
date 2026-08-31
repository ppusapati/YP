-- name: InsertComputeTask :one
INSERT INTO compute_tasks (
    uuid, tenant_id, processing_job_uuid, farm_uuid, index_types,
    status, version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    'QUEUED', 1, TRUE, $6, NOW()
)
RETURNING *;

-- name: GetComputeTaskByUUID :one
SELECT * FROM compute_tasks
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListComputeTasks :many
SELECT * FROM compute_tasks
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('status')::compute_status IS NULL OR status = sqlc.narg('status')::compute_status)
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: UpdateComputeStatus :one
UPDATE compute_tasks SET
    status = $3,
    error_message = $4,
    compute_time_seconds = COALESCE($5, compute_time_seconds),
    completed_at = CASE WHEN $3 IN ('COMPLETED', 'FAILED') THEN NOW() ELSE completed_at END,
    version = version + 1,
    updated_by = $6,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: InsertVegetationIndex :one
INSERT INTO vegetation_indices (
    uuid, tenant_id, farm_uuid, field_uuid, processing_job_uuid,
    compute_task_uuid, index_type, mean_value, min_value, max_value,
    std_deviation, median_value, pixel_count, coverage_percent,
    raster_s3_key, acquisition_date, computed_at,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9, $10,
    $11, $12, $13, $14,
    $15, $16, NOW(),
    TRUE, $17, NOW()
)
RETURNING *;

-- name: GetVegetationIndexByUUID :one
SELECT * FROM vegetation_indices
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListVegetationIndices :many
SELECT * FROM vegetation_indices
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('field_uuid')::VARCHAR IS NULL OR field_uuid = sqlc.narg('field_uuid')::VARCHAR)
    AND (sqlc.narg('index_type')::vegetation_index_type IS NULL OR index_type = sqlc.narg('index_type')::vegetation_index_type)
    AND (sqlc.narg('date_from')::TIMESTAMPTZ IS NULL OR acquisition_date >= sqlc.narg('date_from')::TIMESTAMPTZ)
    AND (sqlc.narg('date_to')::TIMESTAMPTZ IS NULL OR acquisition_date <= sqlc.narg('date_to')::TIMESTAMPTZ)
ORDER BY acquisition_date DESC
LIMIT $2 OFFSET $3;

-- name: CountVegetationIndices :one
SELECT COUNT(*) FROM vegetation_indices
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('field_uuid')::VARCHAR IS NULL OR field_uuid = sqlc.narg('field_uuid')::VARCHAR)
    AND (sqlc.narg('index_type')::vegetation_index_type IS NULL OR index_type = sqlc.narg('index_type')::vegetation_index_type)
    AND (sqlc.narg('date_from')::TIMESTAMPTZ IS NULL OR acquisition_date >= sqlc.narg('date_from')::TIMESTAMPTZ)
    AND (sqlc.narg('date_to')::TIMESTAMPTZ IS NULL OR acquisition_date <= sqlc.narg('date_to')::TIMESTAMPTZ);

-- name: GetNDVITimeSeries :many
SELECT acquisition_date, mean_value, std_deviation
FROM vegetation_indices
WHERE tenant_id = $1
    AND farm_uuid = $2
    AND (sqlc.narg('field_uuid')::VARCHAR IS NULL OR field_uuid = sqlc.narg('field_uuid')::VARCHAR)
    AND index_type = 'NDVI'
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('date_from')::TIMESTAMPTZ IS NULL OR acquisition_date >= sqlc.narg('date_from')::TIMESTAMPTZ)
    AND (sqlc.narg('date_to')::TIMESTAMPTZ IS NULL OR acquisition_date <= sqlc.narg('date_to')::TIMESTAMPTZ)
ORDER BY acquisition_date ASC;

-- name: GetFieldHealthSummary :one
SELECT
    vi.mean_value AS current_ndvi,
    vi.acquisition_date AS last_computed,
    COALESCE(
        vi.mean_value - LAG(vi.mean_value) OVER (ORDER BY vi.acquisition_date),
        0
    ) AS ndvi_trend
FROM vegetation_indices vi
WHERE vi.tenant_id = $1
    AND vi.farm_uuid = $2
    AND (sqlc.narg('field_uuid')::VARCHAR IS NULL OR vi.field_uuid = sqlc.narg('field_uuid')::VARCHAR)
    AND vi.index_type = 'NDVI'
    AND vi.is_active = TRUE
    AND vi.deleted_at IS NULL
ORDER BY vi.acquisition_date DESC
LIMIT 1;
