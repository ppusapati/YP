package handlers

import (
	"context"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	pb "p9e.in/samavaya/agriculture/soil-service/api/v1"
	"p9e.in/samavaya/agriculture/soil-service/internal/mappers"
	"p9e.in/samavaya/agriculture/soil-service/internal/services"
)

// SoilHandler implements the ConnectRPC SoilService handler.
type SoilHandler struct {
	d       deps.ServiceDeps
	service services.SoilService
	log     *p9log.Helper
}

// NewSoilHandler creates a new SoilHandler.
func NewSoilHandler(d deps.ServiceDeps, service services.SoilService) *SoilHandler {
	return &SoilHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "SoilHandler")),
	}
}

// CreateSoilSample handles soil sample creation requests.
func (h *SoilHandler) CreateSoilSample(ctx context.Context, req *pb.CreateSoilSampleRequest) (*pb.CreateSoilSampleResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	h.log.Infow("msg", "CreateSoilSample request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	sample := mappers.SoilSampleFromCreateRequest(req, ulid.NewString(), userID)
	if tenantID != "" {
		sample.TenantID = tenantID
	}

	created, err := h.service.CreateSoilSample(ctx, sample)
	if err != nil {
		h.log.Errorw("msg", "CreateSoilSample failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateSoilSampleResponse{
		Sample: mappers.SoilSampleToProto(created),
	}, nil
}

// GetSoilSample handles get soil sample requests.
func (h *SoilHandler) GetSoilSample(ctx context.Context, req *pb.GetSoilSampleRequest) (*pb.GetSoilSampleResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetSoilSample request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample ID is required")
	}

	sample, err := h.service.GetSoilSample(ctx, req.GetId(), req.GetTenantId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetSoilSampleResponse{
		Sample: mappers.SoilSampleToProto(sample),
	}, nil
}

// ListSoilSamples handles list soil samples requests with filtering and pagination.
func (h *SoilHandler) ListSoilSamples(ctx context.Context, req *pb.ListSoilSamplesRequest) (*pb.ListSoilSamplesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListSoilSamples request", "request_id", requestID)

	samples, totalCount, err := h.service.ListSoilSamples(ctx, req.GetTenantId(), req.GetFieldId(), req.GetFarmId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	nextOffset := req.GetPageOffset() + req.GetPageSize()
	hasNext := int64(nextOffset) < totalCount

	return &pb.ListSoilSamplesResponse{
		Samples:    mappers.SoilSamplesToProto(samples),
		TotalCount: int32(totalCount),
		HasNext:    hasNext,
	}, nil
}

// AnalyzeSoil handles soil analysis requests.
func (h *SoilHandler) AnalyzeSoil(ctx context.Context, req *pb.AnalyzeSoilRequest) (*pb.AnalyzeSoilResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "AnalyzeSoil request", "sample_id", req.GetSampleId(), "request_id", requestID)

	if req.GetSampleId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample_id is required")
	}

	analysis, err := h.service.AnalyzeSoil(ctx, req.GetSampleId(), req.GetTenantId(), req.GetAnalysisType())
	if err != nil {
		h.log.Errorw("msg", "AnalyzeSoil failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.AnalyzeSoilResponse{
		Analysis: mappers.SoilAnalysisToProto(analysis),
	}, nil
}

// ListSoilAnalyses handles list soil analyses requests with filtering and pagination.
func (h *SoilHandler) ListSoilAnalyses(ctx context.Context, req *pb.ListSoilAnalysesRequest) (*pb.ListSoilAnalysesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListSoilAnalyses request", "request_id", requestID)

	analyses, totalCount, err := h.service.ListSoilAnalyses(ctx, req.GetTenantId(), req.GetFieldId(), req.GetFarmId(), req.GetSampleId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	nextOffset := req.GetPageOffset() + req.GetPageSize()
	hasNext := int64(nextOffset) < totalCount

	return &pb.ListSoilAnalysesResponse{
		Analyses:   mappers.SoilAnalysesToProto(analyses),
		TotalCount: int32(totalCount),
		HasNext:    hasNext,
	}, nil
}

// GetSoilMap handles get soil map requests.
func (h *SoilHandler) GetSoilMap(ctx context.Context, req *pb.GetSoilMapRequest) (*pb.GetSoilMapResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetSoilMap request", "field_id", req.GetFieldId(), "request_id", requestID)

	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	soilMap, err := h.service.GetSoilMap(ctx, req.GetFieldId(), req.GetTenantId(), req.GetMapType())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetSoilMapResponse{
		SoilMap: mappers.SoilMapToProto(soilMap),
	}, nil
}

// GetSoilHealth handles get soil health requests.
func (h *SoilHandler) GetSoilHealth(ctx context.Context, req *pb.GetSoilHealthRequest) (*pb.GetSoilHealthResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetSoilHealth request", "field_id", req.GetFieldId(), "request_id", requestID)

	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	healthScore, err := h.service.GetSoilHealth(ctx, req.GetFieldId(), req.GetTenantId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetSoilHealthResponse{
		HealthScore: mappers.SoilHealthScoreToProto(healthScore),
	}, nil
}

// GetNutrientLevels handles get nutrient levels requests.
func (h *SoilHandler) GetNutrientLevels(ctx context.Context, req *pb.GetNutrientLevelsRequest) (*pb.GetNutrientLevelsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetNutrientLevels request", "sample_id", req.GetSampleId(), "request_id", requestID)

	if req.GetSampleId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample_id is required")
	}

	nutrients, err := h.service.GetNutrientLevels(ctx, req.GetSampleId(), req.GetTenantId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetNutrientLevelsResponse{
		Nutrients: mappers.SoilNutrientsToProto(nutrients),
	}, nil
}

// GenerateSoilReport handles soil report generation requests.
func (h *SoilHandler) GenerateSoilReport(ctx context.Context, req *pb.GenerateSoilReportRequest) (*pb.GenerateSoilReportResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "GenerateSoilReport request", "field_id", req.GetFieldId(), "request_id", requestID)

	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	reqTenantID := req.GetTenantId()
	if tenantID != "" {
		reqTenantID = tenantID
	}

	report, err := h.service.GenerateSoilReport(ctx, req.GetFieldId(), reqTenantID, req.GetFarmId())
	if err != nil {
		h.log.Errorw("msg", "GenerateSoilReport failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.GenerateSoilReportResponse{
		Report: mappers.SoilReportToProto(report, ulid.NewString(), reqTenantID, req.GetFieldId(), req.GetFarmId()),
	}, nil
}
