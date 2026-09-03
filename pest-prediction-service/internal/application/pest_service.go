// Package application contains the pest-prediction-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ai"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/outbound"
)

const (
	serviceName           = "pest-prediction-service"
	eventTopic            = "samavaya.agriculture.pest-prediction.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type pestService struct {
	repo         outbound.PestRepository
	pub          outbound.EventPublisher
	fieldClient  outbound.FieldClient
	sensorClient outbound.SensorClient
	farmClient   outbound.FarmClient
	pool         *pgxpool.Pool
	log          *p9log.Helper
	aiClient     *ai.AIClient
}

// NewPestService creates a new application-layer PestService.
func NewPestService(
	repo outbound.PestRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	sensorClient outbound.SensorClient,
	farmClient outbound.FarmClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
	aiClient *ai.AIClient,
) inbound.PestService {
	return &pestService{
		repo:         repo,
		pub:          pub,
		fieldClient:  fieldClient,
		sensorClient: sensorClient,
		farmClient:   farmClient,
		pool:         pool,
		log:          p9log.NewHelper(p9log.With(log, "component", "PestService")),
		aiClient:     aiClient,
	}
}

// ---------------------------------------------------------------------------
// PredictPestRisk
// ---------------------------------------------------------------------------

func (s *pestService) PredictPestRisk(ctx context.Context, params *domain.PredictPestRiskParams) (*domain.PestPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if params.CropType == "" {
		return nil, errors.BadRequest("INVALID_CROP_TYPE", "crop_type is required")
	}
	if userID == "" {
		userID = "system"
	}
	params.TenantID = tenantID

	// Compute risk score from weather + growth stage
	riskScore := computeRiskScore(params)
	riskLevel := domain.RiskLevelFromScore(riskScore)
	confidence := computeConfidence(params)

	// Historical occurrence count
	histCount := 0
	if params.PestSpeciesID != "" {
		cnt, err := s.repo.CountPredictionsBySpecies(ctx, params.PestSpeciesID, tenantID)
		if err != nil {
			s.log.Errorw("msg", "failed to count historical predictions", "error", err)
		} else {
			histCount = cnt
		}
	}

	// Generate treatment recommendations
	treatments := generateTreatments(riskLevel)
	treatmentsJSON, _ := json.Marshal(treatments)

	// Predicted dates
	now := time.Now().UTC()
	onsetDate := now.Add(7 * 24 * time.Hour)
	peakDate := now.Add(14 * 24 * time.Hour)
	twStart := now
	twEnd := now.Add(7 * 24 * time.Hour)

	var gs *domain.GrowthStage
	if params.GrowthStage != nil {
		gs = params.GrowthStage
	}

	prediction := &domain.PestPrediction{
		TenantID:                  tenantID,
		FarmID:                    params.FarmID,
		FieldID:                   params.FieldID,
		PestSpeciesUUID:           params.PestSpeciesID,
		PredictionDate:            now,
		RiskLevel:                 riskLevel,
		RiskScore:                 riskScore,
		ConfidencePct:             confidence,
		CropType:                  params.CropType,
		GrowthStage:               gs,
		GeographicRiskFactor:      0,
		HistoricalOccurrenceCount: histCount,
		TemperatureCelsius:        &params.Weather.TemperatureCelsius,
		HumidityPct:               &params.Weather.HumidityPct,
		RainfallMm:                &params.Weather.RainfallMm,
		WindSpeedKmh:              &params.Weather.WindSpeedKmh,
		PredictedOnsetDate:        &onsetDate,
		PredictedPeakDate:         &peakDate,
		TreatmentWindowStart:      &twStart,
		TreatmentWindowEnd:        &twEnd,
		RecommendedTreatments:     treatmentsJSON,
	}
	prediction.CreatedBy = userID

	created, err := s.repo.CreatePrediction(ctx, prediction)
	if err != nil {
		return nil, err
	}

	// Auto-create alert if risk >= HIGH
	if riskLevel.Severity() >= domain.RiskLevelHigh.Severity() {
		alert := &domain.PestAlert{
			TenantID:        tenantID,
			PredictionUUID:  created.ID,
			FarmID:          params.FarmID,
			FieldID:         params.FieldID,
			PestSpeciesUUID: params.PestSpeciesID,
			RiskLevel:       riskLevel,
			Status:          domain.AlertStatusActive,
			Title:           fmt.Sprintf("%s pest risk alert for field %s", riskLevel, params.FieldID),
			Message:         fmt.Sprintf("Risk score %d detected. Immediate attention recommended.", riskScore),
		}
		if _, err := s.repo.CreateAlert(ctx, alert); err != nil {
			s.log.Errorw("msg", "failed to auto-create alert", "error", err)
		}
	}

	s.emitEvent(ctx, "agriculture.pest-prediction.predicted", created.ID, map[string]interface{}{
		"prediction_id": created.ID, "tenant_id": tenantID, "risk_level": string(riskLevel),
	})
	s.log.Infow("msg", "pest risk predicted", "uuid", created.ID, "risk_level", riskLevel, "risk_score", riskScore)

	return created, nil
}

