// Package postgres implements the outbound.YieldRepository port using pgx.
package postgres

import (
	"context"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/outbound"
)

type yieldRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewYieldRepository creates a new postgres-backed YieldRepository.
func NewYieldRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.YieldRepository {
	return &yieldRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "YieldPostgresRepository")),
	}
}

func (r *yieldRepository) WithTx(tx pgx.Tx) outbound.YieldRepository {
	return &yieldRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *yieldRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *yieldRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *yieldRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------------------------------------------------------------------------
// Predictions
// ---------------------------------------------------------------------------

const predictionColumns = `id, tenant_id, farm_id, field_id, crop_id, season, year,
	predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
	status, factor_soil_quality_score, factor_weather_score, factor_irrigation_score,
	factor_pest_pressure_score, factor_nutrient_score, factor_management_score,
	version, created_by, updated_by, created_at, updated_at`

func scanPrediction(row pgx.Row) (*domain.YieldPrediction, error) {
	p := &domain.YieldPrediction{}
	err := row.Scan(
		&p.ID, &p.TenantID, &p.FarmID, &p.FieldID, &p.CropID, &p.Season, &p.Year,
		&p.PredictedYieldKgPerHectare, &p.PredictionConfidencePct, &p.PredictionModelVersion,
		&p.Status, &p.SoilQualityScore, &p.WeatherScore, &p.IrrigationScore,
		&p.PestPressureScore, &p.NutrientScore, &p.ManagementScore,
		&p.Version, &p.CreatedBy, &p.UpdatedBy, &p.CreatedAt, &p.UpdatedAt,
	)
	return p, err
}

func scanPredictionRows(rows pgx.Rows) ([]domain.YieldPrediction, error) {
	var result []domain.YieldPrediction
	for rows.Next() {
		p := domain.YieldPrediction{}
		if err := rows.Scan(
			&p.ID, &p.TenantID, &p.FarmID, &p.FieldID, &p.CropID, &p.Season, &p.Year,
			&p.PredictedYieldKgPerHectare, &p.PredictionConfidencePct, &p.PredictionModelVersion,
			&p.Status, &p.SoilQualityScore, &p.WeatherScore, &p.IrrigationScore,
			&p.PestPressureScore, &p.NutrientScore, &p.ManagementScore,
			&p.Version, &p.CreatedBy, &p.UpdatedBy, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, err
		}
		result = append(result, p)
	}
	return result, rows.Err()
}

func (r *yieldRepository) CreatePrediction(ctx context.Context, p *domain.YieldPrediction) (*domain.YieldPrediction, error) {
	p.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO yield_predictions (
			id, tenant_id, farm_id, field_id, crop_id, season, year,
			predicted_yield_kg_per_hectare, prediction_confidence_pct, prediction_model_version,
			status, factor_soil_quality_score, factor_weather_score, factor_irrigation_score,
			factor_pest_pressure_score, factor_nutrient_score, factor_management_score,
			created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
		RETURNING `+predictionColumns,
		p.ID, p.TenantID, p.FarmID, p.FieldID, p.CropID, p.Season, p.Year,
		p.PredictedYieldKgPerHectare, p.PredictionConfidencePct, p.PredictionModelVersion,
		p.Status, p.SoilQualityScore, p.WeatherScore, p.IrrigationScore,
		p.PestPressureScore, p.NutrientScore, p.ManagementScore,
		p.CreatedBy,
	)
	created, err := scanPrediction(row)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return created, nil
}

func (r *yieldRepository) GetPredictionByID(ctx context.Context, id, tenantID string) (*domain.YieldPrediction, error) {
	row := r.queryRow(ctx,
		`SELECT `+predictionColumns+`
		FROM yield_predictions
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		id, tenantID,
	)
	p, err := scanPrediction(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PREDICTION_NOT_FOUND", fmt.Sprintf("prediction not found: %s", id))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return p, nil
}

func (r *yieldRepository) ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.YieldPrediction, int32, error) {
	var (
		conditions []string
		countConds []string
		args       []any
		countArgs  []any
		argIdx     = 1
	)

	addFilter := func(col, val string) {
		cond := fmt.Sprintf("%s = $%d", col, argIdx)
		conditions = append(conditions, cond)
		countConds = append(countConds, cond)
		args = append(args, val)
		countArgs = append(countArgs, val)
		argIdx++
	}

	addFilter("tenant_id", params.TenantID)
	conditions = append(conditions, "deleted_at IS NULL")
	countConds = append(countConds, "deleted_at IS NULL")

	if params.FarmID != "" {
		addFilter("farm_id", params.FarmID)
	}
	if params.FieldID != "" {
		addFilter("field_id", params.FieldID)
	}
	if params.CropID != "" {
		addFilter("crop_id", params.CropID)
	}
	if params.Season != "" {
		addFilter("season", params.Season)
	}
	if params.Year > 0 {
		cond := fmt.Sprintf("year = $%d", argIdx)
		conditions = append(conditions, cond)
		countConds = append(countConds, cond)
		args = append(args, params.Year)
		countArgs = append(countArgs, params.Year)
		argIdx++
	}
	if params.Status != "" {
		addFilter("status", params.Status)
	}

	where := strings.Join(conditions, " AND ")
	countWhere := strings.Join(countConds, " AND ")

	// Count query
	var total int32
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM yield_predictions WHERE %s", countWhere)
	if err := r.queryRow(ctx, countSQL, countArgs...).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}

	// Data query
	dataSQL := fmt.Sprintf(
		"SELECT %s FROM yield_predictions WHERE %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		predictionColumns, where, argIdx, argIdx+1,
	)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, dataSQL, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	predictions, err := scanPredictionRows(rows)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return predictions, total, nil
}

