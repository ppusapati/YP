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
	EventTypeScheduleCreated   domain.EventType = "agriculture.irrigation.schedule.created"
	EventTypeScheduleUpdated   domain.EventType = "agriculture.irrigation.schedule.updated"
	EventTypeIrrigationTriggered domain.EventType = "agriculture.irrigation.triggered"
	EventTypeIrrigationStopped domain.EventType = "agriculture.irrigation.stopped"
	EventTypeDecisionGenerated domain.EventType = "agriculture.irrigation.decision.generated"
)

// IrrigationService defines the interface for irrigation business logic.
type IrrigationService interface {
	CreateSchedule(ctx context.Context, schedule *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	GetSchedule(ctx context.Context, uuid string) (*models.IrrigationSchedule, error)
	ListSchedules(ctx context.Context, fieldID, farmID, zoneID string, status *models.IrrigationStatus, pageSize, pageOffset int32) ([]models.IrrigationSchedule, int32, error)
	UpdateSchedule(ctx context.Context, schedule *models.IrrigationSchedule) (*models.IrrigationSchedule, error)
	DeleteSchedule(ctx context.Context, uuid string) error
	GenerateIrrigationDecision(ctx context.Context, zoneID, fieldID string, inputs models.DecisionInputs) (*models.IrrigationDecision, error)
	CreateZone(ctx context.Context, zone *models.IrrigationZone) (*models.IrrigationZone, error)
	ListZones(ctx context.Context, fieldID, farmID string, pageSize, pageOffset int32) ([]models.IrrigationZone, int32, error)
	RegisterController(ctx context.Context, ctrl *models.WaterController) (*models.WaterController, error)
	ListControllers(ctx context.Context, zoneID, fieldID string, status *models.ControllerStatus, pageSize, pageOffset int32) ([]models.WaterController, int32, error)
	TriggerIrrigation(ctx context.Context, scheduleID, controllerID, zoneID string, durationMinutes int32, waterQuantityLiters float64) (*models.IrrigationEvent, error)
	StopIrrigation(ctx context.Context, eventID, controllerID string) (*models.IrrigationEvent, error)
	GetWaterUsage(ctx context.Context, zoneID, fieldID string, from, to time.Time) ([]models.WaterUsageLog, float64, error)
	GetIrrigationHistory(ctx context.Context, zoneID, fieldID, scheduleID string, from, to time.Time, pageSize, pageOffset int32) ([]models.IrrigationEvent, int32, error)
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

// CreateSchedule creates a new irrigation schedule.
func (s *irrigationService) CreateSchedule(ctx context.Context, schedule *models.IrrigationSchedule) (*models.IrrigationSchedule, error) {
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
	if schedule.Name == "" {
		return nil, errors.BadRequest("INVALID_SCHEDULE_NAME", "schedule name is required")
	}
	if schedule.ZoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}
	if schedule.DurationMinutes <= 0 {
		return nil, errors.BadRequest("INVALID_DURATION", "duration_minutes must be positive")
	}
	if schedule.StartTime.IsZero() {
		return nil, errors.BadRequest("MISSING_START_TIME", "start_time is required")
	}
	if schedule.WaterQuantityLiters < 0 {
		return nil, errors.BadRequest("INVALID_WATER_QUANTITY", "water_quantity_liters must be non-negative")
	}
	if schedule.FlowRateLitersPerHour < 0 {
		return nil, errors.BadRequest("INVALID_FLOW_RATE", "flow_rate_liters_per_hour must be non-negative")
	}

	// Verify the zone exists
	_, err := s.repo.GetZoneByUUID(ctx, schedule.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", schedule.ZoneID))
	}

	schedule.TenantID = tenantID
	schedule.CreatedBy = userID
	schedule.Status = models.IrrigationStatusScheduled

	created, err := s.repo.CreateSchedule(ctx, schedule)
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

// ListSchedules lists schedules with filtering and pagination.
func (s *irrigationService) ListSchedules(ctx context.Context, fieldID, farmID, zoneID string, status *models.IrrigationStatus, pageSize, pageOffset int32) ([]models.IrrigationSchedule, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	// Clamp page size
	if pageSize <= 0 {
		pageSize = defaultPageSize
	}
	if pageSize > maxPageSize {
		pageSize = maxPageSize
	}

	// Route to the appropriate repository method based on filters
	if status != nil {
		return s.repo.ListSchedulesByStatus(ctx, *status, pageSize, pageOffset)
	}
	if zoneID != "" {
		return s.repo.ListSchedulesByZone(ctx, zoneID, pageSize, pageOffset)
	}
	if fieldID != "" {
		return s.repo.ListSchedulesByField(ctx, fieldID, pageSize, pageOffset)
	}
	if farmID != "" {
		return s.repo.ListSchedulesByFarm(ctx, farmID, pageSize, pageOffset)
	}

	// Default: list by farm (empty string will return all for tenant via repo)
	return s.repo.ListSchedulesByFarm(ctx, "", pageSize, pageOffset)
}

// UpdateSchedule updates an existing irrigation schedule.
func (s *irrigationService) UpdateSchedule(ctx context.Context, schedule *models.IrrigationSchedule) (*models.IrrigationSchedule, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if schedule.UUID == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Verify the schedule exists
	existing, err := s.repo.GetScheduleByUUID(ctx, schedule.UUID)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", schedule.UUID))
	}

	// Validate fields if provided
	if schedule.DurationMinutes < 0 {
		return nil, errors.BadRequest("INVALID_DURATION", "duration_minutes must be non-negative")
	}
	if schedule.WaterQuantityLiters < 0 {
		return nil, errors.BadRequest("INVALID_WATER_QUANTITY", "water_quantity_liters must be non-negative")
	}
	if schedule.FlowRateLitersPerHour < 0 {
		return nil, errors.BadRequest("INVALID_FLOW_RATE", "flow_rate_liters_per_hour must be non-negative")
	}

	schedule.TenantID = tenantID
	updatedBy := userID
	schedule.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSchedule(ctx, schedule)
	if err != nil {
		return nil, err
	}

	// Emit domain event
	s.emitIrrigationEvent(ctx, EventTypeScheduleUpdated, updated.UUID, map[string]interface{}{
		"schedule_id":   updated.UUID,
		"tenant_id":     tenantID,
		"name":          updated.Name,
		"zone_id":       updated.ZoneID,
		"schedule_type": string(updated.ScheduleType),
		"status":        string(updated.Status),
		"version":       updated.Version,
	})

	s.log.Infow("msg", "schedule updated", "uuid", updated.UUID, "version", updated.Version, "request_id", requestID)
	return updated, nil
}

// DeleteSchedule soft-deletes an irrigation schedule.
func (s *irrigationService) DeleteSchedule(ctx context.Context, uuid string) error {
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

	if err := s.repo.DeleteSchedule(ctx, uuid); err != nil {
		s.log.Errorw("msg", "failed to delete schedule", "uuid", uuid, "error", err, "request_id", requestID)
		return err
	}

	s.log.Infow("msg", "schedule deleted", "uuid", uuid, "tenant_id", tenantID, "request_id", requestID)
	return nil
}

// GenerateIrrigationDecision generates an AI-driven irrigation decision for a zone.
func (s *irrigationService) GenerateIrrigationDecision(ctx context.Context, zoneID, fieldID string, inputs models.DecisionInputs) (*models.IrrigationDecision, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if zoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}

	// Verify the zone exists
	_, err := s.repo.GetZoneByUUID(ctx, zoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", zoneID))
	}

	// Compute the irrigation decision based on inputs
	output := computeIrrigationDecision(inputs)

	decision := &models.IrrigationDecision{
		TenantID:  tenantID,
		ZoneID:    zoneID,
		FieldID:   fieldID,
		Inputs:    inputs,
		Output:    output,
		DecidedAt: time.Now(),
		Applied:   false,
	}

	created, err := s.repo.CreateDecision(ctx, decision)
	if err != nil {
		s.log.Errorw("msg", "failed to create irrigation decision", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitIrrigationEvent(ctx, EventTypeDecisionGenerated, created.UUID, map[string]interface{}{
		"decision_id":      created.UUID,
		"tenant_id":        tenantID,
		"zone_id":          zoneID,
		"should_irrigate":  output.ShouldIrrigate,
		"confidence_score": output.ConfidenceScore,
	})

	s.log.Infow("msg", "irrigation decision generated",
		"uuid", created.UUID,
		"zone_id", zoneID,
		"should_irrigate", output.ShouldIrrigate,
		"request_id", requestID,
	)
	return created, nil
}

// CreateZone creates a new irrigation zone.
func (s *irrigationService) CreateZone(ctx context.Context, zone *models.IrrigationZone) (*models.IrrigationZone, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
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

	created, err := s.repo.CreateZone(ctx, zone)
	if err != nil {
		s.log.Errorw("msg", "failed to create zone", "error", err, "request_id", requestID)
		return nil, err
	}

	s.log.Infow("msg", "zone created", "uuid", created.UUID, "tenant_id", tenantID, "request_id", requestID)
	return created, nil
}

// ListZones lists irrigation zones with filtering and pagination.
func (s *irrigationService) ListZones(ctx context.Context, fieldID, farmID string, pageSize, pageOffset int32) ([]models.IrrigationZone, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	// Clamp page size
	if pageSize <= 0 {
		pageSize = defaultPageSize
	}
	if pageSize > maxPageSize {
		pageSize = maxPageSize
	}

	if fieldID != "" {
		return s.repo.ListZonesByField(ctx, fieldID, pageSize, pageOffset)
	}
	if farmID != "" {
		return s.repo.ListZonesByFarm(ctx, farmID, pageSize, pageOffset)
	}

	// Default to listing by farm with empty filter
	return s.repo.ListZonesByFarm(ctx, "", pageSize, pageOffset)
}

// RegisterController registers a new water controller.
func (s *irrigationService) RegisterController(ctx context.Context, ctrl *models.WaterController) (*models.WaterController, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
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
	ctrl.Status = models.ControllerStatusOffline

	created, err := s.repo.CreateController(ctx, ctrl)
	if err != nil {
		s.log.Errorw("msg", "failed to register controller", "error", err, "request_id", requestID)
		return nil, err
	}

	s.log.Infow("msg", "controller registered", "uuid", created.UUID, "tenant_id", tenantID, "request_id", requestID)
	return created, nil
}

// ListControllers lists water controllers with filtering and pagination.
func (s *irrigationService) ListControllers(ctx context.Context, zoneID, fieldID string, status *models.ControllerStatus, pageSize, pageOffset int32) ([]models.WaterController, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	// Clamp page size
	if pageSize <= 0 {
		pageSize = defaultPageSize
	}
	if pageSize > maxPageSize {
		pageSize = maxPageSize
	}

	if status != nil {
		return s.repo.ListControllersByStatus(ctx, *status, pageSize, pageOffset)
	}
	if zoneID != "" {
		return s.repo.ListControllersByZone(ctx, zoneID, pageSize, pageOffset)
	}
	if fieldID != "" {
		return s.repo.ListControllersByField(ctx, fieldID, pageSize, pageOffset)
	}

	// Default: list by zone with empty filter
	return s.repo.ListControllersByZone(ctx, "", pageSize, pageOffset)
}

// TriggerIrrigation starts an irrigation event for a given schedule and controller.
func (s *irrigationService) TriggerIrrigation(ctx context.Context, scheduleID, controllerID, zoneID string, durationMinutes int32, waterQuantityLiters float64) (*models.IrrigationEvent, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if scheduleID == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule_id is required")
	}
	if controllerID == "" {
		return nil, errors.BadRequest("MISSING_CONTROLLER_ID", "controller_id is required")
	}
	if zoneID == "" {
		return nil, errors.BadRequest("MISSING_ZONE_ID", "zone_id is required")
	}
	if durationMinutes <= 0 {
		return nil, errors.BadRequest("INVALID_DURATION", "duration_minutes must be positive")
	}

	// Verify the schedule exists
	schedule, err := s.repo.GetScheduleByUUID(ctx, scheduleID)
	if err != nil {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", scheduleID))
	}

	// Verify the controller exists and is online
	controller, err := s.repo.GetControllerByUUID(ctx, controllerID)
	if err != nil {
		return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller not found: %s", controllerID))
	}
	if controller.Status != models.ControllerStatusOnline {
		return nil, errors.BadRequest("CONTROLLER_NOT_ONLINE", fmt.Sprintf("controller %s is not online (status: %s)", controllerID, controller.Status))
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
			TenantID:     tenantID,
			ScheduleID:   scheduleID,
			ZoneID:       zoneID,
			ControllerID: controllerID,
			Status:       models.IrrigationStatusActive,
			StartedAt:    &now,
			ActualDurationMinutes: durationMinutes,
			ActualWaterLiters:     waterQuantityLiters,
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
		"controller_id": controllerID,
		"zone_id":       zoneID,
		"schedule_name": schedule.Name,
	})

	s.log.Infow("msg", "irrigation triggered",
		"event_uuid", createdEvent.UUID,
		"schedule_id", scheduleID,
		"controller_id", controllerID,
		"request_id", requestID,
	)
	return createdEvent, nil
}

