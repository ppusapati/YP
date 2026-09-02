// Package postgres implements the outbound.IrrigationRepository port using pgx.
package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// irrigationRepository is the pgx implementation of outbound.IrrigationRepository.
// All tables in this service key on `id CHAR(26)` (a ULID), there is no
// separate surrogate integer key or `uuid` column.
type irrigationRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx // non-nil when scoped to a transaction
}

// NewIrrigationRepository creates a new postgres-backed IrrigationRepository.
func NewIrrigationRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.IrrigationRepository {
	return &irrigationRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "IrrigationPostgresRepository")),
	}
}

// WithTx returns a copy of the repository scoped to the given pgx.Tx.
func (r *irrigationRepository) WithTx(tx pgx.Tx) outbound.IrrigationRepository {
	return &irrigationRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *irrigationRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *irrigationRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *irrigationRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

func (r *irrigationRepository) tenantID(ctx context.Context) string {
	return p9context.TenantID(ctx)
}

func (r *irrigationRepository) userID(ctx context.Context) string {
	return p9context.UserID(ctx)
}

// =========================================================================
// Irrigation (simple aggregate) — persisted on the irrigation_schedules
// table using only the columns common to every schedule row (name/status).
// =========================================================================

func (r *irrigationRepository) CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
	entity.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO irrigation_schedules (id, tenant_id, name, status, version, created_by)
		VALUES ($1,$2,$3,$4,1,$5)
		RETURNING id, tenant_id, name, status, version, created_by, created_at`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status), entity.CreatedBy,
	)
	result, err := scanIrrigation(row)
	if err != nil {
		r.log.Errorw("msg", "CreateIrrigation failed", "error", err)
		return nil, errors.InternalServer("IRRIGATION_CREATE_FAILED", fmt.Sprintf("failed to create irrigation: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) GetIrrigationByUUID(ctx context.Context, uuid, tenantID string) (*domain.Irrigation, error) {
	row := r.queryRow(ctx,
		`SELECT id, tenant_id, name, status, version, created_by, created_at
		FROM irrigation_schedules WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	e, err := scanIrrigation(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", uuid))
		}
		return nil, errors.InternalServer("IRRIGATION_GET_FAILED", fmt.Sprintf("failed to get irrigation: %v", err))
	}
	return e, nil
}

func (r *irrigationRepository) ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error) {
	pageSize := params.PageSize
	if pageSize <= 0 {
		pageSize = 20
	}

	var total int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM irrigation_schedules
		WHERE tenant_id = $1 AND deleted_at IS NULL
			AND ($2::TEXT IS NULL OR status = $2)
			AND ($3::TEXT IS NULL OR name ILIKE '%' || $3 || '%')`,
		params.TenantID, nullableStatus(params.Status), params.Search,
	)
	if err := countRow.Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("IRRIGATION_COUNT_FAILED", fmt.Sprintf("failed to count irrigations: %v", err))
	}

	rows, err := r.query(ctx, `
		SELECT id, tenant_id, name, status, version, created_by, created_at
		FROM irrigation_schedules
		WHERE tenant_id = $1 AND deleted_at IS NULL
			AND ($2::TEXT IS NULL OR status = $2)
			AND ($3::TEXT IS NULL OR name ILIKE '%' || $3 || '%')
		ORDER BY created_at DESC
		LIMIT $4 OFFSET $5`,
		params.TenantID, nullableStatus(params.Status), params.Search, pageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("IRRIGATION_LIST_FAILED", fmt.Sprintf("failed to list irrigations: %v", err))
	}
	defer rows.Close()

	entities := make([]domain.Irrigation, 0)
	for rows.Next() {
		e, err := scanIrrigation(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("IRRIGATION_SCAN_FAILED", fmt.Sprintf("failed to scan irrigation: %v", err))
		}
		entities = append(entities, *e)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("IRRIGATION_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}
	return entities, total, nil
}

func (r *irrigationRepository) UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
	row := r.queryRow(ctx,
		`UPDATE irrigation_schedules SET
			name = COALESCE(NULLIF($3,''), name),
			status = COALESCE(NULLIF($4,''), status),
			version = version + 1,
			updated_at = NOW()
		WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL
		RETURNING id, tenant_id, name, status, version, created_by, created_at`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status),
	)
	e, err := scanIrrigation(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", entity.UUID))
		}
		return nil, errors.InternalServer("IRRIGATION_UPDATE_FAILED", fmt.Sprintf("failed to update irrigation: %v", err))
	}
	return e, nil
}

func (r *irrigationRepository) DeleteIrrigation(ctx context.Context, uuid, tenantID, deletedBy string) error {
	_ = deletedBy // irrigation_schedules has no deleted_by column
	if err := r.exec(ctx,
		`UPDATE irrigation_schedules SET deleted_at=NOW() WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	); err != nil {
		return errors.InternalServer("IRRIGATION_DELETE_FAILED", fmt.Sprintf("failed to delete irrigation: %v", err))
	}
	return nil
}

