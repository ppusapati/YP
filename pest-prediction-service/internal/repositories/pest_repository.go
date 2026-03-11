package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	pestmodels "p9e.in/samavaya/agriculture/pest-prediction-service/internal/models"
)

// PestRepository defines the interface for pest prediction data access.
type PestRepository interface {
	// Pest species
	CreatePestSpecies(ctx context.Context, species *pestmodels.PestSpecies) (*pestmodels.PestSpecies, error)
	GetPestSpeciesByUUID(ctx context.Context, tenantID, uuid string) (*pestmodels.PestSpecies, error)
	ListPestSpecies(ctx context.Context, params *pestmodels.ListPestSpeciesParams) ([]pestmodels.PestSpecies, int64, error)

	// Predictions
	CreatePrediction(ctx context.Context, prediction *pestmodels.PestPrediction) (*pestmodels.PestPrediction, error)
	GetPredictionByUUID(ctx context.Context, tenantID, uuid string) (*pestmodels.PestPrediction, error)
	ListPredictions(ctx context.Context, params *pestmodels.ListPredictionsParams) ([]pestmodels.PestPrediction, int64, error)
	GetHistoricalOccurrenceCount(ctx context.Context, tenantID, farmID, pestSpeciesUUID string) (int64, error)

	// Alerts
	CreateAlert(ctx context.Context, alert *pestmodels.PestAlert) (*pestmodels.PestAlert, error)
	ListAlerts(ctx context.Context, params *pestmodels.ListAlertsParams) ([]pestmodels.PestAlert, int64, error)
	AcknowledgeAlert(ctx context.Context, tenantID, uuid, userID string) (*pestmodels.PestAlert, error)

	// Observations
	CreateObservation(ctx context.Context, observation *pestmodels.PestObservation) (*pestmodels.PestObservation, error)
	ListObservations(ctx context.Context, params *pestmodels.ListObservationsParams) ([]pestmodels.PestObservation, int64, error)
	GetRecentObservationsBySpecies(ctx context.Context, tenantID, farmID, pestSpeciesUUID string) ([]pestmodels.PestObservation, error)

	// Treatments
	CreateTreatment(ctx context.Context, treatment *pestmodels.PestTreatment) (*pestmodels.PestTreatment, error)
	ListTreatmentsByPrediction(ctx context.Context, tenantID, predictionUUID string) ([]pestmodels.PestTreatment, error)

	// Risk maps
	GetRiskMap(ctx context.Context, tenantID, pestSpeciesUUID, region string) (*pestmodels.PestRiskMap, error)
	UpsertRiskMap(ctx context.Context, riskMap *pestmodels.PestRiskMap) (*pestmodels.PestRiskMap, error)
}

// pestRepository implements PestRepository using pgx.
type pestRepository struct {
	pool *pgxpool.Pool
	log  p9log.Logger
}

// NewPestRepository creates a new PestRepository.
func NewPestRepository(d deps.ServiceDeps) PestRepository {
	return &pestRepository{
		pool: d.Pool,
		log:  d.Log,
	}
}

// ---------------------------------------------------------------------------
// Pest Species
// ---------------------------------------------------------------------------

