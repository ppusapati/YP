package handlers

import (
	"context"
	"fmt"
	"strconv"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/pest-prediction-service/api/v1"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/mappers"
	pestmodels "p9e.in/samavaya/agriculture/pest-prediction-service/internal/models"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/services"
)

// PestHandler implements the ConnectRPC PestPredictionService handler.
type PestHandler struct {
	d       deps.ServiceDeps
	service services.PestService
	log     *p9log.Helper
}

// NewPestHandler creates a new PestHandler.
func NewPestHandler(d deps.ServiceDeps, service services.PestService) *PestHandler {
	return &PestHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "PestHandler")),
	}
}

// PredictPestRisk handles pest risk prediction requests.
func (h *PestHandler) PredictPestRisk(ctx context.Context, req *pb.PredictPestRiskRequest) (*pb.PredictPestRiskResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "PredictPestRisk request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetPestSpeciesId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "pest_species_id is required")
	}
	if req.GetCropType() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "crop_type is required")
	}

	params := mappers.PredictPestRiskRequestToDomain(req, tenantID)

	prediction, err := h.service.PredictPestRisk(ctx, params)
	if err != nil {
		h.log.Errorw("msg", "PredictPestRisk failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.PredictPestRiskResponse{
		Prediction: mappers.PestPredictionToProto(prediction),
	}, nil
}

// GetPrediction handles get prediction requests.
func (h *PestHandler) GetPrediction(ctx context.Context, req *pb.GetPredictionRequest) (*pb.GetPredictionResponse, error) {
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
		Prediction: mappers.PestPredictionToProto(prediction),
	}, nil
}

