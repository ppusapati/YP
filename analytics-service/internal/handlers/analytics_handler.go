package handlers

import (
	"context"

	pb "p9e.in/samavaya/agriculture/analytics-service/api/v1"
	"p9e.in/samavaya/agriculture/analytics-service/internal/models"
	"p9e.in/samavaya/agriculture/analytics-service/internal/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

// AnalyticsHandler implements the gRPC FieldAnalyticsServiceServer interface.
type AnalyticsHandler struct {
	pb.UnimplementedFieldAnalyticsServiceServer

	service services.AnalyticsService
	deps    deps.ServiceDeps
	logger  *p9log.Helper
}

// NewAnalyticsHandler creates a new AnalyticsHandler.
func NewAnalyticsHandler(d deps.ServiceDeps, svc services.AnalyticsService) *AnalyticsHandler {
	return &AnalyticsHandler{
		service: svc,
		deps:    d,
		logger:  p9log.NewHelper(p9log.With(d.Log, "component", "analytics_handler")),
	}
}

// GetHistoricalMetrics handles the GetHistoricalMetrics RPC.
func (h *AnalyticsHandler) GetHistoricalMetrics(ctx context.Context, req *pb.GetHistoricalMetricsRequest) (*pb.GetHistoricalMetricsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	metrics, err := h.service.GetHistoricalMetrics(ctx, req.GetFarmId(), req.GetFieldId(), req.GetTimePeriod())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	fields := make([]*pb.FieldAnalyticsSummary, len(metrics.Fields))
	for i, f := range metrics.Fields {
		fields[i] = fieldSummaryToProto(&f)
	}

	return &pb.GetHistoricalMetricsResponse{
		Metrics: &pb.HistoricalMetrics{
			MeanYield:       metrics.MeanYield,
			PeakYield:       metrics.PeakYield,
			YieldTrend:      metrics.YieldTrend,
			AvgStressDays:   metrics.AvgStressDays,
			AvgNdvi:         metrics.AvgNDVI,
			SeasonsAnalyzed: metrics.SeasonsAnalyzed,
			Fields:          fields,
		},
	}, nil
}

// ListFieldAnalytics handles the ListFieldAnalytics RPC.
func (h *AnalyticsHandler) ListFieldAnalytics(ctx context.Context, req *pb.ListFieldAnalyticsRequest) (*pb.ListFieldAnalyticsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}

	summaries, err := h.service.ListFieldAnalytics(ctx, req.GetFarmId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.FieldAnalyticsSummary, len(summaries))
	for i, s := range summaries {
		out[i] = fieldSummaryToProto(&s)
	}

	return &pb.ListFieldAnalyticsResponse{Summaries: out}, nil
}

// GetFieldAnalytics handles the GetFieldAnalytics RPC.
func (h *AnalyticsHandler) GetFieldAnalytics(ctx context.Context, req *pb.GetFieldAnalyticsRequest) (*pb.GetFieldAnalyticsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	summary, trends, err := h.service.GetFieldAnalytics(ctx, req.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	pbTrends := make([]*pb.YieldTrendPoint, len(trends))
	for i, t := range trends {
		pbTrends[i] = &pb.YieldTrendPoint{
			Season:     t.Season,
			Crop:       t.Crop,
			YieldValue: t.YieldValue,
			Ndvi:       t.NDVI,
		}
	}

	return &pb.GetFieldAnalyticsResponse{
		Summary:     fieldSummaryToProto(summary),
		YieldTrends: pbTrends,
	}, nil
}

// GetSeasonComparisons handles the GetSeasonComparisons RPC.
func (h *AnalyticsHandler) GetSeasonComparisons(ctx context.Context, req *pb.GetSeasonComparisonsRequest) (*pb.GetSeasonComparisonsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	comparisons, err := h.service.GetSeasonComparisons(ctx, req.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.SeasonComparison, len(comparisons))
	for i, c := range comparisons {
		out[i] = &pb.SeasonComparison{
			Season:          c.Season,
			Crop:            c.Crop,
			YieldValue:      c.YieldValue,
			YieldVsMeanPct:  c.YieldVsMeanPct,
			StressDays:      c.StressDays,
			StressVsMeanPct: c.StressVsMeanPct,
			NdviPeak:        c.NDVIPeak,
			NdviVsMeanPct:   c.NDVIVsMeanPct,
			NotableEvents:   c.NotableEvents,
		}
	}

	return &pb.GetSeasonComparisonsResponse{Comparisons: out}, nil
}

// GetRotationAnalysis handles the GetRotationAnalysis RPC.
func (h *AnalyticsHandler) GetRotationAnalysis(ctx context.Context, req *pb.GetRotationAnalysisRequest) (*pb.GetRotationAnalysisResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if req.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	analysis, err := h.service.GetRotationAnalysis(ctx, req.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return &pb.GetRotationAnalysisResponse{
		Analysis: &pb.RotationAnalysis{
			EffectivenessScore: analysis.EffectivenessScore,
			DiversityIndex:     analysis.DiversityIndex,
			RotationLength:     analysis.RotationLength,
			SoilHealthImpact:   analysis.SoilHealthImpact,
			RotationPattern:    analysis.RotationPattern,
			Recommendations:    analysis.Recommendations,
		},
	}, nil
}

// GetCrossFieldTrends handles the GetCrossFieldTrends RPC.
func (h *AnalyticsHandler) GetCrossFieldTrends(ctx context.Context, req *pb.GetCrossFieldTrendsRequest) (*pb.GetCrossFieldTrendsResponse, error) {
	if req == nil {
		return nil, errors.BadRequest("INVALID_REQUEST", "request must not be nil")
	}
	if len(req.GetFieldIds()) == 0 {
		return nil, errors.BadRequest("MISSING_FIELD_IDS", "at least one field_id is required")
	}

	trends, err := h.service.GetCrossFieldTrends(ctx, req.GetFieldIds(), req.GetMetric())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.CrossFieldTrendPoint, len(trends))
	for i, t := range trends {
		out[i] = &pb.CrossFieldTrendPoint{
			FieldId:   t.FieldID,
			FieldName: t.FieldName,
			Values:    t.Values,
			Labels:    t.Labels,
		}
	}

	return &pb.GetCrossFieldTrendsResponse{Trends: out}, nil
}

// ---------------------------------------------------------------------------
// Proto mapping helper
// ---------------------------------------------------------------------------

func fieldSummaryToProto(s *models.FieldAnalyticsSummary) *pb.FieldAnalyticsSummary {
	if s == nil {
		return nil
	}
	return &pb.FieldAnalyticsSummary{
		FieldId:         s.FieldID,
		FieldName:       s.FieldName,
		MeanYield:       s.MeanYield,
		PeakYield:       s.PeakYield,
		YieldTrend:      s.YieldTrend,
		AvgStressDays:   s.AvgStressDays,
		AvgNdvi:         s.AvgNDVI,
		SeasonsAnalyzed: s.SeasonsAnalyzed,
	}
}
