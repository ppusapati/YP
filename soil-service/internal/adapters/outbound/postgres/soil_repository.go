// Package postgres implements the outbound.SoilRepository port using pgx.
package postgres

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-service/internal/ports/outbound"
)

type soilRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewSoilRepository creates a new postgres-backed SoilRepository.
func NewSoilRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.SoilRepository {
	return &soilRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SoilPostgresRepository")),
	}
}

func (r *soilRepository) WithTx(tx pgx.Tx) outbound.SoilRepository {
	return &soilRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *soilRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *soilRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *soilRepository) exec(ctx context.Context, sql string, args ...any) (int64, error) {
	if r.tx != nil {
		tag, err := r.tx.Exec(ctx, sql, args...)
		return tag.RowsAffected(), err
	}
	tag, err := r.pool.Exec(ctx, sql, args...)
	return tag.RowsAffected(), err
}

// ---------------------------------------------------------------------------
// Soil (generic aggregate root)
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error) {
	entity.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO soil_samples (id, tenant_id, field_id, farm_id, notes, texture, is_active, created_by)
		VALUES ($1,$2,'','',$3,$4,true,$5)
		RETURNING id, tenant_id, notes, texture, is_active, created_by, created_at, version`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status), entity.CreatedBy,
	)
	return scanSoil(row)
}

func (r *soilRepository) GetSoilByUUID(ctx context.Context, uuid, tenantID string) (*domain.Soil, error) {
	row := r.queryRow(ctx,
		`SELECT id, tenant_id, notes, texture, is_active, created_by, created_at, version
		FROM soil_samples WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	e, err := scanSoil(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SOIL_NOT_FOUND", fmt.Sprintf("soil not found: %s", uuid))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *soilRepository) ListSoils(ctx context.Context, params domain.ListSoilParams) ([]domain.Soil, int32, error) {
	return nil, 0, nil
}

func (r *soilRepository) UpdateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error) {
	row := r.queryRow(ctx,
		`UPDATE soil_samples SET notes=COALESCE(NULLIF($1,''),notes), texture=COALESCE(NULLIF($2,''),texture),
		updated_by=$3, updated_at=NOW(), version=version+1
		WHERE id=$4 AND tenant_id=$5 AND deleted_at IS NULL
		RETURNING id, tenant_id, notes, texture, is_active, created_by, created_at, version`,
		entity.Name, string(entity.Status), entity.UpdatedBy, entity.UUID, entity.TenantID,
	)
	e, err := scanSoil(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SOIL_NOT_FOUND", fmt.Sprintf("soil not found: %s", entity.UUID))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *soilRepository) DeleteSoil(ctx context.Context, uuid, tenantID, deletedBy string) error {
	_, err := r.exec(ctx,
		`UPDATE soil_samples SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE id=$2 AND tenant_id=$3`,
		deletedBy, uuid, tenantID,
	)
	return err
}

func (r *soilRepository) CheckSoilExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM soil_samples WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	return exists, err
}

func (r *soilRepository) CheckSoilNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM soil_samples WHERE notes=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		name, tenantID,
	).Scan(&exists)
	return exists, err
}

func scanSoil(row pgx.Row) (*domain.Soil, error) {
	e := &domain.Soil{}
	err := row.Scan(
		&e.UUID, &e.TenantID, &e.Name, &e.Status,
		&e.IsActive, &e.CreatedBy, &e.CreatedAt, &e.Version,
	)
	return e, err
}

