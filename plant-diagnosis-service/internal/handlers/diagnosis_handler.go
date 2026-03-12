package handlers

import (
	"context"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/plant-diagnosis-service/api/v1"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/mappers"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/models"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/services"
)

// DiagnosisHandler implements the ConnectRPC PlantDiagnosisService handler.
type DiagnosisHandler struct {
	d       deps.ServiceDeps
	service services.DiagnosisService
	log     *p9log.Helper
}

// NewDiagnosisHandler creates a new DiagnosisHandler.
func NewDiagnosisHandler(d deps.ServiceDeps, service services.DiagnosisService) *DiagnosisHandler {
	return &DiagnosisHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "DiagnosisHandler")),
	}
}

// SubmitDiagnosis handles submission of a new plant diagnosis request with images.
func (h *DiagnosisHandler) SubmitDiagnosis(ctx context.Context, req *pb.SubmitDiagnosisRequest) (*pb.SubmitDiagnosisResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "SubmitDiagnosis request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if len(req.GetImages()) == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "at least one image is required")
	}

	images := mappers.ImageInputsToModels(req.GetImages())

	params := services.SubmitDiagnosisParams{
		FarmID:         req.GetFarmId(),
		FieldID:        req.GetFieldId(),
		PlantSpeciesID: req.GetPlantSpeciesId(),
		Images:         images,
		Notes:          req.GetNotes(),
	}

	diagnosis, err := h.service.SubmitDiagnosis(ctx, params)
	if err != nil {
		h.log.Errorw("msg", "SubmitDiagnosis failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.SubmitDiagnosisResponse{
		Diagnosis: mappers.DiagnosisRequestToProto(diagnosis),
	}, nil
}

// GetDiagnosis handles get diagnosis by ID requests.
func (h *DiagnosisHandler) GetDiagnosis(ctx context.Context, req *pb.GetDiagnosisRequest) (*pb.GetDiagnosisResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetDiagnosis request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "diagnosis ID is required")
	}

	diagnosis, err := h.service.GetDiagnosis(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetDiagnosisResponse{
		Diagnosis: mappers.DiagnosisRequestToProto(diagnosis),
	}, nil
}

// ListDiagnoses handles list diagnoses requests with filtering and pagination.
func (h *DiagnosisHandler) ListDiagnoses(ctx context.Context, req *pb.ListDiagnosesRequest) (*pb.ListDiagnosesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListDiagnoses request", "request_id", requestID)

	params := services.ListDiagnosesParams{
		FarmID:     req.GetFarmId(),
		FieldID:    req.GetFieldId(),
		PageSize:   req.GetPageSize(),
		PageOffset: req.GetPageOffset(),
		SortDesc:   req.GetSortDesc(),
	}

	if req.GetStatus() != pb.DiagnosisStatus_DIAGNOSIS_STATUS_UNSPECIFIED {
		params.Status = diagnosisStatusToString(req.GetStatus())
	}

	diagnoses, totalCount, err := h.service.ListDiagnoses(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	protoDiagnoses := make([]*pb.DiagnosisRequest, 0, len(diagnoses))
	for _, d := range diagnoses {
		protoDiagnoses = append(protoDiagnoses, mappers.DiagnosisRequestToProto(d))
	}

	return &pb.ListDiagnosesResponse{
		Diagnoses:  protoDiagnoses,
		TotalCount: int32(totalCount),
	}, nil
}

// GetDiseaseInfo handles get disease information by ID requests.
func (h *DiagnosisHandler) GetDiseaseInfo(ctx context.Context, req *pb.GetDiseaseInfoRequest) (*pb.GetDiseaseInfoResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetDiseaseInfo request", "disease_id", req.GetDiseaseId(), "request_id", requestID)

	if req.GetDiseaseId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "disease_id is required")
	}

	disease, err := h.service.GetDiseaseInfo(ctx, req.GetDiseaseId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetDiseaseInfoResponse{
		Disease: mappers.DiseaseCatalogToProto(disease),
	}, nil
}

