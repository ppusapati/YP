package repositories

import (
	"context"
	"fmt"
	"time"

	"p9e.in/samavaya/agriculture/yield-service/internal/models"
	"p9e.in/samavaya/packages/convert/ptr"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// YieldRepository defines the interface for yield data persistence operations.
type YieldRepository interface {
	// Predictions
	CreatePrediction(ctx context.Context, prediction *models.YieldPrediction) (*models.YieldPrediction, error)
	GetPredictionByUUID(ctx context.Context, tenantID, uuid string) (*models.YieldPrediction, error)
	ListPredictions(ctx context.Context, params *ListPredictionsParams) ([]*models.YieldPrediction, int64, error)
	UpdatePredictionStatus(ctx context.Context, tenantID, uuid, status, updatedBy string) (*models.YieldPrediction, error)

	// Yield Records
	CreateYieldRecord(ctx context.Context, record *models.YieldRecord) (*models.YieldRecord, error)
	GetYieldRecordByUUID(ctx context.Context, tenantID, uuid string) (*models.YieldRecord, error)
	ListYieldRecords(ctx context.Context, params *ListYieldRecordsParams) ([]*models.YieldRecord, int64, error)
	GetRegionalAverageYield(ctx context.Context, tenantID, cropID, season string) (float64, error)
	GetHistoricalAverageYield(ctx context.Context, tenantID, farmID, fieldID, cropID string) (float64, error)

	// Harvest Plans
	CreateHarvestPlan(ctx context.Context, plan *models.HarvestPlan) (*models.HarvestPlan, error)
	GetHarvestPlanByUUID(ctx context.Context, tenantID, uuid string) (*models.HarvestPlan, error)
	ListHarvestPlans(ctx context.Context, params *ListHarvestPlansParams) ([]*models.HarvestPlan, int64, error)
	UpdateHarvestPlanStatus(ctx context.Context, tenantID, uuid, status, updatedBy string) (*models.HarvestPlan, error)

	// Crop Performance
	UpsertCropPerformance(ctx context.Context, perf *models.CropPerformance) (*models.CropPerformance, error)
	GetCropPerformance(ctx context.Context, tenantID, farmID, fieldID, cropID, season string, year int32) (*models.CropPerformance, error)
}

// ListPredictionsParams holds the parameters for listing yield predictions.
type ListPredictionsParams struct {
	TenantID string
	FarmID   string
	FieldID  string
	CropID   string
	Season   string
	Year     int32
	Status   string
	Limit    int32
	Offset   int32
}

// ListYieldRecordsParams holds the parameters for listing yield records.
type ListYieldRecordsParams struct {
	TenantID string
	FarmID   string
	FieldID  string
	CropID   string
	FromYear int32
	ToYear   int32
	Limit    int32
	Offset   int32
}

// ListHarvestPlansParams holds the parameters for listing harvest plans.
type ListHarvestPlansParams struct {
	TenantID string
	FarmID   string
	FieldID  string
	CropID   string
	Season   string
	Year     int32
	Status   string
	Limit    int32
	Offset   int32
}

// yieldRepository implements YieldRepository using pgxpool.
type yieldRepository struct {
	pool   *pgxpool.Pool
	logger *p9log.Helper
}

// NewYieldRepository creates a new YieldRepository instance.
func NewYieldRepository(d deps.ServiceDeps) YieldRepository {
	return &yieldRepository{
		pool:   d.Pool,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "YieldRepository")),
	}
}

// --- Predictions ---

func (r *yieldRepository) CreatePrediction(ctx context.Context, prediction *models.YieldPrediction) (*models.YieldPrediction, error) {
	prediction.UUID = ulid.NewString()
	prediction.CreatedAt = time.Now()
	prediction.IsActive = true
	prediction.Version = 1

	query := `
		INSERT INTO yield_predictions (
			uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
			status, soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7,
			$8, $9, $10,
			$11, $12, $13, $14,
			$15, $16, $17,
			$18, $19, $20, $21
		) RETURNING id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
			status, soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_by, updated_by, created_at, updated_at`

	var result models.YieldPrediction
	err := r.pool.QueryRow(ctx, query,
		prediction.UUID, prediction.TenantID, prediction.FarmID, prediction.FieldID,
		prediction.CropID, prediction.Season, prediction.Year,
		prediction.PredictedYieldKgPerHectare, prediction.PredictionConfidencePct, prediction.PredictionModelVersion,
		prediction.Status, prediction.SoilQualityScore, prediction.WeatherScore, prediction.IrrigationScore,
		prediction.PestPressureScore, prediction.NutrientScore, prediction.ManagementScore,
		prediction.IsActive, prediction.Version, prediction.CreatedBy, prediction.CreatedAt,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.PredictedYieldKgPerHectare, &result.PredictionConfidencePct, &result.PredictionModelVersion,
		&result.Status, &result.SoilQualityScore, &result.WeatherScore, &result.IrrigationScore,
		&result.PestPressureScore, &result.NutrientScore, &result.ManagementScore,
		&result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create yield prediction: %v", err)
		return nil, errors.Internal("failed to create yield prediction: %v", err)
	}

	return &result, nil
}

