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
	field.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO fields (id, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage, created_by)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
RETURNING `+fieldColumns,
		field.ID, field.TenantID, field.FarmID, field.Name, field.AreaHectares,
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
		field.ID, field.TenantID,
	)
	f, err := scanField(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", field.ID))
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
		&f.ID, &f.TenantID, &f.FarmID, &f.Name, &f.AreaHectares,
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
ON CONFLICT (tenant_id, field_id) WHERE deleted_at IS NULL
DO UPDATE SET polygon = EXCLUDED.polygon,
              area_hectares = EXCLUDED.area_hectares,
              perimeter_meters = EXCLUDED.perimeter_meters,
              source = EXCLUDED.source,
              recorded_at = EXCLUDED.recorded_at
RETURNING id, tenant_id, field_id, polygon::text, area_hectares, perimeter_meters, source, recorded_at, created_at`,
		b.ID, b.TenantID, b.FieldID, b.Polygon, b.AreaHectares, b.PerimeterMeters, b.Source, b.RecordedAt,
	)
	out := &domain.FieldBoundary{}
	err := row.Scan(&out.ID, &out.TenantID, &out.FieldID, &out.Polygon,
		&out.AreaHectares, &out.PerimeterMeters, &out.Source, &out.RecordedAt, &out.CreatedAt)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to upsert boundary: %v", err))
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

// ---------------------------------------------------------------------------
// crop_cycles
// ---------------------------------------------------------------------------

const cropCycleColumns = `id, tenant_id, field_id, crop_id, crop_assignment_id, management_unit_id,
season, cycle_year, name,
planned_planting_date, actual_planting_date, planned_harvest_date, actual_harvest_date,
status, target_yield_per_hectare, actual_yield_per_hectare, yield_unit,
total_input_cost, total_revenue, currency,
crop_variety, seed_source, notes,
version, created_by, updated_by, created_at, updated_at, deleted_at`

func (r *fieldRepository) CreateCropCycle(ctx context.Context, c *domain.CropCycle) (*domain.CropCycle, error) {
	c.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO crop_cycles (id, tenant_id, field_id, crop_id, crop_assignment_id, management_unit_id,
season, cycle_year, name, planned_planting_date, planned_harvest_date,
status, target_yield_per_hectare, yield_unit, crop_variety, seed_source, notes, created_by)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
RETURNING `+cropCycleColumns,
		c.ID, c.TenantID, c.FieldID, c.CropID, c.CropAssignmentID, c.ManagementUnitID,
		c.Season, c.CycleYear, c.Name,
		c.PlannedPlantingDate, c.PlannedHarvestDate,
		string(c.Status), c.TargetYieldPerHectare, c.YieldUnit,
		c.CropVariety, c.SeedSource, c.Notes, c.CreatedBy,
	)
	return scanCropCycle(row)
}

func (r *fieldRepository) GetCropCycleByID(ctx context.Context, id, tenantID string) (*domain.CropCycle, error) {
	row := r.queryRow(ctx,
		`SELECT `+cropCycleColumns+` FROM crop_cycles WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		id, tenantID,
	)
	cc, err := scanCropCycle(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CYCLE_NOT_FOUND", fmt.Sprintf("crop cycle not found: %s", id))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return cc, nil
}

func (r *fieldRepository) ListCropCycles(ctx context.Context, params domain.ListCropCyclesParams) ([]domain.CropCycle, int32, error) {
	var total int32
	err := r.queryRow(ctx,
		`SELECT COUNT(*)::int FROM crop_cycles
		 WHERE tenant_id=$1 AND deleted_at IS NULL
		   AND ($2::varchar IS NULL OR field_id=$2)
		   AND ($3::varchar IS NULL OR status=$3)
		   AND ($4::varchar IS NULL OR management_unit_id=$4)`,
		params.TenantID, nilIfEmptyStr(ptrOrNil(params.FieldID)), nilIfEmptyCycleStatus(params.Status),
		nilIfEmptyStr(params.ManagementUnitID),
	).Scan(&total)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to count crop cycles: %v", err))
	}

	rows, err := r.query(ctx,
		`SELECT `+cropCycleColumns+` FROM crop_cycles
		 WHERE tenant_id=$1 AND deleted_at IS NULL
		   AND ($2::varchar IS NULL OR field_id=$2)
		   AND ($3::varchar IS NULL OR status=$3)
		   AND ($4::varchar IS NULL OR management_unit_id=$4)
		 ORDER BY cycle_year DESC, created_at DESC
		 LIMIT $5 OFFSET $6`,
		params.TenantID, nilIfEmptyStr(ptrOrNil(params.FieldID)), nilIfEmptyCycleStatus(params.Status),
		nilIfEmptyStr(params.ManagementUnitID),
		params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to list crop cycles: %v", err))
	}
	defer rows.Close()

	var out []domain.CropCycle
	for rows.Next() {
		cc, err := scanCropCycle(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		out = append(out, *cc)
	}
	return out, total, nil
}

