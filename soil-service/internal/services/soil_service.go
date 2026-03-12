package services

import (
	"context"
	"fmt"
	"math"
	"time"

	"p9e.in/samavaya/agriculture/soil-service/internal/models"
	"p9e.in/samavaya/agriculture/soil-service/internal/repositories"
	"p9e.in/samavaya/packages/convert/ptr"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/events/domain"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// SoilService defines the business-logic contract for the soil domain.
type SoilService interface {
	// Samples
	CreateSoilSample(ctx context.Context, sample *models.SoilSample) (*models.SoilSample, error)
	GetSoilSample(ctx context.Context, id, tenantID string) (*models.SoilSample, error)
	ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]models.SoilSample, int64, error)

	// Analyses
	AnalyzeSoil(ctx context.Context, sampleID, tenantID, analysisType string) (*models.SoilAnalysis, error)
	ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]models.SoilAnalysis, int64, error)

	// Maps
	GetSoilMap(ctx context.Context, fieldID, tenantID, mapType string) (*models.SoilMap, error)

	// Health
	GetSoilHealth(ctx context.Context, fieldID, tenantID string) (*models.SoilHealthScore, error)

	// Nutrients
	GetNutrientLevels(ctx context.Context, sampleID, tenantID string) ([]models.SoilNutrient, error)

	// Reports
	GenerateSoilReport(ctx context.Context, fieldID, tenantID, farmID string) (*models.SoilReport, error)
}

// soilService is the production implementation.
type soilService struct {
	repo   repositories.SoilRepository
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewSoilService creates a new soil service with all its dependencies.
func NewSoilService(d deps.ServiceDeps, repo repositories.SoilRepository) SoilService {
	return &soilService{
		repo:   repo,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "SoilService")),
	}
}

// ---------------------------------------------------------------------------
// Samples
// ---------------------------------------------------------------------------

func (s *soilService) CreateSoilSample(ctx context.Context, sample *models.SoilSample) (*models.SoilSample, error) {
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
		s.logger.Errorf("failed to create soil sample: %v", err)
		return nil, err
	}

	// Publish domain event
	s.publishEvent(ctx, domain.EventType("agriculture.soil.sample.collected"), created.UUID, "soil_sample", map[string]interface{}{
		"sample_id": created.UUID,
		"field_id":  created.FieldID,
		"farm_id":   created.FarmID,
		"tenant_id": created.TenantID,
		"ph":        created.PH,
		"latitude":  created.Latitude,
		"longitude": created.Longitude,
	})

	s.logger.Infof("created soil sample %s for field %s", created.UUID, created.FieldID)
	return created, nil
}

func (s *soilService) GetSoilSample(ctx context.Context, id, tenantID string) (*models.SoilSample, error) {
	if id == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample id is required")
	}
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	return s.repo.GetSoilSampleByUUID(ctx, id, tenantID)
}