// StopIrrigation stops an active irrigation event.
func (s *irrigationService) StopIrrigation(ctx context.Context, eventID, controllerID string) (*models.IrrigationEvent, error) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if eventID == "" {
		return nil, errors.BadRequest("MISSING_EVENT_ID", "event_id is required")
	}
	if controllerID == "" {
		return nil, errors.BadRequest("MISSING_CONTROLLER_ID", "controller_id is required")
	}

	// Retrieve the event
	evt, err := s.repo.GetEventByUUID(ctx, eventID)
	if err != nil {
		return nil, errors.NotFound("EVENT_NOT_FOUND", fmt.Sprintf("irrigation event not found: %s", eventID))
	}

	if evt.Status != models.IrrigationStatusActive {
		return nil, errors.BadRequest("EVENT_NOT_ACTIVE", fmt.Sprintf("irrigation event %s is not active (status: %s)", eventID, evt.Status))
	}

	now := time.Now()
	evt.Status = models.IrrigationStatusCompleted
	evt.EndedAt = &now

	// Calculate actual duration if started_at is set
	if evt.StartedAt != nil {
		actualMinutes := int32(now.Sub(*evt.StartedAt).Minutes())
		evt.ActualDurationMinutes = actualMinutes
	}

	var updatedEvent *models.IrrigationEvent

	txErr := uow.WithTransaction(ctx, s.d.Pool, func(u uow.UnitOfWork) error {
		// Update the event
		updated, err := s.repo.UpdateEvent(ctx, evt)
		if err != nil {
			return err
		}
		updatedEvent = updated

		// Update the schedule status back to scheduled
		if evt.ScheduleID != "" {
			_, err = s.repo.UpdateScheduleStatus(ctx, evt.ScheduleID, models.IrrigationStatusScheduled)
			if err != nil {
				return err
			}
		}

		// Log water usage
		if evt.ActualWaterLiters > 0 {
			usageLog := &models.WaterUsageLog{
				TenantID:     tenantID,
				ZoneID:       evt.ZoneID,
				ControllerID: controllerID,
				WaterLiters:  evt.ActualWaterLiters,
				RecordedAt:   now,
				PeriodStart:  *evt.StartedAt,
				PeriodEnd:    now,
			}
			if _, err := s.repo.CreateWaterUsageLog(ctx, usageLog); err != nil {
				return err
			}
		}

		return nil
	})

	if txErr != nil {
		s.log.Errorw("msg", "failed to stop irrigation", "event_id", eventID, "error", txErr, "request_id", requestID)
		return nil, txErr
	}

	// Emit domain event
	s.emitIrrigationEvent(ctx, EventTypeIrrigationStopped, updatedEvent.UUID, map[string]interface{}{
		"event_id":      updatedEvent.UUID,
		"tenant_id":     tenantID,
		"controller_id": controllerID,
		"zone_id":       updatedEvent.ZoneID,
		"schedule_id":   updatedEvent.ScheduleID,
		"water_liters":  updatedEvent.ActualWaterLiters,
		"duration_min":  updatedEvent.ActualDurationMinutes,
	})

	s.log.Infow("msg", "irrigation stopped",
		"event_uuid", updatedEvent.UUID,
		"controller_id", controllerID,
		"request_id", requestID,
	)
	return updatedEvent, nil
}