func (r *yieldRepository) GetPredictionByUUID(ctx context.Context, tenantID, uuid string) (*models.YieldPrediction, error) {
	query := `
		SELECT id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
			status, soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_by, updated_by, created_at, updated_at
		FROM yield_predictions
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE`

	var result models.YieldPrediction
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.PredictedYieldKgPerHectare, &result.PredictionConfidencePct, &result.PredictionModelVersion,
		&result.Status, &result.SoilQualityScore, &result.WeatherScore, &result.IrrigationScore,
		&result.PestPressureScore, &result.NutrientScore, &result.ManagementScore,
		&result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PREDICTION_NOT_FOUND", fmt.Sprintf("yield prediction %s not found", uuid))
		}
		r.logger.Errorf("failed to get yield prediction: %v", err)
		return nil, errors.Internal("failed to get yield prediction: %v", err)
	}

	return &result, nil
}

func (r *yieldRepository) ListPredictions(ctx context.Context, params *ListPredictionsParams) ([]*models.YieldPrediction, int64, error) {
	// Build dynamic where clause
	where := "tenant_id = $1 AND is_active = TRUE"
	args := []interface{}{params.TenantID}
	argIdx := 2

	if params.FarmID != "" {
		where += fmt.Sprintf(" AND farm_id = $%d", argIdx)
		args = append(args, params.FarmID)
		argIdx++
	}
	if params.FieldID != "" {
		where += fmt.Sprintf(" AND field_id = $%d", argIdx)
		args = append(args, params.FieldID)
		argIdx++
	}
	if params.CropID != "" {
		where += fmt.Sprintf(" AND crop_id = $%d", argIdx)
		args = append(args, params.CropID)
		argIdx++
	}
	if params.Season != "" {
		where += fmt.Sprintf(" AND season = $%d", argIdx)
		args = append(args, params.Season)
		argIdx++
	}
	if params.Year > 0 {
		where += fmt.Sprintf(" AND year = $%d", argIdx)
		args = append(args, params.Year)
		argIdx++
	}
	if params.Status != "" {
		where += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, params.Status)
		argIdx++
	}

	// Count query
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM yield_predictions WHERE %s", where)
	var totalCount int64
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount); err != nil {
		r.logger.Errorf("failed to count yield predictions: %v", err)
		return nil, 0, errors.Internal("failed to count yield predictions: %v", err)
	}

	// Data query
	dataQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
			status, soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_by, updated_by, created_at, updated_at
		FROM yield_predictions
		WHERE %s
		ORDER BY created_at DESC
		LIMIT $%d OFFSET $%d`, where, argIdx, argIdx+1)
	args = append(args, params.Limit, params.Offset)

	rows, err := r.pool.Query(ctx, dataQuery, args...)
	if err != nil {
		r.logger.Errorf("failed to list yield predictions: %v", err)
		return nil, 0, errors.Internal("failed to list yield predictions: %v", err)
	}
	defer rows.Close()

	var predictions []*models.YieldPrediction
	for rows.Next() {
		var p models.YieldPrediction
		if err := rows.Scan(
			&p.ID, &p.UUID, &p.TenantID, &p.FarmID, &p.FieldID,
			&p.CropID, &p.Season, &p.Year,
			&p.PredictedYieldKgPerHectare, &p.PredictionConfidencePct, &p.PredictionModelVersion,
			&p.Status, &p.SoilQualityScore, &p.WeatherScore, &p.IrrigationScore,
			&p.PestPressureScore, &p.NutrientScore, &p.ManagementScore,
			&p.IsActive, &p.Version, &p.CreatedBy, &p.UpdatedBy, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			r.logger.Errorf("failed to scan yield prediction: %v", err)
			return nil, 0, errors.Internal("failed to scan yield prediction: %v", err)
		}
		predictions = append(predictions, &p)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("failed to iterate yield predictions: %v", err)
	}

	return predictions, totalCount, nil
}

func (r *yieldRepository) UpdatePredictionStatus(ctx context.Context, tenantID, uuid, status, updatedBy string) (*models.YieldPrediction, error) {
	query := `
		UPDATE yield_predictions
		SET status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE
		RETURNING id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
			status, soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_by, updated_by, created_at, updated_at`

	var result models.YieldPrediction
	err := r.pool.QueryRow(ctx, query, uuid, tenantID, status, updatedBy).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.PredictedYieldKgPerHectare, &result.PredictionConfidencePct, &result.PredictionModelVersion,
		&result.Status, &result.SoilQualityScore, &result.WeatherScore, &result.IrrigationScore,
		&result.PestPressureScore, &result.NutrientScore, &result.ManagementScore,
		&result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PREDICTION_NOT_FOUND", fmt.Sprintf("yield prediction %s not found", uuid))
		}
		r.logger.Errorf("failed to update prediction status: %v", err)
		return nil, errors.Internal("failed to update prediction status: %v", err)
	}

	return &result, nil
}

// --- Yield Records ---

func (r *yieldRepository) CreateYieldRecord(ctx context.Context, record *models.YieldRecord) (*models.YieldRecord, error) {
	record.UUID = ulid.NewString()
	record.CreatedAt = time.Now()
	record.IsActive = true
	record.Version = 1

	// Compute profit
	record.ProfitPerHectare = record.RevenuePerHectare - record.CostPerHectare

	query := `
		INSERT INTO yield_records (
			uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			actual_yield_kg_per_hectare, total_area_harvested_hectares, total_yield_kg,
			harvest_quality_grade, moisture_content_pct, harvest_date,
			revenue_per_hectare, cost_per_hectare, profit_per_hectare,
			prediction_id, is_active, version, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7,
			$8, $9, $10,
			$11, $12, $13,
			$14, $15, $16,
			$17, $18, $19, $20, $21
		) RETURNING id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			actual_yield_kg_per_hectare, total_area_harvested_hectares, total_yield_kg,
			harvest_quality_grade, moisture_content_pct, harvest_date,
			revenue_per_hectare, cost_per_hectare, profit_per_hectare,
			prediction_id, is_active, version, created_by, updated_by, created_at, updated_at`

	var result models.YieldRecord
	err := r.pool.QueryRow(ctx, query,
		record.UUID, record.TenantID, record.FarmID, record.FieldID,
		record.CropID, record.Season, record.Year,
		record.ActualYieldKgPerHectare, record.TotalAreaHarvestedHectares, record.TotalYieldKg,
		record.HarvestQualityGrade, record.MoistureContentPct, record.HarvestDate,
		record.RevenuePerHectare, record.CostPerHectare, record.ProfitPerHectare,
		record.PredictionID, record.IsActive, record.Version, record.CreatedBy, record.CreatedAt,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.ActualYieldKgPerHectare, &result.TotalAreaHarvestedHectares, &result.TotalYieldKg,
		&result.HarvestQualityGrade, &result.MoistureContentPct, &result.HarvestDate,
		&result.RevenuePerHectare, &result.CostPerHectare, &result.ProfitPerHectare,
		&result.PredictionID, &result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy,
		&result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create yield record: %v", err)
		return nil, errors.Internal("failed to create yield record: %v", err)
	}

	return &result, nil
}

func (r *yieldRepository) GetYieldRecordByUUID(ctx context.Context, tenantID, uuid string) (*models.YieldRecord, error) {
	query := `
		SELECT id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			actual_yield_kg_per_hectare, total_area_harvested_hectares, total_yield_kg,
			harvest_quality_grade, moisture_content_pct, harvest_date,
			revenue_per_hectare, cost_per_hectare, profit_per_hectare,
			prediction_id, is_active, version, created_by, updated_by, created_at, updated_at
		FROM yield_records
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE`

	var result models.YieldRecord
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.ActualYieldKgPerHectare, &result.TotalAreaHarvestedHectares, &result.TotalYieldKg,
		&result.HarvestQualityGrade, &result.MoistureContentPct, &result.HarvestDate,
		&result.RevenuePerHectare, &result.CostPerHectare, &result.ProfitPerHectare,
		&result.PredictionID, &result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy,
		&result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("YIELD_RECORD_NOT_FOUND", fmt.Sprintf("yield record %s not found", uuid))
		}
		r.logger.Errorf("failed to get yield record: %v", err)
		return nil, errors.Internal("failed to get yield record: %v", err)
	}

	return &result, nil
}

func (r *yieldRepository) ListYieldRecords(ctx context.Context, params *ListYieldRecordsParams) ([]*models.YieldRecord, int64, error) {
	where := "tenant_id = $1 AND is_active = TRUE"
	args := []interface{}{params.TenantID}
	argIdx := 2

	if params.FarmID != "" {
		where += fmt.Sprintf(" AND farm_id = $%d", argIdx)
		args = append(args, params.FarmID)
		argIdx++
	}
	if params.FieldID != "" {
		where += fmt.Sprintf(" AND field_id = $%d", argIdx)
		args = append(args, params.FieldID)
		argIdx++
	}
	if params.CropID != "" {
		where += fmt.Sprintf(" AND crop_id = $%d", argIdx)
		args = append(args, params.CropID)
		argIdx++
	}
	if params.FromYear > 0 {
		where += fmt.Sprintf(" AND year >= $%d", argIdx)
		args = append(args, params.FromYear)
		argIdx++
	}
	if params.ToYear > 0 {
		where += fmt.Sprintf(" AND year <= $%d", argIdx)
		args = append(args, params.ToYear)
		argIdx++
	}

	// Count query
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM yield_records WHERE %s", where)
	var totalCount int64
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount); err != nil {
		r.logger.Errorf("failed to count yield records: %v", err)
		return nil, 0, errors.Internal("failed to count yield records: %v", err)
	}

	// Data query
	dataQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			actual_yield_kg_per_hectare, total_area_harvested_hectares, total_yield_kg,
			harvest_quality_grade, moisture_content_pct, harvest_date,
			revenue_per_hectare, cost_per_hectare, profit_per_hectare,
			prediction_id, is_active, version, created_by, updated_by, created_at, updated_at
		FROM yield_records
		WHERE %s
		ORDER BY year DESC, harvest_date DESC
		LIMIT $%d OFFSET $%d`, where, argIdx, argIdx+1)
	args = append(args, params.Limit, params.Offset)

	rows, err := r.pool.Query(ctx, dataQuery, args...)
	if err != nil {
		r.logger.Errorf("failed to list yield records: %v", err)
		return nil, 0, errors.Internal("failed to list yield records: %v", err)
	}
	defer rows.Close()

	var records []*models.YieldRecord
	for rows.Next() {
		var rec models.YieldRecord
		if err := rows.Scan(
			&rec.ID, &rec.UUID, &rec.TenantID, &rec.FarmID, &rec.FieldID,
			&rec.CropID, &rec.Season, &rec.Year,
			&rec.ActualYieldKgPerHectare, &rec.TotalAreaHarvestedHectares, &rec.TotalYieldKg,
			&rec.HarvestQualityGrade, &rec.MoistureContentPct, &rec.HarvestDate,
			&rec.RevenuePerHectare, &rec.CostPerHectare, &rec.ProfitPerHectare,
			&rec.PredictionID, &rec.IsActive, &rec.Version, &rec.CreatedBy, &rec.UpdatedBy,
			&rec.CreatedAt, &rec.UpdatedAt,
		); err != nil {
			r.logger.Errorf("failed to scan yield record: %v", err)
			return nil, 0, errors.Internal("failed to scan yield record: %v", err)
		}
		records = append(records, &rec)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("failed to iterate yield records: %v", err)
	}

	return records, totalCount, nil
}

