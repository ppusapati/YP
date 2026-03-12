-- name: CreateField :one
INSERT INTO fields (
    id, tenant_id, farm_id, name, area_hectares, boundary,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version
) VALUES (
    $1, $2, $3, $4, $5, ST_GeomFromGeoJSON($6),
    $7, $8, $9,
    $10, $11, $12, $13, $14,
    $15, $16, $17,
    $18, $19, NOW(), NOW(), 1
)
RETURNING id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version;

-- name: GetFieldByID :one
SELECT
    id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version
FROM fields
WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListFields :many
SELECT
    id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version
FROM fields
WHERE tenant_id = $1
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::varchar IS NULL OR farm_id = sqlc.narg('farm_id'))
    AND (sqlc.narg('status')::varchar IS NULL OR status = sqlc.narg('status'))
    AND (sqlc.narg('field_type')::varchar IS NULL OR field_type = sqlc.narg('field_type'))
    AND (sqlc.narg('search')::varchar IS NULL OR name ILIKE '%' || sqlc.narg('search') || '%')
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountFields :one
SELECT COUNT(*) AS total_count
FROM fields
WHERE tenant_id = $1
    AND deleted_at IS NULL
    AND (sqlc.narg('farm_id')::varchar IS NULL OR farm_id = sqlc.narg('farm_id'))
    AND (sqlc.narg('status')::varchar IS NULL OR status = sqlc.narg('status'))
    AND (sqlc.narg('field_type')::varchar IS NULL OR field_type = sqlc.narg('field_type'))
    AND (sqlc.narg('search')::varchar IS NULL OR name ILIKE '%' || sqlc.narg('search') || '%');

-- name: UpdateField :one
UPDATE fields
SET
    name              = COALESCE(sqlc.narg('name'), name),
    area_hectares     = COALESCE(sqlc.narg('area_hectares'), area_hectares),
    field_type        = COALESCE(sqlc.narg('field_type'), field_type),
    soil_type         = COALESCE(sqlc.narg('soil_type'), soil_type),
    irrigation_type   = COALESCE(sqlc.narg('irrigation_type'), irrigation_type),
    status            = COALESCE(sqlc.narg('status'), status),
    elevation_meters  = COALESCE(sqlc.narg('elevation_meters'), elevation_meters),
    slope_degrees     = COALESCE(sqlc.narg('slope_degrees'), slope_degrees),
    aspect_direction  = COALESCE(sqlc.narg('aspect_direction'), aspect_direction),
    growth_stage      = COALESCE(sqlc.narg('growth_stage'), growth_stage),
    updated_by        = $3,
    updated_at        = NOW(),
    version           = version + 1
WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version;

-- name: SoftDeleteField :exec
UPDATE fields
SET deleted_at = NOW(), updated_by = $3, updated_at = NOW(), version = version + 1
WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: ListFieldsByFarm :many
SELECT
    id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version
FROM fields
WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL
ORDER BY name ASC
LIMIT $3 OFFSET $4;

-- name: CountFieldsByFarm :one
SELECT COUNT(*) AS total_count
FROM fields
WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL;

-- name: UpdateFieldBoundary :one
UPDATE fields
SET
    boundary     = ST_GeomFromGeoJSON($3),
    area_hectares = $4,
    updated_by   = $5,
    updated_at   = NOW(),
    version      = version + 1
WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
RETURNING id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version;

-- name: UpdateFieldCurrentCrop :exec
UPDATE fields
SET
    current_crop_id       = $3,
    planting_date         = $4,
    expected_harvest_date = $5,
    growth_stage          = $6,
    updated_by            = $7,
    updated_at            = NOW(),
    version               = version + 1
WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL;

-- name: FieldExists :one
SELECT EXISTS(
    SELECT 1 FROM fields WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
) AS exists;

-- name: FieldNameExists :one
SELECT EXISTS(
    SELECT 1 FROM fields
    WHERE tenant_id = $1 AND farm_id = $2 AND name = $3 AND deleted_at IS NULL
) AS exists;

-- -----------------------------------------------------------------------------
-- Field Boundaries
-- -----------------------------------------------------------------------------

-- name: CreateFieldBoundary :one
INSERT INTO field_boundaries (
    id, field_id, polygon, area_hectares, perimeter_meters, source, recorded_at, created_at
) VALUES (
    $1, $2, ST_GeomFromGeoJSON($3), $4, $5, $6, $7, NOW()
)
RETURNING id, field_id,
    ST_AsGeoJSON(polygon)::text AS polygon_geojson,
    area_hectares, perimeter_meters, source, recorded_at, created_at;

