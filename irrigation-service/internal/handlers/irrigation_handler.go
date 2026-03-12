package handlers

import (
	"context"
	"fmt"
	"strconv"
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

// GetZone handles get zone requests.
func (h *IrrigationHandler) GetZone(ctx context.Context, req *pb.GetZoneRequest) (*pb.GetZoneResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetZone request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone ID is required")
	}

	zone, err := h.service.GetZone(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetZoneResponse{
		Zone: mappers.ZoneToProto(zone),
	}, nil
}

// ListZonesByField handles list zones by field requests with pagination.
func (h *IrrigationHandler) ListZonesByField(ctx context.Context, req *pb.ListZonesByFieldRequest) (*pb.ListZonesByFieldResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListZonesByField request", "field_id", req.GetFieldId(), "request_id", requestID)

	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	zones, totalCount, err := h.service.ListZonesByField(ctx, req.GetFieldId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListZonesByFieldResponse{
		Zones:      mappers.ZonesToProto(zones),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := req.GetPageOffset() + req.GetPageSize()
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// ListZonesByFarm handles list zones by farm requests with pagination.
func (h *IrrigationHandler) ListZonesByFarm(ctx context.Context, req *pb.ListZonesByFarmRequest) (*pb.ListZonesByFarmResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListZonesByFarm request", "farm_id", req.GetFarmId(), "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	zones, totalCount, err := h.service.ListZonesByFarm(ctx, req.GetFarmId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListZonesByFarmResponse{
		Zones:      mappers.ZonesToProto(zones),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := req.GetPageOffset() + req.GetPageSize()
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// CreateController handles controller creation requests.
func (h *IrrigationHandler) CreateController(ctx context.Context, req *pb.CreateControllerRequest) (*pb.CreateControllerResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "CreateController request", "tenant_id", tenantID, "request_id", requestID)

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

	created, err := h.service.CreateController(ctx, ctrl)
	if err != nil {
		h.log.Errorw("msg", "CreateController failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateControllerResponse{
		Controller: mappers.ControllerToProto(created),
	}, nil
}

// GetController handles get controller requests.
func (h *IrrigationHandler) GetController(ctx context.Context, req *pb.GetControllerRequest) (*pb.GetControllerResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetController request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "controller ID is required")
	}

	controller, err := h.service.GetController(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetControllerResponse{
		Controller: mappers.ControllerToProto(controller),
	}, nil
}

// ListControllersByZone handles list controllers by zone requests with pagination.
func (h *IrrigationHandler) ListControllersByZone(ctx context.Context, req *pb.ListControllersByZoneRequest) (*pb.ListControllersByZoneResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListControllersByZone request", "zone_id", req.GetZoneId(), "request_id", requestID)

	if req.GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}

	controllers, totalCount, err := h.service.ListControllersByZone(ctx, req.GetZoneId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListControllersByZoneResponse{
		Controllers: mappers.ControllersToProto(controllers),
		TotalCount:  totalCount,
	}

	// Compute next page token
	nextOffset := req.GetPageOffset() + req.GetPageSize()
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// UpdateControllerStatus handles controller status update requests.
func (h *IrrigationHandler) UpdateControllerStatus(ctx context.Context, req *pb.UpdateControllerStatusRequest) (*pb.UpdateControllerStatusResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "UpdateControllerStatus request", "id", req.GetId(), "status", req.GetStatus(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "controller ID is required")
	}
	if req.GetStatus() == pb.ControllerStatus_CONTROLLER_STATUS_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "controller status is required")
	}

	status := mappers.ControllerStatusFromProto(req.GetStatus())

	updated, err := h.service.UpdateControllerStatus(ctx, req.GetId(), status)
	if err != nil {
		h.log.Errorw("msg", "UpdateControllerStatus failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.UpdateControllerStatusResponse{
		Controller: mappers.ControllerToProto(updated),
	}, nil
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

// ListSchedulesByZone handles list schedules by zone requests with pagination.
func (h *IrrigationHandler) ListSchedulesByZone(ctx context.Context, req *pb.ListSchedulesByZoneRequest) (*pb.ListSchedulesByZoneResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListSchedulesByZone request", "zone_id", req.GetZoneId(), "request_id", requestID)

	if req.GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}

	schedules, totalCount, err := h.service.ListSchedulesByZone(ctx, req.GetZoneId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListSchedulesByZoneResponse{
		Schedules:  mappers.SchedulesToProto(schedules),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := req.GetPageOffset() + req.GetPageSize()
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// ListSchedulesByField handles list schedules by field requests with pagination.
func (h *IrrigationHandler) ListSchedulesByField(ctx context.Context, req *pb.ListSchedulesByFieldRequest) (*pb.ListSchedulesByFieldResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListSchedulesByField request", "field_id", req.GetFieldId(), "request_id", requestID)

	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	schedules, totalCount, err := h.service.ListSchedulesByField(ctx, req.GetFieldId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListSchedulesByFieldResponse{
		Schedules:  mappers.SchedulesToProto(schedules),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := req.GetPageOffset() + req.GetPageSize()
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
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

// CancelSchedule handles schedule cancellation requests.
func (h *IrrigationHandler) CancelSchedule(ctx context.Context, req *pb.CancelScheduleRequest) (*pb.CancelScheduleResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CancelSchedule request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule ID is required")
	}

	err := h.service.CancelSchedule(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.CancelScheduleResponse{
		Success: true,
	}, nil
}

// TriggerIrrigation handles irrigation trigger requests.
func (h *IrrigationHandler) TriggerIrrigation(ctx context.Context, req *pb.TriggerIrrigationRequest) (*pb.TriggerIrrigationResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "TriggerIrrigation request",
		"schedule_id", req.GetScheduleId(),
		"request_id", requestID,
	)

	if req.GetScheduleId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule_id is required")
	}

	evt, err := h.service.TriggerIrrigation(ctx, req.GetScheduleId())
	if err != nil {
		h.log.Errorw("msg", "TriggerIrrigation failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.TriggerIrrigationResponse{
		Event: mappers.EventToProto(evt),
	}, nil
}

// GetEvent handles get event requests.
func (h *IrrigationHandler) GetEvent(ctx context.Context, req *pb.GetEventRequest) (*pb.GetEventResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetEvent request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "event ID is required")
	}

	evt, err := h.service.GetEvent(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetEventResponse{
		Event: mappers.EventToProto(evt),
	}, nil
}

// ListEventsBySchedule handles list events by schedule requests with pagination.
func (h *IrrigationHandler) ListEventsBySchedule(ctx context.Context, req *pb.ListEventsByScheduleRequest) (*pb.ListEventsByScheduleResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListEventsBySchedule request", "schedule_id", req.GetScheduleId(), "request_id", requestID)

	if req.GetScheduleId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "schedule_id is required")
	}

	events, totalCount, err := h.service.ListEventsBySchedule(ctx, req.GetScheduleId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListEventsByScheduleResponse{
		Events:     mappers.EventsToProto(events),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := req.GetPageOffset() + req.GetPageSize()
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// RequestDecision handles AI-driven irrigation decision requests.
func (h *IrrigationHandler) RequestDecision(ctx context.Context, req *pb.RequestDecisionRequest) (*pb.RequestDecisionResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "RequestDecision request", "zone_id", req.GetZoneId(), "request_id", requestID)

	if req.GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}
	if req.GetInputs() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "decision inputs are required")
	}

	inputs := mappers.DecisionInputsFromProto(req.GetInputs())

	decision := &models.IrrigationDecision{
		ZoneID:  req.GetZoneId(),
		FieldID: req.GetFieldId(),
		Inputs:  inputs,
	}

	if req.GetScheduleId() != "" {
		decision.ScheduleID = req.GetScheduleId()
	}

	created, err := h.service.RequestDecision(ctx, decision)
	if err != nil {
		h.log.Errorw("msg", "RequestDecision failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.RequestDecisionResponse{
		Decision: mappers.DecisionToProto(created),
	}, nil
}

// GetWaterUsage handles water usage reporting requests.
func (h *IrrigationHandler) GetWaterUsage(ctx context.Context, req *pb.GetWaterUsageRequest) (*pb.GetWaterUsageResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetWaterUsage request", "zone_id", req.GetZoneId(), "request_id", requestID)

	if req.GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}

	var start, end time.Time
	if req.GetStart() != nil {
		start = req.GetStart().AsTime()
	}
	if req.GetEnd() != nil {
		end = req.GetEnd().AsTime()
	}

	logs, err := h.service.GetWaterUsage(ctx, req.GetZoneId(), start, end)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetWaterUsageResponse{
		Logs: mappers.WaterUsageLogsToProto(logs),
	}, nil
}

// parsePageToken parses a page token string into an int32 offset.
func parsePageToken(token string) int32 {
	if token == "" {
		return 0
	}
	offset, err := strconv.ParseInt(token, 10, 32)
	if err != nil {
		return 0
	}
	return int32(offset)
}
