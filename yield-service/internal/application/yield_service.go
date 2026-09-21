// Package application contains the yield-service application service.
package application

import (
	"context"
	"encoding/json"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/yield-service/internal/ai"
	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/outbound"
)

const (
	serviceName           = "yield-service"
	eventTopic            = "samavaya.agriculture.yield.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)
)

type yieldService struct {
	repo             outbound.YieldRepository
	pub              outbound.EventPublisher
	fieldClient      outbound.FieldClient
	soilClient       outbound.SoilClient
	irrigationClient outbound.IrrigationClient
	pestClient       outbound.PestClient
	cropClient       outbound.CropClient
	farmClient       outbound.FarmClient
	weatherClient    outbound.WeatherClient
	pool             *pgxpool.Pool
	log              *p9log.Helper
	aiClient         *ai.AIClient
	now              func() time.Time
}

var _ inbound.YieldService = (*yieldService)(nil)

// WithWeatherClient enables observed-weather features for AI yield predictions.
func (s *yieldService) WithWeatherClient(w outbound.WeatherClient) *yieldService {
	s.weatherClient = w
	return s
}

// observedEnvironment fetches season-to-date agro metrics for the field so the
// gateway sees real GDD, rainfall, and stress-day counts instead of placeholders.
// Returns nil (placeholders) when weather is unavailable.
func (s *yieldService) observedEnvironment(ctx context.Context, p *domain.YieldPrediction) *ai.EnvironmentInput {
	if s.weatherClient == nil || p.FieldID == "" {
		return nil
	}
	now := time.Now()
	if s.now != nil {
		now = s.now()
	}
	start, end := SeasonWindow(p.Season, int(p.Year), now)
	if !end.After(start) {
		return nil
	}
	w, err := s.weatherClient.SeasonWeather(ctx, p.FieldID, start, end)
	if err != nil || w == nil || w.Days == 0 {
		s.log.Warnw("msg", "season weather unavailable; using score-derived environment", "field_id", p.FieldID, "error", err)
		return nil
	}
	return &ai.EnvironmentInput{
		AvgTemperatureC:   w.AvgTemperatureC,
		HumidityPct:       w.AvgHumidityPct,
		RainfallMM:        w.TotalPrecipMM,
		SolarRadiationMJ:  w.AvgSolarMJ,
		GrowingDegreeDays: w.GrowingDegreeDays,
		FrostDays:         w.FrostDays,
		HeatStressDays:    w.HeatStressDays,
	}
}

// SeasonWindow maps an Indian cropping season and year onto a date range,
// clipped to `now` so in-season predictions use season-to-date weather.
// Unknown seasons use the calendar year.
func SeasonWindow(season string, year int, now time.Time) (time.Time, time.Time) {
	var start, end time.Time
	switch strings.ToLower(strings.TrimSpace(season)) {
	case "kharif", "monsoon", "khariff":
		start = time.Date(year, time.June, 1, 0, 0, 0, 0, time.UTC)
		end = time.Date(year, time.October, 31, 0, 0, 0, 0, time.UTC)
	case "rabi", "winter":
		start = time.Date(year, time.November, 1, 0, 0, 0, 0, time.UTC)
		end = time.Date(year+1, time.March, 31, 0, 0, 0, 0, time.UTC)
	case "zaid", "summer", "spring":
		start = time.Date(year, time.March, 1, 0, 0, 0, 0, time.UTC)
		end = time.Date(year, time.June, 30, 0, 0, 0, 0, time.UTC)
	default:
		start = time.Date(year, time.January, 1, 0, 0, 0, 0, time.UTC)
		end = time.Date(year, time.December, 31, 0, 0, 0, 0, time.UTC)
	}
	if end.After(now) {
		end = now
	}
	return start, end
}

// NewYieldService creates a new application-layer YieldService.
func NewYieldService(
	repo outbound.YieldRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	soilClient outbound.SoilClient,
	irrigationClient outbound.IrrigationClient,
	pestClient outbound.PestClient,
	cropClient outbound.CropClient,
	farmClient outbound.FarmClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
	aiClient *ai.AIClient,
) *yieldService {
	return &yieldService{
		repo:             repo,
		pub:              pub,
		fieldClient:      fieldClient,
		soilClient:       soilClient,
		irrigationClient: irrigationClient,
		pestClient:       pestClient,
		cropClient:       cropClient,
		farmClient:       farmClient,
		pool:             pool,
		log:              p9log.NewHelper(p9log.With(log, "component", "YieldService")),
		aiClient:         aiClient,
	}
}

// ---------------------------------------------------------------------------
// Predictions
// ---------------------------------------------------------------------------

