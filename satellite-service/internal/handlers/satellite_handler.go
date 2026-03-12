package handlers

import (
	"context"
	"fmt"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/satellite-service/api/v1"
	"p9e.in/samavaya/agriculture/satellite-service/internal/mappers"
	"p9e.in/samavaya/agriculture/satellite-service/internal/services"
)

// SatelliteHandler implements the ConnectRPC SatelliteService handler.
type SatelliteHandler struct {
	d       deps.ServiceDeps
	service services.SatelliteService
	log     *p9log.Helper
}

// NewSatelliteHandler creates a new SatelliteHandler.
func NewSatelliteHandler(d deps.ServiceDeps, service services.SatelliteService) *SatelliteHandler {
	return &SatelliteHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "SatelliteHandler")),
	}
}

// RequestImagery handles requests for new satellite imagery acquisition.
func (h *SatelliteHandler) RequestImagery(ctx context.Context, req *pb.RequestImageryRequest) (*pb.RequestImageryResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "RequestImagery request", "tenant_id", tenantID, "request_id", requestID)

	if req.GetTenantId() == "" && tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}

	imageryReq := &services.ImageryRequest{
		TenantID:          effectiveTenantID,
		FieldID:           req.GetFieldId(),
		FarmID:            req.GetFarmId(),
		SatelliteProvider: mappers.ProviderFromProto(req.GetSatelliteProvider()),
		Bbox:              mappers.BboxFromProto(req.GetBbox()),
		MaxCloudCoverPct:  req.GetMaxCloudCoverPct(),
		ResolutionMeters:  req.GetResolutionMeters(),
		Bands:             mappers.BandsFromProto(req.GetBands()),
	}

	task, err := h.service.RequestImagery(ctx, imageryReq)
	if err != nil {
		h.log.Errorw("msg", "RequestImagery failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.RequestImageryResponse{
		Task:    mappers.SatelliteTaskToProto(task),
		Message: fmt.Sprintf("Imagery acquisition task %s created successfully", task.UUID),
	}, nil
}

// GetImage handles get satellite image by ID requests.
func (h *SatelliteHandler) GetImage(ctx context.Context, req *pb.GetImageRequest) (*pb.GetImageResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "GetImage request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "image ID is required")
	}

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}
	if effectiveTenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}

	image, err := h.service.GetImage(ctx, req.GetId(), effectiveTenantID)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetImageResponse{
		Image: mappers.SatelliteImageToProto(image),
	}, nil
}

// ListImages handles list satellite images requests with filtering and pagination.
func (h *SatelliteHandler) ListImages(ctx context.Context, req *pb.ListImagesRequest) (*pb.ListImagesResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "ListImages request", "request_id", requestID)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}
	if effectiveTenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}

	images, totalCount, err := h.service.ListImages(ctx, effectiveTenantID, req.GetFieldId(), req.GetFarmId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListImagesResponse{
		Images:     mappers.SatelliteImagesToProto(images),
		TotalCount: int32(totalCount),
	}, nil
}

// ComputeNDVI handles NDVI vegetation index computation requests.
func (h *SatelliteHandler) ComputeNDVI(ctx context.Context, req *pb.ComputeIndexRequest) (*pb.ComputeIndexResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "ComputeNDVI request", "image_id", req.GetImageId(), "request_id", requestID)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}

	if err := validateComputeIndexRequest(req, effectiveTenantID); err != nil {
		return nil, err
	}

	index, err := h.service.ComputeNDVI(ctx, effectiveTenantID, req.GetImageId(), req.GetFieldId())
	if err != nil {
		h.log.Errorw("msg", "ComputeNDVI failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.ComputeIndexResponse{
		Index:   mappers.VegetationIndexToProto(index),
		Message: "NDVI computation completed successfully",
	}, nil
}

// ComputeNDWI handles NDWI vegetation index computation requests.
func (h *SatelliteHandler) ComputeNDWI(ctx context.Context, req *pb.ComputeIndexRequest) (*pb.ComputeIndexResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "ComputeNDWI request", "image_id", req.GetImageId(), "request_id", requestID)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}

	if err := validateComputeIndexRequest(req, effectiveTenantID); err != nil {
		return nil, err
	}

	index, err := h.service.ComputeNDWI(ctx, effectiveTenantID, req.GetImageId(), req.GetFieldId())
	if err != nil {
		h.log.Errorw("msg", "ComputeNDWI failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.ComputeIndexResponse{
		Index:   mappers.VegetationIndexToProto(index),
		Message: "NDWI computation completed successfully",
	}, nil
}