func (r *irrigationRepository) CheckIrrigationExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM irrigation_schedules WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	if err != nil {
		return false, errors.InternalServer("IRRIGATION_CHECK_FAILED", fmt.Sprintf("failed to check irrigation exists: %v", err))
	}
	return exists, nil
}

func (r *irrigationRepository) CheckIrrigationNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM irrigation_schedules WHERE name=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		name, tenantID,
	).Scan(&exists)
	if err != nil {
		return false, errors.InternalServer("IRRIGATION_NAME_CHECK_FAILED", fmt.Sprintf("failed to check irrigation name: %v", err))
	}
	return exists, nil
}

func scanIrrigation(row pgx.Row) (*domain.Irrigation, error) {
	e := &domain.Irrigation{}
	var status string
	err := row.Scan(&e.UUID, &e.TenantID, &e.Name, &status, &e.Version, &e.CreatedBy, &e.CreatedAt)
	if err != nil {
		return nil, err
	}
	e.Status = domain.IrrigationStatus(status)
	return e, nil
}

func nullableStatus(status *domain.IrrigationStatus) interface{} {
	if status == nil || *status == "" {
		return nil
	}
	return string(*status)
}

// =========================================================================
// Zones
// =========================================================================

func (r *irrigationRepository) CreateZone(ctx context.Context, zone *domain.IrrigationZone) (*domain.IrrigationZone, error) {
	zone.UUID = ulid.NewString()
	zone.IsActive = true

	row := r.queryRow(ctx, `
		INSERT INTO irrigation_zones (
			id, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
		RETURNING id, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_at, updated_at`,
		zone.UUID, zone.TenantID, zone.FieldID, zone.FarmID, zone.Name, zone.Description,
		zone.AreaHectares, zone.SoilType, zone.CropType, zone.CropGrowthStage,
		zone.Latitude, zone.Longitude, zone.IsActive,
	)

	result, err := scanZone(row)
	if err != nil {
		r.log.Errorw("msg", "CreateZone failed", "error", err)
		return nil, errors.InternalServer("ZONE_CREATE_FAILED", fmt.Sprintf("failed to create zone: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) GetZoneByUUID(ctx context.Context, uuid string) (*domain.IrrigationZone, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		SELECT id, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_at, updated_at
		FROM irrigation_zones
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	z, err := scanZone(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ZONE_NOT_FOUND", fmt.Sprintf("zone %s not found", uuid))
		}
		return nil, errors.InternalServer("ZONE_GET_FAILED", fmt.Sprintf("failed to get zone: %v", err))
	}
	return z, nil
}

func (r *irrigationRepository) ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error) {
	return r.listZones(ctx, "field_id", fieldID, pageSize, offset)
}

func (r *irrigationRepository) ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error) {
	return r.listZones(ctx, "farm_id", farmID, pageSize, offset)
}

