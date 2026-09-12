package handlers

import (
	"context"
	"fmt"
	"strconv"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/satellite-processing-service/api/v1"
	"p9e.in/samavaya/agriculture/satellite-processing-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/satellite-processing-service/internal/mappers"
	procmodels "p9e.in/samavaya/agriculture/satellite-processing-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-processing-service/services"
)

// ProcessingHandler implements the ConnectRPC SatelliteProcessingServiceHandler interface.
type ProcessingHandler struct {
	v1connect.UnimplementedSatelliteProcessingServiceHandler

	d       deps.ServiceDeps
	service services.ProcessingService
	log     *p9log.Helper
}

// NewProcessingHandler creates a new ProcessingHandler.
func NewProcessingHandler(d deps.ServiceDeps, service services.ProcessingService) *ProcessingHandler {
	return &ProcessingHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "ProcessingHandler")),
	}
}

// SubmitProcessingJob handles processing job submission requests.
func (h *ProcessingHandler) SubmitProcessingJob(ctx context.Context, req *connect.Request[pb.SubmitProcessingJobRequest]) (*connect.Response[pb.SubmitProcessingJobResponse], error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	h.log.Infow("msg", "SubmitProcessingJob request", "tenant_id", tenantID, "request_id", requestID)

	if req.Msg.GetIngestionTaskId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "ingestion_task_id is required")
	}
	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	job := mappers.SubmitProcessingJobRequestToDomain(req.Msg, tenantID, userID)

	created, err := h.service.SubmitProcessingJob(ctx, job)
	if err != nil {
		h.log.Errorw("msg", "SubmitProcessingJob failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.SubmitProcessingJobResponse{
		Job: mappers.ProcessingJobToProto(created),
	}), nil
}

// GetProcessingJob handles get processing job requests.
func (h *ProcessingHandler) GetProcessingJob(ctx context.Context, req *connect.Request[pb.GetProcessingJobRequest]) (*connect.Response[pb.GetProcessingJobResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetProcessingJob request", "id", req.Msg.GetId(), "request_id", requestID)

	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "processing job ID is required")
	}

	job, err := h.service.GetProcessingJob(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetProcessingJobResponse{
		Job: mappers.ProcessingJobToProto(job),
	}), nil
}

// ListProcessingJobs handles list processing jobs requests with filtering and pagination.
func (h *ProcessingHandler) ListProcessingJobs(ctx context.Context, req *connect.Request[pb.ListProcessingJobsRequest]) (*connect.Response[pb.ListProcessingJobsResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListProcessingJobs request", "request_id", requestID)

	params := procmodels.ListProcessingJobsParams{
		PageSize: req.Msg.GetPageSize(),
	}

	// Parse page token as offset
	if req.Msg.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.Msg.GetPageToken(), 10, 32)
		if err == nil {
			params.Offset = int32(offset)
		}
	}

	// Apply filters
	if req.Msg.GetFarmId() != "" {
		farmID := req.Msg.GetFarmId()
		params.FarmUUID = &farmID
	}
	if req.Msg.GetStatus() != pb.ProcessingStatus_PROCESSING_STATUS_UNSPECIFIED {
		st := mappers.ProtoProcessingStatusToDomain(req.Msg.GetStatus())
		params.Status = &st
	}

	jobs, totalCount, err := h.service.ListProcessingJobs(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListProcessingJobsResponse{
		Jobs:       mappers.ProcessingJobsToProto(jobs),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return connect.NewResponse(resp), nil
}

// CancelProcessingJob handles processing job cancellation requests.
func (h *ProcessingHandler) CancelProcessingJob(ctx context.Context, req *connect.Request[pb.CancelProcessingJobRequest]) (*connect.Response[pb.CancelProcessingJobResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CancelProcessingJob request", "id", req.Msg.GetId(), "request_id", requestID)

	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "processing job ID is required")
	}

	err := h.service.CancelProcessingJob(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.CancelProcessingJobResponse{
		Success: true,
	}), nil
}

// GetProcessingStats handles processing stats requests.
func (h *ProcessingHandler) GetProcessingStats(ctx context.Context, req *connect.Request[pb.GetProcessingStatsRequest]) (*connect.Response[pb.GetProcessingStatsResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetProcessingStats request", "farm_id", req.Msg.GetFarmId(), "request_id", requestID)

	stats, err := h.service.GetProcessingStats(ctx, req.Msg.GetFarmId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(mappers.ProcessingStatsToProto(stats)), nil
}