// ComputeEVI handles EVI vegetation index computation requests.
func (h *SatelliteHandler) ComputeEVI(ctx context.Context, req *pb.ComputeIndexRequest) (*pb.ComputeIndexResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "ComputeEVI request", "image_id", req.GetImageId(), "request_id", requestID)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}

	if err := validateComputeIndexRequest(req, effectiveTenantID); err != nil {
		return nil, err
	}

	index, err := h.service.ComputeEVI(ctx, effectiveTenantID, req.GetImageId(), req.GetFieldId())
	if err != nil {
		h.log.Errorw("msg", "ComputeEVI failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.ComputeIndexResponse{
		Index:   mappers.VegetationIndexToProto(index),
		Message: "EVI computation completed successfully",
	}, nil
}

// GetVegetationIndices handles retrieval of computed vegetation indices.
func (h *SatelliteHandler) GetVegetationIndices(ctx context.Context, req *pb.GetVegetationIndicesRequest) (*pb.GetVegetationIndicesResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "GetVegetationIndices request", "request_id", requestID)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}
	if effectiveTenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}

	indices, err := h.service.GetVegetationIndices(ctx, effectiveTenantID, req.GetImageId(), req.GetFieldId(), req.GetIndexType())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetVegetationIndicesResponse{
		Indices: mappers.VegetationIndicesToProto(indices),
	}, nil
}

// DetectCropStress handles crop stress detection requests.
func (h *SatelliteHandler) DetectCropStress(ctx context.Context, req *pb.DetectCropStressRequest) (*pb.DetectCropStressResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "DetectCropStress request", "image_id", req.GetImageId(), "request_id", requestID)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}
	if effectiveTenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}
	if req.GetImageId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "image_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	alert, err := h.service.DetectCropStress(ctx, effectiveTenantID, req.GetImageId(), req.GetFieldId())
	if err != nil {
		h.log.Errorw("msg", "DetectCropStress failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	message := "No crop stress detected"
	if alert.StressDetected {
		message = fmt.Sprintf("Crop stress detected: %s (severity: %.2f)", alert.StressType, alert.StressSeverity)
	}

	return &pb.DetectCropStressResponse{
		Alert:   mappers.CropStressAlertToProto(alert),
		Message: message,
	}, nil
}

// ListAlerts handles list crop stress alerts requests with filtering and pagination.
func (h *SatelliteHandler) ListAlerts(ctx context.Context, req *pb.ListAlertsRequest) (*pb.ListAlertsResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "ListAlerts request", "request_id", requestID)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}
	if effectiveTenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}

	alerts, totalCount, err := h.service.ListAlerts(ctx, effectiveTenantID, req.GetFieldId(), req.GetPageSize(), req.GetPageOffset())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.ListAlertsResponse{
		Alerts:     mappers.CropStressAlertsToProto(alerts),
		TotalCount: int32(totalCount),
	}, nil
}

// GetTemporalAnalysis handles temporal analysis requests for vegetation indices.
func (h *SatelliteHandler) GetTemporalAnalysis(ctx context.Context, req *pb.GetTemporalAnalysisRequest) (*pb.GetTemporalAnalysisResponse, error) {
	requestID := p9context.RequestID(ctx)
	tenantID := p9context.TenantID(ctx)

	h.log.Infow("msg", "GetTemporalAnalysis request",
		"field_id", req.GetFieldId(),
		"index_type", req.GetIndexType(),
		"request_id", requestID,
	)

	effectiveTenantID := req.GetTenantId()
	if effectiveTenantID == "" {
		effectiveTenantID = tenantID
	}
	if effectiveTenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetIndexType() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "index_type is required")
	}
	if req.GetStartDate() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "start_date is required")
	}
	if req.GetEndDate() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "end_date is required")
	}

	startDate := mappers.TimeFromProto(req.GetStartDate())
	endDate := mappers.TimeFromProto(req.GetEndDate())

	analysis, err := h.service.GetTemporalAnalysis(ctx, effectiveTenantID, req.GetFieldId(), req.GetIndexType(), startDate, endDate)
	if err != nil {
		h.log.Errorw("msg", "GetTemporalAnalysis failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetTemporalAnalysisResponse{
		Analysis: mappers.TemporalAnalysisToProto(analysis),
	}, nil
}

// validateComputeIndexRequest validates common fields for compute index requests.
func validateComputeIndexRequest(req *pb.ComputeIndexRequest, tenantID string) error {
	if tenantID == "" {
		return errors.BadRequest("INVALID_ARGUMENT", "tenant_id is required")
	}
	if req.GetImageId() == "" {
		return errors.BadRequest("INVALID_ARGUMENT", "image_id is required")
	}
	if req.GetFieldId() == "" {
		return errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	return nil
}
