// Package application contains the crop-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/crop-service/internal/domain"
	"p9e.in/samavaya/agriculture/crop-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/crop-service/internal/ports/outbound"
)

const (
	serviceName           = "crop-service"
	eventTopic            = "samavaya.agriculture.crop.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type cropService struct {
	repo outbound.CropRepository
	pub  outbound.EventPublisher
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewCropService creates a new application-layer CropService.
func NewCropService(
	repo outbound.CropRepository,
	pub outbound.EventPublisher,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.CropService {
	return &cropService{
		repo: repo,
		pub:  pub,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "CropService")),
	}
}

func (s *cropService) CreateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.Name == "" {
		return nil, errors.BadRequest("INVALID_NAME", "name is required")
	}
	if userID == "" {
		userID = "system"
	}

	nameExists, err := s.repo.CheckCropNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("CROP_NAME_EXISTS", fmt.Sprintf("crop with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.CropStatusActive

	created, err := s.repo.CreateCrop(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.crop.created", created.UUID, map[string]interface{}{
		"crop_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "crop created", "uuid", created.UUID)
	return created, nil
}

func (s *cropService) GetCrop(ctx context.Context, uuid string) (*domain.Crop, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "crop ID is required")
	}
	return s.repo.GetCropByUUID(ctx, uuid, tenantID)
}

func (s *cropService) ListCrops(ctx context.Context, params domain.ListCropParams) ([]domain.Crop, int32, error) {
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
	return s.repo.ListCrops(ctx, params)
}

func (s *cropService) UpdateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "crop ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckCropExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateCrop(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.crop.updated", updated.UUID, map[string]interface{}{
		"crop_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *cropService) DeleteCrop(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "crop ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckCropExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", uuid))
	}

	if err := s.repo.DeleteCrop(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.crop.deleted", uuid, map[string]interface{}{
		"crop_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *cropService) AddVariety(ctx context.Context, variety *domain.CropVariety) (*domain.CropVariety, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if strings.TrimSpace(variety.Name) == "" {
		return nil, errors.BadRequest("INVALID_VARIETY_NAME", "variety name is required")
	}
	if variety.CropID <= 0 {
		return nil, errors.BadRequest("INVALID_CROP_ID", "a valid crop_id is required to add a variety")
	}
	if userID == "" {
		userID = "system"
	}
	if tenantID != "" {
		variety.TenantID = tenantID
	}

	if variety.UUID == "" {
		variety.UUID = ulid.NewString()
	}
	variety.IsActive = true
	variety.CreatedBy = userID

	created, err := s.repo.CreateVariety(ctx, variety)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.crop.variety_added", created.UUID, map[string]interface{}{
		"variety_id": created.UUID,
		"crop_id":    created.CropID,
		"tenant_id":  created.TenantID,
	})
	return created, nil
}

func (s *cropService) ListVarieties(ctx context.Context, cropUUID, tenantID string, limit, offset int32) ([]*domain.CropVariety, int32, error) {
	if tenantID == "" {
		tenantID = p9context.TenantID(ctx)
	}
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
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

func (s *cropService) GetGrowthStages(ctx context.Context, cropUUID, tenantID string) ([]*domain.CropGrowthStage, error) {
	if tenantID == "" {
		tenantID = p9context.TenantID(ctx)
	}
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	crop, err := s.repo.GetCropByUUID(ctx, cropUUID, tenantID)
	if err != nil {
		return nil, err
	}
	return s.repo.GetGrowthStagesByCropID(ctx, crop.ID, tenantID)
}

func (s *cropService) GetCropRequirements(ctx context.Context, cropUUID, tenantID string) (*domain.CropRequirements, error) {
	if tenantID == "" {
		tenantID = p9context.TenantID(ctx)
	}
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	crop, err := s.repo.GetCropByUUID(ctx, cropUUID, tenantID)
	if err != nil {
		return nil, err
	}
	return s.repo.GetCropRequirementsByCropID(ctx, crop.ID, tenantID)
}

func (s *cropService) GenerateRecommendation(ctx context.Context, input *domain.RecommendationInput) (*domain.CropRecommendation, error) {
	if strings.TrimSpace(input.CropID) == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}
	if strings.TrimSpace(input.TenantID) == "" {
		if tenantID := p9context.TenantID(ctx); tenantID != "" {
			input.TenantID = tenantID
		} else {
			return nil, errors.BadRequest("INVALID_TENANT_ID", "tenant_id is required")
		}
	}
	if strings.TrimSpace(input.RecommendationType) == "" {
		return nil, errors.BadRequest("INVALID_RECOMMENDATION_TYPE", "recommendation_type is required")
	}

	crop, err := s.repo.GetCropByUUID(ctx, input.CropID, input.TenantID)
	if err != nil {
		return nil, err
	}

	requirements, _ := s.repo.GetCropRequirementsByCropID(ctx, crop.ID, input.TenantID)

	rec := s.buildRecommendation(crop, requirements, input)
	rec.UUID = ulid.NewString()
	rec.CreatedBy = p9context.UserID(ctx)
	rec.IsActive = true

	created, err := s.repo.CreateRecommendation(ctx, rec)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.crop.recommendation_generated", created.UUID, map[string]interface{}{
		"recommendation_id": created.UUID,
		"crop_id":           input.CropID,
		"tenant_id":         input.TenantID,
		"type":              input.RecommendationType,
		"confidence":        created.ConfidenceScore,
	})
	return created, nil
}

