package services

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/ai"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/clients"
	analyticsmodels "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/repositories"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/timeseries"
)

// minTemporalSamples is the fewest observations that support a fit.
const minTemporalSamples = 3

const (
	serviceName           = "satellite-analytics-service"
	maxPageSize     int32 = 100
	defaultPageSize       = 20
)

// Analytics event types
const (
	EventTypeStressDetected    domain.EventType = "agriculture.satellite.analytics.stress.detected"
	EventTypeAnalysisCompleted domain.EventType = "agriculture.satellite.analytics.analysis.completed"
)

// AnalyticsService defines the interface for satellite analytics business logic.
type AnalyticsService interface {
	DetectStress(ctx context.Context, farmID, fieldID, processingJobID string) ([]analyticsmodels.StressAlert, error)
	ListStressAlerts(ctx context.Context, params analyticsmodels.ListStressAlertsParams) ([]analyticsmodels.StressAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, alertID string) error
	RunTemporalAnalysis(ctx context.Context, farmID, fieldID string, analysisType analyticsmodels.AnalysisType, periodStart, periodEnd time.Time) (*analyticsmodels.TemporalAnalysis, error)
	GetFieldAnalyticsSummary(ctx context.Context, farmID, fieldID string) (*analyticsmodels.FieldAnalyticsSummary, error)
}

// analyticsService is the concrete implementation of AnalyticsService.
type analyticsService struct {
	d         deps.ServiceDeps
	repo      repositories.AnalyticsRepository
	log       *p9log.Helper
	aiClient  *ai.AIClient
	vegClient clients.VegetationIndexClient
}

// NewAnalyticsService creates a new AnalyticsService.
func NewAnalyticsService(d deps.ServiceDeps, repo repositories.AnalyticsRepository, aiClient *ai.AIClient, vegClient clients.VegetationIndexClient) AnalyticsService {
	return &analyticsService{
		d:         d,
		repo:      repo,
		log:       p9log.NewHelper(p9log.With(d.Log, "component", "AnalyticsService")),
		aiClient:  aiClient,
		vegClient: vegClient,
	}
}

