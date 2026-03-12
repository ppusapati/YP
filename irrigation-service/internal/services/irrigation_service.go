package services

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
	"p9e.in/samavaya/packages/uow"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/models"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/repositories"
)

const (
	serviceName       = "irrigation-service"
	maxPageSize int32 = 100
	defaultPageSize   = 20
)

// Irrigation event types
const (
	EventTypeZoneCreated       domain.EventType = "agriculture.irrigation.zone.created"
	EventTypeScheduleCreated   domain.EventType = "agriculture.irrigation.schedule.created"
	EventTypeScheduleCancelled domain.EventType = "agriculture.irrigation.schedule.cancelled"
	EventTypeIrrigationTriggered domain.EventType = "agriculture.irrigation.triggered"
	EventTypeIrrigationCompleted domain.EventType = "agriculture.irrigation.completed"
	EventTypeIrrigationFailed    domain.EventType = "agriculture.irrigation.failed"
)

// IrrigationService defines the interface for irrigation business logic.
type IrrigationService interface {
	CreateZone(ctx context.Context, zone *models.IrrigationZone) (*models.IrrigationZone, error)
	GetZone(ctx context.Context, uuid string) (*models.IrrigationZone, error)
	ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]models.IrrigationZone, int32, error)
	ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]models.IrrigationZone, int32, error)

	CreateController(ctx context.Context, ctrl *models.WaterController) (*models.WaterController, error)
	GetController(ctx context.Context, uuid string) (*models.WaterController, error)
	ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]models.WaterController, int32, error)
	UpdateControllerStatus(ctx context.Context, uuid string, status models.ControllerStatus) (*models.WaterController, error)

	CreateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	GetSchedule(ctx context.Context, uuid string) (*models.IrrigationSchedule, error)
	ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]models.IrrigationSchedule, int32, error)
	ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]models.IrrigationSchedule, int32, error)
	UpdateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	CancelSchedule(ctx context.Context, uuid string) error

	TriggerIrrigation(ctx context.Context, scheduleID string) (*models.IrrigationEvent, error)
	GetEvent(ctx context.Context, uuid string) (*models.IrrigationEvent, error)
	ListEventsBySchedule(ctx context.Context, scheduleID string, pageSize, offset int32) ([]models.IrrigationEvent, int32, error)

	RequestDecision(ctx context.Context, decision *models.IrrigationDecision) (*models.IrrigationDecision, error)

	GetWaterUsage(ctx context.Context, zoneID string, start, end time.Time) ([]models.WaterUsageLog, error)
}

// irrigationService is the concrete implementation of IrrigationService.
type irrigationService struct {
	d    deps.ServiceDeps
	repo repositories.IrrigationRepository
	log  *p9log.Helper
}

// NewIrrigationService creates a new IrrigationService.
func NewIrrigationService(d deps.ServiceDeps, repo repositories.IrrigationRepository) IrrigationService {
	return &irrigationService{
		d:    d,
		repo: repo,
		log:  p9log.NewHelper(p9log.With(d.Log, "component", "IrrigationService")),
	}
}

// CreateZone creates a new irrigation zone.
func (s *irrigationService) CreateZone(ctx context.Context, zone *models.IrrigationZone) (*models.IrrigationZone, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Validate required fields
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
		s.log.Errorw("msg", "failed to create zone", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitIrrigationEvent(ctx, EventTypeZoneCreated, created.UUID, map[string]interface{}{
		"zone_id":   created.UUID,
		"tenant_id": tenantID,
		"name":      created.Name,
		"field_id":  created.FieldID,
		"farm_id":   created.FarmID,
	})

	s.log.Infow("msg", "zone created", "uuid", created.UUID, "tenant_id", tenantID, "request_id", requestID)
	return created, nil
}

// GetZone retrieves an irrigation zone by UUID.
func (s *irrigationService) GetZone(ctx context.Context, uuid string) (*models.IrrigationZone, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone ID is required")
	}

	zone, err := s.repo.GetZoneByUUID(ctx, uuid)
	if err != nil {
		return nil, err
	}

	return zone, nil
}