func (r *pestRepository) CreatePestSpecies(ctx context.Context, species *pestmodels.PestSpecies) (*pestmodels.PestSpecies, error) {
	species.UUID = ulid.NewString()

	affectedCrops := jsonDefault(species.AffectedCrops, "[]")
	favorableConditions := jsonDefault(species.FavorableConditions, "[]")

	row := r.pool.QueryRow(ctx,
		`INSERT INTO pest_species (
			uuid, tenant_id, common_name, scientific_name, family,
			description, affected_crops, favorable_conditions, image_url,
			version, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,1,TRUE,$10,NOW())
		RETURNING id, uuid, tenant_id, common_name, scientific_name, family,
			description, affected_crops, favorable_conditions, image_url,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		species.UUID, species.TenantID, species.CommonName, species.ScientificName, species.Family,
		species.Description, affectedCrops, favorableConditions, species.ImageURL,
		species.CreatedBy,
	)

	result := &pestmodels.PestSpecies{}
	if err := scanPestSpecies(row, result); err != nil {
		return nil, errors.Internal("failed to create pest species: %v", err)
	}
	return result, nil
}

func (r *pestRepository) GetPestSpeciesByUUID(ctx context.Context, tenantID, uuid string) (*pestmodels.PestSpecies, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, uuid, tenant_id, common_name, scientific_name, family,
			description, affected_crops, favorable_conditions, image_url,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_species
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	result := &pestmodels.PestSpecies{}
	if err := scanPestSpecies(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PEST_SPECIES_NOT_FOUND", fmt.Sprintf("pest species %s not found", uuid))
		}
		return nil, errors.Internal("failed to get pest species: %v", err)
	}
	return result, nil
}

func (r *pestRepository) ListPestSpecies(ctx context.Context, params *pestmodels.ListPestSpeciesParams) ([]pestmodels.PestSpecies, int64, error) {
	// Count
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM pest_species
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR common_name ILIKE '%' || $2::VARCHAR || '%' OR scientific_name ILIKE '%' || $2::VARCHAR || '%')`,
		params.TenantID, params.Search,
	).Scan(&count)
	if err != nil {
		return nil, 0, errors.Internal("failed to count pest species: %v", err)
	}

	// List
	rows, err := r.pool.Query(ctx,
		`SELECT id, uuid, tenant_id, common_name, scientific_name, family,
			description, affected_crops, favorable_conditions, image_url,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_species
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR common_name ILIKE '%' || $2::VARCHAR || '%' OR scientific_name ILIKE '%' || $2::VARCHAR || '%')
		ORDER BY common_name ASC
		LIMIT $3 OFFSET $4`,
		params.TenantID, params.Search, params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.Internal("failed to list pest species: %v", err)
	}
	defer rows.Close()

	var results []pestmodels.PestSpecies
	for rows.Next() {
		var s pestmodels.PestSpecies
		if err := scanPestSpeciesRow(rows, &s); err != nil {
			return nil, 0, errors.Internal("failed to scan pest species: %v", err)
		}
		results = append(results, s)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("error iterating pest species: %v", err)
	}

	return results, count, nil
}

// ---------------------------------------------------------------------------
// Predictions
// ---------------------------------------------------------------------------

