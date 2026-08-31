// Package application contains the soil-service application service.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/soil-service/internal/ports/outbound"
)

const (
	serviceName           = "soil-service"
	eventTopic            = "samavaya.agriculture.soil.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type soilService struct {
	repo outbound.SoilRepository
	pub  outbound.EventPublisher
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewSoilService creates a new application-layer SoilService.
// The fieldClient parameter is accepted for backward compatibility with main.go wiring.
func NewSoilService(
	repo outbound.SoilRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.SoilService {
	_ = fieldClient // not used in this implementation
	return &soilService{
		repo: repo,
		pub:  pub,
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SoilService")),
	}
}

func (s *soilService) CreateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error) {
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

	nameExists, err := s.repo.CheckSoilNameExists(ctx, entity.Name, tenantID)
	if err != nil {
		return nil, err
	}
	if nameExists {
		return nil, errors.Conflict("SOIL_NAME_EXISTS", fmt.Sprintf("soil with name '%s' already exists", entity.Name))
	}

	entity.TenantID = tenantID
	entity.CreatedBy = userID
	entity.Status = domain.SoilStatusActive

	created, err := s.repo.CreateSoil(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.soil.created", created.UUID, map[string]interface{}{
		"soil_id": created.UUID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "soil created", "uuid", created.UUID)
	return created, nil
}

func (s *soilService) GetSoil(ctx context.Context, uuid string) (*domain.Soil, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return nil, errors.BadRequest("MISSING_ID", "soil ID is required")
	}
	return s.repo.GetSoilByUUID(ctx, uuid, tenantID)
}

func (s *soilService) ListSoils(ctx context.Context, params domain.ListSoilParams) ([]domain.Soil, int32, error) {
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
	return s.repo.ListSoils(ctx, params)
}

func (s *soilService) UpdateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if entity.UUID == "" {
		return nil, errors.BadRequest("MISSING_ID", "soil ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSoilExists(ctx, entity.UUID, tenantID)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NotFound("SOIL_NOT_FOUND", fmt.Sprintf("soil not found: %s", entity.UUID))
	}

	entity.TenantID = tenantID
	updatedBy := userID
	entity.UpdatedBy = &updatedBy

	updated, err := s.repo.UpdateSoil(ctx, entity)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.soil.updated", updated.UUID, map[string]interface{}{
		"soil_id": updated.UUID, "tenant_id": tenantID,
	})
	return updated, nil
}

func (s *soilService) DeleteSoil(ctx context.Context, uuid string) error {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if uuid == "" {
		return errors.BadRequest("MISSING_ID", "soil ID is required")
	}
	if userID == "" {
		userID = "system"
	}

	exists, err := s.repo.CheckSoilExists(ctx, uuid, tenantID)
	if err != nil {
		return err
	}
	if !exists {
		return errors.NotFound("SOIL_NOT_FOUND", fmt.Sprintf("soil not found: %s", uuid))
	}

	if err := s.repo.DeleteSoil(ctx, uuid, tenantID, userID); err != nil {
		return err
	}

	s.emitEvent(ctx, "agriculture.soil.deleted", uuid, map[string]interface{}{
		"soil_id": uuid, "tenant_id": tenantID,
	})
	return nil
}

func (s *soilService) CreateSoilSample(ctx context.Context, sample *domain.SoilSample) (*domain.SoilSample, error) {
	userID := p9context.UserID(ctx)
	tenantID := p9context.TenantID(ctx)
	if tenantID != "" {
		sample.TenantID = tenantID
	}
	if userID != "" {
		sample.CreatedBy = userID
		sample.CollectedBy = userID
	}

	if err := validateSoilSample(sample); err != nil {
		return nil, err
	}

	if sample.UUID == "" {
		sample.UUID = ulid.NewString()
	}
	sample.Version = 1
	sample.IsActive = true

	created, err := s.repo.CreateSoilSample(ctx, sample)
	if err != nil {
		s.log.Errorw("msg", "failed to create soil sample", "error", err)
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.soil.sample.collected", created.UUID, map[string]interface{}{
		"sample_id": created.UUID,
		"field_id":  created.FieldID,
		"farm_id":   created.FarmID,
		"tenant_id": created.TenantID,
		"ph":        created.PH,
		"latitude":  created.Latitude,
		"longitude": created.Longitude,
	})

	s.log.Infow("msg", "created soil sample", "uuid", created.UUID, "field_id", created.FieldID)
	return created, nil
}

