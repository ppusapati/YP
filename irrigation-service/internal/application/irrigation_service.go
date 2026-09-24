// Package application contains the irrigation-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	eventsdomain "p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

const (
	serviceName           = "irrigation-service"
	eventTopic            = "samavaya.agriculture.irrigation.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type irrigationService struct {
	repo          outbound.IrrigationRepository
	pub           outbound.EventPublisher
	fieldClient   outbound.FieldClient
	farmClient    outbound.FarmClient
	weatherClient outbound.WeatherClient
	waterClient   outbound.WaterBalanceClient
	// actuator is what turns a decision into a valve movement. Optional, and
	// its absence is a refusal rather than a silent fallback to recording runs
	// that did not happen.
	actuator *Actuator
	pool     *pgxpool.Pool
	log      *p9log.Helper
}

// WithActuator enables real actuation.
//
// An option rather than a constructor argument to match WithWaterBalance, and
// because a deployment with no controllers is a legitimate one: it keeps
// schedules, decisions and history, and refuses to claim it opened a valve.
func (s *irrigationService) WithActuator(a *Actuator) *irrigationService {
	s.actuator = a
	return s
}

// NewIrrigationService creates a new application-layer IrrigationService.
func NewIrrigationService(
	repo outbound.IrrigationRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	farmClient outbound.FarmClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) *irrigationService {
	return &irrigationService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		farmClient:  farmClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "IrrigationService")),
	}
}

func (s *irrigationService) CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.Name == "" {
		return nil, errors.BadRequest("INVALID_NAME", "name is required")
	}
	if userID == "" {
		userID = "system"
	}

	nameExists, err := s.repo.CheckIrrigationNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("IRRIGATION_NAME_EXISTS", fmt.Sprintf("irrigation with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.IrrigationStatusActive

	created, err := s.repo.CreateIrrigation(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.created", created.ID, map[string]interface{}{
		"irrigation_id": created.ID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "irrigation created", "uuid", created.ID)
	return created, nil
}

func (s *irrigationService) GetIrrigation(ctx context.Context, uuid string) (*domain.Irrigation, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "irrigation ID is required")
	}
	return s.repo.GetIrrigationByUUID(ctx, uuid, tenantID)
}

func (s *irrigationService) ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}
	return s.repo.ListIrrigations(ctx, params)
}

func (s *irrigationService) UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.ID == "" {
		return nil, errors.BadRequest("MISSING_ID", "irrigation ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckIrrigationExists(ctx, entity.ID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", entity.ID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateIrrigation(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.updated", updated.ID, map[string]interface{}{
		"irrigation_id": updated.ID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *irrigationService) DeleteIrrigation(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "irrigation ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckIrrigationExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", uuid))
	}

	if err := s.repo.DeleteIrrigation(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.irrigation.deleted", uuid, map[string]interface{}{
		"irrigation_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *irrigationService) CreateZone(ctx context.Context, zone *domain.IrrigationZone) (*domain.IrrigationZone, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}
	if zone.Name == "" {
		return nil, errors.BadRequest("INVALID_ZONE_NAME", "zone name is required")
	}
	if zone.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if zone.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if zone.AreaHectares < 0 {
		return nil, errors.BadRequest("INVALID_AREA", "area_hectares must be non-negative")
	}
	if zone.Latitude < -90 || zone.Latitude > 90 {
		return nil, errors.BadRequest("INVALID_LATITUDE", "latitude must be between -90 and 90")
	}
	if zone.Longitude < -180 || zone.Longitude > 180 {
		return nil, errors.BadRequest("INVALID_LONGITUDE", "longitude must be between -180 and 180")
	}

	zone.TenantID = tenantID
	zone.CreatedBy = userID

	created, err := s.repo.CreateZone(ctx, zone)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.zone.created", created.ID, map[string]interface{}{
		"zone_id": created.ID, "tenant_id": tenantID,
	})
	return created, nil
}

func (s *irrigationService) GetZone(ctx context.Context, uuid string) (*domain.IrrigationZone, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone ID is required")
	}
	return s.repo.GetZoneByUUID(ctx, uuid)
}

func (s *irrigationService) ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	return s.repo.ListZonesByField(ctx, fieldID, clampPageSize(pageSize), offset)
}

func (s *irrigationService) ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, 0, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	return s.repo.ListZonesByFarm(ctx, farmID, clampPageSize(pageSize), offset)
}

