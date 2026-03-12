package handlers

import (
	"context"
	"fmt"
	"strconv"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/yield-service/api/v1"
	"p9e.in/samavaya/agriculture/yield-service/internal/mappers"
	"p9e.in/samavaya/agriculture/yield-service/internal/models"
	"p9e.in/samavaya/agriculture/yield-service/internal/services"
)

// YieldHandler implements the ConnectRPC YieldService handler.
type YieldHandler struct {
	d       deps.ServiceDeps
	service services.YieldService
	log     *p9log.Helper
}

// NewYieldHandler creates a new YieldHandler.
func NewYieldHandler(d deps.ServiceDeps, service services.YieldService) *YieldHandler {
	return &YieldHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "YieldHandler")),
	}
}

// PredictYield handles yield prediction requests.
func (h *YieldHandler) PredictYield(ctx context.Context, req *pb.PredictYieldRequest) (*pb.PredictYieldResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "PredictYield request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetCropId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_id is required")
	}
	if req.GetSeason() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "season is required")
	}
	if req.GetYear() <= 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "year must be positive")
	}

	input := &services.PredictYieldInput{
		FarmID:       req.GetFarmId(),
		FieldID:      req.GetFieldId(),
		CropID:       req.GetCropId(),
		Season:       req.GetSeason(),
		Year:         req.GetYear(),
		YieldFactors: mappers.YieldFactorsFromProto(req.GetYieldFactors()),
	}

	prediction, err := h.service.PredictYield(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "PredictYield failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.PredictYieldResponse{
		Prediction: mappers.YieldPredictionToProto(prediction),
	}, nil
}

// GetPrediction handles get prediction requests.
func (h *YieldHandler) GetPrediction(ctx context.Context, req *pb.GetPredictionRequest) (*pb.GetPredictionResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetPrediction request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "prediction ID is required")
	}

	prediction, err := h.service.GetPrediction(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetPredictionResponse{
		Prediction: mappers.YieldPredictionToProto(prediction),
	}, nil
}

// ListPredictions handles list predictions requests with filtering and pagination.
func (h *YieldHandler) ListPredictions(ctx context.Context, req *pb.ListPredictionsRequest) (*pb.ListPredictionsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListPredictions request", "request_id", requestID)

	input := &services.ListPredictionsInput{
		FarmID:   req.GetFarmId(),
		FieldID:  req.GetFieldId(),
		CropID:   req.GetCropId(),
		Season:   req.GetSeason(),
		Year:     req.GetYear(),
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			input.Offset = int32(offset)
		}
	}

	// Apply status filter
	if req.GetStatus() != pb.PredictionStatus_PREDICTION_STATUS_UNSPECIFIED {
		input.Status = mappers.PredictionStatusFromProto(req.GetStatus())
	}

	predictions, totalCount, err := h.service.ListPredictions(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListPredictionsResponse{
		Predictions: mappers.YieldPredictionsToProto(predictions),
		TotalCount:  int32(totalCount),
	}

	// Compute next page token
	nextOffset := input.Offset + input.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// RecordYield handles recording actual yield data.
func (h *YieldHandler) RecordYield(ctx context.Context, req *pb.RecordYieldRequest) (*pb.RecordYieldResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "RecordYield request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetCropId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_id is required")
	}
	if req.GetActualYieldKgPerHectare() <= 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "actual_yield_kg_per_hectare must be positive")
	}

	input := &services.RecordYieldInput{
		FarmID:                     req.GetFarmId(),
		FieldID:                    req.GetFieldId(),
		CropID:                     req.GetCropId(),
		Season:                     req.GetSeason(),
		Year:                       req.GetYear(),
		ActualYieldKgPerHectare:    req.GetActualYieldKgPerHectare(),
		TotalAreaHarvestedHectares: req.GetTotalAreaHarvestedHectares(),
		TotalYieldKg:               req.GetTotalYieldKg(),
		HarvestQualityGrade:        mappers.QualityGradeFromProto(req.GetHarvestQualityGrade()),
		MoistureContentPct:         req.GetMoistureContentPct(),
		RevenuePerHectare:          req.GetRevenuePerHectare(),
		CostPerHectare:             req.GetCostPerHectare(),
		PredictionID:               req.GetPredictionId(),
	}

	// Set harvest date if provided
	if req.GetHarvestDate() != nil {
		t := req.GetHarvestDate().AsTime()
		input.HarvestDate = &models.HarvestDateInputType{Time: t}
	}

	record, err := h.service.RecordYield(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "RecordYield failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.RecordYieldResponse{
		Record: mappers.YieldRecordToProto(record),
	}, nil
}