func (s *soilService) ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]models.SoilSample, int64, error) {
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
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

// ---------------------------------------------------------------------------
// Analyses
// ---------------------------------------------------------------------------

func (s *soilService) AnalyzeSoil(ctx context.Context, sampleID, tenantID, analysisType string) (*models.SoilAnalysis, error) {
	if sampleID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample id is required")
	}
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	if analysisType == "" {
		analysisType = "STANDARD"
	}

	userID := p9context.UserID(ctx)

	// Fetch sample to analyze
	sample, err := s.repo.GetSoilSampleByUUID(ctx, sampleID, tenantID)
	if err != nil {
		return nil, err
	}

	// Perform soil analysis computation
	healthScore := computeSoilHealthScore(sample)
	category := classifyHealthCategory(healthScore)
	recommendations := generateRecommendations(sample, healthScore)

	now := time.Now()
	analysis := &models.SoilAnalysis{
		TenantID:        tenantID,
		SampleID:        sampleID,
		FieldID:         sample.FieldID,
		FarmID:          sample.FarmID,
		Status:          models.AnalysisStatusCompleted,
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
		s.logger.Errorf("failed to create soil analysis: %v", err)
		return nil, err
	}

	// Extract and store individual nutrient records
	nutrients := extractNutrients(sample, tenantID, sampleID, userID)
	if len(nutrients) > 0 {
		if _, err := s.repo.BatchCreateNutrients(ctx, nutrients); err != nil {
			s.logger.Warnf("failed to store nutrient records for sample %s: %v", sampleID, err)
		}
	}

	// Update or create soil health score for the field
	existingHealth, err := s.repo.GetLatestSoilHealthScore(ctx, sample.FieldID, tenantID)
	if err != nil && !errors.IsNotFound(err) {
		s.logger.Warnf("failed to fetch existing health score: %v", err)
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
		_, updateErr := s.repo.UpdateSoilHealthScore(ctx, existingHealth)
		if updateErr != nil {
			s.logger.Warnf("failed to update health score for field %s: %v", sample.FieldID, updateErr)
		}
	} else {
		healthRecord := &models.SoilHealthScore{
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
		_, createErr := s.repo.CreateSoilHealthScore(ctx, healthRecord)
		if createErr != nil {
			s.logger.Warnf("failed to create health score for field %s: %v", sample.FieldID, createErr)
		}
	}

	// Publish event
	s.publishEvent(ctx, domain.EventType("agriculture.soil.analysis.completed"), created.UUID, "soil_analysis", map[string]interface{}{
		"analysis_id":      created.UUID,
		"sample_id":        sampleID,
		"field_id":         sample.FieldID,
		"farm_id":          sample.FarmID,
		"soil_health_score": healthScore,
		"health_category":  string(category),
		"tenant_id":        tenantID,
	})

	// Check for nutrient deficiencies and publish alert events
	deficiencies := detectNutrientDeficiencies(sample)
	if len(deficiencies) > 0 {
		s.publishEvent(ctx, domain.EventType("agriculture.soil.nutrient.deficiency.detected"), sampleID, "soil_sample", map[string]interface{}{
			"sample_id":    sampleID,
			"field_id":     sample.FieldID,
			"farm_id":      sample.FarmID,
			"tenant_id":    tenantID,
			"deficiencies": deficiencyNames(deficiencies),
		})
	}

	s.logger.Infof("completed soil analysis %s for sample %s, score=%.1f category=%s",
		created.UUID, sampleID, healthScore, category)
	return created, nil
}

func (s *soilService) ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]models.SoilAnalysis, int64, error) {
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
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

// ---------------------------------------------------------------------------
// Maps
// ---------------------------------------------------------------------------

func (s *soilService) GetSoilMap(ctx context.Context, fieldID, tenantID, mapType string) (*models.SoilMap, error) {
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field id is required")
	}
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
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

// ---------------------------------------------------------------------------
// Health
// ---------------------------------------------------------------------------

func (s *soilService) GetSoilHealth(ctx context.Context, fieldID, tenantID string) (*models.SoilHealthScore, error) {
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field id is required")
	}
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	return s.repo.GetLatestSoilHealthScore(ctx, fieldID, tenantID)
}

// ---------------------------------------------------------------------------
// Nutrients
// ---------------------------------------------------------------------------

func (s *soilService) GetNutrientLevels(ctx context.Context, sampleID, tenantID string) ([]models.SoilNutrient, error) {
	if sampleID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "sample id is required")
	}
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}
	return s.repo.ListNutrientsBySample(ctx, sampleID, tenantID)
}

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

func (s *soilService) GenerateSoilReport(ctx context.Context, fieldID, tenantID, farmID string) (*models.SoilReport, error) {
	if fieldID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "field id is required")
	}
	ctxTenant := p9context.TenantID(ctx)
	if ctxTenant != "" {
		tenantID = ctxTenant
	}
	if tenantID == "" {
		return nil, errors.BadRequest("INVALID_ARGUMENT", "tenant id is required")
	}

	// Get the most recent sample for the field
	samples, _, err := s.repo.ListSoilSamples(ctx, tenantID, fieldID, farmID, 1, 0)
	if err != nil {
		return nil, err
	}
	if len(samples) == 0 {
		return nil, errors.NotFound("NO_SAMPLES_FOUND", fmt.Sprintf("no soil samples found for field %s", fieldID))
	}
	latestSample := &samples[0]

	// Get the most recent analysis for the field
	analyses, _, err := s.repo.ListSoilAnalyses(ctx, tenantID, fieldID, farmID, "", 1, 0)
	if err != nil {
		s.logger.Warnf("failed to fetch analyses for report: %v", err)
	}
	var latestAnalysis *models.SoilAnalysis
	if len(analyses) > 0 {
		latestAnalysis = &analyses[0]
	}

	// Get health score
	healthScore, err := s.repo.GetLatestSoilHealthScore(ctx, fieldID, tenantID)
	if err != nil && !errors.IsNotFound(err) {
		s.logger.Warnf("failed to fetch health score for report: %v", err)
	}

	// Get nutrient details for the latest sample
	nutrients, err := s.repo.ListNutrientsBySample(ctx, latestSample.UUID, tenantID)
	if err != nil {
		s.logger.Warnf("failed to fetch nutrients for report: %v", err)
		nutrients = make([]models.SoilNutrient, 0)
	}

	// Aggregate recommendations
	recommendations := aggregateRecommendations(latestSample, latestAnalysis, healthScore)

	report := &models.SoilReport{
		Sample:          latestSample,
		Analysis:        latestAnalysis,
		HealthScore:     healthScore,
		Nutrients:       nutrients,
		Recommendations: recommendations,
		GeneratedAt:     time.Now(),
	}

	s.logger.Infof("generated soil report for field %s", fieldID)
	return report, nil
}

