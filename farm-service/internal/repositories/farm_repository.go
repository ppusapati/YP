package repositories

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	farmmodels "p9e.in/samavaya/agriculture/farm-service/internal/models"
)

// FarmRepository defines the interface for farm persistence operations.
type FarmRepository interface {
	CreateFarm(ctx context.Context, farm *farmmodels.Farm) (*farmmodels.Farm, error)
	GetFarmByUUID(ctx context.Context, uuid, tenantID string) (*farmmodels.Farm, error)
	ListFarms(ctx context.Context, params farmmodels.ListFarmsParams) ([]farmmodels.Farm, int32, error)
	UpdateFarm(ctx context.Context, farm *farmmodels.Farm) (*farmmodels.Farm, error)
	DeleteFarm(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckFarmExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckFarmNameExists(ctx context.Context, name, tenantID string) (bool, error)

	CreateFarmBoundary(ctx context.Context, boundary *farmmodels.FarmBoundary) (*farmmodels.FarmBoundary, error)
	GetFarmBoundaryByFarmUUID(ctx context.Context, farmUUID, tenantID string) (*farmmodels.FarmBoundary, error)
	UpdateFarmBoundary(ctx context.Context, boundary *farmmodels.FarmBoundary) (*farmmodels.FarmBoundary, error)
	DeleteFarmBoundary(ctx context.Context, farmUUID, tenantID, deletedBy string) error

	CreateFarmOwner(ctx context.Context, owner *farmmodels.FarmOwner) (*farmmodels.FarmOwner, error)
	GetFarmOwnersByFarmUUID(ctx context.Context, farmUUID, tenantID string) ([]farmmodels.FarmOwner, error)
	GetFarmOwnerByUserID(ctx context.Context, farmUUID, tenantID, userID string) (*farmmodels.FarmOwner, error)
	DeactivateFarmOwner(ctx context.Context, farmUUID, tenantID, userID, deletedBy string) error
	ClearPrimaryOwner(ctx context.Context, farmUUID, tenantID, updatedBy string) error

	// Transaction support: accept a pgx.Tx for use within a UoW
	WithTx(tx pgx.Tx) FarmRepository
}

// farmRepository is the concrete implementation of FarmRepository.
type farmRepository struct {
	d      deps.ServiceDeps
	log    *p9log.Helper
	tx     pgx.Tx
}

// NewFarmRepository creates a new FarmRepository.
func NewFarmRepository(d deps.ServiceDeps) FarmRepository {
	return &farmRepository{
		d:   d,
		log: p9log.NewHelper(p9log.With(d.Log, "component", "FarmRepository")),
	}
}

// WithTx returns a copy of the repository that uses the provided transaction.
func (r *farmRepository) WithTx(tx pgx.Tx) FarmRepository {
	return &farmRepository{
		d:   r.d,
		log: r.log,
		tx:  tx,
	}
}

// querier returns the pgx.Tx if set, otherwise the pool.
func (r *farmRepository) querier() interface {
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
	Exec(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
} {
	if r.tx != nil {
		return r.tx
	}
	return nil
}

// queryRow is a helper to use the tx or pool for single-row queries.
func (r *farmRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.d.Pool.QueryRow(ctx, sql, args...)
}

// query is a helper to use the tx or pool for multi-row queries.
func (r *farmRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.d.Pool.Query(ctx, sql, args...)
}

// exec is a helper to use the tx or pool for exec statements.
func (r *farmRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.d.Pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---------- Farm CRUD ----------

func (r *farmRepository) CreateFarm(ctx context.Context, farm *farmmodels.Farm) (*farmmodels.Farm, error) {
	farm.UUID = ulid.NewString()
	farm.CreatedAt = time.Now()
	farm.IsActive = true
	farm.Version = 1

	metaJSON := json.RawMessage("{}")
	if len(farm.Metadata) > 0 {
		metaJSON = farm.Metadata
	}

	row := r.queryRow(ctx, `
		INSERT INTO farms (
			uuid, tenant_id, name, description, total_area_hectares,
			latitude, longitude, elevation_meters, farm_type, status,
			soil_type, climate_zone, address, region, country,
			metadata, version, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9, $10,
			$11, $12, $13, $14, $15,
			$16, 1, TRUE, $17, NOW()
		)
		RETURNING id, uuid, tenant_id, name, description, total_area_hectares,
			latitude, longitude, elevation_meters, farm_type, status,
			soil_type, climate_zone, address, region, country,
			metadata, version, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at`,
		farm.UUID, farm.TenantID, farm.Name, farm.Description, farm.TotalAreaHectares,
		farm.Latitude, farm.Longitude, farm.ElevationMeters, farm.FarmType, farmmodels.FarmStatusPending,
		farm.SoilType, farm.ClimateZone, farm.Address, farm.Region, farm.Country,
		metaJSON, farm.CreatedBy,
	)

	result := &farmmodels.Farm{}
	if err := scanFarm(row, result); err != nil {
		r.log.Errorw("msg", "failed to create farm", "error", err)
		return nil, errors.InternalServer("FARM_CREATE_FAILED", fmt.Sprintf("failed to create farm: %v", err))
	}

	r.log.Infow("msg", "farm created", "uuid", result.UUID, "tenant_id", result.TenantID)
	return result, nil
}

func (r *farmRepository) GetFarmByUUID(ctx context.Context, uuid, tenantID string) (*farmmodels.Farm, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, tenant_id, name, description, total_area_hectares,
			latitude, longitude, elevation_meters, farm_type, status,
			soil_type, climate_zone, address, region, country,
			metadata, version, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM farms
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID,
	)

	farm := &farmmodels.Farm{}
	if err := scanFarm(row, farm); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get farm", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("FARM_GET_FAILED", fmt.Sprintf("failed to get farm: %v", err))
	}

	return farm, nil
}

func (r *farmRepository) ListFarms(ctx context.Context, params farmmodels.ListFarmsParams) ([]farmmodels.Farm, int32, error) {
	// Count total matching records
	var totalCount int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM farms
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_type = $2::farm_type)
			AND ($3::VARCHAR IS NULL OR status = $3::farm_status)
			AND ($4::VARCHAR IS NULL OR region = $4)
			AND ($5::VARCHAR IS NULL OR country = $5)
			AND ($6::VARCHAR IS NULL OR climate_zone = $6::climate_zone)
			AND ($7::VARCHAR IS NULL OR name ILIKE '%' || $7 || '%')`,
		params.TenantID,
		nullableString(params.FarmType),
		nullableString(params.Status),
		params.Region,
		params.Country,
		nullableString(params.ClimateZone),
		params.Search,
	)
	if err := countRow.Scan(&totalCount); err != nil {
		r.log.Errorw("msg", "failed to count farms", "error", err)
		return nil, 0, errors.InternalServer("FARM_COUNT_FAILED", fmt.Sprintf("failed to count farms: %v", err))
	}

	// Fetch the page
	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, name, description, total_area_hectares,
			latitude, longitude, elevation_meters, farm_type, status,
			soil_type, climate_zone, address, region, country,
			metadata, version, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM farms
		WHERE tenant_id = $1
			AND is_active = TRUE
			AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_type = $2::farm_type)
			AND ($3::VARCHAR IS NULL OR status = $3::farm_status)
			AND ($4::VARCHAR IS NULL OR region = $4)
			AND ($5::VARCHAR IS NULL OR country = $5)
			AND ($6::VARCHAR IS NULL OR climate_zone = $6::climate_zone)
			AND ($7::VARCHAR IS NULL OR name ILIKE '%' || $7 || '%')
		ORDER BY created_at DESC
		LIMIT $8 OFFSET $9`,
		params.TenantID,
		nullableString(params.FarmType),
		nullableString(params.Status),
		params.Region,
		params.Country,
		nullableString(params.ClimateZone),
		params.Search,
		params.PageSize,
		params.Offset,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list farms", "error", err)
		return nil, 0, errors.InternalServer("FARM_LIST_FAILED", fmt.Sprintf("failed to list farms: %v", err))
	}
	defer rows.Close()

	farms := make([]farmmodels.Farm, 0)
	for rows.Next() {
		var farm farmmodels.Farm
		if err := scanFarmFromRows(rows, &farm); err != nil {
			r.log.Errorw("msg", "failed to scan farm row", "error", err)
			return nil, 0, errors.InternalServer("FARM_SCAN_FAILED", fmt.Sprintf("failed to scan farm: %v", err))
		}
		farms = append(farms, farm)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("FARM_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return farms, totalCount, nil
}

func (r *farmRepository) UpdateFarm(ctx context.Context, farm *farmmodels.Farm) (*farmmodels.Farm, error) {
	metaJSON := json.RawMessage(nil)
	if len(farm.Metadata) > 0 {
		metaJSON = farm.Metadata
	}

	row := r.queryRow(ctx, `
		UPDATE farms SET
			name = COALESCE($3, name),
			description = COALESCE($4, description),
			total_area_hectares = COALESCE($5, total_area_hectares),
			latitude = COALESCE($6, latitude),
			longitude = COALESCE($7, longitude),
			elevation_meters = COALESCE($8, elevation_meters),
			farm_type = COALESCE($9::farm_type, farm_type),
			status = COALESCE($10::farm_status, status),
			soil_type = COALESCE($11::soil_type, soil_type),
			climate_zone = COALESCE($12::climate_zone, climate_zone),
			address = COALESCE($13, address),
			region = COALESCE($14, region),
			country = COALESCE($15, country),
			metadata = COALESCE($16, metadata),
			version = version + 1,
			updated_by = $17,
			updated_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, tenant_id, name, description, total_area_hectares,
			latitude, longitude, elevation_meters, farm_type, status,
			soil_type, climate_zone, address, region, country,
			metadata, version, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at`,
		farm.UUID, farm.TenantID,
		nilIfEmpty(farm.Name), farm.Description,
		nilIfZeroFloat(farm.TotalAreaHectares),
		farm.Latitude, farm.Longitude, farm.ElevationMeters,
		nilIfEmptyFarmType(farm.FarmType), nilIfEmptyFarmStatus(farm.Status),
		farm.SoilType, farm.ClimateZone,
		farm.Address, farm.Region, farm.Country,
		metaJSON, farm.UpdatedBy,
	)

	result := &farmmodels.Farm{}
	if err := scanFarm(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", farm.UUID))
		}
		r.log.Errorw("msg", "failed to update farm", "uuid", farm.UUID, "error", err)
		return nil, errors.InternalServer("FARM_UPDATE_FAILED", fmt.Sprintf("failed to update farm: %v", err))
	}

	r.log.Infow("msg", "farm updated", "uuid", result.UUID, "version", result.Version)
	return result, nil
}