func (s *irrigationService) CreateController(ctx context.Context, ctrl *domain.WaterController) (*domain.WaterController, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}
	if ctrl.Name == "" {
		return nil, errors.BadRequest("INVALID_CONTROLLER_NAME", "controller name is required")
	}
	if ctrl.ZoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}
	if ctrl.Endpoint == "" {
		return nil, errors.BadRequest("MISSING_ENDPOINT", "endpoint is required")
	}
	if ctrl.MaxFlowRateLitersPerHour <= 0 {
		return nil, errors.BadRequest("INVALID_FLOW_RATE", "max_flow_rate_liters_per_hour must be positive")
	}

	_, err := s.repo.GetZoneByUUID(ctx, ctrl.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", ctrl.ZoneID))
	}

	ctrl.TenantID = tenantID
	ctrl.CreatedBy = userID
	ctrl.Status = domain.ControllerStatusOffline

	return s.repo.CreateController(ctx, ctrl)
}

func (s *irrigationService) GetController(ctx context.Context, uuid string) (*domain.WaterController, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_CONTROLLER_ID", "controller ID is required")
	}
	return s.repo.GetControllerByUUID(ctx, uuid)
}

func (s *irrigationService) ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.WaterController, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if zoneID == "" {
		return nil, 0, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}
	return s.repo.ListControllersByZone(ctx, zoneID, clampPageSize(pageSize), offset)
}

func (s *irrigationService) UpdateControllerStatus(ctx context.Context, uuid string, status domain.ControllerStatus) (*domain.WaterController, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_CONTROLLER_ID", "controller ID is required")
	}
	if status == "" {
		return nil, errors.BadRequest("MISSING_STATUS", "controller status is required")
	}
	_, err := s.repo.GetControllerByUUID(ctx, uuid)
	if err != nil {
		return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller not found: %s", uuid))
	}
	return s.repo.UpdateControllerStatus(ctx, uuid, status)
}

func (s *irrigationService) CreateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}
	if sched.Name == "" {
		return nil, errors.BadRequest("INVALID_SCHEDULE_NAME", "schedule name is required")
	}
	if sched.ZoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}
	if sched.DurationMinutes <= 0 {
		return nil, errors.BadRequest("INVALID_DURATION", "duration_minutes must be positive")
	}
	if sched.StartTime.IsZero() {
		return nil, errors.BadRequest("MISSING_START_TIME", "start_time is required")
	}
	if sched.WaterQuantityLiters < 0 {
		return nil, errors.BadRequest("INVALID_WATER_QUANTITY", "water_quantity_liters must be non-negative")
	}

	_, err := s.repo.GetZoneByUUID(ctx, sched.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", sched.ZoneID))
	}

	sched.TenantID = tenantID
	sched.CreatedBy = userID
	sched.Status = domain.IrrigationStatusScheduled

	created, err := s.repo.CreateSchedule(ctx, sched)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.schedule.created", created.ID, map[string]interface{}{
		"schedule_id": created.ID, "tenant_id": tenantID,
	})
	return created, nil
}

func (s *irrigationService) GetSchedule(ctx context.Context, uuid string) (*domain.IrrigationSchedule, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}
	return s.repo.GetScheduleByUUID(ctx, uuid)
}

func (s *irrigationService) ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if zoneID == "" {
		return nil, 0, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}
	return s.repo.ListSchedulesByZone(ctx, zoneID, clampPageSize(pageSize), offset)
}

func (s *irrigationService) ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	return s.repo.ListSchedulesByField(ctx, fieldID, clampPageSize(pageSize), offset)
}

func (s *irrigationService) UpdateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sched.ID == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	existing, err := s.repo.GetScheduleByUUID(ctx, sched.ID)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", sched.ID))
	}
	if sched.DurationMinutes < 0 {
		return nil, errors.BadRequest("INVALID_DURATION", "duration_minutes must be non-negative")
	}
	if sched.WaterQuantityLiters < 0 {
		return nil, errors.BadRequest("INVALID_WATER_QUANTITY", "water_quantity_liters must be non-negative")
	}

	sched.TenantID = tenantID
	updatedBy := userID
	sched.UpdatedBy = &updatedBy

	return s.repo.UpdateSchedule(ctx, sched)
}

func (s *irrigationService) CancelSchedule(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	existing, err := s.repo.GetScheduleByUUID(ctx, uuid)
	if err != nil {
		return err
	}
	if existing == nil {
		return errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", uuid))
	}
	if existing.Status == domain.IrrigationStatusCancelled {
		return errors.BadRequest("ALREADY_CANCELLED", fmt.Sprintf("schedule %s is already cancelled", uuid))
	}
	if existing.Status == domain.IrrigationStatusCompleted {
		return errors.BadRequest("ALREADY_COMPLETED", fmt.Sprintf("schedule %s is already completed", uuid))
	}

	_, err = s.repo.UpdateScheduleStatus(ctx, uuid, domain.IrrigationStatusCancelled)
	if err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.irrigation.schedule.cancelled", uuid, map[string]interface{}{
		"schedule_id": uuid, "tenant_id": tenantID, "cancelled_by": userID,
	})
	return nil
}

