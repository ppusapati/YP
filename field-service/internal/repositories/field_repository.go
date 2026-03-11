package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/agriculture/field-service/internal/models"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// FieldRepository defines the contract for field persistence operations.
type FieldRepository interface {
	CreateField(ctx context.Context, tenantID, userID string, input models.CreateFieldInput) (*models.Field, error)
	GetFieldByID(ctx context.Context, tenantID, fieldID string) (*models.Field, error)
	ListFields(ctx context.Context, tenantID string, input models.ListFieldsInput) ([]models.Field, int64, error)
	UpdateField(ctx context.Context, tenantID, userID string, input models.UpdateFieldInput) (*models.Field, error)
	DeleteField(ctx context.Context, tenantID, userID, fieldID string) error
	FieldExists(ctx context.Context, tenantID, fieldID string) (bool, error)
	FieldNameExists(ctx context.Context, tenantID, farmID, name string) (bool, error)

	ListFieldsByFarm(ctx context.Context, tenantID, farmID string, pageSize, pageOffset int32) ([]models.Field, int64, error)

	SetFieldBoundary(ctx context.Context, tenantID, userID string, input models.SetBoundaryInput) (*models.FieldBoundary, error)
	GetLatestFieldBoundary(ctx context.Context, fieldID string) (*models.FieldBoundary, error)

	AssignCrop(ctx context.Context, tenantID, userID string, input models.AssignCropInput) (*models.FieldCropAssignment, error)
	ListCropAssignments(ctx context.Context, fieldID string, pageSize, pageOffset int32) ([]models.FieldCropAssignment, int64, error)

	CreateFieldSegments(ctx context.Context, fieldID string, inputs []models.SegmentFieldInput) ([]models.FieldSegment, error)
	ListFieldSegments(ctx context.Context, fieldID string) ([]models.FieldSegment, error)
	DeleteFieldSegments(ctx context.Context, fieldID string) error
}

// pgxFieldRepository is the PostgreSQL implementation of FieldRepository.
type pgxFieldRepository struct {
	pool   *pgxpool.Pool
	logger *p9log.Helper
}

// NewFieldRepository creates a new PostgreSQL-backed field repository.
func NewFieldRepository(pool *pgxpool.Pool, logger p9log.Logger) FieldRepository {
	return &pgxFieldRepository{
		pool:   pool,
		logger: p9log.NewHelper(p9log.With(logger, "component", "field_repository")),
	}
}

// ---------------------------------------------------------------------------
// Field CRUD
// ---------------------------------------------------------------------------

func (r *pgxFieldRepository) CreateField(ctx context.Context, tenantID, userID string, input models.CreateFieldInput) (*models.Field, error) {
	id := ulid.NewString()

	var boundaryGeoJSON *string
	if input.BoundaryGeoJSON != nil {
		boundaryGeoJSON = input.BoundaryGeoJSON
	}

	query := `
		INSERT INTO fields (
			id, tenant_id, farm_id, name, area_hectares, boundary,
			growth_stage, soil_type, irrigation_type, field_type, status,
			elevation_meters, slope_degrees, aspect_direction,
			created_by, updated_by, created_at, updated_at, version
		) VALUES (
			$1, $2, $3, $4, $5, ST_GeomFromGeoJSON(NULLIF($6, '')),
			$7, $8, $9, $10, $11,
			$12, $13, $14,
			$15, $16, NOW(), NOW(), 1
		)
		RETURNING id, tenant_id, farm_id, name, area_hectares,
			ST_AsGeoJSON(boundary)::text AS boundary_geojson,
			current_crop_id, planting_date, expected_harvest_date,
			growth_stage, soil_type, irrigation_type, field_type, status,
			elevation_meters, slope_degrees, aspect_direction,
			created_by, updated_by, created_at, updated_at, version`

	bStr := ""
	if boundaryGeoJSON != nil {
		bStr = *boundaryGeoJSON
	}

	row := r.pool.QueryRow(ctx, query,
		id, tenantID, input.FarmID, input.Name, input.AreaHectares, bStr,
		string(models.GrowthStageUnspecified),
		string(input.SoilType), string(input.IrrigationType),
		string(input.FieldType), string(models.FieldStatusActive),
		input.ElevationMeters, input.SlopeDegrees, string(input.AspectDirection),
		userID, userID,
	)

	field, err := scanField(row)
	if err != nil {
		r.logger.Errorf("CreateField failed: %v", err)
		return nil, errors.InternalServer("FIELD_CREATE_FAILED", fmt.Sprintf("failed to create field: %v", err))
	}
	return field, nil
}

