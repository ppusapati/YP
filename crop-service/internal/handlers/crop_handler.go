package handlers

import (
	"context"
	"strings"

	pb "p9e.in/samavaya/agriculture/crop-service/api/v1"
	"p9e.in/samavaya/agriculture/crop-service/internal/mappers"
	cropmodels "p9e.in/samavaya/agriculture/crop-service/internal/models"
	"p9e.in/samavaya/agriculture/crop-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// CropHandler implements the gRPC CropServiceServer interface.
type CropHandler struct {
	pb.UnimplementedCropServiceServer
	svc    services.CropService
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewCropHandler creates a new CropHandler.
func NewCropHandler(d deps.ServiceDeps, svc services.CropService) *CropHandler {
	return &CropHandler{
		svc:    svc,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "CropHandler")),
	}
}

// CreateCrop handles a CreateCrop RPC request.
func (h *CropHandler) CreateCrop(ctx context.Context, req *pb.CreateCropRequest) (*pb.CreateCropResponse, error) {
	if err := h.validateCreateCropRequest(req); err != nil {
		return nil, err
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())
	userID := p9context.UserID(ctx)

	crop := mappers.CropFromCreateRequest(req, userID)
	crop.TenantID = tenantID

	created, err := h.svc.CreateCrop(ctx, crop)
	if err != nil {
		h.logger.Errorf("CreateCrop failed: %v", err)
		return nil, errors.ToConnectError(err)
	}

	return &pb.CreateCropResponse{
		Crop: mappers.CropToProto(created),
	}, nil
}

