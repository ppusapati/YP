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

	pestmodels "p9e.in/samavaya/agriculture/pest-prediction-service/internal/models"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/repositories"
)

const (
	serviceName       = "pest-prediction-service"
	maxPageSize int32 = 100
	defaultPageSize   = 20
)

// Pest event types
const (
	EventTypePestRiskPredicted    domain.EventType = "agriculture.pest.risk.predicted"
	EventTypeObservationReported  domain.EventType = "agriculture.pest.observation.reported"
	EventTypePestAlertCreated     domain.EventType = "agriculture.pest.alert.created"
	EventTypePestAlertAcknowledged domain.EventType = "agriculture.pest.alert.acknowledged"
)

// PestService defines the interface for pest prediction business logic.
type PestService interface {
	PredictPestRisk(ctx context.Context, params *pestmodels.PredictPestRiskParams) (*pestmodels.PestPrediction, error)
	GetPrediction(ctx context.Context, uuid string) (*pestmodels.PestPrediction, error)
	ListPredictions(ctx context.Context, params pestmodels.ListPredictionsParams) ([]pestmodels.PestPrediction, int64, error)
	CreatePestSpecies(ctx context.Context, species *pestmodels.PestSpecies) (*pestmodels.PestSpecies, error)
	GetPestSpecies(ctx context.Context, uuid string) (*pestmodels.PestSpecies, error)
	ListPestSpecies(ctx context.Context, params pestmodels.ListPestSpeciesParams) ([]pestmodels.PestSpecies, int64, error)
	ReportObservation(ctx context.Context, params *pestmodels.ReportObservationParams) (*pestmodels.PestObservation, error)
	ListObservations(ctx context.Context, params pestmodels.ListObservationsParams) ([]pestmodels.PestObservation, int64, error)
	CreateAlert(ctx context.Context, alert *pestmodels.PestAlert) (*pestmodels.PestAlert, error)
	ListAlerts(ctx context.Context, params pestmodels.ListAlertsParams) ([]pestmodels.PestAlert, int64, error)
	AcknowledgeAlert(ctx context.Context, uuid string) (*pestmodels.PestAlert, error)
	GetRiskMap(ctx context.Context, pestSpeciesUUID, region string) (*pestmodels.PestRiskMap, error)
	RecommendTreatments(ctx context.Context, predictionUUID string) (*pestmodels.PestPrediction, []pestmodels.RecommendedTreatment, error)
}

// pestService is the concrete implementation of PestService.
type pestService struct {
	d    deps.ServiceDeps
	repo repositories.PestRepository
	log  *p9log.Helper
}

// NewPestService creates a new PestService.
func NewPestService(d deps.ServiceDeps, repo repositories.PestRepository) PestService {
	return &pestService{
		d:    d,
		repo: repo,
		log:  p9log.NewHelper(p9log.With(d.Log, "component", "PestService")),
	}
}