func (r *yieldRepository) GetRegionalAverageYield(ctx context.Context, tenantID, cropID, season string) (float64, error) {
	query := `
		SELECT COALESCE(AVG(actual_yield_kg_per_hectare), 0)
		FROM yield_records
		WHERE tenant_id = $1 AND crop_id = $2 AND season = $3 AND is_active = TRUE`

	var avg float64
	if err := r.pool.QueryRow(ctx, query, tenantID, cropID, season).Scan(&avg); err != nil {
		r.logger.Errorf("failed to get regional average yield: %v", err)
		return 0, errors.Internal("failed to get regional average yield: %v", err)
	}

	return avg, nil
}

func (r *yieldRepository) GetHistoricalAverageYield(ctx context.Context, tenantID, farmID, fieldID, cropID string) (float64, error) {
	query := `
		SELECT COALESCE(AVG(actual_yield_kg_per_hectare), 0)
		FROM yield_records
		WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3 AND crop_id = $4 AND is_active = TRUE`

	var avg float64
	if err := r.pool.QueryRow(ctx, query, tenantID, farmID, fieldID, cropID).Scan(&avg); err != nil {
		r.logger.Errorf("failed to get historical average yield: %v", err)
		return 0, errors.Internal("failed to get historical average yield: %v", err)
	}

	return avg, nil
}

