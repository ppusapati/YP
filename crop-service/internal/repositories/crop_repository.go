package repositories

import (
	"context"
	"fmt"
	"strings"
	"time"

	cropmodels "p9e.in/samavaya/agriculture/crop-service/internal/models"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// CropRepository defines the interface for crop persistence operations.
type CropRepository interface {
	CreateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error)
	GetCropByUUID(ctx context.Context, uuid, tenantID string) (*cropmodels.Crop, error)
	ListCrops(ctx context.Context, tenantID string, category *string, searchTerm *string, limit, offset int32) ([]*cropmodels.Crop, int32, error)
	UpdateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error)
	SoftDeleteCrop(ctx context.Context, uuid, tenantID, deletedBy string) error
	CropExistsByName(ctx context.Context, tenantID, name string) (bool, error)

	CreateVariety(ctx context.Context, variety *cropmodels.CropVariety) (*cropmodels.CropVariety, error)
	ListVarietiesByCropID(ctx context.Context, cropID int64, tenantID string, limit, offset int32) ([]*cropmodels.CropVariety, int32, error)

	GetGrowthStagesByCropID(ctx context.Context, cropID int64, tenantID string) ([]*cropmodels.CropGrowthStage, error)
	CreateGrowthStage(ctx context.Context, stage *cropmodels.CropGrowthStage) (*cropmodels.CropGrowthStage, error)

	GetCropRequirementsByCropID(ctx context.Context, cropID int64, tenantID string) (*cropmodels.CropRequirements, error)
	UpsertCropRequirements(ctx context.Context, req *cropmodels.CropRequirements) (*cropmodels.CropRequirements, error)

	CreateRecommendation(ctx context.Context, rec *cropmodels.CropRecommendation) (*cropmodels.CropRecommendation, error)
}

// cropRepository is the concrete pgx-backed implementation of CropRepository.
type cropRepository struct {
	pool   *pgxpool.Pool
	logger *p9log.Helper
}

// NewCropRepository creates a new CropRepository.
func NewCropRepository(d deps.ServiceDeps) CropRepository {
	return &cropRepository{
		pool:   d.Pool,
		logger: p9log.NewHelper(p9log.With(d.Log, "component", "CropRepository")),
	}
}

// ---------- Crop CRUD ----------

func (r *cropRepository) CreateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error) {
	query := `
		INSERT INTO crops (
			uuid, tenant_id, name, scientific_name, family, category,
			description, image_url, disease_susceptibilities, companion_plants,
			rotation_group, version, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9, $10,
			$11, $12, $13, $14, $15
		) RETURNING id, uuid, tenant_id, name, scientific_name, family, category,
			description, image_url, disease_susceptibilities, companion_plants,
			rotation_group, version, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		crop.UUID, crop.TenantID, crop.Name, crop.ScientificName, crop.Family, string(crop.Category),
		crop.Description, crop.ImageURL, crop.DiseaseSusceptibilities, crop.CompanionPlants,
		crop.RotationGroup, crop.Version, crop.IsActive, crop.CreatedBy, crop.CreatedAt,
	)

	result := &cropmodels.Crop{}
	var category string
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.Name, &result.ScientificName,
		&result.Family, &category, &result.Description, &result.ImageURL,
		&result.DiseaseSusceptibilities, &result.CompanionPlants,
		&result.RotationGroup, &result.Version, &result.IsActive,
		&result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if isDuplicateKeyError(err) {
			return nil, errors.Conflict("CROP_ALREADY_EXISTS",
				fmt.Sprintf("crop with name '%s' already exists for this tenant", crop.Name))
		}
		r.logger.Errorf("CreateCrop failed: %v", err)
		return nil, errors.InternalServer("CREATE_CROP_FAILED", "failed to create crop")
	}
	result.Category = cropmodels.CropCategory(category)
	return result, nil
}

func (r *cropRepository) GetCropByUUID(ctx context.Context, uuid, tenantID string) (*cropmodels.Crop, error) {
	query := `
		SELECT id, uuid, tenant_id, name, scientific_name, family, category,
			description, image_url, disease_susceptibilities, companion_plants,
			rotation_group, version, is_active, created_by, created_at, updated_by, updated_at
		FROM crops
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, uuid, tenantID)

	result := &cropmodels.Crop{}
	var category string
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.Name, &result.ScientificName,
		&result.Family, &category, &result.Description, &result.ImageURL,
		&result.DiseaseSusceptibilities, &result.CompanionPlants,
		&result.RotationGroup, &result.Version, &result.IsActive,
		&result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_NOT_FOUND",
				fmt.Sprintf("crop with id '%s' not found", uuid))
		}
		r.logger.Errorf("GetCropByUUID failed: %v", err)
		return nil, errors.InternalServer("GET_CROP_FAILED", "failed to retrieve crop")
	}
	result.Category = cropmodels.CropCategory(category)
	return result, nil
}

