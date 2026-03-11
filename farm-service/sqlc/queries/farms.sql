-- name: CreateFarm :one
INSERT INTO farms (
    uuid, tenant_id, name, description, total_area_hectares,
    latitude, longitude, elevation_meters, farm_type, status,
    soil_type, climate_zone, address, region, country,
    metadata, version, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9, $10,
    $11, $12, $13, $14, $15,
    $16, 1, TRUE, $17, NOW()
)
RETURNING *;

-- name: GetFarmByUUID :one
SELECT * FROM farms
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: GetFarmByID :one
SELECT * FROM farms
WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: ListFarms :many
SELECT * FROM farms
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_type')::farm_type IS NULL OR farm_type = sqlc.narg('farm_type')::farm_type)
    AND (sqlc.narg('status')::farm_status IS NULL OR status = sqlc.narg('status')::farm_status)
    AND (sqlc.narg('region')::VARCHAR IS NULL OR region = sqlc.narg('region')::VARCHAR)
    AND (sqlc.narg('country')::VARCHAR IS NULL OR country = sqlc.narg('country')::VARCHAR)
    AND (sqlc.narg('climate_zone')::climate_zone IS NULL OR climate_zone = sqlc.narg('climate_zone')::climate_zone)
    AND (sqlc.narg('search')::VARCHAR IS NULL OR name ILIKE '%' || sqlc.narg('search')::VARCHAR || '%')
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountFarms :one
SELECT COUNT(*) FROM farms
WHERE tenant_id = $1
    AND is_active = TRUE
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_type')::farm_type IS NULL OR farm_type = sqlc.narg('farm_type')::farm_type)
    AND (sqlc.narg('status')::farm_status IS NULL OR status = sqlc.narg('status')::farm_status)
    AND (sqlc.narg('region')::VARCHAR IS NULL OR region = sqlc.narg('region')::VARCHAR)
    AND (sqlc.narg('country')::VARCHAR IS NULL OR country = sqlc.narg('country')::VARCHAR)
    AND (sqlc.narg('climate_zone')::climate_zone IS NULL OR climate_zone = sqlc.narg('climate_zone')::climate_zone)
    AND (sqlc.narg('search')::VARCHAR IS NULL OR name ILIKE '%' || sqlc.narg('search')::VARCHAR || '%');

-- name: UpdateFarm :one
UPDATE farms SET
    name = COALESCE(sqlc.narg('name'), name),
    description = COALESCE(sqlc.narg('description'), description),
    total_area_hectares = COALESCE(sqlc.narg('total_area_hectares'), total_area_hectares),
    latitude = COALESCE(sqlc.narg('latitude'), latitude),
    longitude = COALESCE(sqlc.narg('longitude'), longitude),
    elevation_meters = COALESCE(sqlc.narg('elevation_meters'), elevation_meters),
    farm_type = COALESCE(sqlc.narg('farm_type')::farm_type, farm_type),
    status = COALESCE(sqlc.narg('status')::farm_status, status),
    soil_type = COALESCE(sqlc.narg('soil_type')::soil_type, soil_type),
    climate_zone = COALESCE(sqlc.narg('climate_zone')::climate_zone, climate_zone),
    address = COALESCE(sqlc.narg('address'), address),
    region = COALESCE(sqlc.narg('region'), region),
    country = COALESCE(sqlc.narg('country'), country),
    metadata = COALESCE(sqlc.narg('metadata'), metadata),
    version = version + 1,
    updated_by = $3,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: DeleteFarm :exec
UPDATE farms SET
    is_active = FALSE,
    deleted_by = $3,
    deleted_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: CheckFarmExists :one
SELECT EXISTS(
    SELECT 1 FROM farms
    WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
) AS exists;

-- name: CheckFarmNameExists :one
SELECT EXISTS(
    SELECT 1 FROM farms
    WHERE name = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
) AS exists;

-- name: CreateFarmBoundary :one
INSERT INTO farm_boundaries (
    uuid, farm_id, farm_uuid, tenant_id, geojson,
    boundary, area_hectares, perimeter_meters,
    is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    ST_GeomFromGeoJSON($5), $6, $7,
    TRUE, $8, NOW()
)
RETURNING *;

-- name: GetFarmBoundaryByFarmUUID :one
SELECT * FROM farm_boundaries
WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: UpdateFarmBoundary :one
UPDATE farm_boundaries SET
    geojson = $3,
    boundary = ST_GeomFromGeoJSON($3),
    area_hectares = $4,
    perimeter_meters = $5,
    updated_by = $6,
    updated_at = NOW()
WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: DeleteFarmBoundary :exec
UPDATE farm_boundaries SET
    is_active = FALSE,
    deleted_by = $3,
    deleted_at = NOW()
WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL;

-- name: CreateFarmOwner :one
INSERT INTO farm_owners (
    uuid, farm_id, farm_uuid, tenant_id, user_id,
    owner_name, email, phone, is_primary, ownership_percentage,
    acquired_at, is_active, created_by, created_at
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9, $10,
    COALESCE(sqlc.narg('acquired_at'), NOW()), TRUE, $11, NOW()
)
RETURNING *;

-- name: GetFarmOwnersByFarmUUID :many
SELECT * FROM farm_owners
WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
ORDER BY is_primary DESC, created_at ASC;

-- name: GetFarmOwnerByUserID :one
SELECT * FROM farm_owners
WHERE farm_uuid = $1 AND tenant_id = $2 AND user_id = $3
    AND is_active = TRUE AND deleted_at IS NULL;

-- name: UpdateFarmOwner :one
UPDATE farm_owners SET
    owner_name = COALESCE(sqlc.narg('owner_name'), owner_name),
    email = COALESCE(sqlc.narg('email'), email),
    phone = COALESCE(sqlc.narg('phone'), phone),
    is_primary = COALESCE(sqlc.narg('is_primary'), is_primary),
    ownership_percentage = COALESCE(sqlc.narg('ownership_percentage'), ownership_percentage),
    updated_by = $4,
    updated_at = NOW()
WHERE uuid = $1 AND tenant_id = $2 AND farm_uuid = $3
    AND is_active = TRUE AND deleted_at IS NULL
RETURNING *;

-- name: DeactivateFarmOwner :exec
UPDATE farm_owners SET
    is_active = FALSE,
    deleted_by = $4,
    deleted_at = NOW()
WHERE farm_uuid = $1 AND tenant_id = $2 AND user_id = $3
    AND is_active = TRUE AND deleted_at IS NULL;

-- name: SetFarmOwnerPrimary :exec
UPDATE farm_owners SET
    is_primary = FALSE,
    updated_by = $3,
    updated_at = NOW()
WHERE farm_uuid = $1 AND tenant_id = $2 AND is_primary = TRUE
    AND is_active = TRUE AND deleted_at IS NULL;