func (r *farmRepository) DeleteFarm(ctx context.Context, uuid, tenantID, deletedBy string) error {
	err := r.exec(ctx, `
		UPDATE farms SET
			is_active = FALSE,
			deleted_by = $3,
			deleted_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID, deletedBy,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to delete farm", "uuid", uuid, "error", err)
		return errors.InternalServer("FARM_DELETE_FAILED", fmt.Sprintf("failed to delete farm: %v", err))
	}

	r.log.Infow("msg", "farm deleted", "uuid", uuid)
	return nil
}

func (r *farmRepository) CheckFarmExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	row := r.queryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM farms
			WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		)`,
		uuid, tenantID,
	)
	if err := row.Scan(&exists); err != nil {
		return false, errors.InternalServer("FARM_CHECK_FAILED", fmt.Sprintf("failed to check farm exists: %v", err))
	}
	return exists, nil
}

func (r *farmRepository) CheckFarmNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	row := r.queryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM farms
			WHERE name = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		)`,
		name, tenantID,
	)
	if err := row.Scan(&exists); err != nil {
		return false, errors.InternalServer("FARM_NAME_CHECK_FAILED", fmt.Sprintf("failed to check farm name exists: %v", err))
	}
	return exists, nil
}

// ---------- Farm Boundary ----------

func (r *farmRepository) CreateFarmBoundary(ctx context.Context, boundary *farmmodels.FarmBoundary) (*farmmodels.FarmBoundary, error) {
	boundary.UUID = ulid.NewString()
	boundary.CreatedAt = time.Now()
	boundary.IsActive = true

	row := r.queryRow(ctx, `
		INSERT INTO farm_boundaries (
			uuid, farm_id, farm_uuid, tenant_id, geojson,
			boundary, area_hectares, perimeter_meters,
			is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			ST_GeomFromGeoJSON($5), $6, $7,
			TRUE, $8, NOW()
		)
		RETURNING id, uuid, farm_id, farm_uuid, tenant_id, geojson,
			area_hectares, perimeter_meters, is_active,
			created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		boundary.UUID, boundary.FarmID, boundary.FarmUUID, boundary.TenantID,
		boundary.GeoJSON, boundary.AreaHectares, boundary.PerimeterMeters,
		boundary.CreatedBy,
	)

	result := &farmmodels.FarmBoundary{}
	if err := scanBoundary(row, result); err != nil {
		r.log.Errorw("msg", "failed to create farm boundary", "farm_uuid", boundary.FarmUUID, "error", err)
		return nil, errors.InternalServer("BOUNDARY_CREATE_FAILED", fmt.Sprintf("failed to create boundary: %v", err))
	}

	return result, nil
}

