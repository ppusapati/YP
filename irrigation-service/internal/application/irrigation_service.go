// Package application contains the irrigation-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

const (
	serviceName           = "irrigation-service"
	eventTopic            = "samavaya.agriculture.irrigation.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type irrigationService struct {
	repo outbound.IrrigationRepository
	pub  outbound.EventPublisher
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewIrrigationService creates a new application-layer IrrigationService.
// The fieldClient parameter is accepted for backward compatibility with main.go wiring.
func NewIrrigationService(
	repo outbound.IrrigationRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.IrrigationService {
	_ = fieldClient // not used in this implementation
	return &irrigationService{
		repo: repo,
		pub:  pub,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "IrrigationService")),
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

	s.emitEvent(ctx, "agriculture.irrigation.created", created.UUID, map[string]interface{}{
		"irrigation_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "irrigation created", "uuid", created.UUID)
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
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "irrigation ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckIrrigationExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateIrrigation(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.updated", updated.UUID, map[string]interface{}{
		"irrigation_id": updated.UUID, "tenant_id": tenantID,
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

	s.emitEvent(ctx, "agriculture.irrigation.zone.created", created.UUID, map[string]interface{}{
		"zone_id": created.UUID, "tenant_id": tenantID,
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

	s.emitEvent(ctx, "agriculture.irrigation.schedule.created", created.UUID, map[string]interface{}{
		"schedule_id": created.UUID, "tenant_id": tenantID,
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
	if sched.UUID == "" {
		return nil, errors.BadRequest("MISSING_SCHEDULE_ID", "schedule ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	existing, err := s.repo.GetScheduleByUUID(ctx, sched.UUID)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", sched.UUID))
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

	if schedule.ControllerID != "" {
		controller, err := s.repo.GetControllerByUUID(ctx, schedule.ControllerID)
		if err != nil {
			return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller not found: %s", schedule.ControllerID))
		}
		if controller.Status != domain.ControllerStatusOnline {
			return nil, errors.BadRequest("CONTROLLER_NOT_ONLINE",
				fmt.Sprintf("controller %s is not online (status: %s)", schedule.ControllerID, controller.Status))
		}
	}

	now := time.Now()
	_, err = s.repo.UpdateScheduleStatus(ctx, scheduleID, domain.IrrigationStatusActive)
	if err != nil {
		return nil, err
	}

	evt := &domain.IrrigationEvent{
		TenantID:              tenantID,
		ScheduleID:            scheduleID,
		ZoneID:                schedule.ZoneID,
		ControllerID:          schedule.ControllerID,
		Status:                domain.IrrigationStatusActive,
		StartedAt:             &now,
		ActualDurationMinutes: schedule.DurationMinutes,
		ActualWaterLiters:     schedule.WaterQuantityLiters,
	}

	createdEvent, err := s.repo.CreateEvent(ctx, evt)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.irrigation.triggered", createdEvent.UUID, map[string]interface{}{
		"event_id": createdEvent.UUID, "schedule_id": scheduleID, "tenant_id": tenantID,
	})
	return createdEvent, nil
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

	_, err := s.repo.GetZoneByUUID(ctx, decision.ZoneID)
	if err != nil {
		return nil, errors.BadRequest("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", decision.ZoneID))
	}

	output := computeIrrigationDecision(decision.Inputs)
	decision.TenantID = tenantID
	decision.Output = output
	decision.DecidedAt = time.Now()
	decision.Applied = false

	return s.repo.CreateDecision(ctx, decision)
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