// ListPredictions handles list predictions requests with filtering and pagination.
func (h *PestHandler) ListPredictions(ctx context.Context, req *pb.ListPredictionsRequest) (*pb.ListPredictionsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListPredictions request", "request_id", requestID)

	params := pestmodels.ListPredictionsParams{
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
		params.FarmID = &farmID
	}
	if req.GetFieldId() != "" {
		fieldID := req.GetFieldId()
		params.FieldID = &fieldID
	}
	if req.GetPestSpeciesId() != "" {
		speciesID := req.GetPestSpeciesId()
		params.PestSpeciesID = &speciesID
	}
	if req.GetMinRiskLevel() != pb.RiskLevel_RISK_LEVEL_UNSPECIFIED {
		rl := mappers.ProtoRiskLevelToDomain(req.GetMinRiskLevel())
		params.MinRiskLevel = &rl
	}

	predictions, totalCount, err := h.service.ListPredictions(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListPredictionsResponse{
		Predictions: mappers.PestPredictionsToProto(predictions),
		TotalCount:  int32(totalCount),
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// GetPestSpecies handles get pest species requests.
func (h *PestHandler) GetPestSpecies(ctx context.Context, req *pb.GetPestSpeciesRequest) (*pb.GetPestSpeciesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetPestSpecies request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "pest species ID is required")
	}

	species, err := h.service.GetPestSpecies(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetPestSpeciesResponse{
		Species: mappers.PestSpeciesToProto(species),
	}, nil
}

// ListPestSpecies handles list pest species requests with filtering and pagination.
func (h *PestHandler) ListPestSpecies(ctx context.Context, req *pb.ListPestSpeciesRequest) (*pb.ListPestSpeciesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListPestSpecies request", "request_id", requestID)

	params := pestmodels.ListPestSpeciesParams{
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
	if req.GetSearch() != "" {
		search := req.GetSearch()
		params.Search = &search
	}
	if req.GetCropType() != "" {
		cropType := req.GetCropType()
		params.CropType = &cropType
	}

	species, totalCount, err := h.service.ListPestSpecies(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListPestSpeciesResponse{
		Species:    mappers.PestSpeciesListToProto(species),
		TotalCount: int32(totalCount),
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// ReportObservation handles pest observation reporting requests.
func (h *PestHandler) ReportObservation(ctx context.Context, req *pb.ReportObservationRequest) (*pb.ReportObservationResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	h.log.Infow("msg", "ReportObservation request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetPestSpeciesId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "pest_species_id is required")
	}

	params := mappers.ReportObservationRequestToDomain(req, tenantID, userID)

	observation, err := h.service.ReportObservation(ctx, params)
	if err != nil {
		h.log.Errorw("msg", "ReportObservation failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.ReportObservationResponse{
		Observation: mappers.PestObservationToProto(observation),
	}, nil
}

// ListObservations handles list observations requests with filtering and pagination.
func (h *PestHandler) ListObservations(ctx context.Context, req *pb.ListObservationsRequest) (*pb.ListObservationsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListObservations request", "request_id", requestID)

	params := pestmodels.ListObservationsParams{
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
		params.FarmID = &farmID
	}
	if req.GetFieldId() != "" {
		fieldID := req.GetFieldId()
		params.FieldID = &fieldID
	}
	if req.GetPestSpeciesId() != "" {
		speciesID := req.GetPestSpeciesId()
		params.PestSpeciesID = &speciesID
	}

	observations, totalCount, err := h.service.ListObservations(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListObservationsResponse{
		Observations: mappers.PestObservationsToProto(observations),
		TotalCount:   int32(totalCount),
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// ListAlerts handles list alerts requests with filtering and pagination.
func (h *PestHandler) ListAlerts(ctx context.Context, req *pb.ListAlertsRequest) (*pb.ListAlertsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListAlerts request", "request_id", requestID)

	params := pestmodels.ListAlertsParams{
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
		params.FarmID = &farmID
	}
	if req.GetFieldId() != "" {
		fieldID := req.GetFieldId()
		params.FieldID = &fieldID
	}
	if req.GetStatus() != pb.AlertStatus_ALERT_STATUS_UNSPECIFIED {
		st := mappers.ProtoAlertStatusToDomain(req.GetStatus())
		params.Status = &st
	}
	if req.GetMinRiskLevel() != pb.RiskLevel_RISK_LEVEL_UNSPECIFIED {
		rl := mappers.ProtoRiskLevelToDomain(req.GetMinRiskLevel())
		params.MinRiskLevel = &rl
	}

	alerts, totalCount, err := h.service.ListAlerts(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListAlertsResponse{
		Alerts:     mappers.PestAlertsToProto(alerts),
		TotalCount: int32(totalCount),
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if int64(nextOffset) < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// AcknowledgeAlert handles alert acknowledgment requests.
func (h *PestHandler) AcknowledgeAlert(ctx context.Context, req *pb.AcknowledgeAlertRequest) (*pb.AcknowledgeAlertResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "AcknowledgeAlert request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "alert ID is required")
	}

	alert, err := h.service.AcknowledgeAlert(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.AcknowledgeAlertResponse{
		Alert: mappers.PestAlertToProto(alert),
	}, nil
}

// GetRiskMap handles get risk map requests.
func (h *PestHandler) GetRiskMap(ctx context.Context, req *pb.GetRiskMapRequest) (*pb.GetRiskMapResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetRiskMap request",
		"pest_species_id", req.GetPestSpeciesId(),
		"region", req.GetRegion(),
		"request_id", requestID,
	)

	if req.GetPestSpeciesId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "pest_species_id is required")
	}
	if req.GetRegion() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "region is required")
	}

	riskMap, err := h.service.GetRiskMap(ctx, req.GetPestSpeciesId(), req.GetRegion())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetRiskMapResponse{
		RiskMap: mappers.PestRiskMapToProto(riskMap),
	}, nil
}

// GetTreatmentPlan handles get treatment plan requests.
func (h *PestHandler) GetTreatmentPlan(ctx context.Context, req *pb.GetTreatmentPlanRequest) (*pb.GetTreatmentPlanResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetTreatmentPlan request", "prediction_id", req.GetPredictionId(), "request_id", requestID)

	if req.GetPredictionId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "prediction_id is required")
	}

	prediction, treatments, err := h.service.RecommendTreatments(ctx, req.GetPredictionId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetTreatmentPlanResponse{
		Prediction: mappers.PestPredictionToProto(prediction),
		Treatments: mappers.RecommendedTreatmentsToProto(treatments),
	}, nil
}