func (r *irrigationRepository) listZones(ctx context.Context, column, value string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error) {
	tenantID := r.tenantID(ctx)
	if pageSize <= 0 {
		pageSize = 20
	}

	countQuery := fmt.Sprintf(`SELECT COUNT(*) FROM irrigation_zones WHERE tenant_id = $1 AND %s = $2 AND deleted_at IS NULL`, column)
	var total int32
	if err := r.queryRow(ctx, countQuery, tenantID, value).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("ZONE_COUNT_FAILED", fmt.Sprintf("failed to count zones: %v", err))
	}

	dataQuery := fmt.Sprintf(`
		SELECT id, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_at, updated_at
		FROM irrigation_zones
		WHERE tenant_id = $1 AND %s = $2 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4`, column)

	rows, err := r.query(ctx, dataQuery, tenantID, value, pageSize, offset)
	if err != nil {
		return nil, 0, errors.InternalServer("ZONE_LIST_FAILED", fmt.Sprintf("failed to list zones: %v", err))
	}
	defer rows.Close()

	zones := make([]domain.IrrigationZone, 0)
	for rows.Next() {
		z, err := scanZone(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("ZONE_SCAN_FAILED", fmt.Sprintf("failed to scan zone: %v", err))
		}
		zones = append(zones, *z)
	}
	return zones, total, rows.Err()
}

func scanZone(row pgx.Row) (*domain.IrrigationZone, error) {
	z := &domain.IrrigationZone{}
	err := row.Scan(
		&z.UUID, &z.TenantID, &z.FieldID, &z.FarmID,
		&z.Name, &z.Description, &z.AreaHectares, &z.SoilType,
		&z.CropType, &z.CropGrowthStage, &z.Latitude, &z.Longitude,
		&z.IsActive, &z.CreatedAt, &z.UpdatedAt,
	)
	return z, err
}

// =========================================================================
// Controllers
// =========================================================================

func (r *irrigationRepository) CreateController(ctx context.Context, ctrl *domain.WaterController) (*domain.WaterController, error) {
	ctrl.UUID = ulid.NewString()
	ctrl.IsActive = true

	row := r.queryRow(ctx, `
		INSERT INTO water_controllers (
			id, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, is_active, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
		RETURNING id, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_at`,
		ctrl.UUID, ctrl.TenantID, ctrl.ZoneID, ctrl.FieldID, ctrl.FarmID,
		ctrl.Name, ctrl.Model, ctrl.FirmwareVersion,
		string(ctrl.ControllerType), string(ctrl.Protocol), string(ctrl.Status),
		ctrl.Endpoint, ctrl.MaxFlowRateLitersPerHour, ctrl.IsActive, ctrl.CreatedBy,
	)

	result, err := scanController(row)
	if err != nil {
		r.log.Errorw("msg", "CreateController failed", "error", err)
		return nil, errors.InternalServer("CONTROLLER_CREATE_FAILED", fmt.Sprintf("failed to create controller: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) GetControllerByUUID(ctx context.Context, uuid string) (*domain.WaterController, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		SELECT id, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_at
		FROM water_controllers
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	c, err := scanController(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller %s not found", uuid))
		}
		return nil, errors.InternalServer("CONTROLLER_GET_FAILED", fmt.Sprintf("failed to get controller: %v", err))
	}
	return c, nil
}

func (r *irrigationRepository) ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.WaterController, int32, error) {
	tenantID := r.tenantID(ctx)
	if pageSize <= 0 {
		pageSize = 20
	}

	var total int32
	if err := r.queryRow(ctx,
		`SELECT COUNT(*) FROM water_controllers WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL`,
		tenantID, zoneID,
	).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("CONTROLLER_COUNT_FAILED", fmt.Sprintf("failed to count controllers: %v", err))
	}

	rows, err := r.query(ctx, `
		SELECT id, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_at
		FROM water_controllers
		WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4`,
		tenantID, zoneID, pageSize, offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("CONTROLLER_LIST_FAILED", fmt.Sprintf("failed to list controllers: %v", err))
	}
	defer rows.Close()

	controllers := make([]domain.WaterController, 0)
	for rows.Next() {
		c, err := scanController(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("CONTROLLER_SCAN_FAILED", fmt.Sprintf("failed to scan controller: %v", err))
		}
		controllers = append(controllers, *c)
	}
	return controllers, total, rows.Err()
}