// ---------------------------------------------------------------------------
// Samples
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilSample(ctx context.Context, sample *domain.SoilSample) (*domain.SoilSample, error) {
	if sample.UUID == "" {
		sample.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_samples (
			id, tenant_id, field_id, farm_id,
			sample_latitude, sample_longitude, sample_depth_cm, collection_date,
			ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
			calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
			zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
			texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
			collected_by, notes, created_by
		) VALUES (
			$1, $2, $3, $4,
			$5, $6, $7, $8,
			$9, $10, $11, $12, $13,
			$14, $15, $16, $17, $18,
			$19, $20, $21, $22,
			$23, $24, $25, $26,
			$27, $28, $29
		) RETURNING id, tenant_id, field_id, farm_id,
			sample_latitude, sample_longitude,
			sample_depth_cm, collection_date,
			ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
			calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
			zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
			texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
			collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version`

	var result domain.SoilSample
	var texture string
	err := r.queryRow(ctx, query,
		sample.UUID, sample.TenantID, sample.FieldID, sample.FarmID,
		sample.Latitude, sample.Longitude, sample.SampleDepthCm, sample.CollectionDate,
		sample.PH, sample.OrganicMatterPct, sample.NitrogenPPM, sample.PhosphorusPPM, sample.PotassiumPPM,
		sample.CalciumPPM, sample.MagnesiumPPM, sample.SulfurPPM, sample.IronPPM, sample.ManganesePPM,
		sample.ZincPPM, sample.CopperPPM, sample.BoronPPM, sample.MoisturePct,
		string(sample.Texture), sample.BulkDensity, sample.CationExchangeCapacity, sample.ElectricalConductivity,
		sample.CollectedBy, sample.Notes, sample.CreatedBy,
	).Scan(
		&result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
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
		r.log.Errorw("msg", "CreateSoilSample failed", "error", err)
		return nil, errors.InternalServer("CREATE_SAMPLE_FAILED", fmt.Sprintf("failed to create soil sample: %v", err))
	}
	result.Texture = domain.SoilTexture(texture)
	return &result, nil
}

func (r *soilRepository) GetSoilSampleByUUID(ctx context.Context, uuid, tenantID string) (*domain.SoilSample, error) {
	query := `
		SELECT id, tenant_id, field_id, farm_id,
			sample_latitude, sample_longitude,
			sample_depth_cm, collection_date,
			ph, organic_matter_pct, nitrogen_ppm, phosphorus_ppm, potassium_ppm,
			calcium_ppm, magnesium_ppm, sulfur_ppm, iron_ppm, manganese_ppm,
			zinc_ppm, copper_ppm, boron_ppm, moisture_pct,
			texture, bulk_density, cation_exchange_capacity, electrical_conductivity,
			collected_by, notes, is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_samples
		WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	var result domain.SoilSample
	var texture string
	err := r.queryRow(ctx, query, uuid, tenantID).Scan(
		&result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
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
		r.log.Errorw("msg", "GetSoilSampleByUUID failed", "error", err)
		return nil, errors.InternalServer("GET_SAMPLE_FAILED", fmt.Sprintf("failed to get soil sample: %v", err))
	}
	result.Texture = domain.SoilTexture(texture)
	return &result, nil
}

func (r *soilRepository) ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]domain.SoilSample, int64, error) {
	countQuery := `
		SELECT COUNT(*) FROM soil_samples
		WHERE tenant_id = $1
			AND ($2::VARCHAR = '' OR field_id = $2)
			AND ($3::VARCHAR = '' OR farm_id = $3)
			AND is_active = TRUE AND deleted_at IS NULL`

	var totalCount int64
	if err := r.queryRow(ctx, countQuery, tenantID, fieldID, farmID).Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "CountSoilSamples failed", "error", err)
		return nil, 0, errors.InternalServer("COUNT_SAMPLES_FAILED", fmt.Sprintf("failed to count soil samples: %v", err))
	}

	listQuery := `
		SELECT id, tenant_id, field_id, farm_id,
			sample_latitude, sample_longitude,
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

	rows, err := r.query(ctx, listQuery, tenantID, fieldID, farmID, pageSize, pageOffset)
	if err != nil {
		r.log.Errorw("msg", "ListSoilSamples query failed", "error", err)
		return nil, 0, errors.InternalServer("LIST_SAMPLES_FAILED", fmt.Sprintf("failed to list soil samples: %v", err))
	}
	defer rows.Close()

	samples := make([]domain.SoilSample, 0)
	for rows.Next() {
		var s domain.SoilSample
		var texture string
		if err := rows.Scan(
			&s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
			&s.Latitude, &s.Longitude,
			&s.SampleDepthCm, &s.CollectionDate,
			&s.PH, &s.OrganicMatterPct, &s.NitrogenPPM, &s.PhosphorusPPM, &s.PotassiumPPM,
			&s.CalciumPPM, &s.MagnesiumPPM, &s.SulfurPPM, &s.IronPPM, &s.ManganesePPM,
			&s.ZincPPM, &s.CopperPPM, &s.BoronPPM, &s.MoisturePct,
			&texture, &s.BulkDensity, &s.CationExchangeCapacity, &s.ElectricalConductivity,
			&s.CollectedBy, &s.Notes, &s.IsActive, &s.CreatedBy, &s.CreatedAt,
			&s.UpdatedBy, &s.UpdatedAt, &s.Version,
		); err != nil {
			r.log.Errorw("msg", "ListSoilSamples scan failed", "error", err)
			return nil, 0, errors.InternalServer("LIST_SAMPLES_SCAN_FAILED", fmt.Sprintf("failed to scan soil sample row: %v", err))
		}
		s.Texture = domain.SoilTexture(texture)
		samples = append(samples, s)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("LIST_SAMPLES_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return samples, totalCount, nil
}

func (r *soilRepository) DeleteSoilSample(ctx context.Context, uuid, tenantID string) error {
	query := `
		UPDATE soil_samples
		SET is_active = FALSE, deleted_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	affected, err := r.exec(ctx, query, uuid, tenantID)
	if err != nil {
		r.log.Errorw("msg", "DeleteSoilSample failed", "error", err)
		return errors.InternalServer("DELETE_SAMPLE_FAILED", fmt.Sprintf("failed to delete soil sample: %v", err))
	}
	if affected == 0 {
		return errors.NotFound("SAMPLE_NOT_FOUND", fmt.Sprintf("soil sample %s not found", uuid))
	}
	return nil
}