func (s *irrigationService) TriggerIrrigation(ctx context.Context, scheduleID string) (*domain.IrrigationEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if scheduleID == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule_id is required")
	}

	schedule, err := s.repo.GetScheduleByUUID(ctx, scheduleID)
	if err != nil {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", scheduleID))
	}

	// The valve first, the record second, and that order is the change.
	//
	// This used to flip the schedule to ACTIVE, write an event row and return
	// success without dialling anything: "turn on zone 3" was a database entry
	// rather than a valve movement, and a farmer reading their irrigation
	// history saw runs that never happened. The stored controller status was
	// consulted, which is a cached opinion something has to remember to
	// revise, and only when the schedule happened to name a controller.
	//
	// Now the actuator runs every interlock — automation, already running,
	// maximum run, minimum rest, daily cap, controller reachability — records
	// the command before sending it, and sends it. An event row is written
	// only once a controller has taken the command, because the row is a
	// record of water going on a field.
	if s.actuator == nil {
		return nil, errors.ServiceUnavailable("ACTUATOR_UNAVAILABLE",
			"this deployment has no controller client configured, so irrigation cannot be started")
	}

	userID := p9context.UserID(ctx)
	if userID == "" {
		userID = "system"
	}

	cmd := &domain.IrrigationCommand{
		ID:              ulid.NewString(),
		TenantID:        tenantID,
		ZoneID:          schedule.ZoneID,
		Kind:            domain.CommandStart,
		DurationMinutes: schedule.DurationMinutes,
		LitersRequested: schedule.WaterQuantityLiters,
		IssuedBy:        userID,
		Reason:          fmt.Sprintf("schedule %s triggered", scheduleID),
	}
	if _, err := s.actuator.Actuate(ctx, cmd); err != nil {
		// Returned as-is. The actuator's refusals already name the interlock
		// that stopped the command — INTERLOCK_MIN_REST, INTERLOCK_MAX_DAILY —
		// and flattening them into one message would cost an operator the
		// difference between a safety limit and a fault.
		return nil, err
	}

	if _, err := s.repo.UpdateScheduleStatus(ctx, scheduleID, domain.IrrigationStatusActive); err != nil {
		return nil, err
	}
	return s.recordRun(ctx, tenantID, schedule, cmd)
}

// ApplyMoistureReading is the sensor leg: a measurement arrives and, if the
// zone has opted in and every interlock agrees, a valve opens.
//
// This is the part of the platform that acts on a farm without anybody
// present, so the shape is again mostly refusal. Of everything that arrives
// here, the overwhelming majority ends in no action: a reading from a sensor
// that is not a moisture probe, a zone with no adaptive schedule, soil that is
// wet enough, a zone that irrigated an hour ago. None of those is an error and
// none is logged as one.
//
// Errors are returned only when a retry could help — a database blip mid-scan.
// A malformed or unusable reading returns nil: Kafka would redeliver it for
// ever, and it can never succeed.
func (s *irrigationService) ApplyMoistureReading(ctx context.Context, reading domain.MoistureReading) error {
	if err := reading.UsableForActuation(); err != nil {
		// Logged at info, not warn: an irrigation service sees every sensor
		// reading on the farm and most of them are temperature and humidity.
		// A warn per reading would bury the ones that matter.
		s.log.Infow("msg", "reading not acted on", "sensor_id", reading.SensorID, "reason", err.Error())
		return nil
	}
	if s.actuator == nil {
		// Nothing to open a valve with. Not an error: blocking the partition
		// over a deployment that has no controllers would stop every other
		// consumer on this topic too.
		s.log.Infow("msg", "no controller client configured; moisture reading not acted on",
			"sensor_id", reading.SensorID, "field_id", reading.FieldID)
		return nil
	}

	ctx = s.systemContext(ctx, reading.TenantID)

	zones, _, err := s.repo.ListZonesByField(ctx, reading.FieldID, maxPageSize, 0)
	if err != nil {
		// Returned, so the consumer retries: a database blip must not silently
		// skip an irrigation the field needed.
		return fmt.Errorf("ApplyMoistureReading: list zones for field %s: %w", reading.FieldID, err)
	}
	if len(zones) == 0 {
		return nil
	}

	var failures int
	for i := range zones {
		zone := &zones[i]
		acted, err := s.applyReadingToZone(ctx, reading, zone)
		if err != nil {
			// One zone's controller being unreachable must not strand the
			// others: the next zone may be on a different panel entirely.
			failures++
			s.log.Warnw("msg", "could not apply a moisture reading to a zone",
				"zone_id", zone.ID, "sensor_id", reading.SensorID, "error", err)
			continue
		}
		if acted {
			s.log.Infow("msg", "irrigation started from a soil moisture reading",
				"zone_id", zone.ID, "sensor_id", reading.SensorID,
				"moisture_pct", reading.Percent)
		}
	}

	// Every zone failing is a fault on this side rather than a run of
	// coincidences, and reporting success would have Kafka commit the offset
	// over a reading that watered nothing.
	if failures == len(zones) {
		return fmt.Errorf("ApplyMoistureReading: all %d zones on field %s failed", failures, reading.FieldID)
	}
	return nil
}