func (s *soilService) GetSoilSample(ctx context.Context, id, tenantID string) (*domain.SoilSample, error) {
	if id == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample id is required")
	}
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	return s.repo.GetSoilSampleByUUID(ctx, id, tenantID)
}

func (s *soilService) ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]domain.SoilSample, int64, error) {
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, 0, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}
	if pageOffset < 0 {
		pageOffset = 0
	}
	return s.repo.ListSoilSamples(ctx, tenantID, fieldID, farmID, pageSize, pageOffset)
}

func (s *soilService) AnalyzeSoil(ctx context.Context, sampleID, tenantID, analysisType string) (*domain.SoilAnalysis, error) {
	if sampleID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample id is required")
	}
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	if analysisType == "" {
		analysisType = "STANDARD"
	}

	userID := p9context.UserID(ctx)

	sample, err := s.repo.GetSoilSampleByUUID(ctx, sampleID, tenantID)
	if err != nil {
		return nil, err
	}

	healthScore := computeSoilHealthScore(sample)
	category := classifyHealthCategory(healthScore)
	recommendations := generateRecommendations(sample, healthScore)

	now := time.Now()
	analysis := &domain.SoilAnalysis{
		TenantID:        tenantID,
		SampleID:        sampleID,
		FieldID:         sample.FieldID,
		FarmID:          sample.FarmID,
		Status:          domain.AnalysisStatusCompleted,
		AnalysisType:    analysisType,
		SoilHealthScore: healthScore,
		HealthCategory:  category,
		Recommendations: recommendations,
		AnalyzedBy:      userID,
		AnalyzedAt:      &now,
		Summary:         generateAnalysisSummary(sample, healthScore, category),
		Version:         1,
	}
	analysis.UUID = ulid.NewString()
	analysis.CreatedBy = userID
	analysis.IsActive = true

	created, err := s.repo.CreateSoilAnalysis(ctx, analysis)
	if err != nil {
		s.log.Errorw("msg", "failed to create soil analysis", "error", err)
		return nil, err
	}

	nutrients := extractNutrients(sample, tenantID, sampleID, userID)
	if len(nutrients) > 0 {
		if _, err := s.repo.BatchCreateNutrients(ctx, nutrients); err != nil {
			s.log.Warnw("msg", "failed to store nutrient records", "sample_id", sampleID, "error", err)
		}
	}

	existingHealth, err := s.repo.GetLatestSoilHealthScore(ctx, sample.FieldID, tenantID)
	if err != nil && !errors.IsNotFound(err) {
		s.log.Warnw("msg", "failed to fetch existing health score", "error", err)
	}

	physicalScore := computePhysicalScore(sample)
	chemicalScore := computeChemicalScore(sample)
	biologicalScore := computeBiologicalScore(sample)

	if existingHealth != nil {
		existingHealth.OverallScore = healthScore
		existingHealth.Category = category
		existingHealth.PhysicalScore = physicalScore
		existingHealth.ChemicalScore = chemicalScore
		existingHealth.BiologicalScore = biologicalScore
		existingHealth.Recommendations = recommendations
		existingHealth.AssessedAt = &now
		if _, updateErr := s.repo.UpdateSoilHealthScore(ctx, existingHealth); updateErr != nil {
			s.log.Warnw("msg", "failed to update health score", "field_id", sample.FieldID, "error", updateErr)
		}
	} else {
		healthRecord := &domain.SoilHealthScore{
			TenantID:        tenantID,
			FieldID:         sample.FieldID,
			FarmID:          sample.FarmID,
			OverallScore:    healthScore,
			Category:        category,
			PhysicalScore:   physicalScore,
			ChemicalScore:   chemicalScore,
			BiologicalScore: biologicalScore,
			Recommendations: recommendations,
			AssessedAt:      &now,
			Version:         1,
		}
		healthRecord.UUID = ulid.NewString()
		healthRecord.CreatedBy = userID
		healthRecord.IsActive = true
		if _, createErr := s.repo.CreateSoilHealthScore(ctx, healthRecord); createErr != nil {
			s.log.Warnw("msg", "failed to create health score", "field_id", sample.FieldID, "error", createErr)
		}
	}

	s.emitEvent(ctx, "agriculture.soil.analysis.completed", created.UUID, map[string]interface{}{
		"analysis_id":       created.UUID,
		"sample_id":         sampleID,
		"field_id":          sample.FieldID,
		"farm_id":           sample.FarmID,
		"soil_health_score": healthScore,
		"health_category":   string(category),
		"tenant_id":         tenantID,
	})

	deficiencies := detectNutrientDeficiencies(sample)
	if len(deficiencies) > 0 {
		s.emitEvent(ctx, "agriculture.soil.nutrient.deficiency.detected", sampleID, map[string]interface{}{
			"sample_id":    sampleID,
			"field_id":     sample.FieldID,
			"farm_id":      sample.FarmID,
			"tenant_id":    tenantID,
			"deficiencies": deficiencyNames(deficiencies),
		})
	}

	s.log.Infow("msg", "completed soil analysis", "uuid", created.UUID, "sample_id", sampleID,
		"score", healthScore, "category", category)
	return created, nil
}

