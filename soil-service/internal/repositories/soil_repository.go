package repositories

import (
	"context"
	"fmt"
	"time"

	"p9e.in/samavaya/agriculture/soil-service/internal/mappers"
	"p9e.in/samavaya/agriculture/soil-service/internal/models"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// SoilRepository defines the data-access contract for the soil domain.
type SoilRepository interface {
	// Samples
	CreateSoilSample(ctx context.Context, sample *models.SoilSample) (*models.SoilSample, error)
	GetSoilSampleByUUID(ctx context.Context, uuid, tenantID string) (*models.SoilSample, error)
	ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, limit, offset int32) ([]models.SoilSample, int64, error)
	DeleteSoilSample(ctx context.Context, uuid, tenantID, userID string) error

	// Analyses
	CreateSoilAnalysis(ctx context.Context, analysis *models.SoilAnalysis) (*models.SoilAnalysis, error)
	GetSoilAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*models.SoilAnalysis, error)
	ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, limit, offset int32) ([]models.SoilAnalysis, int64, error)
	UpdateSoilAnalysisStatus(ctx context.Context, analysis *models.SoilAnalysis) (*models.SoilAnalysis, error)

	// Maps
	CreateSoilMap(ctx context.Context, soilMap *models.SoilMap) (*models.SoilMap, error)
	GetSoilMapByFieldAndType(ctx context.Context, fieldID, tenantID, mapType string) (*models.SoilMap, error)

	// Nutrients
	CreateSoilNutrient(ctx context.Context, nutrient *models.SoilNutrient) (*models.SoilNutrient, error)
	ListNutrientsBySample(ctx context.Context, sampleID, tenantID string) ([]models.SoilNutrient, error)
	BatchCreateNutrients(ctx context.Context, nutrients []models.SoilNutrient) ([]models.SoilNutrient, error)

	// Health Scores
	CreateSoilHealthScore(ctx context.Context, score *models.SoilHealthScore) (*models.SoilHealthScore, error)
	GetLatestSoilHealthScore(ctx context.Context, fieldID, tenantID string) (*models.SoilHealthScore, error)
	UpdateSoilHealthScore(ctx context.Context, score *models.SoilHealthScore) (*models.SoilHealthScore, error)
	ListSoilHealthScoresByFarm(ctx context.Context, farmID, tenantID string) ([]models.SoilHealthScore, error)
}

// soilRepository is the concrete pgx implementation.
type soilRepository struct {
	pool   *pgxpool.Pool
	logger *p9log.Helper
}

// NewSoilRepository returns a production-ready SoilRepository.
func NewSoilRepository(d deps.ServiceDeps) SoilRepository {
	return &soilRepository{
		pool:   d.Pool,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "SoilRepository")),
	}
}

