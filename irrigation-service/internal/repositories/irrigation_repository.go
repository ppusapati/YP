package repositories

import (
	"context"
	"fmt"
	"time"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/models"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// IrrigationRepository defines the persistence contract for all irrigation entities.
type IrrigationRepository interface {
	// Zones
	CreateZone(ctx context.Context, zone *models.IrrigationZone) (*models.IrrigationZone, error)
	GetZoneByUUID(ctx context.Context, uuid string) (*models.IrrigationZone, error)
	ListZonesByField(ctx context.Context, fieldID string, limit, offset int32) ([]models.IrrigationZone, int32, error)
	ListZonesByFarm(ctx context.Context, farmID string, limit, offset int32) ([]models.IrrigationZone, int32, error)

	// Controllers
	CreateController(ctx context.Context, ctrl *models.WaterController) (*models.WaterController, error)
	GetControllerByUUID(ctx context.Context, uuid string) (*models.WaterController, error)
	ListControllersByZone(ctx context.Context, zoneID string, limit, offset int32) ([]models.WaterController, int32, error)
	ListControllersByField(ctx context.Context, fieldID string, limit, offset int32) ([]models.WaterController, int32, error)
	ListControllersByStatus(ctx context.Context, status models.ControllerStatus, limit, offset int32) ([]models.WaterController, int32, error)
	UpdateControllerStatus(ctx context.Context, uuid string, status models.ControllerStatus) (*models.WaterController, error)

	// Schedules
	CreateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	GetScheduleByUUID(ctx context.Context, uuid string) (*models.IrrigationSchedule, error)
	ListSchedulesByField(ctx context.Context, fieldID string, limit, offset int32) ([]models.IrrigationSchedule, int32, error)
	ListSchedulesByZone(ctx context.Context, zoneID string, limit, offset int32) ([]models.IrrigationSchedule, int32, error)
	ListSchedulesByFarm(ctx context.Context, farmID string, limit, offset int32) ([]models.IrrigationSchedule, int32, error)
	ListSchedulesByStatus(ctx context.Context, status models.IrrigationStatus, limit, offset int32) ([]models.IrrigationSchedule, int32, error)
	UpdateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	UpdateScheduleStatus(ctx context.Context, uuid string, status models.IrrigationStatus) (*models.IrrigationSchedule, error)
	DeleteSchedule(ctx context.Context, uuid string) error

	// Events
	CreateEvent(ctx context.Context, evt *models.IrrigationEvent) (*models.IrrigationEvent, error)
	GetEventByUUID(ctx context.Context, uuid string) (*models.IrrigationEvent, error)
	ListEventsByZone(ctx context.Context, zoneID string, limit, offset int32) ([]models.IrrigationEvent, int32, error)
	ListEventsByTimeRange(ctx context.Context, zoneID string, from, to time.Time, limit, offset int32) ([]models.IrrigationEvent, int32, error)
	UpdateEvent(ctx context.Context, evt *models.IrrigationEvent) (*models.IrrigationEvent, error)

	// Decisions
	CreateDecision(ctx context.Context, dec *models.IrrigationDecision) (*models.IrrigationDecision, error)
	MarkDecisionApplied(ctx context.Context, uuid string) (*models.IrrigationDecision, error)

	// Water Usage
	CreateWaterUsageLog(ctx context.Context, log *models.WaterUsageLog) (*models.WaterUsageLog, error)
	ListWaterUsageLogs(ctx context.Context, zoneID string, from, to time.Time) ([]models.WaterUsageLog, error)
	SumWaterUsageByZone(ctx context.Context, zoneID string, from, to time.Time) (float64, error)
}

// ---------------------------------------------------------------------------
// PostgreSQL implementation
// ---------------------------------------------------------------------------

type irrigationRepo struct {
	pool *pgxpool.Pool
	log  p9log.Helper
}

// NewIrrigationRepository creates a new PostgreSQL-backed irrigation repository.
func NewIrrigationRepository(d deps.ServiceDeps) IrrigationRepository {
	return &irrigationRepo{
		pool: d.Pool,
		log:  *p9log.NewHelper(p9log.With(d.Log, "component", "IrrigationRepository")),
	}
}

func (r *irrigationRepo) tenantID(ctx context.Context) string {
	return p9context.TenantID(ctx)
}

func (r *irrigationRepo) userID(ctx context.Context) string {
	return p9context.UserID(ctx)
}

// =========================================================================
// Zones
// =========================================================================

func (r *irrigationRepo) CreateZone(ctx context.Context, zone *models.IrrigationZone) (*models.IrrigationZone, error) {
	tenantID := r.tenantID(ctx)
	zone.UUID = ulid.NewString()
	zone.TenantID = tenantID
	zone.IsActive = true
	zone.CreatedBy = r.userID(ctx)
	zone.CreatedAt = time.Now()

	query := `
		INSERT INTO irrigation_zones (
			uuid, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
		RETURNING id, uuid, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		zone.UUID, zone.TenantID, zone.FieldID, zone.FarmID, zone.Name, zone.Description,
		zone.AreaHectares, zone.SoilType, zone.CropType, zone.CropGrowthStage,
		zone.Latitude, zone.Longitude, zone.IsActive, zone.CreatedBy, zone.CreatedAt,
	)

	result := &models.IrrigationZone{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.Name, &result.Description, &result.AreaHectares, &result.SoilType,
		&result.CropType, &result.CropGrowthStage, &result.Latitude, &result.Longitude,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		r.log.Errorf("CreateZone failed: %v", err)
		return nil, errors.InternalServer("CREATE_ZONE_FAILED", fmt.Sprintf("failed to create zone: %v", err))
	}
	return result, nil
}

func (r *irrigationRepo) GetZoneByUUID(ctx context.Context, uuid string) (*models.IrrigationZone, error) {
	tenantID := r.tenantID(ctx)
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_zones
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID)
	z := &models.IrrigationZone{}
	err := row.Scan(
		&z.ID, &z.UUID, &z.TenantID, &z.FieldID, &z.FarmID,
		&z.Name, &z.Description, &z.AreaHectares, &z.SoilType,
		&z.CropType, &z.CropGrowthStage, &z.Latitude, &z.Longitude,
		&z.IsActive, &z.CreatedBy, &z.CreatedAt, &z.UpdatedBy, &z.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ZONE_NOT_FOUND", fmt.Sprintf("zone %s not found", uuid))
		}
		r.log.Errorf("GetZoneByUUID failed: %v", err)
		return nil, errors.InternalServer("GET_ZONE_FAILED", fmt.Sprintf("failed to get zone: %v", err))
	}
	return z, nil
}

func (r *irrigationRepo) ListZonesByField(ctx context.Context, fieldID string, limit, offset int32) ([]models.IrrigationZone, int32, error) {
	tenantID := r.tenantID(ctx)
	if limit <= 0 {
		limit = 20
	}

	countQuery := `SELECT COUNT(*)::int FROM irrigation_zones WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL`
	var total int32
	if err := r.pool.QueryRow(ctx, countQuery, tenantID, fieldID).Scan(&total); err != nil {
		r.log.Errorf("ListZonesByField count failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_ZONES_FAILED", fmt.Sprintf("failed to count zones: %v", err))
	}

	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_zones
		WHERE tenant_id = $1 AND field_id = $2 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4`

	rows, err := r.pool.Query(ctx, query, tenantID, fieldID, limit, offset)
	if err != nil {
		r.log.Errorf("ListZonesByField failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_ZONES_FAILED", fmt.Sprintf("failed to list zones: %v", err))
	}
	defer rows.Close()

	zones, err := scanZones(rows)
	if err != nil {
		return nil, 0, err
	}
	return zones, total, nil
}

func (r *irrigationRepo) ListZonesByFarm(ctx context.Context, farmID string, limit, offset int32) ([]models.IrrigationZone, int32, error) {
	tenantID := r.tenantID(ctx)
	if limit <= 0 {
		limit = 20
	}

	countQuery := `SELECT COUNT(*)::int FROM irrigation_zones WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL`
	var total int32
	if err := r.pool.QueryRow(ctx, countQuery, tenantID, farmID).Scan(&total); err != nil {
		r.log.Errorf("ListZonesByFarm count failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_ZONES_FAILED", fmt.Sprintf("failed to count zones: %v", err))
	}

	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, name, description,
			area_hectares, soil_type, crop_type, crop_growth_stage,
			latitude, longitude, is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_zones
		WHERE tenant_id = $1 AND farm_id = $2 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4`

	rows, err := r.pool.Query(ctx, query, tenantID, farmID, limit, offset)
	if err != nil {
		r.log.Errorf("ListZonesByFarm failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_ZONES_FAILED", fmt.Sprintf("failed to list zones: %v", err))
	}
	defer rows.Close()

	zones, err := scanZones(rows)
	if err != nil {
		return nil, 0, err
	}
	return zones, total, nil
}

func scanZones(rows pgx.Rows) ([]models.IrrigationZone, error) {
	var zones []models.IrrigationZone
	for rows.Next() {
		var z models.IrrigationZone
		if err := rows.Scan(
			&z.ID, &z.UUID, &z.TenantID, &z.FieldID, &z.FarmID,
			&z.Name, &z.Description, &z.AreaHectares, &z.SoilType,
			&z.CropType, &z.CropGrowthStage, &z.Latitude, &z.Longitude,
			&z.IsActive, &z.CreatedBy, &z.CreatedAt, &z.UpdatedBy, &z.UpdatedAt,
		); err != nil {
			return nil, errors.InternalServer("SCAN_ZONE_FAILED", fmt.Sprintf("failed to scan zone: %v", err))
		}
		zones = append(zones, z)
	}
	if zones == nil {
		zones = []models.IrrigationZone{}
	}
	return zones, nil
}

// =========================================================================
// Controllers
// =========================================================================

func (r *irrigationRepo) CreateController(ctx context.Context, ctrl *models.WaterController) (*models.WaterController, error) {
	tenantID := r.tenantID(ctx)
	ctrl.UUID = ulid.NewString()
	ctrl.TenantID = tenantID
	ctrl.IsActive = true
	ctrl.CreatedBy = r.userID(ctx)
	ctrl.CreatedAt = time.Now()

	query := `
		INSERT INTO water_controllers (
			uuid, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
		RETURNING id, uuid, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		ctrl.UUID, ctrl.TenantID, ctrl.ZoneID, ctrl.FieldID, ctrl.FarmID,
		ctrl.Name, ctrl.Model, ctrl.FirmwareVersion,
		string(ctrl.ControllerType), string(ctrl.Protocol), string(ctrl.Status),
		ctrl.Endpoint, ctrl.MaxFlowRateLitersPerHour,
		ctrl.IsActive, ctrl.CreatedBy, ctrl.CreatedAt,
	)

	result := &models.WaterController{}
	var ctrlType, proto, status string
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.ZoneID, &result.FieldID,
		&result.FarmID, &result.Name, &result.Model, &result.FirmwareVersion,
		&ctrlType, &proto, &status, &result.Endpoint,
		&result.MaxFlowRateLitersPerHour, &result.LastHeartbeat, &result.IsActive,
		&result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		r.log.Errorf("CreateController failed: %v", err)
		return nil, errors.InternalServer("CREATE_CONTROLLER_FAILED", fmt.Sprintf("failed to create controller: %v", err))
	}
	result.ControllerType = models.ControllerType(ctrlType)
	result.Protocol = models.Protocol(proto)
	result.Status = models.ControllerStatus(status)
	return result, nil
}

