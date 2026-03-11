package services

import (
	"context"
	"fmt"
	"math"

	"p9e.in/samavaya/agriculture/yield-service/internal/models"
	"p9e.in/samavaya/agriculture/yield-service/internal/repositories"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// YieldService defines the interface for yield business logic.
type YieldService interface {
	// Predictions
	PredictYield(ctx context.Context, req *PredictYieldInput) (*models.YieldPrediction, error)
	GetPrediction(ctx context.Context, id string) (*models.YieldPrediction, error)
	ListPredictions(ctx context.Context, req *ListPredictionsInput) ([]*models.YieldPrediction, int64, error)

	// Yield Records
	RecordYield(ctx context.Context, req *RecordYieldInput) (*models.YieldRecord, error)
	GetYieldHistory(ctx context.Context, req *GetYieldHistoryInput) ([]*models.YieldRecord, int64, error)

	// Harvest Plans
	CreateHarvestPlan(ctx context.Context, req *CreateHarvestPlanInput) (*models.HarvestPlan, error)
	GetHarvestPlan(ctx context.Context, id string) (*models.HarvestPlan, error)
	ListHarvestPlans(ctx context.Context, req *ListHarvestPlansInput) ([]*models.HarvestPlan, int64, error)

	// Analytics
	GetCropPerformance(ctx context.Context, req *GetCropPerformanceInput) (*models.CropPerformance, error)
	CompareYields(ctx context.Context, req *CompareYieldsInput) (*CompareYieldsOutput, error)
}

// --- Input/Output DTOs ---

// PredictYieldInput holds the input for yield prediction.
type PredictYieldInput struct {
	FarmID       string
	FieldID      string
	CropID       string
	Season       string
	Year         int32
	YieldFactors models.YieldFactors
}

// ListPredictionsInput holds the input for listing predictions.
type ListPredictionsInput struct {
	FarmID   string
	FieldID  string
	CropID   string
	Season   string
	Year     int32
	Status   string
	PageSize int32
	Offset   int32
}

// RecordYieldInput holds the input for recording actual yield.
type RecordYieldInput struct {
	FarmID                     string
	FieldID                    string
	CropID                     string
	Season                     string
	Year                       int32
	ActualYieldKgPerHectare    float64
	TotalAreaHarvestedHectares float64
	TotalYieldKg               float64
	HarvestQualityGrade        string
	MoistureContentPct         float64
	HarvestDate                *models.HarvestDateInput
	RevenuePerHectare          float64
	CostPerHectare             float64
	PredictionID               string
}

// HarvestDateInput wraps a time value for the harvest date.
type HarvestDateInput = models.HarvestDateInputType

// GetYieldHistoryInput holds the input for getting yield history.
type GetYieldHistoryInput struct {
	FarmID   string
	FieldID  string
	CropID   string
	FromYear int32
	ToYear   int32
	PageSize int32
	Offset   int32
}

// CreateHarvestPlanInput holds the input for creating a harvest plan.
type CreateHarvestPlanInput struct {
	FarmID           string
	FieldID          string
	CropID           string
	Season           string
	Year             int32
	PlannedStartDate models.PlanDateInput
	PlannedEndDate   models.PlanDateInput
	EstimatedYieldKg float64
	TotalAreaHectares float64
	Notes            string
}

// ListHarvestPlansInput holds the input for listing harvest plans.
type ListHarvestPlansInput struct {
	FarmID   string
	FieldID  string
	CropID   string
	Season   string
	Year     int32
	Status   string
	PageSize int32
	Offset   int32
}

// GetCropPerformanceInput holds the input for retrieving crop performance analytics.
type GetCropPerformanceInput struct {
	FarmID  string
	FieldID string
	CropID  string
	Season  string
	Year    int32
}

// CompareYieldsInput holds the input for comparing yields across seasons/years.
type CompareYieldsInput struct {
	FarmID  string
	FieldID string
	CropID  string
	YearA   int32
	SeasonA string
	YearB   int32
	SeasonB string
}

// CompareYieldsOutput holds the output of yield comparison analytics.
type CompareYieldsOutput struct {
	PerformanceA                *models.CropPerformance
	PerformanceB                *models.CropPerformance
	YieldDifferenceKgPerHectare float64
	YieldDifferencePct          float64
	ProfitDifferencePerHectare  float64
}

// yieldService implements YieldService.
type yieldService struct {
	repo   repositories.YieldRepository
	deps   deps.ServiceDeps
	logger *p9log.Helper
}

// NewYieldService creates a new YieldService instance.
func NewYieldService(d deps.ServiceDeps, repo repositories.YieldRepository) YieldService {
	return &yieldService{
		repo:   repo,
		deps:   d,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "YieldService")),
	}
}