// ListDiseases handles list all known diseases requests with search and pagination.
func (h *DiagnosisHandler) ListDiseases(ctx context.Context, req *pb.ListDiseasesRequest) (*pb.ListDiseasesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListDiseases request", "request_id", requestID)

	diseases, totalCount, err := h.service.ListDiseases(ctx, req.GetSearchTerm(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	protoDiseases := make([]*pb.DiseaseInfo, 0, len(diseases))
	for _, d := range diseases {
		protoDiseases = append(protoDiseases, mappers.DiseaseCatalogToProto(d))
	}

	return &pb.ListDiseasesResponse{
		Diseases:   protoDiseases,
		TotalCount: int32(totalCount),
	}, nil
}

// GetTreatmentPlan handles get treatment plan for a diagnosis requests.
func (h *DiagnosisHandler) GetTreatmentPlan(ctx context.Context, req *pb.GetTreatmentPlanRequest) (*pb.GetTreatmentPlanResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetTreatmentPlan request", "diagnosis_id", req.GetDiagnosisId(), "request_id", requestID)

	if req.GetDiagnosisId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "diagnosis_id is required")
	}

	plan, err := h.service.GetTreatmentPlan(ctx, req.GetDiagnosisId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetTreatmentPlanResponse{
		TreatmentPlan: mappers.TreatmentPlanToProto(plan),
	}, nil
}

// IdentifySpecies handles plant species identification from images.
func (h *DiagnosisHandler) IdentifySpecies(ctx context.Context, req *pb.IdentifySpeciesRequest) (*pb.IdentifySpeciesResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "IdentifySpecies request", "request_id", requestID)

	if len(req.GetImages()) == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "at least one image is required")
	}

	images := mappers.ImageInputsToModels(req.GetImages())

	aiResp, err := h.service.IdentifySpecies(ctx, images)
	if err != nil {
		h.log.Errorw("msg", "IdentifySpecies failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	var species []*pb.PlantSpecies
	if aiResp.Species != nil {
		species = append(species, mappers.IdentifiedSpeciesToProto(aiResp.Species))
	}

	return &pb.IdentifySpeciesResponse{
		Species:          species,
		AiModelVersion:   aiResp.ModelVersion,
		ProcessingTimeMs: aiResp.ProcessingTimeMs,
	}, nil
}

// DetectNutrientDeficiency handles nutrient deficiency detection from images.
func (h *DiagnosisHandler) DetectNutrientDeficiency(ctx context.Context, req *pb.DetectNutrientDeficiencyRequest) (*pb.DetectNutrientDeficiencyResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DetectNutrientDeficiency request", "request_id", requestID)

	if len(req.GetImages()) == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "at least one image is required")
	}

	images := mappers.ImageInputsToModels(req.GetImages())

	aiResp, err := h.service.DetectNutrientDeficiency(ctx, req.GetPlantSpeciesId(), images)
	if err != nil {
		h.log.Errorw("msg", "DetectNutrientDeficiency failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	deficiencies := make([]*pb.NutrientDeficiency, 0, len(aiResp.NutrientDeficiencies))
	for i := range aiResp.NutrientDeficiencies {
		deficiencies = append(deficiencies, mappers.DetectedNutrientDeficiencyToProto(&aiResp.NutrientDeficiencies[i]))
	}

	return &pb.DetectNutrientDeficiencyResponse{
		Deficiencies:     deficiencies,
		AiModelVersion:   aiResp.ModelVersion,
		ProcessingTimeMs: aiResp.ProcessingTimeMs,
	}, nil
}

// DetectPestDamage handles pest damage detection from images.
func (h *DiagnosisHandler) DetectPestDamage(ctx context.Context, req *pb.DetectPestDamageRequest) (*pb.DetectPestDamageResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DetectPestDamage request", "request_id", requestID)

	if len(req.GetImages()) == 0 {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "at least one image is required")
	}

	images := mappers.ImageInputsToModels(req.GetImages())

	aiResp, err := h.service.DetectPestDamage(ctx, req.GetPlantSpeciesId(), images)
	if err != nil {
		h.log.Errorw("msg", "DetectPestDamage failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	pests := make([]*pb.PestDamage, 0, len(aiResp.PestDamage))
	for i := range aiResp.PestDamage {
		pests = append(pests, mappers.DetectedPestDamageToProto(&aiResp.PestDamage[i]))
	}

	return &pb.DetectPestDamageResponse{
		Pests:            pests,
		AiModelVersion:   aiResp.ModelVersion,
		ProcessingTimeMs: aiResp.ProcessingTimeMs,
	}, nil
}

// diagnosisStatusToString converts a proto DiagnosisStatus to its domain string representation.
func diagnosisStatusToString(s pb.DiagnosisStatus) string {
	switch s {
	case pb.DiagnosisStatus_DIAGNOSIS_STATUS_PENDING:
		return string(models.DiagnosisStatusPending)
	case pb.DiagnosisStatus_DIAGNOSIS_STATUS_ANALYZING:
		return string(models.DiagnosisStatusAnalyzing)
	case pb.DiagnosisStatus_DIAGNOSIS_STATUS_COMPLETED:
		return string(models.DiagnosisStatusCompleted)
	case pb.DiagnosisStatus_DIAGNOSIS_STATUS_FAILED:
		return string(models.DiagnosisStatusFailed)
	default:
		return ""
	}
}