func (r *irrigationRepo) GetControllerByUUID(ctx context.Context, uuid string) (*models.WaterController, error) {
	tenantID := r.tenantID(ctx)
	query := `
		SELECT id, uuid, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_by, updated_at
		FROM water_controllers
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID)
	c, err := scanController(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller %s not found", uuid))
		}
		r.log.Errorf("GetControllerByUUID failed: %v", err)
		return nil, errors.InternalServer("GET_CONTROLLER_FAILED", fmt.Sprintf("failed to get controller: %v", err))
	}
	return c, nil
}

func scanController(row pgx.Row) (*models.WaterController, error) {
	c := &models.WaterController{}
	var ctrlType, proto, status string
	err := row.Scan(
		&c.ID, &c.UUID, &c.TenantID, &c.ZoneID, &c.FieldID, &c.FarmID,
		&c.Name, &c.Model, &c.FirmwareVersion,
		&ctrlType, &proto, &status, &c.Endpoint,
		&c.MaxFlowRateLitersPerHour, &c.LastHeartbeat, &c.IsActive,
		&c.CreatedBy, &c.CreatedAt, &c.UpdatedBy, &c.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	c.ControllerType = models.ControllerType(ctrlType)
	c.Protocol = models.Protocol(proto)
	c.Status = models.ControllerStatus(status)
	return c, nil
}

func (r *irrigationRepo) listControllers(ctx context.Context, where string, args []any, limit, offset int32) ([]models.WaterController, int32, error) {
	if limit <= 0 {
		limit = 20
	}

	countQuery := fmt.Sprintf("SELECT COUNT(*)::int FROM water_controllers WHERE %s AND deleted_at IS NULL", where)
	var total int32
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("LIST_CONTROLLERS_FAILED", fmt.Sprintf("failed to count controllers: %v", err))
	}

	dataQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_by, updated_at
		FROM water_controllers
		WHERE %s AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $%d OFFSET $%d`, where, len(args)+1, len(args)+2)

	rows, err := r.pool.Query(ctx, dataQuery, append(args, limit, offset)...)
	if err != nil {
		return nil, 0, errors.InternalServer("LIST_CONTROLLERS_FAILED", fmt.Sprintf("failed to list controllers: %v", err))
	}
	defer rows.Close()

	var controllers []models.WaterController
	for rows.Next() {
		c, err := scanController(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("SCAN_CONTROLLER_FAILED", fmt.Sprintf("failed to scan controller: %v", err))
		}
		controllers = append(controllers, *c)
	}
	if controllers == nil {
		controllers = []models.WaterController{}
	}
	return controllers, total, nil
}