-- name: ListFieldBoundaries :many
SELECT
    id, field_id,
    ST_AsGeoJSON(polygon)::text AS polygon_geojson,
    area_hectares, perimeter_meters, source, recorded_at, created_at
FROM field_boundaries
WHERE field_id = $1
ORDER BY recorded_at DESC;

-- name: GetLatestFieldBoundary :one
SELECT
    id, field_id,
    ST_AsGeoJSON(polygon)::text AS polygon_geojson,
    area_hectares, perimeter_meters, source, recorded_at, created_at
FROM field_boundaries
WHERE field_id = $1
ORDER BY recorded_at DESC
LIMIT 1;

-- name: DeleteFieldBoundaries :exec
DELETE FROM field_boundaries WHERE field_id = $1;

-- -----------------------------------------------------------------------------
-- Field Crop Assignments
-- -----------------------------------------------------------------------------

-- name: CreateCropAssignment :one
INSERT INTO field_crop_assignments (
    id, field_id, crop_id, crop_variety, planting_date,
    expected_harvest_date, growth_stage, notes, season, created_at, updated_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW()
)
RETURNING id, field_id, crop_id, crop_variety, planting_date,
    expected_harvest_date, actual_harvest_date, growth_stage,
    yield_per_hectare, notes, season, created_at, updated_at;

-- name: ListCropAssignments :many
SELECT
    id, field_id, crop_id, crop_variety, planting_date,
    expected_harvest_date, actual_harvest_date, growth_stage,
    yield_per_hectare, notes, season, created_at, updated_at
FROM field_crop_assignments
WHERE field_id = $1
ORDER BY planting_date DESC
LIMIT $2 OFFSET $3;

-- name: CountCropAssignments :one
SELECT COUNT(*) AS total_count
FROM field_crop_assignments
WHERE field_id = $1;

-- name: GetCurrentCropAssignment :one
SELECT
    id, field_id, crop_id, crop_variety, planting_date,
    expected_harvest_date, actual_harvest_date, growth_stage,
    yield_per_hectare, notes, season, created_at, updated_at
FROM field_crop_assignments
WHERE field_id = $1 AND actual_harvest_date IS NULL
ORDER BY planting_date DESC
LIMIT 1;

-- name: DeleteCropAssignmentsByField :exec
DELETE FROM field_crop_assignments WHERE field_id = $1;

-- -----------------------------------------------------------------------------
-- Field Segments
-- -----------------------------------------------------------------------------

-- name: CreateFieldSegment :one
INSERT INTO field_segments (
    id, field_id, name, boundary, area_hectares,
    soil_type, current_crop_id, notes, segment_index, created_at, updated_at
) VALUES (
    $1, $2, $3, ST_GeomFromGeoJSON($4), $5,
    $6, $7, $8, $9, NOW(), NOW()
)
RETURNING id, field_id, name,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    area_hectares, soil_type, current_crop_id, notes, segment_index,
    created_at, updated_at;

-- name: ListFieldSegments :many
SELECT
    id, field_id, name,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    area_hectares, soil_type, current_crop_id, notes, segment_index,
    created_at, updated_at
FROM field_segments
WHERE field_id = $1
ORDER BY segment_index ASC;

-- name: DeleteFieldSegments :exec
DELETE FROM field_segments WHERE field_id = $1;

-- name: GetFieldSegmentByID :one
SELECT
    id, field_id, name,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    area_hectares, soil_type, current_crop_id, notes, segment_index,
    created_at, updated_at
FROM field_segments
WHERE id = $1;

-- -----------------------------------------------------------------------------
-- Spatial queries
-- -----------------------------------------------------------------------------

-- name: FindFieldsContainingPoint :many
SELECT
    id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version
FROM fields
WHERE tenant_id = $1
    AND deleted_at IS NULL
    AND ST_Contains(boundary, ST_SetSRID(ST_MakePoint($2, $3), 4326));

-- name: FindFieldsInBoundingBox :many
SELECT
    id, tenant_id, farm_id, name, area_hectares,
    ST_AsGeoJSON(boundary)::text AS boundary_geojson,
    current_crop_id, planting_date, expected_harvest_date,
    growth_stage, soil_type, irrigation_type, field_type, status,
    elevation_meters, slope_degrees, aspect_direction,
    created_by, updated_by, created_at, updated_at, version
FROM fields
WHERE tenant_id = $1
    AND deleted_at IS NULL
    AND boundary && ST_MakeEnvelope($2, $3, $4, $5, 4326);

-- name: GetFieldArea :one
SELECT COALESCE(ST_Area(boundary::geography), 0) AS area_sq_meters
FROM fields
WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL;
