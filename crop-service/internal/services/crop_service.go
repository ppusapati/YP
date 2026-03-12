package services

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"strings"
	"time"

	cropmodels "p9e.in/samavaya/agriculture/crop-service/internal/models"
	"p9e.in/samavaya/agriculture/crop-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// CropService defines the business logic interface for crop operations.
type CropService interface {
	CreateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error)
	GetCrop(ctx context.Context, id, tenantID string) (*cropmodels.Crop, error)
	ListCrops(ctx context.Context, tenantID string, category *string, searchTerm *string, limit, offset int32) ([]*cropmodels.Crop, int32, error)
	UpdateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error)
	DeleteCrop(ctx context.Context, id, tenantID string) error

	AddVariety(ctx context.Context, variety *cropmodels.CropVariety) (*cropmodels.CropVariety, error)
	ListVarieties(ctx context.Context, cropUUID, tenantID string, limit, offset int32) ([]*cropmodels.CropVariety, int32, error)

	GetGrowthStages(ctx context.Context, cropUUID, tenantID string) ([]*cropmodels.CropGrowthStage, error)

	GetCropRequirements(ctx context.Context, cropUUID, tenantID string) (*cropmodels.CropRequirements, error)

	GenerateRecommendation(ctx context.Context, input *cropmodels.RecommendationInput) (*cropmodels.CropRecommendation, error)
}

// cropService is the concrete implementation of CropService.
type cropService struct {
	repo   repositories.CropRepository
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewCropService creates a new CropService instance.
func NewCropService(d deps.ServiceDeps, repo repositories.CropRepository) CropService {
	return &cropService{
		repo:   repo,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "CropService")),
	}
}

// ---------- Crop CRUD ----------

func (s *cropService) CreateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error) {
	// Validate required fields
	if strings.TrimSpace(crop.Name) == "" {
		return nil, errors.BadRequest("INVALID_CROP_NAME", "crop name is required")
	}
	if strings.TrimSpace(crop.TenantID) == "" {
		return nil, errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
	}

	// Check for duplicate name within tenant
	exists, err := s.repo.CropExistsByName(ctx, crop.TenantID, crop.Name)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.Conflict("CROP_ALREADY_EXISTS",
			fmt.Sprintf("crop with name '%s' already exists for this tenant", crop.Name))
	}

	// Ensure fields are initialized
	if crop.UUID == "" {
		crop.UUID = ulid.NewString()
	}
	if crop.Version == 0 {
		crop.Version = 1
	}
	crop.IsActive = true
	if crop.CreatedAt.IsZero() {
		crop.CreatedAt = time.Now()
	}
	if crop.CreatedBy == "" {
		crop.CreatedBy = p9context.UserID(ctx)
	}

	created, err := s.repo.CreateCrop(ctx, crop)
	if err != nil {
		return nil, err
	}

	// Publish domain event
	s.publishEvent(ctx, domain.EventType("agriculture.crop.created"), created.UUID, map[string]interface{}{
		"crop_id":   created.UUID,
		"tenant_id": created.TenantID,
		"name":      created.Name,
		"category":  string(created.Category),
	})

	s.logger.Infof("Crop created: id=%s name=%s tenant=%s", created.UUID, created.Name, created.TenantID)
	return created, nil
}

func (s *cropService) GetCrop(ctx context.Context, id, tenantID string) (*cropmodels.Crop, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop id is required")
	}
	if strings.TrimSpace(tenantID) == "" {
		return nil, errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
	}

	crop, err := s.repo.GetCropByUUID(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	// Eagerly load related data
	varieties, _, _ := s.repo.ListVarietiesByCropID(ctx, crop.ID, tenantID, 100, 0)
	if varieties != nil {
		for _, v := range varieties {
			crop.Varieties = append(crop.Varieties, *v)
		}
	}

	stages, _ := s.repo.GetGrowthStagesByCropID(ctx, crop.ID, tenantID)
	if stages != nil {
		for _, st := range stages {
			crop.GrowthStages = append(crop.GrowthStages, *st)
		}
	}

	reqs, reqErr := s.repo.GetCropRequirementsByCropID(ctx, crop.ID, tenantID)
	if reqErr == nil && reqs != nil {
		crop.Requirements = reqs
	}

	return crop, nil
}