func (r *pestRepository) CreatePrediction(ctx context.Context, prediction *pestmodels.PestPrediction) (*pestmodels.PestPrediction, error) {
	prediction.UUID = ulid.NewString()

	treatmentsJSON := jsonDefault(prediction.RecommendedTreatments, "[]")

	row := r.pool.QueryRow(ctx,
		`INSERT INTO pest_predictions (
			uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			prediction_date, risk_level, risk_score, confidence_pct,
			temperature_celsius, humidity_pct, rainfall_mm, wind_speed_kmh,
			crop_type, growth_stage, geographic_risk_factor, historical_occurrence_count,
			predicted_onset_date, predicted_peak_date,
			treatment_window_start, treatment_window_end,
			recommended_treatments,
			version, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,NOW(),$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,1,TRUE,$23,NOW())
		RETURNING id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			prediction_date, risk_level, risk_score, confidence_pct,
			temperature_celsius, humidity_pct, rainfall_mm, wind_speed_kmh,
			crop_type, growth_stage, geographic_risk_factor, historical_occurrence_count,
			predicted_onset_date, predicted_peak_date,
			treatment_window_start, treatment_window_end,
			recommended_treatments,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		prediction.UUID, prediction.TenantID, prediction.FarmID, prediction.FieldID,
		prediction.PestSpeciesID, prediction.PestSpeciesUUID,
		string(prediction.RiskLevel), prediction.RiskScore, prediction.ConfidencePct,
		prediction.TemperatureCelsius, prediction.HumidityPct, prediction.RainfallMm, prediction.WindSpeedKmh,
		prediction.CropType, prediction.GrowthStage, prediction.GeographicRiskFactor, prediction.HistoricalOccurrenceCount,
		prediction.PredictedOnsetDate, prediction.PredictedPeakDate,
		prediction.TreatmentWindowStart, prediction.TreatmentWindowEnd,
		treatmentsJSON,
		prediction.CreatedBy,
	)

	result := &pestmodels.PestPrediction{}
	if err := scanPestPrediction(row, result); err != nil {
		return nil, errors.Internal("failed to create prediction: %v", err)
	}
	return result, nil
}

func (r *pestRepository) GetPredictionByUUID(ctx context.Context, tenantID, uuid string) (*pestmodels.PestPrediction, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			prediction_date, risk_level, risk_score, confidence_pct,
			temperature_celsius, humidity_pct, rainfall_mm, wind_speed_kmh,
			crop_type, growth_stage, geographic_risk_factor, historical_occurrence_count,
			predicted_onset_date, predicted_peak_date,
			treatment_window_start, treatment_window_end,
			recommended_treatments,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_predictions
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	result := &pestmodels.PestPrediction{}
	if err := scanPestPrediction(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PREDICTION_NOT_FOUND", fmt.Sprintf("prediction %s not found", uuid))
		}
		return nil, errors.Internal("failed to get prediction: %v", err)
	}
	return result, nil
}

func (r *pestRepository) ListPredictions(ctx context.Context, params *pestmodels.ListPredictionsParams) ([]pestmodels.PestPrediction, int64, error) {
	// Count
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM pest_predictions
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR farm_id = $2::VARCHAR)
		AND ($3::VARCHAR IS NULL OR field_id = $3::VARCHAR)
		AND ($4::VARCHAR IS NULL OR pest_species_uuid = $4::VARCHAR)
		AND ($5::risk_level IS NULL OR risk_level >= $5::risk_level)`,
		params.TenantID, params.FarmID, params.FieldID, params.PestSpeciesID, params.MinRiskLevel,
	).Scan(&count)
	if err != nil {
		return nil, 0, errors.Internal("failed to count predictions: %v", err)
	}

	// List
	rows, err := r.pool.Query(ctx,
		`SELECT id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			prediction_date, risk_level, risk_score, confidence_pct,
			temperature_celsius, humidity_pct, rainfall_mm, wind_speed_kmh,
			crop_type, growth_stage, geographic_risk_factor, historical_occurrence_count,
			predicted_onset_date, predicted_peak_date,
			treatment_window_start, treatment_window_end,
			recommended_treatments,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_predictions
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR farm_id = $2::VARCHAR)
		AND ($3::VARCHAR IS NULL OR field_id = $3::VARCHAR)
		AND ($4::VARCHAR IS NULL OR pest_species_uuid = $4::VARCHAR)
		AND ($5::risk_level IS NULL OR risk_level >= $5::risk_level)
		ORDER BY prediction_date DESC
		LIMIT $6 OFFSET $7`,
		params.TenantID, params.FarmID, params.FieldID, params.PestSpeciesID, params.MinRiskLevel,
		params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.Internal("failed to list predictions: %v", err)
	}
	defer rows.Close()

	var results []pestmodels.PestPrediction
	for rows.Next() {
		var p pestmodels.PestPrediction
		if err := scanPestPredictionRow(rows, &p); err != nil {
			return nil, 0, errors.Internal("failed to scan prediction: %v", err)
		}
		results = append(results, p)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("error iterating predictions: %v", err)
	}

	return results, count, nil
}

