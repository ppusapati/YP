package handlers

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/vegetation-index-service/api/v1"
	"p9e.in/samavaya/agriculture/vegetation-index-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/vegetation-index-service/internal/mappers"
	vimodels "p9e.in/samavaya/agriculture/vegetation-index-service/internal/models"
	"p9e.in/samavaya/agriculture/vegetation-index-service/internal/services"
)

// VegetationIndexHandler implements the ConnectRPC VegetationIndexServiceHandler interface.
type VegetationIndexHandler struct {
	v1connect.UnimplementedVegetationIndexServiceHandler

	d       deps.ServiceDeps
	service services.VegetationIndexService
	log     *p9log.Helper
}

// NewVegetationIndexHandler creates a new VegetationIndexHandler.
func NewVegetationIndexHandler(d deps.ServiceDeps, service services.VegetationIndexService) *VegetationIndexHandler {
	return &VegetationIndexHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "VegetationIndexHandler")),
	}
}

// ComputeIndices handles index computation requests.
func (h *VegetationIndexHandler) ComputeIndices(ctx context.Context, req *connect.Request[pb.ComputeIndicesRequest]) (*connect.Response[pb.ComputeIndicesResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ComputeIndices request",
		"processing_job_id", req.Msg.GetProcessingJobId(),
		"farm_id", req.Msg.GetFarmId(),
		"request_id", requestID,
	)

	if req.Msg.GetProcessingJobId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "processing_job_id is required")
	}
	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if len(req.Msg.GetIndexTypes()) == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "at least one index type is required")
	}

	// Convert proto index types to domain types
	indexTypes := mappers.ProtoIndexTypesToDomain(req.Msg.GetIndexTypes())

	task, err := h.service.ComputeIndices(ctx, req.Msg.GetProcessingJobId(), req.Msg.GetFarmId(), indexTypes)
	if err != nil {
		h.log.Errorw("msg", "ComputeIndices failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.ComputeIndicesResponse{
		Task: mappers.ComputeTaskToProto(task),
	}), nil
}

// GetVegetationIndex handles get vegetation index requests.
func (h *VegetationIndexHandler) GetVegetationIndex(ctx context.Context, req *connect.Request[pb.GetVegetationIndexRequest]) (*connect.Response[pb.GetVegetationIndexResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetVegetationIndex request", "id", req.Msg.GetId(), "request_id", requestID)

	if req.Msg.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "vegetation index ID is required")
	}

	vi, err := h.service.GetVegetationIndex(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetVegetationIndexResponse{
		Index: mappers.VegetationIndexToProto(vi),
	}), nil
}

// ListVegetationIndices handles list vegetation indices requests with filtering and pagination.
func (h *VegetationIndexHandler) ListVegetationIndices(ctx context.Context, req *connect.Request[pb.ListVegetationIndicesRequest]) (*connect.Response[pb.ListVegetationIndicesResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListVegetationIndices request", "request_id", requestID)

	params := vimodels.ListVegetationIndicesParams{
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
	if req.Msg.GetFieldId() != "" {
		fieldID := req.Msg.GetFieldId()
		params.FieldUUID = &fieldID
	}
	if req.Msg.GetIndexType() != pb.VegetationIndexType_VEGETATION_INDEX_TYPE_UNSPECIFIED {
		it := mappers.ProtoIndexTypeToDomain(req.Msg.GetIndexType())
		params.IndexType = &it
	}
	if req.Msg.GetDateFrom() != nil {
		dateFrom := req.Msg.GetDateFrom().AsTime()
		params.DateFrom = &dateFrom
	}
	if req.Msg.GetDateTo() != nil {
		dateTo := req.Msg.GetDateTo().AsTime()
		params.DateTo = &dateTo
	}

	indices, totalCount, err := h.service.ListVegetationIndices(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListVegetationIndicesResponse{
		Indices:    mappers.VegetationIndicesToProto(indices),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return connect.NewResponse(resp), nil
}

// GetNDVITimeSeries handles NDVI time series requests.
func (h *VegetationIndexHandler) GetNDVITimeSeries(ctx context.Context, req *connect.Request[pb.GetNDVITimeSeriesRequest]) (*connect.Response[pb.GetNDVITimeSeriesResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetNDVITimeSeries request",
		"farm_id", req.Msg.GetFarmId(),
		"field_id", req.Msg.GetFieldId(),
		"request_id", requestID,
	)

	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	var fieldID *string
	if req.Msg.GetFieldId() != "" {
		fid := req.Msg.GetFieldId()
		fieldID = &fid
	}

	var dateFrom, dateTo *time.Time
	if req.Msg.GetDateFrom() != nil {
		df := req.Msg.GetDateFrom().AsTime()
		dateFrom = &df
	}
	if req.Msg.GetDateTo() != nil {
		dt := req.Msg.GetDateTo().AsTime()
		dateTo = &dt
	}

	points, resolvedFieldID, err := h.service.GetNDVITimeSeries(ctx, req.Msg.GetFarmId(), fieldID, dateFrom, dateTo)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetNDVITimeSeriesResponse{
		TimeSeries: &pb.NDVITimeSeries{
			FarmId:  req.Msg.GetFarmId(),
			FieldId: resolvedFieldID,
			Points:  mappers.TimeSeriesPointsToProto(points),
		},
	}), nil
}

// GetFieldHealth handles field health requests.
func (h *VegetationIndexHandler) GetFieldHealth(ctx context.Context, req *connect.Request[pb.GetFieldHealthRequest]) (*connect.Response[pb.GetFieldHealthResponse], error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetFieldHealth request",
		"farm_id", req.Msg.GetFarmId(),
		"field_id", req.Msg.GetFieldId(),
		"request_id", requestID,
	)

	if req.Msg.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	var fieldID *string
	if req.Msg.GetFieldId() != "" {
		fid := req.Msg.GetFieldId()
		fieldID = &fid
	}

	summary, err := h.service.GetFieldHealth(ctx, req.Msg.GetFarmId(), fieldID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetFieldHealthResponse{
		CurrentNdvi:    summary.CurrentNDVI,
		NdviTrend:      summary.NDVITrend,
		HealthScore:    summary.HealthScore,
		HealthCategory: summary.HealthCategory,
		LastComputed:   timestamppb.New(summary.LastComputed),
	}), nil
}