// applyReadingToZone acts on one zone, and reports whether it started a run.
func (s *irrigationService) applyReadingToZone(
	ctx context.Context,
	reading domain.MoistureReading,
	zone *domain.IrrigationZone,
) (bool, error) {
	schedules, _, err := s.repo.ListSchedulesByZone(ctx, zone.ID, maxPageSize, 0)
	if err != nil {
		return false, fmt.Errorf("list schedules for zone %s: %w", zone.ID, err)
	}

	schedule, err := domain.AdaptiveSchedule(schedules)
	if err != nil {
		// Ambiguous configuration. Logged and skipped rather than returned:
		// a retry produces the same ambiguity for ever, and the fix is a
		// farmer editing a schedule.
		s.log.Warnw("msg", "zone not watered from its sensor", "zone_id", zone.ID, "error", err)
		return false, nil
	}
	if schedule == nil {
		// The zone has not opted in. The common case, and not worth a line
		// per reading.
		return false, nil
	}

	// Both sides of this comparison are percentages on 0..100 — the reading
	// because sensor-service records soil moisture that way, the threshold
	// because the column is SoilMoistureThresholdPct. They are checked
	// against each other by a test, because the mistake is not a crash: a
	// fraction on one side reads as bone-dry soil and waters a saturated
	// field on every reading that arrives.
	cmd, err := s.actuator.ActuateFromReading(ctx,
		reading.TenantID, zone.ID,
		reading.Percent, schedule.SoilMoistureThresholdPct,
		reading.RecordedAt, schedule.DurationMinutes)
	if err != nil {
		return false, err
	}
	if cmd == nil {
		// No action called for: wet enough, too stale, or an interlock
		// declined. ActuateFromReading reports all three as (nil, nil)
		// because none of them is a failure.
		return false, nil
	}

	// The run is written even though nobody asked for it, and especially
	// because nobody did: ZoneState derives the rest interval and the daily
	// cap from these rows, so an automatic run that actuated without
	// recording one would be invisible to the interlocks meant to bound it.
	// A flapping sensor could then water a field all day inside a limit that
	// was counting nothing.
	//
	// The schedule's status is deliberately not touched. An adaptive schedule
	// is a standing rule, not a one-shot; flipping it to ACTIVE the way
	// TriggerIrrigation does would take the rule out of service after its
	// first firing.
	if _, err := s.recordRun(ctx, reading.TenantID, schedule, cmd); err != nil {
		// The valve is open. Failing to record that is bad, and it is not a
		// reason to report failure upward and have the reading redelivered —
		// which would try to open the same valve again.
		s.log.Errorw("msg", "irrigation started but the run could not be recorded",
			"zone_id", zone.ID, "command_id", cmd.ID, "error", err)
	}
	return true, nil
}

// systemContext scopes a consumer-initiated operation to a tenant.
//
// A consumer has no request to inherit one from, so without this every query
// runs unscoped and row-level security returns nothing — which looks like a
// field with no irrigation zones rather than a failure.
func (s *irrigationService) systemContext(ctx context.Context, tenantID string) context.Context {
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	return p9context.NewUserContext(ctx, p9context.UserContext{
		UserID:   "system",
		TenantID: tenantID,
	})
}