func (r *pestRepository) GetHistoricalOccurrenceCount(ctx context.Context, tenantID, farmID, pestSpeciesUUID string) (int64, error) {
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM pest_predictions
		WHERE tenant_id = $1 AND farm_id = $2 AND pest_species_uuid = $3
		AND risk_level IN ('MODERATE', 'HIGH', 'CRITICAL')
		AND is_active = TRUE AND deleted_at IS NULL`,
		tenantID, farmID, pestSpeciesUUID,
	).Scan(&count)
	if err != nil {
		return 0, errors.Internal("failed to get historical occurrence count: %v", err)
	}
	return count, nil
}

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------

func (r *pestRepository) CreateAlert(ctx context.Context, alert *pestmodels.PestAlert) (*pestmodels.PestAlert, error) {
	alert.UUID = ulid.NewString()

	row := r.pool.QueryRow(ctx,
		`INSERT INTO pest_alerts (
			uuid, tenant_id, prediction_id, prediction_uuid, farm_id, field_id,
			pest_species_id, pest_species_uuid, risk_level, status,
			title, message,
			version, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,'ACTIVE',$10,$11,1,TRUE,$12,NOW())
		RETURNING id, uuid, tenant_id, prediction_id, prediction_uuid, farm_id, field_id,
			pest_species_id, pest_species_uuid, risk_level, status,
			title, message, acknowledged_at, acknowledged_by,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		alert.UUID, alert.TenantID, alert.PredictionID, alert.PredictionUUID,
		alert.FarmID, alert.FieldID, alert.PestSpeciesID, alert.PestSpeciesUUID,
		string(alert.RiskLevel), alert.Title, alert.Message,
		alert.CreatedBy,
	)

	result := &pestmodels.PestAlert{}
	if err := scanPestAlert(row, result); err != nil {
		return nil, errors.Internal("failed to create alert: %v", err)
	}
	return result, nil
}

func (r *pestRepository) ListAlerts(ctx context.Context, params *pestmodels.ListAlertsParams) ([]pestmodels.PestAlert, int64, error) {
	// Count
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM pest_alerts
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR farm_id = $2::VARCHAR)
		AND ($3::VARCHAR IS NULL OR field_id = $3::VARCHAR)
		AND ($4::alert_status IS NULL OR status = $4::alert_status)
		AND ($5::risk_level IS NULL OR risk_level >= $5::risk_level)`,
		params.TenantID, params.FarmID, params.FieldID, params.Status, params.MinRiskLevel,
	).Scan(&count)
	if err != nil {
		return nil, 0, errors.Internal("failed to count alerts: %v", err)
	}

	// List
	rows, err := r.pool.Query(ctx,
		`SELECT id, uuid, tenant_id, prediction_id, prediction_uuid, farm_id, field_id,
			pest_species_id, pest_species_uuid, risk_level, status,
			title, message, acknowledged_at, acknowledged_by,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_alerts
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR farm_id = $2::VARCHAR)
		AND ($3::VARCHAR IS NULL OR field_id = $3::VARCHAR)
		AND ($4::alert_status IS NULL OR status = $4::alert_status)
		AND ($5::risk_level IS NULL OR risk_level >= $5::risk_level)
		ORDER BY created_at DESC
		LIMIT $6 OFFSET $7`,
		params.TenantID, params.FarmID, params.FieldID, params.Status, params.MinRiskLevel,
		params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.Internal("failed to list alerts: %v", err)
	}
	defer rows.Close()

	var results []pestmodels.PestAlert
	for rows.Next() {
		var a pestmodels.PestAlert
		if err := scanPestAlertRow(rows, &a); err != nil {
			return nil, 0, errors.Internal("failed to scan alert: %v", err)
		}
		results = append(results, a)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("error iterating alerts: %v", err)
	}

	return results, count, nil
}

func (r *pestRepository) AcknowledgeAlert(ctx context.Context, tenantID, uuid, userID string) (*pestmodels.PestAlert, error) {
	row := r.pool.QueryRow(ctx,
		`UPDATE pest_alerts SET
			status = 'ACKNOWLEDGED',
			acknowledged_at = NOW(),
			acknowledged_by = $3,
			updated_by = $3,
			updated_at = NOW(),
			version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND status = 'ACTIVE'
			AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, prediction_id, prediction_uuid, farm_id, field_id,
			pest_species_id, pest_species_uuid, risk_level, status,
			title, message, acknowledged_at, acknowledged_by,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		uuid, tenantID, userID,
	)

	result := &pestmodels.PestAlert{}
	if err := scanPestAlert(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("active alert %s not found", uuid))
		}
		return nil, errors.Internal("failed to acknowledge alert: %v", err)
	}
	return result, nil
}