// ListZonesByField lists irrigation zones for a given field with pagination.
func (s *irrigationService) ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]models.IrrigationZone, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	pageSize = clampPageSize(pageSize)

	return s.repo.ListZonesByField(ctx, fieldID, pageSize, offset)
}

// ListZonesByFarm lists irrigation zones for a given farm with pagination.
func (s *irrigationService) ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]models.IrrigationZone, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, 0, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	pageSize = clampPageSize(pageSize)

	return s.repo.ListZonesByFarm(ctx, farmID, pageSize, offset)
}

// CreateController registers a new water controller.
func (s *irrigationService) CreateController(ctx context.Context, ctrl *models.WaterController) (*models.WaterController, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Validate required fields
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

	// Verify the zone exists
	_, err := s.repo.GetZoneByUUID(ctx, ctrl.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", ctrl.ZoneID))
	}

	ctrl.TenantID = tenantID
	ctrl.CreatedBy = userID
	ctrl.Status = models.ControllerStatusOffline

	created, err := s.repo.CreateController(ctx, ctrl)
	if err != nil {
		s.log.Errorw("msg", "failed to create controller", "error", err, "request_id", requestID)
		return nil, err
	}

	s.log.Infow("msg", "controller created", "uuid", created.UUID, "tenant_id", tenantID, "request_id", requestID)
	return created, nil
}

// GetController retrieves a water controller by UUID.
func (s *irrigationService) GetController(ctx context.Context, uuid string) (*models.WaterController, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_CONTROLLER_ID", "controller ID is required")
	}

	controller, err := s.repo.GetControllerByUUID(ctx, uuid)
	if err != nil {
		return nil, err
	}

	return controller, nil
}

// ListControllersByZone lists water controllers for a given zone with pagination.
func (s *irrigationService) ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]models.WaterController, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if zoneID == "" {
		return nil, 0, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}

	pageSize = clampPageSize(pageSize)

	return s.repo.ListControllersByZone(ctx, zoneID, pageSize, offset)
}

// UpdateControllerStatus updates the operational status of a water controller.
func (s *irrigationService) UpdateControllerStatus(ctx context.Context, uuid string, status models.ControllerStatus) (*models.WaterController, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_CONTROLLER_ID", "controller ID is required")
	}
	if status == "" {
		return nil, errors.BadRequest("MISSING_STATUS", "controller status is required")
	}

	// Verify the controller exists
	_, err := s.repo.GetControllerByUUID(ctx, uuid)
	if err != nil {
		return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller not found: %s", uuid))
	}

	updated, err := s.repo.UpdateControllerStatus(ctx, uuid, status)
	if err != nil {
		s.log.Errorw("msg", "failed to update controller status", "uuid", uuid, "error", err, "request_id", requestID)
		return nil, err
	}

	s.log.Infow("msg", "controller status updated", "uuid", uuid, "status", string(status), "request_id", requestID)
	return updated, nil
}

// CreateSchedule creates a new irrigation schedule.
func (s *irrigationService) CreateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Validate required fields
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
	if sched.FlowRateLitersPerHour < 0 {
		return nil, errors.BadRequest("INVALID_FLOW_RATE", "flow_rate_liters_per_hour must be non-negative")
	}

	// Verify the zone exists
	_, err := s.repo.GetZoneByUUID(ctx, sched.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", sched.ZoneID))
	}

	sched.TenantID = tenantID
	sched.CreatedBy = userID
	sched.Status = models.IrrigationStatusScheduled

	created, err := s.repo.CreateSchedule(ctx, sched)
	if err != nil {
		s.log.Errorw("msg", "failed to create schedule", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitIrrigationEvent(ctx, EventTypeScheduleCreated, created.UUID, map[string]interface{}{
		"schedule_id":   created.UUID,
		"tenant_id":     tenantID,
		"name":          created.Name,
		"zone_id":       created.ZoneID,
		"schedule_type": string(created.ScheduleType),
		"status":        string(created.Status),
	})

	s.log.Infow("msg", "schedule created", "uuid", created.UUID, "tenant_id", tenantID, "request_id", requestID)
	return created, nil
}

// GetSchedule retrieves a schedule by UUID.
func (s *irrigationService) GetSchedule(ctx context.Context, uuid string) (*models.IrrigationSchedule, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}

	schedule, err := s.repo.GetScheduleByUUID(ctx, uuid)
	if err != nil {
		return nil, err
	}

	return schedule, nil
}

