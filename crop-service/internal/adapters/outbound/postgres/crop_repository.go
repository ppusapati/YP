// Package postgres implements the outbound.CropRepository port using pgx.
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

	"p9e.in/samavaya/agriculture/crop-service/internal/domain"
	"p9e.in/samavaya/agriculture/crop-service/internal/ports/outbound"
)

type cropRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewCropRepository creates a new postgres-backed CropRepository.
func NewCropRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.CropRepository {
	return &cropRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "CropPostgresRepository")),
	}
}

func (r *cropRepository) WithTx(tx pgx.Tx) outbound.CropRepository {
	return &cropRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *cropRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *cropRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *cropRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------- Crop CRUD ----------

const cropColumns = `id, tenant_id, name, scientific_name, family, category,
	description, image_url, disease_susceptibilities, companion_plants,
	rotation_group, version, status, is_active, created_by, created_at,
	updated_by, updated_at, deleted_by, deleted_at`

func (r *cropRepository) CreateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
	if entity.UUID == "" {
		entity.UUID = ulid.NewString()
	}
	query := fmt.Sprintf(`
		INSERT INTO crops (
			id, tenant_id, name, scientific_name, family, category,
			description, image_url, disease_susceptibilities, companion_plants,
			rotation_group, version, status, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9, $10,
			$11, $12, $13, $14, $15, NOW()
		) RETURNING %s`, cropColumns)

	row := r.queryRow(ctx, query,
		entity.UUID, entity.TenantID, entity.Name, entity.ScientificName, entity.Family, string(entity.Category),
		entity.Description, entity.ImageURL, entity.DiseaseSusceptibilities, entity.CompanionPlants,
		entity.RotationGroup, entity.Version, string(entity.Status), entity.IsActive, entity.CreatedBy,
	)

	result, err := scanCrop(row)
	if err != nil {
		if isDuplicateKeyError(err) {
			return nil, errors.Conflict("CROP_ALREADY_EXISTS",
				fmt.Sprintf("crop with name '%s' already exists for this tenant", entity.Name))
		}
		r.log.Errorw("msg", "CreateCrop failed", "error", err)
		return nil, errors.InternalServer("CREATE_CROP_FAILED", "failed to create crop")
	}
	return result, nil
}

func (r *cropRepository) GetCropByUUID(ctx context.Context, uuid, tenantID string) (*domain.Crop, error) {
	query := fmt.Sprintf(`SELECT %s FROM crops WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL`, cropColumns)
	row := r.queryRow(ctx, query, uuid, tenantID)

	result, err := scanCrop(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", uuid))
		}
		r.log.Errorw("msg", "GetCropByUUID failed", "error", err)
		return nil, errors.InternalServer("GET_CROP_FAILED", "failed to retrieve crop")
	}
	return result, nil
}

func (r *cropRepository) ListCrops(ctx context.Context, params domain.ListCropParams) ([]domain.Crop, int32, error) {
	args := []interface{}{params.TenantID}
	conditions := []string{"tenant_id = $1", "deleted_at IS NULL"}
	argIndex := 2

	if params.Status != nil && *params.Status != "" {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argIndex))
		args = append(args, string(*params.Status))
		argIndex++
	}

	if params.Search != nil && *params.Search != "" {
		conditions = append(conditions, fmt.Sprintf(
			"(name ILIKE '%%' || $%d || '%%' OR scientific_name ILIKE '%%' || $%d || '%%')",
			argIndex, argIndex))
		args = append(args, *params.Search)
		argIndex++
	}

	whereClause := strings.Join(conditions, " AND ")

	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM crops WHERE %s", whereClause)
	var totalCount int32
	if err := r.queryRow(ctx, countQuery, args...).Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "ListCrops count failed", "error", err)
		return nil, 0, errors.InternalServer("LIST_CROPS_COUNT_FAILED", "failed to count crops")
	}

	pageSize := params.PageSize
	if pageSize <= 0 {
		pageSize = 50
	}

	dataQuery := fmt.Sprintf(`SELECT %s FROM crops WHERE %s ORDER BY name ASC LIMIT $%d OFFSET $%d`,
		cropColumns, whereClause, argIndex, argIndex+1)
	args = append(args, pageSize, params.Offset)

	rows, err := r.query(ctx, dataQuery, args...)
	if err != nil {
		r.log.Errorw("msg", "ListCrops query failed", "error", err)
		return nil, 0, errors.InternalServer("LIST_CROPS_FAILED", "failed to list crops")
	}
	defer rows.Close()

	var crops []domain.Crop
	for rows.Next() {
		c, err := scanCrop(rows)
		if err != nil {
			r.log.Errorw("msg", "ListCrops scan failed", "error", err)
			return nil, 0, errors.InternalServer("LIST_CROPS_SCAN_FAILED", "failed to scan crop row")
		}
		crops = append(crops, *c)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "ListCrops rows error", "error", err)
		return nil, 0, errors.InternalServer("LIST_CROPS_ROWS_FAILED", "error iterating crop rows")
	}

	return crops, totalCount, nil
}

