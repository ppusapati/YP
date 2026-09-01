// Package postgres implements the outbound.PestRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/outbound"
)

type pestRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewPestRepository creates a new postgres-backed PestRepository.
func NewPestRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.PestRepository {
	return &pestRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "PestPostgresRepository")),
	}
}

func (r *pestRepository) WithTx(tx pgx.Tx) outbound.PestRepository {
	return &pestRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *pestRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *pestRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *pestRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------------------------------------------------------------------------
// Enum conversions: domain <-> DB
// ---------------------------------------------------------------------------

func riskLevelToDB(rl domain.RiskLevel) string {
	if rl == "" {
		return "RISK_LEVEL_UNSPECIFIED"
	}
	return "RISK_LEVEL_" + string(rl)
}

func riskLevelFromDB(s string) domain.RiskLevel {
	v := strings.TrimPrefix(s, "RISK_LEVEL_")
	if v == "UNSPECIFIED" || v == "" {
		return domain.RiskLevelUnspecified
	}
	return domain.RiskLevel(v)
}

func alertStatusToDB(s domain.AlertStatus) string {
	if s == "" {
		return "ALERT_STATUS_UNSPECIFIED"
	}
	return "ALERT_STATUS_" + string(s)
}

func alertStatusFromDB(s string) domain.AlertStatus {
	v := strings.TrimPrefix(s, "ALERT_STATUS_")
	if v == "UNSPECIFIED" || v == "" {
		return domain.AlertStatusUnspecified
	}
	return domain.AlertStatus(v)
}

func damageLevelToDB(d domain.DamageLevel) string {
	if d == "" {
		return "DAMAGE_LEVEL_UNSPECIFIED"
	}
	return "DAMAGE_LEVEL_" + string(d)
}

func damageLevelFromDB(s string) domain.DamageLevel {
	v := strings.TrimPrefix(s, "DAMAGE_LEVEL_")
	if v == "UNSPECIFIED" || v == "" {
		return domain.DamageLevelUnspecified
	}
	return domain.DamageLevel(v)
}

func growthStageToDB(g domain.GrowthStage) string {
	if g == "" {
		return "GROWTH_STAGE_UNSPECIFIED"
	}
	return "GROWTH_STAGE_" + string(g)
}

func growthStageFromDB(s string) domain.GrowthStage {
	v := strings.TrimPrefix(s, "GROWTH_STAGE_")
	if v == "UNSPECIFIED" || v == "" {
		return domain.GrowthStageUnspecified
	}
	return domain.GrowthStage(v)
}

// ---------------------------------------------------------------------------
// Predictions
// ---------------------------------------------------------------------------

const predictionColumns = `id, tenant_id, COALESCE(farm_id,''), COALESCE(field_id,''),
	COALESCE(pest_species_id,''), prediction_date, risk_level, risk_score, confidence_pct,
	COALESCE(crop_type,''), growth_stage, geographic_risk_factor, historical_occurrence_count,
	weather_temperature_celsius, weather_humidity_pct, weather_rainfall_mm, weather_wind_speed_kmh,
	predicted_onset_date, predicted_peak_date, treatment_window_start, treatment_window_end,
	recommended_treatments, version, COALESCE(created_by,''), created_at, updated_at`

func (r *pestRepository) CreatePrediction(ctx context.Context, p *domain.PestPrediction) (*domain.PestPrediction, error) {
	p.UUID = ulid.NewString()

	treatmentsJSON := json.RawMessage("[]")
	if len(p.RecommendedTreatments) > 0 {
		treatmentsJSON = p.RecommendedTreatments
	}

	var gsStr string
	if p.GrowthStage != nil {
		gsStr = growthStageToDB(*p.GrowthStage)
	} else {
		gsStr = "GROWTH_STAGE_UNSPECIFIED"
	}

	row := r.queryRow(ctx,
		`INSERT INTO pest_predictions (
			id, tenant_id, farm_id, field_id, pest_species_id,
			prediction_date, risk_level, risk_score, confidence_pct,
			crop_type, growth_stage, geographic_risk_factor, historical_occurrence_count,
			weather_temperature_celsius, weather_humidity_pct, weather_rainfall_mm, weather_wind_speed_kmh,
			predicted_onset_date, predicted_peak_date, treatment_window_start, treatment_window_end,
			recommended_treatments, created_by
		) VALUES (
			$1,$2,$3,$4,$5,
			$6,$7,$8,$9,
			$10,$11,$12,$13,
			$14,$15,$16,$17,
			$18,$19,$20,$21,
			$22,$23
		) RETURNING `+predictionColumns,
		p.UUID, p.TenantID, p.FarmID, p.FieldID, p.PestSpeciesUUID,
		p.PredictionDate, riskLevelToDB(p.RiskLevel), p.RiskScore, p.ConfidencePct,
		p.CropType, gsStr, p.GeographicRiskFactor, p.HistoricalOccurrenceCount,
		p.TemperatureCelsius, p.HumidityPct, p.RainfallMm, p.WindSpeedKmh,
		p.PredictedOnsetDate, p.PredictedPeakDate, p.TreatmentWindowStart, p.TreatmentWindowEnd,
		treatmentsJSON, p.CreatedBy,
	)

	return scanPrediction(row)
}

func (r *pestRepository) GetPredictionByID(ctx context.Context, id, tenantID string) (*domain.PestPrediction, error) {
	row := r.queryRow(ctx,
		`SELECT `+predictionColumns+`
		FROM pest_predictions WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
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

func (r *pestRepository) ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.PestPrediction, int32, error) {
	where := []string{"tenant_id = $1", "deleted_at IS NULL"}
	args := []any{params.TenantID}
	idx := 2

	if params.FarmID != nil && *params.FarmID != "" {
		where = append(where, fmt.Sprintf("farm_id = $%d", idx))
		args = append(args, *params.FarmID)
		idx++
	}
	if params.FieldID != nil && *params.FieldID != "" {
		where = append(where, fmt.Sprintf("field_id = $%d", idx))
		args = append(args, *params.FieldID)
		idx++
	}
	if params.PestSpeciesID != nil && *params.PestSpeciesID != "" {
		where = append(where, fmt.Sprintf("pest_species_id = $%d", idx))
		args = append(args, *params.PestSpeciesID)
		idx++
	}
	if params.MinRiskLevel != nil && *params.MinRiskLevel != "" {
		minSeverity := params.MinRiskLevel.Severity()
		levels := riskLevelsAboveSeverity(minSeverity)
		if len(levels) > 0 {
			placeholders := make([]string, len(levels))
			for i, l := range levels {
				placeholders[i] = fmt.Sprintf("$%d", idx)
				args = append(args, l)
				idx++
			}
			where = append(where, fmt.Sprintf("risk_level IN (%s)", strings.Join(placeholders, ",")))
		}
	}

	whereClause := strings.Join(where, " AND ")

	q := fmt.Sprintf(`SELECT %s, COUNT(*) OVER() AS full_count
		FROM pest_predictions WHERE %s
		ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		predictionColumns, whereClause, idx, idx+1)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, q, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var results []domain.PestPrediction
	var totalCount int32
	for rows.Next() {
		p, tc, err := scanPredictionWithCount(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		totalCount = tc
		results = append(results, *p)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return results, totalCount, nil
}

func (r *pestRepository) CountPredictionsBySpecies(ctx context.Context, pestSpeciesID, tenantID string) (int, error) {
	var count int
	err := r.queryRow(ctx,
		`SELECT COUNT(*) FROM pest_predictions WHERE pest_species_id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		pestSpeciesID, tenantID,
	).Scan(&count)
	if err != nil {
		return 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return count, nil
}

func scanPrediction(row pgx.Row) (*domain.PestPrediction, error) {
	p := &domain.PestPrediction{}
	var riskLevelStr, growthStageStr string
	var predictionDate, createdAt time.Time
	var updatedAt *time.Time
	var treatmentsRaw []byte

	err := row.Scan(
		&p.UUID, &p.TenantID, &p.FarmID, &p.FieldID,
		&p.PestSpeciesUUID, &predictionDate, &riskLevelStr, &p.RiskScore, &p.ConfidencePct,
		&p.CropType, &growthStageStr, &p.GeographicRiskFactor, &p.HistoricalOccurrenceCount,
		&p.TemperatureCelsius, &p.HumidityPct, &p.RainfallMm, &p.WindSpeedKmh,
		&p.PredictedOnsetDate, &p.PredictedPeakDate, &p.TreatmentWindowStart, &p.TreatmentWindowEnd,
		&treatmentsRaw, &p.Version, &p.CreatedBy, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	p.PredictionDate = predictionDate
	p.CreatedAt = createdAt
	p.UpdatedAt = updatedAt
	p.RiskLevel = riskLevelFromDB(riskLevelStr)
	gs := growthStageFromDB(growthStageStr)
	if gs != domain.GrowthStageUnspecified {
		p.GrowthStage = &gs
	}
	if len(treatmentsRaw) > 0 {
		p.RecommendedTreatments = json.RawMessage(treatmentsRaw)
	}

	return p, nil
}

func scanPredictionWithCount(rows pgx.Rows) (*domain.PestPrediction, int32, error) {
	p := &domain.PestPrediction{}
	var riskLevelStr, growthStageStr string
	var predictionDate, createdAt time.Time
	var updatedAt *time.Time
	var treatmentsRaw []byte
	var fullCount int32

	err := rows.Scan(
		&p.UUID, &p.TenantID, &p.FarmID, &p.FieldID,
		&p.PestSpeciesUUID, &predictionDate, &riskLevelStr, &p.RiskScore, &p.ConfidencePct,
		&p.CropType, &growthStageStr, &p.GeographicRiskFactor, &p.HistoricalOccurrenceCount,
		&p.TemperatureCelsius, &p.HumidityPct, &p.RainfallMm, &p.WindSpeedKmh,
		&p.PredictedOnsetDate, &p.PredictedPeakDate, &p.TreatmentWindowStart, &p.TreatmentWindowEnd,
		&treatmentsRaw, &p.Version, &p.CreatedBy, &createdAt, &updatedAt,
		&fullCount,
	)
	if err != nil {
		return nil, 0, err
	}

	p.PredictionDate = predictionDate
	p.CreatedAt = createdAt
	p.UpdatedAt = updatedAt
	p.RiskLevel = riskLevelFromDB(riskLevelStr)
	gs := growthStageFromDB(growthStageStr)
	if gs != domain.GrowthStageUnspecified {
		p.GrowthStage = &gs
	}
	if len(treatmentsRaw) > 0 {
		p.RecommendedTreatments = json.RawMessage(treatmentsRaw)
	}

	return p, fullCount, nil
}

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------

const alertColumns = `id, tenant_id, COALESCE(prediction_id,''), COALESCE(farm_id,''),
	COALESCE(field_id,''), COALESCE(pest_species_id,''), risk_level, status,
	title, COALESCE(message,''), acknowledged_at, acknowledged_by,
	version, created_at, updated_at`

func (r *pestRepository) CreateAlert(ctx context.Context, a *domain.PestAlert) (*domain.PestAlert, error) {
	a.UUID = ulid.NewString()

	row := r.queryRow(ctx,
		`INSERT INTO pest_alerts (
			id, tenant_id, prediction_id, farm_id, field_id, pest_species_id,
			risk_level, status, title, message
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		RETURNING `+alertColumns,
		a.UUID, a.TenantID, a.PredictionUUID, a.FarmID, a.FieldID, a.PestSpeciesUUID,
		riskLevelToDB(a.RiskLevel), alertStatusToDB(a.Status), a.Title, a.Message,
	)

	return scanAlert(row)
}

func (r *pestRepository) GetAlertByID(ctx context.Context, id, tenantID string) (*domain.PestAlert, error) {
	row := r.queryRow(ctx,
		`SELECT `+alertColumns+`
		FROM pest_alerts WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		id, tenantID,
	)
	a, err := scanAlert(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("alert not found: %s", id))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return a, nil
}

func (r *pestRepository) ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PestAlert, int32, error) {
	where := []string{"tenant_id = $1", "deleted_at IS NULL"}
	args := []any{params.TenantID}
	idx := 2

	if params.FarmID != nil && *params.FarmID != "" {
		where = append(where, fmt.Sprintf("farm_id = $%d", idx))
		args = append(args, *params.FarmID)
		idx++
	}
	if params.FieldID != nil && *params.FieldID != "" {
		where = append(where, fmt.Sprintf("field_id = $%d", idx))
		args = append(args, *params.FieldID)
		idx++
	}
	if params.Status != nil && *params.Status != "" {
		where = append(where, fmt.Sprintf("status = $%d", idx))
		args = append(args, alertStatusToDB(*params.Status))
		idx++
	}
	if params.MinRiskLevel != nil && *params.MinRiskLevel != "" {
		minSeverity := params.MinRiskLevel.Severity()
		levels := riskLevelsAboveSeverity(minSeverity)
		if len(levels) > 0 {
			placeholders := make([]string, len(levels))
			for i, l := range levels {
				placeholders[i] = fmt.Sprintf("$%d", idx)
				args = append(args, l)
				idx++
			}
			where = append(where, fmt.Sprintf("risk_level IN (%s)", strings.Join(placeholders, ",")))
		}
	}

	whereClause := strings.Join(where, " AND ")

	q := fmt.Sprintf(`SELECT %s, COUNT(*) OVER() AS full_count
		FROM pest_alerts WHERE %s
		ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		alertColumns, whereClause, idx, idx+1)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, q, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var results []domain.PestAlert
	var totalCount int32
	for rows.Next() {
		a, tc, err := scanAlertWithCount(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		totalCount = tc
		results = append(results, *a)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return results, totalCount, nil
}

func (r *pestRepository) AcknowledgeAlert(ctx context.Context, id, tenantID, userID string) (*domain.PestAlert, error) {
	row := r.queryRow(ctx,
		`UPDATE pest_alerts SET
			status=$1, acknowledged_at=NOW(), acknowledged_by=$2, version=version+1
		WHERE id=$3 AND tenant_id=$4 AND deleted_at IS NULL
		RETURNING `+alertColumns,
		alertStatusToDB(domain.AlertStatusAcknowledged), userID, id, tenantID,
	)
	a, err := scanAlert(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("alert not found: %s", id))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return a, nil
}

func scanAlert(row pgx.Row) (*domain.PestAlert, error) {
	a := &domain.PestAlert{}
	var riskLevelStr, statusStr string
	var createdAt time.Time
	var updatedAt *time.Time

	err := row.Scan(
		&a.UUID, &a.TenantID, &a.PredictionUUID, &a.FarmID,
		&a.FieldID, &a.PestSpeciesUUID, &riskLevelStr, &statusStr,
		&a.Title, &a.Message, &a.AcknowledgedAt, &a.AcknowledgedBy,
		&a.Version, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	a.CreatedAt = createdAt
	a.UpdatedAt = updatedAt
	a.RiskLevel = riskLevelFromDB(riskLevelStr)
	a.Status = alertStatusFromDB(statusStr)

	return a, nil
}

func scanAlertWithCount(rows pgx.Rows) (*domain.PestAlert, int32, error) {
	a := &domain.PestAlert{}
	var riskLevelStr, statusStr string
	var createdAt time.Time
	var updatedAt *time.Time
	var fullCount int32

	err := rows.Scan(
		&a.UUID, &a.TenantID, &a.PredictionUUID, &a.FarmID,
		&a.FieldID, &a.PestSpeciesUUID, &riskLevelStr, &statusStr,
		&a.Title, &a.Message, &a.AcknowledgedAt, &a.AcknowledgedBy,
		&a.Version, &createdAt, &updatedAt,
		&fullCount,
	)
	if err != nil {
		return nil, 0, err
	}

	a.CreatedAt = createdAt
	a.UpdatedAt = updatedAt
	a.RiskLevel = riskLevelFromDB(riskLevelStr)
	a.Status = alertStatusFromDB(statusStr)

	return a, fullCount, nil
}

// ---------------------------------------------------------------------------
// Observations
// ---------------------------------------------------------------------------

const observationColumns = `id, tenant_id, COALESCE(farm_id,''), COALESCE(field_id,''),
	COALESCE(pest_species_id,''), pest_count, damage_level,
	trap_type, image_url, latitude, longitude, notes,
	COALESCE(observed_by,''), COALESCE(observed_at, created_at),
	version, created_at, updated_at`

func (r *pestRepository) CreateObservation(ctx context.Context, o *domain.PestObservation) (*domain.PestObservation, error) {
	o.UUID = ulid.NewString()

	row := r.queryRow(ctx,
		`INSERT INTO pest_observations (
			id, tenant_id, farm_id, field_id, pest_species_id,
			pest_count, damage_level, trap_type, image_url,
			latitude, longitude, notes, observed_by, observed_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		RETURNING `+observationColumns,
		o.UUID, o.TenantID, o.FarmID, o.FieldID, o.PestSpeciesUUID,
		o.PestCount, damageLevelToDB(o.DamageLevel), o.TrapType, o.ImageURL,
		o.Latitude, o.Longitude, o.Notes, o.ObservedBy, o.ObservedAt,
	)

	return scanObservation(row)
}

func (r *pestRepository) ListObservations(ctx context.Context, params domain.ListObservationsParams) ([]domain.PestObservation, int32, error) {
	where := []string{"tenant_id = $1", "deleted_at IS NULL"}
	args := []any{params.TenantID}
	idx := 2

	if params.FarmID != nil && *params.FarmID != "" {
		where = append(where, fmt.Sprintf("farm_id = $%d", idx))
		args = append(args, *params.FarmID)
		idx++
	}
	if params.FieldID != nil && *params.FieldID != "" {
		where = append(where, fmt.Sprintf("field_id = $%d", idx))
		args = append(args, *params.FieldID)
		idx++
	}
	if params.PestSpeciesID != nil && *params.PestSpeciesID != "" {
		where = append(where, fmt.Sprintf("pest_species_id = $%d", idx))
		args = append(args, *params.PestSpeciesID)
		idx++
	}

	whereClause := strings.Join(where, " AND ")

	q := fmt.Sprintf(`SELECT %s, COUNT(*) OVER() AS full_count
		FROM pest_observations WHERE %s
		ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		observationColumns, whereClause, idx, idx+1)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, q, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var results []domain.PestObservation
	var totalCount int32
	for rows.Next() {
		o, tc, err := scanObservationWithCount(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		totalCount = tc
		results = append(results, *o)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return results, totalCount, nil
}

func scanObservation(row pgx.Row) (*domain.PestObservation, error) {
	o := &domain.PestObservation{}
	var damageLevelStr string
	var observedAt, createdAt time.Time
	var updatedAt *time.Time

	err := row.Scan(
		&o.UUID, &o.TenantID, &o.FarmID, &o.FieldID,
		&o.PestSpeciesUUID, &o.PestCount, &damageLevelStr,
		&o.TrapType, &o.ImageURL, &o.Latitude, &o.Longitude, &o.Notes,
		&o.ObservedBy, &observedAt,
		&o.Version, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	o.ObservedAt = observedAt
	o.CreatedAt = createdAt
	o.UpdatedAt = updatedAt
	o.DamageLevel = damageLevelFromDB(damageLevelStr)

	return o, nil
}

func scanObservationWithCount(rows pgx.Rows) (*domain.PestObservation, int32, error) {
	o := &domain.PestObservation{}
	var damageLevelStr string
	var observedAt, createdAt time.Time
	var updatedAt *time.Time
	var fullCount int32

	err := rows.Scan(
		&o.UUID, &o.TenantID, &o.FarmID, &o.FieldID,
		&o.PestSpeciesUUID, &o.PestCount, &damageLevelStr,
		&o.TrapType, &o.ImageURL, &o.Latitude, &o.Longitude, &o.Notes,
		&o.ObservedBy, &observedAt,
		&o.Version, &createdAt, &updatedAt,
		&fullCount,
	)
	if err != nil {
		return nil, 0, err
	}

	o.ObservedAt = observedAt
	o.CreatedAt = createdAt
	o.UpdatedAt = updatedAt
	o.DamageLevel = damageLevelFromDB(damageLevelStr)

	return o, fullCount, nil
}

// ---------------------------------------------------------------------------
// Species
// ---------------------------------------------------------------------------

const speciesColumns = `id, tenant_id, common_name, COALESCE(scientific_name,''),
	family, description, affected_crops, favorable_conditions,
	image_url, version, created_at, updated_at`

func (r *pestRepository) GetSpeciesByID(ctx context.Context, id, tenantID string) (*domain.PestSpecies, error) {
	row := r.queryRow(ctx,
		`SELECT `+speciesColumns+`
		FROM pest_species WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		id, tenantID,
	)
	s, err := scanSpecies(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SPECIES_NOT_FOUND", fmt.Sprintf("pest species not found: %s", id))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return s, nil
}

func (r *pestRepository) ListSpecies(ctx context.Context, params domain.ListPestSpeciesParams) ([]domain.PestSpecies, int32, error) {
	where := []string{"tenant_id = $1", "deleted_at IS NULL"}
	args := []any{params.TenantID}
	idx := 2

	if params.Search != nil && *params.Search != "" {
		where = append(where, fmt.Sprintf("(common_name ILIKE $%d OR scientific_name ILIKE $%d)", idx, idx))
		args = append(args, "%"+*params.Search+"%")
		idx++
	}
	if params.CropType != nil && *params.CropType != "" {
		where = append(where, fmt.Sprintf("$%d = ANY(affected_crops)", idx))
		args = append(args, *params.CropType)
		idx++
	}

	whereClause := strings.Join(where, " AND ")

	q := fmt.Sprintf(`SELECT %s, COUNT(*) OVER() AS full_count
		FROM pest_species WHERE %s
		ORDER BY common_name ASC LIMIT $%d OFFSET $%d`,
		speciesColumns, whereClause, idx, idx+1)
	args = append(args, params.PageSize, params.Offset)

	rows, err := r.query(ctx, q, args...)
	if err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	defer rows.Close()

	var results []domain.PestSpecies
	var totalCount int32
	for rows.Next() {
		s, tc, err := scanSpeciesWithCount(rows)
		if err != nil {
			return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
		}
		totalCount = tc
		results = append(results, *s)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("DB_ERROR", err.Error())
	}
	return results, totalCount, nil
}

func scanSpecies(row pgx.Row) (*domain.PestSpecies, error) {
	s := &domain.PestSpecies{}
	var createdAt time.Time
	var updatedAt *time.Time
	var affectedCrops, favorableConditions []string

	err := row.Scan(
		&s.UUID, &s.TenantID, &s.CommonName, &s.ScientificName,
		&s.Family, &s.Description, &affectedCrops, &favorableConditions,
		&s.ImageURL, &s.Version, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	s.CreatedAt = createdAt
	s.UpdatedAt = updatedAt

	if len(affectedCrops) > 0 {
		raw, _ := json.Marshal(affectedCrops)
		s.AffectedCrops = raw
	}
	if len(favorableConditions) > 0 {
		raw, _ := json.Marshal(favorableConditions)
		s.FavorableConditions = raw
	}

	return s, nil
}

func scanSpeciesWithCount(rows pgx.Rows) (*domain.PestSpecies, int32, error) {
	s := &domain.PestSpecies{}
	var createdAt time.Time
	var updatedAt *time.Time
	var affectedCrops, favorableConditions []string
	var fullCount int32

	err := rows.Scan(
		&s.UUID, &s.TenantID, &s.CommonName, &s.ScientificName,
		&s.Family, &s.Description, &affectedCrops, &favorableConditions,
		&s.ImageURL, &s.Version, &createdAt, &updatedAt,
		&fullCount,
	)
	if err != nil {
		return nil, 0, err
	}

	s.CreatedAt = createdAt
	s.UpdatedAt = updatedAt

	if len(affectedCrops) > 0 {
		raw, _ := json.Marshal(affectedCrops)
		s.AffectedCrops = raw
	}
	if len(favorableConditions) > 0 {
		raw, _ := json.Marshal(favorableConditions)
		s.FavorableConditions = raw
	}

	return s, fullCount, nil
}

// ---------------------------------------------------------------------------
// Risk Maps
// ---------------------------------------------------------------------------

const riskMapColumns = `id, tenant_id, COALESCE(pest_species_id,''), COALESCE(region,''),
	overall_risk_level, COALESCE(geojson,''), valid_from, valid_until,
	version, created_at, updated_at`

func (r *pestRepository) GetRiskMap(ctx context.Context, pestSpeciesID, region, tenantID string) (*domain.PestRiskMap, error) {
	row := r.queryRow(ctx,
		`SELECT `+riskMapColumns+`
		FROM pest_risk_maps
		WHERE pest_species_id=$1 AND region=$2 AND tenant_id=$3 AND deleted_at IS NULL
		ORDER BY created_at DESC LIMIT 1`,
		pestSpeciesID, region, tenantID,
	)
	m, err := scanRiskMap(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("RISK_MAP_NOT_FOUND",
				fmt.Sprintf("risk map not found for species %s in region %s", pestSpeciesID, region))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return m, nil
}

func scanRiskMap(row pgx.Row) (*domain.PestRiskMap, error) {
	m := &domain.PestRiskMap{}
	var riskLevelStr string
	var createdAt time.Time
	var updatedAt *time.Time
	var validFrom, validUntil time.Time

	err := row.Scan(
		&m.UUID, &m.TenantID, &m.PestSpeciesUUID, &m.Region,
		&riskLevelStr, &m.GeoJSON, &validFrom, &validUntil,
		&m.Version, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}

	m.ValidFrom = validFrom
	m.ValidUntil = validUntil
	m.CreatedAt = createdAt
	m.UpdatedAt = updatedAt
	m.OverallRiskLevel = riskLevelFromDB(riskLevelStr)

	return m, nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func riskLevelsAboveSeverity(minSeverity int) []string {
	var levels []string
	allLevels := []struct {
		severity int
		dbValue  string
	}{
		{0, "RISK_LEVEL_NONE"},
		{1, "RISK_LEVEL_LOW"},
		{2, "RISK_LEVEL_MODERATE"},
		{3, "RISK_LEVEL_HIGH"},
		{4, "RISK_LEVEL_CRITICAL"},
	}
	for _, l := range allLevels {
		if l.severity >= minSeverity {
			levels = append(levels, l.dbValue)
		}
	}
	return levels
}