// --- Prediction Operations ---

// PredictYield generates a yield prediction using multi-factor analysis.
//
// The prediction algorithm works as follows:
//  1. Retrieve base yield for the crop type (region-calibrated reference yield).
//  2. Apply a weighted composite factor score from six individual factor scores.
//  3. Incorporate historical yield data for the same field/crop to adjust the base.
//  4. Calculate confidence level based on factor score variance and data availability.
//  5. Persist the prediction and mark its status as completed.
func (s *yieldService) PredictYield(ctx context.Context, req *PredictYieldInput) (*models.YieldPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if req.FarmID == "" || req.FieldID == "" || req.CropID == "" {
		return nil, errors.BadRequest("MISSING_REQUIRED_FIELDS", "farm_id, field_id, and crop_id are required")
	}
	if req.Season == "" || req.Year <= 0 {
		return nil, errors.BadRequest("MISSING_REQUIRED_FIELDS", "season and year are required")
	}

	// Step 1: Determine base yield for the crop
	baseYield := getBaseCropYield(req.CropID)

	// Step 2: Calculate weighted composite factor score (0.0 - 1.0 scale)
	factors := req.YieldFactors
	compositeScore := factors.WeightedScore()

	// Clamp composite score to [0, 1]
	if compositeScore > 1.0 {
		compositeScore = 1.0
	}
	if compositeScore < 0.0 {
		compositeScore = 0.0
	}

	// Step 3: Incorporate historical data
	historicalAvg, err := s.repo.GetHistoricalAverageYield(ctx, tenantID, req.FarmID, req.FieldID, req.CropID)
	if err != nil {
		s.logger.Warnf("could not fetch historical average, using base yield: %v", err)
		historicalAvg = 0
	}

	// Blend base yield with historical data (70% historical if available, 30% reference)
	var adjustedBase float64
	if historicalAvg > 0 {
		adjustedBase = historicalAvg*0.7 + baseYield*0.3
	} else {
		adjustedBase = baseYield
	}

	// Step 4: Apply factor-adjusted prediction
	// The composite score scales the adjusted base: at 1.0 you get 110% of base, at 0.5 you get base, at 0 you get 50%
	scaleFactor := 0.5 + compositeScore*0.6
	predictedYield := adjustedBase * scaleFactor

	// Round to 2 decimal places
	predictedYield = math.Round(predictedYield*100) / 100

	// Step 5: Calculate confidence percentage
	confidence := calculateConfidence(factors, historicalAvg > 0)

	prediction := &models.YieldPrediction{
		TenantID:                   tenantID,
		FarmID:                     req.FarmID,
		FieldID:                    req.FieldID,
		CropID:                     req.CropID,
		Season:                     req.Season,
		Year:                       req.Year,
		PredictedYieldKgPerHectare: predictedYield,
		PredictionConfidencePct:    confidence,
		PredictionModelVersion:     models.PredictionModelVersion,
		Status:                     models.PredictionStatusCompleted,
		SoilQualityScore:           factors.SoilQualityScore,
		WeatherScore:               factors.WeatherScore,
		IrrigationScore:            factors.IrrigationScore,
		PestPressureScore:          factors.PestPressureScore,
		NutrientScore:              factors.NutrientScore,
		ManagementScore:            factors.ManagementScore,
	}
	prediction.CreatedBy = userID

	result, err := s.repo.CreatePrediction(ctx, prediction)
	if err != nil {
		return nil, err
	}

	s.logger.Infof("yield prediction created: id=%s, predicted=%.2f kg/ha, confidence=%.1f%%",
		result.UUID, predictedYield, confidence)

	return result, nil
}

// getBaseCropYield returns the base reference yield (kg/ha) for a given crop.
func getBaseCropYield(cropID string) float64 {
	if yield, ok := models.BaseCropYieldKgPerHectare[cropID]; ok {
		return yield
	}
	return models.BaseCropYieldKgPerHectare["default"]
}