func (r *pgxFieldRepository) GetFieldByID(ctx context.Context, tenantID, fieldID string) (*models.Field, error) {
	query := `
		SELECT id, tenant_id, farm_id, name, area_hectares,
			ST_AsGeoJSON(boundary)::text AS boundary_geojson,
			current_crop_id, planting_date, expected_harvest_date,
			growth_stage, soil_type, irrigation_type, field_type, status,
			elevation_meters, slope_degrees, aspect_direction,
			created_by, updated_by, created_at, updated_at, version
		FROM fields
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, fieldID, tenantID)

	field, err := scanField(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", fieldID))
		}
		r.logger.Errorf("GetFieldByID failed: %v", err)
		return nil, errors.InternalServer("FIELD_GET_FAILED", fmt.Sprintf("failed to get field: %v", err))
	}
	return field, nil
}

func (r *pgxFieldRepository) ListFields(ctx context.Context, tenantID string, input models.ListFieldsInput) ([]models.Field, int64, error) {
	if input.PageSize <= 0 {
		input.PageSize = 20
	}
	if input.PageSize > 100 {
		input.PageSize = 100
	}

	countQuery := `
		SELECT COUNT(*) FROM fields
		WHERE tenant_id = $1 AND deleted_at IS NULL
			AND ($2::varchar IS NULL OR farm_id = $2)
			AND ($3::varchar IS NULL OR status = $3)
			AND ($4::varchar IS NULL OR field_type = $4)
			AND ($5::varchar IS NULL OR name ILIKE '%' || $5 || '%')`

	var totalCount int64
	err := r.pool.QueryRow(ctx, countQuery,
		tenantID, input.FarmID, input.Status, input.FieldType, input.Search,
	).Scan(&totalCount)
	if err != nil {
		r.logger.Errorf("ListFields count failed: %v", err)
		return nil, 0, errors.InternalServer("FIELD_LIST_COUNT_FAILED", fmt.Sprintf("failed to count fields: %v", err))
	}

	listQuery := `
		SELECT id, tenant_id, farm_id, name, area_hectares,
			ST_AsGeoJSON(boundary)::text AS boundary_geojson,
			current_crop_id, planting_date, expected_harvest_date,
			growth_stage, soil_type, irrigation_type, field_type, status,
			elevation_meters, slope_degrees, aspect_direction,
			created_by, updated_by, created_at, updated_at, version
		FROM fields
		WHERE tenant_id = $1 AND deleted_at IS NULL
			AND ($2::varchar IS NULL OR farm_id = $2)
			AND ($3::varchar IS NULL OR status = $3)
			AND ($4::varchar IS NULL OR field_type = $4)
			AND ($5::varchar IS NULL OR name ILIKE '%' || $5 || '%')
		ORDER BY created_at DESC
		LIMIT $6 OFFSET $7`

	rows, err := r.pool.Query(ctx, listQuery,
		tenantID, input.FarmID, input.Status, input.FieldType, input.Search,
		input.PageSize, input.PageOffset,
	)
	if err != nil {
		r.logger.Errorf("ListFields query failed: %v", err)
		return nil, 0, errors.InternalServer("FIELD_LIST_FAILED", fmt.Sprintf("failed to list fields: %v", err))
	}
	defer rows.Close()

	fields, err := scanFields(rows)
	if err != nil {
		return nil, 0, errors.InternalServer("FIELD_LIST_SCAN_FAILED", fmt.Sprintf("failed to scan fields: %v", err))
	}

	return fields, totalCount, nil
}

func (r *pgxFieldRepository) UpdateField(ctx context.Context, tenantID, userID string, input models.UpdateFieldInput) (*models.Field, error) {
	query := `
		UPDATE fields SET
			name             = COALESCE($3, name),
			area_hectares    = COALESCE($4, area_hectares),
			field_type       = COALESCE($5, field_type),
			soil_type        = COALESCE($6, soil_type),
			irrigation_type  = COALESCE($7, irrigation_type),
			status           = COALESCE($8, status),
			elevation_meters = COALESCE($9, elevation_meters),
			slope_degrees    = COALESCE($10, slope_degrees),
			aspect_direction = COALESCE($11, aspect_direction),
			growth_stage     = COALESCE($12, growth_stage),
			updated_by       = $13,
			updated_at       = NOW(),
			version          = version + 1
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, tenant_id, farm_id, name, area_hectares,
			ST_AsGeoJSON(boundary)::text AS boundary_geojson,
			current_crop_id, planting_date, expected_harvest_date,
			growth_stage, soil_type, irrigation_type, field_type, status,
			elevation_meters, slope_degrees, aspect_direction,
			created_by, updated_by, created_at, updated_at, version`

	var nameArg, ftArg, stArg, itArg, statusArg, adArg, gsArg *string
	var ahArg, emArg, sdArg *float64

	if input.Name != nil {
		nameArg = input.Name
	}
	if input.AreaHectares != nil {
		ahArg = input.AreaHectares
	}
	if input.FieldType != nil {
		s := string(*input.FieldType)
		ftArg = &s
	}
	if input.SoilType != nil {
		s := string(*input.SoilType)
		stArg = &s
	}
	if input.IrrigationType != nil {
		s := string(*input.IrrigationType)
		itArg = &s
	}
	if input.Status != nil {
		s := string(*input.Status)
		statusArg = &s
	}
	if input.ElevationMeters != nil {
		emArg = input.ElevationMeters
	}
	if input.SlopeDegrees != nil {
		sdArg = input.SlopeDegrees
	}
	if input.AspectDirection != nil {
		s := string(*input.AspectDirection)
		adArg = &s
	}
	if input.GrowthStage != nil {
		s := string(*input.GrowthStage)
		gsArg = &s
	}

	row := r.pool.QueryRow(ctx, query,
		input.ID, tenantID,
		nameArg, ahArg, ftArg, stArg, itArg, statusArg,
		emArg, sdArg, adArg, gsArg,
		userID,
	)

	field, err := scanField(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", input.ID))
		}
		r.logger.Errorf("UpdateField failed: %v", err)
		return nil, errors.InternalServer("FIELD_UPDATE_FAILED", fmt.Sprintf("failed to update field: %v", err))
	}
	return field, nil
}

func (r *pgxFieldRepository) DeleteField(ctx context.Context, tenantID, userID, fieldID string) error {
	query := `
		UPDATE fields
		SET deleted_at = NOW(), updated_by = $3, updated_at = NOW(), version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	tag, err := r.pool.Exec(ctx, query, fieldID, tenantID, userID)
	if err != nil {
		r.logger.Errorf("DeleteField failed: %v", err)
		return errors.InternalServer("FIELD_DELETE_FAILED", fmt.Sprintf("failed to delete field: %v", err))
	}
	if tag.RowsAffected() == 0 {
		return errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field %s not found", fieldID))
	}
	return nil
}