func (r *cropRepository) ListCrops(ctx context.Context, tenantID string, category *string, searchTerm *string, limit, offset int32) ([]*cropmodels.Crop, int32, error) {
	// Build dynamic WHERE clause
	args := []interface{}{tenantID}
	conditions := []string{"tenant_id = $1", "is_active = TRUE", "deleted_at IS NULL"}
	argIndex := 2

	if category != nil && *category != "" {
		conditions = append(conditions, fmt.Sprintf("category = $%d", argIndex))
		args = append(args, *category)
		argIndex++
	}

	if searchTerm != nil && *searchTerm != "" {
		conditions = append(conditions, fmt.Sprintf(
			"(name ILIKE '%%' || $%d || '%%' OR scientific_name ILIKE '%%' || $%d || '%%')",
			argIndex, argIndex))
		args = append(args, *searchTerm)
		argIndex++
	}

	whereClause := strings.Join(conditions, " AND ")

	// Count query
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM crops WHERE %s", whereClause)
	var totalCount int32
	err := r.pool.QueryRow(ctx, countQuery, args...).Scan(&totalCount)
	if err != nil {
		r.logger.Errorf("ListCrops count failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_CROPS_COUNT_FAILED", "failed to count crops")
	}

	// Default pagination
	if limit <= 0 {
		limit = 50
	}

	// Data query
	dataQuery := fmt.Sprintf(`
		SELECT id, uuid, tenant_id, name, scientific_name, family, category,
			description, image_url, disease_susceptibilities, companion_plants,
			rotation_group, version, is_active, created_by, created_at, updated_by, updated_at
		FROM crops WHERE %s ORDER BY name ASC LIMIT $%d OFFSET $%d`,
		whereClause, argIndex, argIndex+1)
	args = append(args, limit, offset)

	rows, err := r.pool.Query(ctx, dataQuery, args...)
	if err != nil {
		r.logger.Errorf("ListCrops query failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_CROPS_FAILED", "failed to list crops")
	}
	defer rows.Close()

	var crops []*cropmodels.Crop
	for rows.Next() {
		c := &cropmodels.Crop{}
		var cat string
		if err := rows.Scan(
			&c.ID, &c.UUID, &c.TenantID, &c.Name, &c.ScientificName,
			&c.Family, &cat, &c.Description, &c.ImageURL,
			&c.DiseaseSusceptibilities, &c.CompanionPlants,
			&c.RotationGroup, &c.Version, &c.IsActive,
			&c.CreatedBy, &c.CreatedAt, &c.UpdatedBy, &c.UpdatedAt,
		); err != nil {
			r.logger.Errorf("ListCrops scan failed: %v", err)
			return nil, 0, errors.InternalServer("LIST_CROPS_SCAN_FAILED", "failed to scan crop row")
		}
		c.Category = cropmodels.CropCategory(cat)
		crops = append(crops, c)
	}

	if err := rows.Err(); err != nil {
		r.logger.Errorf("ListCrops rows error: %v", err)
		return nil, 0, errors.InternalServer("LIST_CROPS_ROWS_FAILED", "error iterating crop rows")
	}

	return crops, totalCount, nil
}