// calculateConfidence computes prediction confidence based on factor consistency
// and whether historical data is available.
func calculateConfidence(factors models.YieldFactors, hasHistory bool) float64 {
	scores := []float64{
		factors.SoilQualityScore,
		factors.WeatherScore,
		factors.IrrigationScore,
		factors.PestPressureScore,
		factors.NutrientScore,
		factors.ManagementScore,
	}

	// Calculate mean
	var sum float64
	nonZeroCount := 0
	for _, s := range scores {
		sum += s
		if s > 0 {
			nonZeroCount++
		}
	}

	// More data points available means higher base confidence
	baseConfidence := 40.0 // minimum confidence
	if hasHistory {
		baseConfidence += 20.0
	}

	// Higher factor coverage increases confidence
	if nonZeroCount > 0 {
		coverage := float64(nonZeroCount) / float64(len(scores))
		baseConfidence += coverage * 20.0
	}

	// Lower variance among factors increases confidence (consistent data = more reliable)
	if nonZeroCount > 1 {
		mean := sum / float64(nonZeroCount)
		var varianceSum float64
		for _, s := range scores {
			if s > 0 {
				diff := s - mean
				varianceSum += diff * diff
			}
		}
		variance := varianceSum / float64(nonZeroCount)
		// Low variance (< 0.02) gives full bonus, high variance (> 0.1) gives none
		varianceBonus := math.Max(0, 1.0-variance/0.1) * 20.0
		baseConfidence += varianceBonus
	}

	// Clamp to [0, 100]
	confidence := math.Min(100.0, math.Max(0, baseConfidence))
	return math.Round(confidence*10) / 10
}

func (s *yieldService) GetPrediction(ctx context.Context, id string) (*models.YieldPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "prediction ID is required")
	}
	return s.repo.GetPredictionByUUID(ctx, tenantID, id)
}

func (s *yieldService) ListPredictions(ctx context.Context, req *ListPredictionsInput) ([]*models.YieldPrediction, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	pageSize := req.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	params := &repositories.ListPredictionsParams{
		TenantID: tenantID,
		FarmID:   req.FarmID,
		FieldID:  req.FieldID,
		CropID:   req.CropID,
		Season:   req.Season,
		Year:     req.Year,
		Status:   req.Status,
		Limit:    pageSize,
		Offset:   req.Offset,
	}

	return s.repo.ListPredictions(ctx, params)
}

// --- Yield Record Operations ---

func (s *yieldService) RecordYield(ctx context.Context, req *RecordYieldInput) (*models.YieldRecord, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if req.FarmID == "" || req.FieldID == "" || req.CropID == "" {
		return nil, errors.BadRequest("MISSING_REQUIRED_FIELDS", "farm_id, field_id, and crop_id are required")
	}
	if req.ActualYieldKgPerHectare <= 0 {
		return nil, errors.BadRequest("INVALID_YIELD", "actual_yield_kg_per_hectare must be positive")
	}

	record := &models.YieldRecord{
		TenantID:                   tenantID,
		FarmID:                     req.FarmID,
		FieldID:                    req.FieldID,
		CropID:                     req.CropID,
		Season:                     req.Season,
		Year:                       req.Year,
		ActualYieldKgPerHectare:    req.ActualYieldKgPerHectare,
		TotalAreaHarvestedHectares: req.TotalAreaHarvestedHectares,
		TotalYieldKg:               req.TotalYieldKg,
		HarvestQualityGrade:        req.HarvestQualityGrade,
		MoistureContentPct:         req.MoistureContentPct,
		RevenuePerHectare:          req.RevenuePerHectare,
		CostPerHectare:             req.CostPerHectare,
		ProfitPerHectare:           req.RevenuePerHectare - req.CostPerHectare,
	}
	record.CreatedBy = userID

	// Set harvest date if provided
	if req.HarvestDate != nil {
		record.HarvestDate = &req.HarvestDate.Time
	}

	// Link to prediction if provided
	if req.PredictionID != "" {
		record.PredictionID = &req.PredictionID
	}

	// Set quality grade default
	if record.HarvestQualityGrade == "" {
		record.HarvestQualityGrade = models.HarvestQualityGradeB
	}

	// Auto-calculate total yield if not provided
	if record.TotalYieldKg <= 0 && record.TotalAreaHarvestedHectares > 0 {
		record.TotalYieldKg = record.ActualYieldKgPerHectare * record.TotalAreaHarvestedHectares
	}

	result, err := s.repo.CreateYieldRecord(ctx, record)
	if err != nil {
		return nil, err
	}

	// Update prediction status to superseded if linked
	if req.PredictionID != "" {
		if _, err := s.repo.UpdatePredictionStatus(ctx, tenantID, req.PredictionID,
			models.PredictionStatusSuperseded, userID); err != nil {
			s.logger.Warnf("failed to update linked prediction status: %v", err)
		}
	}

	// Asynchronously calculate and update crop performance analytics
	go s.updateCropPerformance(context.Background(), tenantID, result)

	s.logger.Infof("yield recorded: id=%s, actual=%.2f kg/ha, quality=%s",
		result.UUID, result.ActualYieldKgPerHectare, result.HarvestQualityGrade)

	return result, nil
}