func (r *pgxFieldRepository) FieldExists(ctx context.Context, tenantID, fieldID string) (bool, error) {
	var exists bool
	err := r.pool.QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM fields WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL)`,
		fieldID, tenantID,
	).Scan(&exists)
	if err != nil {
		return false, errors.InternalServer("FIELD_EXISTS_FAILED", fmt.Sprintf("failed to check field existence: %v", err))
	}
	return exists, nil
}

func (r *pgxFieldRepository) FieldNameExists(ctx context.Context, tenantID, farmID, name string) (bool, error) {
	var exists bool
	err := r.pool.QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM fields WHERE tenant_id = $1 AND farm_id = $2 AND name = $3 AND deleted_at IS NULL)`,
		tenantID, farmID, name,
	).Scan(&exists)
	if err != nil {
		return false, errors.InternalServer("FIELD_NAME_EXISTS_FAILED", fmt.Sprintf("failed to check field name existence: %v", err))
	}
	return exists, nil
}

func (r *pgxFieldRepository) ListFieldsByFarm(ctx context.Context, tenantID, farmID string, pageSize, pageOffset int32) ([]models.Field, int64, error) {
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}

	var totalCount int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM fields WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL`,
		tenantID, farmID,
	).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.InternalServer("FIELD_LIST_BY_FARM_COUNT_FAILED", err.Error())
	}

	query := `
		SELECT id, tenant_id, farm_id, name, area_hectares,
			ST_AsGeoJSON(boundary)::text AS boundary_geojson,
			current_crop_id, planting_date, expected_harvest_date,
			growth_stage, soil_type, irrigation_type, field_type, status,
			elevation_meters, slope_degrees, aspect_direction,
			created_by, updated_by, created_at, updated_at, version
		FROM fields
		WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL
		ORDER BY name ASC
		LIMIT $3 OFFSET $4`

	rows, err := r.pool.Query(ctx, query, tenantID, farmID, pageSize, pageOffset)
	if err != nil {
		return nil, 0, errors.InternalServer("FIELD_LIST_BY_FARM_FAILED", err.Error())
	}
	defer rows.Close()

	fields, err := scanFields(rows)
	if err != nil {
		return nil, 0, errors.InternalServer("FIELD_LIST_BY_FARM_SCAN_FAILED", err.Error())
	}

	return fields, totalCount, nil
}

// ---------------------------------------------------------------------------
// Boundaries
// ---------------------------------------------------------------------------

func (r *pgxFieldRepository) SetFieldBoundary(ctx context.Context, tenantID, userID string, input models.SetBoundaryInput) (*models.FieldBoundary, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, errors.InternalServer("TX_BEGIN_FAILED", err.Error())
	}
	defer tx.Rollback(ctx)

	// Update the field's boundary and area_hectares.
	_, err = tx.Exec(ctx, `
		UPDATE fields SET
			boundary     = ST_GeomFromGeoJSON($3),
			area_hectares = $4,
			updated_by   = $5,
			updated_at   = NOW(),
			version      = version + 1
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		input.FieldID, tenantID, input.PolygonGeoJSON, input.AreaHectares, userID,
	)
	if err != nil {
		return nil, errors.InternalServer("FIELD_BOUNDARY_UPDATE_FAILED", err.Error())
	}

	// Insert a new boundary record.
	boundaryID := ulid.NewString()
	row := tx.QueryRow(ctx, `
		INSERT INTO field_boundaries (
			id, field_id, polygon, area_hectares, perimeter_meters, source, recorded_at, created_at
		) VALUES (
			$1, $2, ST_GeomFromGeoJSON($3), $4, $5, $6, NOW(), NOW()
		)
		RETURNING id, field_id,
			ST_AsGeoJSON(polygon)::text AS polygon_geojson,
			area_hectares, perimeter_meters, source, recorded_at, created_at`,
		boundaryID, input.FieldID, input.PolygonGeoJSON,
		input.AreaHectares, input.PerimeterMeters, input.Source,
	)

	boundary, err := scanFieldBoundary(row)
	if err != nil {
		return nil, errors.InternalServer("FIELD_BOUNDARY_INSERT_FAILED", err.Error())
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, errors.InternalServer("TX_COMMIT_FAILED", err.Error())
	}

	return boundary, nil
}