func (r *fieldRepository) UpdateCropCycle(ctx context.Context, c *domain.CropCycle) (*domain.CropCycle, error) {
	row := r.queryRow(ctx,
		`UPDATE crop_cycles SET
			status = COALESCE(NULLIF($3,''), status),
			actual_planting_date = COALESCE($4, actual_planting_date),
			actual_harvest_date = COALESCE($5, actual_harvest_date),
			actual_yield_per_hectare = COALESCE($6, actual_yield_per_hectare),
			total_input_cost = COALESCE($7, total_input_cost),
			total_revenue = COALESCE($8, total_revenue),
			notes = COALESCE($9, notes),
			updated_by = $10,
			version = version + 1
		WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL
		RETURNING `+cropCycleColumns,
		c.ID, c.TenantID,
		nilIfEmptyCycleStatusVal(c.Status),
		c.ActualPlantingDate, c.ActualHarvestDate,
		c.ActualYieldPerHectare,
		nilIfZeroInt64(c.TotalInputCost), nilIfZeroInt64(c.TotalRevenue),
		c.Notes, c.UpdatedBy,
	)
	cc, err := scanCropCycle(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CYCLE_NOT_FOUND", fmt.Sprintf("crop cycle not found: %s", c.ID))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return cc, nil
}

func scanCropCycle(row pgx.Row) (*domain.CropCycle, error) {
	c := &domain.CropCycle{}
	err := row.Scan(
		&c.ID, &c.TenantID, &c.FieldID, &c.CropID, &c.CropAssignmentID, &c.ManagementUnitID,
		&c.Season, &c.CycleYear, &c.Name,
		&c.PlannedPlantingDate, &c.ActualPlantingDate, &c.PlannedHarvestDate, &c.ActualHarvestDate,
		&c.Status, &c.TargetYieldPerHectare, &c.ActualYieldPerHectare, &c.YieldUnit,
		&c.TotalInputCost, &c.TotalRevenue, &c.Currency,
		&c.CropVariety, &c.SeedSource, &c.Notes,
		&c.Version, &c.CreatedBy, &c.UpdatedBy, &c.CreatedAt, &c.UpdatedAt, &c.DeletedAt,
	)
	return c, err
}

func nilIfEmptyCycleStatus(s *domain.CropCycleStatus) interface{} {
	if s == nil || *s == domain.CropCycleStatusUnspecified {
		return nil
	}
	return string(*s)
}

func nilIfEmptyCycleStatusVal(s domain.CropCycleStatus) interface{} {
	if s == domain.CropCycleStatusUnspecified {
		return nil
	}
	return string(s)
}

func nilIfZeroInt64(v int64) interface{} {
	if v == 0 {
		return nil
	}
	return v
}

// ---------------------------------------------------------------------------
// activity_events
// ---------------------------------------------------------------------------

const activityEventColumns = `id, tenant_id, field_id, crop_cycle_id, performed_by,
activity_type, category, started_at, completed_at, duration_minutes,
description, notes, metadata,
input_product_id, input_quantity, input_unit, input_cost, currency,
area_hectares,
weather_temp_celsius, weather_humidity_pct, weather_wind_speed_kmh, weather_conditions,
created_at`

func (r *fieldRepository) CreateActivityEvent(ctx context.Context, e *domain.ActivityEvent) (*domain.ActivityEvent, error) {
	e.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO activity_events (id, tenant_id, field_id, crop_cycle_id, performed_by,
activity_type, category, started_at, completed_at, duration_minutes,
description, notes,
input_product_id, input_quantity, input_unit, input_cost, currency,
area_hectares)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
RETURNING `+activityEventColumns,
		e.ID, e.TenantID, e.FieldID, e.CropCycleID, e.PerformedBy,
		e.ActivityType, string(e.Category), e.StartedAt, e.CompletedAt, e.DurationMinutes,
		e.Description, e.Notes,
		e.InputProductID, e.InputQuantity, e.InputUnit, e.InputCost, e.Currency,
		e.AreaHectares,
	)
	return scanActivityEvent(row)
}

func (r *fieldRepository) ListActivityEvents(ctx context.Context, params domain.ListActivityEventsParams) ([]domain.ActivityEvent, int32, error) {
	var total int32
	err := r.queryRow(ctx,
		`SELECT COUNT(*)::int FROM activity_events
		 WHERE tenant_id=$1 AND field_id=$2
		   AND ($3::varchar IS NULL OR crop_cycle_id=$3)
		   AND ($4::varchar IS NULL OR category=$4)`,
		params.TenantID, params.FieldID,
		nilIfEmptyStr(params.CropCycleID), nilIfEmptyCategory(params.Category),
	).Scan(&total)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to count activity events: %v", err))
	}

	rows, err := r.query(ctx,
		`SELECT `+activityEventColumns+` FROM activity_events
		 WHERE tenant_id=$1 AND field_id=$2
		   AND ($3::varchar IS NULL OR crop_cycle_id=$3)
		   AND ($4::varchar IS NULL OR category=$4)
		 ORDER BY started_at DESC
		 LIMIT $5 OFFSET $6`,
		params.TenantID, params.FieldID,
		nilIfEmptyStr(params.CropCycleID), nilIfEmptyCategory(params.Category),
		params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to list activity events: %v", err))
	}
	defer rows.Close()

	var out []domain.ActivityEvent
	for rows.Next() {
		e, err := scanActivityEvent(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		out = append(out, *e)
	}
	return out, total, nil
}

func scanActivityEvent(row pgx.Row) (*domain.ActivityEvent, error) {
	e := &domain.ActivityEvent{}
	var metadata interface{}
	err := row.Scan(
		&e.ID, &e.TenantID, &e.FieldID, &e.CropCycleID, &e.PerformedBy,
		&e.ActivityType, &e.Category, &e.StartedAt, &e.CompletedAt, &e.DurationMinutes,
		&e.Description, &e.Notes, &metadata,
		&e.InputProductID, &e.InputQuantity, &e.InputUnit, &e.InputCost, &e.Currency,
		&e.AreaHectares,
		&e.WeatherTempC, &e.WeatherHumidity, &e.WeatherWindSpeed, &e.WeatherConditions,
		&e.CreatedAt,
	)
	return e, err
}

func ptrOrNil(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

func nilIfEmptyStr(s *string) interface{} {
	if s == nil || *s == "" {
		return nil
	}
	return *s
}

func nilIfEmptyCategory(c *domain.ActivityCategory) interface{} {
	if c == nil || *c == domain.ActivityCategoryUnspecified {
		return nil
	}
	return string(*c)
}

// ---------------------------------------------------------------------------
// activity_evidence
// ---------------------------------------------------------------------------

const activityEvidenceColumns = `id, tenant_id, activity_event_id, evidence_type,
file_url, file_name, file_size_bytes, mime_type, thumbnail_url, caption,
latitude, longitude, captured_at, captured_by, created_at`

func (r *fieldRepository) CreateActivityEvidence(ctx context.Context, e *domain.ActivityEvidence) (*domain.ActivityEvidence, error) {
	e.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO activity_evidence (id, tenant_id, activity_event_id, evidence_type,
file_url, file_name, file_size_bytes, mime_type, thumbnail_url, caption,
latitude, longitude, captured_at, captured_by)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
RETURNING `+activityEvidenceColumns,
		e.ID, e.TenantID, e.ActivityEventID, string(e.EvidenceType),
		e.FileURL, e.FileName, e.FileSizeBytes, e.MimeType, e.ThumbnailURL, e.Caption,
		e.Latitude, e.Longitude, e.CapturedAt, e.CapturedBy,
	)
	return scanActivityEvidence(row)
}