// updateCropPerformance recalculates and persists crop performance analytics.
func (s *yieldService) updateCropPerformance(ctx context.Context, tenantID string, record *models.YieldRecord) {
	// Get regional and historical averages for comparison
	regionalAvg, err := s.repo.GetRegionalAverageYield(ctx, tenantID, record.CropID, record.Season)
	if err != nil {
		s.logger.Warnf("failed to get regional average for performance calc: %v", err)
		regionalAvg = 0
	}

	historicalAvg, err := s.repo.GetHistoricalAverageYield(ctx, tenantID, record.FarmID, record.FieldID, record.CropID)
	if err != nil {
		s.logger.Warnf("failed to get historical average for performance calc: %v", err)
		historicalAvg = 0
	}

	// Look up linked prediction for yield variance
	var predictedYield float64
	if record.PredictionID != nil && *record.PredictionID != "" {
		pred, err := s.repo.GetPredictionByUUID(ctx, tenantID, *record.PredictionID)
		if err == nil {
			predictedYield = pred.PredictedYieldKgPerHectare
		}
	}

	// Calculate variance percentages
	var yieldVariancePct, regionalCompPct, historicalCompPct float64
	if predictedYield > 0 {
		yieldVariancePct = ((record.ActualYieldKgPerHectare - predictedYield) / predictedYield) * 100
	}
	if regionalAvg > 0 {
		regionalCompPct = ((record.ActualYieldKgPerHectare - regionalAvg) / regionalAvg) * 100
	}
	if historicalAvg > 0 {
		historicalCompPct = ((record.ActualYieldKgPerHectare - historicalAvg) / historicalAvg) * 100
	}

	perf := &models.CropPerformance{
		TenantID:                     tenantID,
		FarmID:                       record.FarmID,
		FieldID:                      record.FieldID,
		CropID:                       record.CropID,
		Season:                       record.Season,
		Year:                         record.Year,
		ActualYieldKgPerHectare:      record.ActualYieldKgPerHectare,
		PredictedYieldKgPerHectare:   predictedYield,
		YieldVariancePct:             math.Round(yieldVariancePct*100) / 100,
		ComparisonToRegionalAvgPct:   math.Round(regionalCompPct*100) / 100,
		ComparisonToHistoricalAvgPct: math.Round(historicalCompPct*100) / 100,
		RevenuePerHectare:            record.RevenuePerHectare,
		CostPerHectare:               record.CostPerHectare,
		ProfitPerHectare:             record.ProfitPerHectare,
	}

	if _, err := s.repo.UpsertCropPerformance(ctx, perf); err != nil {
		s.logger.Errorf("failed to upsert crop performance: %v", err)
	}
}

func (s *yieldService) GetYieldHistory(ctx context.Context, req *GetYieldHistoryInput) ([]*models.YieldRecord, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	pageSize := req.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	params := &repositories.ListYieldRecordsParams{
		TenantID: tenantID,
		FarmID:   req.FarmID,
		FieldID:  req.FieldID,
		CropID:   req.CropID,
		FromYear: req.FromYear,
		ToYear:   req.ToYear,
		Limit:    pageSize,
		Offset:   req.Offset,
	}

	return s.repo.ListYieldRecords(ctx, params)
}

// --- Harvest Plan Operations ---