func (r *irrigationRepo) ListControllersByZone(ctx context.Context, zoneID string, limit, offset int32) ([]models.WaterController, int32, error) {
	tenantID := r.tenantID(ctx)
	return r.listControllers(ctx, "tenant_id = $1 AND zone_id = $2", []any{tenantID, zoneID}, limit, offset)
}

func (r *irrigationRepo) ListControllersByField(ctx context.Context, fieldID string, limit, offset int32) ([]models.WaterController, int32, error) {
	tenantID := r.tenantID(ctx)
	return r.listControllers(ctx, "tenant_id = $1 AND field_id = $2", []any{tenantID, fieldID}, limit, offset)
}

func (r *irrigationRepo) ListControllersByStatus(ctx context.Context, status models.ControllerStatus, limit, offset int32) ([]models.WaterController, int32, error) {
	tenantID := r.tenantID(ctx)
	return r.listControllers(ctx, "tenant_id = $1 AND status = $2", []any{tenantID, string(status)}, limit, offset)
}

func (r *irrigationRepo) UpdateControllerStatus(ctx context.Context, uuid string, status models.ControllerStatus) (*models.WaterController, error) {
	tenantID := r.tenantID(ctx)
	userID := r.userID(ctx)

	query := `
		UPDATE water_controllers SET
			status = $3, last_heartbeat = NOW(), updated_by = $4, updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, zone_id, field_id, farm_id, name, model,
			firmware_version, controller_type, protocol, status, endpoint,
			max_flow_rate_liters_per_hour, last_heartbeat, is_active,
			created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID, string(status), userID)
	c, err := scanController(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller %s not found", uuid))
		}
		r.log.Errorf("UpdateControllerStatus failed: %v", err)
		return nil, errors.InternalServer("UPDATE_CONTROLLER_FAILED", fmt.Sprintf("failed to update controller status: %v", err))
	}
	return c, nil
}

// =========================================================================
// Schedules
// =========================================================================

func (r *irrigationRepo) CreateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error) {
	tenantID := r.tenantID(ctx)
	sched.UUID = ulid.NewString()
	sched.TenantID = tenantID
	sched.IsActive = true
	sched.CreatedBy = r.userID(ctx)
	sched.CreatedAt = time.Now()
	sched.Version = 1
	if sched.Status == "" {
		sched.Status = models.IrrigationStatusScheduled
	}

	query := `
		INSERT INTO irrigation_schedules (
			uuid, tenant_id, field_id, farm_id, zone_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			controller_id, status, version, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23)
		RETURNING id, uuid, tenant_id, field_id, farm_id, zone_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			controller_id, status, version, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		sched.UUID, sched.TenantID, sched.FieldID, sched.FarmID, sched.ZoneID,
		sched.Name, sched.Description,
		string(sched.ScheduleType), sched.StartTime, sched.EndTime, sched.DurationMinutes,
		sched.WaterQuantityLiters, sched.FlowRateLitersPerHour, string(sched.Frequency),
		sched.SoilMoistureThresholdPct, sched.WeatherAdjusted, sched.CropGrowthStage,
		sched.ControllerID, string(sched.Status), sched.Version,
		sched.IsActive, sched.CreatedBy, sched.CreatedAt,
	)

	result, err := scanSchedule(row)
	if err != nil {
		r.log.Errorf("CreateSchedule failed: %v", err)
		return nil, errors.InternalServer("CREATE_SCHEDULE_FAILED", fmt.Sprintf("failed to create schedule: %v", err))
	}
	return result, nil
}