func (r *cropRepository) UpdateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error) {
	now := time.Now()
	userID := p9context.UserID(ctx)

	query := `
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
			version = version + 1,
			updated_by = $12,
			updated_at = $13
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL AND version = $14
		RETURNING id, uuid, tenant_id, name, scientific_name, family, category,
			description, image_url, disease_susceptibilities, companion_plants,
			rotation_group, version, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		crop.UUID, crop.TenantID,
		crop.Name, crop.ScientificName, crop.Family, string(crop.Category),
		crop.Description, crop.ImageURL, crop.DiseaseSusceptibilities, crop.CompanionPlants,
		crop.RotationGroup, userID, now, crop.Version,
	)

	result := &cropmodels.Crop{}
	var category string
	err := row.Scan(
		&result.ID, &result.UUID, &result.TenantID, &result.Name, &result.ScientificName,
		&result.Family, &category, &result.Description, &result.ImageURL,
		&result.DiseaseSusceptibilities, &result.CompanionPlants,
		&result.RotationGroup, &result.Version, &result.IsActive,
		&result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.Conflict("CROP_VERSION_CONFLICT",
				"crop was modified by another request; please retry with the latest version")
		}
		if isDuplicateKeyError(err) {
			return nil, errors.Conflict("CROP_NAME_CONFLICT",
				fmt.Sprintf("crop with name '%s' already exists for this tenant", crop.Name))
		}
		r.logger.Errorf("UpdateCrop failed: %v", err)
		return nil, errors.InternalServer("UPDATE_CROP_FAILED", "failed to update crop")
	}
	result.Category = cropmodels.CropCategory(category)
	return result, nil
}

func (r *cropRepository) SoftDeleteCrop(ctx context.Context, uuid, tenantID, deletedBy string) error {
	query := `
		UPDATE crops SET
			is_active = FALSE,
			deleted_by = $3,
			deleted_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	cmdTag, err := r.pool.Exec(ctx, query, uuid, tenantID, deletedBy)
	if err != nil {
		r.logger.Errorf("SoftDeleteCrop failed: %v", err)
		return errors.InternalServer("DELETE_CROP_FAILED", "failed to delete crop")
	}

	if cmdTag.RowsAffected() == 0 {
		return errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop with id '%s' not found", uuid))
	}
	return nil
}

func (r *cropRepository) CropExistsByName(ctx context.Context, tenantID, name string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM crops WHERE tenant_id = $1 AND name = $2 AND is_active = TRUE AND deleted_at IS NULL)`
	var exists bool
	err := r.pool.QueryRow(ctx, query, tenantID, name).Scan(&exists)
	if err != nil {
		r.logger.Errorf("CropExistsByName failed: %v", err)
		return false, errors.InternalServer("CHECK_CROP_EXISTS_FAILED", "failed to check crop existence")
	}
	return exists, nil
}

// ---------- Variety ----------

func (r *cropRepository) CreateVariety(ctx context.Context, variety *cropmodels.CropVariety) (*cropmodels.CropVariety, error) {
	query := `
		INSERT INTO crop_varieties (
			uuid, crop_id, tenant_id, name, description, maturity_days,
			yield_potential_kg_per_hectare, is_hybrid, disease_resistance,
			suitable_regions, seed_rate_kg_per_hectare, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9,
			$10, $11, $12, $13, $14
		) RETURNING id, uuid, crop_id, tenant_id, name, description, maturity_days,
			yield_potential_kg_per_hectare, is_hybrid, disease_resistance,
			suitable_regions, seed_rate_kg_per_hectare, is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		variety.UUID, variety.CropID, variety.TenantID, variety.Name, variety.Description,
		variety.MaturityDays, variety.YieldPotentialKgPerHectare, variety.IsHybrid,
		variety.DiseaseResistance, variety.SuitableRegions, variety.SeedRateKgPerHectare,
		variety.IsActive, variety.CreatedBy, variety.CreatedAt,
	)

	result := &cropmodels.CropVariety{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.CropID, &result.TenantID, &result.Name,
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
		r.logger.Errorf("CreateVariety failed: %v", err)
		return nil, errors.InternalServer("CREATE_VARIETY_FAILED", "failed to create crop variety")
	}
	return result, nil
}