func (s *cropService) ListCrops(ctx context.Context, tenantID string, category *string, searchTerm *string, limit, offset int32) ([]*cropmodels.Crop, int32, error) {
	if strings.TrimSpace(tenantID) == "" {
		return nil, 0, errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
	}

	if limit <= 0 {
		limit = 50
	}
	if limit > 200 {
		limit = 200
	}

	return s.repo.ListCrops(ctx, tenantID, category, searchTerm, limit, offset)
}

func (s *cropService) UpdateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error) {
	if strings.TrimSpace(crop.UUID) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop id is required")
	}
	if strings.TrimSpace(crop.TenantID) == "" {
		return nil, errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
	}
	if strings.TrimSpace(crop.Name) == "" {
		return nil, errors.BadRequest("INVALID_CROP_NAME", "crop name is required")
	}
	if crop.Version <= 0 {
		return nil, errors.BadRequest("INVALID_VERSION", "version must be a positive integer for optimistic concurrency")
	}

	updated, err := s.repo.UpdateCrop(ctx, crop)
	if err != nil {
		return nil, err
	}

	// Publish domain event
	s.publishEvent(ctx, domain.EventType("agriculture.crop.updated"), updated.UUID, map[string]interface{}{
		"crop_id":   updated.UUID,
		"tenant_id": updated.TenantID,
		"name":      updated.Name,
		"version":   updated.Version,
	})

	s.logger.Infof("Crop updated: id=%s version=%d", updated.UUID, updated.Version)
	return updated, nil
}

func (s *cropService) DeleteCrop(ctx context.Context, id, tenantID string) error {
	if strings.TrimSpace(id) == "" {
		return errors.BadRequest("INVALID_CROP_ID", "crop id is required")
	}
	if strings.TrimSpace(tenantID) == "" {
		return errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
	}

	deletedBy := p9context.UserID(ctx)
	if deletedBy == "" {
		deletedBy = "system"
	}

	err := s.repo.SoftDeleteCrop(ctx, id, tenantID, deletedBy)
	if err != nil {
		return err
	}

	// Publish domain event
	s.publishEvent(ctx, domain.EventType("agriculture.crop.deleted"), id, map[string]interface{}{
		"crop_id":    id,
		"tenant_id":  tenantID,
		"deleted_by": deletedBy,
	})

	s.logger.Infof("Crop deleted: id=%s tenant=%s", id, tenantID)
	return nil
}

// ---------- Varieties ----------

func (s *cropService) AddVariety(ctx context.Context, variety *cropmodels.CropVariety) (*cropmodels.CropVariety, error) {
	if strings.TrimSpace(variety.Name) == "" {
		return nil, errors.BadRequest("INVALID_VARIETY_NAME", "variety name is required")
	}
	if variety.CropID <= 0 {
		return nil, errors.BadRequest("INVALID_CROP_ID", "a valid crop_id is required to add a variety")
	}

	if variety.UUID == "" {
		variety.UUID = ulid.NewString()
	}
	variety.IsActive = true
	if variety.CreatedAt.IsZero() {
		variety.CreatedAt = time.Now()
	}
	if variety.CreatedBy == "" {
		variety.CreatedBy = p9context.UserID(ctx)
	}

	created, err := s.repo.CreateVariety(ctx, variety)
	if err != nil {
		return nil, err
	}

	// Publish domain event
	s.publishEvent(ctx, domain.EventType("agriculture.crop.variety_added"), created.UUID, map[string]interface{}{
		"variety_id": created.UUID,
		"crop_id":    created.CropID,
		"tenant_id":  created.TenantID,
		"name":       created.Name,
	})

	s.logger.Infof("Variety added: id=%s crop_id=%d", created.UUID, created.CropID)
	return created, nil
}