// GetCrop handles a GetCrop RPC request.
func (h *CropHandler) GetCrop(ctx context.Context, req *pb.GetCropRequest) (*pb.GetCropResponse, error) {
	if strings.TrimSpace(req.GetId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop id is required")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())

	crop, err := h.svc.GetCrop(ctx, req.GetId(), tenantID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetCropResponse{
		Crop: mappers.CropToProto(crop),
	}, nil
}

// ListCrops handles a ListCrops RPC request.
func (h *CropHandler) ListCrops(ctx context.Context, req *pb.ListCropsRequest) (*pb.ListCropsResponse, error) {
	tenantID := resolveTenantID(ctx, req.GetTenantId())
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
	}

	var category *string
	if req.GetCategory() != pb.CropCategory_CROP_CATEGORY_UNSPECIFIED {
		cat := mappers.CategoryFromProto(req.GetCategory())
		catStr := string(cat)
		category = &catStr
	}

	var searchTerm *string
	if req.GetSearchTerm() != "" {
		s := req.GetSearchTerm()
		searchTerm = &s
	}

	limit := req.GetPageSize()
	if limit <= 0 {
		limit = 50
	}

	crops, totalCount, err := h.svc.ListCrops(ctx, tenantID, category, searchTerm, limit, req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListCropsResponse{
		Crops:      mappers.CropSliceToProto(crops),
		TotalCount: totalCount,
	}, nil
}

// UpdateCrop handles an UpdateCrop RPC request.
func (h *CropHandler) UpdateCrop(ctx context.Context, req *pb.UpdateCropRequest) (*pb.UpdateCropResponse, error) {
	if strings.TrimSpace(req.GetId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop id is required")
	}
	if strings.TrimSpace(req.GetName()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_NAME", "crop name is required")
	}
	if req.GetVersion() <= 0 {
		return nil, errors.BadRequest("INVALID_VERSION", "version is required for optimistic concurrency")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())

	crop := &cropmodels.Crop{
		TenantID:               tenantID,
		Name:                   strings.TrimSpace(req.GetName()),
		ScientificName:         req.GetScientificName(),
		Family:                 req.GetFamily(),
		Category:               mappers.CategoryFromProto(req.GetCategory()),
		Description:            req.GetDescription(),
		ImageURL:               req.GetImageUrl(),
		DiseaseSusceptibilities: req.GetDiseaseSusceptibilities(),
		CompanionPlants:        req.GetCompanionPlants(),
		RotationGroup:          req.GetRotationGroup(),
		Version:                req.GetVersion(),
	}
	crop.UUID = req.GetId()

	updated, err := h.svc.UpdateCrop(ctx, crop)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.UpdateCropResponse{
		Crop: mappers.CropToProto(updated),
	}, nil
}

// DeleteCrop handles a DeleteCrop RPC request.
func (h *CropHandler) DeleteCrop(ctx context.Context, req *pb.DeleteCropRequest) (*pb.DeleteCropResponse, error) {
	if strings.TrimSpace(req.GetId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop id is required")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())

	err := h.svc.DeleteCrop(ctx, req.GetId(), tenantID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.DeleteCropResponse{
		Success: true,
	}, nil
}

// AddVariety handles an AddVariety RPC request.
func (h *CropHandler) AddVariety(ctx context.Context, req *pb.AddVarietyRequest) (*pb.AddVarietyResponse, error) {
	if strings.TrimSpace(req.GetCropId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}
	if strings.TrimSpace(req.GetName()) == "" {
		return nil, errors.BadRequest("INVALID_VARIETY_NAME", "variety name is required")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())
	userID := p9context.UserID(ctx)

	// Resolve crop to get internal ID
	crop, err := h.svc.GetCrop(ctx, req.GetCropId(), tenantID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	variety := mappers.CropVarietyFromAddRequest(req, crop.ID, userID)
	variety.TenantID = tenantID

	created, err := h.svc.AddVariety(ctx, variety)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	pbVariety := mappers.CropVarietyToProto(created)
	pbVariety.CropId = req.GetCropId()

	return &pb.AddVarietyResponse{
		Variety: pbVariety,
	}, nil
}

// ListVarieties handles a ListVarieties RPC request.
func (h *CropHandler) ListVarieties(ctx context.Context, req *pb.ListVarietiesRequest) (*pb.ListVarietiesResponse, error) {
	if strings.TrimSpace(req.GetCropId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())
	limit := req.GetPageSize()
	if limit <= 0 {
		limit = 50
	}

	varieties, totalCount, err := h.svc.ListVarieties(ctx, req.GetCropId(), tenantID, limit, req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListVarietiesResponse{
		Varieties:  mappers.CropVarietySliceToProto(varieties),
		TotalCount: totalCount,
	}, nil
}

// GetGrowthStages handles a GetGrowthStages RPC request.
func (h *CropHandler) GetGrowthStages(ctx context.Context, req *pb.GetGrowthStagesRequest) (*pb.GetGrowthStagesResponse, error) {
	if strings.TrimSpace(req.GetCropId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())

	stages, err := h.svc.GetGrowthStages(ctx, req.GetCropId(), tenantID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetGrowthStagesResponse{
		GrowthStages: mappers.GrowthStageSliceToProto(stages),
	}, nil
}

// GetCropRequirements handles a GetCropRequirements RPC request.
func (h *CropHandler) GetCropRequirements(ctx context.Context, req *pb.GetCropRequirementsRequest) (*pb.GetCropRequirementsResponse, error) {
	if strings.TrimSpace(req.GetCropId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())

	reqs, err := h.svc.GetCropRequirements(ctx, req.GetCropId(), tenantID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	pbReqs := mappers.CropRequirementsToProto(reqs)
	pbReqs.CropId = req.GetCropId()

	return &pb.GetCropRequirementsResponse{
		Requirements: pbReqs,
	}, nil
}

// GenerateRecommendation handles a GenerateRecommendation RPC request.
func (h *CropHandler) GenerateRecommendation(ctx context.Context, req *pb.GenerateRecommendationRequest) (*pb.GenerateRecommendationResponse, error) {
	if strings.TrimSpace(req.GetCropId()) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}
	if strings.TrimSpace(req.GetRecommendationType()) == "" {
		return nil, errors.BadRequest("INVALID_RECOMMENDATION_TYPE", "recommendation_type is required")
	}

	tenantID := resolveTenantID(ctx, req.GetTenantId())

	input := &cropmodels.RecommendationInput{
		CropID:             req.GetCropId(),
		TenantID:           tenantID,
		RecommendationType: req.GetRecommendationType(),
		CurrentGrowthStage: req.GetCurrentGrowthStage(),
		CurrentTemperature: req.GetCurrentTemperature(),
		CurrentHumidity:    req.GetCurrentHumidity(),
		CurrentSoilPH:      req.GetCurrentSoilPh(),
		CurrentSoilMoisture: req.GetCurrentSoilMoisture(),
	}

	rec, err := h.svc.GenerateRecommendation(ctx, input)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	pbRec := mappers.CropRecommendationToProto(rec)
	pbRec.CropId = req.GetCropId()

	return &pb.GenerateRecommendationResponse{
		Recommendation: pbRec,
	}, nil
}

// ---------- Validation ----------

func (h *CropHandler) validateCreateCropRequest(req *pb.CreateCropRequest) error {
	if strings.TrimSpace(req.GetName()) == "" {
		return errors.BadRequest("INVALID_CROP_NAME", "crop name is required")
	}
	if req.GetCategory() == pb.CropCategory_CROP_CATEGORY_UNSPECIFIED {
		return errors.BadRequest("INVALID_CATEGORY", "a valid crop category must be specified")
	}
	return nil
}

// ---------- Helpers ----------

// resolveTenantID returns the tenant ID from the request or falls back to the context.
func resolveTenantID(ctx context.Context, reqTenantID string) string {
	if reqTenantID != "" {
		return reqTenantID
	}
	return p9context.TenantID(ctx)
}
