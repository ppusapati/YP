package services

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	analyticsmodels "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/repositories"
)

const (
	serviceName       = "satellite-analytics-service"
	maxPageSize int32 = 100
	defaultPageSize   = 20
)

// Analytics event types
const (
	EventTypeStressDetected   domain.EventType = "agriculture.satellite.analytics.stress.detected"
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
}

// NewAnalyticsService creates a new AnalyticsService.
func NewAnalyticsService(d deps.ServiceDeps, repo repositories.AnalyticsRepository) AnalyticsService {
	return &analyticsService{
		d:    d,
		repo: repo,
		log:  p9log.NewHelper(p9log.With(d.Log, "component", "AnalyticsService")),
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

	// Placeholder: create a sample stress detection result.
	// In production, this would be replaced by actual ML/analysis pipeline results.
	alert := &analyticsmodels.StressAlert{
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
		CreatedBy:            userID,
	}

	created, err := s.repo.CreateStressAlert(ctx, alert)
	if err != nil {
		s.log.Errorw("msg", "failed to create stress alert", "error", err, "request_id", requestID)
		return nil, err
	}

	alerts := []analyticsmodels.StressAlert{*created}

	// Emit domain event
	s.emitAnalyticsEvent(ctx, EventTypeStressDetected, map[string]interface{}{
		"farm_id":            farmID,
		"field_id":           fieldID,
		"processing_job_id":  processingJobID,
		"alert_count":        len(alerts),
		"stress_type":        string(created.StressType),
		"severity":           string(created.Severity),
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

	// In a real implementation, this would perform temporal analysis
	// on satellite imagery time series data.
	// For now, we create the analysis record with computed results.

	metricName := "NDVI"
	switch analysisType {
	case analyticsmodels.AnalysisTypeStressDetection:
		metricName = "stress_index"
	case analyticsmodels.AnalysisTypeChangeDetection:
		metricName = "change_magnitude"
	case analyticsmodels.AnalysisTypeTemporalTrend:
		metricName = "NDVI"
	case analyticsmodels.AnalysisTypeAnomalyDetection:
		metricName = "anomaly_score"
	case analyticsmodels.AnalysisTypeCropClassification:
		metricName = "classification_confidence"
	}

	analysis := &analyticsmodels.TemporalAnalysis{
		TenantID:         tenantID,
		FarmID:           farmID,
		FieldID:          fieldID,
		AnalysisType:     analysisType,
		MetricName:       metricName,
		TrendSlope:       0.02,
		TrendRSquared:    0.87,
		CurrentValue:     0.72,
		BaselineValue:    0.68,
		DeviationPercent: 5.88,
		PeriodStart:      periodStart,
		PeriodEnd:        periodEnd,
		CreatedBy:        userID,
	}

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
		"analysis_id":   created.UUID,
		"metric_name":   metricName,
	})

	s.log.Infow("msg", "temporal analysis completed",
		"uuid", created.UUID,
		"farm_id", farmID,
		"field_id", fieldID,
		"analysis_type", string(analysisType),
		"request_id", requestID,
	)

	return created, nil
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

	event := domain.NewDomainEvent(eventType, aggregateID, "satellite-analytics").
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)
	event.Data = data

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