func (s *yieldService) PredictYield(ctx context.Context, prediction *domain.YieldPrediction) (*domain.YieldPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if prediction.FarmID == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if prediction.FieldID == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if prediction.CropID == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}
	if prediction.Season == "" {
		return nil, errors.BadRequest("INVALID_SEASON", "season is required")
	}
	if prediction.Year <= 0 {
		return nil, errors.BadRequest("INVALID_YEAR", "year must be positive")
	}
	if userID == "" {
		userID = "system"
	}

	prediction.TenantID = tenantID
	prediction.CreatedBy = userID
	prediction.PredictionModelVersion = domain.PredictionModelVersion

	factors := prediction.GetYieldFactors()

	if s.aiClient != nil {
		requestID := p9context.RequestID(ctx)
		if requestID == "" {
			requestID = ulid.NewString()
		}
		aiFactors := ai.YieldFactorsInput{
			SoilQualityScore:  factors.SoilQualityScore / 100.0,
			WeatherScore:      factors.WeatherScore / 100.0,
			IrrigationScore:   factors.IrrigationScore / 100.0,
			PestPressureScore: factors.PestPressureScore / 100.0,
			NutrientScore:     factors.NutrientScore / 100.0,
			ManagementScore:   factors.ManagementScore / 100.0,
		}
		env := s.observedEnvironment(ctx, prediction)
		result, aiErr := s.aiClient.PredictYieldWithEnvironment(ctx, requestID, prediction.CropID, aiFactors, env, 1.0)
		if aiErr != nil {
			s.log.Warnw("msg", "AI PredictYield failed, falling back to formula", "error", aiErr)
		} else {
			prediction.PredictedYieldKgPerHectare = result.PredictedYieldKgPerHectare
			prediction.PredictionConfidencePct = result.ConfidencePct
			prediction.PredictionModelVersion = result.ModelVersion
			s.log.Infow("msg", "AI yield prediction",
				"field_id", prediction.FieldID, "model_source", result.ModelSource,
				"tabular_weight", result.TabularWeight, "crop_supported", result.CropSupported,
				"lower", result.YieldLowerBound, "upper", result.YieldUpperBound,
				"observed_weather", env != nil)
		}
	}

	if prediction.PredictedYieldKgPerHectare == 0 {
		baseYield, ok := domain.BaseCropYieldKgPerHectare[strings.ToLower(prediction.CropID)]
		if !ok {
			baseYield = domain.BaseCropYieldKgPerHectare["default"]
		}
		weightedScore := factors.WeightedScore()
		if weightedScore > 0 {
			prediction.PredictedYieldKgPerHectare = baseYield * (weightedScore / 100.0)
		} else {
			prediction.PredictedYieldKgPerHectare = baseYield
		}
		prediction.PredictionConfidencePct = computeConfidence(factors)
	}

	prediction.Status = "PREDICTION_STATUS_COMPLETED"

	created, err := s.repo.CreatePrediction(ctx, prediction)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.yield.prediction.created", created.ID, map[string]interface{}{
		"prediction_id": created.ID,
		"tenant_id":     tenantID,
		"farm_id":       created.FarmID,
		"field_id":      created.FieldID,
		"crop_id":       created.CropID,
	})
	s.log.Infow("msg", "prediction created", "id", created.ID)
	return created, nil
}

func (s *yieldService) GetPrediction(ctx context.Context, id string) (*domain.YieldPrediction, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "prediction ID is required")
	}
	return s.repo.GetPredictionByID(ctx, id, tenantID)
}

func (s *yieldService) ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.YieldPrediction, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = clampPageSize(params.PageSize)
	return s.repo.ListPredictions(ctx, params)
}

// ---------------------------------------------------------------------------
// Yield Records
// ---------------------------------------------------------------------------

func (s *yieldService) RecordYield(ctx context.Context, record *domain.YieldRecord) (*domain.YieldRecord, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if record.FarmID == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if record.FieldID == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if record.CropID == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}
	if record.Season == "" {
		return nil, errors.BadRequest("INVALID_SEASON", "season is required")
	}
	if record.Year <= 0 {
		return nil, errors.BadRequest("INVALID_YEAR", "year must be positive")
	}
	if userID == "" {
		userID = "system"
	}

	record.TenantID = tenantID
	record.CreatedBy = userID

	// Compute profit per hectare.
	record.ProfitPerHectare = record.RevenuePerHectare - record.CostPerHectare

	created, err := s.repo.CreateYieldRecord(ctx, record)
	if err != nil {
		return nil, err
	}

	// The harvest details travel with the event so traceability-service can
	// open a record without calling back for them. A traceability record is
	// the chain of custody for a batch, and the harvest is the link it starts
	// from: if it is missing, everything downstream traces to nothing.
	harvestDate := ""
	if created.HarvestDate != nil {
		harvestDate = created.HarvestDate.UTC().Format(time.RFC3339)
	}
	s.emitEvent(ctx, "agriculture.yield.record.created", created.ID, map[string]interface{}{
		"record_id":      created.ID,
		"tenant_id":      tenantID,
		"farm_id":        created.FarmID,
		"field_id":       created.FieldID,
		"crop_id":        created.CropID,
		"season":         created.Season,
		"year":           created.Year,
		"total_yield_kg": created.TotalYieldKg,
		"quality_grade":  created.HarvestQualityGrade,
		"harvest_date":   harvestDate,
	})
	s.log.Infow("msg", "yield record created", "id", created.ID)
	return created, nil
}

