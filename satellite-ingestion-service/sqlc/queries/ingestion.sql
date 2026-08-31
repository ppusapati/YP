-- name: InsertIngestionTask :one
INSERT INTO ingestion_tasks (
    uuid, tenant_id, farm_id, farm_uuid, provider,
    scene_id, status, s3_bucket, s3_key,
    cloud_cover_percent, resolution_meters, bands, bbox,
    file_size_bytes, checksum_sha256, error_message, retry_count,
    acquisition_date, is_active, version, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, 'QUEUED', $7, $8,
    $9, $10, $11, ST_GeomFromGeoJSON(sqlc.narg('bbox_geojson')),
    $12, $13, $14, 0,
    $15, TRUE, 1, $16, NOW()
)
RETURNING *;

-- name: GetIngestionTaskByUUID :one
SELECT * FROM ingestion_tasks
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListIngestionTasks :many
SELECT * FROM ingestion_tasks
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('provider')::satellite_provider IS NULL OR provider = sqlc.narg('provider')::satellite_provider)
    AND (sqlc.narg('status')::ingestion_status IS NULL OR status = sqlc.narg('status')::ingestion_status)
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountIngestionTasks :one
SELECT COUNT(*) FROM ingestion_tasks
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('provider')::satellite_provider IS NULL OR provider = sqlc.narg('provider')::satellite_provider)
    AND (sqlc.narg('status')::ingestion_status IS NULL OR status = sqlc.narg('status')::ingestion_status);

-- name: UpdateIngestionStatus :one
UPDATE ingestion_tasks SET
    status = $3::ingestion_status,
    s3_bucket = COALESCE(sqlc.narg('s3_bucket'), s3_bucket),
    s3_key = COALESCE(sqlc.narg('s3_key'), s3_key),
    file_size_bytes = COALESCE(sqlc.narg('file_size_bytes'), file_size_bytes),
    checksum_sha256 = COALESCE(sqlc.narg('checksum_sha256'), checksum_sha256),
    error_message = COALESCE(sqlc.narg('error_message'), error_message),
    retry_count = COALESCE(sqlc.narg('retry_count'), retry_count),
    completed_at = COALESCE(sqlc.narg('completed_at'), completed_at),
    version = version + 1,
    updated_by = $4,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: CancelIngestionTask :one
UPDATE ingestion_tasks SET
    status = 'FAILED',
    error_message = 'Cancelled by user',
    version = version + 1,
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2
    AND status IN ('QUEUED', 'DOWNLOADING')
    AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: GetIngestionStats :one
SELECT
    COUNT(*) AS total_tasks,
    COUNT(*) FILTER (WHERE status = 'STORED') AS completed_tasks,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_tasks,
    COUNT(*) FILTER (WHERE status IN ('QUEUED', 'DOWNLOADING', 'VALIDATING')) AS pending_tasks,
    COALESCE(SUM(file_size_bytes) FILTER (WHERE status = 'STORED'), 0) AS total_bytes_stored
FROM ingestion_tasks
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_uuid')::VARCHAR IS NULL OR farm_uuid = sqlc.narg('farm_uuid')::VARCHAR)
    AND (sqlc.narg('provider')::satellite_provider IS NULL OR provider = sqlc.narg('provider')::satellite_provider);