// ---------------------------------------------------------------------------
// Yield Records
// ---------------------------------------------------------------------------

const recordColumns = `id, tenant_id, farm_id, field_id, crop_id, prediction_id, season, year,
	harvest_date, actual_yield_kg_per_hectare, total_area_harvested_hectares, total_yield_kg,
	harvest_quality_grade, moisture_content_pct, revenue_per_hectare, cost_per_hectare,
	profit_per_hectare, version, created_by, updated_by, created_at, updated_at`

func scanRecord(row pgx.Row) (*domain.YieldRecord, error) {
	r := &domain.YieldRecord{}
	err := row.Scan(
		&r.ID, &r.TenantID, &r.FarmID, &r.FieldID, &r.CropID, &r.PredictionID, &r.Season, &r.Year,
		&r.HarvestDate, &r.ActualYieldKgPerHectare, &r.TotalAreaHarvestedHectares, &r.TotalYieldKg,
		&r.HarvestQualityGrade, &r.MoistureContentPct, &r.RevenuePerHectare, &r.CostPerHectare,
		&r.ProfitPerHectare, &r.Version, &r.CreatedBy, &r.UpdatedBy, &r.CreatedAt, &r.UpdatedAt,
	)
	return r, err
}

func scanRecordRows(rows pgx.Rows) ([]domain.YieldRecord, error) {
	var result []domain.YieldRecord
	for rows.Next() {
		r := domain.YieldRecord{}
		if err := rows.Scan(
			&r.ID, &r.TenantID, &r.FarmID, &r.FieldID, &r.CropID, &r.PredictionID, &r.Season, &r.Year,
			&r.HarvestDate, &r.ActualYieldKgPerHectare, &r.TotalAreaHarvestedHectares, &r.TotalYieldKg,
			&r.HarvestQualityGrade, &r.MoistureContentPct, &r.RevenuePerHectare, &r.CostPerHectare,
			&r.ProfitPerHectare, &r.Version, &r.CreatedBy, &r.UpdatedBy, &r.CreatedAt, &r.UpdatedAt,
		); err != nil {
			return nil, err
		}
		result = append(result, r)
	}
	return result, rows.Err()
}

