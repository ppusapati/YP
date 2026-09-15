package handlers

import (
	"context"

	"connectrpc.com/connect"

	pb "p9e.in/samavaya/agriculture/analytics-service/api/v1"
	"p9e.in/samavaya/agriculture/analytics-service/api/v1/v1connect"
	"p9e.in/samavaya/agriculture/analytics-service/internal/models"
	"p9e.in/samavaya/agriculture/analytics-service/services"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
)

// AnalyticsHandler implements the ConnectRPC FieldAnalyticsServiceHandler interface.
type AnalyticsHandler struct {
	v1connect.UnimplementedFieldAnalyticsServiceHandler

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
func (h *AnalyticsHandler) GetHistoricalMetrics(ctx context.Context, req *connect.Request[pb.GetHistoricalMetricsRequest]) (*connect.Response[pb.GetHistoricalMetricsResponse], error) {
	metrics, err := h.service.GetHistoricalMetrics(ctx, req.Msg.GetFarmId(), req.Msg.GetFieldId(), req.Msg.GetTimePeriod())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	fields := make([]*pb.FieldAnalyticsSummary, len(metrics.Fields))
	for i, f := range metrics.Fields {
		fields[i] = fieldSummaryToProto(&f)
	}

	return connect.NewResponse(&pb.GetHistoricalMetricsResponse{
		Metrics: &pb.HistoricalMetrics{
			MeanYield:       metrics.MeanYield,
			PeakYield:       metrics.PeakYield,
			YieldTrend:      metrics.YieldTrend,
			AvgStressDays:   metrics.AvgStressDays,
			AvgNdvi:         metrics.AvgNDVI,
			SeasonsAnalyzed: metrics.SeasonsAnalyzed,
			Fields:          fields,
		},
	}), nil
}

// ListFieldAnalytics handles the ListFieldAnalytics RPC.
func (h *AnalyticsHandler) ListFieldAnalytics(ctx context.Context, req *connect.Request[pb.ListFieldAnalyticsRequest]) (*connect.Response[pb.ListFieldAnalyticsResponse], error) {
	summaries, err := h.service.ListFieldAnalytics(ctx, req.Msg.GetFarmId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	out := make([]*pb.FieldAnalyticsSummary, len(summaries))
	for i, s := range summaries {
		out[i] = fieldSummaryToProto(&s)
	}

	return connect.NewResponse(&pb.ListFieldAnalyticsResponse{Summaries: out}), nil
}

// GetFieldAnalytics handles the GetFieldAnalytics RPC.
func (h *AnalyticsHandler) GetFieldAnalytics(ctx context.Context, req *connect.Request[pb.GetFieldAnalyticsRequest]) (*connect.Response[pb.GetFieldAnalyticsResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	summary, trends, err := h.service.GetFieldAnalytics(ctx, req.Msg.GetFieldId())
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

	return connect.NewResponse(&pb.GetFieldAnalyticsResponse{
		Summary:     fieldSummaryToProto(summary),
		YieldTrends: pbTrends,
	}), nil
}

// GetSeasonComparisons handles the GetSeasonComparisons RPC.
func (h *AnalyticsHandler) GetSeasonComparisons(ctx context.Context, req *connect.Request[pb.GetSeasonComparisonsRequest]) (*connect.Response[pb.GetSeasonComparisonsResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	comparisons, err := h.service.GetSeasonComparisons(ctx, req.Msg.GetFieldId())
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

	return connect.NewResponse(&pb.GetSeasonComparisonsResponse{Comparisons: out}), nil
}

// GetRotationAnalysis handles the GetRotationAnalysis RPC.
func (h *AnalyticsHandler) GetRotationAnalysis(ctx context.Context, req *connect.Request[pb.GetRotationAnalysisRequest]) (*connect.Response[pb.GetRotationAnalysisResponse], error) {
	if req.Msg.GetFieldId() == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}

	analysis, err := h.service.GetRotationAnalysis(ctx, req.Msg.GetFieldId())
	if err != nil {
		return nil, errors.ToConnectError(err)
	}

	return connect.NewResponse(&pb.GetRotationAnalysisResponse{
		Analysis: &pb.RotationAnalysis{
			EffectivenessScore: analysis.EffectivenessScore,
			DiversityIndex:     analysis.DiversityIndex,
			RotationLength:     analysis.RotationLength,
			SoilHealthImpact:   analysis.SoilHealthImpact,
			RotationPattern:    analysis.RotationPattern,
			Recommendations:    analysis.Recommendations,
		},
	}), nil
}

// GetCrossFieldTrends handles the GetCrossFieldTrends RPC.
func (h *AnalyticsHandler) GetCrossFieldTrends(ctx context.Context, req *connect.Request[pb.GetCrossFieldTrendsRequest]) (*connect.Response[pb.GetCrossFieldTrendsResponse], error) {
	if len(req.Msg.GetFieldIds()) == 0 {
		return nil, errors.BadRequest("MISSING_FIELD_IDS", "at least one field_id is required")
	}

	trends, err := h.service.GetCrossFieldTrends(ctx, req.Msg.GetFieldIds(), req.Msg.GetMetric())
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

	return connect.NewResponse(&pb.GetCrossFieldTrendsResponse{Trends: out}), nil
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