func (r *farmRepository) GetFarmBoundaryByFarmUUID(ctx context.Context, farmUUID, tenantID string) (*farmmodels.FarmBoundary, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, farm_id, farm_uuid, tenant_id, geojson,
			area_hectares, perimeter_meters, is_active,
			created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM farm_boundaries
		WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID,
	)

	boundary := &farmmodels.FarmBoundary{}
	if err := scanBoundary(row, boundary); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("BOUNDARY_NOT_FOUND", fmt.Sprintf("boundary not found for farm: %s", farmUUID))
		}
		r.log.Errorw("msg", "failed to get farm boundary", "farm_uuid", farmUUID, "error", err)
		return nil, errors.InternalServer("BOUNDARY_GET_FAILED", fmt.Sprintf("failed to get boundary: %v", err))
	}

	return boundary, nil
}

func (r *farmRepository) UpdateFarmBoundary(ctx context.Context, boundary *farmmodels.FarmBoundary) (*farmmodels.FarmBoundary, error) {
	row := r.queryRow(ctx, `
		UPDATE farm_boundaries SET
			geojson = $3,
			boundary = ST_GeomFromGeoJSON($3),
			area_hectares = $4,
			perimeter_meters = $5,
			updated_by = $6,
			updated_at = NOW()
		WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		RETURNING id, uuid, farm_id, farm_uuid, tenant_id, geojson,
			area_hectares, perimeter_meters, is_active,
			created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		boundary.FarmUUID, boundary.TenantID,
		boundary.GeoJSON, boundary.AreaHectares, boundary.PerimeterMeters,
		boundary.UpdatedBy,
	)

	result := &farmmodels.FarmBoundary{}
	if err := scanBoundary(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("BOUNDARY_NOT_FOUND", fmt.Sprintf("boundary not found for farm: %s", boundary.FarmUUID))
		}
		r.log.Errorw("msg", "failed to update farm boundary", "farm_uuid", boundary.FarmUUID, "error", err)
		return nil, errors.InternalServer("BOUNDARY_UPDATE_FAILED", fmt.Sprintf("failed to update boundary: %v", err))
	}

	return result, nil
}

func (r *farmRepository) DeleteFarmBoundary(ctx context.Context, farmUUID, tenantID, deletedBy string) error {
	err := r.exec(ctx, `
		UPDATE farm_boundaries SET
			is_active = FALSE,
			deleted_by = $3,
			deleted_at = NOW()
		WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, deletedBy,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to delete farm boundary", "farm_uuid", farmUUID, "error", err)
		return errors.InternalServer("BOUNDARY_DELETE_FAILED", fmt.Sprintf("failed to delete boundary: %v", err))
	}
	return nil
}