func (r *pgxFieldRepository) GetLatestFieldBoundary(ctx context.Context, fieldID string) (*models.FieldBoundary, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT id, field_id,
			ST_AsGeoJSON(polygon)::text AS polygon_geojson,
			area_hectares, perimeter_meters, source, recorded_at, created_at
		FROM field_boundaries
		WHERE field_id = $1
		ORDER BY recorded_at DESC
		LIMIT 1`,
		fieldID,
	)

	boundary, err := scanFieldBoundary(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errors.InternalServer("FIELD_BOUNDARY_GET_FAILED", err.Error())
	}
	return boundary, nil
}

// ---------------------------------------------------------------------------
// Crop Assignments
// ---------------------------------------------------------------------------

func (r *pgxFieldRepository) AssignCrop(ctx context.Context, tenantID, userID string, input models.AssignCropInput) (*models.FieldCropAssignment, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, errors.InternalServer("TX_BEGIN_FAILED", err.Error())
	}
	defer tx.Rollback(ctx)

	assignmentID := ulid.NewString()

	row := tx.QueryRow(ctx, `
		INSERT INTO field_crop_assignments (
			id, field_id, crop_id, crop_variety, planting_date,
			expected_harvest_date, growth_stage, notes, season, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW()
		)
		RETURNING id, field_id, crop_id, crop_variety, planting_date,
			expected_harvest_date, actual_harvest_date, growth_stage,
			yield_per_hectare, notes, season, created_at, updated_at`,
		assignmentID, input.FieldID, input.CropID, input.CropVariety,
		input.PlantingDate, input.ExpectedHarvestDate,
		string(models.GrowthStageGermination), input.Notes, input.Season,
	)

	assignment, err := scanCropAssignment(row)
	if err != nil {
		return nil, errors.InternalServer("CROP_ASSIGNMENT_CREATE_FAILED", err.Error())
	}

	// Update the field's current crop.
	_, err = tx.Exec(ctx, `
		UPDATE fields SET
			current_crop_id       = $3,
			planting_date         = $4,
			expected_harvest_date = $5,
			growth_stage          = $6,
			updated_by            = $7,
			updated_at            = NOW(),
			version               = version + 1
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		input.FieldID, tenantID, input.CropID,
		input.PlantingDate, input.ExpectedHarvestDate,
		string(models.GrowthStageGermination), userID,
	)
	if err != nil {
		return nil, errors.InternalServer("FIELD_CROP_UPDATE_FAILED", err.Error())
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, errors.InternalServer("TX_COMMIT_FAILED", err.Error())
	}

	return assignment, nil
}