func (s *cropService) buildRecommendation(
	crop *domain.Crop,
	requirements *domain.CropRequirements,
	input *domain.RecommendationInput,
) *domain.CropRecommendation {
	now := time.Now()
	validUntil := now.Add(7 * 24 * time.Hour)

	title, description, severity, confidence := s.analyzeConditions(crop, requirements, input)

	params, _ := json.Marshal(map[string]interface{}{
		"current_temperature":   input.CurrentTemperature,
		"current_humidity":      input.CurrentHumidity,
		"current_soil_ph":       input.CurrentSoilPH,
		"current_soil_moisture": input.CurrentSoilMoisture,
		"growth_stage":          input.CurrentGrowthStage,
	})

	return &domain.CropRecommendation{
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

func (s *cropService) analyzeConditions(
	crop *domain.Crop,
	requirements *domain.CropRequirements,
	input *domain.RecommendationInput,
) (title, description, severity string, confidence float64) {
	if requirements == nil {
		return s.generateGenericRecommendation(crop, input)
	}

	var issues []string
	severityLevel := 0

	if input.CurrentTemperature > 0 {
		if input.CurrentTemperature < requirements.OptimalTempMin {
			diff := requirements.OptimalTempMin - input.CurrentTemperature
			issues = append(issues, fmt.Sprintf("Temperature %.1f°C is %.1f°C below optimal minimum (%.1f°C)",
				input.CurrentTemperature, diff, requirements.OptimalTempMin))
			if diff > 10 {
				severityLevel = maxInt(severityLevel, 2)
			} else {
				severityLevel = maxInt(severityLevel, 1)
			}
		}
		if input.CurrentTemperature > requirements.OptimalTempMax {
			diff := input.CurrentTemperature - requirements.OptimalTempMax
			issues = append(issues, fmt.Sprintf("Temperature %.1f°C is %.1f°C above optimal maximum (%.1f°C)",
				input.CurrentTemperature, diff, requirements.OptimalTempMax))
			if diff > 10 {
				severityLevel = maxInt(severityLevel, 2)
			} else {
				severityLevel = maxInt(severityLevel, 1)
			}
		}
	}

	if input.CurrentHumidity > 0 {
		if input.CurrentHumidity < requirements.OptimalHumidityMin {
			issues = append(issues, fmt.Sprintf("Humidity %.1f%% is below optimal minimum (%.1f%%)",
				input.CurrentHumidity, requirements.OptimalHumidityMin))
			severityLevel = maxInt(severityLevel, 1)
		}
		if input.CurrentHumidity > requirements.OptimalHumidityMax {
			issues = append(issues, fmt.Sprintf("Humidity %.1f%% is above optimal maximum (%.1f%%)",
				input.CurrentHumidity, requirements.OptimalHumidityMax))
			severityLevel = maxInt(severityLevel, 1)
		}
	}

	if input.CurrentSoilPH > 0 {
		if input.CurrentSoilPH < requirements.OptimalSoilPhMin {
			issues = append(issues, fmt.Sprintf("Soil pH %.2f is below optimal minimum (%.2f). Consider applying lime.",
				input.CurrentSoilPH, requirements.OptimalSoilPhMin))
			severityLevel = maxInt(severityLevel, 1)
		}
		if input.CurrentSoilPH > requirements.OptimalSoilPhMax {
			issues = append(issues, fmt.Sprintf("Soil pH %.2f is above optimal maximum (%.2f). Consider applying sulfur.",
				input.CurrentSoilPH, requirements.OptimalSoilPhMax))
			severityLevel = maxInt(severityLevel, 1)
		}
	}

	if input.CurrentSoilMoisture > 0 && requirements.WaterRequirementMMPerDay > 0 {
		if input.CurrentSoilMoisture < requirements.WaterRequirementMMPerDay*0.5 {
			issues = append(issues, fmt.Sprintf("Soil moisture is critically low. Current: %.1fmm, daily requirement: %.1fmm. Immediate irrigation recommended.",
				input.CurrentSoilMoisture, requirements.WaterRequirementMMPerDay))
			severityLevel = maxInt(severityLevel, 2)
		} else if input.CurrentSoilMoisture < requirements.WaterRequirementMMPerDay*0.8 {
			issues = append(issues, fmt.Sprintf("Soil moisture is below adequate levels. Current: %.1fmm, daily requirement: %.1fmm.",
				input.CurrentSoilMoisture, requirements.WaterRequirementMMPerDay))
			severityLevel = maxInt(severityLevel, 1)
		}
	}

	if len(issues) == 0 {
		return fmt.Sprintf("Optimal Conditions for %s", crop.Name),
			fmt.Sprintf("All monitored conditions are within optimal ranges for %s (%s). Continue current management practices.",
				crop.Name, crop.ScientificName),
			"info",
			0.95
	}

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

	title = fmt.Sprintf("%s Alert for %s", strings.ToUpper(string(severity[0]))+severity[1:], crop.Name)
	description = fmt.Sprintf("Analysis for %s (%s):\n%s",
		crop.Name, crop.ScientificName, strings.Join(issues, "\n"))

	return title, description, severity, confidence
}

func (s *cropService) generateGenericRecommendation(
	crop *domain.Crop,
	input *domain.RecommendationInput,
) (title, description, severity string, confidence float64) {
	recType := strings.ToLower(input.RecommendationType)
	recTypeTitle := strings.ToUpper(string(recType[0])) + recType[1:]
	title = fmt.Sprintf("General %s Recommendation for %s", recTypeTitle, crop.Name)

	var suggestions []string
	switch recType {
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
			fmt.Sprintf("Ensure optimal growing conditions for %s in the %s stage.", crop.Name, input.CurrentGrowthStage),
			"Monitor environmental conditions regularly.",
			"Keep detailed records of observations and interventions.",
		)
	}

	return title, strings.Join(suggestions, " "), "info", 0.60
}

func (s *cropService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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

func maxInt(a, b int) int {
	if a > b {
		return a
	}
	return b
}