// --- Harvest Plans ---

func (r *yieldRepository) CreateHarvestPlan(ctx context.Context, plan *models.HarvestPlan) (*models.HarvestPlan, error) {
	plan.UUID = ulid.NewString()
	plan.CreatedAt = time.Now()
	plan.IsActive = true
	plan.Version = 1

	query := `
		INSERT INTO harvest_plans (
			uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			planned_start_date, planned_end_date, estimated_yield_kg,
			total_area_hectares, status, notes,
			is_active, version, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7,
			$8, $9, $10,
			$11, $12, $13,
			$14, $15, $16, $17
		) RETURNING id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			planned_start_date, planned_end_date, estimated_yield_kg,
			total_area_hectares, status, notes,
			is_active, version, created_by, updated_by, created_at, updated_at`

	var result models.HarvestPlan
	err := r.pool.QueryRow(ctx, query,
		plan.UUID, plan.TenantID, plan.FarmID, plan.FieldID,
		plan.CropID, plan.Season, plan.Year,
		plan.PlannedStartDate, plan.PlannedEndDate, plan.EstimatedYieldKg,
		plan.TotalAreaHectares, plan.Status, plan.Notes,
		plan.IsActive, plan.Version, plan.CreatedBy, plan.CreatedAt,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.PlannedStartDate, &result.PlannedEndDate, &result.EstimatedYieldKg,
		&result.TotalAreaHectares, &result.Status, &result.Notes,
		&result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy,
		&result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to create harvest plan: %v", err)
		return nil, errors.Internal("failed to create harvest plan: %v", err)
	}

	return &result, nil
}