func (r *cropRepository) UpdateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
	query := fmt.Sprintf(`
		UPDATE crops SET
			name = $3,
			scientific_name = $4,
			family = $5,
			category = $6,
			description = $7,
			image_url = $8,
			disease_susceptibilities = $9,
			companion_plants = $10,
			rotation_group = $11,
			status = $12,
			version = version + 1,
			updated_by = $13,
			updated_at = NOW()
		WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL
		RETURNING %s`, cropColumns)

	row := r.queryRow(ctx, query,
		entity.UUID, entity.TenantID,
		entity.Name, entity.ScientificName, entity.Family, string(entity.Category),
		entity.Description, entity.ImageURL, entity.DiseaseSusceptibilities, entity.CompanionPlants,
		entity.RotationGroup, string(entity.Status), entity.UpdatedBy,
	)

	result, err := scanCrop(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", entity.UUID))
		}
		if isDuplicateKeyError(err) {
			return nil, errors.Conflict("CROP_NAME_CONFLICT",
				fmt.Sprintf("crop with name '%s' already exists for this tenant", entity.Name))
		}
		r.log.Errorw("msg", "UpdateCrop failed", "error", err)
		return nil, errors.InternalServer("UPDATE_CROP_FAILED", "failed to update crop")
	}
	return result, nil
}

func (r *cropRepository) DeleteCrop(ctx context.Context, uuid, tenantID, deletedBy string) error {
	if err := r.exec(ctx,
		`UPDATE crops SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE id=$2 AND tenant_id=$3 AND deleted_at IS NULL`,
		deletedBy, uuid, tenantID,
	); err != nil {
		r.log.Errorw("msg", "DeleteCrop failed", "error", err)
		return errors.InternalServer("DELETE_CROP_FAILED", "failed to delete crop")
	}
	return nil
}

func (r *cropRepository) CheckCropExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM crops WHERE id=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	if err != nil {
		return false, errors.InternalServer("CHECK_CROP_EXISTS_FAILED", "failed to check crop existence")
	}
	return exists, nil
}

func (r *cropRepository) CheckCropNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM crops WHERE name=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		name, tenantID,
	).Scan(&exists)
	if err != nil {
		return false, errors.InternalServer("CHECK_CROP_NAME_EXISTS_FAILED", "failed to check crop name existence")
	}
	return exists, nil
}

