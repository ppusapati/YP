package postgres

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
	"p9e.in/samavaya/agriculture/field-service/internal/ports/outbound"
)

type fieldRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

func NewFieldRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.FieldRepository {
	return &fieldRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "FieldPostgresRepository")),
	}
}

func (r *fieldRepository) WithTx(tx pgx.Tx) outbound.FieldRepository {
	return &fieldRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *fieldRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *fieldRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *fieldRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------------------------------------------------------------------------
// fields CRUD
// ---------------------------------------------------------------------------

const fieldColumns = `id, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage,
current_crop_id, planting_date, expected_harvest_date,
created_by, updated_by, created_at, updated_at, version`

func (r *fieldRepository) CreateField(ctx context.Context, field *domain.Field) (*domain.Field, error) {
	field.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO fields (id, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage, created_by)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
RETURNING `+fieldColumns,
		field.UUID, field.TenantID, field.FarmID, field.Name, field.AreaHectares,
		string(field.FieldType), string(field.SoilType), string(field.IrrigationType),
		string(field.Status), field.ElevationMeters, field.SlopeDegrees,
		string(field.AspectDirection), string(field.GrowthStage), field.CreatedBy,
	)
	return scanField(row)
}

func (r *fieldRepository) GetFieldByUUID(ctx context.Context, uuid, tenantID string) (*domain.Field, error) {
	row := r.queryRow(ctx,
		`SELECT `+fieldColumns+` FROM fields WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	f, err := scanField(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", uuid))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return f, nil
}

func (r *fieldRepository) ListFields(ctx context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error) {
	pageSize := params.PageSize
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}

	var totalCount int32
	err := r.queryRow(ctx,
		`SELECT COUNT(*)::int FROM fields
		 WHERE tenant_id = $1 AND deleted_at IS NULL
		   AND ($2::varchar IS NULL OR farm_id = $2)
		   AND ($3::varchar IS NULL OR status = $3)
		   AND ($4::varchar IS NULL OR field_type = $4)
		   AND ($5::varchar IS NULL OR name ILIKE '%' || $5 || '%')`,
		params.TenantID, params.FarmID, params.Status, params.FieldType, params.Search,
	).Scan(&totalCount)
	if err != nil {
		return nil, 0, errors.InternalServer("FIELD_LIST_COUNT_FAILED", fmt.Sprintf("failed to count fields: %v", err))
	}

	rows, err := r.query(ctx,
		`SELECT `+fieldColumns+`
		 FROM fields
		 WHERE tenant_id = $1 AND deleted_at IS NULL
		   AND ($2::varchar IS NULL OR farm_id = $2)
		   AND ($3::varchar IS NULL OR status = $3)
		   AND ($4::varchar IS NULL OR field_type = $4)
		   AND ($5::varchar IS NULL OR name ILIKE '%' || $5 || '%')
		 ORDER BY created_at DESC
		 LIMIT $6 OFFSET $7`,
		params.TenantID, params.FarmID, params.Status, params.FieldType, params.Search,
		pageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("FIELD_LIST_FAILED", fmt.Sprintf("failed to list fields: %v", err))
	}
	defer rows.Close()

	var fields []domain.Field
	for rows.Next() {
		f, err := scanField(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("FIELD_SCAN_FAILED", err.Error())
		}
		fields = append(fields, *f)
	}
	return fields, totalCount, nil
}

func (r *fieldRepository) UpdateField(ctx context.Context, field *domain.Field) (*domain.Field, error) {
	row := r.queryRow(ctx,
		`UPDATE fields SET
			name = COALESCE(NULLIF($1,''), name),
			status = COALESCE(NULLIF($2,''), status),
			current_crop_id = COALESCE($3, current_crop_id),
			planting_date = COALESCE($4, planting_date),
			expected_harvest_date = COALESCE($5, expected_harvest_date),
			growth_stage = COALESCE(NULLIF($6,''), growth_stage),
			updated_by = $7,
			version = version + 1
		WHERE id = $8 AND tenant_id = $9 AND deleted_at IS NULL
		RETURNING `+fieldColumns,
		field.Name, string(field.Status),
		field.CurrentCropID, field.PlantingDate, field.ExpectedHarvestDate,
		string(field.GrowthStage), field.UpdatedBy,
		field.UUID, field.TenantID,
	)
	f, err := scanField(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", field.UUID))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return f, nil
}

func (r *fieldRepository) DeleteField(ctx context.Context, uuid, tenantID, deletedBy string) error {
	return r.exec(ctx,
		`UPDATE fields SET deleted_at=NOW(), updated_by=$1 WHERE id=$2 AND tenant_id=$3 AND deleted_at IS NULL`,
		deletedBy, uuid, tenantID,
	)
}

func (r *fieldRepository) CheckFieldExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM fields WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	return exists, err
}

func (r *fieldRepository) CheckFieldNameExists(ctx context.Context, name, farmID, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM fields WHERE name=$1 AND farm_id=$2 AND tenant_id=$3 AND deleted_at IS NULL)`,
		name, farmID, tenantID,
	).Scan(&exists)
	return exists, err
}

func scanField(row pgx.Row) (*domain.Field, error) {
	f := &domain.Field{}
	err := row.Scan(
		&f.UUID, &f.TenantID, &f.FarmID, &f.Name, &f.AreaHectares,
		&f.FieldType, &f.SoilType, &f.IrrigationType, &f.Status,
		&f.ElevationMeters, &f.SlopeDegrees, &f.AspectDirection, &f.GrowthStage,
		&f.CurrentCropID, &f.PlantingDate, &f.ExpectedHarvestDate,
		&f.CreatedBy, &f.UpdatedBy, &f.CreatedAt, &f.UpdatedAt, &f.Version,
	)
	if err != nil {
		return nil, err
	}
	f.IsActive = true
	return f, err
}

// ---------------------------------------------------------------------------
// field_boundaries
// ---------------------------------------------------------------------------

func (r *fieldRepository) SetFieldBoundary(ctx context.Context, b *domain.FieldBoundary) (*domain.FieldBoundary, error) {
	b.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO field_boundaries (id, tenant_id, field_id, polygon, area_hectares, perimeter_meters, source, recorded_at)
VALUES ($1, $2, $3, $4::jsonb, $5, $6, $7, $8)
RETURNING id, tenant_id, field_id, polygon::text, area_hectares, perimeter_meters, source, recorded_at, created_at`,
		b.ID, b.TenantID, b.FieldID, b.Polygon, b.AreaHectares, b.PerimeterMeters, b.Source, b.RecordedAt,
	)
	out := &domain.FieldBoundary{}
	err := row.Scan(&out.ID, &out.TenantID, &out.FieldID, &out.Polygon,
		&out.AreaHectares, &out.PerimeterMeters, &out.Source, &out.RecordedAt, &out.CreatedAt)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to insert boundary: %v", err))
	}
	return out, nil
}