// ---------------------------------------------------------------------------
// Observations
// ---------------------------------------------------------------------------

func (r *pestRepository) CreateObservation(ctx context.Context, obs *pestmodels.PestObservation) (*pestmodels.PestObservation, error) {
	obs.UUID = ulid.NewString()

	row := r.pool.QueryRow(ctx,
		`INSERT INTO pest_observations (
			uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			pest_count, damage_level, trap_type, image_url,
			location, latitude, longitude, notes,
			observed_by, observed_at,
			version, is_active, created_by, created_at
		) VALUES (
			$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,
			CASE WHEN $11::DOUBLE PRECISION IS NOT NULL AND $12::DOUBLE PRECISION IS NOT NULL
				THEN ST_SetSRID(ST_MakePoint($12::DOUBLE PRECISION, $11::DOUBLE PRECISION), 4326)
				ELSE NULL
			END,
			$11,$12,$13,$14,NOW(),1,TRUE,$14,NOW()
		)
		RETURNING id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			pest_count, damage_level, trap_type, image_url,
			latitude, longitude, notes,
			observed_by, observed_at,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		obs.UUID, obs.TenantID, obs.FarmID, obs.FieldID, obs.PestSpeciesID, obs.PestSpeciesUUID,
		obs.PestCount, string(obs.DamageLevel), obs.TrapType, obs.ImageURL,
		obs.Latitude, obs.Longitude, obs.Notes,
		obs.ObservedBy,
	)

	result := &pestmodels.PestObservation{}
	if err := scanPestObservation(row, result); err != nil {
		return nil, errors.Internal("failed to create observation: %v", err)
	}
	return result, nil
}

func (r *pestRepository) ListObservations(ctx context.Context, params *pestmodels.ListObservationsParams) ([]pestmodels.PestObservation, int64, error) {
	// Count
	var count int64
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM pest_observations
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR farm_id = $2::VARCHAR)
		AND ($3::VARCHAR IS NULL OR field_id = $3::VARCHAR)
		AND ($4::VARCHAR IS NULL OR pest_species_uuid = $4::VARCHAR)`,
		params.TenantID, params.FarmID, params.FieldID, params.PestSpeciesID,
	).Scan(&count)
	if err != nil {
		return nil, 0, errors.Internal("failed to count observations: %v", err)
	}

	// List
	rows, err := r.pool.Query(ctx,
		`SELECT id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			pest_count, damage_level, trap_type, image_url,
			latitude, longitude, notes,
			observed_by, observed_at,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_observations
		WHERE tenant_id = $1 AND is_active = TRUE AND deleted_at IS NULL
		AND ($2::VARCHAR IS NULL OR farm_id = $2::VARCHAR)
		AND ($3::VARCHAR IS NULL OR field_id = $3::VARCHAR)
		AND ($4::VARCHAR IS NULL OR pest_species_uuid = $4::VARCHAR)
		ORDER BY observed_at DESC
		LIMIT $5 OFFSET $6`,
		params.TenantID, params.FarmID, params.FieldID, params.PestSpeciesID,
		params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.Internal("failed to list observations: %v", err)
	}
	defer rows.Close()

	var results []pestmodels.PestObservation
	for rows.Next() {
		var o pestmodels.PestObservation
		if err := scanPestObservationRow(rows, &o); err != nil {
			return nil, 0, errors.Internal("failed to scan observation: %v", err)
		}
		results = append(results, o)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.Internal("error iterating observations: %v", err)
	}

	return results, count, nil
}