func (s *cropService) ListVarieties(ctx context.Context, cropUUID, tenantID string, limit, offset int32) ([]*cropmodels.CropVariety, int32, error) {
	// Resolve crop ID from UUID
	crop, err := s.repo.GetCropByUUID(ctx, cropUUID, tenantID)
	if err != nil {
		return nil, 0, err
	}

	if limit <= 0 {
		limit = 50
	}
	if limit > 200 {
		limit = 200
	}

	return s.repo.ListVarietiesByCropID(ctx, crop.ID, tenantID, limit, offset)
}

// ---------- Growth Stages ----------

func (s *cropService) GetGrowthStages(ctx context.Context, cropUUID, tenantID string) ([]*cropmodels.CropGrowthStage, error) {
	crop, err := s.repo.GetCropByUUID(ctx, cropUUID, tenantID)
	if err != nil {
		return nil, err
	}

	return s.repo.GetGrowthStagesByCropID(ctx, crop.ID, tenantID)
}

// ---------- Requirements ----------

func (s *cropService) GetCropRequirements(ctx context.Context, cropUUID, tenantID string) (*cropmodels.CropRequirements, error) {
	crop, err := s.repo.GetCropByUUID(ctx, cropUUID, tenantID)
	if err != nil {
		return nil, err
	}

	return s.repo.GetCropRequirementsByCropID(ctx, crop.ID, tenantID)
}

// ---------- Intelligence / Recommendations ----------

func (s *cropService) GenerateRecommendation(ctx context.Context, input *cropmodels.RecommendationInput) (*cropmodels.CropRecommendation, error) {
	if strings.TrimSpace(input.CropID) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}
	if strings.TrimSpace(input.TenantID) == "" {
		return nil, errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
	}
	if strings.TrimSpace(input.RecommendationType) == "" {
		return nil, errors.BadRequest("INVALID_RECOMMENDATION_TYPE", "recommendation_type is required")
	}

	// Resolve crop
	crop, err := s.repo.GetCropByUUID(ctx, input.CropID, input.TenantID)
	if err != nil {
		return nil, err
	}

	// Load requirements for comparison
	requirements, reqErr := s.repo.GetCropRequirementsByCropID(ctx, crop.ID, input.TenantID)
	if reqErr != nil {
		// If no requirements exist, produce a generic recommendation
		requirements = nil
	}

	// Generate recommendation based on type and current conditions
	rec := s.buildRecommendation(crop, requirements, input)

	// Persist the recommendation
	created, err := s.repo.CreateRecommendation(ctx, rec)
	if err != nil {
		return nil, err
	}

	// Publish domain event
	s.publishEvent(ctx, domain.EventType("agriculture.crop.recommendation_generated"), created.UUID, map[string]interface{}{
		"recommendation_id": created.UUID,
		"crop_id":           input.CropID,
		"tenant_id":         input.TenantID,
		"type":              input.RecommendationType,
		"confidence":        created.ConfidenceScore,
	})

	s.logger.Infof("Recommendation generated: id=%s crop=%s type=%s confidence=%.2f",
		created.UUID, input.CropID, input.RecommendationType, created.ConfidenceScore)
	return created, nil
}

// buildRecommendation generates an AI-like recommendation by comparing current conditions against requirements.
func (s *cropService) buildRecommendation(
	crop *cropmodels.Crop,
	requirements *cropmodels.CropRequirements,
	input *cropmodels.RecommendationInput,
) *cropmodels.CropRecommendation {
	now := time.Now()
	validUntil := now.Add(7 * 24 * time.Hour) // recommendations valid for 7 days

	title, description, severity, confidence := s.analyzeConditions(crop, requirements, input)

	params, _ := json.Marshal(map[string]interface{}{
		"current_temperature":  input.CurrentTemperature,
		"current_humidity":     input.CurrentHumidity,
		"current_soil_ph":      input.CurrentSoilPH,
		"current_soil_moisture": input.CurrentSoilMoisture,
		"growth_stage":         input.CurrentGrowthStage,
	})

	return &cropmodels.CropRecommendation{
		CropID:                crop.ID,
		TenantID:              input.TenantID,
		RecommendationType:    input.RecommendationType,
		Title:                 title,
		Description:           description,
		Severity:              severity,
		ConfidenceScore:       confidence,
		Parameters:            string(params),
		ApplicableGrowthStage: input.CurrentGrowthStage,
		ValidFrom:             &now,
		ValidUntil:            &validUntil,
	}
}

