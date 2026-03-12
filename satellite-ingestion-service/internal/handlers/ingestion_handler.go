package handlers

import (
	"context"
	"fmt"
	"strconv"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/satellite-ingestion-service/api/v1"
	"p9e.in/samavaya/agriculture/satellite-ingestion-service/internal/mappers"
	ingestionmodels "p9e.in/samavaya/agriculture/satellite-ingestion-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-ingestion-service/internal/services"
)

// IngestionHandler implements the ConnectRPC SatelliteIngestionService handler.
type IngestionHandler struct {
	d       deps.ServiceDeps
	service services.IngestionService
	log     *p9log.Helper
}

// NewIngestionHandler creates a new IngestionHandler.
func NewIngestionHandler(d deps.ServiceDeps, service services.IngestionService) *IngestionHandler {
	return &IngestionHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "IngestionHandler")),
	}
}

// RequestIngestion handles ingestion request creation.
func (h *IngestionHandler) RequestIngestion(ctx context.Context, req *pb.RequestIngestionRequest) (*pb.RequestIngestionResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	h.log.Infow("msg", "RequestIngestion request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetProvider() == pb.SatelliteProvider_SATELLITE_PROVIDER_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "provider is required")
	}

	task := mappers.RequestIngestionToDomain(req, tenantID, userID)

	created, err := h.service.RequestIngestion(ctx, task)
	if err != nil {
		h.log.Errorw("msg", "RequestIngestion failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.RequestIngestionResponse{
		Task: mappers.IngestionTaskToProto(created),
	}, nil
}

// GetIngestionTask handles get ingestion task requests.
func (h *IngestionHandler) GetIngestionTask(ctx context.Context, req *pb.GetIngestionTaskRequest) (*pb.GetIngestionTaskResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetIngestionTask request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "task ID is required")
	}

	task, err := h.service.GetIngestionTask(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetIngestionTaskResponse{
		Task: mappers.IngestionTaskToProto(task),
	}, nil
}

// ListIngestionTasks handles list ingestion tasks requests with filtering and pagination.
func (h *IngestionHandler) ListIngestionTasks(ctx context.Context, req *pb.ListIngestionTasksRequest) (*pb.ListIngestionTasksResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListIngestionTasks request", "request_id", requestID)

	params := ingestionmodels.ListIngestionTasksParams{
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			params.Offset = int32(offset)
		}
	}

	// Apply filters
	if req.GetFarmId() != "" {
		farmID := req.GetFarmId()
		params.FarmUUID = &farmID
	}
	if req.GetProvider() != pb.SatelliteProvider_SATELLITE_PROVIDER_UNSPECIFIED {
		provider := mappers.ProtoProviderToDomain(req.GetProvider())
		params.Provider = &provider
	}
	if req.GetStatus() != pb.IngestionStatus_INGESTION_STATUS_UNSPECIFIED {
		status := mappers.ProtoIngestionStatusToDomain(req.GetStatus())
		params.Status = &status
	}

	tasks, totalCount, err := h.service.ListIngestionTasks(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListIngestionTasksResponse{
		Tasks:      mappers.IngestionTasksToProto(tasks),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// CancelIngestion handles ingestion cancellation requests.
func (h *IngestionHandler) CancelIngestion(ctx context.Context, req *pb.CancelIngestionRequest) (*pb.CancelIngestionResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CancelIngestion request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "task ID is required")
	}

	_, err := h.service.CancelIngestion(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.CancelIngestionResponse{
		Success: true,
	}, nil
}

// RetryIngestion handles ingestion retry requests.
func (h *IngestionHandler) RetryIngestion(ctx context.Context, req *pb.RetryIngestionRequest) (*pb.RetryIngestionResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "RetryIngestion request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "task ID is required")
	}

	task, err := h.service.RetryIngestion(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.RetryIngestionResponse{
		Task: mappers.IngestionTaskToProto(task),
	}, nil
}

// GetIngestionStats handles ingestion statistics requests.
func (h *IngestionHandler) GetIngestionStats(ctx context.Context, req *pb.GetIngestionStatsRequest) (*pb.GetIngestionStatsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetIngestionStats request", "request_id", requestID)

	var farmUUID *string
	if req.GetFarmId() != "" {
		fid := req.GetFarmId()
		farmUUID = &fid
	}

	var provider *ingestionmodels.SatelliteProvider
	if req.GetProvider() != pb.SatelliteProvider_SATELLITE_PROVIDER_UNSPECIFIED {
		p := mappers.ProtoProviderToDomain(req.GetProvider())
		provider = &p
	}

	stats, err := h.service.GetIngestionStats(ctx, farmUUID, provider)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetIngestionStatsResponse{
		TotalTasks:       stats.TotalTasks,
		CompletedTasks:   stats.CompletedTasks,
		FailedTasks:      stats.FailedTasks,
		PendingTasks:     stats.PendingTasks,
		TotalBytesStored: stats.TotalBytesStored,
	}, nil
}