func scanSchedule(row pgx.Row) (*models.IrrigationSchedule, error) {
	s := &models.IrrigationSchedule{}
	var schedType, freq, status string
	err := row.Scan(
		&s.ID, &s.UUID, &s.TenantID, &s.FieldID, &s.FarmID, &s.ZoneID,
		&s.Name, &s.Description,
		&schedType, &s.StartTime, &s.EndTime, &s.DurationMinutes,
		&s.WaterQuantityLiters, &s.FlowRateLitersPerHour, &freq,
		&s.SoilMoistureThresholdPct, &s.WeatherAdjusted, &s.CropGrowthStage,
		&s.ControllerID, &status, &s.Version, &s.IsActive,
		&s.CreatedBy, &s.CreatedAt, &s.UpdatedBy, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	s.ScheduleType = models.ScheduleType(schedType)
	s.Frequency = models.Frequency(freq)
	s.Status = models.IrrigationStatus(status)
	return s, nil
}

func (r *irrigationRepo) GetScheduleByUUID(ctx context.Context, uuid string) (*models.IrrigationSchedule, error) {
	tenantID := r.tenantID(ctx)
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, zone_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			controller_id, status, version, is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_schedules
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID)
	s, err := scanSchedule(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", uuid))
		}
		r.log.Errorf("GetScheduleByUUID failed: %v", err)
		return nil, errors.InternalServer("GET_SCHEDULE_FAILED", fmt.Sprintf("failed to get schedule: %v", err))
	}
	return s, nil
}