func (r *yieldRepository) GetHarvestPlanByUUID(ctx context.Context, tenantID, uuid string) (*models.HarvestPlan, error) {
	query := `
		SELECT id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			planned_start_date, planned_end_date, estimated_yield_kg,
			total_area_hectares, status, notes,
			is_active, version, created_by, updated_by, created_at, updated_at
		FROM harvest_plans
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE`

	var result models.HarvestPlan
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.PlannedStartDate, &result.PlannedEndDate, &result.EstimatedYieldKg,
		&result.TotalAreaHectares, &result.Status, &result.Notes,
		&result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy,
		&result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("HARVEST_PLAN_NOT_FOUND", fmt.Sprintf("harvest plan %s not found", uuid))
		}
		r.logger.Errorf("failed to get harvest plan: %v", err)
		return nil, errors.Internal("failed to get harvest plan: %v", err)
	}

	return &result, nil
}

func (r *yieldRepository) ListHarvestPlans(ctx context.Context, params *ListHarvestPlansParams) ([]*models.HarvestPlan, int64, error) {
	where := "tenant_id = $1 AND is_active = TRUE"
	args := []interface{}{params.TenantID}
	argIdx := 2

	if params.FarmID != "" {
		where += fmt.Sprintf(" AND farm_id = $%d", argIdx)
		args = append(args, params.FarmID)
		argIdx++
	}
	if params.FieldID != "" {
		where += fmt.Sprintf(" AND field_id = $%d", argIdx)
		args = append(args, params.FieldID)
		argIdx++
	}
	if params.CropID != "" {
		where += fmt.Sprintf(" AND crop_id = $%d", argIdx)
		args = append(args, params.CropID)
		argIdx++
	}
	if params.Season != "" {
		where += fmt.Sprintf(" AND season = $%d", argIdx)
		args = append(args, params.Season)
		argIdx++
	}
	if params.Year > 0 {
		where += fmt.Sprintf(" AND year = $%d", argIdx)
		args = append(args, params.Year)
		argIdx++
	}
	if params.Status != "" {
		where += fmt.Sprintf(" AND status = $%d", argIdx)
		args = append(args, params.Status)
		argIdx++
	}

	// Count query
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM harvest_plans WHERE %s", where)
	var totalCount int64
	if err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount); err != nil {
		r.logger.Errorf("failed to count harvest plans: %v", err)
		return nil, 0, errors.Internal("failed to count harvest plans: %v", err)
	}

	// Data query
	dataQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			planned_start_date, planned_end_date, estimated_yield_kg,
			total_area_hectares, status, notes,
			is_active, version, created_by, updated_by, created_at, updated_at
		FROM harvest_plans
		WHERE %s
		ORDER BY planned_start_date ASC
		LIMIT $%d OFFSET $%d`, where, argIdx, argIdx+1)
	args = append(args, params.Limit, params.Offset)

	rows, err := r.pool.Query(ctx, dataQuery, args...)
	if err != nil {
		r.logger.Errorf("failed to list harvest plans: %v", err)
		return nil, 0, errors.Internal("failed to list harvest plans: %v", err)
	}
	defer rows.Close()

	var plans []*models.HarvestPlan
	for rows.Next() {
		var p models.HarvestPlan
		if err := rows.Scan(
			&p.ID, &p.UUID, &p.TenantID, &p.FarmID, &p.FieldID,
			&p.CropID, &p.Season, &p.Year,
			&p.PlannedStartDate, &p.PlannedEndDate, &p.EstimatedYieldKg,
			&p.TotalAreaHectares, &p.Status, &p.Notes,
			&p.IsActive, &p.Version, &p.CreatedBy, &p.UpdatedBy,
			&p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			r.logger.Errorf("failed to scan harvest plan: %v", err)
			return nil, 0, errors.Internal("failed to scan harvest plan: %v", err)
		}
		plans = append(plans, &p)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("failed to iterate harvest plans: %v", err)
	}

	return plans, totalCount, nil
}

func (r *yieldRepository) UpdateHarvestPlanStatus(ctx context.Context, tenantID, uuid, status, updatedBy string) (*models.HarvestPlan, error) {
	query := `
		UPDATE harvest_plans
		SET status = $3, updated_by = $4, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE
		RETURNING id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			planned_start_date, planned_end_date, estimated_yield_kg,
			total_area_hectares, status, notes,
			is_active, version, created_by, updated_by, created_at, updated_at`

	var result models.HarvestPlan
	err := r.pool.QueryRow(ctx, query, uuid, tenantID, status, updatedBy).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.PlannedStartDate, &result.PlannedEndDate, &result.EstimatedYieldKg,
		&result.TotalAreaHectares, &result.Status, &result.Notes,
		&result.IsActive, &result.Version, &result.CreatedBy, &result.UpdatedBy,
		&result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("HARVEST_PLAN_NOT_FOUND", fmt.Sprintf("harvest plan %s not found", uuid))
		}
		r.logger.Errorf("failed to update harvest plan status: %v", err)
		return nil, errors.Internal("failed to update harvest plan status: %v", err)
	}

	return &result, nil
}

// --- Crop Performance ---

func (r *yieldRepository) UpsertCropPerformance(ctx context.Context, perf *models.CropPerformance) (*models.CropPerformance, error) {
	if perf.UUID == "" {
		perf.UUID = ulid.NewString()
	}
	perf.CreatedAt = time.Now()
	perf.IsActive = true

	query := `
		INSERT INTO crop_performance (
			uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			actual_yield_kg_per_hectare, predicted_yield_kg_per_hectare,
			yield_variance_pct, comparison_to_regional_avg_pct,
			comparison_to_historical_avg_pct, revenue_per_hectare,
			cost_per_hectare, profit_per_hectare,
			soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7,
			$8, $9,
			$10, $11,
			$12, $13,
			$14, $15,
			$16, $17, $18,
			$19, $20, $21,
			TRUE, 1, NOW()
		)
		ON CONFLICT (tenant_id, farm_id, field_id, crop_id, season, year) DO UPDATE SET
			actual_yield_kg_per_hectare = EXCLUDED.actual_yield_kg_per_hectare,
			predicted_yield_kg_per_hectare = EXCLUDED.predicted_yield_kg_per_hectare,
			yield_variance_pct = EXCLUDED.yield_variance_pct,
			comparison_to_regional_avg_pct = EXCLUDED.comparison_to_regional_avg_pct,
			comparison_to_historical_avg_pct = EXCLUDED.comparison_to_historical_avg_pct,
			revenue_per_hectare = EXCLUDED.revenue_per_hectare,
			cost_per_hectare = EXCLUDED.cost_per_hectare,
			profit_per_hectare = EXCLUDED.profit_per_hectare,
			soil_quality_score = EXCLUDED.soil_quality_score,
			weather_score = EXCLUDED.weather_score,
			irrigation_score = EXCLUDED.irrigation_score,
			pest_pressure_score = EXCLUDED.pest_pressure_score,
			nutrient_score = EXCLUDED.nutrient_score,
			management_score = EXCLUDED.management_score,
			version = crop_performance.version + 1,
			updated_at = NOW()
		RETURNING id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			actual_yield_kg_per_hectare, predicted_yield_kg_per_hectare,
			yield_variance_pct, comparison_to_regional_avg_pct,
			comparison_to_historical_avg_pct, revenue_per_hectare,
			cost_per_hectare, profit_per_hectare,
			soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_at, updated_at`

	var result models.CropPerformance
	err := r.pool.QueryRow(ctx, query,
		perf.UUID, perf.TenantID, perf.FarmID, perf.FieldID, perf.CropID, perf.Season, perf.Year,
		perf.ActualYieldKgPerHectare, perf.PredictedYieldKgPerHectare,
		perf.YieldVariancePct, perf.ComparisonToRegionalAvgPct,
		perf.ComparisonToHistoricalAvgPct, perf.RevenuePerHectare,
		perf.CostPerHectare, perf.ProfitPerHectare,
		perf.SoilQualityScore, perf.WeatherScore, perf.IrrigationScore,
		perf.PestPressureScore, perf.NutrientScore, perf.ManagementScore,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.ActualYieldKgPerHectare, &result.PredictedYieldKgPerHectare,
		&result.YieldVariancePct, &result.ComparisonToRegionalAvgPct,
		&result.ComparisonToHistoricalAvgPct, &result.RevenuePerHectare,
		&result.CostPerHectare, &result.ProfitPerHectare,
		&result.SoilQualityScore, &result.WeatherScore, &result.IrrigationScore,
		&result.PestPressureScore, &result.NutrientScore, &result.ManagementScore,
		&result.IsActive, &result.Version, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("failed to upsert crop performance: %v", err)
		return nil, errors.Internal("failed to upsert crop performance: %v", err)
	}

	return &result, nil
}

func (r *yieldRepository) GetCropPerformance(ctx context.Context, tenantID, farmID, fieldID, cropID, season string, year int32) (*models.CropPerformance, error) {
	query := `
		SELECT id, uuid, tenant_id, farm_id, field_id, crop_id, season, year,
			actual_yield_kg_per_hectare, predicted_yield_kg_per_hectare,
			yield_variance_pct, comparison_to_regional_avg_pct,
			comparison_to_historical_avg_pct, revenue_per_hectare,
			cost_per_hectare, profit_per_hectare,
			soil_quality_score, weather_score, irrigation_score,
			pest_pressure_score, nutrient_score, management_score,
			is_active, version, created_at, updated_at
		FROM crop_performance
		WHERE tenant_id = $1 AND farm_id = $2 AND field_id = $3 AND crop_id = $4
			AND season = $5 AND year = $6 AND is_active = TRUE`

	var result models.CropPerformance
	err := r.pool.QueryRow(ctx, query, tenantID, farmID, fieldID, cropID, season, year).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FarmID, &result.FieldID,
		&result.CropID, &result.Season, &result.Year,
		&result.ActualYieldKgPerHectare, &result.PredictedYieldKgPerHectare,
		&result.YieldVariancePct, &result.ComparisonToRegionalAvgPct,
		&result.ComparisonToHistoricalAvgPct, &result.RevenuePerHectare,
		&result.CostPerHectare, &result.ProfitPerHectare,
		&result.SoilQualityScore, &result.WeatherScore, &result.IrrigationScore,
		&result.PestPressureScore, &result.NutrientScore, &result.ManagementScore,
		&result.IsActive, &result.Version, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_PERFORMANCE_NOT_FOUND",
				fmt.Sprintf("crop performance for crop %s, season %s, year %d not found", cropID, season, year))
		}
		r.logger.Errorf("failed to get crop performance: %v", err)
		return nil, errors.Internal("failed to get crop performance: %v", err)
	}

	return &result, nil
}

// Ensure unused import is used.
var _ = ptr.String