func (r *cropRepository) ListVarietiesByCropID(ctx context.Context, cropID int64, tenantID string, limit, offset int32) ([]*cropmodels.CropVariety, int32, error) {
	if limit <= 0 {
		limit = 50
	}

	// Count
	var totalCount int32
	err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM crop_varieties WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		cropID, tenantID).Scan(&totalCount)
	if err != nil {
		r.logger.Errorf("ListVarietiesByCropID count failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_VARIETIES_COUNT_FAILED", "failed to count varieties")
	}

	// Data
	rows, err := r.pool.Query(ctx, `
		SELECT id, uuid, crop_id, tenant_id, name, description, maturity_days,
			yield_potential_kg_per_hectare, is_hybrid, disease_resistance,
			suitable_regions, seed_rate_kg_per_hectare, is_active, created_by, created_at, updated_by, updated_at
		FROM crop_varieties
		WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY name ASC LIMIT $3 OFFSET $4`,
		cropID, tenantID, limit, offset)
	if err != nil {
		r.logger.Errorf("ListVarietiesByCropID query failed: %v", err)
		return nil, 0, errors.InternalServer("LIST_VARIETIES_FAILED", "failed to list varieties")
	}
	defer rows.Close()

	var varieties []*cropmodels.CropVariety
	for rows.Next() {
		v := &cropmodels.CropVariety{}
		if err := rows.Scan(
			&v.ID, &v.UUID, &v.CropID, &v.TenantID, &v.Name,
			&v.Description, &v.MaturityDays, &v.YieldPotentialKgPerHectare,
			&v.IsHybrid, &v.DiseaseResistance, &v.SuitableRegions,
			&v.SeedRateKgPerHectare, &v.IsActive, &v.CreatedBy, &v.CreatedAt,
			&v.UpdatedBy, &v.UpdatedAt,
		); err != nil {
			r.logger.Errorf("ListVarietiesByCropID scan failed: %v", err)
			return nil, 0, errors.InternalServer("LIST_VARIETIES_SCAN_FAILED", "failed to scan variety row")
		}
		varieties = append(varieties, v)
	}

	if err := rows.Err(); err != nil {
		r.logger.Errorf("ListVarietiesByCropID rows error: %v", err)
		return nil, 0, errors.InternalServer("LIST_VARIETIES_ROWS_FAILED", "error iterating variety rows")
	}

	return varieties, totalCount, nil
}

// ---------- Growth Stages ----------