// ---------- Farm Owners ----------

func (r *farmRepository) CreateFarmOwner(ctx context.Context, owner *farmmodels.FarmOwner) (*farmmodels.FarmOwner, error) {
	owner.UUID = ulid.NewString()
	owner.CreatedAt = time.Now()
	owner.IsActive = true
	if owner.AcquiredAt.IsZero() {
		owner.AcquiredAt = time.Now()
	}

	row := r.queryRow(ctx, `
		INSERT INTO farm_owners (
			uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9, $10,
			$11, TRUE, $12, NOW()
		)
		RETURNING id, uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at`,
		owner.UUID, owner.FarmID, owner.FarmUUID, owner.TenantID, owner.UserID,
		owner.OwnerName, owner.Email, owner.Phone, owner.IsPrimary, owner.OwnershipPercentage,
		owner.AcquiredAt, owner.CreatedBy,
	)

	result := &farmmodels.FarmOwner{}
	if err := scanOwner(row, result); err != nil {
		r.log.Errorw("msg", "failed to create farm owner", "farm_uuid", owner.FarmUUID, "error", err)
		return nil, errors.InternalServer("OWNER_CREATE_FAILED", fmt.Sprintf("failed to create owner: %v", err))
	}

	return result, nil
}

func (r *farmRepository) GetFarmOwnersByFarmUUID(ctx context.Context, farmUUID, tenantID string) ([]farmmodels.FarmOwner, error) {
	rows, err := r.query(ctx, `
		SELECT id, uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM farm_owners
		WHERE farm_uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL
		ORDER BY is_primary DESC, created_at ASC`,
		farmUUID, tenantID,
	)
	if err != nil {
		r.log.Errorw("msg", "failed to list farm owners", "farm_uuid", farmUUID, "error", err)
		return nil, errors.InternalServer("OWNER_LIST_FAILED", fmt.Sprintf("failed to list owners: %v", err))
	}
	defer rows.Close()

	owners := make([]farmmodels.FarmOwner, 0)
	for rows.Next() {
		var owner farmmodels.FarmOwner
		if err := scanOwnerFromRows(rows, &owner); err != nil {
			return nil, errors.InternalServer("OWNER_SCAN_FAILED", fmt.Sprintf("failed to scan owner: %v", err))
		}
		owners = append(owners, owner)
	}
	if err := rows.Err(); err != nil {
		return nil, errors.InternalServer("OWNER_ROWS_ERROR", fmt.Sprintf("row iteration error: %v", err))
	}

	return owners, nil
}