// ---------------------------------------------------------------------------
// Event publishing
// ---------------------------------------------------------------------------

func (s *soilService) publishEvent(ctx context.Context, eventType domain.EventType, aggregateID, aggregateType string, data map[string]interface{}) {
	event := domain.NewDomainEvent(eventType, aggregateID, aggregateType, data).
		WithSource("soil-service").
		WithCorrelationID(p9context.RequestID(ctx))

	tenantID := p9context.TenantID(ctx)
	if tenantID != "" {
		event.WithMetadata("tenant_id", tenantID)
	}
	userID := p9context.UserID(ctx)
	if userID != "" {
		event.WithMetadata("user_id", userID)
	}

	if s.deps.KafkaProducer != nil {
		// Fire-and-forget with logging; event publishing should not block the main flow
		go func() {
			publisher := domain.NewDomainEventPublisher(nil, s.deps.KafkaProducer, s.deps.Log)
			if err := publisher.PublishEvent(ctx, event); err != nil {
				s.logger.Warnf("failed to publish event %s: %v", event.ID, err)
			}
		}()
	}
}

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

func validateSoilSample(sample *models.SoilSample) error {
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

// computeSoilHealthScore produces a 0-100 health score from a soil sample.
// It uses a weighted composite of pH, organic matter, CEC, macronutrients,
// and micronutrients to derive an overall soil quality index.
func computeSoilHealthScore(sample *models.SoilSample) float64 {
	phScore := computePHScore(sample.PH)
	omScore := computeOrganicMatterScore(sample.OrganicMatterPct)
	cecScore := computeCECScore(sample.CationExchangeCapacity)
	macroScore := computeMacronutrientScore(sample)
	microScore := computeMicronutrientScore(sample)

	// Weighted composite
	overall := phScore*0.25 + omScore*0.20 + cecScore*0.15 + macroScore*0.25 + microScore*0.15

	return math.Round(overall*10) / 10
}

// computePHScore returns a 0-100 score. Optimal range 6.0-7.0.
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

// computeOrganicMatterScore returns a 0-100 score. Optimal >= 5%.
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

// computeCECScore returns a 0-100 score. Optimal 15-25 meq/100g.
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

// computeMacronutrientScore evaluates N, P, K balance. Optimal ranges: N 20-40, P 25-50, K 150-250 ppm.
func computeMacronutrientScore(sample *models.SoilSample) float64 {
	nScore := nutrientRangeScore(sample.NitrogenPPM, 20, 40, 0, 80)
	pScore := nutrientRangeScore(sample.PhosphorusPPM, 25, 50, 0, 100)
	kScore := nutrientRangeScore(sample.PotassiumPPM, 150, 250, 0, 500)
	caScore := nutrientRangeScore(sample.CalciumPPM, 1000, 3000, 0, 5000)
	mgScore := nutrientRangeScore(sample.MagnesiumPPM, 100, 300, 0, 600)
	sScore := nutrientRangeScore(sample.SulfurPPM, 10, 30, 0, 60)

	return (nScore*0.25 + pScore*0.20 + kScore*0.20 + caScore*0.15 + mgScore*0.10 + sScore*0.10)
}

// computeMicronutrientScore evaluates Fe, Mn, Zn, Cu, B.
func computeMicronutrientScore(sample *models.SoilSample) float64 {
	feScore := nutrientRangeScore(sample.IronPPM, 4.5, 20, 0, 50)
	mnScore := nutrientRangeScore(sample.ManganesePPM, 1, 5, 0, 15)
	znScore := nutrientRangeScore(sample.ZincPPM, 1, 3, 0, 10)
	cuScore := nutrientRangeScore(sample.CopperPPM, 0.2, 1, 0, 3)
	bScore := nutrientRangeScore(sample.BoronPPM, 0.5, 2, 0, 5)

	return (feScore + mnScore + znScore + cuScore + bScore) / 5.0
}

// nutrientRangeScore maps a nutrient value onto 0-100, with 100 in [optMin,optMax].
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
	// value > optMax
	if value >= absMax {
		return 0.0
	}
	return ((absMax - value) / (absMax - optMax)) * 100.0
}