// analyzeConditions performs rule-based analysis comparing current conditions to crop requirements.
func (s *cropService) analyzeConditions(
	crop *cropmodels.Crop,
	requirements *cropmodels.CropRequirements,
	input *cropmodels.RecommendationInput,
) (title, description, severity string, confidence float64) {
	if requirements == nil {
		return s.generateGenericRecommendation(crop, input)
	}

	var issues []string
	var severityLevel int // 0=info, 1=warning, 2=critical

	// Temperature analysis
	if input.CurrentTemperature > 0 {
		if input.CurrentTemperature < requirements.OptimalTempMin {
			diff := requirements.OptimalTempMin - input.CurrentTemperature
			issues = append(issues, fmt.Sprintf("Temperature %.1f°C is %.1f°C below optimal minimum (%.1f°C)",
				input.CurrentTemperature, diff, requirements.OptimalTempMin))
			if diff > 10 {
				severityLevel = max(severityLevel, 2)
			} else {
				severityLevel = max(severityLevel, 1)
			}
		}
		if input.CurrentTemperature > requirements.OptimalTempMax {
			diff := input.CurrentTemperature - requirements.OptimalTempMax
			issues = append(issues, fmt.Sprintf("Temperature %.1f°C is %.1f°C above optimal maximum (%.1f°C)",
				input.CurrentTemperature, diff, requirements.OptimalTempMax))
			if diff > 10 {
				severityLevel = max(severityLevel, 2)
			} else {
				severityLevel = max(severityLevel, 1)
			}
		}
	}

	// Humidity analysis
	if input.CurrentHumidity > 0 {
		if input.CurrentHumidity < requirements.OptimalHumidityMin {
			issues = append(issues, fmt.Sprintf("Humidity %.1f%% is below optimal minimum (%.1f%%)",
				input.CurrentHumidity, requirements.OptimalHumidityMin))
			severityLevel = max(severityLevel, 1)
		}
		if input.CurrentHumidity > requirements.OptimalHumidityMax {
			issues = append(issues, fmt.Sprintf("Humidity %.1f%% is above optimal maximum (%.1f%%)",
				input.CurrentHumidity, requirements.OptimalHumidityMax))
			severityLevel = max(severityLevel, 1)
		}
	}

	// Soil pH analysis
	if input.CurrentSoilPH > 0 {
		if input.CurrentSoilPH < requirements.OptimalSoilPhMin {
			issues = append(issues, fmt.Sprintf("Soil pH %.2f is below optimal minimum (%.2f). Consider applying lime.",
				input.CurrentSoilPH, requirements.OptimalSoilPhMin))
			severityLevel = max(severityLevel, 1)
		}
		if input.CurrentSoilPH > requirements.OptimalSoilPhMax {
			issues = append(issues, fmt.Sprintf("Soil pH %.2f is above optimal maximum (%.2f). Consider applying sulfur.",
				input.CurrentSoilPH, requirements.OptimalSoilPhMax))
			severityLevel = max(severityLevel, 1)
		}
	}

	// Soil moisture / water analysis
	if input.CurrentSoilMoisture > 0 && requirements.WaterRequirementMMPerDay > 0 {
		if input.CurrentSoilMoisture < requirements.WaterRequirementMMPerDay*0.5 {
			issues = append(issues, fmt.Sprintf("Soil moisture is critically low. Current: %.1fmm, daily requirement: %.1fmm. Immediate irrigation recommended.",
				input.CurrentSoilMoisture, requirements.WaterRequirementMMPerDay))
			severityLevel = max(severityLevel, 2)
		} else if input.CurrentSoilMoisture < requirements.WaterRequirementMMPerDay*0.8 {
			issues = append(issues, fmt.Sprintf("Soil moisture is below adequate levels. Current: %.1fmm, daily requirement: %.1fmm.",
				input.CurrentSoilMoisture, requirements.WaterRequirementMMPerDay))
			severityLevel = max(severityLevel, 1)
		}
	}

	// Build recommendation from issues
	if len(issues) == 0 {
		confidence = 0.95
		return fmt.Sprintf("Optimal Conditions for %s", crop.Name),
			fmt.Sprintf("All monitored conditions are within optimal ranges for %s (%s). Continue current management practices.",
				crop.Name, crop.ScientificName),
			"info",
			confidence
	}

	// Calculate confidence based on number of data points provided
	dataPoints := 0
	if input.CurrentTemperature > 0 {
		dataPoints++
	}
	if input.CurrentHumidity > 0 {
		dataPoints++
	}
	if input.CurrentSoilPH > 0 {
		dataPoints++
	}
	if input.CurrentSoilMoisture > 0 {
		dataPoints++
	}
	confidence = math.Min(0.5+float64(dataPoints)*0.1, 0.9)

	switch severityLevel {
	case 2:
		severity = "critical"
	case 1:
		severity = "warning"
	default:
		severity = "info"
	}

	title = fmt.Sprintf("%s Alert for %s", strings.Title(severity), crop.Name)
	description = fmt.Sprintf("Analysis for %s (%s):\n%s",
		crop.Name, crop.ScientificName, strings.Join(issues, "\n"))

	return title, description, severity, confidence
}