func (s *yieldService) GetYieldHistory(ctx context.Context, params domain.YieldHistoryParams) ([]domain.YieldRecord, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = clampPageSize(params.PageSize)
	return s.repo.ListYieldRecords(ctx, params)
}

// ---------------------------------------------------------------------------
// Harvest Plans
// ---------------------------------------------------------------------------

func (s *yieldService) CreateHarvestPlan(ctx context.Context, plan *domain.HarvestPlan) (*domain.HarvestPlan, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if plan.FarmID == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if plan.FieldID == "" {
		return nil, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	if plan.CropID == "" {
		return nil, errors.BadRequest("INVALID_CROP_ID", "crop_id is required")
	}
	if userID == "" {
		userID = "system"
	}

	plan.TenantID = tenantID
	plan.CreatedBy = userID
	plan.Status = "HARVEST_PLAN_STATUS_DRAFT"

	created, err := s.repo.CreateHarvestPlan(ctx, plan)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.yield.harvest_plan.created", created.ID, map[string]interface{}{
		"plan_id":   created.ID,
		"tenant_id": tenantID,
		"farm_id":   created.FarmID,
		"field_id":  created.FieldID,
		"crop_id":   created.CropID,
	})
	s.log.Infow("msg", "harvest plan created", "id", created.ID)
	return created, nil
}

func (s *yieldService) GetHarvestPlan(ctx context.Context, id string) (*domain.HarvestPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "harvest plan ID is required")
	}
	return s.repo.GetHarvestPlanByID(ctx, id, tenantID)
}

func (s *yieldService) ListHarvestPlans(ctx context.Context, params domain.ListHarvestPlansParams) ([]domain.HarvestPlan, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	params.PageSize = clampPageSize(params.PageSize)
	return s.repo.ListHarvestPlans(ctx, params)
}

// ---------------------------------------------------------------------------
// Crop Performance & Comparison
// ---------------------------------------------------------------------------

func (s *yieldService) GetCropPerformance(ctx context.Context, params domain.CropPerformanceParams) (*domain.CropPerformance, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID
	return s.repo.GetCropPerformance(ctx, params)
}

// ArchiveFieldForecasts retires the predictions and harvest plans for a field
// that no longer exists, and reports how many rows it retired.
//
// Not exposed over the API: no client asks yield-service to forget a field, and
// the only caller is the consumer reacting to field-service having deleted one.
func (s *yieldService) ArchiveFieldForecasts(ctx context.Context, fieldID string) (int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if fieldID == "" {
		return 0, errors.BadRequest("INVALID_FIELD_ID", "field_id is required")
	}
	return s.repo.ArchiveFieldForecasts(ctx, fieldID, tenantID)
}

func (s *yieldService) CompareYields(ctx context.Context, params domain.CompareYieldsParams) (*domain.CropPerformance, *domain.CropPerformance, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID

	perfA, err := s.repo.GetCropPerformance(ctx, domain.CropPerformanceParams{
		TenantID: params.TenantID,
		FarmID:   params.FarmID,
		FieldID:  params.FieldID,
		CropID:   params.CropID,
		Season:   params.SeasonA,
		Year:     params.YearA,
	})
	if err != nil {
		return nil, nil, err
	}

	perfB, err := s.repo.GetCropPerformance(ctx, domain.CropPerformanceParams{
		TenantID: params.TenantID,
		FarmID:   params.FarmID,
		FieldID:  params.FieldID,
		CropID:   params.CropID,
		Season:   params.SeasonB,
		Year:     params.YearB,
	})
	if err != nil {
		return nil, nil, err
	}

	return perfA, perfB, nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func computeConfidence(f domain.YieldFactors) float64 {
	scores := []float64{
		f.SoilQualityScore, f.WeatherScore, f.IrrigationScore,
		f.PestPressureScore, f.NutrientScore, f.ManagementScore,
	}
	var sum float64
	var count float64
	for _, s := range scores {
		if s > 0 {
			sum += s
			count++
		}
	}
	if count == 0 {
		return 0
	}
	// Confidence is the average of the non-zero factor scores.
	return sum / count
}

func clampPageSize(ps int32) int32 {
	if ps <= 0 {
		return defaultPageSize
	}
	if ps > maxPageSize {
		return maxPageSize
	}
	return ps
}

func (s *yieldService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
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