func (s *soilService) ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]domain.SoilAnalysis, int64, error) {
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, 0, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	if pageSize <= 0 {
		pageSize = 20
	}
	if pageSize > 100 {
		pageSize = 100
	}
	if pageOffset < 0 {
		pageOffset = 0
	}
	return s.repo.ListSoilAnalyses(ctx, tenantID, fieldID, farmID, sampleID, pageSize, pageOffset)
}

func (s *soilService) GetSoilMap(ctx context.Context, fieldID, tenantID, mapType string) (*domain.SoilMap, error) {
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field id is required")
	}
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	if mapType == "" {
		mapType = "nutrient"
	}
	return s.repo.GetSoilMapByFieldAndType(ctx, fieldID, tenantID, mapType)
}

func (s *soilService) GetSoilHealth(ctx context.Context, fieldID, tenantID string) (*domain.SoilHealthScore, error) {
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field id is required")
	}
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	return s.repo.GetLatestSoilHealthScore(ctx, fieldID, tenantID)
}

func (s *soilService) GetNutrientLevels(ctx context.Context, sampleID, tenantID string) ([]domain.SoilNutrient, error) {
	if sampleID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample id is required")
	}
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	return s.repo.ListNutrientsBySample(ctx, sampleID, tenantID)
}

func (s *soilService) GenerateSoilReport(ctx context.Context, fieldID, tenantID, farmID string) (*domain.SoilReport, error) {
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field id is required")
	}
	if ctxTenant := p9context.TenantID(ctx); ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}

	samples, _, err := s.repo.ListSoilSamples(ctx, tenantID, fieldID, farmID, 1, 0)
	if err != nil {
		return nil, err
	}
	if len(samples) == 0 {
		return nil, errors.NotFound("NO_SAMPLES_FOUND", fmt.Sprintf("no soil samples found for field %s", fieldID))
	}
	latestSample := &samples[0]

	analyses, _, err := s.repo.ListSoilAnalyses(ctx, tenantID, fieldID, farmID, "", 1, 0)
	if err != nil {
		s.log.Warnw("msg", "failed to fetch analyses for report", "error", err)
	}
	var latestAnalysis *domain.SoilAnalysis
	if len(analyses) > 0 {
		latestAnalysis = &analyses[0]
	}

	healthScore, err := s.repo.GetLatestSoilHealthScore(ctx, fieldID, tenantID)
	if err != nil && !errors.IsNotFound(err) {
		s.log.Warnw("msg", "failed to fetch health score for report", "error", err)
	}

	nutrients, err := s.repo.ListNutrientsBySample(ctx, latestSample.UUID, tenantID)
	if err != nil {
		s.log.Warnw("msg", "failed to fetch nutrients for report", "error", err)
		nutrients = make([]domain.SoilNutrient, 0)
	}

	recommendations := aggregateRecommendations(latestSample, latestAnalysis, healthScore)

	report := &domain.SoilReport{
		Sample:          latestSample,
		Analysis:        latestAnalysis,
		HealthScore:     healthScore,
		Nutrients:       nutrients,
		Recommendations: recommendations,
		GeneratedAt:     time.Now(),
	}

	s.log.Infow("msg", "generated soil report", "field_id", fieldID)
	return report, nil
}