// recordRun writes the run and announces it, once a controller has taken the
// command.
//
// Shared by the operator's TriggerIrrigation and the sensor-driven path, and
// sharing it is not just tidiness: the run row is what ZoneState reads to
// derive minutes-run-today and the rest interval. An automatic run that
// actuated without writing one would be invisible to the very interlocks meant
// to bound it — the daily cap would never engage, and a flapping sensor could
// water a field all day inside a limit that was counting nothing.
func (s *irrigationService) recordRun(
	ctx context.Context,
	tenantID string,
	schedule *domain.IrrigationSchedule,
	cmd *domain.IrrigationCommand,
) (*domain.IrrigationEvent, error) {
	now := time.Now()

	evt := &domain.IrrigationEvent{
		TenantID:     tenantID,
		ScheduleID:   schedule.ID,
		ZoneID:       schedule.ZoneID,
		ControllerID: cmd.ControllerID,
		Status:       domain.IrrigationStatusActive,
		StartedAt:    &now,
		// Deliberately not pre-filled with the schedule's figures. They used
		// to be copied into ActualDurationMinutes and ActualWaterLiters at
		// start time — before water could have flowed — so a plan was stored
		// in a column named "actual" and nothing ever revised it.
		// StopIrrigation now fills them in from the run that happened.
	}

	createdEvent, err := s.repo.CreateEvent(ctx, evt)
	if err != nil {
		return nil, err
	}

	fieldID, farmID := s.locate(ctx, schedule)

	// The payload names the field, and that is the whole point of it. Water
	// application is an input an organic or GAP audit asks about, and
	// traceability's handler keys the batch off `field_id` — so an event
	// without one is logged as unrecordable and dropped. This used to carry
	// `{event_id, schedule_id, tenant_id}` and nothing else, so every
	// irrigation on every field took that branch.
	//
	// The water figure is `planned_`, not `actual_`, because nothing here has
	// measured anything: the quantity is the schedule's, and no transport in
	// this service meters water. Publishing it as an actual would put a plan
	// into a compliance record as a measurement.
	s.emitEvent(ctx, string(eventsdomain.EventTypeIrrigationTriggered), createdEvent.ID, map[string]interface{}{
		"event_id":                 createdEvent.ID,
		"schedule_id":              schedule.ID,
		"tenant_id":                tenantID,
		"zone_id":                  schedule.ZoneID,
		"field_id":                 fieldID,
		"farm_id":                  farmID,
		"controller_id":            cmd.ControllerID,
		"started_at":               now.UTC().Format(time.RFC3339),
		"issued_by":                cmd.IssuedBy,
		"planned_water_liters":     schedule.WaterQuantityLiters,
		"planned_duration_minutes": schedule.DurationMinutes,
	})
	return createdEvent, nil
}

// locate resolves the field and farm a scheduled run applies to.
//
// The schedule's own field_id and farm_id are nullable — CreateSchedule
// requires neither — while its zone_id is required and validated to exist, and
// CreateZone rejects a zone without a field and a farm. So the zone is the
// reliable answer and the schedule's columns are the override, used when set
// because a schedule naming a field is the more specific statement.
//
// A failed zone lookup is logged and skipped rather than returned: the run has
// already started and the event row is already written, so refusing to publish
// would lose the record of a run that happened.
func (s *irrigationService) locate(ctx context.Context, schedule *domain.IrrigationSchedule) (fieldID, farmID string) {
	fieldID, farmID = schedule.FieldID, schedule.FarmID
	if fieldID != "" && farmID != "" {
		return fieldID, farmID
	}
	if schedule.ZoneID == "" {
		return fieldID, farmID
	}

	zone, err := s.repo.GetZoneByUUID(ctx, schedule.ZoneID)
	if err != nil || zone == nil {
		s.log.Warnw("msg", "could not resolve the zone's field; the run will not reach traceability",
			"schedule_id", schedule.ID, "zone_id", schedule.ZoneID, "error", err)
		return fieldID, farmID
	}
	if fieldID == "" {
		fieldID = zone.FieldID
	}
	if farmID == "" {
		farmID = zone.FarmID
	}
	return fieldID, farmID
}