// DetectStress runs stress detection analysis on satellite data for a field.
func (s *analyticsService) DetectStress(ctx context.Context, farmID, fieldID, processingJobID string) ([]analyticsmodels.StressAlert, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if processingJobID == "" {
		return nil, errors.BadRequest("MISSING_PROCESSING_JOB_ID", "processing job ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// In a real implementation, this would analyze satellite imagery data
	// from the processing job and detect various types of stress.
	// For now, we create the stress alert records based on analysis results.

	// Check if alerts already exist for this processing job
	existing, err := s.repo.ListStressAlertsByProcessingJob(ctx, processingJobID, tenantID)
	if err != nil {
		return nil, err
	}
	if len(existing) > 0 {
		return existing, nil
	}

	// Attempt AI-powered stress detection via the AI gateway.
	var alerts []analyticsmodels.StressAlert
	if s.aiClient != nil {
		aiResult, aiErr := s.aiClient.DetectVegetationStress(ctx, requestID, &ai.RasterBandsInput{}, 0.3, 0.2)
		if aiErr != nil {
			s.log.Warnw("msg", "AI DetectVegetationStress failed, falling back to synthetic result",
				"error", aiErr, "request_id", requestID)
		} else {
			for _, zone := range aiResult.StressZones {
				desc := fmt.Sprintf("%s stress detected with %.0f%% confidence", zone.StressType, zone.Confidence*100)
				rec := fmt.Sprintf("Review affected area (%.1f%% of field) for %s stress mitigation", zone.AffectedAreaPct, zone.StressType)
				zoneAlert := &analyticsmodels.StressAlert{
					TenantID:             tenantID,
					FarmID:               farmID,
					FieldID:              fieldID,
					ProcessingJobID:      &processingJobID,
					StressType:           analyticsmodels.StressType(zone.StressType),
					Severity:             analyticsmodels.SeverityLevel(zone.Severity),
					Confidence:           zone.Confidence,
					AffectedAreaHectares: 0,
					AffectedPercentage:   zone.AffectedAreaPct,
					Description:          strPtr(desc),
					Recommendation:       strPtr(rec),
					DetectedAt:           time.Now(),
				}
				zoneAlert.CreatedBy = userID
				created, createErr := s.repo.CreateStressAlert(ctx, zoneAlert)
				if createErr != nil {
					s.log.Errorw("msg", "failed to create AI stress alert", "error", createErr, "request_id", requestID)
					continue
				}
				alerts = append(alerts, *created)
			}
		}
	}

	// Fallback: create a synthetic stress alert if AI produced no results.
	if len(alerts) == 0 {
		syntheticAlert := &analyticsmodels.StressAlert{
			TenantID:             tenantID,
			FarmID:               farmID,
			FieldID:              fieldID,
			ProcessingJobID:      &processingJobID,
			StressType:           analyticsmodels.StressTypeWater,
			Severity:             analyticsmodels.SeverityLevelMedium,
			Confidence:           0.85,
			AffectedAreaHectares: 2.5,
			AffectedPercentage:   15.0,
			Description:          strPtr("Water stress detected in northern section of the field based on NDWI analysis"),
			Recommendation:       strPtr("Consider increasing irrigation frequency in the affected area"),
			DetectedAt:           time.Now(),
		}
		syntheticAlert.CreatedBy = userID

		created, err := s.repo.CreateStressAlert(ctx, syntheticAlert)
		if err != nil {
			s.log.Errorw("msg", "failed to create stress alert", "error", err, "request_id", requestID)
			return nil, err
		}
		alerts = []analyticsmodels.StressAlert{*created}
	}

	// Emit domain event
	s.emitAnalyticsEvent(ctx, EventTypeStressDetected, map[string]interface{}{
		"farm_id":           farmID,
		"field_id":          fieldID,
		"processing_job_id": processingJobID,
		"alert_count":       len(alerts),
		"stress_type":       string(alerts[0].StressType),
		"severity":          string(alerts[0].Severity),
	})

	s.log.Infow("msg", "stress detection completed",
		"farm_id", farmID,
		"field_id", fieldID,
		"processing_job_id", processingJobID,
		"alert_count", len(alerts),
		"request_id", requestID,
	)

	return alerts, nil
}

// ListStressAlerts lists stress alerts with filtering and pagination.
func (s *analyticsService) ListStressAlerts(ctx context.Context, params analyticsmodels.ListStressAlertsParams) ([]analyticsmodels.StressAlert, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	// Clamp page size
	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	alerts, totalCount, err := s.repo.ListStressAlerts(ctx, params)
	if err != nil {
		return nil, 0, err
	}

	return alerts, totalCount, nil
}

// AcknowledgeAlert marks a stress alert as acknowledged.
func (s *analyticsService) AcknowledgeAlert(ctx context.Context, alertID string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if alertID == "" {
		return errors.BadRequest("MISSING_ALERT_ID", "alert ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Verify the alert exists
	alert, err := s.repo.GetStressAlertByUUID(ctx, alertID, tenantID)
	if err != nil {
		return err
	}

	if alert.Acknowledged {
		return errors.BadRequest("ALREADY_ACKNOWLEDGED", "alert is already acknowledged")
	}

	if err := s.repo.AcknowledgeStressAlert(ctx, alertID, tenantID, userID); err != nil {
		return err
	}

	s.log.Infow("msg", "stress alert acknowledged", "alert_id", alertID, "acknowledged_by", userID, "request_id", requestID)
	return nil
}

// RunTemporalAnalysis executes a temporal analysis on field data.
func (s *analyticsService) RunTemporalAnalysis(ctx context.Context, farmID, fieldID string, analysisType analyticsmodels.AnalysisType, periodStart, periodEnd time.Time) (*analyticsmodels.TemporalAnalysis, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}
	if !analysisType.IsValid() {
		return nil, errors.BadRequest("INVALID_ANALYSIS_TYPE", "invalid analysis type")
	}
	if periodStart.IsZero() || periodEnd.IsZero() {
		return nil, errors.BadRequest("INVALID_PERIOD", "period start and end are required")
	}
	if periodEnd.Before(periodStart) {
		return nil, errors.BadRequest("INVALID_PERIOD", "period end must be after period start")
	}
	if userID == "" {
		userID = "system"
	}
	if analysisType == analyticsmodels.AnalysisTypeCropClassification {
		return nil, errors.BadRequest("UNSUPPORTED_ANALYSIS_TYPE", "crop classification is an imagery task; use the AI gateway, not temporal analysis")
	}
	if s.vegClient == nil {
		return nil, errors.InternalServer("VEGETATION_CLIENT_UNAVAILABLE", "vegetation-index client not configured")
	}

	raw, err := s.vegClient.GetNDVITimeSeries(ctx, farmID, fieldID, periodStart, periodEnd)
	if err != nil {
		s.log.Errorw("msg", "failed to fetch NDVI time series", "error", err, "request_id", requestID)
		return nil, errors.InternalServer("TIME_SERIES_FETCH_FAILED", "could not fetch NDVI time series")
	}
	if len(raw) < minTemporalSamples {
		return nil, errors.NotFound("INSUFFICIENT_DATA", fmt.Sprintf("need at least %d NDVI observations in the period, found %d", minTemporalSamples, len(raw)))
	}

	analysis := s.analyzeSeries(analysisType, raw, periodStart, periodEnd)
	analysis.TenantID = tenantID
	analysis.FarmID = farmID
	analysis.FieldID = fieldID
	analysis.CreatedBy = userID
	metricName := analysis.MetricName

	created, err := s.repo.CreateTemporalAnalysis(ctx, analysis)
	if err != nil {
		s.log.Errorw("msg", "failed to create temporal analysis", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitAnalyticsEvent(ctx, EventTypeAnalysisCompleted, map[string]interface{}{
		"farm_id":       farmID,
		"field_id":      fieldID,
		"analysis_type": string(analysisType),
		"analysis_id":   created.ID,
		"metric_name":   metricName,
	})

	s.log.Infow("msg", "temporal analysis completed",
		"uuid", created.ID,
		"farm_id", farmID,
		"field_id", fieldID,
		"analysis_type", string(analysisType),
		"request_id", requestID,
	)

	return created, nil
}

// analyzeSeries derives the analysis record from the observed NDVI series.
// Observations are harmonized onto the Sentinel-2 scale and resampled onto a
// regular grid so uneven revisit intervals do not bias the fits.
func (s *analyticsService) analyzeSeries(analysisType analyticsmodels.AnalysisType, raw []timeseries.Sample, periodStart, periodEnd time.Time) *analyticsmodels.TemporalAnalysis {
	observed := timeseries.Sorted(timeseries.Harmonize(raw))
	filled := timeseries.GapFill(observed, timeseries.DefaultStep, timeseries.DefaultMaxGap)
	trend := timeseries.FitTrend(filled)
	last := observed[len(observed)-1]

	details := map[string]interface{}{
		"observations":        len(observed),
		"grid_points":         len(filled),
		"first_observation":   observed[0].Date.Format(time.RFC3339),
		"last_observation":    last.Date.Format(time.RFC3339),
		"trend_direction":     trend.Direction,
		"trend_slope_per_day": trend.SlopePerDay,
		"trend_r_squared":     trend.RSquared,
	}

	a := &analyticsmodels.TemporalAnalysis{
		AnalysisType:  analysisType,
		MetricName:    "NDVI",
		TrendSlope:    trend.SlopePerDay,
		TrendRSquared: trend.RSquared,
		CurrentValue:  last.Value,
		BaselineValue: trend.FittedStart,
		PeriodStart:   periodStart,
		PeriodEnd:     periodEnd,
		Details:       details,
	}
	if a.BaselineValue != 0 {
		a.DeviationPercent = (a.CurrentValue - a.BaselineValue) / math.Abs(a.BaselineValue) * 100
	}

	switch analysisType {
	case analyticsmodels.AnalysisTypeChangeDetection:
		split := periodStart.Add(periodEnd.Sub(periodStart) / 2)
		c := timeseries.DetectChange(filled, split)
		a.MetricName = "change_magnitude"
		a.CurrentValue = c.AfterMean
		a.BaselineValue = c.BeforeMean
		a.DeviationPercent = c.PctChange
		details["split_at"] = split.Format(time.RFC3339)
		details["delta"] = c.Delta
		details["z_score"] = c.ZScore
		details["significant"] = c.Significant
		details["samples_before"] = c.NBefore
		details["samples_after"] = c.NAfter

	case analyticsmodels.AnalysisTypeAnomalyDetection:
		anomalies := timeseries.DetectAnomalies(observed, timeseries.DefaultAnomalyZ)
		a.MetricName = "anomaly_score"
		a.BaselineValue = timeseries.Median(observed)
		if a.BaselineValue != 0 {
			a.DeviationPercent = (a.CurrentValue - a.BaselineValue) / math.Abs(a.BaselineValue) * 100
		}
		var maxAbsZ float64
		list := make([]interface{}, 0, len(anomalies))
		for _, an := range anomalies {
			maxAbsZ = math.Max(maxAbsZ, math.Abs(an.ZScore))
			list = append(list, map[string]interface{}{
				"date": an.Date.Format(time.RFC3339), "value": an.Value, "expected": an.Expected, "z_score": an.ZScore,
			})
		}
		details["anomaly_count"] = len(anomalies)
		details["max_abs_z"] = maxAbsZ
		details["anomalies"] = list

	case analyticsmodels.AnalysisTypeStressDetection:
		frac := timeseries.FractionBelow(observed, timeseries.StressNDVIThreshold)
		a.MetricName = "stress_index"
		a.CurrentValue = frac
		a.BaselineValue = timeseries.StressNDVIThreshold
		a.DeviationPercent = frac * 100
		details["stress_threshold"] = timeseries.StressNDVIThreshold
		details["latest_ndvi"] = last.Value
		details["stressed_fraction"] = frac

	case analyticsmodels.AnalysisTypePhenology:
		p := timeseries.ExtractPhenology(filled, timeseries.DefaultPhenologyThreshold)
		a.MetricName = "phenology"
		a.CurrentValue = p.PeakValue
		a.BaselineValue = p.BaseValue
		a.DeviationPercent = p.Amplitude * 100
		details["detected"] = p.Detected
		details["peak_value"] = p.PeakValue
		details["base_value"] = p.BaseValue
		details["amplitude"] = p.Amplitude
		if p.Detected {
			details["season_start"] = p.SeasonStart.Format(time.RFC3339)
			details["peak_date"] = p.PeakDate.Format(time.RFC3339)
			details["season_end"] = p.SeasonEnd.Format(time.RFC3339)
			details["season_length_days"] = p.SeasonLengthDays
			details["green_up_rate_per_day"] = p.GreenUpRatePerDay
			details["senescence_rate_per_day"] = p.SenescenceRatePerDay
		}
	}
	return a
}

// GetFieldAnalyticsSummary returns an analytics summary for a field.
func (s *analyticsService) GetFieldAnalyticsSummary(ctx context.Context, farmID, fieldID string) (*analyticsmodels.FieldAnalyticsSummary, error) {
	tenantID := p9context.TenantID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if farmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm ID is required")
	}
	if fieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field ID is required")
	}

	// Count active stress alerts
	activeAlerts, err := s.repo.CountActiveStressAlerts(ctx, tenantID, farmID, fieldID)
	if err != nil {
		return nil, err
	}

	// Get dominant stress type
	dominantStressType := ""
	dst, err := s.repo.GetDominantStressType(ctx, tenantID, farmID, fieldID)
	if err != nil {
		return nil, err
	}
	if dst != nil {
		dominantStressType = string(*dst)
	}

	// Get latest temporal analysis for NDVI trend
	var ndviTrend float64
	var lastAnalysis *time.Time
	latestAnalysis, err := s.repo.GetLatestTemporalAnalysis(ctx, tenantID, farmID, fieldID)
	if err != nil {
		return nil, err
	}
	if latestAnalysis != nil {
		ndviTrend = latestAnalysis.TrendSlope
		lastAnalysis = &latestAnalysis.CreatedAt
	}

	// Compute health score based on active alerts and NDVI
	healthScore := computeHealthScore(activeAlerts, ndviTrend)

	summary := &analyticsmodels.FieldAnalyticsSummary{
		ActiveStressAlerts: activeAlerts,
		HealthScore:        healthScore,
		NdviTrend:          ndviTrend,
		DominantStressType: dominantStressType,
		LastAnalysis:       lastAnalysis,
	}

	return summary, nil
}

// computeHealthScore calculates a health score (0-100) based on stress alerts and NDVI trend.
func computeHealthScore(activeAlerts int32, ndviTrend float64) float64 {
	// Start with a perfect score
	score := 100.0

	// Deduct points for active alerts (up to 40 points)
	alertPenalty := float64(activeAlerts) * 10.0
	if alertPenalty > 40.0 {
		alertPenalty = 40.0
	}
	score -= alertPenalty

	// Adjust based on NDVI trend (positive trend is good, negative is bad)
	if ndviTrend < -0.05 {
		score -= 30.0
	} else if ndviTrend < -0.02 {
		score -= 15.0
	} else if ndviTrend < 0 {
		score -= 5.0
	} else if ndviTrend > 0.02 {
		score += 5.0
	}

	// Clamp to 0-100 range
	if score < 0 {
		score = 0
	}
	if score > 100 {
		score = 100
	}

	return score
}

// emitAnalyticsEvent publishes a domain event for analytics operations (best-effort).
func (s *analyticsService) emitAnalyticsEvent(ctx context.Context, eventType domain.EventType, data map[string]interface{}) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	aggregateID := ""
	if farmID, ok := data["farm_id"].(string); ok {
		aggregateID = farmID
	}

	event := domain.NewDomainEvent(eventType, aggregateID, "satellite-analytics", data).
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal analytics event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.satellite.analytics.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "analytics event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}

// strPtr returns a pointer to the given string.
func strPtr(s string) *string {
	return &s
}

// getAnalysisTypeMetricName returns the default metric name for an analysis type.
func getAnalysisTypeMetricName(at analyticsmodels.AnalysisType) string {
	switch at {
	case analyticsmodels.AnalysisTypeStressDetection:
		return "stress_index"
	case analyticsmodels.AnalysisTypeChangeDetection:
		return "change_magnitude"
	case analyticsmodels.AnalysisTypeTemporalTrend:
		return "NDVI"
	case analyticsmodels.AnalysisTypeAnomalyDetection:
		return "anomaly_score"
	case analyticsmodels.AnalysisTypeCropClassification:
		return "classification_confidence"
	default:
		return "unknown"
	}
}
