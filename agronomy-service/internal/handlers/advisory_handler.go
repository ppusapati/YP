package handlers

import (
	"context"

	"connectrpc.com/connect"

	pb "p9e.in/samavaya/agriculture/agronomy-service/api/v1"
	"p9e.in/samavaya/agriculture/agronomy-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/agronomy-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

// AdvisoryHandler implements the ConnectRPC AdvisoryServiceHandler interface.
type AdvisoryHandler struct {
	v1connect.UnimplementedAdvisoryServiceHandler

	svc    services.AdvisoryService
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewAdvisoryHandler creates a new AdvisoryHandler.
func NewAdvisoryHandler(d deps.ServiceDeps, svc services.AdvisoryService) *AdvisoryHandler {
	return &AdvisoryHandler{
		svc:    svc,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "advisory_handler")),
	}
}

// GetAdvisory handles the GetAdvisory RPC.
func (h *AdvisoryHandler) GetAdvisory(ctx context.Context, req *connect.Request[pb.GetAdvisoryRequest]) (*connect.Response[pb.GetAdvisoryResponse], error) {
	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("MISSING_ID", "id is required")
	}

	advisory, err := h.svc.GetAdvisory(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetAdvisoryResponse{Advisory: advisory}), nil
}

// ListAdvisories handles the ListAdvisories RPC.
func (h *AdvisoryHandler) ListAdvisories(ctx context.Context, req *connect.Request[pb.ListAdvisoriesRequest]) (*connect.Response[pb.ListAdvisoriesResponse], error) {
	advisories, nextPageToken, totalCount, err := h.svc.ListAdvisories(ctx, services.ListAdvisoriesInput{
		FarmID:    req.Msg.GetFarmId(),
		FieldID:   req.Msg.GetFieldId(),
		CropType:  req.Msg.GetCropType(),
		Severity:  req.Msg.GetSeverity(),
		Region:    req.Msg.GetRegion(),
		PageSize:  req.Msg.GetPageSize(),
		PageToken: req.Msg.GetPageToken(),
	})
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ListAdvisoriesResponse{
		Advisories:    advisories,
		NextPageToken: nextPageToken,
		TotalCount:    totalCount,
	}), nil
}

// CreateAdvisory handles the CreateAdvisory RPC.
func (h *AdvisoryHandler) CreateAdvisory(ctx context.Context, req *connect.Request[pb.CreateAdvisoryRequest]) (*connect.Response[pb.CreateAdvisoryResponse], error) {
	if req.Msg.GetTitle() == "" {
		return nil, errors.BadRequest("MISSING_TITLE", "title is required")
	}
	if req.Msg.GetContent() == "" {
		return nil, errors.BadRequest("MISSING_CONTENT", "content is required")
	}

	advisory, err := h.svc.CreateAdvisory(ctx, req.Msg)
	if err != nil {
		h.logger.Errorf("CreateAdvisory failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.CreateAdvisoryResponse{Advisory: advisory}), nil
}