func (r *irrigationRepository) UpdateControllerStatus(ctx context.Context, uuid string, status domain.ControllerStatus) (*domain.WaterController, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		UPDATE water_controllers SET
			status = $3, last_heartbeat = NOW(), updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_at`,
		uuid, tenantID, string(status),
	)
	c, err := scanController(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller %s not found", uuid))
		}
		return nil, errors.InternalServer("CONTROLLER_UPDATE_FAILED", fmt.Sprintf("failed to update controller status: %v", err))
	}
	return c, nil
}

func scanController(row pgx.Row) (*domain.WaterController, error) {
	c := &domain.WaterController{}
	var ctrlType, proto, status string
	err := row.Scan(
		&c.UUID, &c.TenantID, &c.ZoneID, &c.FieldID, &c.FarmID,
		&c.Name, &c.Model, &c.FirmwareVersion,
		&ctrlType, &proto, &status, &c.Endpoint,
		&c.MaxFlowRateLitersPerHour, &c.LastHeartbeat, &c.IsActive,
		&c.CreatedBy, &c.CreatedAt, &c.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	c.ControllerType = domain.ControllerType(ctrlType)
	c.Protocol = domain.Protocol(proto)
	c.Status = domain.ControllerStatus(status)
	return c, nil
}

// =========================================================================
// Schedules
// =========================================================================

func (r *irrigationRepository) CreateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	sched.UUID = ulid.NewString()
	if sched.Status == "" {
		sched.Status = domain.IrrigationStatusScheduled
	}

	row := r.queryRow(ctx, `
		INSERT INTO irrigation_schedules (
			id, tenant_id, field_id, farm_id, zone_id, controller_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			status, version, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,1,$20)
		RETURNING id, tenant_id, field_id, farm_id, zone_id, controller_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			status, version, created_by, created_at, updated_at`,
		sched.UUID, sched.TenantID, sched.FieldID, sched.FarmID, sched.ZoneID, sched.ControllerID,
		sched.Name, sched.Description, string(sched.ScheduleType), sched.StartTime, sched.EndTime,
		sched.DurationMinutes, sched.WaterQuantityLiters, sched.FlowRateLitersPerHour,
		string(sched.Frequency), sched.SoilMoistureThresholdPct, sched.WeatherAdjusted,
		sched.CropGrowthStage, string(sched.Status), sched.CreatedBy,
	)

	result, err := scanSchedule(row)
	if err != nil {
		r.log.Errorw("msg", "CreateSchedule failed", "error", err)
		return nil, errors.InternalServer("SCHEDULE_CREATE_FAILED", fmt.Sprintf("failed to create schedule: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) GetScheduleByUUID(ctx context.Context, uuid string) (*domain.IrrigationSchedule, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		SELECT id, tenant_id, field_id, farm_id, zone_id, controller_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			status, version, created_by, created_at, updated_at
		FROM irrigation_schedules
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	s, err := scanSchedule(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", uuid))
		}
		return nil, errors.InternalServer("SCHEDULE_GET_FAILED", fmt.Sprintf("failed to get schedule: %v", err))
	}
	return s, nil
}

func (r *irrigationRepository) ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	return r.listSchedules(ctx, "field_id", fieldID, pageSize, offset)
}

func (r *irrigationRepository) ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	return r.listSchedules(ctx, "zone_id", zoneID, pageSize, offset)
}

func (r *irrigationRepository) listSchedules(ctx context.Context, column, value string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	tenantID := r.tenantID(ctx)
	if pageSize <= 0 {
		pageSize = 20
	}

	countQuery := fmt.Sprintf(`SELECT COUNT(*) FROM irrigation_schedules WHERE tenant_id = $1 AND %s = $2 AND deleted_at IS NULL`, column)
	var total int32
	if err := r.queryRow(ctx, countQuery, tenantID, value).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("SCHEDULE_COUNT_FAILED", fmt.Sprintf("failed to count schedules: %v", err))
	}

	dataQuery := fmt.Sprintf(`
		SELECT id, tenant_id, field_id, farm_id, zone_id, controller_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			status, version, created_by, created_at, updated_at
		FROM irrigation_schedules
		WHERE tenant_id = $1 AND %s = $2 AND deleted_at IS NULL
		ORDER BY start_time DESC
		LIMIT $3 OFFSET $4`, column)

	rows, err := r.query(ctx, dataQuery, tenantID, value, pageSize, offset)
	if err != nil {
		return nil, 0, errors.InternalServer("SCHEDULE_LIST_FAILED", fmt.Sprintf("failed to list schedules: %v", err))
	}
	defer rows.Close()

	schedules := make([]domain.IrrigationSchedule, 0)
	for rows.Next() {
		s, err := scanSchedule(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("SCHEDULE_SCAN_FAILED", fmt.Sprintf("failed to scan schedule: %v", err))
		}
		schedules = append(schedules, *s)
	}
	return schedules, total, rows.Err()
}

func (r *irrigationRepository) UpdateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		UPDATE irrigation_schedules SET
			name = $3, description = $4, schedule_type = $5,
			start_time = $6, end_time = $7, duration_minutes = $8,
			water_quantity_liters = $9, flow_rate_liters_per_hour = $10, frequency = $11,
			soil_moisture_threshold_pct = $12, weather_adjusted = $13, crop_growth_stage = $14,
			controller_id = $15, status = $16, version = version + 1, updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, tenant_id, field_id, farm_id, zone_id, controller_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			status, version, created_by, created_at, updated_at`,
		sched.UUID, tenantID,
		sched.Name, sched.Description, string(sched.ScheduleType),
		sched.StartTime, sched.EndTime, sched.DurationMinutes,
		sched.WaterQuantityLiters, sched.FlowRateLitersPerHour, string(sched.Frequency),
		sched.SoilMoistureThresholdPct, sched.WeatherAdjusted, sched.CropGrowthStage,
		sched.ControllerID, string(sched.Status),
	)

	result, err := scanSchedule(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", sched.UUID))
		}
		return nil, errors.InternalServer("SCHEDULE_UPDATE_FAILED", fmt.Sprintf("failed to update schedule: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) UpdateScheduleStatus(ctx context.Context, uuid string, status domain.IrrigationStatus) (*domain.IrrigationSchedule, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		UPDATE irrigation_schedules SET
			status = $3, version = version + 1, updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, tenant_id, field_id, farm_id, zone_id, controller_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			status, version, created_by, created_at, updated_at`,
		uuid, tenantID, string(status),
	)
	result, err := scanSchedule(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", uuid))
		}
		return nil, errors.InternalServer("SCHEDULE_UPDATE_FAILED", fmt.Sprintf("failed to update schedule status: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) DeleteSchedule(ctx context.Context, uuid string) error {
	tenantID := r.tenantID(ctx)
	tag, err := r.pool.Exec(ctx,
		`UPDATE irrigation_schedules SET deleted_at = NOW() WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	if err != nil {
		return errors.InternalServer("SCHEDULE_DELETE_FAILED", fmt.Sprintf("failed to delete schedule: %v", err))
	}
	if tag.RowsAffected() == 0 {
		return errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", uuid))
	}
	return nil
}

func scanSchedule(row pgx.Row) (*domain.IrrigationSchedule, error) {
	s := &domain.IrrigationSchedule{}
	var schedType, freq, status string
	err := row.Scan(
		&s.UUID, &s.TenantID, &s.FieldID, &s.FarmID, &s.ZoneID, &s.ControllerID,
		&s.Name, &s.Description,
		&schedType, &s.StartTime, &s.EndTime, &s.DurationMinutes,
		&s.WaterQuantityLiters, &s.FlowRateLitersPerHour, &freq,
		&s.SoilMoistureThresholdPct, &s.WeatherAdjusted, &s.CropGrowthStage,
		&status, &s.Version, &s.CreatedBy, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	s.ScheduleType = domain.ScheduleType(schedType)
	s.Frequency = domain.Frequency(freq)
	s.Status = domain.IrrigationStatus(status)
	return s, nil
}

// =========================================================================
// Events
// =========================================================================

func (r *irrigationRepository) CreateEvent(ctx context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error) {
	evt.UUID = ulid.NewString()

	row := r.queryRow(ctx, `
		INSERT INTO irrigation_events (
			id, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
		RETURNING id, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason, created_at`,
		evt.UUID, evt.TenantID, evt.ScheduleID, evt.ZoneID, evt.ControllerID,
		string(evt.Status), evt.StartedAt, evt.EndedAt,
		evt.ActualDurationMinutes, evt.ActualWaterLiters,
		evt.SoilMoistureBeforePct, evt.SoilMoistureAfterPct, evt.FailureReason,
	)

	result, err := scanEvent(row)
	if err != nil {
		r.log.Errorw("msg", "CreateEvent failed", "error", err)
		return nil, errors.InternalServer("EVENT_CREATE_FAILED", fmt.Sprintf("failed to create event: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) GetEventByUUID(ctx context.Context, uuid string) (*domain.IrrigationEvent, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		SELECT id, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason, created_at
		FROM irrigation_events
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	e, err := scanEvent(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("EVENT_NOT_FOUND", fmt.Sprintf("event %s not found", uuid))
		}
		return nil, errors.InternalServer("EVENT_GET_FAILED", fmt.Sprintf("failed to get event: %v", err))
	}
	return e, nil
}

func (r *irrigationRepository) ListEventsByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationEvent, int32, error) {
	tenantID := r.tenantID(ctx)
	if pageSize <= 0 {
		pageSize = 20
	}

	var total int32
	if err := r.queryRow(ctx,
		`SELECT COUNT(*) FROM irrigation_events WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL`,
		tenantID, zoneID,
	).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("EVENT_COUNT_FAILED", fmt.Sprintf("failed to count events: %v", err))
	}

	rows, err := r.query(ctx, `
		SELECT id, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason, created_at
		FROM irrigation_events
		WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4`,
		tenantID, zoneID, pageSize, offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("EVENT_LIST_FAILED", fmt.Sprintf("failed to list events: %v", err))
	}
	defer rows.Close()

	events := make([]domain.IrrigationEvent, 0)
	for rows.Next() {
		e, err := scanEvent(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("EVENT_SCAN_FAILED", fmt.Sprintf("failed to scan event: %v", err))
		}
		events = append(events, *e)
	}
	return events, total, rows.Err()
}

func (r *irrigationRepository) ListEventsByTimeRange(ctx context.Context, zoneID string, start, end time.Time) ([]domain.IrrigationEvent, error) {
	tenantID := r.tenantID(ctx)
	rows, err := r.query(ctx, `
		SELECT id, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason, created_at
		FROM irrigation_events
		WHERE tenant_id = $1 AND zone_id = $2 AND started_at >= $3 AND started_at <= $4 AND deleted_at IS NULL
		ORDER BY started_at DESC`,
		tenantID, zoneID, start, end,
	)
	if err != nil {
		return nil, errors.InternalServer("EVENT_LIST_FAILED", fmt.Sprintf("failed to list events: %v", err))
	}
	defer rows.Close()

	events := make([]domain.IrrigationEvent, 0)
	for rows.Next() {
		e, err := scanEvent(rows)
		if err != nil {
			return nil, errors.InternalServer("EVENT_SCAN_FAILED", fmt.Sprintf("failed to scan event: %v", err))
		}
		events = append(events, *e)
	}
	return events, rows.Err()
}

func (r *irrigationRepository) UpdateEvent(ctx context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error) {
	tenantID := r.tenantID(ctx)
	row := r.queryRow(ctx, `
		UPDATE irrigation_events SET
			status = $3, ended_at = $4, actual_duration_minutes = $5,
			actual_water_liters = $6, soil_moisture_after_pct = $7,
			failure_reason = $8, updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason, created_at`,
		evt.UUID, tenantID,
		string(evt.Status), evt.EndedAt, evt.ActualDurationMinutes,
		evt.ActualWaterLiters, evt.SoilMoistureAfterPct, evt.FailureReason,
	)

	result, err := scanEvent(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("EVENT_NOT_FOUND", fmt.Sprintf("event %s not found", evt.UUID))
		}
		return nil, errors.InternalServer("EVENT_UPDATE_FAILED", fmt.Sprintf("failed to update event: %v", err))
	}
	return result, nil
}

func scanEvent(row pgx.Row) (*domain.IrrigationEvent, error) {
	e := &domain.IrrigationEvent{}
	var status string
	err := row.Scan(
		&e.UUID, &e.TenantID, &e.ScheduleID, &e.ZoneID, &e.ControllerID,
		&status, &e.StartedAt, &e.EndedAt,
		&e.ActualDurationMinutes, &e.ActualWaterLiters,
		&e.SoilMoistureBeforePct, &e.SoilMoistureAfterPct,
		&e.FailureReason, &e.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	e.Status = domain.IrrigationStatus(status)
	return e, nil
}

// =========================================================================
// Decisions
// =========================================================================

func (r *irrigationRepository) CreateDecision(ctx context.Context, dec *domain.IrrigationDecision) (*domain.IrrigationDecision, error) {
	dec.UUID = ulid.NewString()
	if dec.DecidedAt.IsZero() {
		dec.DecidedAt = time.Now()
	}

	row := r.queryRow(ctx, `
		INSERT INTO irrigation_decisions (
			id, tenant_id, zone_id, field_id, schedule_id,
			input_soil_moisture, input_temperature, input_humidity,
			input_rainfall_forecast_mm, input_wind_speed, input_crop_type,
			input_growth_stage, input_evapotranspiration_mm,
			output_should_irrigate, output_water_quantity_liters,
			output_duration_minutes, output_optimal_time, output_reasoning,
			output_confidence_score, decided_at, applied, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22)
		RETURNING id, tenant_id, zone_id, field_id, schedule_id,
			input_soil_moisture, input_temperature, input_humidity,
			input_rainfall_forecast_mm, input_wind_speed, input_crop_type,
			input_growth_stage, input_evapotranspiration_mm,
			output_should_irrigate, output_water_quantity_liters,
			output_duration_minutes, output_optimal_time, output_reasoning,
			output_confidence_score, decided_at, applied, created_by, created_at`,
		dec.UUID, dec.TenantID, dec.ZoneID, dec.FieldID, dec.ScheduleID,
		dec.Inputs.SoilMoisture, dec.Inputs.Temperature, dec.Inputs.Humidity,
		dec.Inputs.RainfallForecastMM, dec.Inputs.WindSpeed, dec.Inputs.CropType,
		dec.Inputs.GrowthStage, dec.Inputs.EvapotranspirationMM,
		dec.Output.ShouldIrrigate, dec.Output.WaterQuantityLiters,
		dec.Output.DurationMinutes, dec.Output.OptimalTime, dec.Output.Reasoning,
		dec.Output.ConfidenceScore, dec.DecidedAt, dec.Applied, dec.CreatedBy,
	)

	result, err := scanDecision(row)
	if err != nil {
		r.log.Errorw("msg", "CreateDecision failed", "error", err)
		return nil, errors.InternalServer("DECISION_CREATE_FAILED", fmt.Sprintf("failed to create decision: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) MarkDecisionApplied(ctx context.Context, uuid string) error {
	tenantID := r.tenantID(ctx)
	tag, err := r.pool.Exec(ctx,
		`UPDATE irrigation_decisions SET applied = TRUE, updated_at = NOW() WHERE id = $1 AND tenant_id = $2`,
		uuid, tenantID,
	)
	if err != nil {
		return errors.InternalServer("DECISION_MARK_FAILED", fmt.Sprintf("failed to mark decision applied: %v", err))
	}
	if tag.RowsAffected() == 0 {
		return errors.NotFound("DECISION_NOT_FOUND", fmt.Sprintf("decision %s not found", uuid))
	}
	return nil
}

func scanDecision(row pgx.Row) (*domain.IrrigationDecision, error) {
	d := &domain.IrrigationDecision{}
	err := row.Scan(
		&d.UUID, &d.TenantID, &d.ZoneID, &d.FieldID, &d.ScheduleID,
		&d.Inputs.SoilMoisture, &d.Inputs.Temperature, &d.Inputs.Humidity,
		&d.Inputs.RainfallForecastMM, &d.Inputs.WindSpeed, &d.Inputs.CropType,
		&d.Inputs.GrowthStage, &d.Inputs.EvapotranspirationMM,
		&d.Output.ShouldIrrigate, &d.Output.WaterQuantityLiters,
		&d.Output.DurationMinutes, &d.Output.OptimalTime, &d.Output.Reasoning,
		&d.Output.ConfidenceScore, &d.DecidedAt, &d.Applied, &d.CreatedBy, &d.CreatedAt,
	)
	return d, err
}

// =========================================================================
// Water Usage
// =========================================================================

func (r *irrigationRepository) CreateWaterUsageLog(ctx context.Context, wl *domain.WaterUsageLog) (*domain.WaterUsageLog, error) {
	wl.UUID = ulid.NewString()
	if wl.RecordedAt.IsZero() {
		wl.RecordedAt = time.Now()
	}

	row := r.queryRow(ctx, `
		INSERT INTO water_usage_logs (
			id, tenant_id, zone_id, controller_id, water_liters,
			recorded_at, period_start, period_end, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING id, tenant_id, zone_id, controller_id, water_liters,
			recorded_at, period_start, period_end, created_by, created_at`,
		wl.UUID, wl.TenantID, wl.ZoneID, wl.ControllerID, wl.WaterLiters,
		wl.RecordedAt, wl.PeriodStart, wl.PeriodEnd, wl.CreatedBy,
	)

	result, err := scanWaterUsageLog(row)
	if err != nil {
		r.log.Errorw("msg", "CreateWaterUsageLog failed", "error", err)
		return nil, errors.InternalServer("USAGE_LOG_CREATE_FAILED", fmt.Sprintf("failed to create water usage log: %v", err))
	}
	return result, nil
}

func (r *irrigationRepository) ListWaterUsageLogs(ctx context.Context, zoneID string, start, end time.Time) ([]domain.WaterUsageLog, error) {
	tenantID := r.tenantID(ctx)
	rows, err := r.query(ctx, `
		SELECT id, tenant_id, zone_id, controller_id, water_liters,
			recorded_at, period_start, period_end, created_by, created_at
		FROM water_usage_logs
		WHERE tenant_id = $1 AND zone_id = $2 AND period_start >= $3 AND period_end <= $4 AND deleted_at IS NULL
		ORDER BY recorded_at DESC`,
		tenantID, zoneID, start, end,
	)
	if err != nil {
		return nil, errors.InternalServer("USAGE_LOG_LIST_FAILED", fmt.Sprintf("failed to list water usage logs: %v", err))
	}
	defer rows.Close()

	logs := make([]domain.WaterUsageLog, 0)
	for rows.Next() {
		wl, err := scanWaterUsageLog(rows)
		if err != nil {
			return nil, errors.InternalServer("USAGE_LOG_SCAN_FAILED", fmt.Sprintf("failed to scan water usage log: %v", err))
		}
		logs = append(logs, *wl)
	}
	return logs, rows.Err()
}

func (r *irrigationRepository) SumWaterUsageByZone(ctx context.Context, zoneID string, start, end time.Time) (float64, error) {
	tenantID := r.tenantID(ctx)
	var total float64
	err := r.queryRow(ctx, `
		SELECT COALESCE(SUM(water_liters), 0)::double precision
		FROM water_usage_logs
		WHERE tenant_id = $1 AND zone_id = $2 AND period_start >= $3 AND period_end <= $4 AND deleted_at IS NULL`,
		tenantID, zoneID, start, end,
	).Scan(&total)
	if err != nil {
		return 0, errors.InternalServer("USAGE_SUM_FAILED", fmt.Sprintf("failed to sum water usage: %v", err))
	}
	return total, nil
}

func scanWaterUsageLog(row pgx.Row) (*domain.WaterUsageLog, error) {
	wl := &domain.WaterUsageLog{}
	err := row.Scan(
		&wl.UUID, &wl.TenantID, &wl.ZoneID, &wl.ControllerID,
		&wl.WaterLiters, &wl.RecordedAt, &wl.PeriodStart, &wl.PeriodEnd,
		&wl.CreatedBy, &wl.CreatedAt,
	)
	return wl, err
}