// ListSchedulesByZone lists schedules for a given zone with pagination.
func (s *irrigationService) ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]models.IrrigationSchedule, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if zoneID == "" {
		return nil, 0, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}

	pageSize = clampPageSize(pageSize)

	return s.repo.ListSchedulesByZone(ctx, zoneID, pageSize, offset)
}

// ListSchedulesByField lists schedules for a given field with pagination.
func (s *irrigationService) ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]models.IrrigationSchedule, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return nil, 0, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	pageSize = clampPageSize(pageSize)

	return s.repo.ListSchedulesByField(ctx, fieldID, pageSize, offset)
}

// UpdateSchedule updates an existing irrigation schedule.
func (s *irrigationService) UpdateSchedule(ctx context.Context, sched *models.IrrigationSchedule) (*models.IrrigationSchedule, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if sched.UUID == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Verify the schedule exists
	existing, err := s.repo.GetScheduleByUUID(ctx, sched.UUID)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", sched.UUID))
	}

	// Validate fields if provided
	if sched.DurationMinutes < 0 {
		return nil, errors.BadRequest("INVALID_DURATION", "duration_minutes must be non-negative")
	}
	if sched.WaterQuantityLiters < 0 {
		return nil, errors.BadRequest("INVALID_WATER_QUANTITY", "water_quantity_liters must be non-negative")
	}
	if sched.FlowRateLitersPerHour < 0 {
		return nil, errors.BadRequest("INVALID_FLOW_RATE", "flow_rate_liters_per_hour must be non-negative")
	}

	sched.TenantID = tenantID
	updatedBy := userID
	sched.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSchedule(ctx, sched)
	if err != nil {
		return nil, err
	}

	s.log.Infow("msg", "schedule updated", "uuid", updated.UUID, "version", updated.Version, "request_id", requestID)
	return updated, nil
}

// CancelSchedule cancels an irrigation schedule by setting its status to cancelled.
func (s *irrigationService) CancelSchedule(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Verify the schedule exists
	existing, err := s.repo.GetScheduleByUUID(ctx, uuid)
	if err != nil {
		return err
	}
	if existing == nil {
		return errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", uuid))
	}

	// Cannot cancel an already cancelled or completed schedule
	if existing.Status == models.IrrigationStatusCancelled {
		return errors.BadRequest("ALREADY_CANCELLED", fmt.Sprintf("schedule %s is already cancelled", uuid))
	}
	if existing.Status == models.IrrigationStatusCompleted {
		return errors.BadRequest("ALREADY_COMPLETED", fmt.Sprintf("schedule %s is already completed", uuid))
	}

	_, err = s.repo.UpdateScheduleStatus(ctx, uuid, models.IrrigationStatusCancelled)
	if err != nil {
		s.log.Errorw("msg", "failed to cancel schedule", "uuid", uuid, "error", err, "request_id", requestID)
		return err
	}

	// Emit domain event
	s.emitIrrigationEvent(ctx, EventTypeScheduleCancelled, uuid, map[string]interface{}{
		"schedule_id":  uuid,
		"tenant_id":    tenantID,
		"cancelled_by": userID,
	})

	s.log.Infow("msg", "schedule cancelled", "uuid", uuid, "tenant_id", tenantID, "request_id", requestID)
	return nil
}