func (r *irrigationRepo) listSchedules(ctx context.Context, where string, args []any, limit, offset int32) ([]models.IrrigationSchedule, int32, error) {
	if limit <= 0 {
		limit = 20
	}

	countQuery := fmt.Sprintf("SELECT COUNT(*)::int FROM irrigation_schedules WHERE %s AND deleted_at IS NULL", where)
	var total int32
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("LIST_SCHEDULES_FAILED", fmt.Sprintf("failed to count schedules: %v", err))
	}

	dataQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, field_id, farm_id, zone_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			controller_id, status, version, is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_schedules
		WHERE %s AND deleted_at IS NULL
		ORDER BY start_time DESC
		LIMIT $%d OFFSET $%d`, where, len(args)+1, len(args)+2)

	rows, err := r.pool.Query(ctx, dataQuery, append(args, limit, offset)...)
	if err != nil {
		return nil, 0, errors.InternalServer("LIST_SCHEDULES_FAILED", fmt.Sprintf("failed to list schedules: %v", err))
	}
	defer rows.Close()

	var schedules []models.IrrigationSchedule
	for rows.Next() {
		s, err := scanSchedule(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("SCAN_SCHEDULE_FAILED", fmt.Sprintf("failed to scan schedule: %v", err))
		}
		schedules = append(schedules, *s)
	}
	if schedules == nil {
		schedules = []models.IrrigationSchedule{}
	}
	return schedules, total, nil
}

func (r *irrigationRepo) ListSchedulesByField(ctx context.Context, fieldID string, limit, offset int32) ([]models.IrrigationSchedule, int32, error) {
	return r.listSchedules(ctx, "tenant_id = $1 AND field_id = $2", []any{r.tenantID(ctx), fieldID}, limit, offset)
}

func (r *irrigationRepo) ListSchedulesByZone(ctx context.Context, zoneID string, limit, offset int32) ([]models.IrrigationSchedule, int32, error) {
	return r.listSchedules(ctx, "tenant_id = $1 AND zone_id = $2", []any{r.tenantID(ctx), zoneID}, limit, offset)
}

func (r *irrigationRepo) ListSchedulesByFarm(ctx context.Context, farmID string, limit, offset int32) ([]models.IrrigationSchedule, int32, error) {
	return r.listSchedules(ctx, "tenant_id = $1 AND farm_id = $2", []any{r.tenantID(ctx), farmID}, limit, offset)
}

func (r *irrigationRepo) ListSchedulesByStatus(ctx context.Context, status models.IrrigationStatus, limit, offset int32) ([]models.IrrigationSchedule, int32, error) {
	return r.listSchedules(ctx, "tenant_id = $1 AND status = $2", []any{r.tenantID(ctx), string(status)}, limit, offset)
}

func (r *irrigationRepo) UpdateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error) {
	tenantID := r.tenantID(ctx)
	userID := r.userID(ctx)

	query := `
		UPDATE irrigation_schedules SET
			name = $3, description = $4, schedule_type = $5,
			start_time = $6, end_time = $7, duration_minutes = $8,
			water_quantity_liters = $9, flow_rate_liters_per_hour = $10, frequency = $11,
			soil_moisture_threshold_pct = $12, weather_adjusted = $13, crop_growth_stage = $14,
			controller_id = $15, status = $16, version = version + 1,
			updated_by = $17, updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, farm_id, zone_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			controller_id, status, version, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		sched.UUID, tenantID,
		sched.Name, sched.Description, string(sched.ScheduleType),
		sched.StartTime, sched.EndTime, sched.DurationMinutes,
		sched.WaterQuantityLiters, sched.FlowRateLitersPerHour, string(sched.Frequency),
		sched.SoilMoistureThresholdPct, sched.WeatherAdjusted, sched.CropGrowthStage,
		sched.ControllerID, string(sched.Status), userID,
	)

	result, err := scanSchedule(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", sched.UUID))
		}
		r.log.Errorf("UpdateSchedule failed: %v", err)
		return nil, errors.InternalServer("UPDATE_SCHEDULE_FAILED", fmt.Sprintf("failed to update schedule: %v", err))
	}
	return result, nil
}

func (r *irrigationRepo) UpdateScheduleStatus(ctx context.Context, uuid string, status models.IrrigationStatus) (*models.IrrigationSchedule, error) {
	tenantID := r.tenantID(ctx)
	userID := r.userID(ctx)

	query := `
		UPDATE irrigation_schedules SET
			status = $3, version = version + 1, updated_by = $4, updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, farm_id, zone_id, name, description,
			schedule_type, start_time, end_time, duration_minutes,
			water_quantity_liters, flow_rate_liters_per_hour, frequency,
			soil_moisture_threshold_pct, weather_adjusted, crop_growth_stage,
			controller_id, status, version, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID, string(status), userID)
	result, err := scanSchedule(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", uuid))
		}
		r.log.Errorf("UpdateScheduleStatus failed: %v", err)
		return nil, errors.InternalServer("UPDATE_SCHEDULE_FAILED", fmt.Sprintf("failed to update schedule status: %v", err))
	}
	return result, nil
}

func (r *irrigationRepo) DeleteSchedule(ctx context.Context, uuid string) error {
	tenantID := r.tenantID(ctx)
	userID := r.userID(ctx)

	query := `UPDATE irrigation_schedules SET deleted_by = $3, deleted_at = NOW() WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`
	tag, err := r.pool.Exec(ctx, query, uuid, tenantID, userID)
	if err != nil {
		r.log.Errorf("DeleteSchedule failed: %v", err)
		return errors.InternalServer("DELETE_SCHEDULE_FAILED", fmt.Sprintf("failed to delete schedule: %v", err))
	}
	if tag.RowsAffected() == 0 {
		return errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule %s not found", uuid))
	}
	return nil
}

// =========================================================================
// Events
// =========================================================================

func (r *irrigationRepo) CreateEvent(ctx context.Context, evt *models.IrrigationEvent) (*models.IrrigationEvent, error) {
	tenantID := r.tenantID(ctx)
	evt.UUID = ulid.NewString()
	evt.TenantID = tenantID
	evt.IsActive = true
	evt.CreatedBy = r.userID(ctx)
	evt.CreatedAt = time.Now()

	query := `
		INSERT INTO irrigation_events (
			uuid, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason,
			is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
		RETURNING id, uuid, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason,
			is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		evt.UUID, evt.TenantID, evt.ScheduleID, evt.ZoneID, evt.ControllerID,
		string(evt.Status), evt.StartedAt, evt.EndedAt,
		evt.ActualDurationMinutes, evt.ActualWaterLiters,
		evt.SoilMoistureBeforePct, evt.SoilMoistureAfterPct,
		evt.FailureReason, evt.IsActive, evt.CreatedBy, evt.CreatedAt,
	)

	result, err := scanEvent(row)
	if err != nil {
		r.log.Errorf("CreateEvent failed: %v", err)
		return nil, errors.InternalServer("CREATE_EVENT_FAILED", fmt.Sprintf("failed to create event: %v", err))
	}
	return result, nil
}

