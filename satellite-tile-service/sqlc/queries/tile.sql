-- name: CreateTileset :one
INSERT INTO tilesets (
    uuid, tenant_id, farm_id, processing_job_id, layer,
    format, status, min_zoom, max_zoom, s3_prefix,
    total_tiles, bbox_geojson, acquisition_date,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, 'QUEUED', $7, $8, $9,
    0, $10, $11,
    TRUE, $12, NOW()
)
RETURNING *;

-- name: GetTilesetByUUID :one
SELECT * FROM tilesets
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListTilesets :many
SELECT * FROM tilesets
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('layer')::tile_layer IS NULL OR layer = sqlc.narg('layer')::tile_layer)
    AND (sqlc.narg('status')::tileset_status IS NULL OR status = sqlc.narg('status')::tileset_status)
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountTilesets :one
SELECT COUNT(*) FROM tilesets
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::VARCHAR IS NULL OR farm_id = sqlc.narg('farm_id')::VARCHAR)
    AND (sqlc.narg('layer')::tile_layer IS NULL OR layer = sqlc.narg('layer')::tile_layer)
    AND (sqlc.narg('status')::tileset_status IS NULL OR status = sqlc.narg('status')::tileset_status);

-- name: UpdateTilesetStatus :one
UPDATE tilesets SET
    status = $3,
    error_message = $4,
    updated_by = $5,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: CompleteTileset :one
UPDATE tilesets SET
    status = 'COMPLETED',
    total_tiles = $3,
    s3_prefix = $4,
    completed_at = NOW(),
    updated_by = $5,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: FailTileset :one
UPDATE tilesets SET
    status = 'FAILED',
    error_message = $3,
    updated_by = $4,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: DeleteTileset :exec
UPDATE tilesets SET
    is_active = FALSE,
    deleted_by = $3,
    deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: CheckTilesetExists :one
SELECT EXISTS(
    SELECT 1 FROM tilesets
    WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
) AS exists;

-- name: GetTilesetByProcessingJobAndLayer :one
SELECT * FROM tilesets
WHERE processing_job_id = $1 AND tenant_id = $2 AND layer = $3
    AND is_active = TRUE AND deleted_at IS NULL;
