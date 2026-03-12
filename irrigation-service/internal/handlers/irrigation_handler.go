package handlers

import (
	"context"
	"time"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/irrigation-service/api/v1"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/mappers"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/models"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/services"
)

// IrrigationHandler implements the ConnectRPC IrrigationService handler.
type IrrigationHandler struct {
	d       deps.ServiceDeps
	service services.IrrigationService
	log     *p9log.Helper
}

// NewIrrigationHandler creates a new IrrigationHandler.
func NewIrrigationHandler(d deps.ServiceDeps, service services.IrrigationService) *IrrigationHandler {
	return &IrrigationHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "IrrigationHandler")),
	}
}

// CreateSchedule handles schedule creation requests.
func (h *IrrigationHandler) CreateSchedule(ctx context.Context, req *pb.CreateScheduleRequest) (*pb.CreateScheduleResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "CreateSchedule request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetSchedule() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule is required")
	}
	if req.GetSchedule().GetName() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule name is required")
	}
	if req.GetSchedule().GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}

	schedule := mappers.ScheduleFromProto(req.GetSchedule())

	created, err := h.service.CreateSchedule(ctx, schedule)
	if err != nil {
		h.log.Errorw("msg", "CreateSchedule failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateScheduleResponse{
		Schedule: mappers.ScheduleToProto(created),
	}, nil
}

// GetSchedule handles get schedule requests.
func (h *IrrigationHandler) GetSchedule(ctx context.Context, req *pb.GetScheduleRequest) (*pb.GetScheduleResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetSchedule request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule ID is required")
	}

	schedule, err := h.service.GetSchedule(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetScheduleResponse{
		Schedule: mappers.ScheduleToProto(schedule),
	}, nil
}

// ListSchedules handles list schedules requests with filtering and pagination.
func (h *IrrigationHandler) ListSchedules(ctx context.Context, req *pb.ListSchedulesRequest) (*pb.ListSchedulesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListSchedules request", "request_id", requestID)

	var status *models.IrrigationStatus
	if req.GetStatus() != pb.IrrigationStatus_IRRIGATION_STATUS_UNSPECIFIED {
		s := mappers.IrrigationStatusFromProto(req.GetStatus())
		status = &s
	}

	schedules, totalCount, err := h.service.ListSchedules(ctx, req.GetFieldId(), req.GetFarmId(), req.GetZoneId(), status, req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListSchedulesResponse{
		Schedules:  mappers.SchedulesToProto(schedules),
		TotalCount: totalCount,
	}, nil
}

// UpdateSchedule handles schedule update requests.
func (h *IrrigationHandler) UpdateSchedule(ctx context.Context, req *pb.UpdateScheduleRequest) (*pb.UpdateScheduleResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "UpdateSchedule request", "request_id", requestID)

	if req.GetSchedule() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule is required")
	}
	if req.GetSchedule().GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule ID is required")
	}

	schedule := mappers.ScheduleFromProto(req.GetSchedule())
	schedule.UUID = req.GetSchedule().GetId()

	updated, err := h.service.UpdateSchedule(ctx, schedule)
	if err != nil {
		h.log.Errorw("msg", "UpdateSchedule failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.UpdateScheduleResponse{
		Schedule: mappers.ScheduleToProto(updated),
	}, nil
}

// DeleteSchedule handles schedule deletion requests.
func (h *IrrigationHandler) DeleteSchedule(ctx context.Context, req *pb.DeleteScheduleRequest) (*pb.DeleteScheduleResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DeleteSchedule request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule ID is required")
	}

	err := h.service.DeleteSchedule(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.DeleteScheduleResponse{
		Success: true,
	}, nil
}

// GenerateIrrigationDecision handles AI-driven irrigation decision requests.
func (h *IrrigationHandler) GenerateIrrigationDecision(ctx context.Context, req *pb.GenerateIrrigationDecisionRequest) (*pb.GenerateIrrigationDecisionResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GenerateIrrigationDecision request", "zone_id", req.GetZoneId(), "request_id", requestID)

	if req.GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}
	if req.GetInputs() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "decision inputs are required")
	}

	inputs := mappers.DecisionInputsFromProto(req.GetInputs())

	decision, err := h.service.GenerateIrrigationDecision(ctx, req.GetZoneId(), req.GetFieldId(), inputs)
	if err != nil {
		h.log.Errorw("msg", "GenerateIrrigationDecision failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.GenerateIrrigationDecisionResponse{
		Decision: mappers.DecisionToProto(decision),
	}, nil
}

// CreateZone handles zone creation requests.
func (h *IrrigationHandler) CreateZone(ctx context.Context, req *pb.CreateZoneRequest) (*pb.CreateZoneResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "CreateZone request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetZone() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone is required")
	}
	if req.GetZone().GetName() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone name is required")
	}
	if req.GetZone().GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetZone().GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	zone := mappers.ZoneFromProto(req.GetZone())

	created, err := h.service.CreateZone(ctx, zone)
	if err != nil {
		h.log.Errorw("msg", "CreateZone failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateZoneResponse{
		Zone: mappers.ZoneToProto(created),
	}, nil
}