// classifyHealthCategory maps a 0-100 score to a category.
func classifyHealthCategory(score float64) models.HealthCategory {
	switch {
	case score >= 85:
		return models.HealthCategoryExcellent
	case score >= 70:
		return models.HealthCategoryGood
	case score >= 50:
		return models.HealthCategoryFair
	case score >= 30:
		return models.HealthCategoryPoor
	default:
		return models.HealthCategoryCritical
	}
}

func computePhysicalScore(sample *models.SoilSample) float64 {
	bulkDensityScore := 100.0
	if sample.BulkDensity > 0 {
		// Optimal 1.1-1.4 g/cm3
		bulkDensityScore = nutrientRangeScore(sample.BulkDensity, 1.1, 1.4, 0.5, 2.0)
	}
	moistureScore := nutrientRangeScore(sample.MoisturePct, 20, 60, 0, 100)
	textureScore := 70.0
	switch sample.Texture {
	case models.SoilTextureLoamy:
		textureScore = 100.0
	case models.SoilTextureSilt:
		textureScore = 85.0
	case models.SoilTextureClay:
		textureScore = 65.0
	case models.SoilTextureSandy:
		textureScore = 55.0
	case models.SoilTexturePeat:
		textureScore = 75.0
	case models.SoilTextureChalk:
		textureScore = 60.0
	}
	return (bulkDensityScore*0.35 + moistureScore*0.35 + textureScore*0.30)
}

func computeChemicalScore(sample *models.SoilSample) float64 {
	phScore := computePHScore(sample.PH)
	cecScore := computeCECScore(sample.CationExchangeCapacity)
	ecScore := 100.0
	if sample.ElectricalConductivity > 4.0 {
		ecScore = math.Max(0, 100.0-(sample.ElectricalConductivity-4.0)*20.0)
	}
	macroScore := computeMacronutrientScore(sample)
	return (phScore*0.30 + cecScore*0.25 + ecScore*0.15 + macroScore*0.30)
}

func computeBiologicalScore(sample *models.SoilSample) float64 {
	omScore := computeOrganicMatterScore(sample.OrganicMatterPct)
	// Approximate biological activity from organic matter and nitrogen
	nScore := nutrientRangeScore(sample.NitrogenPPM, 20, 40, 0, 80)
	return (omScore*0.60 + nScore*0.40)
}

// ---------------------------------------------------------------------------
// Recommendation Engine
// ---------------------------------------------------------------------------

func generateRecommendations(sample *models.SoilSample, healthScore float64) []string {
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

func generateAnalysisSummary(sample *models.SoilSample, score float64, category models.HealthCategory) string {
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

func detectNutrientDeficiencies(sample *models.SoilSample) []models.NutrientDeficiency {
	defs := make([]models.NutrientDeficiency, 0)

	checkDeficiency := func(name string, value, optMin float64, rec string) {
		if value < optMin {
			level := models.NutrientLevelLow
			if value < optMin*0.5 {
				level = models.NutrientLevelDeficient
			}
			defs = append(defs, models.NutrientDeficiency{
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

func deficiencyNames(defs []models.NutrientDeficiency) []string {
	names := make([]string, 0, len(defs))
	for _, d := range defs {
		names = append(names, d.NutrientName)
	}
	return names
}

func extractNutrients(sample *models.SoilSample, tenantID, sampleID, userID string) []models.SoilNutrient {
	type nutrientSpec struct {
		name      string
		value     float64
		optMin    float64
		optMax    float64
		unit      string
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

	nutrients := make([]models.SoilNutrient, 0, len(specs))
	for _, sp := range specs {
		level := classifyNutrientLevel(sp.value, sp.optMin, sp.optMax)
		n := models.SoilNutrient{
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

func classifyNutrientLevel(value, optMin, optMax float64) models.NutrientLevel {
	if value < optMin*0.5 {
		return models.NutrientLevelDeficient
	}
	if value < optMin {
		return models.NutrientLevelLow
	}
	if value <= optMax {
		return models.NutrientLevelAdequate
	}
	if value <= optMax*1.5 {
		return models.NutrientLevelHigh
	}
	return models.NutrientLevelExcessive
}

func aggregateRecommendations(sample *models.SoilSample, analysis *models.SoilAnalysis, health *models.SoilHealthScore) []string {
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

// Ensure ptr import is referenced.
var _ = ptr.Ptr[string]