// StopIrrigation closes the valve for a run, then closes the run.
//
// The valve first. Cancelling the schedule was what this used to do and it
// stops nothing: a schedule is a plan, and a cancelled plan does not reach the
// panel that currently has water flowing. A stop is never refused by an
// interlock — every guard in this service applies to starting water, because
// the one thing worse than a valve that will not open is a valve that will not
// close.
func (s *irrigationService) StopIrrigation(ctx context.Context, eventID, reason string) (*domain.IrrigationEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if eventID == "" {
		return nil, errors.BadRequest("MISSING_EVENT_ID", "event_id is required")
	}
	userID := p9context.UserID(ctx)
	if userID == "" {
		userID = "system"
	}

	evt, err := s.repo.GetEventByUUID(ctx, eventID)
	if err != nil {
		return nil, err
	}
	if evt.EndedAt != nil {
		// Already closed. Idempotent rather than an error: an operator
		// pressing stop twice on a slow connection means stop.
		return evt, nil
	}

	if s.actuator == nil {
		return nil, errors.ServiceUnavailable("ACTUATOR_UNAVAILABLE",
			"this deployment has no controller client configured, so the valve cannot be closed from here")
	}
	if reason == "" {
		reason = "stop requested"
	}
	if _, err := s.actuator.Stop(ctx, tenantID, evt.ZoneID, userID, reason); err != nil {
		// Not swallowed, and the run is left open. Marking it finished while
		// the valve may still be open is the one outcome that leaves nobody
		// looking for the water.
		s.log.Errorw("msg", "could not close the valve", "event_id", eventID,
			"zone_id", evt.ZoneID, "error", err)
		return nil, err
	}

	now := time.Now()
	evt.EndedAt = &now
	evt.Status = domain.IrrigationStatusCompleted
	if evt.StartedAt != nil {
		// Measured, not planned: wall clock between the start and the stop.
		// This is the only figure on the row that anything has observed.
		evt.ActualDurationMinutes = int32(now.Sub(*evt.StartedAt) / time.Minute)
	}
	// ActualWaterLiters is deliberately left alone. Multiplying the elapsed
	// minutes by a controller's nameplate flow rate would produce a number
	// that looks like a meter reading and is not one; a blocked line or a
	// closed manual valve upstream delivers nothing at the same nameplate
	// rate. It stays zero until something meters the water.

	updated, err := s.repo.UpdateEvent(ctx, evt)
	if err != nil {
		return nil, err
	}

	// The schedule is cancelled after the valve is shut, not instead of it.
	if evt.ScheduleID != "" {
		if err := s.CancelSchedule(ctx, evt.ScheduleID); err != nil {
			// Logged and swallowed: the water is off and the run is recorded,
			// which is what the caller asked for. A schedule left ACTIVE is a
			// tidiness problem, not a valve.
			s.log.Warnw("msg", "valve closed but the schedule could not be cancelled",
				"event_id", eventID, "schedule_id", evt.ScheduleID, "error", err)
		}
	}

	s.emitEvent(ctx, string(eventsdomain.EventTypeIrrigationStopped), updated.ID, map[string]interface{}{
		"event_id":                updated.ID,
		"schedule_id":             updated.ScheduleID,
		"tenant_id":               tenantID,
		"zone_id":                 updated.ZoneID,
		"ended_at":                now.UTC().Format(time.RFC3339),
		"actual_duration_minutes": updated.ActualDurationMinutes,
		"stopped_by":              userID,
		"reason":                  reason,
	})
	return updated, nil
}

func (s *irrigationService) GetEvent(ctx context.Context, uuid string) (*domain.IrrigationEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_EVENT_ID", "event ID is required")
	}
	return s.repo.GetEventByUUID(ctx, uuid)
}

func (s *irrigationService) ListEventsBySchedule(ctx context.Context, scheduleID string, pageSize, offset int32) ([]domain.IrrigationEvent, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if scheduleID == "" {
		return nil, 0, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule_id is required")
	}
	schedule, err := s.repo.GetScheduleByUUID(ctx, scheduleID)
	if err != nil {
		return nil, 0, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", scheduleID))
	}
	return s.repo.ListEventsByZone(ctx, schedule.ZoneID, clampPageSize(pageSize), offset)
}

func (s *irrigationService) RequestDecision(ctx context.Context, decision *domain.IrrigationDecision) (*domain.IrrigationDecision, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if decision.ZoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}

	zone, err := s.repo.GetZoneByUUID(ctx, decision.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", decision.ZoneID))
	}
	if decision.FieldID == "" {
		decision.FieldID = zone.FieldID
	}
	if decision.Inputs.CropType == "" {
		decision.Inputs.CropType = zone.CropType
	}
	if decision.Inputs.GrowthStage == "" {
		decision.Inputs.GrowthStage = zone.CropGrowthStage
	}

	output, ok := s.waterBalanceDecision(ctx, zone, decision)
	if !ok {
		output = computeIrrigationDecision(decision.Inputs)
	}
	decision.TenantID = tenantID
	decision.Output = output
	decision.DecidedAt = time.Now()
	decision.Applied = false

	return s.repo.CreateDecision(ctx, decision)
}

// WithWaterBalance enables ET0-driven scheduling through weather-service and
// the AI gateway water-flow simulation. Either client missing keeps the
// threshold heuristic.
func (s *irrigationService) WithWaterBalance(weather outbound.WeatherClient, water outbound.WaterBalanceClient) *irrigationService {
	s.weatherClient = weather
	s.waterClient = water
	return s
}