// ---------------------------------------------------------------------------
// Samples
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilSample(ctx context.Context, sample *models.SoilSample) (*models.SoilSample, error) {
	if sample.UUID == "" {
		sample.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_samples (
			uuid, tenant_id, field_id, farm_id,
			sample_location, sample_depth_cm, collection_date,
			ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
			calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
			zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
			texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
			collected_by, notes, created_by
		) VALUES (
			$1, $2, $3, $4,
			ST_SetSRID(ST_MakePoint($5, $6), 4326), $7, $8,
			$9, $10, $11, $12, $13,
			$14, $15, $16, $17, $18,
			$19, $20, $21, $22,
			$23, $24, $25, $26,
			$27, $28, $29
		) RETURNING id, uuid, tenant_id, field_id, farm_id,
			ST_Y(sample_location::geometry) AS latitude,
			ST_X(sample_location::geometry) AS longitude,
			sample_depth_cm, collection_date,
			ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
			calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
			zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
			texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
			collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version`

	var result models.SoilSample
	var texture string
	err := r.pool.QueryRow(ctx, query,
		sample.UUID, sample.TenantID, sample.FieldID, sample.FarmID,
		sample.Longitude, sample.Latitude, sample.SampleDepthCm, sample.CollectionDate,
		sample.PH, sample.OrganicMatterPct, sample.NitrogenPPM, sample.PhosphorusPPM, sample.PotassiumPPM,
		sample.CalciumPPM, sample.MagnesiumPPM, sample.SulfurPPM, sample.IronPPM, sample.ManganesePPM,
		sample.ZincPPM, sample.CopperPPM, sample.BoronPPM, sample.MoisturePct,
		string(sample.Texture), sample.BulkDensity, sample.CationExchangeCapacity, sample.ElectricalConductivity,
		sample.CollectedBy, sample.Notes, sample.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.Latitude, &result.Longitude,
		&result.SampleDepthCm, &result.CollectionDate,
		&result.PH, &result.OrganicMatterPct, &result.NitrogenPPM, &result.PhosphorusPPM, &result.PotassiumPPM,
		&result.CalciumPPM, &result.MagnesiumPPM, &result.SulfurPPM, &result.IronPPM, &result.ManganesePPM,
		&result.ZincPPM, &result.CopperPPM, &result.BoronPPM, &result.MoisturePct,
		&texture, &result.BulkDensity, &result.CationExchangeCapacity, &result.ElectricalConductivity,
		&result.CollectedBy, &result.Notes, &result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		r.logger.Errorf("CreateSoilSample failed: %v", err)
		return nil, errors.InternalServer("CREATE_SAMPLE_FAILED", fmt.Sprintf("failed to create soil sample: %v", err))
	}
	result.Texture = models.SoilTexture(texture)
	return &result, nil
}

func (r *soilRepository) GetSoilSampleByUUID(ctx context.Context, uuid, tenantID string) (*models.SoilSample, error) {
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id,
			ST_Y(sample_location::geometry) AS latitude,
			ST_X(sample_location::geometry) AS longitude,
			sample_depth_cm, collection_date,
			ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
			calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
			zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
			texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
			collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_samples
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	var result models.SoilSample
	var texture string
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.Latitude, &result.Longitude,
		&result.SampleDepthCm, &result.CollectionDate,
		&result.PH, &result.OrganicMatterPct, &result.NitrogenPPM, &result.PhosphorusPPM, &result.PotassiumPPM,
		&result.CalciumPPM, &result.MagnesiumPPM, &result.SulfurPPM, &result.IronPPM, &result.ManganesePPM,
		&result.ZincPPM, &result.CopperPPM, &result.BoronPPM, &result.MoisturePct,
		&texture, &result.BulkDensity, &result.CationExchangeCapacity, &result.ElectricalConductivity,
		&result.CollectedBy, &result.Notes, &result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SAMPLE_NOT_FOUND", fmt.Sprintf("soil sample %s not found", uuid))
		}
		r.logger.Errorf("GetSoilSampleByUUID failed: %v", err)
		return nil, errors.InternalServer("GET_SAMPLE_FAILED", fmt.Sprintf("failed to get soil sample: %v", err))
	}
	result.Texture = models.SoilTexture(texture)
	return &result, nil
}

func (r *soilRepository) ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, limit, offset int32) ([]models.SoilSample, int64, error) {
	countQuery := `
		SELECT COUNT(*) FROM soil_samples
		WHERE tenant_id = $1
			AND ($2::VARCHAR = '' OR field_id = $2)
			AND ($3::VARCHAR = '' OR farm_id = $3)
			AND is_active = TRUE AND deleted_at IS NULL`

	var totalCount int64
	if err := r.pool.QueryRow(ctx, countQuery, tenantID, fieldID, farmID).Scan(&totalCount); err != nil {
		r.logger.Errorf("CountSoilSamples failed: %v", err)
		return nil, 0, errors.InternalServer("COUNT_SAMPLES_FAILED", fmt.Sprintf("failed to count soil samples: %v", err))
	}

	listQuery := `
		SELECT id, uuid, tenant_id, field_id, farm_id,
			ST_Y(sample_location::geometry) AS latitude,
			ST_X(sample_location::geometry) AS longitude,
			sample_depth_cm, collection_date,
			ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
			calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
			zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
			texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
			collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_samples
		WHERE tenant_id = $1
			AND ($2::VARCHAR = '' OR field_id = $2)
			AND ($3::VARCHAR = '' OR farm_id = $3)
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY collection_date DESC
		LIMIT $4 OFFSET $5`

	rows, err := r.pool.Query(ctx, listQuery, tenantID, fieldID, farmID, limit, offset)
	if err != nil {
		r.logger.Errorf("ListSoilSamples query failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_SAMPLES_FAILED", fmt.Sprintf("failed to list soil samples: %v", err))
	}
	defer rows.Close()

	samples := make([]models.SoilSample, 0)
	for rows.Next() {
		var s models.SoilSample
		var texture string
		if err := rows.Scan(
			&s.ID, &s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
			&s.Latitude, &s.Longitude,
			&s.SampleDepthCm, &s.CollectionDate,
			&s.PH, &s.OrganicMatterPct, &s.NitrogenPPM, &s.PhosphorusPPM, &s.PotassiumPPM,
			&s.CalciumPPM, &s.MagnesiumPPM, &s.SulfurPPM, &s.IronPPM, &s.ManganesePPM,
			&s.ZincPPM, &s.CopperPPM, &s.BoronPPM, &s.MoisturePct,
			&texture, &s.BulkDensity, &s.CationExchangeCapacity, &s.ElectricalConductivity,
			&s.CollectedBy, &s.Notes, &s.IsActive, &s.CreatedBy, &s.CreatedAt,
			&s.UpdatedBy, &s.UpdatedAt, &s.Version,
		); err != nil {
			r.logger.Errorf("ListSoilSamples scan failed: %v", err)
			return nil, 0, errors.InternalServer("LIST_SAMPLES_SCAN_FAILED", fmt.Sprintf("failed to scan soil sample row: %v", err))
		}
		s.Texture = models.SoilTexture(texture)
		samples = append(samples, s)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("LIST_SAMPLES_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return samples, totalCount, nil
}

func (r *soilRepository) DeleteSoilSample(ctx context.Context, uuid, tenantID, userID string) error {
	query := `
		UPDATE soil_samples
		SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	tag, err := r.pool.Exec(ctx, query, uuid, tenantID, userID)
	if err != nil {
		r.logger.Errorf("DeleteSoilSample failed: %v", err)
		return errors.InternalServer("DELETE_SAMPLE_FAILED", fmt.Sprintf("failed to delete soil sample: %v", err))
	}
	if tag.RowsAffected() == 0 {
		return errors.NotFound("SAMPLE_NOT_FOUND", fmt.Sprintf("soil sample %s not found", uuid))
	}
	return nil
}

// ---------------------------------------------------------------------------
// Analyses
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilAnalysis(ctx context.Context, analysis *models.SoilAnalysis) (*models.SoilAnalysis, error) {
	if analysis.UUID == "" {
		analysis.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_analyses (
			uuid, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary, created_by
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
		) RETURNING id, uuid, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result models.SoilAnalysis
	var status, healthCat string
	err := r.pool.QueryRow(ctx, query,
		analysis.UUID, analysis.TenantID, analysis.SampleID, analysis.FieldID, analysis.FarmID,
		string(analysis.Status), analysis.AnalysisType, analysis.SoilHealthScore, string(analysis.HealthCategory),
		analysis.Recommendations, analysis.AnalyzedBy, analysis.AnalyzedAt, analysis.Summary, analysis.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.SampleID, &result.FieldID, &result.FarmID,
		&status, &result.AnalysisType, &result.SoilHealthScore, &healthCat,
		&result.Recommendations, &result.AnalyzedBy, &result.AnalyzedAt, &result.Summary,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		r.logger.Errorf("CreateSoilAnalysis failed: %v", err)
		return nil, errors.InternalServer("CREATE_ANALYSIS_FAILED", fmt.Sprintf("failed to create soil analysis: %v", err))
	}
	result.Status = mappers.AnalysisStatusFromString(status)
	result.HealthCategory = mappers.HealthCategoryFromString(healthCat)
	return &result, nil
}

func (r *soilRepository) GetSoilAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*models.SoilAnalysis, error) {
	query := `
		SELECT id, uuid, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_analyses
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	var result models.SoilAnalysis
	var status, healthCat string
	err := r.pool.QueryRow(ctx, query, uuid, tenantID).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.SampleID, &result.FieldID, &result.FarmID,
		&status, &result.AnalysisType, &result.SoilHealthScore, &healthCat,
		&result.Recommendations, &result.AnalyzedBy, &result.AnalyzedAt, &result.Summary,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ANALYSIS_NOT_FOUND", fmt.Sprintf("soil analysis %s not found", uuid))
		}
		r.logger.Errorf("GetSoilAnalysisByUUID failed: %v", err)
		return nil, errors.InternalServer("GET_ANALYSIS_FAILED", fmt.Sprintf("failed to get soil analysis: %v", err))
	}
	result.Status = mappers.AnalysisStatusFromString(status)
	result.HealthCategory = mappers.HealthCategoryFromString(healthCat)
	return &result, nil
}

func (r *soilRepository) ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, limit, offset int32) ([]models.SoilAnalysis, int64, error) {
	countQuery := `
		SELECT COUNT(*) FROM soil_analyses
		WHERE tenant_id = $1
			AND ($2::VARCHAR = '' OR field_id = $2)
			AND ($3::VARCHAR = '' OR farm_id = $3)
			AND ($4::VARCHAR = '' OR sample_id = $4)
			AND is_active = TRUE AND deleted_at IS NULL`

	var totalCount int64
	if err := r.pool.QueryRow(ctx, countQuery, tenantID, fieldID, farmID, sampleID).Scan(&totalCount); err != nil {
		r.logger.Errorf("CountSoilAnalyses failed: %v", err)
		return nil, 0, errors.InternalServer("COUNT_ANALYSES_FAILED", fmt.Sprintf("failed to count soil analyses: %v", err))
	}

	listQuery := `
		SELECT id, uuid, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_analyses
		WHERE tenant_id = $1
			AND ($2::VARCHAR = '' OR field_id = $2)
			AND ($3::VARCHAR = '' OR farm_id = $3)
			AND ($4::VARCHAR = '' OR sample_id = $4)
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $5 OFFSET $6`

	rows, err := r.pool.Query(ctx, listQuery, tenantID, fieldID, farmID, sampleID, limit, offset)
	if err != nil {
		r.logger.Errorf("ListSoilAnalyses query failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_ANALYSES_FAILED", fmt.Sprintf("failed to list soil analyses: %v", err))
	}
	defer rows.Close()

	analyses := make([]models.SoilAnalysis, 0)
	for rows.Next() {
		var a models.SoilAnalysis
		var status, healthCat string
		if err := rows.Scan(
			&a.ID, &a.UUID, &a.TenantID, &a.SampleID, &a.FieldID, &a.FarmID,
			&status, &a.AnalysisType, &a.SoilHealthScore, &healthCat,
			&a.Recommendations, &a.AnalyzedBy, &a.AnalyzedAt, &a.Summary,
			&a.IsActive, &a.CreatedBy, &a.CreatedAt, &a.UpdatedBy, &a.UpdatedAt, &a.Version,
		); err != nil {
			r.logger.Errorf("ListSoilAnalyses scan failed: %v", err)
			return nil, 0, errors.InternalServer("LIST_ANALYSES_SCAN_FAILED", fmt.Sprintf("failed to scan soil analysis row: %v", err))
		}
		a.Status = mappers.AnalysisStatusFromString(status)
		a.HealthCategory = mappers.HealthCategoryFromString(healthCat)
		analyses = append(analyses, a)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("LIST_ANALYSES_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return analyses, totalCount, nil
}

func (r *soilRepository) UpdateSoilAnalysisStatus(ctx context.Context, analysis *models.SoilAnalysis) (*models.SoilAnalysis, error) {
	query := `
		UPDATE soil_analyses
		SET status = $3, soil_health_score = $4, health_category = $5,
			recommendations = $6, analyzed_by = $7, analyzed_at = $8,
			summary = $9, updated_by = $10, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result models.SoilAnalysis
	var status, healthCat string
	err := r.pool.QueryRow(ctx, query,
		analysis.UUID, analysis.TenantID,
		string(analysis.Status), analysis.SoilHealthScore, string(analysis.HealthCategory),
		analysis.Recommendations, analysis.AnalyzedBy, analysis.AnalyzedAt,
		analysis.Summary, analysis.AnalyzedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.SampleID, &result.FieldID, &result.FarmID,
		&status, &result.AnalysisType, &result.SoilHealthScore, &healthCat,
		&result.Recommendations, &result.AnalyzedBy, &result.AnalyzedAt, &result.Summary,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ANALYSIS_NOT_FOUND", fmt.Sprintf("soil analysis %s not found", analysis.UUID))
		}
		r.logger.Errorf("UpdateSoilAnalysisStatus failed: %v", err)
		return nil, errors.InternalServer("UPDATE_ANALYSIS_FAILED", fmt.Sprintf("failed to update soil analysis: %v", err))
	}
	result.Status = mappers.AnalysisStatusFromString(status)
	result.HealthCategory = mappers.HealthCategoryFromString(healthCat)
	return &result, nil
}