func (s *yieldService) CreateHarvestPlan(ctx context.Context, req *CreateHarvestPlanInput) (*models.HarvestPlan, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if req.FarmID == "" || req.FieldID == "" || req.CropID == "" {
		return nil, errors.BadRequest("MISSING_REQUIRED_FIELDS", "farm_id, field_id, and crop_id are required")
	}
	if req.PlannedStartDate.Time.After(req.PlannedEndDate.Time) {
		return nil, errors.BadRequest("INVALID_DATE_RANGE", "planned start date must be before end date")
	}

	plan := &models.HarvestPlan{
		TenantID:          tenantID,
		FarmID:            req.FarmID,
		FieldID:           req.FieldID,
		CropID:            req.CropID,
		Season:            req.Season,
		Year:              req.Year,
		PlannedStartDate:  req.PlannedStartDate.Time,
		PlannedEndDate:    req.PlannedEndDate.Time,
		EstimatedYieldKg:  req.EstimatedYieldKg,
		TotalAreaHectares: req.TotalAreaHectares,
		Status:            models.HarvestPlanStatusDraft,
	}
	plan.CreatedBy = userID

	if req.Notes != "" {
		plan.Notes = &req.Notes
	}

	result, err := s.repo.CreateHarvestPlan(ctx, plan)
	if err != nil {
		return nil, err
	}

	s.logger.Infof("harvest plan created: id=%s, farm=%s, field=%s",
		result.UUID, result.FarmID, result.FieldID)

	return result, nil
}

func (s *yieldService) GetHarvestPlan(ctx context.Context, id string) (*models.HarvestPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "harvest plan ID is required")
	}
	return s.repo.GetHarvestPlanByUUID(ctx, tenantID, id)
}

func (s *yieldService) ListHarvestPlans(ctx context.Context, req *ListHarvestPlansInput) ([]*models.HarvestPlan, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}

	pageSize := req.PageSize
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	params := &repositories.ListHarvestPlansParams{
		TenantID: tenantID,
		FarmID:   req.FarmID,
		FieldID:  req.FieldID,
		CropID:   req.CropID,
		Season:   req.Season,
		Year:     req.Year,
		Status:   req.Status,
		Limit:    pageSize,
		Offset:   req.Offset,
	}

	return s.repo.ListHarvestPlans(ctx, params)
}

// --- Analytics Operations ---

func (s *yieldService) GetCropPerformance(ctx context.Context, req *GetCropPerformanceInput) (*models.CropPerformance, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if req.FarmID == "" || req.FieldID == "" || req.CropID == "" {
		return nil, errors.BadRequest("MISSING_REQUIRED_FIELDS", "farm_id, field_id, and crop_id are required")
	}
	if req.Season == "" || req.Year <= 0 {
		return nil, errors.BadRequest("MISSING_REQUIRED_FIELDS", "season and year are required")
	}

	return s.repo.GetCropPerformance(ctx, tenantID, req.FarmID, req.FieldID, req.CropID, req.Season, req.Year)
}

func (s *yieldService) CompareYields(ctx context.Context, req *CompareYieldsInput) (*CompareYieldsOutput, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if req.FarmID == "" || req.FieldID == "" || req.CropID == "" {
		return nil, errors.BadRequest("MISSING_REQUIRED_FIELDS", "farm_id, field_id, and crop_id are required")
	}

	// Fetch performance A
	perfA, err := s.repo.GetCropPerformance(ctx, tenantID, req.FarmID, req.FieldID, req.CropID, req.SeasonA, req.YearA)
	if err != nil {
		return nil, fmt.Errorf("failed to get performance for period A: %w", err)
	}

	// Fetch performance B
	perfB, err := s.repo.GetCropPerformance(ctx, tenantID, req.FarmID, req.FieldID, req.CropID, req.SeasonB, req.YearB)
	if err != nil {
		return nil, fmt.Errorf("failed to get performance for period B: %w", err)
	}

	// Calculate differences
	yieldDiff := perfA.ActualYieldKgPerHectare - perfB.ActualYieldKgPerHectare
	var yieldDiffPct float64
	if perfB.ActualYieldKgPerHectare > 0 {
		yieldDiffPct = (yieldDiff / perfB.ActualYieldKgPerHectare) * 100
	}
	profitDiff := perfA.ProfitPerHectare - perfB.ProfitPerHectare

	return &CompareYieldsOutput{
		PerformanceA:                perfA,
		PerformanceB:                perfB,
		YieldDifferenceKgPerHectare: math.Round(yieldDiff*100) / 100,
		YieldDifferencePct:          math.Round(yieldDiffPct*100) / 100,
		ProfitDifferencePerHectare:  math.Round(profitDiff*100) / 100,
	}, nil
}