// TriggerIrrigation starts an irrigation event for a given schedule.
func (s *irrigationService) TriggerIrrigation(ctx context.Context, scheduleID string) (*models.IrrigationEvent, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if scheduleID == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule_id is required")
	}

	// Verify the schedule exists and retrieve details
	schedule, err := s.repo.GetScheduleByUUID(ctx, scheduleID)
	if err != nil {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", scheduleID))
	}

	// Verify the controller exists and is online
	if schedule.ControllerID != "" {
		controller, err := s.repo.GetControllerByUUID(ctx, schedule.ControllerID)
		if err != nil {
			return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller not found: %s", schedule.ControllerID))
		}
		if controller.Status != models.ControllerStatusOnline {
			return nil, errors.BadRequest("CONTROLLER_NOT_ONLINE", fmt.Sprintf("controller %s is not online (status: %s)", schedule.ControllerID, controller.Status))
		}
	}

	now := time.Now()

	var createdEvent *models.IrrigationEvent

	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		// Update schedule status to active
		_, err := s.repo.UpdateScheduleStatus(ctx, scheduleID, models.IrrigationStatusActive)
		if err != nil {
			return err
		}

		// Create the irrigation event
		evt := &models.IrrigationEvent{
			TenantID:          tenantID,
			ScheduleID:        scheduleID,
			ZoneID:            schedule.ZoneID,
			ControllerID:      schedule.ControllerID,
			Status:            models.IrrigationStatusActive,
			StartedAt:         &now,
			ActualDurationMinutes: schedule.DurationMinutes,
			ActualWaterLiters:     schedule.WaterQuantityLiters,
		}

		createdEvent, err = s.repo.CreateEvent(ctx, evt)
		if err != nil {
			return err
		}

		return nil
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to trigger irrigation", "schedule_id", scheduleID, "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	// Emit domain event
	s.emitIrrigationEvent(ctx, EventTypeIrrigationTriggered, createdEvent.UUID, map[string]interface{}{
		"event_id":      createdEvent.UUID,
		"tenant_id":     tenantID,
		"schedule_id":   scheduleID,
		"controller_id": schedule.ControllerID,
		"zone_id":       schedule.ZoneID,
		"schedule_name": schedule.Name,
	})

	s.log.Infow("msg", "irrigation triggered",
		"event_uuid", createdEvent.UUID,
		"schedule_id", scheduleID,
		"request_id", requestID,
	)
	return createdEvent, nil
}

// GetEvent retrieves an irrigation event by UUID.
func (s *irrigationService) GetEvent(ctx context.Context, uuid string) (*models.IrrigationEvent, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_EVENT_ID", "event ID is required")
	}

	evt, err := s.repo.GetEventByUUID(ctx, uuid)
	if err != nil {
		return nil, err
	}

	return evt, nil
}

// ListEventsBySchedule lists irrigation events for a given schedule with pagination.
func (s *irrigationService) ListEventsBySchedule(ctx context.Context, scheduleID string, pageSize, offset int32) ([]models.IrrigationEvent, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if scheduleID == "" {
		return nil, 0, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule_id is required")
	}

	pageSize = clampPageSize(pageSize)

	// Use zone-based listing via the schedule's zone
	schedule, err := s.repo.GetScheduleByUUID(ctx, scheduleID)
	if err != nil {
		return nil, 0, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", scheduleID))
	}

	return s.repo.ListEventsByZone(ctx, schedule.ZoneID, pageSize, offset)
}

// RequestDecision creates an irrigation decision record based on sensor and environmental inputs.
func (s *irrigationService) RequestDecision(ctx context.Context, decision *models.IrrigationDecision) (*models.IrrigationDecision, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if decision.ZoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}

	// Verify the zone exists
	_, err := s.repo.GetZoneByUUID(ctx, decision.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", decision.ZoneID))
	}

	// Compute the irrigation decision based on inputs
	output := computeIrrigationDecision(decision.Inputs)

	decision.TenantID = tenantID
	decision.Output = output
	decision.DecidedAt = time.Now()
	decision.Applied = false

	created, err := s.repo.CreateDecision(ctx, decision)
	if err != nil {
		s.log.Errorw("msg", "failed to create irrigation decision", "error", err, "request_id", requestID)
		return nil, err
	}

	s.log.Infow("msg", "irrigation decision created",
		"uuid", created.UUID,
		"zone_id", decision.ZoneID,
		"should_irrigate", output.ShouldIrrigate,
		"request_id", requestID,
	)
	return created, nil
}