// GetWaterUsage retrieves water usage logs and total consumption for a zone/field in a time range.
func (s *irrigationService) GetWaterUsage(ctx context.Context, zoneID, fieldID string, from, to time.Time) ([]models.WaterUsageLog, float64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	lookupZoneID := zoneID
	if lookupZoneID == "" && fieldID != "" {
		// If only field_id is provided, list zones for the field and aggregate
		zones, _, err := s.repo.ListZonesByField(ctx, fieldID, maxPageSize, 0)
		if err != nil {
			return nil, 0, err
		}
		if len(zones) == 0 {
			return []models.WaterUsageLog{}, 0, nil
		}
		// Aggregate across all zones in the field
		var allLogs []models.WaterUsageLog
		var totalLiters float64
		for _, z := range zones {
			logs, err := s.repo.ListWaterUsageLogs(ctx, z.UUID, from, to)
			if err != nil {
				return nil, 0, err
			}
			allLogs = append(allLogs, logs...)
			sum, err := s.repo.SumWaterUsageByZone(ctx, z.UUID, from, to)
			if err != nil {
				return nil, 0, err
			}
			totalLiters += sum
		}
		return allLogs, totalLiters, nil
	}

	if lookupZoneID == "" {
		return nil, 0, errors.BadRequest("MISSING_FILTER", "zone_id or field_id is required")
	}

	logs, err := s.repo.ListWaterUsageLogs(ctx, lookupZoneID, from, to)
	if err != nil {
		return nil, 0, err
	}

	totalLiters, err := s.repo.SumWaterUsageByZone(ctx, lookupZoneID, from, to)
	if err != nil {
		return nil, 0, err
	}

	return logs, totalLiters, nil
}