// ---------------------------------------------------------------------------
// crop_assignments
// ---------------------------------------------------------------------------

func (r *fieldRepository) CreateCropAssignment(ctx context.Context, a *domain.CropAssignment) (*domain.CropAssignment, error) {
	a.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO crop_assignments (id, tenant_id, field_id, crop_id, crop_variety, planting_date,
expected_harvest_date, growth_stage, season, notes)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
RETURNING id, tenant_id, field_id, crop_id, crop_variety, planting_date,
expected_harvest_date, actual_harvest_date, growth_stage, yield_per_hectare,
season, notes, created_at, updated_at`,
		a.ID, a.TenantID, a.FieldID, a.CropID, a.CropVariety,
		a.PlantingDate, a.ExpectedHarvestDate, string(a.GrowthStage),
		a.Season, a.Notes,
	)
	return scanCropAssignment(row)
}

func (r *fieldRepository) GetCropHistory(ctx context.Context, fieldID, tenantID string, pageSize, offset int32) ([]domain.CropAssignment, int32, error) {
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}

	var total int32
	err := r.queryRow(ctx,
		`SELECT COUNT(*)::int FROM crop_assignments WHERE field_id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		fieldID, tenantID,
	).Scan(&total)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to count crop history: %v", err))
	}

	rows, err := r.query(ctx,
		`SELECT id, tenant_id, field_id, crop_id, crop_variety, planting_date,
expected_harvest_date, actual_harvest_date, growth_stage, yield_per_hectare,
season, notes, created_at, updated_at
FROM crop_assignments
WHERE field_id=$1 AND tenant_id=$2 AND deleted_at IS NULL
ORDER BY planting_date DESC NULLS LAST
LIMIT $3 OFFSET $4`,
		fieldID, tenantID, pageSize, offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to list crop history: %v", err))
	}
	defer rows.Close()

	var out []domain.CropAssignment
	for rows.Next() {
		a, err := scanCropAssignment(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		out = append(out, *a)
	}
	return out, total, nil
}