func (r *farmRepository) GetFarmOwnerByUserID(ctx context.Context, farmUUID, tenantID, userID string) (*farmmodels.FarmOwner, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM farm_owners
		WHERE farm_uuid = $1 AND tenant_id = $2 AND user_id = $3
			AND is_active = TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, userID,
	)

	owner := &farmmodels.FarmOwner{}
	if err := scanOwner(row, owner); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("OWNER_NOT_FOUND", fmt.Sprintf("owner not found: user=%s farm=%s", userID, farmUUID))
		}
		return nil, errors.InternalServer("OWNER_GET_FAILED", fmt.Sprintf("failed to get owner: %v", err))
	}

	return owner, nil
}

func (r *farmRepository) DeactivateFarmOwner(ctx context.Context, farmUUID, tenantID, userID, deletedBy string) error {
	err := r.exec(ctx, `
		UPDATE farm_owners SET
			is_active = FALSE,
			deleted_by = $4,
			deleted_at = NOW()
		WHERE farm_uuid = $1 AND tenant_id = $2 AND user_id = $3
			AND is_active = TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, userID, deletedBy,
	)
	if err != nil {
		return errors.InternalServer("OWNER_DEACTIVATE_FAILED", fmt.Sprintf("failed to deactivate owner: %v", err))
	}
	return nil
}

func (r *farmRepository) ClearPrimaryOwner(ctx context.Context, farmUUID, tenantID, updatedBy string) error {
	err := r.exec(ctx, `
		UPDATE farm_owners SET
			is_primary = FALSE,
			updated_by = $3,
			updated_at = NOW()
		WHERE farm_uuid = $1 AND tenant_id = $2 AND is_primary = TRUE
			AND is_active = TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, updatedBy,
	)
	if err != nil {
		return errors.InternalServer("OWNER_CLEAR_PRIMARY_FAILED", fmt.Sprintf("failed to clear primary owner: %v", err))
	}
	return nil
}