func (r *pgxFieldRepository) ListCropAssignments(ctx context.Context, fieldID string, pageSize, pageOffset int32) ([]models.FieldCropAssignment, int64, error) {
	if pageSize <= 0 {
		pageSize = 20
	}

	var totalCount int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM field_crop_assignments WHERE field_id = $1`, fieldID,
	).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.InternalServer("CROP_ASSIGNMENT_COUNT_FAILED", err.Error())
	}

	rows, err := r.pool.Query(ctx, `
		SELECT id, field_id, crop_id, crop_variety, planting_date,
			expected_harvest_date, actual_harvest_date, growth_stage,
			yield_per_hectare, notes, season, created_at, updated_at
		FROM field_crop_assignments
		WHERE field_id = $1
		ORDER BY planting_date DESC
		LIMIT $2 OFFSET $3`,
		fieldID, pageSize, pageOffset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("CROP_ASSIGNMENT_LIST_FAILED", err.Error())
	}
	defer rows.Close()

	var assignments []models.FieldCropAssignment
	for rows.Next() {
		a, err := scanCropAssignmentFromRows(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("CROP_ASSIGNMENT_SCAN_FAILED", err.Error())
		}
		assignments = append(assignments, *a)
	}
	if assignments == nil {
		assignments = []models.FieldCropAssignment{}
	}

	return assignments, totalCount, nil
}

// ---------------------------------------------------------------------------
// Segments
// ---------------------------------------------------------------------------

func (r *pgxFieldRepository) CreateFieldSegments(ctx context.Context, fieldID string, inputs []models.SegmentFieldInput) ([]models.FieldSegment, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, errors.InternalServer("TX_BEGIN_FAILED", err.Error())
	}
	defer tx.Rollback(ctx)

	// Delete existing segments first (replace strategy).
	_, err = tx.Exec(ctx, `DELETE FROM field_segments WHERE field_id = $1`, fieldID)
	if err != nil {
		return nil, errors.InternalServer("SEGMENT_DELETE_FAILED", err.Error())
	}

	segments := make([]models.FieldSegment, 0, len(inputs))
	for idx, in := range inputs {
		segID := ulid.NewString()

		bStr := ""
		if in.BoundaryGeoJSON != nil {
			bStr = *in.BoundaryGeoJSON
		}

		row := tx.QueryRow(ctx, `
			INSERT INTO field_segments (
				id, field_id, name, boundary, area_hectares,
				soil_type, notes, segment_index, created_at, updated_at
			) VALUES (
				$1, $2, $3, ST_GeomFromGeoJSON(NULLIF($4, '')), $5,
				$6, $7, $8, NOW(), NOW()
			)
			RETURNING id, field_id, name,
				ST_AsGeoJSON(boundary)::text AS boundary_geojson,
				area_hectares, soil_type, current_crop_id, notes, segment_index,
				created_at, updated_at`,
			segID, fieldID, in.Name, bStr, in.AreaHectares,
			string(in.SoilType), in.Notes, int32(idx),
		)

		seg, err := scanFieldSegment(row)
		if err != nil {
			return nil, errors.InternalServer("SEGMENT_CREATE_FAILED", fmt.Sprintf("failed to create segment %d: %v", idx, err))
		}
		segments = append(segments, *seg)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, errors.InternalServer("TX_COMMIT_FAILED", err.Error())
	}

	return segments, nil
}

func (r *pgxFieldRepository) ListFieldSegments(ctx context.Context, fieldID string) ([]models.FieldSegment, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT id, field_id, name,
			ST_AsGeoJSON(boundary)::text AS boundary_geojson,
			area_hectares, soil_type, current_crop_id, notes, segment_index,
			created_at, updated_at
		FROM field_segments
		WHERE field_id = $1
		ORDER BY segment_index ASC`,
		fieldID,
	)
	if err != nil {
		return nil, errors.InternalServer("SEGMENT_LIST_FAILED", err.Error())
	}
	defer rows.Close()

	var segments []models.FieldSegment
	for rows.Next() {
		seg, err := scanFieldSegmentFromRows(rows)
		if err != nil {
			return nil, errors.InternalServer("SEGMENT_SCAN_FAILED", err.Error())
		}
		segments = append(segments, *seg)
	}
	if segments == nil {
		segments = []models.FieldSegment{}
	}

	return segments, nil
}

