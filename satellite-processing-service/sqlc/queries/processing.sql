-- name: InsertProcessingJob :one
INSERT INTO processing_jobs (
    uuid, tenant_id, ingestion_task_uuid, farm_uuid, status,
    input_level, output_level, algorithm, input_s3_key, output_s3_key,
    cloud_mask_threshold, apply_atmospheric_correction, apply_cloud_masking,
    apply_orthorectification, output_resolution_meters, output_crs,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9, $10,
    $11, $12, $13,
    $14, $15, $16,
    TRUE, $17, NOW()
)
RETURNING *;

-- name: GetProcessingJobByUUID :one
SELECT * FROM processing_jobs
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListProcessingJobs :many
SELECT * FROM processing_jobs
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('status')::processing_status IS NULL OR status = sqlc.narg('status')::processing_status)
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountProcessingJobs :one
SELECT COUNT(*) FROM processing_jobs
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('status')::processing_status IS NULL OR status = sqlc.narg('status')::processing_status);

-- name: UpdateProcessingStatus :one
UPDATE processing_jobs SET
    status = $3,
    output_s3_key = COALESCE(sqlc.narg('output_s3_key'), output_s3_key),
    error_message = COALESCE(sqlc.narg('error_message'), error_message),
    processing_time_seconds = COALESCE(sqlc.narg('processing_time_seconds'), processing_time_seconds),
    completed_at = COALESCE(sqlc.narg('completed_at'), completed_at),
    updated_by = $4,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: CancelProcessingJob :exec
UPDATE processing_jobs SET
    status = 'FAILED',
    error_message = 'Cancelled by user',
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2
    AND status NOT IN ('COMPLETED', 'FAILED')
    AND is_active = TRUE AND deleted_at IS NULL;

-- name: GetProcessingStats :one
SELECT
    COUNT(*) AS total_jobs,
    COUNT(*) FILTER (WHERE status = 'COMPLETED') AS completed_jobs,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_jobs,
    COUNT(*) FILTER (WHERE status NOT IN ('COMPLETED', 'FAILED')) AS pending_jobs,
    COALESCE(AVG(processing_time_seconds) FILTER (WHERE status = 'COMPLETED'), 0) AS avg_processing_time_seconds
FROM processing_jobs
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR);