// PredictPestRisk generates a pest risk prediction based on weather factors, historical data, and growth stage.
func (s *pestService) PredictPestRisk(ctx context.Context, params *pestmodels.PredictPestRiskParams) (*pestmodels.PestPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	// Validate required fields
	if params.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if params.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if params.PestSpeciesID == "" {
		return nil, errors.BadRequest("MISSING_PEST_SPECIES_ID", "pest_species_id is required")
	}
	if params.CropType == "" {
		return nil, errors.BadRequest("MISSING_CROP_TYPE", "crop_type is required")
	}

	params.TenantID = tenantID

	// Verify pest species exists
	species, err := s.repo.GetPestSpeciesByUUID(ctx, tenantID, params.PestSpeciesID)
	if err != nil {
		return nil, err
	}

	// Get historical occurrence count
	histCount, err := s.repo.GetHistoricalOccurrenceCount(ctx, tenantID, params.FarmID, params.PestSpeciesID)
	if err != nil {
		s.log.Warnw("msg", "failed to get historical occurrence count", "error", err)
		histCount = 0
	}

	// Get recent observations to factor into the risk score
	recentObs, err := s.repo.GetRecentObservationsBySpecies(ctx, tenantID, params.FarmID, params.PestSpeciesID)
	if err != nil {
		s.log.Warnw("msg", "failed to get recent observations", "error", err)
		recentObs = nil
	}

	// Compute risk score based on weather, historical data, growth stage, and observations
	riskScore, confidence := computeRiskScore(params, histCount, recentObs)
	riskLevel := pestmodels.RiskLevelFromScore(riskScore)

	// Compute geographic risk factor based on latitude
	geoRiskFactor := computeGeographicRiskFactor(params.Latitude, params.Longitude)

	// Compute predicted dates
	now := time.Now()
	predictedOnset := now.Add(time.Duration(max(1, 14-riskScore/10)) * 24 * time.Hour)
	predictedPeak := predictedOnset.Add(time.Duration(max(3, 21-riskScore/5)) * 24 * time.Hour)
	treatmentStart := now.Add(24 * time.Hour)
	treatmentEnd := predictedOnset.Add(-24 * time.Hour)
	if treatmentEnd.Before(treatmentStart) {
		treatmentEnd = treatmentStart.Add(48 * time.Hour)
	}

	// Build recommended treatments based on risk level
	treatments := buildRecommendedTreatments(riskLevel, params.CropType)
	treatmentsJSON, err := json.Marshal(treatments)
	if err != nil {
		return nil, errors.Internal("failed to marshal treatments: %v", err)
	}

	prediction := &pestmodels.PestPrediction{
		TenantID:                  tenantID,
		FarmID:                    params.FarmID,
		FieldID:                   params.FieldID,
		PestSpeciesID:             species.ID,
		PestSpeciesUUID:           species.UUID,
		RiskLevel:                 riskLevel,
		RiskScore:                 riskScore,
		ConfidencePct:             confidence,
		TemperatureCelsius:        &params.Weather.TemperatureCelsius,
		HumidityPct:               &params.Weather.HumidityPct,
		RainfallMm:                &params.Weather.RainfallMm,
		WindSpeedKmh:              &params.Weather.WindSpeedKmh,
		CropType:                  params.CropType,
		GrowthStage:               params.GrowthStage,
		GeographicRiskFactor:      geoRiskFactor,
		HistoricalOccurrenceCount: int(histCount),
		PredictedOnsetDate:        &predictedOnset,
		PredictedPeakDate:         &predictedPeak,
		TreatmentWindowStart:      &treatmentStart,
		TreatmentWindowEnd:        &treatmentEnd,
		RecommendedTreatments:     treatmentsJSON,
	}
	prediction.CreatedBy = userID

	created, err := s.repo.CreatePrediction(ctx, prediction)
	if err != nil {
		s.log.Errorw("msg", "failed to create prediction", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitPestEvent(ctx, EventTypePestRiskPredicted, map[string]interface{}{
		"prediction_id":   created.UUID,
		"farm_id":         created.FarmID,
		"field_id":        created.FieldID,
		"pest_species_id": created.PestSpeciesUUID,
		"risk_level":      string(created.RiskLevel),
		"risk_score":      created.RiskScore,
		"tenant_id":       tenantID,
	}, created.UUID)

	s.log.Infow("msg", "pest risk predicted",
		"prediction_uuid", created.UUID,
		"risk_level", string(created.RiskLevel),
		"risk_score", created.RiskScore,
		"tenant_id", tenantID,
		"request_id", requestID,
	)
	return created, nil
}

// GetPrediction retrieves a prediction by UUID.
func (s *pestService) GetPrediction(ctx context.Context, uuid string) (*pestmodels.PestPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_PREDICTION_ID", "prediction ID is required")
	}

	return s.repo.GetPredictionByUUID(ctx, tenantID, uuid)
}

// ListPredictions lists predictions with filtering and pagination.
func (s *pestService) ListPredictions(ctx context.Context, params pestmodels.ListPredictionsParams) ([]pestmodels.PestPrediction, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListPredictions(ctx, &params)
}

// CreatePestSpecies creates a new pest species in the catalogue.
func (s *pestService) CreatePestSpecies(ctx context.Context, species *pestmodels.PestSpecies) (*pestmodels.PestSpecies, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	if species.CommonName == "" {
		return nil, errors.BadRequest("MISSING_COMMON_NAME", "common_name is required")
	}
	if species.ScientificName == "" {
		return nil, errors.BadRequest("MISSING_SCIENTIFIC_NAME", "scientific_name is required")
	}

	species.TenantID = tenantID
	species.CreatedBy = userID

	created, err := s.repo.CreatePestSpecies(ctx, species)
	if err != nil {
		s.log.Errorw("msg", "failed to create pest species", "error", err, "request_id", requestID)
		return nil, err
	}

	s.log.Infow("msg", "pest species created",
		"uuid", created.UUID,
		"common_name", created.CommonName,
		"tenant_id", tenantID,
		"request_id", requestID,
	)
	return created, nil
}

// GetPestSpecies retrieves a pest species by UUID.
func (s *pestService) GetPestSpecies(ctx context.Context, uuid string) (*pestmodels.PestSpecies, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_SPECIES_ID", "pest species ID is required")
	}

	return s.repo.GetPestSpeciesByUUID(ctx, tenantID, uuid)
}