func scanEvent(row pgx.Row) (*models.IrrigationEvent, error) {
	e := &models.IrrigationEvent{}
	var status string
	err := row.Scan(
		&e.ID, &e.UUID, &e.TenantID, &e.ScheduleID, &e.ZoneID, &e.ControllerID,
		&status, &e.StartedAt, &e.EndedAt,
		&e.ActualDurationMinutes, &e.ActualWaterLiters,
		&e.SoilMoistureBeforePct, &e.SoilMoistureAfterPct,
		&e.FailureReason, &e.IsActive, &e.CreatedBy, &e.CreatedAt, &e.UpdatedBy, &e.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	e.Status = models.IrrigationStatus(status)
	return e, nil
}

func (r *irrigationRepo) GetEventByUUID(ctx context.Context, uuid string) (*models.IrrigationEvent, error) {
	tenantID := r.tenantID(ctx)
	query := `
		SELECT id, uuid, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason,
			is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_events
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID)
	e, err := scanEvent(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("EVENT_NOT_FOUND", fmt.Sprintf("event %s not found", uuid))
		}
		r.log.Errorf("GetEventByUUID failed: %v", err)
		return nil, errors.InternalServer("GET_EVENT_FAILED", fmt.Sprintf("failed to get event: %v", err))
	}
	return e, nil
}

func (r *irrigationRepo) ListEventsByZone(ctx context.Context, zoneID string, limit, offset int32) ([]models.IrrigationEvent, int32, error) {
	tenantID := r.tenantID(ctx)
	if limit <= 0 {
		limit = 20
	}

	countQuery := `SELECT COUNT(*)::int FROM irrigation_events WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL`
	var total int32
	if err := r.pool.QueryRow(ctx, countQuery, tenantID, zoneID).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("LIST_EVENTS_FAILED", fmt.Sprintf("failed to count events: %v", err))
	}

	query := `
		SELECT id, uuid, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason,
			is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_events
		WHERE tenant_id = $1 AND zone_id = $2 AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4`

	rows, err := r.pool.Query(ctx, query, tenantID, zoneID, limit, offset)
	if err != nil {
		return nil, 0, errors.InternalServer("LIST_EVENTS_FAILED", fmt.Sprintf("failed to list events: %v", err))
	}
	defer rows.Close()

	var events []models.IrrigationEvent
	for rows.Next() {
		e, err := scanEvent(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("SCAN_EVENT_FAILED", fmt.Sprintf("failed to scan event: %v", err))
		}
		events = append(events, *e)
	}
	if events == nil {
		events = []models.IrrigationEvent{}
	}
	return events, total, nil
}

func (r *irrigationRepo) ListEventsByTimeRange(ctx context.Context, zoneID string, from, to time.Time, limit, offset int32) ([]models.IrrigationEvent, int32, error) {
	tenantID := r.tenantID(ctx)
	if limit <= 0 {
		limit = 20
	}

	countQuery := `SELECT COUNT(*)::int FROM irrigation_events WHERE tenant_id = $1 AND zone_id = $2 AND started_at >= $3 AND started_at <= $4 AND deleted_at IS NULL`
	var total int32
	if err := r.pool.QueryRow(ctx, countQuery, tenantID, zoneID, from, to).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("LIST_EVENTS_FAILED", fmt.Sprintf("failed to count events: %v", err))
	}

	query := `
		SELECT id, uuid, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason,
			is_active, created_by, created_at, updated_by, updated_at
		FROM irrigation_events
		WHERE tenant_id = $1 AND zone_id = $2 AND started_at >= $3 AND started_at <= $4 AND deleted_at IS NULL
		ORDER BY started_at DESC
		LIMIT $5 OFFSET $6`

	rows, err := r.pool.Query(ctx, query, tenantID, zoneID, from, to, limit, offset)
	if err != nil {
		return nil, 0, errors.InternalServer("LIST_EVENTS_FAILED", fmt.Sprintf("failed to list events: %v", err))
	}
	defer rows.Close()

	var events []models.IrrigationEvent
	for rows.Next() {
		e, err := scanEvent(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("SCAN_EVENT_FAILED", fmt.Sprintf("failed to scan event: %v", err))
		}
		events = append(events, *e)
	}
	if events == nil {
		events = []models.IrrigationEvent{}
	}
	return events, total, nil
}

func (r *irrigationRepo) UpdateEvent(ctx context.Context, evt *models.IrrigationEvent) (*models.IrrigationEvent, error) {
	tenantID := r.tenantID(ctx)
	userID := r.userID(ctx)

	query := `
		UPDATE irrigation_events SET
			status = $3, ended_at = $4, actual_duration_minutes = $5,
			actual_water_liters = $6, soil_moisture_after_pct = $7,
			failure_reason = $8, updated_by = $9, updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, schedule_id, zone_id, controller_id, status,
			started_at, ended_at, actual_duration_minutes, actual_water_liters,
			soil_moisture_before_pct, soil_moisture_after_pct, failure_reason,
			is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		evt.UUID, tenantID,
		string(evt.Status), evt.EndedAt, evt.ActualDurationMinutes,
		evt.ActualWaterLiters, evt.SoilMoistureAfterPct,
		evt.FailureReason, userID,
	)

	result, err := scanEvent(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("EVENT_NOT_FOUND", fmt.Sprintf("event %s not found", evt.UUID))
		}
		r.log.Errorf("UpdateEvent failed: %v", err)
		return nil, errors.InternalServer("UPDATE_EVENT_FAILED", fmt.Sprintf("failed to update event: %v", err))
	}
	return result, nil
}