func (r *cropRepository) CropExistsByName(ctx context.Context, tenantID, name string) (bool, error) {
	return r.CheckCropNameExists(ctx, name, tenantID)
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanCrop(row rowScanner) (*domain.Crop, error) {
	e := &domain.Crop{}
	var category, status string
	err := row.Scan(
		&e.UUID, &e.TenantID, &e.Name, &e.ScientificName, &e.Family, &category,
		&e.Description, &e.ImageURL, &e.DiseaseSusceptibilities, &e.CompanionPlants,
		&e.RotationGroup, &e.Version, &status, &e.IsActive, &e.CreatedBy, &e.CreatedAt,
		&e.UpdatedBy, &e.UpdatedAt, &e.DeletedBy, &e.DeletedAt,
	)
	if err != nil {
		return nil, err
	}
	e.Category = domain.CropCategory(category)
	e.Status = domain.CropStatus(status)
	return e, nil
}

// ---------- Variety ----------

func (r *cropRepository) CreateVariety(ctx context.Context, variety *domain.CropVariety) (*domain.CropVariety, error) {
	if variety.UUID == "" {
		variety.UUID = ulid.NewString()
	}
	query := `
		INSERT INTO crop_varieties (
			id, crop_id, tenant_id, name, description, maturity_days,
			yield_potential_kg_per_hectare, is_hybrid, disease_resistance,
			suitable_regions, seed_rate_kg_per_hectare, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9,
			$10, $11, $12, $13, NOW()
		) RETURNING id, crop_id, tenant_id, name, description, maturity_days,
			yield_potential_kg_per_hectare, is_hybrid, disease_resistance,
			suitable_regions, seed_rate_kg_per_hectare, is_active, created_by, created_at, updated_by, updated_at`

	row := r.queryRow(ctx, query,
		variety.UUID, variety.CropID, variety.TenantID, variety.Name, variety.Description,
		variety.MaturityDays, variety.YieldPotentialKgPerHectare, variety.IsHybrid,
		variety.DiseaseResistance, variety.SuitableRegions, variety.SeedRateKgPerHectare,
		variety.IsActive, variety.CreatedBy,
	)

	result := &domain.CropVariety{}
	err := row.Scan(
		&result.UUID, &result.CropID, &result.TenantID, &result.Name,
		&result.Description, &result.MaturityDays, &result.YieldPotentialKgPerHectare,
		&result.IsHybrid, &result.DiseaseResistance, &result.SuitableRegions,
		&result.SeedRateKgPerHectare, &result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if isDuplicateKeyError(err) {
			return nil, errors.Conflict("VARIETY_ALREADY_EXISTS",
				fmt.Sprintf("variety with name '%s' already exists for this crop", variety.Name))
		}
		r.log.Errorw("msg", "CreateVariety failed", "error", err)
		return nil, errors.InternalServer("CREATE_VARIETY_FAILED", "failed to create crop variety")
	}
	return result, nil
}

func (r *cropRepository) ListVarietiesByCropID(ctx context.Context, cropID int64, tenantID string, limit, offset int32) ([]*domain.CropVariety, int32, error) {
	if limit <= 0 {
		limit = 50
	}

	var totalCount int32
	err := r.queryRow(ctx,
		`SELECT COUNT(*) FROM crop_varieties WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		cropID, tenantID).Scan(&totalCount)
	if err != nil {
		r.log.Errorw("msg", "ListVarietiesByCropID count failed", "error", err)
		return nil, 0, errors.InternalServer("LIST_VARIETIES_COUNT_FAILED", "failed to count varieties")
	}

	rows, err := r.query(ctx, `
		SELECT id, crop_id, tenant_id, name, description, maturity_days,
			yield_potential_kg_per_hectare, is_hybrid, disease_resistance,
			suitable_regions, seed_rate_kg_per_hectare, is_active, created_by, created_at, updated_by, updated_at
		FROM crop_varieties
		WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY name ASC LIMIT $3 OFFSET $4`,
		cropID, tenantID, limit, offset)
	if err != nil {
		r.log.Errorw("msg", "ListVarietiesByCropID query failed", "error", err)
		return nil, 0, errors.InternalServer("LIST_VARIETIES_FAILED", "failed to list varieties")
	}
	defer rows.Close()

	var varieties []*domain.CropVariety
	for rows.Next() {
		v := &domain.CropVariety{}
		if err := rows.Scan(
			&v.UUID, &v.CropID, &v.TenantID, &v.Name,
			&v.Description, &v.MaturityDays, &v.YieldPotentialKgPerHectare,
			&v.IsHybrid, &v.DiseaseResistance, &v.SuitableRegions,
			&v.SeedRateKgPerHectare, &v.IsActive, &v.CreatedBy, &v.CreatedAt,
			&v.UpdatedBy, &v.UpdatedAt,
		); err != nil {
			r.log.Errorw("msg", "ListVarietiesByCropID scan failed", "error", err)
			return nil, 0, errors.InternalServer("LIST_VARIETIES_SCAN_FAILED", "failed to scan variety row")
		}
		varieties = append(varieties, v)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "ListVarietiesByCropID rows error", "error", err)
		return nil, 0, errors.InternalServer("LIST_VARIETIES_ROWS_FAILED", "error iterating variety rows")
	}

	return varieties, totalCount, nil
}

// ---------- Growth Stages ----------

func (r *cropRepository) GetGrowthStagesByCropID(ctx context.Context, cropID int64, tenantID string) ([]*domain.CropGrowthStage, error) {
	rows, err := r.query(ctx, `
		SELECT id, crop_id, tenant_id, name, stage_order, duration_days,
			water_requirement_mm, nutrient_requirements, description,
			optimal_temp_min, optimal_temp_max, is_active, created_by, created_at, updated_by, updated_at
		FROM crop_growth_stages
		WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY stage_order ASC`,
		cropID, tenantID)
	if err != nil {
		r.log.Errorw("msg", "GetGrowthStagesByCropID query failed", "error", err)
		return nil, errors.InternalServer("GET_GROWTH_STAGES_FAILED", "failed to retrieve growth stages")
	}
	defer rows.Close()

	var stages []*domain.CropGrowthStage
	for rows.Next() {
		s := &domain.CropGrowthStage{}
		if err := rows.Scan(
			&s.UUID, &s.CropID, &s.TenantID, &s.Name, &s.StageOrder,
			&s.DurationDays, &s.WaterRequirementMM, &s.NutrientRequirements,
			&s.Description, &s.OptimalTempMin, &s.OptimalTempMax,
			&s.IsActive, &s.CreatedBy, &s.CreatedAt, &s.UpdatedBy, &s.UpdatedAt,
		); err != nil {
			r.log.Errorw("msg", "GetGrowthStagesByCropID scan failed", "error", err)
			return nil, errors.InternalServer("GET_GROWTH_STAGES_SCAN_FAILED", "failed to scan growth stage row")
		}
		stages = append(stages, s)
	}
	if err := rows.Err(); err != nil {
		r.log.Errorw("msg", "GetGrowthStagesByCropID rows error", "error", err)
		return nil, errors.InternalServer("GET_GROWTH_STAGES_ROWS_FAILED", "error iterating growth stage rows")
	}

	return stages, nil
}

// ---------- Requirements ----------

func (r *cropRepository) GetCropRequirementsByCropID(ctx context.Context, cropID int64, tenantID string) (*domain.CropRequirements, error) {
	query := `
		SELECT id, crop_id, tenant_id, optimal_temp_min, optimal_temp_max,
			optimal_humidity_min, optimal_humidity_max, optimal_soil_ph_min, optimal_soil_ph_max,
			water_requirement_mm_per_day, sunlight_hours, frost_tolerant, drought_tolerant,
			soil_type_preference, nutrient_requirements,
			is_active, created_by, created_at, updated_by, updated_at
		FROM crop_requirements
		WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	row := r.queryRow(ctx, query, cropID, tenantID)

	result := &domain.CropRequirements{}
	err := row.Scan(
		&result.UUID, &result.CropID, &result.TenantID,
		&result.OptimalTempMin, &result.OptimalTempMax,
		&result.OptimalHumidityMin, &result.OptimalHumidityMax,
		&result.OptimalSoilPhMin, &result.OptimalSoilPhMax,
		&result.WaterRequirementMMPerDay, &result.SunlightHours,
		&result.FrostTolerant, &result.DroughtTolerant,
		&result.SoilTypePreference, &result.NutrientRequirements,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_REQUIREMENTS_NOT_FOUND", "crop requirements not found")
		}
		r.log.Errorw("msg", "GetCropRequirementsByCropID failed", "error", err)
		return nil, errors.InternalServer("GET_CROP_REQUIREMENTS_FAILED", "failed to retrieve crop requirements")
	}
	return result, nil
}

// ---------- Recommendations ----------

func (r *cropRepository) CreateRecommendation(ctx context.Context, rec *domain.CropRecommendation) (*domain.CropRecommendation, error) {
	if rec.UUID == "" {
		rec.UUID = ulid.NewString()
	}

	query := `
		INSERT INTO crop_recommendations (
			id, crop_id, tenant_id, recommendation_type, title,
			description, severity, confidence_score, parameters,
			applicable_growth_stage, valid_from, valid_until,
			is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9,
			$10, $11, $12,
			TRUE, $13, NOW()
		) RETURNING id, crop_id, tenant_id, recommendation_type, title,
			description, severity, confidence_score, parameters,
			applicable_growth_stage, valid_from, valid_until,
			is_active, created_by, created_at`

	row := r.queryRow(ctx, query,
		rec.UUID, rec.CropID, rec.TenantID, rec.RecommendationType, rec.Title,
		rec.Description, rec.Severity, rec.ConfidenceScore, rec.Parameters,
		rec.ApplicableGrowthStage, rec.ValidFrom, rec.ValidUntil,
		rec.CreatedBy,
	)

	result := &domain.CropRecommendation{}
	err := row.Scan(
		&result.UUID, &result.CropID, &result.TenantID,
		&result.RecommendationType, &result.Title, &result.Description,
		&result.Severity, &result.ConfidenceScore, &result.Parameters,
		&result.ApplicableGrowthStage, &result.ValidFrom, &result.ValidUntil,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		r.log.Errorw("msg", "CreateRecommendation failed", "error", err)
		return nil, errors.InternalServer("CREATE_RECOMMENDATION_FAILED", "failed to create recommendation")
	}
	return result, nil
}

// ---------- Helpers ----------

func isDuplicateKeyError(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(err.Error(), "23505") || strings.Contains(err.Error(), "duplicate key")
}