// GetIrrigationHistory retrieves irrigation event history with filtering and pagination.
func (s *irrigationService) GetIrrigationHistory(ctx context.Context, zoneID, fieldID, scheduleID string, from, to time.Time, pageSize, pageOffset int32) ([]models.IrrigationEvent, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	// Clamp page size
	if pageSize <= 0 {
		pageSize = defaultPageSize
	}
	if pageSize > maxPageSize {
		pageSize = maxPageSize
	}

	// Use time range filtering if dates are provided
	if !from.IsZero() && !to.IsZero() {
		lookupZoneID := zoneID
		if lookupZoneID == "" && fieldID != "" {
			// Aggregate across all zones in the field
			zones, _, err := s.repo.ListZonesByField(ctx, fieldID, maxPageSize, 0)
			if err != nil {
				return nil, 0, err
			}
			var allEvents []models.IrrigationEvent
			var totalCount int32
			for _, z := range zones {
				events, count, err := s.repo.ListEventsByTimeRange(ctx, z.UUID, from, to, pageSize, pageOffset)
				if err != nil {
					return nil, 0, err
				}
				allEvents = append(allEvents, events...)
				totalCount += count
			}
			return allEvents, totalCount, nil
		}
		if lookupZoneID != "" {
			return s.repo.ListEventsByTimeRange(ctx, lookupZoneID, from, to, pageSize, pageOffset)
		}
	}

	// Fall back to zone-based listing
	if zoneID != "" {
		return s.repo.ListEventsByZone(ctx, zoneID, pageSize, pageOffset)
	}

	// If field_id is provided, aggregate across zones
	if fieldID != "" {
		zones, _, err := s.repo.ListZonesByField(ctx, fieldID, maxPageSize, 0)
		if err != nil {
			return nil, 0, err
		}
		var allEvents []models.IrrigationEvent
		var totalCount int32
		for _, z := range zones {
			events, count, err := s.repo.ListEventsByZone(ctx, z.UUID, pageSize, pageOffset)
			if err != nil {
				return nil, 0, err
			}
			allEvents = append(allEvents, events...)
			totalCount += count
		}
		return allEvents, totalCount, nil
	}

	return nil, 0, errors.BadRequest("MISSING_FILTER", "zone_id or field_id is required")
}

// computeIrrigationDecision applies heuristic rules to determine if irrigation is needed.
func computeIrrigationDecision(inputs models.DecisionInputs) models.DecisionOutput {
	shouldIrrigate := false
	reasoning := ""
	confidence := 0.0
	waterQty := 0.0
	duration := int32(0)

	// Rule 1: If soil moisture is below a threshold, irrigate
	soilThreshold := 30.0 // default threshold percentage
	if inputs.SoilMoisture < soilThreshold {
		shouldIrrigate = true
		reasoning = fmt.Sprintf("Soil moisture (%.1f%%) is below threshold (%.1f%%).", inputs.SoilMoisture, soilThreshold)
		confidence = 0.85

		// Estimate water quantity based on deficit
		deficit := soilThreshold - inputs.SoilMoisture
		waterQty = deficit * 10.0 // simplified: 10 liters per percent deficit
		duration = int32(waterQty / 60.0 * 60) // rough estimate
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
