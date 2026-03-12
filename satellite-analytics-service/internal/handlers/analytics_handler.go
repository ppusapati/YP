package handlers

import (
	"context"
	"fmt"
	"strconv"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"

	pb "p9e.in/samavaya/agriculture/satellite-analytics-service/api/v1"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/mappers"
	analyticsmodels "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/services"
)

// AnalyticsHandler implements the ConnectRPC SatelliteAnalyticsService handler.
type AnalyticsHandler struct {
	d       deps.ServiceDeps
	service services.AnalyticsService
	log     *p9log.Helper
}

// NewAnalyticsHandler creates a new AnalyticsHandler.
func NewAnalyticsHandler(d deps.ServiceDeps, service services.AnalyticsService) *AnalyticsHandler {
	return &AnalyticsHandler{
		d:       d,
		service: service,
		log:     p9log.NewHelper(p9log.With(d.Log, "component", "AnalyticsHandler")),
	}
}

// DetectStress handles stress detection requests.
func (h *AnalyticsHandler) DetectStress(ctx context.Context, req *pb.DetectStressRequest) (*pb.DetectStressResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "DetectStress request",
		"farm_id", req.GetFarmId(),
		"field_id", req.GetFieldId(),
		"processing_job_id", req.GetProcessingJobId(),
		"request_id", requestID,
	)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetProcessingJobId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "processing_job_id is required")
	}

	alerts, err := h.service.DetectStress(ctx, req.GetFarmId(), req.GetFieldId(), req.GetProcessingJobId())
	if err != nil {
		h.log.Errorw("msg", "DetectStress failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.DetectStressResponse{
		Alerts: mappers.StressAlertsToProto(alerts),
	}, nil
}

// ListStressAlerts handles list stress alerts requests with filtering and pagination.
func (h *AnalyticsHandler) ListStressAlerts(ctx context.Context, req *pb.ListStressAlertsRequest) (*pb.ListStressAlertsResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "ListStressAlerts request", "request_id", requestID)

	params := analyticsmodels.ListStressAlertsParams{
		PageSize:           req.GetPageSize(),
		UnacknowledgedOnly: req.GetUnacknowledgedOnly(),
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
	if req.GetStressType() != pb.StressType_STRESS_TYPE_UNSPECIFIED {
		st := mappers.ProtoStressTypeToDomain(req.GetStressType())
		params.StressType = &st
	}
	if req.GetMinSeverity() != pb.SeverityLevel_SEVERITY_LEVEL_UNSPECIFIED {
		sl := mappers.ProtoSeverityLevelToDomain(req.GetMinSeverity())
		params.MinSeverity = &sl
	}

	alerts, totalCount, err := h.service.ListStressAlerts(ctx, params)
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	resp := &pb.ListStressAlertsResponse{
		Alerts:     mappers.StressAlertsToProto(alerts),
		TotalCount: totalCount,
	}

	// Compute next page token
	nextOffset := params.Offset + params.PageSize
	if nextOffset < totalCount {
		resp.NextPageToken = fmt.Sprintf("%d", nextOffset)
	}

	return resp, nil
}

// AcknowledgeAlert handles alert acknowledgment requests.
func (h *AnalyticsHandler) AcknowledgeAlert(ctx context.Context, req *pb.AcknowledgeAlertRequest) (*pb.AcknowledgeAlertResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "AcknowledgeAlert request", "id", req.GetId(), "request_id", requestID)

	if req.GetId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "alert ID is required")
	}

	err := h.service.AcknowledgeAlert(ctx, req.GetId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.AcknowledgeAlertResponse{
		Success: true,
	}, nil
}

// RunTemporalAnalysis handles temporal analysis requests.
func (h *AnalyticsHandler) RunTemporalAnalysis(ctx context.Context, req *pb.RunTemporalAnalysisRequest) (*pb.RunTemporalAnalysisResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "RunTemporalAnalysis request",
		"farm_id", req.GetFarmId(),
		"field_id", req.GetFieldId(),
		"analysis_type", req.GetAnalysisType().String(),
		"request_id", requestID,
	)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}
	if req.GetAnalysisType() == pb.AnalysisType_ANALYSIS_TYPE_UNSPECIFIED {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "analysis_type is required")
	}
	if req.GetPeriodStart() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "period_start is required")
	}
	if req.GetPeriodEnd() == nil {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "period_end is required")
	}

	analysisType := mappers.ProtoAnalysisTypeToDomain(req.GetAnalysisType())
	periodStart := req.GetPeriodStart().AsTime()
	periodEnd := req.GetPeriodEnd().AsTime()

	analysis, err := h.service.RunTemporalAnalysis(ctx, req.GetFarmId(), req.GetFieldId(), analysisType, periodStart, periodEnd)
	if err != nil {
		h.log.Errorw("msg", "RunTemporalAnalysis failed", "error", err, "request_id", requestID)
		return nil, errors.ToConnectError(err)
	}

	return &pb.RunTemporalAnalysisResponse{
		Analysis: mappers.TemporalAnalysisToProto(analysis),
	}, nil
}

// GetFieldAnalyticsSummary handles field analytics summary requests.
func (h *AnalyticsHandler) GetFieldAnalyticsSummary(ctx context.Context, req *pb.GetFieldAnalyticsSummaryRequest) (*pb.GetFieldAnalyticsSummaryResponse, error) {
	requestID := p9context.RequestID(ctx)

	h.log.Infow("msg", "GetFieldAnalyticsSummary request",
		"farm_id", req.GetFarmId(),
		"field_id", req.GetFieldId(),
		"request_id", requestID,
	)

	if req.GetFarmId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "farm_id is required")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field_id is required")
	}

	summary, err := h.service.GetFieldAnalyticsSummary(ctx, req.GetFarmId(), req.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return mappers.FieldAnalyticsSummaryToProto(summary), nil
}