func (r *pestRepository) GetRecentObservationsBySpecies(ctx context.Context, tenantID, farmID, pestSpeciesUUID string) ([]pestmodels.PestObservation, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			pest_count, damage_level, trap_type, image_url,
			latitude, longitude, notes,
			observed_by, observed_at,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_observations
		WHERE tenant_id = $1 AND farm_id = $2 AND pest_species_uuid = $3
		AND is_active = TRUE AND deleted_at IS NULL
		AND observed_at >= NOW() - INTERVAL '90 days'
		ORDER BY observed_at DESC
		LIMIT 50`,
		tenantID, farmID, pestSpeciesUUID,
	)
	if err != nil {
		return nil, errors.Internal("failed to get recent observations: %v", err)
	}
	defer rows.Close()

	var results []pestmodels.PestObservation
	for rows.Next() {
		var o pestmodels.PestObservation
		if err := scanPestObservationRow(rows, &o); err != nil {
			return nil, errors.Internal("failed to scan observation: %v", err)
		}
		results = append(results, o)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.Internal("error iterating recent observations: %v", err)
	}

	return results, nil
}

// ---------------------------------------------------------------------------
// Treatments
// ---------------------------------------------------------------------------

func (r *pestRepository) CreateTreatment(ctx context.Context, treatment *pestmodels.PestTreatment) (*pestmodels.PestTreatment, error) {
	treatment.UUID = ulid.NewString()

	row := r.pool.QueryRow(ctx,
		`INSERT INTO pest_treatments (
			uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			prediction_id, prediction_uuid, treatment_type, product_name,
			application_rate, application_method, cost, effectiveness_rating,
			applied_by, applied_at, notes,
			version, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,NOW(),$16,1,TRUE,$15,NOW())
		RETURNING id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			prediction_id, prediction_uuid, treatment_type, product_name,
			application_rate, application_method, cost, effectiveness_rating,
			applied_by, applied_at, notes,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		treatment.UUID, treatment.TenantID, treatment.FarmID, treatment.FieldID,
		treatment.PestSpeciesID, treatment.PestSpeciesUUID,
		treatment.PredictionID, treatment.PredictionUUID,
		string(treatment.TreatmentType), treatment.ProductName,
		treatment.ApplicationRate, treatment.ApplicationMethod, treatment.Cost, treatment.EffectivenessRating,
		treatment.AppliedBy, treatment.Notes,
	)

	result := &pestmodels.PestTreatment{}
	if err := scanPestTreatment(row, result); err != nil {
		return nil, errors.Internal("failed to create treatment: %v", err)
	}
	return result, nil
}