// ---------------------------------------------------------------------------
// GetPrediction
// ---------------------------------------------------------------------------

func (s *pestService) GetPrediction(ctx context.Context, id string) (*domain.PestPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "prediction ID is required")
	}
	return s.repo.GetPredictionByID(ctx, id, tenantID)
}

// ---------------------------------------------------------------------------
// ListPredictions
// ---------------------------------------------------------------------------

func (s *pestService) ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.PestPrediction, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = normalizePageSize(params.PageSize)
	return s.repo.ListPredictions(ctx, params)
}

// ---------------------------------------------------------------------------
// ReportObservation
// ---------------------------------------------------------------------------

func (s *pestService) ReportObservation(ctx context.Context, obs *domain.PestObservation) (*domain.PestObservation, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	obs.TenantID = tenantID
	obs.ObservedBy = userID
	if obs.ObservedAt.IsZero() {
		obs.ObservedAt = time.Now().UTC()
	}

	created, err := s.repo.CreateObservation(ctx, obs)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.pest-prediction.observation.reported", created.ID, map[string]interface{}{
		"observation_id": created.ID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "observation reported", "uuid", created.ID)

	return created, nil
}

// ---------------------------------------------------------------------------
// ListObservations
// ---------------------------------------------------------------------------

func (s *pestService) ListObservations(ctx context.Context, params domain.ListObservationsParams) ([]domain.PestObservation, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = normalizePageSize(params.PageSize)
	return s.repo.ListObservations(ctx, params)
}

// ---------------------------------------------------------------------------
// GetPestSpecies
// ---------------------------------------------------------------------------

func (s *pestService) GetPestSpecies(ctx context.Context, id string) (*domain.PestSpecies, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "species ID is required")
	}
	return s.repo.GetSpeciesByID(ctx, id, tenantID)
}

// ---------------------------------------------------------------------------
// ListPestSpecies
// ---------------------------------------------------------------------------

func (s *pestService) ListPestSpecies(ctx context.Context, params domain.ListPestSpeciesParams) ([]domain.PestSpecies, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = normalizePageSize(params.PageSize)
	return s.repo.ListSpecies(ctx, params)
}

// ---------------------------------------------------------------------------
// GetTreatmentPlan
// ---------------------------------------------------------------------------

func (s *pestService) GetTreatmentPlan(ctx context.Context, predictionID string) (*domain.PestPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if predictionID == "" {
		return nil, errors.BadRequest("MISSING_ID", "prediction ID is required")
	}
	return s.repo.GetPredictionByID(ctx, predictionID, tenantID)
}

// ---------------------------------------------------------------------------
// GetRiskMap
// ---------------------------------------------------------------------------

func (s *pestService) GetRiskMap(ctx context.Context, pestSpeciesID, region string) (*domain.PestRiskMap, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if pestSpeciesID == "" {
		return nil, errors.BadRequest("MISSING_SPECIES_ID", "pest_species_id is required")
	}
	if region == "" {
		return nil, errors.BadRequest("MISSING_REGION", "region is required")
	}
	return s.repo.GetRiskMap(ctx, pestSpeciesID, region, tenantID)
}

// ---------------------------------------------------------------------------
// ListAlerts
// ---------------------------------------------------------------------------

func (s *pestService) ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PestAlert, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = normalizePageSize(params.PageSize)
	return s.repo.ListAlerts(ctx, params)
}

// ---------------------------------------------------------------------------
// AcknowledgeAlert
// ---------------------------------------------------------------------------

func (s *pestService) AcknowledgeAlert(ctx context.Context, id string) (*domain.PestAlert, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "alert ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	alert, err := s.repo.AcknowledgeAlert(ctx, id, tenantID, userID)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.pest-prediction.alert.acknowledged", id, map[string]interface{}{
		"alert_id": id, "tenant_id": tenantID, "acknowledged_by": userID,
	})
	s.log.Infow("msg", "alert acknowledged", "uuid", id)

	return alert, nil
}