func (r *yieldRepository) CreateYieldRecord(ctx context.Context, rec *domain.YieldRecord) (*domain.YieldRecord, error) {
	rec.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO yield_records (
			id, tenant_id, farm_id, field_id, crop_id, prediction_id, season, year,
			harvest_date, actual_yield_kg_per_hectare, total_area_harvested_hectares, total_yield_kg,
			harvest_quality_grade, moisture_content_pct, revenue_per_hectare, cost_per_hectare,
			profit_per_hectare, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
		RETURNING `+recordColumns,
		rec.ID, rec.TenantID, rec.FarmID, rec.FieldID, rec.CropID, rec.PredictionID, rec.Season, rec.Year,
		rec.HarvestDate, rec.ActualYieldKgPerHectare, rec.TotalAreaHarvestedHectares, rec.TotalYieldKg,
		rec.HarvestQualityGrade, rec.MoistureContentPct, rec.RevenuePerHectare, rec.CostPerHectare,
		rec.ProfitPerHectare, rec.CreatedBy,
	)
	created, err := scanRecord(row)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return created, nil
}

func (r *yieldRepository) ListYieldRecords(ctx context.Context, params domain.YieldHistoryParams) ([]domain.YieldRecord, int32, error) {
	var (
		conditions []string
		countConds []string
		args       []any
		countArgs  []any
		argIdx     = 1
	)

	addFilter := func(col, val string) {
		cond := fmt.Sprintf("%s = $%d", col, argIdx)
		conditions = append(conditions, cond)
		countConds = append(countConds, cond)
		args = append(args, val)
		countArgs = append(countArgs, val)
		argIdx++
	}

	addFilter("tenant_id", params.TenantID)
	conditions = append(conditions, "deleted_at IS NULL")
	countConds = append(countConds, "deleted_at IS NULL")

	if params.FarmID != "" {
		addFilter("farm_id", params.FarmID)
	}
	if params.FieldID != "" {
		addFilter("field_id", params.FieldID)
	}
	if params.CropID != "" {
		addFilter("crop_id", params.CropID)
	}
	if params.FromYear > 0 {
		cond := fmt.Sprintf("year >= $%d", argIdx)
		conditions = append(conditions, cond)
		countConds = append(countConds, cond)
		args = append(args, params.FromYear)
		countArgs = append(countArgs, params.FromYear)
		argIdx++
	}
	if params.ToYear > 0 {
		cond := fmt.Sprintf("year <= $%d", argIdx)
		conditions = append(conditions, cond)
		countConds = append(countConds, cond)
		args = append(args, params.ToYear)
		countArgs = append(countArgs, params.ToYear)
		argIdx++
	}

	where := strings.Join(conditions, " AND ")
	countWhere := strings.Join(countConds, " AND ")

	var total int32
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM yield_records WHERE %s", countWhere)
	if err := r.queryRow(ctx, countSQL, countArgs...).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}

	dataSQL := fmt.Sprintf(
		"SELECT %s FROM yield_records WHERE %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		recordColumns, where, argIdx, argIdx+1,
	)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, dataSQL, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	records, err := scanRecordRows(rows)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return records, total, nil
}

// ---------------------------------------------------------------------------
// Harvest Plans
// ---------------------------------------------------------------------------

const planColumns = `id, tenant_id, farm_id, field_id, crop_id, season, year,
	planned_start_date, planned_end_date, estimated_yield_kg, total_area_hectares,
	status, notes, version, created_by, updated_by, created_at, updated_at`

func scanHarvestPlan(row pgx.Row) (*domain.HarvestPlan, error) {
	p := &domain.HarvestPlan{}
	err := row.Scan(
		&p.ID, &p.TenantID, &p.FarmID, &p.FieldID, &p.CropID, &p.Season, &p.Year,
		&p.PlannedStartDate, &p.PlannedEndDate, &p.EstimatedYieldKg, &p.TotalAreaHectares,
		&p.Status, &p.Notes, &p.Version, &p.CreatedBy, &p.UpdatedBy, &p.CreatedAt, &p.UpdatedAt,
	)
	return p, err
}

func scanHarvestPlanRows(rows pgx.Rows) ([]domain.HarvestPlan, error) {
	var result []domain.HarvestPlan
	for rows.Next() {
		p := domain.HarvestPlan{}
		if err := rows.Scan(
			&p.ID, &p.TenantID, &p.FarmID, &p.FieldID, &p.CropID, &p.Season, &p.Year,
			&p.PlannedStartDate, &p.PlannedEndDate, &p.EstimatedYieldKg, &p.TotalAreaHectares,
			&p.Status, &p.Notes, &p.Version, &p.CreatedBy, &p.UpdatedBy, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, err
		}
		result = append(result, p)
	}
	return result, rows.Err()
}

func (r *yieldRepository) CreateHarvestPlan(ctx context.Context, p *domain.HarvestPlan) (*domain.HarvestPlan, error) {
	p.ID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO harvest_plans (
			id, tenant_id, farm_id, field_id, crop_id, season, year,
			planned_start_date, planned_end_date, estimated_yield_kg, total_area_hectares,
			status, notes, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		RETURNING `+planColumns,
		p.ID, p.TenantID, p.FarmID, p.FieldID, p.CropID, p.Season, p.Year,
		p.PlannedStartDate, p.PlannedEndDate, p.EstimatedYieldKg, p.TotalAreaHectares,
		p.Status, p.Notes, p.CreatedBy,
	)
	created, err := scanHarvestPlan(row)
	if err != nil {
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return created, nil
}

func (r *yieldRepository) GetHarvestPlanByID(ctx context.Context, id, tenantID string) (*domain.HarvestPlan, error) {
	row := r.queryRow(ctx,
		`SELECT `+planColumns+`
		FROM harvest_plans
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
		id, tenantID,
	)
	p, err := scanHarvestPlan(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("HARVEST_PLAN_NOT_FOUND", fmt.Sprintf("harvest plan not found: %s", id))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return p, nil
}

func (r *yieldRepository) ListHarvestPlans(ctx context.Context, params domain.ListHarvestPlansParams) ([]domain.HarvestPlan, int32, error) {
	var (
		conditions []string
		countConds []string
		args       []any
		countArgs  []any
		argIdx     = 1
	)

	addFilter := func(col, val string) {
		cond := fmt.Sprintf("%s = $%d", col, argIdx)
		conditions = append(conditions, cond)
		countConds = append(countConds, cond)
		args = append(args, val)
		countArgs = append(countArgs, val)
		argIdx++
	}

	addFilter("tenant_id", params.TenantID)
	conditions = append(conditions, "deleted_at IS NULL")
	countConds = append(countConds, "deleted_at IS NULL")

	if params.FarmID != "" {
		addFilter("farm_id", params.FarmID)
	}
	if params.FieldID != "" {
		addFilter("field_id", params.FieldID)
	}
	if params.CropID != "" {
		addFilter("crop_id", params.CropID)
	}
	if params.Season != "" {
		addFilter("season", params.Season)
	}
	if params.Year > 0 {
		cond := fmt.Sprintf("year = $%d", argIdx)
		conditions = append(conditions, cond)
		countConds = append(countConds, cond)
		args = append(args, params.Year)
		countArgs = append(countArgs, params.Year)
		argIdx++
	}
	if params.Status != "" {
		addFilter("status", params.Status)
	}

	where := strings.Join(conditions, " AND ")
	countWhere := strings.Join(countConds, " AND ")

	var total int32
	countSQL := fmt.Sprintf("SELECT COUNT(*) FROM harvest_plans WHERE %s", countWhere)
	if err := r.queryRow(ctx, countSQL, countArgs...).Scan(&total); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}

	dataSQL := fmt.Sprintf(
		"SELECT %s FROM harvest_plans WHERE %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		planColumns, where, argIdx, argIdx+1,
	)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, dataSQL, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	plans, err := scanHarvestPlanRows(rows)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return plans, total, nil
}

// ---------------------------------------------------------------------------
// Crop Performance (computed from yield_records + yield_predictions)
// ---------------------------------------------------------------------------

func (r *yieldRepository) GetCropPerformance(ctx context.Context, params domain.CropPerformanceParams) (*domain.CropPerformance, error) {
	// Query the latest yield record for the given params.
	var (
		conditions []string
		args       []any
		argIdx     = 1
	)

	addFilter := func(col, val string) {
		conditions = append(conditions, fmt.Sprintf("%s = $%d", col, argIdx))
		args = append(args, val)
		argIdx++
	}

	addFilter("yr.tenant_id", params.TenantID)
	conditions = append(conditions, "yr.deleted_at IS NULL")

	if params.FarmID != "" {
		addFilter("yr.farm_id", params.FarmID)
	}
	if params.FieldID != "" {
		addFilter("yr.field_id", params.FieldID)
	}
	if params.CropID != "" {
		addFilter("yr.crop_id", params.CropID)
	}
	if params.Season != "" {
		addFilter("yr.season", params.Season)
	}
	if params.Year > 0 {
		conditions = append(conditions, fmt.Sprintf("yr.year = $%d", argIdx))
		args = append(args, params.Year)
		argIdx++
	}

	where := strings.Join(conditions, " AND ")

	sql := fmt.Sprintf(`
		SELECT
			yr.id, yr.tenant_id, yr.farm_id, yr.field_id, yr.crop_id, yr.season, yr.year,
			yr.actual_yield_kg_per_hectare,
			COALESCE(yp.predicted_yield_kg_per_hectare, 0),
			yr.revenue_per_hectare, yr.cost_per_hectare, yr.profit_per_hectare,
			COALESCE(yp.factor_soil_quality_score, 0),
			COALESCE(yp.factor_weather_score, 0),
			COALESCE(yp.factor_irrigation_score, 0),
			COALESCE(yp.factor_pest_pressure_score, 0),
			COALESCE(yp.factor_nutrient_score, 0),
			COALESCE(yp.factor_management_score, 0),
			yr.version, yr.created_at, yr.updated_at
		FROM yield_records yr
		LEFT JOIN yield_predictions yp
			ON yr.prediction_id = yp.id AND yp.deleted_at IS NULL
		WHERE %s
		ORDER BY yr.created_at DESC
		LIMIT 1
	`, where)

	cp := &domain.CropPerformance{}
	err := r.queryRow(ctx, sql, args...).Scan(
		&cp.ID, &cp.TenantID, &cp.FarmID, &cp.FieldID, &cp.CropID, &cp.Season, &cp.Year,
		&cp.ActualYieldKgPerHectare,
		&cp.PredictedYieldKgPerHectare,
		&cp.RevenuePerHectare, &cp.CostPerHectare, &cp.ProfitPerHectare,
		&cp.SoilQualityScore, &cp.WeatherScore, &cp.IrrigationScore,
		&cp.PestPressureScore, &cp.NutrientScore, &cp.ManagementScore,
		&cp.Version, &cp.CreatedAt, &cp.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_PERFORMANCE_NOT_FOUND", "no yield records found for the given criteria")
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}

	// Compute variance
	if cp.PredictedYieldKgPerHectare > 0 {
		cp.YieldVariancePct = (cp.ActualYieldKgPerHectare - cp.PredictedYieldKgPerHectare) / cp.PredictedYieldKgPerHectare * 100
	}

	return cp, nil
}