// ---------------------------------------------------------------------------
// Analyses
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilAnalysis(ctx context.Context, analysis *domain.SoilAnalysis) (*domain.SoilAnalysis, error) {
	if analysis.UUID == "" {
		analysis.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_analyses (
			id, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary, created_by
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
		) RETURNING id, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result domain.SoilAnalysis
	var status, healthCat string
	err := r.queryRow(ctx, query,
		analysis.UUID, analysis.TenantID, analysis.SampleID, analysis.FieldID, analysis.FarmID,
		string(analysis.Status), analysis.AnalysisType, analysis.SoilHealthScore, string(analysis.HealthCategory),
		analysis.Recommendations, analysis.AnalyzedBy, analysis.AnalyzedAt, analysis.Summary, analysis.CreatedBy,
	).Scan(
		&result.UUID, &result.TenantID, &result.SampleID, &result.FieldID, &result.FarmID,
		&status, &result.AnalysisType, &result.SoilHealthScore, &healthCat,
		&result.Recommendations, &result.AnalyzedBy, &result.AnalyzedAt, &result.Summary,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		r.log.Errorw("msg", "CreateSoilAnalysis failed", "error", err)
		return nil, errors.InternalServer("CREATE_ANALYSIS_FAILED", fmt.Sprintf("failed to create soil analysis: %v", err))
	}
	result.Status = domain.AnalysisStatus(status)
	result.HealthCategory = domain.HealthCategory(healthCat)
	return &result, nil
}

func (r *soilRepository) GetSoilAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*domain.SoilAnalysis, error) {
	query := `
		SELECT id, tenant_id, sample_id, field_id, farm_id,
			status, analysis_type, soil_health_score, health_category,
			recommendations, analyzed_by, analyzed_at, summary,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_analyses
		WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	var result domain.SoilAnalysis
	var status, healthCat string
	err := r.queryRow(ctx, query, uuid, tenantID).Scan(
		&result.UUID, &result.TenantID, &result.SampleID, &result.FieldID, &result.FarmID,
		&status, &result.AnalysisType, &result.SoilHealthScore, &healthCat,
		&result.Recommendations, &result.AnalyzedBy, &result.AnalyzedAt, &result.Summary,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("ANALYSIS_NOT_FOUND", fmt.Sprintf("soil analysis %s not found", uuid))
		}
		r.log.Errorw("msg", "GetSoilAnalysisByUUID failed", "error", err)
		return nil, errors.InternalServer("GET_ANALYSIS_FAILED", fmt.Sprintf("failed to get soil analysis: %v", err))
	}
	result.Status = domain.AnalysisStatus(status)
	result.HealthCategory = domain.HealthCategory(healthCat)
	return &result, nil
}

func (r *soilRepository) ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]domain.SoilAnalysis, int64, error) {
	countQuery := `
		SELECT COUNT(*) FROM soil_analyses
		WHERE tenant_id = $1
			AND ($2::VARCHAR = '' OR field_id = $2)
			AND ($3::VARCHAR = '' OR farm_id = $3)
			AND ($4::VARCHAR = '' OR sample_id = $4)
			AND is_active = TRUE AND deleted_at IS NULL`

	var totalCount int64
	if err := r.queryRow(ctx, countQuery, tenantID, fieldID, farmID, sampleID).Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "CountSoilAnalyses failed", "error", err)
		return nil, 0, errors.InternalServer("COUNT_ANALYSES_FAILED", fmt.Sprintf("failed to count soil analyses: %v", err))
	}

	listQuery := `
		SELECT id, tenant_id, sample_id, field_id, farm_id,
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

	rows, err := r.query(ctx, listQuery, tenantID, fieldID, farmID, sampleID, pageSize, pageOffset)
	if err != nil {
		r.log.Errorw("msg", "ListSoilAnalyses query failed", "error", err)
		return nil, 0, errors.InternalServer("LIST_ANALYSES_FAILED", fmt.Sprintf("failed to list soil analyses: %v", err))
	}
	defer rows.Close()

	analyses := make([]domain.SoilAnalysis, 0)
	for rows.Next() {
		var a domain.SoilAnalysis
		var status, healthCat string
		if err := rows.Scan(
			&a.UUID, &a.TenantID, &a.SampleID, &a.FieldID, &a.FarmID,
			&status, &a.AnalysisType, &a.SoilHealthScore, &healthCat,
			&a.Recommendations, &a.AnalyzedBy, &a.AnalyzedAt, &a.Summary,
			&a.IsActive, &a.CreatedBy, &a.CreatedAt, &a.UpdatedBy, &a.UpdatedAt, &a.Version,
		); err != nil {
			r.log.Errorw("msg", "ListSoilAnalyses scan failed", "error", err)
			return nil, 0, errors.InternalServer("LIST_ANALYSES_SCAN_FAILED", fmt.Sprintf("failed to scan soil analysis row: %v", err))
		}
		a.Status = domain.AnalysisStatus(status)
		a.HealthCategory = domain.HealthCategory(healthCat)
		analyses = append(analyses, a)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("LIST_ANALYSES_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return analyses, totalCount, nil
}

func (r *soilRepository) UpdateSoilAnalysisStatus(ctx context.Context, uuid string, status domain.AnalysisStatus) error {
	affected, err := r.exec(ctx,
		`UPDATE soil_analyses SET status = $2, updated_at = NOW(), version = version + 1
		WHERE id = $1 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, string(status),
	)
	if err != nil {
		r.log.Errorw("msg", "UpdateSoilAnalysisStatus failed", "error", err)
		return errors.InternalServer("UPDATE_ANALYSIS_FAILED", fmt.Sprintf("failed to update soil analysis: %v", err))
	}
	if affected == 0 {
		return errors.NotFound("ANALYSIS_NOT_FOUND", fmt.Sprintf("soil analysis %s not found", uuid))
	}
	return nil
}

// ---------------------------------------------------------------------------
// Maps
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilMap(ctx context.Context, soilMap *domain.SoilMap) (*domain.SoilMap, error) {
	if soilMap.UUID == "" {
		soilMap.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_maps (
			id, tenant_id, field_id, farm_id, map_type,
			crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
			generated_by, generated_at, created_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		RETURNING id, tenant_id, field_id, farm_id, map_type,
			crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
			generated_by, generated_at,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result domain.SoilMap
	err := r.queryRow(ctx, query,
		soilMap.UUID, soilMap.TenantID, soilMap.FieldID, soilMap.FarmID, soilMap.MapType,
		soilMap.CRS, soilMap.Resolution, soilMap.BboxMinLat, soilMap.BboxMinLng, soilMap.BboxMaxLat, soilMap.BboxMaxLng,
		soilMap.GeneratedBy, soilMap.GeneratedAt, soilMap.CreatedBy,
	).Scan(
		&result.UUID, &result.TenantID, &result.FieldID, &result.FarmID, &result.MapType,
		&result.CRS, &result.Resolution, &result.BboxMinLat, &result.BboxMinLng, &result.BboxMaxLat, &result.BboxMaxLng,
		&result.GeneratedBy, &result.GeneratedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		r.log.Errorw("msg", "CreateSoilMap failed", "error", err)
		return nil, errors.InternalServer("CREATE_MAP_FAILED", fmt.Sprintf("failed to create soil map: %v", err))
	}
	return &result, nil
}

func (r *soilRepository) GetSoilMapByFieldAndType(ctx context.Context, fieldID, tenantID, mapType string) (*domain.SoilMap, error) {
	query := `
		SELECT id, tenant_id, field_id, farm_id, map_type,
			crs, resolution, bbox_min_lat, bbox_min_lng, bbox_max_lat, bbox_max_lng,
			generated_by, generated_at,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_maps
		WHERE field_id = $1 AND tenant_id = $2 AND map_type = $3
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY generated_at DESC
		LIMIT 1`

	var result domain.SoilMap
	err := r.queryRow(ctx, query, fieldID, tenantID, mapType).Scan(
		&result.UUID, &result.TenantID, &result.FieldID, &result.FarmID, &result.MapType,
		&result.CRS, &result.Resolution, &result.BboxMinLat, &result.BboxMinLng, &result.BboxMaxLat, &result.BboxMaxLng,
		&result.GeneratedBy, &result.GeneratedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("MAP_NOT_FOUND", fmt.Sprintf("soil map for field %s type %s not found", fieldID, mapType))
		}
		r.log.Errorw("msg", "GetSoilMapByFieldAndType failed", "error", err)
		return nil, errors.InternalServer("GET_MAP_FAILED", fmt.Sprintf("failed to get soil map: %v", err))
	}
	return &result, nil
}

// ---------------------------------------------------------------------------
// Nutrients
// ---------------------------------------------------------------------------

func (r *soilRepository) CreateSoilNutrient(ctx context.Context, nutrient *domain.SoilNutrient) (*domain.SoilNutrient, error) {
	if nutrient.UUID == "" {
		nutrient.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_nutrients (
			id, tenant_id, sample_id, nutrient_name,
			value_ppm, level, optimal_min, optimal_max, unit, created_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, tenant_id, sample_id, nutrient_name,
			value_ppm, level, optimal_min, optimal_max, unit,
			is_active, created_by, created_at`

	var result domain.SoilNutrient
	var level string
	err := r.queryRow(ctx, query,
		nutrient.UUID, nutrient.TenantID, nutrient.SampleID, nutrient.NutrientName,
		nutrient.ValuePPM, string(nutrient.Level), nutrient.OptimalMin, nutrient.OptimalMax,
		nutrient.Unit, nutrient.CreatedBy,
	).Scan(
		&result.UUID, &result.TenantID, &result.SampleID, &result.NutrientName,
		&result.ValuePPM, &level, &result.OptimalMin, &result.OptimalMax, &result.Unit,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		r.log.Errorw("msg", "CreateSoilNutrient failed", "error", err)
		return nil, errors.InternalServer("CREATE_NUTRIENT_FAILED", fmt.Sprintf("failed to create soil nutrient: %v", err))
	}
	result.Level = domain.NutrientLevel(level)
	return &result, nil
}

func (r *soilRepository) ListNutrientsBySample(ctx context.Context, sampleID, tenantID string) ([]domain.SoilNutrient, error) {
	query := `
		SELECT id, tenant_id, sample_id, nutrient_name,
			value_ppm, level, optimal_min, optimal_max, unit,
			is_active, created_by, created_at
		FROM soil_nutrients
		WHERE sample_id = $1 AND tenant_id = $2
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY nutrient_name ASC`

	rows, err := r.query(ctx, query, sampleID, tenantID)
	if err != nil {
		r.log.Errorw("msg", "ListNutrientsBySample query failed", "error", err)
		return nil, errors.InternalServer("LIST_NUTRIENTS_FAILED", fmt.Sprintf("failed to list nutrients: %v", err))
	}
	defer rows.Close()

	nutrients := make([]domain.SoilNutrient, 0)
	for rows.Next() {
		var n domain.SoilNutrient
		var level string
		if err := rows.Scan(
			&n.UUID, &n.TenantID, &n.SampleID, &n.NutrientName,
			&n.ValuePPM, &level, &n.OptimalMin, &n.OptimalMax, &n.Unit,
			&n.IsActive, &n.CreatedBy, &n.CreatedAt,
		); err != nil {
			r.log.Errorw("msg", "ListNutrientsBySample scan failed", "error", err)
			return nil, errors.InternalServer("LIST_NUTRIENTS_SCAN_FAILED", fmt.Sprintf("failed to scan nutrient row: %v", err))
		}
		n.Level = domain.NutrientLevel(level)
		nutrients = append(nutrients, n)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("LIST_NUTRIENTS_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return nutrients, nil
}

func (r *soilRepository) BatchCreateNutrients(ctx context.Context, nutrients []domain.SoilNutrient) ([]domain.SoilNutrient, error) {
	results := make([]domain.SoilNutrient, 0, len(nutrients))
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

func (r *soilRepository) CreateSoilHealthScore(ctx context.Context, score *domain.SoilHealthScore) (*domain.SoilHealthScore, error) {
	if score.UUID == "" {
		score.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO soil_health_scores (
			id, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at, created_by
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING id, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result domain.SoilHealthScore
	var category string
	err := r.queryRow(ctx, query,
		score.UUID, score.TenantID, score.FieldID, score.FarmID,
		score.OverallScore, string(score.Category), score.PhysicalScore, score.ChemicalScore, score.BiologicalScore,
		score.Recommendations, score.AssessedAt, score.CreatedBy,
	).Scan(
		&result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.OverallScore, &category, &result.PhysicalScore, &result.ChemicalScore, &result.BiologicalScore,
		&result.Recommendations, &result.AssessedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		r.log.Errorw("msg", "CreateSoilHealthScore failed", "error", err)
		return nil, errors.InternalServer("CREATE_HEALTH_SCORE_FAILED", fmt.Sprintf("failed to create soil health score: %v", err))
	}
	result.Category = domain.HealthCategory(category)
	return &result, nil
}

func (r *soilRepository) GetLatestSoilHealthScore(ctx context.Context, fieldID, tenantID string) (*domain.SoilHealthScore, error) {
	query := `
		SELECT id, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_health_scores
		WHERE field_id = $1 AND tenant_id = $2
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY assessed_at DESC
		LIMIT 1`

	var result domain.SoilHealthScore
	var category string
	err := r.queryRow(ctx, query, fieldID, tenantID).Scan(
		&result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.OverallScore, &category, &result.PhysicalScore, &result.ChemicalScore, &result.BiologicalScore,
		&result.Recommendations, &result.AssessedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("HEALTH_SCORE_NOT_FOUND", fmt.Sprintf("no health score found for field %s", fieldID))
		}
		r.log.Errorw("msg", "GetLatestSoilHealthScore failed", "error", err)
		return nil, errors.InternalServer("GET_HEALTH_SCORE_FAILED", fmt.Sprintf("failed to get soil health score: %v", err))
	}
	result.Category = domain.HealthCategory(category)
	return &result, nil
}

func (r *soilRepository) UpdateSoilHealthScore(ctx context.Context, score *domain.SoilHealthScore) (*domain.SoilHealthScore, error) {
	query := `
		UPDATE soil_health_scores
		SET overall_score = $3, category = $4,
			physical_score = $5, chemical_score = $6, biological_score = $7,
			recommendations = $8, assessed_at = $9,
			updated_by = $10, updated_at = NOW(), version = version + 1
		WHERE id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version`

	var result domain.SoilHealthScore
	var category string
	err := r.queryRow(ctx, query,
		score.UUID, score.TenantID,
		score.OverallScore, string(score.Category),
		score.PhysicalScore, score.ChemicalScore, score.BiologicalScore,
		score.Recommendations, score.AssessedAt,
		score.UpdatedBy,
	).Scan(
		&result.UUID, &result.TenantID, &result.FieldID, &result.FarmID,
		&result.OverallScore, &category, &result.PhysicalScore, &result.ChemicalScore, &result.BiologicalScore,
		&result.Recommendations, &result.AssessedAt,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt, &result.Version,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("HEALTH_SCORE_NOT_FOUND", fmt.Sprintf("soil health score %s not found", score.UUID))
		}
		r.log.Errorw("msg", "UpdateSoilHealthScore failed", "error", err)
		return nil, errors.InternalServer("UPDATE_HEALTH_SCORE_FAILED", fmt.Sprintf("failed to update soil health score: %v", err))
	}
	result.Category = domain.HealthCategory(category)
	return &result, nil
}

func (r *soilRepository) ListSoilHealthScoresByFarm(ctx context.Context, farmID, tenantID string, pageSize, pageOffset int32) ([]domain.SoilHealthScore, int64, error) {
	countQuery := `
		SELECT COUNT(*) FROM soil_health_scores
		WHERE farm_id = $1 AND tenant_id = $2
			AND is_active = TRUE AND deleted_at IS NULL`

	var totalCount int64
	if err := r.queryRow(ctx, countQuery, farmID, tenantID).Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "CountSoilHealthScoresByFarm failed", "error", err)
		return nil, 0, errors.InternalServer("COUNT_HEALTH_SCORES_FAILED", fmt.Sprintf("failed to count health scores: %v", err))
	}

	query := `
		SELECT id, tenant_id, field_id, farm_id,
			overall_score, category, physical_score, chemical_score, biological_score,
			recommendations, assessed_at,
			is_active, created_by, created_at, updated_by, updated_at, version
		FROM soil_health_scores
		WHERE farm_id = $1 AND tenant_id = $2
			AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY assessed_at DESC
		LIMIT $3 OFFSET $4`

	rows, err := r.query(ctx, query, farmID, tenantID, pageSize, pageOffset)
	if err != nil {
		r.log.Errorw("msg", "ListSoilHealthScoresByFarm query failed", "error", err)
		return nil, 0, errors.InternalServer("LIST_HEALTH_SCORES_FAILED", fmt.Sprintf("failed to list health scores: %v", err))
	}
	defer rows.Close()

	scores := make([]domain.SoilHealthScore, 0)
	for rows.Next() {
		var s domain.SoilHealthScore
		var category string
		if err := rows.Scan(
			&s.UUID, &s.TenantID, &s.FieldID, &s.FarmID,
			&s.OverallScore, &category, &s.PhysicalScore, &s.ChemicalScore, &s.BiologicalScore,
			&s.Recommendations, &s.AssessedAt,
			&s.IsActive, &s.CreatedBy, &s.CreatedAt, &s.UpdatedBy, &s.UpdatedAt, &s.Version,
		); err != nil {
			r.log.Errorw("msg", "ListSoilHealthScoresByFarm scan failed", "error", err)
			return nil, 0, errors.InternalServer("LIST_HEALTH_SCORES_SCAN_FAILED", fmt.Sprintf("failed to scan health score row: %v", err))
		}
		s.Category = domain.HealthCategory(category)
		scores = append(scores, s)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("LIST_HEALTH_SCORES_ROWS_ERR", fmt.Sprintf("row iteration error: %v", err))
	}
	return scores, totalCount, nil
}