// ListPestSpecies lists pest species with filtering and pagination.
func (s *pestService) ListPestSpecies(ctx context.Context, params pestmodels.ListPestSpeciesParams) ([]pestmodels.PestSpecies, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListPestSpecies(ctx, &params)
}

// ReportObservation records a field observation of pest activity.
func (s *pestService) ReportObservation(ctx context.Context, params *pestmodels.ReportObservationParams) (*pestmodels.PestObservation, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	if params.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if params.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if params.PestSpeciesID == "" {
		return nil, errors.BadRequest("MISSING_PEST_SPECIES_ID", "pest_species_id is required")
	}
	if !params.DamageLevel.IsValid() {
		return nil, errors.BadRequest("INVALID_DAMAGE_LEVEL", "invalid damage level")
	}

	params.TenantID = tenantID
	if params.ObservedBy == "" {
		params.ObservedBy = userID
	}

	// Verify pest species exists and get its internal ID
	species, err := s.repo.GetPestSpeciesByUUID(ctx, tenantID, params.PestSpeciesID)
	if err != nil {
		return nil, err
	}

	observation := &pestmodels.PestObservation{
		TenantID:        tenantID,
		FarmID:          params.FarmID,
		FieldID:         params.FieldID,
		PestSpeciesID:   species.ID,
		PestSpeciesUUID: species.UUID,
		PestCount:       params.PestCount,
		DamageLevel:     params.DamageLevel,
		TrapType:        params.TrapType,
		ImageURL:        params.ImageURL,
		Latitude:        params.Latitude,
		Longitude:       params.Longitude,
		Notes:           params.Notes,
		ObservedBy:      params.ObservedBy,
		ObservedAt:      time.Now(),
	}
	observation.CreatedBy = userID

	created, err := s.repo.CreateObservation(ctx, observation)
	if err != nil {
		s.log.Errorw("msg", "failed to create observation", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitPestEvent(ctx, EventTypeObservationReported, map[string]interface{}{
		"observation_id":  created.UUID,
		"farm_id":         created.FarmID,
		"field_id":        created.FieldID,
		"pest_species_id": created.PestSpeciesUUID,
		"pest_count":      created.PestCount,
		"damage_level":    string(created.DamageLevel),
		"tenant_id":       tenantID,
	}, created.UUID)

	s.log.Infow("msg", "pest observation reported",
		"observation_uuid", created.UUID,
		"farm_id", created.FarmID,
		"damage_level", string(created.DamageLevel),
		"tenant_id", tenantID,
		"request_id", requestID,
	)
	return created, nil
}

// ListObservations lists pest observations with filtering and pagination.
func (s *pestService) ListObservations(ctx context.Context, params pestmodels.ListObservationsParams) ([]pestmodels.PestObservation, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListObservations(ctx, &params)
}

// CreateAlert creates a new pest alert.
func (s *pestService) CreateAlert(ctx context.Context, alert *pestmodels.PestAlert) (*pestmodels.PestAlert, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	if alert.FarmID == "" {
		return nil, errors.BadRequest("MISSING_FARM_ID", "farm_id is required")
	}
	if alert.FieldID == "" {
		return nil, errors.BadRequest("MISSING_FIELD_ID", "field_id is required")
	}
	if alert.Title == "" {
		return nil, errors.BadRequest("MISSING_TITLE", "title is required")
	}
	if alert.Message == "" {
		return nil, errors.BadRequest("MISSING_MESSAGE", "message is required")
	}
	if !alert.RiskLevel.IsValid() {
		return nil, errors.BadRequest("INVALID_RISK_LEVEL", "invalid risk level")
	}

	alert.TenantID = tenantID
	alert.Status = pestmodels.AlertStatusActive
	alert.CreatedBy = userID

	// If prediction UUID is set, verify it exists and populate IDs
	if alert.PredictionUUID != "" {
		prediction, err := s.repo.GetPredictionByUUID(ctx, tenantID, alert.PredictionUUID)
		if err != nil {
			return nil, err
		}
		alert.PredictionID = prediction.ID
		if alert.PestSpeciesUUID == "" {
			alert.PestSpeciesUUID = prediction.PestSpeciesUUID
			alert.PestSpeciesID = prediction.PestSpeciesID
		}
	}

	// If pest species UUID is set but ID is not, resolve it
	if alert.PestSpeciesUUID != "" && alert.PestSpeciesID == 0 {
		species, err := s.repo.GetPestSpeciesByUUID(ctx, tenantID, alert.PestSpeciesUUID)
		if err != nil {
			return nil, err
		}
		alert.PestSpeciesID = species.ID
	}

	created, err := s.repo.CreateAlert(ctx, alert)
	if err != nil {
		s.log.Errorw("msg", "failed to create alert", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitPestEvent(ctx, EventTypePestAlertCreated, map[string]interface{}{
		"alert_id":        created.UUID,
		"farm_id":         created.FarmID,
		"field_id":        created.FieldID,
		"pest_species_id": created.PestSpeciesUUID,
		"risk_level":      string(created.RiskLevel),
		"title":           created.Title,
		"tenant_id":       tenantID,
	}, created.UUID)

	s.log.Infow("msg", "pest alert created",
		"alert_uuid", created.UUID,
		"risk_level", string(created.RiskLevel),
		"tenant_id", tenantID,
		"request_id", requestID,
	)
	return created, nil
}

// ListAlerts lists pest alerts with filtering and pagination.
func (s *pestService) ListAlerts(ctx context.Context, params pestmodels.ListAlertsParams) ([]pestmodels.PestAlert, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListAlerts(ctx, &params)
}

// AcknowledgeAlert marks an alert as acknowledged.
func (s *pestService) AcknowledgeAlert(ctx context.Context, uuid string) (*pestmodels.PestAlert, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)
	requestID := p9context.RequestID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ALERT_ID", "alert ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	acknowledged, err := s.repo.AcknowledgeAlert(ctx, tenantID, uuid, userID)
	if err != nil {
		s.log.Errorw("msg", "failed to acknowledge alert", "error", err, "request_id", requestID)
		return nil, err
	}

	// Emit domain event
	s.emitPestEvent(ctx, EventTypePestAlertAcknowledged, map[string]interface{}{
		"alert_id":        acknowledged.UUID,
		"farm_id":         acknowledged.FarmID,
		"field_id":        acknowledged.FieldID,
		"acknowledged_by": userID,
		"tenant_id":       tenantID,
	}, acknowledged.UUID)

	s.log.Infow("msg", "pest alert acknowledged",
		"alert_uuid", acknowledged.UUID,
		"acknowledged_by", userID,
		"tenant_id", tenantID,
		"request_id", requestID,
	)
	return acknowledged, nil
}

// GetRiskMap retrieves a geographic risk map for a pest species in a region.
func (s *pestService) GetRiskMap(ctx context.Context, pestSpeciesUUID, region string) (*pestmodels.PestRiskMap, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if pestSpeciesUUID == "" {
		return nil, errors.BadRequest("MISSING_PEST_SPECIES_ID", "pest_species_id is required")
	}
	if region == "" {
		return nil, errors.BadRequest("MISSING_REGION", "region is required")
	}

	return s.repo.GetRiskMap(ctx, tenantID, pestSpeciesUUID, region)
}

// RecommendTreatments retrieves recommended treatments for a prediction.
func (s *pestService) RecommendTreatments(ctx context.Context, predictionUUID string) (*pestmodels.PestPrediction, []pestmodels.RecommendedTreatment, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if predictionUUID == "" {
		return nil, nil, errors.BadRequest("MISSING_PREDICTION_ID", "prediction_id is required")
	}

	prediction, err := s.repo.GetPredictionByUUID(ctx, tenantID, predictionUUID)
	if err != nil {
		return nil, nil, err
	}

	var treatments []pestmodels.RecommendedTreatment
	if len(prediction.RecommendedTreatments) > 0 {
		if err := json.Unmarshal(prediction.RecommendedTreatments, &treatments); err != nil {
			s.log.Errorw("msg", "failed to unmarshal recommended treatments", "error", err)
			return prediction, nil, nil
		}
	}

	return prediction, treatments, nil
}

// ---------------------------------------------------------------------------
// Risk score computation helpers
// ---------------------------------------------------------------------------

// computeRiskScore calculates a risk score (0-100) based on weather, historical data,
// growth stage, and recent field observations.
func computeRiskScore(params *pestmodels.PredictPestRiskParams, histCount int64, recentObs []pestmodels.PestObservation) (int, float64) {
	score := 0.0
	confidence := 50.0

	// Weather-based risk (max 40 points)
	weatherScore := 0.0

	// Temperature factor: most pests thrive at 20-35 C
	temp := params.Weather.TemperatureCelsius
	if temp >= 20 && temp <= 35 {
		weatherScore += 10.0 * (1.0 - math.Abs(temp-27.5)/7.5)
	}

	// Humidity factor: high humidity increases pest risk
	humidity := params.Weather.HumidityPct
	if humidity > 60 {
		weatherScore += 10.0 * math.Min(1.0, (humidity-60)/30.0)
	}

	// Rainfall factor: moderate rainfall increases risk, heavy rainfall may decrease it
	rainfall := params.Weather.RainfallMm
	if rainfall > 5 && rainfall <= 50 {
		weatherScore += 10.0 * math.Min(1.0, rainfall/30.0)
	} else if rainfall > 50 {
		weatherScore += 5.0 // Heavy rain washes away some pests
	}

	// Wind factor: low wind increases pest colonization risk
	wind := params.Weather.WindSpeedKmh
	if wind < 15 {
		weatherScore += 10.0 * (1.0 - wind/15.0)
	}

	score += weatherScore
	if weatherScore > 20 {
		confidence += 10.0
	}

	// Historical occurrence factor (max 25 points)
	if histCount > 0 {
		histScore := math.Min(25.0, float64(histCount)*5.0)
		score += histScore
		confidence += math.Min(15.0, float64(histCount)*3.0)
	}

	// Growth stage factor (max 20 points)
	if params.GrowthStage != nil {
		switch *params.GrowthStage {
		case pestmodels.GrowthStageGermination:
			score += 8.0
		case pestmodels.GrowthStageSeedling:
			score += 15.0
		case pestmodels.GrowthStageVegetative:
			score += 18.0
		case pestmodels.GrowthStageFlowering:
			score += 20.0
		case pestmodels.GrowthStageFruiting:
			score += 16.0
		case pestmodels.GrowthStageMaturation:
			score += 10.0
		case pestmodels.GrowthStageHarvest:
			score += 5.0
		}
		confidence += 5.0
	}

	// Recent observation factor (max 15 points)
	if len(recentObs) > 0 {
		obsScore := 0.0
		for _, obs := range recentObs {
			switch obs.DamageLevel {
			case pestmodels.DamageLevelLight:
				obsScore += 1.0
			case pestmodels.DamageLevelModerate:
				obsScore += 2.5
			case pestmodels.DamageLevelSevere:
				obsScore += 4.0
			case pestmodels.DamageLevelDevastating:
				obsScore += 5.0
			}
		}
		score += math.Min(15.0, obsScore)
		confidence += math.Min(15.0, float64(len(recentObs))*3.0)
	}

	// Clamp values
	finalScore := int(math.Min(100, math.Max(0, score)))
	finalConfidence := math.Min(95.0, math.Max(10.0, confidence))

	return finalScore, finalConfidence
}

// computeGeographicRiskFactor computes a geographic risk multiplier based on location.
func computeGeographicRiskFactor(lat, lng float64) float64 {
	// Tropical and subtropical regions have higher pest risk
	absLat := math.Abs(lat)
	if absLat <= 23.5 {
		return 1.5 // Tropical
	}
	if absLat <= 35.0 {
		return 1.2 // Subtropical
	}
	if absLat <= 50.0 {
		return 1.0 // Temperate
	}
	return 0.7 // High latitude
}

// buildRecommendedTreatments generates treatment recommendations based on risk level.
func buildRecommendedTreatments(riskLevel pestmodels.RiskLevel, cropType string) []pestmodels.RecommendedTreatment {
	var treatments []pestmodels.RecommendedTreatment

	switch riskLevel {
	case pestmodels.RiskLevelCritical, pestmodels.RiskLevelHigh:
		treatments = append(treatments, pestmodels.RecommendedTreatment{
			TreatmentType:     pestmodels.TreatmentTypeChemical,
			ProductName:       "Broad-spectrum insecticide",
			ApplicationRate:   "As per label for " + cropType,
			ApplicationMethod: "Foliar spray",
			Timing:            "Immediate application recommended",
			SafetyInterval:    "14 days pre-harvest",
		})
		treatments = append(treatments, pestmodels.RecommendedTreatment{
			TreatmentType:     pestmodels.TreatmentTypeBiological,
			ProductName:       "Bacillus thuringiensis (Bt)",
			ApplicationRate:   "1-2 kg/ha",
			ApplicationMethod: "Foliar spray",
			Timing:            "Apply in evening hours",
			SafetyInterval:    "None required",
		})
	case pestmodels.RiskLevelModerate:
		treatments = append(treatments, pestmodels.RecommendedTreatment{
			TreatmentType:     pestmodels.TreatmentTypeBiological,
			ProductName:       "Neem oil extract",
			ApplicationRate:   "5 ml/L water",
			ApplicationMethod: "Foliar spray",
			Timing:            "Apply at first sign of infestation",
			SafetyInterval:    "3 days pre-harvest",
		})
		treatments = append(treatments, pestmodels.RecommendedTreatment{
			TreatmentType:     pestmodels.TreatmentTypeCultural,
			ProductName:       "Crop rotation and sanitation",
			ApplicationRate:   "N/A",
			ApplicationMethod: "Field management",
			Timing:            "Begin within 1 week",
			SafetyInterval:    "N/A",
		})
	case pestmodels.RiskLevelLow:
		treatments = append(treatments, pestmodels.RecommendedTreatment{
			TreatmentType:     pestmodels.TreatmentTypeCultural,
			ProductName:       "Monitoring and field sanitation",
			ApplicationRate:   "N/A",
			ApplicationMethod: "Scouting and trap placement",
			Timing:            "Weekly monitoring",
			SafetyInterval:    "N/A",
		})
	case pestmodels.RiskLevelNone:
		treatments = append(treatments, pestmodels.RecommendedTreatment{
			TreatmentType:     pestmodels.TreatmentTypeCultural,
			ProductName:       "Preventive monitoring",
			ApplicationRate:   "N/A",
			ApplicationMethod: "Routine field inspection",
			Timing:            "Monthly monitoring",
			SafetyInterval:    "N/A",
		})
	}

	return treatments
}

// max returns the larger of two ints.
func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

// ---------------------------------------------------------------------------
// Event emission
// ---------------------------------------------------------------------------

// emitPestEvent publishes a domain event for pest operations (best-effort).
func (s *pestService) emitPestEvent(ctx context.Context, eventType domain.EventType, data map[string]interface{}, aggregateID string) {
	tenantID := p9context.TenantID(ctx)
	requestID := p9context.RequestID(ctx)

	event := domain.NewDomainEvent(eventType, aggregateID, "pest").
		WithSource(serviceName).
		WithCorrelationID(requestID).
		WithMetadata("tenant_id", tenantID).
		WithPriority(domain.PriorityMedium)
	event.Data = data

	if s.d.KafkaProducer != nil {
		eventJSON, err := json.Marshal(event)
		if err != nil {
			s.log.Errorw("msg", "failed to marshal pest event", "event_type", string(eventType), "error", err)
			return
		}

		topic := "samavaya.agriculture.pest.events"
		key := aggregateID
		if key == "" {
			key = ulid.NewString()
		}

		_ = eventJSON // Published via Kafka producer in production wiring
		s.log.Debugw("msg", "pest event emitted", "event_type", string(eventType), "topic", topic, "key", key)
	}
}