func (r *cropRepository) GetGrowthStagesByCropID(ctx context.Context, cropID int64, tenantID string) ([]*cropmodels.CropGrowthStage, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT id, uuid, crop_id, tenant_id, name, stage_order, duration_days,
			water_requirement_mm, nutrient_requirements, description,
			optimal_temp_min, optimal_temp_max, is_active, created_by, created_at, updated_by, updated_at
		FROM crop_growth_stages
		WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY stage_order ASC`,
		cropID, tenantID)
	if err != nil {
		r.logger.Errorf("GetGrowthStagesByCropID query failed: %v", err)
		return nil, errors.InternalServer("GET_GROWTH_STAGES_FAILED", "failed to retrieve growth stages")
	}
	defer rows.Close()

	var stages []*cropmodels.CropGrowthStage
	for rows.Next() {
		s := &cropmodels.CropGrowthStage{}
		if err := rows.Scan(
			&s.ID, &s.UUID, &s.CropID, &s.TenantID, &s.Name, &s.StageOrder,
			&s.DurationDays, &s.WaterRequirementMM, &s.NutrientRequirements,
			&s.Description, &s.OptimalTempMin, &s.OptimalTempMax,
			&s.IsActive, &s.CreatedBy, &s.CreatedAt, &s.UpdatedBy, &s.UpdatedAt,
		); err != nil {
			r.logger.Errorf("GetGrowthStagesByCropID scan failed: %v", err)
			return nil, errors.InternalServer("GET_GROWTH_STAGES_SCAN_FAILED", "failed to scan growth stage row")
		}
		stages = append(stages, s)
	}

	if err := rows.Err(); err != nil {
		r.logger.Errorf("GetGrowthStagesByCropID rows error: %v", err)
		return nil, errors.InternalServer("GET_GROWTH_STAGES_ROWS_FAILED", "error iterating growth stage rows")
	}

	return stages, nil
}

func (r *cropRepository) CreateGrowthStage(ctx context.Context, stage *cropmodels.CropGrowthStage) (*cropmodels.CropGrowthStage, error) {
	query := `
		INSERT INTO crop_growth_stages (
			uuid, crop_id, tenant_id, name, stage_order, duration_days,
			water_requirement_mm, nutrient_requirements, description,
			optimal_temp_min, optimal_temp_max, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6,
			$7, $8, $9,
			$10, $11, $12, $13, $14
		) RETURNING id, uuid, crop_id, tenant_id, name, stage_order, duration_days,
			water_requirement_mm, nutrient_requirements, description,
			optimal_temp_min, optimal_temp_max, is_active, created_by, created_at, updated_by, updated_at`

	if stage.UUID == "" {
		stage.UUID = ulid.NewString()
	}

	row := r.pool.QueryRow(ctx, query,
		stage.UUID, stage.CropID, stage.TenantID, stage.Name, stage.StageOrder,
		stage.DurationDays, stage.WaterRequirementMM, stage.NutrientRequirements,
		stage.Description, stage.OptimalTempMin, stage.OptimalTempMax,
		stage.IsActive, stage.CreatedBy, stage.CreatedAt,
	)

	result := &cropmodels.CropGrowthStage{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.CropID, &result.TenantID, &result.Name,
		&result.StageOrder, &result.DurationDays, &result.WaterRequirementMM,
		&result.NutrientRequirements, &result.Description, &result.OptimalTempMin,
		&result.OptimalTempMax, &result.IsActive, &result.CreatedBy, &result.CreatedAt,
		&result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		if isDuplicateKeyError(err) {
			return nil, errors.Conflict("GROWTH_STAGE_ALREADY_EXISTS",
				fmt.Sprintf("growth stage '%s' already exists for this crop", stage.Name))
		}
		r.logger.Errorf("CreateGrowthStage failed: %v", err)
		return nil, errors.InternalServer("CREATE_GROWTH_STAGE_FAILED", "failed to create growth stage")
	}
	return result, nil
}

// ---------- Requirements ----------

func (r *cropRepository) GetCropRequirementsByCropID(ctx context.Context, cropID int64, tenantID string) (*cropmodels.CropRequirements, error) {
	query := `
		SELECT id, uuid, crop_id, tenant_id, optimal_temp_min, optimal_temp_max,
			optimal_humidity_min, optimal_humidity_max, optimal_soil_ph_min, optimal_soil_ph_max,
			water_requirement_mm_per_day, sunlight_hours, frost_tolerant, drought_tolerant,
			soil_type_preference, nutrient_requirements,
			is_active, created_by, created_at, updated_by, updated_at
		FROM crop_requirements
		WHERE crop_id = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`

	row := r.pool.QueryRow(ctx, query, cropID, tenantID)

	result := &cropmodels.CropRequirements{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.CropID, &result.TenantID,
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
		r.logger.Errorf("GetCropRequirementsByCropID failed: %v", err)
		return nil, errors.InternalServer("GET_CROP_REQUIREMENTS_FAILED", "failed to retrieve crop requirements")
	}
	return result, nil
}

func (r *cropRepository) UpsertCropRequirements(ctx context.Context, req *cropmodels.CropRequirements) (*cropmodels.CropRequirements, error) {
	if req.UUID == "" {
		req.UUID = ulid.NewString()
	}

	query := `
		INSERT INTO crop_requirements (
			uuid, crop_id, tenant_id, optimal_temp_min, optimal_temp_max,
			optimal_humidity_min, optimal_humidity_max, optimal_soil_ph_min, optimal_soil_ph_max,
			water_requirement_mm_per_day, sunlight_hours, frost_tolerant, drought_tolerant,
			soil_type_preference, nutrient_requirements, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9,
			$10, $11, $12, $13,
			$14, $15, TRUE, $16, $17
		) ON CONFLICT (crop_id) DO UPDATE SET
			optimal_temp_min = EXCLUDED.optimal_temp_min,
			optimal_temp_max = EXCLUDED.optimal_temp_max,
			optimal_humidity_min = EXCLUDED.optimal_humidity_min,
			optimal_humidity_max = EXCLUDED.optimal_humidity_max,
			optimal_soil_ph_min = EXCLUDED.optimal_soil_ph_min,
			optimal_soil_ph_max = EXCLUDED.optimal_soil_ph_max,
			water_requirement_mm_per_day = EXCLUDED.water_requirement_mm_per_day,
			sunlight_hours = EXCLUDED.sunlight_hours,
			frost_tolerant = EXCLUDED.frost_tolerant,
			drought_tolerant = EXCLUDED.drought_tolerant,
			soil_type_preference = EXCLUDED.soil_type_preference,
			nutrient_requirements = EXCLUDED.nutrient_requirements,
			updated_by = EXCLUDED.created_by,
			updated_at = NOW()
		RETURNING id, uuid, crop_id, tenant_id, optimal_temp_min, optimal_temp_max,
			optimal_humidity_min, optimal_humidity_max, optimal_soil_ph_min, optimal_soil_ph_max,
			water_requirement_mm_per_day, sunlight_hours, frost_tolerant, drought_tolerant,
			soil_type_preference, nutrient_requirements,
			is_active, created_by, created_at, updated_by, updated_at`

	row := r.pool.QueryRow(ctx, query,
		req.UUID, req.CropID, req.TenantID,
		req.OptimalTempMin, req.OptimalTempMax,
		req.OptimalHumidityMin, req.OptimalHumidityMax,
		req.OptimalSoilPhMin, req.OptimalSoilPhMax,
		req.WaterRequirementMMPerDay, req.SunlightHours,
		req.FrostTolerant, req.DroughtTolerant,
		req.SoilTypePreference, req.NutrientRequirements,
		req.CreatedBy, req.CreatedAt,
	)

	result := &cropmodels.CropRequirements{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.CropID, &result.TenantID,
		&result.OptimalTempMin, &result.OptimalTempMax,
		&result.OptimalHumidityMin, &result.OptimalHumidityMax,
		&result.OptimalSoilPhMin, &result.OptimalSoilPhMax,
		&result.WaterRequirementMMPerDay, &result.SunlightHours,
		&result.FrostTolerant, &result.DroughtTolerant,
		&result.SoilTypePreference, &result.NutrientRequirements,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt, &result.UpdatedBy, &result.UpdatedAt,
	)
	if err != nil {
		r.logger.Errorf("UpsertCropRequirements failed: %v", err)
		return nil, errors.InternalServer("UPSERT_CROP_REQUIREMENTS_FAILED", "failed to upsert crop requirements")
	}
	return result, nil
}

// ---------- Recommendations ----------

func (r *cropRepository) CreateRecommendation(ctx context.Context, rec *cropmodels.CropRecommendation) (*cropmodels.CropRecommendation, error) {
	if rec.UUID == "" {
		rec.UUID = ulid.NewString()
	}

	query := `
		INSERT INTO crop_recommendations (
			uuid, crop_id, tenant_id, recommendation_type, title,
			description, severity, confidence_score, parameters,
			applicable_growth_stage, valid_from, valid_until,
			is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9,
			$10, $11, $12,
			TRUE, $13, $14
		) RETURNING id, uuid, crop_id, tenant_id, recommendation_type, title,
			description, severity, confidence_score, parameters,
			applicable_growth_stage, valid_from, valid_until,
			is_active, created_by, created_at`

	row := r.pool.QueryRow(ctx, query,
		rec.UUID, rec.CropID, rec.TenantID, rec.RecommendationType, rec.Title,
		rec.Description, rec.Severity, rec.ConfidenceScore, rec.Parameters,
		rec.ApplicableGrowthStage, rec.ValidFrom, rec.ValidUntil,
		rec.CreatedBy, rec.CreatedAt,
	)

	result := &cropmodels.CropRecommendation{}
	err := row.Scan(
		&result.ID, &result.UUID, &result.CropID, &result.TenantID,
		&result.RecommendationType, &result.Title, &result.Description,
		&result.Severity, &result.ConfidenceScore, &result.Parameters,
		&result.ApplicableGrowthStage, &result.ValidFrom, &result.ValidUntil,
		&result.IsActive, &result.CreatedBy, &result.CreatedAt,
	)
	if err != nil {
		r.logger.Errorf("CreateRecommendation failed: %v", err)
		return nil, errors.InternalServer("CREATE_RECOMMENDATION_FAILED", "failed to create recommendation")
	}
	return result, nil
}

// ---------- Helpers ----------

// isDuplicateKeyError checks if a pgx error is a unique constraint violation (23505).
func isDuplicateKeyError(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(err.Error(), "23505") || strings.Contains(err.Error(), "duplicate key")
}
