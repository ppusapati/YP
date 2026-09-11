package handlers

import (
	"context"

	"connectrpc.com/connect"

	pb "p9e.in/samavaya/agriculture/agronomy-service/api/v1"
	"p9e.in/samavaya/agriculture/agronomy-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/agronomy-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// InspectionHandler implements the ConnectRPC InspectionServiceHandler interface.
type InspectionHandler struct {
	v1connect.UnimplementedInspectionServiceHandler

	svc    services.InspectionService
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewInspectionHandler creates a new InspectionHandler.
func NewInspectionHandler(d deps.ServiceDeps, svc services.InspectionService) *InspectionHandler {
	return &InspectionHandler{
		svc:    svc,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "inspection_handler")),
	}
}

// GetInspection handles the GetInspection RPC.
func (h *InspectionHandler) GetInspection(ctx context.Context, req *connect.Request[pb.GetInspectionRequest]) (*connect.Response[pb.GetInspectionResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	inspection, err := h.svc.GetInspection(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetInspectionResponse{Inspection: inspection}), nil
}

// ListInspections handles the ListInspections RPC.
func (h *InspectionHandler) ListInspections(ctx context.Context, req *connect.Request[pb.ListInspectionsRequest]) (*connect.Response[pb.ListInspectionsResponse], error) {
	inspections, nextPageToken, totalCount, err := h.svc.ListInspections(ctx, services.ListInspectionsInput{
		FarmID:      req.Msg.GetFarmId(),
		FieldID:     req.Msg.GetFieldId(),
		InspectorID: req.Msg.GetInspectorId(),
		Status:      req.Msg.GetStatus(),
		PageSize:    req.Msg.GetPageSize(),
		PageToken:   req.Msg.GetPageToken(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ListInspectionsResponse{
		Inspections:   inspections,
		NextPageToken: nextPageToken,
		TotalCount:    totalCount,
	}), nil
}

// CreateInspection handles the CreateInspection RPC.
func (h *InspectionHandler) CreateInspection(ctx context.Context, req *connect.Request[pb.CreateInspectionRequest]) (*connect.Response[pb.CreateInspectionResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}

	inspectorID := p9context.UserID(ctx)

	inspection, err := h.svc.CreateInspection(ctx, req.Msg, inspectorID)
	if err != nil {
		h.logger.Errorf("CreateInspection failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.CreateInspectionResponse{Inspection: inspection}), nil
}

// SubmitInspection handles the SubmitInspection RPC.
func (h *InspectionHandler) SubmitInspection(ctx context.Context, req *connect.Request[pb.SubmitInspectionRequest]) (*connect.Response[pb.SubmitInspectionResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	inspection, err := h.svc.SubmitInspection(ctx, req.Msg.GetId())
	if err != nil {
		h.logger.Errorf("SubmitInspection failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.SubmitInspectionResponse{Inspection: inspection}), nil
}