// generateGenericRecommendation produces a recommendation when no specific requirements exist.
func (s *cropService) generateGenericRecommendation(
	crop *cropmodels.Crop,
	input *cropmodels.RecommendationInput,
) (title, description, severity string, confidence float64) {
	title = fmt.Sprintf("General %s Recommendation for %s",
		strings.Title(input.RecommendationType), crop.Name)

	var suggestions []string

	switch strings.ToLower(input.RecommendationType) {
	case "irrigation":
		suggestions = append(suggestions,
			"Monitor soil moisture levels daily during the current growth stage.",
			"Ensure consistent irrigation scheduling based on weather forecasts.",
			"Consider drip irrigation to improve water use efficiency.",
		)
	case "fertilization":
		suggestions = append(suggestions,
			"Conduct a soil test to determine nutrient deficiencies.",
			"Apply balanced NPK fertilizer according to the crop's growth stage.",
			"Consider foliar feeding for quick nutrient uptake.",
		)
	case "pest_management":
		suggestions = append(suggestions,
			"Perform regular field scouting for pest and disease signs.",
			"Implement integrated pest management (IPM) practices.",
			"Maintain proper plant spacing to improve air circulation.",
		)
	default:
		suggestions = append(suggestions,
			fmt.Sprintf("Ensure optimal growing conditions for %s in the %s stage.",
				crop.Name, input.CurrentGrowthStage),
			"Monitor environmental conditions regularly.",
			"Keep detailed records of observations and interventions.",
		)
	}

	description = strings.Join(suggestions, " ")
	severity = "info"
	confidence = 0.60 // lower confidence without specific requirements data
	return
}

// ---------- Event Publishing ----------

func (s *cropService) publishEvent(ctx context.Context, eventType domain.EventType, aggregateID string, data map[string]interface{}) {
	event := domain.NewDomainEvent(eventType, aggregateID, "crop", data).
		WithSource("crop-service").
		WithCorrelationID(p9context.RequestID(ctx))

	tenantID := p9context.TenantID(ctx)
	if tenantID != "" {
		event.WithMetadata("tenant_id", tenantID)
	}

	if s.deps.KafkaProducer != nil {
		// Fire-and-forget pattern with error logging
		go func() {
			publisher := domain.NewDomainEventPublisher(nil, s.deps.KafkaProducer, s.deps.Log)
			if err := publisher.PublishEvent(context.Background(), event); err != nil {
				s.logger.Errorf("Failed to publish event %s: %v", event.ID, err)
			}
		}()
	}
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