func (r *pestRepository) ListTreatmentsByPrediction(ctx context.Context, tenantID, predictionUUID string) ([]pestmodels.PestTreatment, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, uuid, tenant_id, farm_id, field_id, pest_species_id, pest_species_uuid,
			prediction_id, prediction_uuid, treatment_type, product_name,
			application_rate, application_method, cost, effectiveness_rating,
			applied_by, applied_at, notes,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_treatments
		WHERE prediction_uuid = $1 AND tenant_id = $2
		AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY applied_at DESC`,
		predictionUUID, tenantID,
	)
	if err != nil {
		return nil, errors.Internal("failed to list treatments: %v", err)
	}
	defer rows.Close()

	var results []pestmodels.PestTreatment
	for rows.Next() {
		var t pestmodels.PestTreatment
		if err := scanPestTreatmentRow(rows, &t); err != nil {
			return nil, errors.Internal("failed to scan treatment: %v", err)
		}
		results = append(results, t)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.Internal("error iterating treatments: %v", err)
	}

	return results, nil
}

// ---------------------------------------------------------------------------
// Risk Maps
// ---------------------------------------------------------------------------

func (r *pestRepository) GetRiskMap(ctx context.Context, tenantID, pestSpeciesUUID, region string) (*pestmodels.PestRiskMap, error) {
	row := r.pool.QueryRow(ctx,
		`SELECT id, uuid, tenant_id, pest_species_id, pest_species_uuid,
			region, overall_risk_level, geojson,
			valid_from, valid_until,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM pest_risk_maps
		WHERE tenant_id = $1 AND pest_species_uuid = $2 AND region = $3
		AND is_active = TRUE AND deleted_at IS NULL
		AND valid_from <= NOW() AND valid_until >= NOW()
		ORDER BY created_at DESC
		LIMIT 1`,
		tenantID, pestSpeciesUUID, region,
	)

	result := &pestmodels.PestRiskMap{}
	if err := scanPestRiskMap(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("RISK_MAP_NOT_FOUND", fmt.Sprintf("risk map for species %s in region %s not found", pestSpeciesUUID, region))
		}
		return nil, errors.Internal("failed to get risk map: %v", err)
	}
	return result, nil
}

func (r *pestRepository) UpsertRiskMap(ctx context.Context, riskMap *pestmodels.PestRiskMap) (*pestmodels.PestRiskMap, error) {
	riskMap.UUID = ulid.NewString()

	row := r.pool.QueryRow(ctx,
		`INSERT INTO pest_risk_maps (
			uuid, tenant_id, pest_species_id, pest_species_uuid,
			region, overall_risk_level, geojson,
			boundary, valid_from, valid_until,
			version, is_active, created_by, created_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,ST_GeomFromGeoJSON($7),$8,$9,1,TRUE,$10,NOW())
		ON CONFLICT (uuid) DO UPDATE SET
			overall_risk_level = EXCLUDED.overall_risk_level,
			geojson = EXCLUDED.geojson,
			boundary = ST_GeomFromGeoJSON(EXCLUDED.geojson),
			valid_from = EXCLUDED.valid_from,
			valid_until = EXCLUDED.valid_until,
			version = pest_risk_maps.version + 1,
			updated_by = $10,
			updated_at = NOW()
		RETURNING id, uuid, tenant_id, pest_species_id, pest_species_uuid,
			region, overall_risk_level, geojson,
			valid_from, valid_until,
			version, is_active, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		riskMap.UUID, riskMap.TenantID, riskMap.PestSpeciesID, riskMap.PestSpeciesUUID,
		riskMap.Region, string(riskMap.OverallRiskLevel), riskMap.GeoJSON,
		riskMap.ValidFrom, riskMap.ValidUntil,
		riskMap.CreatedBy,
	)

	result := &pestmodels.PestRiskMap{}
	if err := scanPestRiskMap(row, result); err != nil {
		return nil, errors.Internal("failed to upsert risk map: %v", err)
	}
	return result, nil
}

// ---------------------------------------------------------------------------
// Scan helpers
// ---------------------------------------------------------------------------

type scannable interface {
	Scan(dest ...interface{}) error
}

func scanPestSpecies(row scannable, s *pestmodels.PestSpecies) error {
	return row.Scan(
		&s.ID, &s.UUID, &s.TenantID, &s.CommonName, &s.ScientificName, &s.Family,
		&s.Description, &s.AffectedCrops, &s.FavorableConditions, &s.ImageURL,
		&s.Version, &s.IsActive, &s.CreatedBy, &s.CreatedAt,
		&s.UpdatedBy, &s.UpdatedAt, &s.DeletedBy, &s.DeletedAt,
	)
}

func scanPestSpeciesRow(rows pgx.Rows, s *pestmodels.PestSpecies) error {
	return scanPestSpecies(rows, s)
}

func scanPestPrediction(row scannable, p *pestmodels.PestPrediction) error {
	return row.Scan(
		&p.ID, &p.UUID, &p.TenantID, &p.FarmID, &p.FieldID, &p.PestSpeciesID, &p.PestSpeciesUUID,
		&p.PredictionDate, &p.RiskLevel, &p.RiskScore, &p.ConfidencePct,
		&p.TemperatureCelsius, &p.HumidityPct, &p.RainfallMm, &p.WindSpeedKmh,
		&p.CropType, &p.GrowthStage, &p.GeographicRiskFactor, &p.HistoricalOccurrenceCount,
		&p.PredictedOnsetDate, &p.PredictedPeakDate,
		&p.TreatmentWindowStart, &p.TreatmentWindowEnd,
		&p.RecommendedTreatments,
		&p.Version, &p.IsActive, &p.CreatedBy, &p.CreatedAt,
		&p.UpdatedBy, &p.UpdatedAt, &p.DeletedBy, &p.DeletedAt,
	)
}