func scanCropAssignment(row pgx.Row) (*domain.CropAssignment, error) {
	a := &domain.CropAssignment{}
	err := row.Scan(
		&a.ID, &a.TenantID, &a.FieldID, &a.CropID, &a.CropVariety,
		&a.PlantingDate, &a.ExpectedHarvestDate, &a.ActualHarvestDate,
		&a.GrowthStage, &a.YieldPerHectare,
		&a.Season, &a.Notes, &a.CreatedAt, &a.UpdatedAt,
	)
	return a, err
}

// ---------------------------------------------------------------------------
// field_segments
// ---------------------------------------------------------------------------

func (r *fieldRepository) CreateFieldSegments(ctx context.Context, fieldID, tenantID string, segments []domain.FieldSegmentInput) ([]domain.FieldSegment, error) {
	out := make([]domain.FieldSegment, 0, len(segments))
	for i, s := range segments {
		id := ulid.NewString()
		row := r.queryRow(ctx,
			`INSERT INTO field_segments (id, tenant_id, field_id, name, boundary, area_hectares, soil_type, notes, segment_index)
VALUES ($1, $2, $3, $4, $5::jsonb, $6, $7, $8, $9)
RETURNING id, tenant_id, field_id, name, COALESCE(boundary::text,''), area_hectares, soil_type,
COALESCE(current_crop_id,''), notes, segment_index, created_at, updated_at`,
			id, tenantID, fieldID, s.Name, nullIfEmpty(s.Boundary), s.AreaHectares,
			string(s.SoilType), s.Notes, int32(i),
		)
		seg := domain.FieldSegment{}
		err := row.Scan(&seg.ID, &seg.TenantID, &seg.FieldID, &seg.Name,
			&seg.Boundary, &seg.AreaHectares, &seg.SoilType,
			&seg.CurrentCropID, &seg.Notes, &seg.SegmentIndex,
			&seg.CreatedAt, &seg.UpdatedAt)
		if err != nil {
			return nil, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to insert segment: %v", err))
		}
		out = append(out, seg)
	}
	return out, nil
}

func (r *fieldRepository) GetFieldSegments(ctx context.Context, fieldID, tenantID string) ([]domain.FieldSegment, error) {
	rows, err := r.query(ctx,
		`SELECT id, tenant_id, field_id, name, COALESCE(boundary::text,''), area_hectares, soil_type,
COALESCE(current_crop_id,''), COALESCE(notes,''), segment_index, created_at, updated_at
FROM field_segments
WHERE field_id=$1 AND tenant_id=$2 AND deleted_at IS NULL
ORDER BY segment_index`,
		fieldID, tenantID,
	)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to get segments: %v", err))
	}
	defer rows.Close()

	var out []domain.FieldSegment
	for rows.Next() {
		seg := domain.FieldSegment{}
		err := rows.Scan(&seg.ID, &seg.TenantID, &seg.FieldID, &seg.Name,
			&seg.Boundary, &seg.AreaHectares, &seg.SoilType,
			&seg.CurrentCropID, &seg.Notes, &seg.SegmentIndex,
			&seg.CreatedAt, &seg.UpdatedAt)
		if err != nil {
			return nil, errors.InternalServer("DB_ERROR", err.Error())
		}
		out = append(out, seg)
	}
	return out, nil
}

func (r *fieldRepository) DeleteFieldSegments(ctx context.Context, fieldID, tenantID string) error {
	return r.exec(ctx,
		`UPDATE field_segments SET deleted_at=NOW() WHERE field_id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		fieldID, tenantID,
	)
}

func nullIfEmpty(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