// ---------------------------------------------------------------------------
// Risk computation helpers
// ---------------------------------------------------------------------------

func computeRiskScore(params *domain.PredictPestRiskParams) int {
	score := 0.0
	w := params.Weather

	// Temperature factor (0-25 points): pests thrive in warm conditions
	switch {
	case w.TemperatureCelsius >= 20 && w.TemperatureCelsius <= 35:
		score += 25
	case w.TemperatureCelsius >= 15 && w.TemperatureCelsius < 20:
		score += 15
	case w.TemperatureCelsius > 35 && w.TemperatureCelsius <= 40:
		score += 10
	}

	// Humidity factor (0-25 points)
	switch {
	case w.HumidityPct > 80:
		score += 25
	case w.HumidityPct > 60:
		score += 15
	case w.HumidityPct > 40:
		score += 5
	}

	// Rainfall factor (0-15 points)
	switch {
	case w.RainfallMm > 50:
		score += 15
	case w.RainfallMm > 20:
		score += 10
	case w.RainfallMm > 5:
		score += 5
	}

	// Wind factor (0-10 points)
	switch {
	case w.WindSpeedKmh > 15 && w.WindSpeedKmh < 40:
		score += 10
	case w.WindSpeedKmh > 5:
		score += 5
	}

	// Growth stage modifier (0-25 points)
	if params.GrowthStage != nil {
		switch *params.GrowthStage {
		case domain.GrowthStageFlowering:
			score += 25
		case domain.GrowthStageFruiting:
			score += 20
		case domain.GrowthStageVegetative:
			score += 15
		case domain.GrowthStageSeedling:
			score += 15
		case domain.GrowthStageGermination:
			score += 10
		case domain.GrowthStageMaturation:
			score += 10
		case domain.GrowthStageHarvest:
			score += 5
		}
	}

	if score > 100 {
		score = 100
	}
	return int(score)
}

func computeConfidence(params *domain.PredictPestRiskParams) float64 {
	nonZero := 0
	w := params.Weather
	if w.TemperatureCelsius != 0 {
		nonZero++
	}
	if w.HumidityPct != 0 {
		nonZero++
	}
	if w.RainfallMm != 0 {
		nonZero++
	}
	if w.WindSpeedKmh != 0 {
		nonZero++
	}
	c := 0.6 + 0.1*float64(nonZero)
	if c > 1.0 {
		c = 1.0
	}
	return c
}

func generateTreatments(rl domain.RiskLevel) []domain.RecommendedTreatment {
	switch rl {
	case domain.RiskLevelCritical:
		return []domain.RecommendedTreatment{
			{TreatmentType: domain.TreatmentTypeChemical, ProductName: "Broad-spectrum insecticide", ApplicationRate: "2L/ha", ApplicationMethod: "Foliar spray", Timing: "Immediate", SafetyInterval: "14 days"},
			{TreatmentType: domain.TreatmentTypeBiological, ProductName: "Bacillus thuringiensis", ApplicationRate: "1kg/ha", ApplicationMethod: "Foliar spray", Timing: "Within 48 hours", SafetyInterval: "0 days"},
		}
	case domain.RiskLevelHigh:
		return []domain.RecommendedTreatment{
			{TreatmentType: domain.TreatmentTypeChemical, ProductName: "Targeted pesticide", ApplicationRate: "1.5L/ha", ApplicationMethod: "Spot treatment", Timing: "Within 3 days", SafetyInterval: "7 days"},
			{TreatmentType: domain.TreatmentTypeCultural, ProductName: "Crop rotation planning", ApplicationRate: "N/A", ApplicationMethod: "Field management", Timing: "Next season", SafetyInterval: "N/A"},
		}
	case domain.RiskLevelModerate:
		return []domain.RecommendedTreatment{
			{TreatmentType: domain.TreatmentTypeBiological, ProductName: "Beneficial insects release", ApplicationRate: "5000/ha", ApplicationMethod: "Field release", Timing: "Within 1 week", SafetyInterval: "0 days"},
		}
	default:
		return []domain.RecommendedTreatment{
			{TreatmentType: domain.TreatmentTypeCultural, ProductName: "Monitoring traps", ApplicationRate: "10/ha", ApplicationMethod: "Field placement", Timing: "Ongoing", SafetyInterval: "N/A"},
		}
	}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func normalizePageSize(ps int32) int32 {
	if ps <= 0 {
		return defaultPageSize
	}
	if ps > maxPageSize {
		return maxPageSize
	}
	return ps
}

func (s *pestService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
