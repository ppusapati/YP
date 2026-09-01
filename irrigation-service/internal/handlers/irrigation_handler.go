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

// GetWaterUsage handles water usage reporting requests.
func (h *IrrigationHandler) GetWaterUsage(ctx context.Context, req *pb.GetWaterUsageRequest) (*pb.GetWaterUsageResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetWaterUsage request", "zone_id", req.GetZoneId(), "request_id", requestID)

	if req.GetZoneId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "zone_id is required")
	}

	var start, end time.Time
	if req.GetFrom() != nil {
		start = req.GetFrom().AsTime()
	}
	if req.GetTo() != nil {
		end = req.GetTo().AsTime()
	}

	logs, err := h.service.GetWaterUsage(ctx, req.GetZoneId(), start, end)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetWaterUsageResponse{
		Logs: mappers.WaterUsageLogsToProto(logs),
	}, nil
}

// Ensure models import is used.
var _ = (*models.IrrigationDecision)(nil)