// =========================================================================
// Decisions
// =========================================================================

func (r *irrigationRepo) CreateDecision(ctx context.Context, dec *models.IrrigationDecision) (*models.IrrigationDecision, error) {
	tenantID := r.tenantID(ctx)
	dec.UUID = ulid.NewString()
	dec.TenantID = tenantID
	dec.IsActive = true
	dec.CreatedBy = r.userID(ctx)
	dec.CreatedAt = time.Now()
	if dec.DecidedAt.IsZero() {
		dec.DecidedAt = time.Now()
	}

	query := `
		INSERT INTO irrigation_decisions (
			uuid, tenant_id, zone_id, field_id, schedule_id,
			input_soil_moisture, input_temperature, input_humidity,
			input_rainfall_forecast_mm, input_wind_speed, input_crop_type,
			input_growth_stage, input_evapotranspiration_mm,
			output_should_irrigate, output_water_quantity_liters,
			output_duration_minutes, output_optimal_time, output_reasoning,
			output_confidence_score, decided_at, applied,
			is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24)
		RETURNING id, uuid, tenant_id, zone_id, field_id, schedule_id,
			input_soil_moisture, input_temperature, input_humidity,
			input_rainfall_forecast_mm, input_wind_speed, input_crop_type,
			input_growth_stage, input_evapotranspiration_mm,
			output_should_irrigate, output_water_quantity_liters,
			output_duration_minutes, output_optimal_time, output_reasoning,
			output_confidence_score, decided_at, applied,
			is_active, created_by, created_at`

	row := r.pool.QueryRow(ctx, query,
		dec.UUID, dec.TenantID, dec.ZoneID, dec.FieldID, dec.ScheduleID,
		dec.Inputs.SoilMoisture, dec.Inputs.Temperature, dec.Inputs.Humidity,
		dec.Inputs.RainfallForecastMM, dec.Inputs.WindSpeed, dec.Inputs.CropType,
		dec.Inputs.GrowthStage, dec.Inputs.EvapotranspirationMM,
		dec.Output.ShouldIrrigate, dec.Output.WaterQuantityLiters,
		dec.Output.DurationMinutes, dec.Output.OptimalTime, dec.Output.Reasoning,
		dec.Output.ConfidenceScore, dec.DecidedAt, dec.Applied,
		dec.IsActive, dec.CreatedBy, dec.CreatedAt,
	)

	result := &models.IrrigationDecision{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.ZoneID, &result.FieldID, &result.ScheduleID,
		&result.Inputs.SoilMoisture, &result.Inputs.Temperature, &result.Inputs.Humidity,
		&result.Inputs.RainfallForecastMM, &result.Inputs.WindSpeed, &result.Inputs.CropType,
		&result.Inputs.GrowthStage, &result.Inputs.EvapotranspirationMM,
		&result.Output.ShouldIrrigate, &result.Output.WaterQuantityLiters,
		&result.Output.DurationMinutes, &result.Output.OptimalTime, &result.Output.Reasoning,
		&result.Output.ConfidenceScore, &result.DecidedAt, &result.Applied,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		r.log.Errorf("CreateDecision failed: %v", err)
		return nil, errors.InternalServer("CREATE_DECISION_FAILED", fmt.Sprintf("failed to create decision: %v", err))
	}
	return result, nil
}

