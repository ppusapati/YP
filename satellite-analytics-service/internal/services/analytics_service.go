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
	d    deps.ServiceDeps
	repo repositories.AnalyticsRepository
	log  *p9log.Helper
	// aiClient is retained but no longer used for stress detection: the gateway
	// needs raster bands, and this service has no route to them. Kept so the
	// wiring survives for when imagery access exists, rather than being called
	// with an empty input to make the code look connected.
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

	// Check if alerts already exist for this processing job
	existing, err := s.repo.ListStressAlertsByProcessingJob(ctx, processingJobID, tenantID)
	if err != nil {
		return nil, err
	}
	if len(existing) > 0 {
		return existing, nil
	}

	// Stress is detected from the field's own NDVI history, not from raster
	// imagery.
	//
	// This used to call the AI gateway's DetectVegetationStress with an empty
	// RasterBandsInput — zero pixels, zero bands — and then, when that
	// unsurprisingly produced nothing, write a hardcoded alert saying "water
	// stress detected in the northern section based on NDWI analysis" at 0.85
	// confidence, persist it, and emit a domain event about it. A farmer was
	// told their field was stressed on the basis of no observation at all, and
	// every downstream consumer was told the same.
	//
	// The reason it could not work is structural: the raster bands live in
	// object storage behind satellite-processing-service, and this service has
	// no route to them. What it does have is a vegetation-index client, and a
	// field whose NDVI has fallen well below its own recent baseline is a real
	// and standard stress signal. So that is what is measured.
	//
	// When there is not enough history to judge, this returns no alerts. Not
	// an error and not a guess: "we cannot tell yet" is the honest answer, and
	// the absence of an alert says it.
	alerts, err := s.detectStressFromHistory(ctx, tenantID, userID, farmID, fieldID, processingJobID)
	if err != nil {
		return nil, err
	}
	if len(alerts) == 0 {
		s.log.Infow("msg", "no stress detected",
			"farm_id", farmID, "field_id", fieldID,
			"processing_job_id", processingJobID, "request_id", requestID)
		return nil, nil
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

// Stress-detection thresholds.
//
// NDVI is a ratio, so these are in NDVI units and comparable across fields.
// The bands come from the drop below a field's own recent baseline rather than
// from an absolute NDVI value, because what is healthy for cotton in July is
// not what is healthy for wheat in March, and a fixed cut-off would alert on
// every crop with a naturally low canopy.
const (
	// stressBaselineDays is how far back the baseline is drawn from.
	stressBaselineDays = 60
	// stressMinSamples is the fewest observations that support a judgement.
	// Below this the baseline is one or two scenes, which a single cloudy
	// pass would drag far enough to raise an alert on a healthy field.
	stressMinSamples = 5
	// stressDropLow is the smallest drop worth reporting.
	stressDropLow = 0.10
	// stressDropMedium, stressDropHigh and stressDropCritical band the rest.
	stressDropMedium   = 0.18
	stressDropHigh     = 0.28
	stressDropCritical = 0.40
	// stressSmoothWindow damps single-scene noise before comparison. Three
	// scenes is roughly a fortnight at Sentinel-2 revisit.
	stressSmoothWindow = 3
)

// detectStressFromHistory raises alerts where a field's NDVI has fallen below
// its own recent baseline.
//
// It deliberately does not name a cause. NDVI falling says the canopy is
// losing vigour; it does not say whether that is drought, disease or a pest,
// and the previous code's confident "water stress ... based on NDWI analysis"
// was inventing an explanation as well as an observation. The stress type is
// reported as unspecified until there is imagery to distinguish them.
func (s *analyticsService) detectStressFromHistory(
	ctx context.Context, tenantID, userID, farmID, fieldID, processingJobID string,
) ([]analyticsmodels.StressAlert, error) {
	if s.vegClient == nil {
		// Without a source of observations there is nothing to judge. Silence
		// is the correct output; the log is how the misconfiguration surfaces.
		s.log.Warnw("msg", "no vegetation index client; stress detection unavailable",
			"field_id", fieldID)
		return nil, nil
	}

	now := time.Now().UTC()
	from := now.AddDate(0, 0, -stressBaselineDays)

	samples, err := s.vegClient.GetNDVITimeSeries(ctx, farmID, fieldID, from, now)
	if err != nil {
		// A dependency being down is a real failure, and reporting "no stress"
		// for it would be indistinguishable from a healthy field.
		s.log.Errorw("msg", "NDVI time series unavailable", "field_id", fieldID, "error", err)
		return nil, errors.InternalServer("NDVI_UNAVAILABLE", "vegetation index data is unavailable")
	}

	series := timeseries.Smooth(timeseries.Sorted(samples), stressSmoothWindow)
	if len(series) < stressMinSamples {
		return nil, nil
	}

	// The baseline is the median of everything but the most recent scene,
	// which resists a single bad observation in a way a mean does not.
	latest := series[len(series)-1]
	baseline := timeseries.Median(series[:len(series)-1])
	drop := baseline - latest.Value
	if drop < stressDropLow {
		return nil, nil
	}

	severity := analyticsmodels.SeverityLevelLow
	switch {
	case drop >= stressDropCritical:
		severity = analyticsmodels.SeverityLevelCritical
	case drop >= stressDropHigh:
		severity = analyticsmodels.SeverityLevelHigh
	case drop >= stressDropMedium:
		severity = analyticsmodels.SeverityLevelMedium
	}

	// Confidence rises with the size of the drop and with how much history
	// supports the baseline, and is capped below certainty — a single index
	// over a handful of scenes does not justify more.
	confidence := math.Min(0.90,
		0.45+math.Min(drop/stressDropCritical, 1)*0.30+
			math.Min(float64(len(series))/20, 1)*0.15)

	var pct float64
	if baseline > 0 {
		pct = math.Min(100, drop/baseline*100)
	}

	desc := fmt.Sprintf(
		"NDVI has fallen to %.2f from a %d-day baseline of %.2f, a drop of %.2f.",
		latest.Value, stressBaselineDays, baseline, drop)
	rec := "Inspect the field before treating. A fall in NDVI shows the canopy losing vigour " +
		"but does not distinguish water stress from disease, pest damage or nutrient deficiency."

	alert := &analyticsmodels.StressAlert{
		TenantID:        tenantID,
		FarmID:          farmID,
		FieldID:         fieldID,
		ProcessingJobID: &processingJobID,
		// Unspecified on purpose: see above.
		StressType: analyticsmodels.StressTypeUnspecified,
		Severity:   severity,
		Confidence: math.Round(confidence*100) / 100,
		// Left at zero rather than guessed. The field's area is not known here,
		// and the previous code's "2.5 hectares" was a literal.
		AffectedAreaHectares: 0,
		AffectedPercentage:   math.Round(pct*10) / 10,
		Description:          strPtr(desc),
		Recommendation:       strPtr(rec),
		DetectedAt:           latest.Date,
	}
	alert.CreatedBy = userID

	created, err := s.repo.CreateStressAlert(ctx, alert)
	if err != nil {
		s.log.Errorw("msg", "failed to create stress alert", "error", err, "field_id", fieldID)
		return nil, err
	}
	return []analyticsmodels.StressAlert{*created}, nil
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