// ---------------------------------------------------------------------------
// Maps
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilMap(ctx context.Context, soilMap *models.SoilMap) (*models.SoilMap, error) {
	if soilMap.UUID == "" {
		soilMap.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_maps (
			uuid, tenant_id, field_id, farm_id, map_type,
			crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
			generated_by, generated_at, created_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		RETURNING id, uuid, tenant_id, field_id, farm_id, map_type,
			crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
			generated_by, generated_at,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result models.SoilMap
	err := r.pool.QueryRow(ctx, query,
		soilMap.UUID, soilMap.TenantID, soilMap.FieldID, soilMap.FarmID, soilMap.MapType,
		soilMap.CRS, soilMap.Resolution, soilMap.BboxMinLat, soilMap.BboxMinLng, soilMap.BboxMaxLat, soilMap.BboxMaxLng,
		soilMap.GeneratedBy, soilMap.GeneratedAt, soilMap.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID, &result.MapType,
		&result.CRS, &result.Resolution, &result.BboxMinLat, &result.BboxMinLng, &result.BboxMaxLat, &result.BboxMaxLng,
		&result.GeneratedBy, &result.GeneratedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		r.logger.Errorf("CreateSoilMap failed: %v", err)
		return nil, errors.InternalServer("CREATE_MAP_FAILED", fmt.Sprintf("failed to create soil map: %v", err))
	}
	return &result, nil
}

func (r *soilRepository) GetSoilMapByFieldAndType(ctx context.Context, fieldID, tenantID, mapType string) (*models.SoilMap, error) {
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id, map_type,
			crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
			generated_by, generated_at,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_maps
		WHERE field_id = $1 AND tenant_id = $2 AND map_type = $3
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY generated_at DESC
		LIMIT 1`

	var result models.SoilMap
	err := r.pool.QueryRow(ctx, query, fieldID, tenantID, mapType).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID, &result.MapType,
		&result.CRS, &result.Resolution, &result.BboxMinLat, &result.BboxMinLng, &result.BboxMaxLat, &result.BboxMaxLng,
		&result.GeneratedBy, &result.GeneratedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("MAP_NOT_FOUND", fmt.Sprintf("soil map for field %s type %s not found", fieldID, mapType))
		}
		r.logger.Errorf("GetSoilMapByFieldAndType failed: %v", err)
		return nil, errors.InternalServer("GET_MAP_FAILED", fmt.Sprintf("failed to get soil map: %v", err))
	}
	return &result, nil
}

// ---------------------------------------------------------------------------
// Nutrients
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilNutrient(ctx context.Context, nutrient *models.SoilNutrient) (*models.SoilNutrient, error) {
	if nutrient.UUID == "" {
		nutrient.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_nutrients (
			uuid, tenant_id, sample_id, nutrient_name,
			value_ppm, level, optimal_min, optimal_max, unit, created_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, uuid, tenant_id, sample_id, nutrient_name,
			value_ppm, level, optimal_min, optimal_max, unit,
			is_active, created_by, created_at`

	var result models.SoilNutrient
	var level string
	err := r.pool.QueryRow(ctx, query,
		nutrient.UUID, nutrient.TenantID, nutrient.SampleID, nutrient.NutrientName,
		nutrient.ValuePPM, string(nutrient.Level), nutrient.OptimalMin, nutrient.OptimalMax,
		nutrient.Unit, nutrient.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.SampleID, &result.NutrientName,
		&result.ValuePPM, &level, &result.OptimalMin, &result.OptimalMax, &result.Unit,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		r.logger.Errorf("CreateSoilNutrient failed: %v", err)
		return nil, errors.InternalServer("CREATE_NUTRIENT_FAILED", fmt.Sprintf("failed to create soil nutrient: %v", err))
	}
	result.Level = mappers.NutrientLevelFromString(level)
	return &result, nil
}

func (r *soilRepository) ListNutrientsBySample(ctx context.Context, sampleID, tenantID string) ([]models.SoilNutrient, error) {
	query := `
		SELECT id, uuid, tenant_id, sample_id, nutrient_name,
			value_ppm, level, optimal_min, optimal_max, unit,
			is_active, created_by, created_at
		FROM soil_nutrients
		WHERE sample_id = $1 AND tenant_id = $2
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY nutrient_name ASC`

	rows, err := r.pool.Query(ctx, query, sampleID, tenantID)
	if err != nil {
		r.logger.Errorf("ListNutrientsBySample query failed: %v", err)
		return nil, errors.InternalServer("LIST_NUTRIENTS_FAILED", fmt.Sprintf("failed to list nutrients: %v", err))
	}
	defer rows.Close()

	nutrients := make([]models.SoilNutrient, 0)
	for rows.Next() {
		var n models.SoilNutrient
		var level string
		if err := rows.Scan(
			&n.ID, &n.UUID, &n.TenantID, &n.SampleID, &n.NutrientName,
			&n.ValuePPM, &level, &n.OptimalMin, &n.OptimalMax, &n.Unit,
			&n.IsActive, &n.CreatedBy, &n.CreatedAt,
		); err != nil {
			r.logger.Errorf("ListNutrientsBySample scan failed: %v", err)
			return nil, errors.InternalServer("LIST_NUTRIENTS_SCAN_FAILED", fmt.Sprintf("failed to scan nutrient row: %v", err))
		}
		n.Level = mappers.NutrientLevelFromString(level)
		nutrients = append(nutrients, n)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("LIST_NUTRIENTS_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return nutrients, nil
}

func (r *soilRepository) BatchCreateNutrients(ctx context.Context, nutrients []models.SoilNutrient) ([]models.SoilNutrient, error) {
	results := make([]models.SoilNutrient, 0, len(nutrients))
	for i := range nutrients {
		created, err := r.CreateSoilNutrient(ctx, &nutrients[i])
		if err != nil {
			return nil, err
		}
		results = append(results, *created)
	}
	return results, nil
}

// ---------------------------------------------------------------------------
// Health Scores
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilHealthScore(ctx context.Context, score *models.SoilHealthScore) (*models.SoilHealthScore, error) {
	if score.UUID == "" {
		score.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_health_scores (
			uuid, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at, created_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING id, uuid, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result models.SoilHealthScore
	var category string
	err := r.pool.QueryRow(ctx, query,
		score.UUID, score.TenantID, score.FieldID, score.FarmID,
		score.OverallScore, string(score.Category), score.PhysicalScore, score.ChemicalScore, score.BiologicalScore,
		score.Recommendations, score.AssessedAt, score.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.OverallScore, &category, &result.PhysicalScore, &result.ChemicalScore, &result.BiologicalScore,
		&result.Recommendations, &result.AssessedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		r.logger.Errorf("CreateSoilHealthScore failed: %v", err)
		return nil, errors.InternalServer("CREATE_HEALTH_SCORE_FAILED", fmt.Sprintf("failed to create soil health score: %v", err))
	}
	result.Category = mappers.HealthCategoryFromString(category)
	return &result, nil
}

func (r *soilRepository) GetLatestSoilHealthScore(ctx context.Context, fieldID, tenantID string) (*models.SoilHealthScore, error) {
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_health_scores
		WHERE field_id = $1 AND tenant_id = $2
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY assessed_at DESC
		LIMIT 1`

	var result models.SoilHealthScore
	var category string
	err := r.pool.QueryRow(ctx, query, fieldID, tenantID).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.OverallScore, &category, &result.PhysicalScore, &result.ChemicalScore, &result.BiologicalScore,
		&result.Recommendations, &result.AssessedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("HEALTH_SCORE_NOT_FOUND", fmt.Sprintf("no health score found for field %s", fieldID))
		}
		r.logger.Errorf("GetLatestSoilHealthScore failed: %v", err)
		return nil, errors.InternalServer("GET_HEALTH_SCORE_FAILED", fmt.Sprintf("failed to get soil health score: %v", err))
	}
	result.Category = mappers.HealthCategoryFromString(category)
	return &result, nil
}

func (r *soilRepository) UpdateSoilHealthScore(ctx context.Context, score *models.SoilHealthScore) (*models.SoilHealthScore, error) {
	query := `
		UPDATE soil_health_scores
		SET overall_score = $3, category = $4,
			physical_score = $5, chemical_score = $6, biological_score = $7,
			recommendations = $8, assessed_at = $9,
			updated_by = $10, updated_at = NOW(), version = version + 1
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result models.SoilHealthScore
	var category string
	err := r.pool.QueryRow(ctx, query,
		score.UUID, score.TenantID,
		score.OverallScore, string(score.Category),
		score.PhysicalScore, score.ChemicalScore, score.BiologicalScore,
		score.Recommendations, score.AssessedAt,
		score.CreatedBy,
	).Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.OverallScore, &category, &result.PhysicalScore, &result.ChemicalScore, &result.BiologicalScore,
		&result.Recommendations, &result.AssessedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("HEALTH_SCORE_NOT_FOUND", fmt.Sprintf("soil health score %s not found", score.UUID))
		}
		r.logger.Errorf("UpdateSoilHealthScore failed: %v", err)
		return nil, errors.InternalServer("UPDATE_HEALTH_SCORE_FAILED", fmt.Sprintf("failed to update soil health score: %v", err))
	}
	result.Category = mappers.HealthCategoryFromString(category)
	return &result, nil
}

func (r *soilRepository) ListSoilHealthScoresByFarm(ctx context.Context, farmID, tenantID string) ([]models.SoilHealthScore, error) {
	query := `
		SELECT id, uuid, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_health_scores
		WHERE farm_id = $1 AND tenant_id = $2
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY assessed_at DESC`

	rows, err := r.pool.Query(ctx, query, farmID, tenantID)
	if err != nil {
		r.logger.Errorf("ListSoilHealthScoresByFarm query failed: %v", err)
		return nil, errors.InternalServer("LIST_HEALTH_SCORES_FAILED", fmt.Sprintf("failed to list health scores: %v", err))
	}
	defer rows.Close()

	scores := make([]models.SoilHealthScore, 0)
	for rows.Next() {
		var s models.SoilHealthScore
		var category string
		if err := rows.Scan(
			&s.ID, &s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
			&s.OverallScore, &category, &s.PhysicalScore, &s.ChemicalScore, &s.BiologicalScore,
			&s.Recommendations, &s.AssessedAt,
			&s.IsActive, &s.CreatedBy, &s.CreatedAt, &s.UpdatedBy, &s.UpdatedAt, &s.Version,
		); err != nil {
			r.logger.Errorf("ListSoilHealthScoresByFarm scan failed: %v", err)
			return nil, errors.InternalServer("LIST_HEALTH_SCORES_SCAN_FAILED", fmt.Sprintf("failed to scan health score row: %v", err))
		}
		s.Category = mappers.HealthCategoryFromString(category)
		scores = append(scores, s)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("LIST_HEALTH_SCORES_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return scores, nil
}

// Ensure time import is used (used in AnalyzedAt fields).
var _ time.Time