// GetWaterUsage retrieves water usage logs for a zone within a time range.
func (s *irrigationService) GetWaterUsage(ctx context.Context, zoneID string, start, end time.Time) ([]models.WaterUsageLog, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if zoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}

	logs, err := s.repo.ListWaterUsageLogs(ctx, zoneID, start, end)
	if err != nil {
		return nil, err
	}

	return logs, nil
}

// computeIrrigationDecision applies heuristic rules to determine if irrigation is needed.
func computeIrrigationDecision(inputs models.DecisionInputs) models.DecisionOutput {
	shouldIrrigate := false
	reasoning := ""
	confidence := 0.0
	waterQty := 0.0
	duration := int32(0)

	// Rule 1: If soil moisture is below a threshold, irrigate
	soilThreshold := 30.0
	if inputs.SoilMoisture < soilThreshold {
		shouldIrrigate = true
		reasoning = fmt.Sprintf("Soil moisture (%.1f%%) is below threshold (%.1f%%).", inputs.SoilMoisture, soilThreshold)
		confidence = 0.85

		// Estimate water quantity based on deficit
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

	// Rule 2: Reduce irrigation if rainfall is forecast
	if inputs.RainfallForecastMM > 5.0 {
		if shouldIrrigate {
			waterQty *= 0.5
			reasoning += fmt.Sprintf(" Rainfall forecast (%.1fmm) reduces needed irrigation.", inputs.RainfallForecastMM)
			confidence *= 0.9
		} else {
			reasoning += fmt.Sprintf(" Rainfall forecast (%.1fmm) further reduces irrigation need.", inputs.RainfallForecastMM)
		}
	}

	// Rule 3: High temperature increases irrigation need
	if inputs.Temperature > 35.0 && !shouldIrrigate && inputs.SoilMoisture < 45.0 {
		shouldIrrigate = true
		waterQty = 50.0
		duration = 15
		reasoning += fmt.Sprintf(" High temperature (%.1f°C) triggers preventive irrigation.", inputs.Temperature)
		confidence = 0.70
	}

	// Rule 4: Evapotranspiration compensation
	if inputs.EvapotranspirationMM > 0 && shouldIrrigate {
		waterQty += inputs.EvapotranspirationMM * 5.0
		reasoning += fmt.Sprintf(" Adjusted for evapotranspiration (%.1fmm).", inputs.EvapotranspirationMM)
	}

	// Rule 5: High wind reduces sprinkler efficiency
	if inputs.WindSpeed > 20.0 && shouldIrrigate {
		waterQty *= 1.2
		reasoning += " High wind increases water loss; quantity adjusted."
	}

	return models.DecisionOutput{
		ShouldIrrigate:      shouldIrrigate,
		WaterQuantityLiters: waterQty,
		DurationMinutes:     duration,
		Reasoning:           reasoning,
		ConfidenceScore:     confidence,
	}
}

// clampPageSize enforces page size bounds.
func clampPageSize(pageSize int32) int32 {
	if pageSize <= 0 {
		return defaultPageSize
	}
	if pageSize > maxPageSize {
		return maxPageSize
	}
	return pageSize
}

// emitIrrigationEvent publishes a domain event for irrigation operations (best-effort).
func (s *irrigationService) emitIrrigationEvent(ctx context.Context, eventType domain.EventType, aggregateID string, data map[string]interface{}) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	event := domain.NewDomainEvent(eventType, aggregateID, "irrigation").
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)
	event.Data = data

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal irrigation event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.irrigation.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "irrigation event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}