// GetYieldHistory handles retrieving historical yield records.
func (h *YieldHandler) GetYieldHistory(ctx context.Context, req *pb.GetYieldHistoryRequest) (*pb.GetYieldHistoryResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetYieldHistory request", "request_id", requestID)

	input := &services.GetYieldHistoryInput{
		FarmID:   req.GetFarmId(),
		FieldID:  req.GetFieldId(),
		CropID:   req.GetCropId(),
		FromYear: req.GetFromYear(),
		ToYear:   req.GetToYear(),
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			input.Offset = int32(offset)
		}
	}

	records, totalCount, err := h.service.GetYieldHistory(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.GetYieldHistoryResponse{
		Records:    mappers.YieldRecordsToProto(records),
		TotalCount: int32(totalCount),
	}

	// Compute next page token
	nextOffset := input.Offset + input.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// CreateHarvestPlan handles harvest plan creation requests.
func (h *YieldHandler) CreateHarvestPlan(ctx context.Context, req *pb.CreateHarvestPlanRequest) (*pb.CreateHarvestPlanResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "CreateHarvestPlan request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetCropId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_id is required")
	}
	if req.GetPlannedStartDate() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "planned_start_date is required")
	}
	if req.GetPlannedEndDate() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "planned_end_date is required")
	}

	input := &services.CreateHarvestPlanInput{
		FarmID:            req.GetFarmId(),
		FieldID:           req.GetFieldId(),
		CropID:            req.GetCropId(),
		Season:            req.GetSeason(),
		Year:              req.GetYear(),
		PlannedStartDate:  models.PlanDateInput{Time: req.GetPlannedStartDate().AsTime()},
		PlannedEndDate:    models.PlanDateInput{Time: req.GetPlannedEndDate().AsTime()},
		EstimatedYieldKg:  req.GetEstimatedYieldKg(),
		TotalAreaHectares: req.GetTotalAreaHectares(),
		Notes:             req.GetNotes(),
	}

	plan, err := h.service.CreateHarvestPlan(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "CreateHarvestPlan failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateHarvestPlanResponse{
		Plan: mappers.HarvestPlanToProto(plan),
	}, nil
}

// GetHarvestPlan handles get harvest plan requests.
func (h *YieldHandler) GetHarvestPlan(ctx context.Context, req *pb.GetHarvestPlanRequest) (*pb.GetHarvestPlanResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetHarvestPlan request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "harvest plan ID is required")
	}

	plan, err := h.service.GetHarvestPlan(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetHarvestPlanResponse{
		Plan: mappers.HarvestPlanToProto(plan),
	}, nil
}

// ListHarvestPlans handles list harvest plans requests with filtering and pagination.
func (h *YieldHandler) ListHarvestPlans(ctx context.Context, req *pb.ListHarvestPlansRequest) (*pb.ListHarvestPlansResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListHarvestPlans request", "request_id", requestID)

	input := &services.ListHarvestPlansInput{
		FarmID:   req.GetFarmId(),
		FieldID:  req.GetFieldId(),
		CropID:   req.GetCropId(),
		Season:   req.GetSeason(),
		Year:     req.GetYear(),
		PageSize: req.GetPageSize(),
	}

	// Parse page token as offset
	if req.GetPageToken() != "" {
		offset, err := strconv.ParseInt(req.GetPageToken(), 10, 32)
		if err == nil {
			input.Offset = int32(offset)
		}
	}

	// Apply status filter
	if req.GetStatus() != pb.HarvestPlanStatus_HARVEST_PLAN_STATUS_UNSPECIFIED {
		input.Status = mappers.HarvestPlanStatusFromProto(req.GetStatus())
	}

	plans, totalCount, err := h.service.ListHarvestPlans(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListHarvestPlansResponse{
		Plans:      mappers.HarvestPlansToProto(plans),
		TotalCount: int32(totalCount),
	}

	// Compute next page token
	nextOffset := input.Offset + input.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// GetCropPerformance handles crop performance analytics requests.
func (h *YieldHandler) GetCropPerformance(ctx context.Context, req *pb.GetCropPerformanceRequest) (*pb.GetCropPerformanceResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetCropPerformance request",
		"farm_id", req.GetFarmId(),
		"field_id", req.GetFieldId(),
		"crop_id", req.GetCropId(),
		"request_id", requestID,
	)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetCropId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_id is required")
	}
	if req.GetSeason() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "season is required")
	}
	if req.GetYear() <= 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "year must be positive")
	}

	input := &services.GetCropPerformanceInput{
		FarmID:  req.GetFarmId(),
		FieldID: req.GetFieldId(),
		CropID:  req.GetCropId(),
		Season:  req.GetSeason(),
		Year:    req.GetYear(),
	}

	performance, err := h.service.GetCropPerformance(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetCropPerformanceResponse{
		Performance: mappers.CropPerformanceToProto(performance),
	}, nil
}

// CompareYields handles yield comparison requests between two seasons or years.
func (h *YieldHandler) CompareYields(ctx context.Context, req *pb.CompareYieldsRequest) (*pb.CompareYieldsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "CompareYields request",
		"farm_id", req.GetFarmId(),
		"year_a", req.GetYearA(),
		"year_b", req.GetYearB(),
		"request_id", requestID,
	)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetCropId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_id is required")
	}
	if req.GetYearA() <= 0 || req.GetYearB() <= 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "year_a and year_b must be positive")
	}
	if req.GetSeasonA() == "" || req.GetSeasonB() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "season_a and season_b are required")
	}

	input := &services.CompareYieldsInput{
		FarmID:  req.GetFarmId(),
		FieldID: req.GetFieldId(),
		CropID:  req.GetCropId(),
		YearA:   req.GetYearA(),
		SeasonA: req.GetSeasonA(),
		YearB:   req.GetYearB(),
		SeasonB: req.GetSeasonB(),
	}

	result, err := h.service.CompareYields(ctx, input)
	if err != nil {
		h.log.Errorw("msg", "CompareYields failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CompareYieldsResponse{
		PerformanceA:                mappers.CropPerformanceToProto(result.PerformanceA),
		PerformanceB:                mappers.CropPerformanceToProto(result.PerformanceB),
		YieldDifferenceKgPerHectare: result.YieldDifferenceKgPerHectare,
		YieldDifferencePct:          result.YieldDifferencePct,
		ProfitDifferencePerHectare:  result.ProfitDifferencePerHectare,
	}, nil
}