// waterBalanceDecision runs the FAO-56 water balance for the zone's field. It
// returns ok=false whenever an input is unavailable so the caller falls back.
func (s *irrigationService) waterBalanceDecision(ctx context.Context, zone *domain.IrrigationZone, decision *domain.IrrigationDecision) (domain.DecisionOutput, bool) {
	if s.weatherClient == nil || s.waterClient == nil || decision.FieldID == "" {
		return domain.DecisionOutput{}, false
	}
	weather, err := s.weatherClient.FieldWeather(ctx, decision.FieldID, 7, 7)
	if err != nil {
		s.log.Warnw("msg", "weather unavailable, using heuristic irrigation decision", "field_id", decision.FieldID, "error", err)
		return domain.DecisionOutput{}, false
	}
	et0 := weather.ForecastET0MMDay
	if et0 <= 0 {
		et0 = weather.ET0MMDay
	}
	if et0 <= 0 && decision.Inputs.EvapotranspirationMM > 0 {
		et0 = decision.Inputs.EvapotranspirationMM
	}
	if et0 <= 0 {
		return domain.DecisionOutput{}, false
	}
	// Carry the observed values into the stored inputs for auditability.
	decision.Inputs.EvapotranspirationMM = et0
	if decision.Inputs.RainfallForecastMM == 0 {
		for _, mm := range weather.ForecastRainfallMM {
			decision.Inputs.RainfallForecastMM += mm
		}
	}

	req := outbound.WaterBalanceRequest{
		FieldAreaHa:        zone.AreaHectares,
		CropType:           decision.Inputs.CropType,
		GrowthStage:        decision.Inputs.GrowthStage,
		ReferenceET0MMDay:  et0,
		InitialDepletionMM: initialDepletionMM(decision.Inputs.SoilMoisture, defaultRootZoneDepthM, defaultFieldCapacity, defaultWiltingPoint),
		DailyRainfallMM:    weather.ForecastRainfallMM,
		SimulationDays:     7,
		RootZoneDepthM:     defaultRootZoneDepthM,
		FieldCapacity:      defaultFieldCapacity,
		WiltingPoint:       defaultWiltingPoint,
		AllowedDepletion:   defaultAllowedDepletion,
	}
	result, err := s.waterClient.Simulate(ctx, req)
	if err != nil || len(result.Days) == 0 {
		s.log.Warnw("msg", "water balance unavailable, using heuristic irrigation decision", "field_id", decision.FieldID, "error", err)
		return domain.DecisionOutput{}, false
	}
	return decisionFromWaterBalance(result, zone.AreaHectares, et0, decision.Inputs), true
}

// Soil hydraulic defaults for zones without a soil profile (loam).
const (
	defaultRootZoneDepthM   = 0.6
	defaultFieldCapacity    = 0.30
	defaultWiltingPoint     = 0.10
	defaultAllowedDepletion = 0.5
	litersPerHaPerMM        = 10_000.0
)

// initialDepletionMM converts a soil-moisture reading (percent of field
// capacity) into root-zone depletion from field capacity in mm.
func initialDepletionMM(soilMoisturePct, rootZoneM, fieldCapacity, wiltingPoint float64) float64 {
	if soilMoisturePct <= 0 {
		return 0
	}
	taw := (fieldCapacity - wiltingPoint) * rootZoneM * 1000 // total available water, mm
	frac := 1 - soilMoisturePct/100
	if frac < 0 {
		frac = 0
	}
	if frac > 1 {
		frac = 1
	}
	return taw * frac
}