func (r *irrigationRepo) MarkDecisionApplied(ctx context.Context, uuid string) (*models.IrrigationDecision, error) {
	tenantID := r.tenantID(ctx)
	userID := r.userID(ctx)

	query := `
		UPDATE irrigation_decisions SET applied = TRUE, updated_by = $3, updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, zone_id, field_id, schedule_id,
			input_soil_moisture, input_temperature, input_humidity,
			input_rainfall_forecast_mm, input_wind_speed, input_crop_type,
			input_growth_stage, input_evapotranspiration_mm,
			output_should_irrigate, output_water_quantity_liters,
			output_duration_minutes, output_optimal_time, output_reasoning,
			output_confidence_score, decided_at, applied,
			is_active, created_by, created_at`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID, userID)

	result := &models.IrrigationDecision{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.ZoneID, &result.FieldID, &result.ScheduleID,
		&result.Inputs.SoilMoisture, &result.Inputs.Temperature, &result.Inputs.Humidity,
		&result.Inputs.RainfallForecastMM, &result.Inputs.WindSpeed, &result.Inputs.CropType,
		&result.Inputs.GrowthStage, &result.Inputs.EvapotranspirationMM,
		&result.Output.ShouldIrrigate, &result.Output.WaterQuantityLiters,
		&result.Output.DurationMinutes, &result.Output.OptimalTime, &result.Output.Reasoning,
		&result.Output.ConfidenceScore, &result.DecidedAt, &result.Applied,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("DECISION_NOT_FOUND", fmt.Sprintf("decision %s not found", uuid))
		}
		r.log.Errorf("MarkDecisionApplied failed: %v", err)
		return nil, errors.InternalServer("MARK_DECISION_FAILED", fmt.Sprintf("failed to mark decision applied: %v", err))
	}
	return result, nil
}

// =========================================================================
// Water Usage
// =========================================================================

func (r *irrigationRepo) CreateWaterUsageLog(ctx context.Context, wl *models.WaterUsageLog) (*models.WaterUsageLog, error) {
	tenantID := r.tenantID(ctx)
	wl.UUID = ulid.NewString()
	wl.TenantID = tenantID
	wl.IsActive = true
	wl.CreatedBy = r.userID(ctx)
	wl.CreatedAt = time.Now()
	if wl.RecordedAt.IsZero() {
		wl.RecordedAt = time.Now()
	}

	query := `
		INSERT INTO water_usage_logs (
			uuid, tenant_id, zone_id, controller_id, water_liters,
			recorded_at, period_start, period_end, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
		RETURNING id, uuid, tenant_id, zone_id, controller_id, water_liters,
			recorded_at, period_start, period_end, is_active, created_by, created_at`

	row := r.pool.QueryRow(ctx, query,
		wl.UUID, wl.TenantID, wl.ZoneID, wl.ControllerID, wl.WaterLiters,
		wl.RecordedAt, wl.PeriodStart, wl.PeriodEnd,
		wl.IsActive, wl.CreatedBy, wl.CreatedAt,
	)

	result := &models.WaterUsageLog{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.ZoneID, &result.ControllerID,
		&result.WaterLiters, &result.RecordedAt, &result.PeriodStart, &result.PeriodEnd,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		r.log.Errorf("CreateWaterUsageLog failed: %v", err)
		return nil, errors.InternalServer("CREATE_USAGE_LOG_FAILED", fmt.Sprintf("failed to create water usage log: %v", err))
	}
	return result, nil
}

func (r *irrigationRepo) ListWaterUsageLogs(ctx context.Context, zoneID string, from, to time.Time) ([]models.WaterUsageLog, error) {
	tenantID := r.tenantID(ctx)

	query := `
		SELECT id, uuid, tenant_id, zone_id, controller_id, water_liters,
			recorded_at, period_start, period_end, is_active, created_by, created_at
		FROM water_usage_logs
		WHERE tenant_id = $1 AND zone_id = $2 AND period_start >= $3 AND period_end <= $4 AND deleted_at IS NULL
		ORDER BY recorded_at DESC`

	rows, err := r.pool.Query(ctx, query, tenantID, zoneID, from, to)
	if err != nil {
		r.log.Errorf("ListWaterUsageLogs failed: %v", err)
		return nil, errors.InternalServer("LIST_USAGE_LOGS_FAILED", fmt.Sprintf("failed to list water usage logs: %v", err))
	}
	defer rows.Close()

	var logs []models.WaterUsageLog
	for rows.Next() {
		var wl models.WaterUsageLog
		if err := rows.Scan(
			&wl.ID, &wl.UUID, &wl.TenantID, &wl.ZoneID, &wl.ControllerID,
			&wl.WaterLiters, &wl.RecordedAt, &wl.PeriodStart, &wl.PeriodEnd,
			&wl.IsActive, &wl.CreatedBy, &wl.CreatedAt,
		); err != nil {
			return nil, errors.InternalServer("SCAN_USAGE_LOG_FAILED", fmt.Sprintf("failed to scan water usage log: %v", err))
		}
		logs = append(logs, wl)
	}
	if logs == nil {
		logs = []models.WaterUsageLog{}
	}
	return logs, nil
}

func (r *irrigationRepo) SumWaterUsageByZone(ctx context.Context, zoneID string, from, to time.Time) (float64, error) {
	tenantID := r.tenantID(ctx)

	query := `
		SELECT COALESCE(SUM(water_liters), 0)::double precision
		FROM water_usage_logs
		WHERE tenant_id = $1 AND zone_id = $2 AND period_start >= $3 AND period_end <= $4 AND deleted_at IS NULL`

	var total float64
	if err := r.pool.QueryRow(ctx, query, tenantID, zoneID, from, to).Scan(&total); err != nil {
		r.log.Errorf("SumWaterUsageByZone failed: %v", err)
		return 0, errors.InternalServer("SUM_USAGE_FAILED", fmt.Sprintf("failed to sum water usage: %v", err))
	}
	return total, nil
}