// ListZones handles list zones requests with filtering and pagination.
func (h *IrrigationHandler) ListZones(ctx context.Context, req *pb.ListZonesRequest) (*pb.ListZonesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListZones request", "request_id", requestID)

	zones, totalCount, err := h.service.ListZones(ctx, req.GetFieldId(), req.GetFarmId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListZonesResponse{
		Zones:      mappers.ZonesToProto(zones),
		TotalCount: totalCount,
	}, nil
}

// RegisterController handles controller registration requests.
func (h *IrrigationHandler) RegisterController(ctx context.Context, req *pb.RegisterControllerRequest) (*pb.RegisterControllerResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "RegisterController request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetController() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "controller is required")
	}
	if req.GetController().GetName() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "controller name is required")
	}
	if req.GetController().GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}
	if req.GetController().GetEndpoint() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "endpoint is required")
	}

	ctrl := mappers.ControllerFromProto(req.GetController())

	created, err := h.service.RegisterController(ctx, ctrl)
	if err != nil {
		h.log.Errorw("msg", "RegisterController failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.RegisterControllerResponse{
		Controller: mappers.ControllerToProto(created),
	}, nil
}

// ListControllers handles list controllers requests with filtering and pagination.
func (h *IrrigationHandler) ListControllers(ctx context.Context, req *pb.ListControllersRequest) (*pb.ListControllersResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListControllers request", "request_id", requestID)

	var status *models.ControllerStatus
	if req.GetStatus() != pb.ControllerStatus_CONTROLLER_STATUS_UNSPECIFIED {
		s := mappers.ControllerStatusFromProto(req.GetStatus())
		status = &s
	}

	controllers, totalCount, err := h.service.ListControllers(ctx, req.GetZoneId(), req.GetFieldId(), status, req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListControllersResponse{
		Controllers: mappers.ControllersToProto(controllers),
		TotalCount:  totalCount,
	}, nil
}

// TriggerIrrigation handles irrigation trigger requests.
func (h *IrrigationHandler) TriggerIrrigation(ctx context.Context, req *pb.TriggerIrrigationRequest) (*pb.TriggerIrrigationResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "TriggerIrrigation request",
		"schedule_id", req.GetScheduleId(),
		"controller_id", req.GetControllerId(),
		"zone_id", req.GetZoneId(),
		"request_id", requestID,
	)

	if req.GetScheduleId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule_id is required")
	}
	if req.GetControllerId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "controller_id is required")
	}
	if req.GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}
	if req.GetDurationMinutes() <= 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "duration_minutes must be positive")
	}

	evt, err := h.service.TriggerIrrigation(ctx, req.GetScheduleId(), req.GetControllerId(), req.GetZoneId(), req.GetDurationMinutes(), req.GetWaterQuantityLiters())
	if err != nil {
		h.log.Errorw("msg", "TriggerIrrigation failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.TriggerIrrigationResponse{
		Event: mappers.EventToProto(evt),
	}, nil
}

// StopIrrigation handles irrigation stop requests.
func (h *IrrigationHandler) StopIrrigation(ctx context.Context, req *pb.StopIrrigationRequest) (*pb.StopIrrigationResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "StopIrrigation request",
		"event_id", req.GetEventId(),
		"controller_id", req.GetControllerId(),
		"request_id", requestID,
	)

	if req.GetEventId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "event_id is required")
	}
	if req.GetControllerId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "controller_id is required")
	}

	evt, err := h.service.StopIrrigation(ctx, req.GetEventId(), req.GetControllerId())
	if err != nil {
		h.log.Errorw("msg", "StopIrrigation failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.StopIrrigationResponse{
		Event: mappers.EventToProto(evt),
	}, nil
}

// GetWaterUsage handles water usage reporting requests.
func (h *IrrigationHandler) GetWaterUsage(ctx context.Context, req *pb.GetWaterUsageRequest) (*pb.GetWaterUsageResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetWaterUsage request", "zone_id", req.GetZoneId(), "field_id", req.GetFieldId(), "request_id", requestID)

	if req.GetZoneId() == "" && req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id or field_id is required")
	}

	var from, to time.Time
	if req.GetFrom() != nil {
		from = req.GetFrom().AsTime()
	}
	if req.GetTo() != nil {
		to = req.GetTo().AsTime()
	}

	logs, totalLiters, err := h.service.GetWaterUsage(ctx, req.GetZoneId(), req.GetFieldId(), from, to)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetWaterUsageResponse{
		Logs:        mappers.WaterUsageLogsToProto(logs),
		TotalLiters: totalLiters,
	}, nil
}

// GetIrrigationHistory handles irrigation history requests.
func (h *IrrigationHandler) GetIrrigationHistory(ctx context.Context, req *pb.GetIrrigationHistoryRequest) (*pb.GetIrrigationHistoryResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetIrrigationHistory request", "zone_id", req.GetZoneId(), "field_id", req.GetFieldId(), "request_id", requestID)

	if req.GetZoneId() == "" && req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id or field_id is required")
	}

	var from, to time.Time
	if req.GetFrom() != nil {
		from = req.GetFrom().AsTime()
	}
	if req.GetTo() != nil {
		to = req.GetTo().AsTime()
	}

	events, totalCount, err := h.service.GetIrrigationHistory(ctx, req.GetZoneId(), req.GetFieldId(), req.GetScheduleId(), from, to, req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetIrrigationHistoryResponse{
		Events:     mappers.EventsToProto(events),
		TotalCount: totalCount,
	}, nil
}