// decisionFromWaterBalance turns the simulated schedule into a recommendation.
// Irrigate now when the first day already needs it; otherwise report the
// next event date and hold.
func decisionFromWaterBalance(result *outbound.WaterBalanceResult, areaHa, et0 float64, inputs domain.DecisionInputs) domain.DecisionOutput {
	kc := 0.0
	if et0 > 0 {
		kc = result.CropCoefficient / et0
	}
	out := domain.DecisionOutput{
		Method:          domain.DecisionMethodWaterBalance,
		CropCoefficient: kc,
		ET0MMDay:        et0,
		ConfidenceScore: 0.9,
	}

	first := -1
	for i, d := range result.Days {
		if d.IrrigationNeeded {
			first = i
			break
		}
	}
	today := result.Days[0]
	if first == 0 {
		depth := today.IrrigationAmountMM
		out.ShouldIrrigate = true
		out.RecommendedDepthMM = depth
		if areaHa > 0 {
			out.WaterQuantityLiters = depth * litersPerHaPerMM * areaHa
		} else {
			out.WaterQuantityLiters = depth * 10
		}
		out.DurationMinutes = int32(depth * 6) // ~10 mm/h application rate
		if out.DurationMinutes < 5 {
			out.DurationMinutes = 5
		}
		now := time.Now()
		out.OptimalTime = &now
		out.Reasoning = fmt.Sprintf(
			"Water balance: root-zone depletion %.1f mm exceeds readily available water %.1f mm (ETc %.1f mm/day, Kc %.2f, ET0 %.1f mm/day). Apply %.1f mm.",
			today.DepletionMM, today.ReadilyAvailableMM, today.ETcMMDay, kc, et0, depth)
		if inputs.WindSpeed > 20 {
			out.WaterQuantityLiters *= 1.1
			out.Reasoning += " High wind: quantity increased 10% for drift losses."
		}
		return out
	}

	out.ShouldIrrigate = false
	if first > 0 {
		when := time.Now().AddDate(0, 0, first)
		out.OptimalTime = &when
		out.RecommendedDepthMM = result.Days[first].IrrigationAmountMM
		out.Reasoning = fmt.Sprintf(
			"Water balance: depletion %.1f mm is within readily available water %.1f mm today; next irrigation of %.1f mm expected in %d day(s) (ETc %.1f mm/day, forecast rain %.1f mm).",
			today.DepletionMM, today.ReadilyAvailableMM, out.RecommendedDepthMM, first, today.ETcMMDay, inputs.RainfallForecastMM)
	} else {
		out.Reasoning = fmt.Sprintf(
			"Water balance: no irrigation needed within the %d-day horizon (depletion %.1f mm, ETc %.1f mm/day, forecast rain %.1f mm).",
			len(result.Days), today.DepletionMM, today.ETcMMDay, inputs.RainfallForecastMM)
	}
	return out
}

func (s *irrigationService) GetWaterUsage(ctx context.Context, zoneID string, start, end time.Time) ([]domain.WaterUsageLog, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if zoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}
	return s.repo.ListWaterUsageLogs(ctx, zoneID, start, end)
}

func computeIrrigationDecision(inputs domain.DecisionInputs) domain.DecisionOutput {
	shouldIrrigate := false
	reasoning := ""
	confidence := 0.0
	waterQty := 0.0
	duration := int32(0)

	soilThreshold := 30.0
	if inputs.SoilMoisture < soilThreshold {
		shouldIrrigate = true
		reasoning = fmt.Sprintf("Soil moisture (%.1f%%) is below threshold (%.1f%%).", inputs.SoilMoisture, soilThreshold)
		confidence = 0.85
		deficit := soilThreshold - inputs.SoilMoisture
		waterQty = deficit * 10.0
		duration = int32(waterQty / 60.0 * 60)
		if duration < 5 {
			duration = 5
		}
	} else {
		reasoning = fmt.Sprintf("Soil moisture (%.1f%%) is adequate.", inputs.SoilMoisture)
		confidence = 0.80
	}

	if inputs.RainfallForecastMM > 5.0 {
		if shouldIrrigate {
			waterQty *= 0.5
			reasoning += fmt.Sprintf(" Rainfall forecast (%.1fmm) reduces needed irrigation.", inputs.RainfallForecastMM)
			confidence *= 0.9
		} else {
			reasoning += fmt.Sprintf(" Rainfall forecast (%.1fmm) further reduces irrigation need.", inputs.RainfallForecastMM)
		}
	}

	if inputs.Temperature > 35.0 && !shouldIrrigate && inputs.SoilMoisture < 45.0 {
		shouldIrrigate = true
		waterQty = 50.0
		duration = 15
		reasoning += fmt.Sprintf(" High temperature (%.1f°C) triggers preventive irrigation.", inputs.Temperature)
		confidence = 0.70
	}

	if inputs.EvapotranspirationMM > 0 && shouldIrrigate {
		waterQty += inputs.EvapotranspirationMM * 5.0
		reasoning += fmt.Sprintf(" Adjusted for evapotranspiration (%.1fmm).", inputs.EvapotranspirationMM)
	}

	if inputs.WindSpeed > 20.0 && shouldIrrigate {
		waterQty *= 1.2
		reasoning += " High wind increases water loss; quantity adjusted."
	}

	return domain.DecisionOutput{
		ShouldIrrigate:      shouldIrrigate,
		WaterQuantityLiters: waterQty,
		DurationMinutes:     duration,
		Reasoning:           reasoning,
		ConfidenceScore:     confidence,
		Method:              domain.DecisionMethodHeuristic,
		RecommendedDepthMM:  waterQty / 10,
	}
}

func clampPageSize(pageSize int32) int32 {
	if pageSize <= 0 {
		return defaultPageSize
	}
	if pageSize > maxPageSize {
		return maxPageSize
	}
	return pageSize
}

func (s *irrigationService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