func (s *soilService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

func validateSoilSample(sample *domain.SoilSample) error {
	if sample.TenantID == "" {
		return errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	if sample.FieldID == "" {
		return errors.BadRequest("INVALID_ARGUMENT", "field id is required")
	}
	if sample.FarmID == "" {
		return errors.BadRequest("INVALID_ARGUMENT", "farm id is required")
	}
	if sample.PH < 0 || sample.PH > 14 {
		return errors.BadRequest("INVALID_ARGUMENT", "pH must be between 0 and 14")
	}
	if sample.MoisturePct < 0 || sample.MoisturePct > 100 {
		return errors.BadRequest("INVALID_ARGUMENT", "moisture percentage must be between 0 and 100")
	}
	if sample.OrganicMatterPct < 0 || sample.OrganicMatterPct > 100 {
		return errors.BadRequest("INVALID_ARGUMENT", "organic matter percentage must be between 0 and 100")
	}
	if sample.SampleDepthCm < 0 {
		return errors.BadRequest("INVALID_ARGUMENT", "sample depth must be non-negative")
	}
	if sample.BulkDensity < 0 {
		return errors.BadRequest("INVALID_ARGUMENT", "bulk density must be non-negative")
	}
	if sample.Latitude < -90 || sample.Latitude > 90 {
		return errors.BadRequest("INVALID_ARGUMENT", "latitude must be between -90 and 90")
	}
	if sample.Longitude < -180 || sample.Longitude > 180 {
		return errors.BadRequest("INVALID_ARGUMENT", "longitude must be between -180 and 180")
	}
	return nil
}

// ---------------------------------------------------------------------------
// Soil Health Computation
// ---------------------------------------------------------------------------

func computeSoilHealthScore(sample *domain.SoilSample) float64 {
	phScore := computePHScore(sample.PH)
	omScore := computeOrganicMatterScore(sample.OrganicMatterPct)
	cecScore := computeCECScore(sample.CationExchangeCapacity)
	macroScore := computeMacronutrientScore(sample)
	microScore := computeMicronutrientScore(sample)

	overall := phScore*0.25 + omScore*0.20 + cecScore*0.15 + macroScore*0.25 + microScore*0.15

	return math.Round(overall*10) / 10
}

func computePHScore(ph float64) float64 {
	if ph >= 6.0 && ph <= 7.0 {
		return 100.0
	}
	if ph >= 5.5 && ph < 6.0 {
		return 80.0 + (ph-5.5)*40.0
	}
	if ph > 7.0 && ph <= 7.5 {
		return 100.0 - (ph-7.0)*40.0
	}
	if ph >= 5.0 && ph < 5.5 {
		return 60.0 + (ph-5.0)*40.0
	}
	if ph > 7.5 && ph <= 8.0 {
		return 80.0 - (ph-7.5)*40.0
	}
	if ph < 5.0 {
		return math.Max(0, 60.0-(5.0-ph)*30.0)
	}
	return math.Max(0, 60.0-(ph-8.0)*30.0)
}

func computeOrganicMatterScore(omPct float64) float64 {
	if omPct >= 5.0 {
		return 100.0
	}
	if omPct >= 3.0 {
		return 70.0 + (omPct-3.0)*15.0
	}
	if omPct >= 1.0 {
		return 30.0 + (omPct-1.0)*20.0
	}
	return omPct * 30.0
}

func computeCECScore(cec float64) float64 {
	if cec >= 15.0 && cec <= 25.0 {
		return 100.0
	}
	if cec >= 10.0 && cec < 15.0 {
		return 70.0 + (cec-10.0)*6.0
	}
	if cec > 25.0 && cec <= 30.0 {
		return 100.0 - (cec-25.0)*4.0
	}
	if cec >= 5.0 && cec < 10.0 {
		return 40.0 + (cec-5.0)*6.0
	}
	if cec < 5.0 {
		return math.Max(0, cec*8.0)
	}
	return math.Max(0, 80.0-(cec-30.0)*4.0)
}

func computeMacronutrientScore(sample *domain.SoilSample) float64 {
	nScore := nutrientRangeScore(sample.NitrogenPPM, 20, 40, 0, 80)
	pScore := nutrientRangeScore(sample.PhosphorusPPM, 25, 50, 0, 100)
	kScore := nutrientRangeScore(sample.PotassiumPPM, 150, 250, 0, 500)
	caScore := nutrientRangeScore(sample.CalciumPPM, 1000, 3000, 0, 5000)
	mgScore := nutrientRangeScore(sample.MagnesiumPPM, 100, 300, 0, 600)
	sScore := nutrientRangeScore(sample.SulfurPPM, 10, 30, 0, 60)

	return nScore*0.25 + pScore*0.20 + kScore*0.20 + caScore*0.15 + mgScore*0.10 + sScore*0.10
}

func computeMicronutrientScore(sample *domain.SoilSample) float64 {
	feScore := nutrientRangeScore(sample.IronPPM, 4.5, 20, 0, 50)
	mnScore := nutrientRangeScore(sample.ManganesePPM, 1, 5, 0, 15)
	znScore := nutrientRangeScore(sample.ZincPPM, 1, 3, 0, 10)
	cuScore := nutrientRangeScore(sample.CopperPPM, 0.2, 1, 0, 3)
	bScore := nutrientRangeScore(sample.BoronPPM, 0.5, 2, 0, 5)

	return (feScore + mnScore + znScore + cuScore + bScore) / 5.0
}

func nutrientRangeScore(value, optMin, optMax, absMin, absMax float64) float64 {
	if value >= optMin && value <= optMax {
		return 100.0
	}
	if value < optMin {
		if value <= absMin {
			return 0.0
		}
		return ((value - absMin) / (optMin - absMin)) * 100.0
	}
	if value >= absMax {
		return 0.0
	}
	return ((absMax - value) / (absMax - optMax)) * 100.0
}

func classifyHealthCategory(score float64) domain.HealthCategory {
	switch {
	case score >= 85:
		return domain.HealthCategoryExcellent
	case score >= 70:
		return domain.HealthCategoryGood
	case score >= 50:
		return domain.HealthCategoryFair
	case score >= 30:
		return domain.HealthCategoryPoor
	default:
		return domain.HealthCategoryCritical
	}
}

func computePhysicalScore(sample *domain.SoilSample) float64 {
	bulkDensityScore := 100.0
	if sample.BulkDensity > 0 {
		bulkDensityScore = nutrientRangeScore(sample.BulkDensity, 1.1, 1.4, 0.5, 2.0)
	}
	moistureScore := nutrientRangeScore(sample.MoisturePct, 20, 60, 0, 100)
	textureScore := 70.0
	switch sample.Texture {
	case domain.SoilTextureLoamy:
		textureScore = 100.0
	case domain.SoilTextureSilt:
		textureScore = 85.0
	case domain.SoilTextureClay:
		textureScore = 65.0
	case domain.SoilTextureSandy:
		textureScore = 55.0
	case domain.SoilTexturePeat:
		textureScore = 75.0
	case domain.SoilTextureChalk:
		textureScore = 60.0
	}
	return bulkDensityScore*0.35 + moistureScore*0.35 + textureScore*0.30
}

func computeChemicalScore(sample *domain.SoilSample) float64 {
	phScore := computePHScore(sample.PH)
	cecScore := computeCECScore(sample.CationExchangeCapacity)
	ecScore := 100.0
	if sample.ElectricalConductivity > 4.0 {
		ecScore = math.Max(0, 100.0-(sample.ElectricalConductivity-4.0)*20.0)
	}
	macroScore := computeMacronutrientScore(sample)
	return phScore*0.30 + cecScore*0.25 + ecScore*0.15 + macroScore*0.30
}

func computeBiologicalScore(sample *domain.SoilSample) float64 {
	omScore := computeOrganicMatterScore(sample.OrganicMatterPct)
	nScore := nutrientRangeScore(sample.NitrogenPPM, 20, 40, 0, 80)
	return omScore*0.60 + nScore*0.40
}

// ---------------------------------------------------------------------------
// Recommendation Engine
// ---------------------------------------------------------------------------

func generateRecommendations(sample *domain.SoilSample, _ float64) []string {
	recs := make([]string, 0)

	if sample.PH < 5.5 {
		recs = append(recs, "Apply agricultural lime to raise soil pH to the optimal 6.0-7.0 range")
	} else if sample.PH > 7.5 {
		recs = append(recs, "Apply elemental sulfur or acidifying fertilizer to lower soil pH")
	}

	if sample.OrganicMatterPct < 3.0 {
		recs = append(recs, "Increase organic matter by incorporating compost, cover crops, or green manure")
	}

	if sample.NitrogenPPM < 20 {
		recs = append(recs, "Apply nitrogen fertilizer or plant nitrogen-fixing cover crops like legumes")
	}
	if sample.PhosphorusPPM < 25 {
		recs = append(recs, "Apply phosphorus fertilizer (e.g., superphosphate or bone meal)")
	}
	if sample.PotassiumPPM < 150 {
		recs = append(recs, "Apply potassium fertilizer (e.g., potash or potassium sulfate)")
	}

	if sample.CalciumPPM < 1000 {
		recs = append(recs, "Apply gypsum or agricultural lime to increase calcium levels")
	}
	if sample.MagnesiumPPM < 100 {
		recs = append(recs, "Apply dolomitic lime or Epsom salt to increase magnesium levels")
	}

	if sample.ZincPPM < 1.0 {
		recs = append(recs, "Apply zinc sulfate to correct zinc deficiency")
	}
	if sample.IronPPM < 4.5 {
		recs = append(recs, "Apply chelated iron to correct iron deficiency")
	}
	if sample.BoronPPM < 0.5 {
		recs = append(recs, "Apply borax at low rates to correct boron deficiency")
	}

	if sample.CationExchangeCapacity < 10 {
		recs = append(recs, "Improve CEC by adding organic matter and clay amendments")
	}

	if sample.ElectricalConductivity > 4.0 {
		recs = append(recs, "Soil salinity is high; consider leaching with fresh water and improving drainage")
	}

	if sample.MoisturePct < 20 {
		recs = append(recs, "Soil moisture is low; consider mulching and irrigation scheduling")
	}

	if sample.BulkDensity > 1.6 {
		recs = append(recs, "Soil compaction detected; consider deep tillage and cover crop root activity")
	}

	if len(recs) == 0 {
		recs = append(recs, "Soil conditions are within optimal ranges. Continue current management practices")
	}

	return recs
}

func generateAnalysisSummary(sample *domain.SoilSample, score float64, category domain.HealthCategory) string {
	return fmt.Sprintf(
		"Soil analysis complete. Overall health score: %.1f/100 (%s). "+
			"pH: %.1f, Organic matter: %.1f%%, N: %.0f ppm, P: %.0f ppm, K: %.0f ppm. "+
			"Texture: %s, Moisture: %.1f%%.",
		score, string(category),
		sample.PH, sample.OrganicMatterPct,
		sample.NitrogenPPM, sample.PhosphorusPPM, sample.PotassiumPPM,
		string(sample.Texture), sample.MoisturePct,
	)
}

func detectNutrientDeficiencies(sample *domain.SoilSample) []domain.NutrientDeficiency {
	defs := make([]domain.NutrientDeficiency, 0)

	checkDeficiency := func(name string, value, optMin float64, rec string) {
		if value < optMin {
			level := domain.NutrientLevelLow
			if value < optMin*0.5 {
				level = domain.NutrientLevelDeficient
			}
			defs = append(defs, domain.NutrientDeficiency{
				NutrientName:   name,
				CurrentValue:   value,
				OptimalValue:   optMin,
				Level:          level,
				Recommendation: rec,
			})
		}
	}

	checkDeficiency("Nitrogen", sample.NitrogenPPM, 20, "Apply nitrogen fertilizer or plant legumes")
	checkDeficiency("Phosphorus", sample.PhosphorusPPM, 25, "Apply phosphorus fertilizer")
	checkDeficiency("Potassium", sample.PotassiumPPM, 150, "Apply potassium fertilizer")
	checkDeficiency("Calcium", sample.CalciumPPM, 1000, "Apply lime or gypsum")
	checkDeficiency("Magnesium", sample.MagnesiumPPM, 100, "Apply dolomitic lime")
	checkDeficiency("Sulfur", sample.SulfurPPM, 10, "Apply sulfur-based fertilizer")
	checkDeficiency("Iron", sample.IronPPM, 4.5, "Apply chelated iron")
	checkDeficiency("Manganese", sample.ManganesePPM, 1, "Apply manganese sulfate")
	checkDeficiency("Zinc", sample.ZincPPM, 1, "Apply zinc sulfate")
	checkDeficiency("Copper", sample.CopperPPM, 0.2, "Apply copper sulfate")
	checkDeficiency("Boron", sample.BoronPPM, 0.5, "Apply borax at low rates")

	return defs
}

func deficiencyNames(defs []domain.NutrientDeficiency) []string {
	names := make([]string, 0, len(defs))
	for _, d := range defs {
		names = append(names, d.NutrientName)
	}
	return names
}

func extractNutrients(sample *domain.SoilSample, tenantID, sampleID, userID string) []domain.SoilNutrient {
	type nutrientSpec struct {
		name   string
		value  float64
		optMin float64
		optMax float64
		unit   string
	}
	specs := []nutrientSpec{
		{"Nitrogen", sample.NitrogenPPM, 20, 40, "ppm"},
		{"Phosphorus", sample.PhosphorusPPM, 25, 50, "ppm"},
		{"Potassium", sample.PotassiumPPM, 150, 250, "ppm"},
		{"Calcium", sample.CalciumPPM, 1000, 3000, "ppm"},
		{"Magnesium", sample.MagnesiumPPM, 100, 300, "ppm"},
		{"Sulfur", sample.SulfurPPM, 10, 30, "ppm"},
		{"Iron", sample.IronPPM, 4.5, 20, "ppm"},
		{"Manganese", sample.ManganesePPM, 1, 5, "ppm"},
		{"Zinc", sample.ZincPPM, 1, 3, "ppm"},
		{"Copper", sample.CopperPPM, 0.2, 1, "ppm"},
		{"Boron", sample.BoronPPM, 0.5, 2, "ppm"},
	}

	nutrients := make([]domain.SoilNutrient, 0, len(specs))
	for _, sp := range specs {
		level := classifyNutrientLevel(sp.value, sp.optMin, sp.optMax)
		n := domain.SoilNutrient{
			TenantID:     tenantID,
			SampleID:     sampleID,
			NutrientName: sp.name,
			ValuePPM:     sp.value,
			Level:        level,
			OptimalMin:   sp.optMin,
			OptimalMax:   sp.optMax,
			Unit:         sp.unit,
		}
		n.UUID = ulid.NewString()
		n.CreatedBy = userID
		n.IsActive = true
		nutrients = append(nutrients, n)
	}
	return nutrients
}

func classifyNutrientLevel(value, optMin, optMax float64) domain.NutrientLevel {
	if value < optMin*0.5 {
		return domain.NutrientLevelDeficient
	}
	if value < optMin {
		return domain.NutrientLevelLow
	}
	if value <= optMax {
		return domain.NutrientLevelAdequate
	}
	if value <= optMax*1.5 {
		return domain.NutrientLevelHigh
	}
	return domain.NutrientLevelExcessive
}

func aggregateRecommendations(sample *domain.SoilSample, analysis *domain.SoilAnalysis, health *domain.SoilHealthScore) []string {
	seen := make(map[string]bool)
	recs := make([]string, 0)

	add := func(items []string) {
		for _, item := range items {
			if !seen[item] {
				seen[item] = true
				recs = append(recs, item)
			}
		}
	}

	if analysis != nil {
		add(analysis.Recommendations)
	}
	if health != nil {
		add(health.Recommendations)
	}
	if sample != nil {
		add(generateRecommendations(sample, 0))
	}
	return recs
}