func (r *fieldRepository) ListActivityEvidence(ctx context.Context, params domain.ListActivityEvidenceParams) ([]domain.ActivityEvidence, int32, error) {
	var total int32
	err := r.queryRow(ctx,
		`SELECT COUNT(*)::int FROM activity_evidence
		 WHERE tenant_id=$1 AND activity_event_id=$2`,
		params.TenantID, params.ActivityEventID,
	).Scan(&total)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to count activity evidence: %v", err))
	}

	rows, err := r.query(ctx,
		`SELECT `+activityEvidenceColumns+` FROM activity_evidence
		 WHERE tenant_id=$1 AND activity_event_id=$2
		 ORDER BY created_at DESC
		 LIMIT $3 OFFSET $4`,
		params.TenantID, params.ActivityEventID,
		params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", fmt.Sprintf("failed to list activity evidence: %v", err))
	}
	defer rows.Close()

	var out []domain.ActivityEvidence
	for rows.Next() {
		e, err := scanActivityEvidence(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		out = append(out, *e)
	}
	return out, total, nil
}

func (r *fieldRepository) DeleteActivityEvidence(ctx context.Context, id, tenantID string) error {
	return r.exec(ctx,
		`DELETE FROM activity_evidence WHERE id=$1 AND tenant_id=$2`,
		id, tenantID,
	)
}

func scanActivityEvidence(row pgx.Row) (*domain.ActivityEvidence, error) {
	e := &domain.ActivityEvidence{}
	err := row.Scan(
		&e.ID, &e.TenantID, &e.ActivityEventID, &e.EvidenceType,
		&e.FileURL, &e.FileName, &e.FileSizeBytes, &e.MimeType, &e.ThumbnailURL, &e.Caption,
		&e.Latitude, &e.Longitude, &e.CapturedAt, &e.CapturedBy, &e.CreatedAt,
	)
	return e, err
}