func (r *pgxFieldRepository) DeleteFieldSegments(ctx context.Context, fieldID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM field_segments WHERE field_id = $1`, fieldID)
	if err != nil {
		return errors.InternalServer("SEGMENT_DELETE_FAILED", err.Error())
	}
	return nil
}

// ---------------------------------------------------------------------------
// Row scanners
// ---------------------------------------------------------------------------

func scanField(row pgx.Row) (*models.Field, error) {
	var f models.Field
	var growthStage, soilType, irrigationType, fieldType, status, aspectDirection string

	err := row.Scan(
		&f.ID, &f.TenantID, &f.FarmID, &f.Name, &f.AreaHectares,
		&f.BoundaryGeoJSON,
		&f.CurrentCropID, &f.PlantingDate, &f.ExpectedHarvestDate,
		&growthStage, &soilType, &irrigationType, &fieldType, &status,
		&f.ElevationMeters, &f.SlopeDegrees, &aspectDirection,
		&f.CreatedBy, &f.UpdatedBy, &f.CreatedAt, &f.UpdatedAt, &f.Version,
	)
	if err != nil {
		return nil, err
	}

	f.GrowthStage = models.GrowthStage(growthStage)
	f.SoilType = models.SoilType(soilType)
	f.IrrigationType = models.IrrigationType(irrigationType)
	f.FieldType = models.FieldType(fieldType)
	f.Status = models.FieldStatus(status)
	f.AspectDirection = models.AspectDirection(aspectDirection)

	return &f, nil
}

func scanFields(rows pgx.Rows) ([]models.Field, error) {
	var fields []models.Field
	for rows.Next() {
		var f models.Field
		var growthStage, soilType, irrigationType, fieldType, status, aspectDirection string

		err := rows.Scan(
			&f.ID, &f.TenantID, &f.FarmID, &f.Name, &f.AreaHectares,
			&f.BoundaryGeoJSON,
			&f.CurrentCropID, &f.PlantingDate, &f.ExpectedHarvestDate,
			&growthStage, &soilType, &irrigationType, &fieldType, &status,
			&f.ElevationMeters, &f.SlopeDegrees, &aspectDirection,
			&f.CreatedBy, &f.UpdatedBy, &f.CreatedAt, &f.UpdatedAt, &f.Version,
		)
		if err != nil {
			return nil, err
		}

		f.GrowthStage = models.GrowthStage(growthStage)
		f.SoilType = models.SoilType(soilType)
		f.IrrigationType = models.IrrigationType(irrigationType)
		f.FieldType = models.FieldType(fieldType)
		f.Status = models.FieldStatus(status)
		f.AspectDirection = models.AspectDirection(aspectDirection)

		fields = append(fields, f)
	}
	if fields == nil {
		fields = []models.Field{}
	}
	return fields, rows.Err()
}

func scanFieldBoundary(row pgx.Row) (*models.FieldBoundary, error) {
	var b models.FieldBoundary
	err := row.Scan(
		&b.ID, &b.FieldID, &b.PolygonGeoJSON,
		&b.AreaHectares, &b.PerimeterMeters, &b.Source,
		&b.RecordedAt, &b.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &b, nil
}

func scanCropAssignment(row pgx.Row) (*models.FieldCropAssignment, error) {
	var a models.FieldCropAssignment
	var growthStage string
	err := row.Scan(
		&a.ID, &a.FieldID, &a.CropID, &a.CropVariety,
		&a.PlantingDate, &a.ExpectedHarvestDate, &a.ActualHarvestDate,
		&growthStage, &a.YieldPerHectare, &a.Notes, &a.Season,
		&a.CreatedAt, &a.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	a.GrowthStage = models.GrowthStage(growthStage)
	return &a, nil
}

func scanCropAssignmentFromRows(rows pgx.Rows) (*models.FieldCropAssignment, error) {
	var a models.FieldCropAssignment
	var growthStage string
	err := rows.Scan(
		&a.ID, &a.FieldID, &a.CropID, &a.CropVariety,
		&a.PlantingDate, &a.ExpectedHarvestDate, &a.ActualHarvestDate,
		&growthStage, &a.YieldPerHectare, &a.Notes, &a.Season,
		&a.CreatedAt, &a.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	a.GrowthStage = models.GrowthStage(growthStage)
	return &a, nil
}

func scanFieldSegment(row pgx.Row) (*models.FieldSegment, error) {
	var s models.FieldSegment
	var soilType string
	err := row.Scan(
		&s.ID, &s.FieldID, &s.Name, &s.BoundaryGeoJSON,
		&s.AreaHectares, &soilType, &s.CurrentCropID, &s.Notes,
		&s.SegmentIndex, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	s.SoilType = models.SoilType(soilType)
	return &s, nil
}

func scanFieldSegmentFromRows(rows pgx.Rows) (*models.FieldSegment, error) {
	var s models.FieldSegment
	var soilType string
	err := rows.Scan(
		&s.ID, &s.FieldID, &s.Name, &s.BoundaryGeoJSON,
		&s.AreaHectares, &soilType, &s.CurrentCropID, &s.Notes,
		&s.SegmentIndex, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	s.SoilType = models.SoilType(soilType)
	return &s, nil
}

// ensure unused import is consumed
var _ = time.Now