// ---------- Scan helpers ----------

func scanFarm(row pgx.Row, f *farmmodels.Farm) error {
	return row.Scan(
		&f.ID, &f.UUID, &f.TenantID, &f.Name, &f.Description, &f.TotalAreaHectares,
		&f.Latitude, &f.Longitude, &f.ElevationMeters, &f.FarmType, &f.Status,
		&f.SoilType, &f.ClimateZone, &f.Address, &f.Region, &f.Country,
		&f.Metadata, &f.Version, &f.IsActive, &f.CreatedBy, &f.CreatedAt,
		&f.UpdatedBy, &f.UpdatedAt, &f.DeletedBy, &f.DeletedAt,
	)
}

func scanFarmFromRows(rows pgx.Rows, f *farmmodels.Farm) error {
	return rows.Scan(
		&f.ID, &f.UUID, &f.TenantID, &f.Name, &f.Description, &f.TotalAreaHectares,
		&f.Latitude, &f.Longitude, &f.ElevationMeters, &f.FarmType, &f.Status,
		&f.SoilType, &f.ClimateZone, &f.Address, &f.Region, &f.Country,
		&f.Metadata, &f.Version, &f.IsActive, &f.CreatedBy, &f.CreatedAt,
		&f.UpdatedBy, &f.UpdatedAt, &f.DeletedBy, &f.DeletedAt,
	)
}

func scanBoundary(row pgx.Row, b *farmmodels.FarmBoundary) error {
	return row.Scan(
		&b.ID, &b.UUID, &b.FarmID, &b.FarmUUID, &b.TenantID, &b.GeoJSON,
		&b.AreaHectares, &b.PerimeterMeters, &b.IsActive,
		&b.CreatedBy, &b.CreatedAt, &b.UpdatedBy, &b.UpdatedAt, &b.DeletedBy, &b.DeletedAt,
	)
}

func scanOwner(row pgx.Row, o *farmmodels.FarmOwner) error {
	return row.Scan(
		&o.ID, &o.UUID, &o.FarmID, &o.FarmUUID, &o.TenantID, &o.UserID,
		&o.OwnerName, &o.Email, &o.Phone, &o.IsPrimary, &o.OwnershipPercentage,
		&o.AcquiredAt, &o.IsActive, &o.CreatedBy, &o.CreatedAt,
		&o.UpdatedBy, &o.UpdatedAt, &o.DeletedBy, &o.DeletedAt,
	)
}

func scanOwnerFromRows(rows pgx.Rows, o *farmmodels.FarmOwner) error {
	return rows.Scan(
		&o.ID, &o.UUID, &o.FarmID, &o.FarmUUID, &o.TenantID, &o.UserID,
		&o.OwnerName, &o.Email, &o.Phone, &o.IsPrimary, &o.OwnershipPercentage,
		&o.AcquiredAt, &o.IsActive, &o.CreatedBy, &o.CreatedAt,
		&o.UpdatedBy, &o.UpdatedAt, &o.DeletedBy, &o.DeletedAt,
	)
}

// ---------- Nil helpers ----------

func nilIfEmpty(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

func nilIfZeroFloat(f float64) *float64 {
	if f == 0 {
		return nil
	}
	return &f
}

func nilIfEmptyFarmType(ft farmmodels.FarmType) *string {
	if ft == farmmodels.FarmTypeUnspecified {
		return nil
	}
	s := string(ft)
	return &s
}

func nilIfEmptyFarmStatus(fs farmmodels.FarmStatus) *string {
	if fs == farmmodels.FarmStatusUnspecified {
		return nil
	}
	s := string(fs)
	return &s
}

func nullableString[T ~string](v *T) *string {
	if v == nil || *v == "" {
		return nil
	}
	s := string(*v)
	return &s
}