func scanPestPredictionRow(rows pgx.Rows, p *pestmodels.PestPrediction) error {
	return scanPestPrediction(rows, p)
}

func scanPestAlert(row scannable, a *pestmodels.PestAlert) error {
	return row.Scan(
		&a.ID, &a.UUID, &a.TenantID, &a.PredictionID, &a.PredictionUUID,
		&a.FarmID, &a.FieldID, &a.PestSpeciesID, &a.PestSpeciesUUID,
		&a.RiskLevel, &a.Status,
		&a.Title, &a.Message, &a.AcknowledgedAt, &a.AcknowledgedBy,
		&a.Version, &a.IsActive, &a.CreatedBy, &a.CreatedAt,
		&a.UpdatedBy, &a.UpdatedAt, &a.DeletedBy, &a.DeletedAt,
	)
}

func scanPestAlertRow(rows pgx.Rows, a *pestmodels.PestAlert) error {
	return scanPestAlert(rows, a)
}

func scanPestObservation(row scannable, o *pestmodels.PestObservation) error {
	return row.Scan(
		&o.ID, &o.UUID, &o.TenantID, &o.FarmID, &o.FieldID, &o.PestSpeciesID, &o.PestSpeciesUUID,
		&o.PestCount, &o.DamageLevel, &o.TrapType, &o.ImageURL,
		&o.Latitude, &o.Longitude, &o.Notes,
		&o.ObservedBy, &o.ObservedAt,
		&o.Version, &o.IsActive, &o.CreatedBy, &o.CreatedAt,
		&o.UpdatedBy, &o.UpdatedAt, &o.DeletedBy, &o.DeletedAt,
	)
}

func scanPestObservationRow(rows pgx.Rows, o *pestmodels.PestObservation) error {
	return scanPestObservation(rows, o)
}

func scanPestTreatment(row scannable, t *pestmodels.PestTreatment) error {
	return row.Scan(
		&t.ID, &t.UUID, &t.TenantID, &t.FarmID, &t.FieldID,
		&t.PestSpeciesID, &t.PestSpeciesUUID,
		&t.PredictionID, &t.PredictionUUID,
		&t.TreatmentType, &t.ProductName,
		&t.ApplicationRate, &t.ApplicationMethod, &t.Cost, &t.EffectivenessRating,
		&t.AppliedBy, &t.AppliedAt, &t.Notes,
		&t.Version, &t.IsActive, &t.CreatedBy, &t.CreatedAt,
		&t.UpdatedBy, &t.UpdatedAt, &t.DeletedBy, &t.DeletedAt,
	)
}

func scanPestTreatmentRow(rows pgx.Rows, t *pestmodels.PestTreatment) error {
	return scanPestTreatment(rows, t)
}

func scanPestRiskMap(row scannable, m *pestmodels.PestRiskMap) error {
	return row.Scan(
		&m.ID, &m.UUID, &m.TenantID, &m.PestSpeciesID, &m.PestSpeciesUUID,
		&m.Region, &m.OverallRiskLevel, &m.GeoJSON,
		&m.ValidFrom, &m.ValidUntil,
		&m.Version, &m.IsActive, &m.CreatedBy, &m.CreatedAt,
		&m.UpdatedBy, &m.UpdatedAt, &m.DeletedBy, &m.DeletedAt,
	)
}

// jsonDefault returns raw if non-nil/non-empty, otherwise returns the default JSON string.
func jsonDefault(raw json.RawMessage, defaultVal string) json.RawMessage {
	if len(raw) == 0 {
		return json.RawMessage(defaultVal)
	}
	return raw
}

// Ensure compile-time interface compliance.
var _ PestRepository = (*pestRepository)(nil)

// Unused in current implementation but kept to satisfy the import.
var _ = time.Now
