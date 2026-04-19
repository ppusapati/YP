// Package postgres implements the outbound.FarmRepository port using pgx.
package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/farm-service/internal/domain"
	"p9e.in/samavaya/agriculture/farm-service/internal/ports/outbound"
)

// farmRepository is the pgx implementation of outbound.FarmRepository.
type farmRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx // non-nil when inside a transaction
}

// NewFarmRepository creates a new postgres-backed FarmRepository.
func NewFarmRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.FarmRepository {
	return &farmRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "FarmPostgresRepository")),
	}
}

// WithTx returns a copy of the repository scoped to the given pgx.Tx.
func (r *farmRepository) WithTx(tx pgx.Tx) outbound.FarmRepository {
	return &farmRepository{pool: r.pool, log: r.log, tx: tx}
}

// querier returns the active transaction or the pool.
func (r *farmRepository) querier() interface {
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
	Exec(ctx context.Context, sql string, args ...any) (interface{ RowsAffected() int64 }, error)
} {
	if r.tx != nil {
		return r.tx
	}
	return r.pool
}

func (r *farmRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *farmRepository) query(ctx context.Context, sql string, args ...any) (pgx.Rows, error) {
	if r.tx != nil {
		return r.tx.Query(ctx, sql, args...)
	}
	return r.pool.Query(ctx, sql, args...)
}

func (r *farmRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

// ---- Farm CRUD ----

func (r *farmRepository) CreateFarm(ctx context.Context, farm *domain.Farm) (*domain.Farm, error) {
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
		farm.Latitude, farm.Longitude, farm.ElevationMeters, string(farm.FarmType), string(domain.FarmStatusPending),
		nullableSoilType(farm.SoilType), nullableClimateZone(farm.ClimateZone),
		farm.Address, farm.Region, farm.Country,
		metaJSON, farm.CreatedBy,
	)

	result := &domain.Farm{}
	if err := scanFarm(row, result); err != nil {
		r.log.Errorw("msg", "failed to create farm", "error", err)
		return nil, errors.InternalServer("FARM_CREATE_FAILED", fmt.Sprintf("failed to create farm: %v", err))
	}
	return result, nil
}

func (r *farmRepository) GetFarmByUUID(ctx context.Context, uuid, tenantID string) (*domain.Farm, error) {
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
	farm := &domain.Farm{}
	if err := scanFarm(row, farm); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", uuid))
		}
		r.log.Errorw("msg", "failed to get farm", "uuid", uuid, "error", err)
		return nil, errors.InternalServer("FARM_GET_FAILED", fmt.Sprintf("failed to get farm: %v", err))
	}
	return farm, nil
}

func (r *farmRepository) ListFarms(ctx context.Context, params domain.ListFarmsParams) ([]domain.Farm, int32, error) {
	var totalCount int32
	countRow := r.queryRow(ctx, `
		SELECT COUNT(*) FROM farms
		WHERE tenant_id = $1
			AND is_active = TRUE AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_type = $2::farm_type)
			AND ($3::VARCHAR IS NULL OR status = $3::farm_status)
			AND ($4::VARCHAR IS NULL OR region = $4)
			AND ($5::VARCHAR IS NULL OR country = $5)
			AND ($6::VARCHAR IS NULL OR climate_zone = $6::climate_zone)
			AND ($7::VARCHAR IS NULL OR name ILIKE '%' || $7 || '%')`,
		params.TenantID,
		nullableFarmType(params.FarmType), nullableFarmStatus(params.Status),
		params.Region, params.Country, nullableClimateZonePtr(params.ClimateZone),
		params.Search,
	)
	if err := countRow.Scan(&totalCount); err != nil {
		return nil, 0, errors.InternalServer("FARM_COUNT_FAILED", "failed to count farms")
	}

	rows, err := r.query(ctx, `
		SELECT id, uuid, tenant_id, name, description, total_area_hectares,
			latitude, longitude, elevation_meters, farm_type, status,
			soil_type, climate_zone, address, region, country,
			metadata, version, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM farms
		WHERE tenant_id = $1
			AND is_active = TRUE AND deleted_at IS NULL
			AND ($2::VARCHAR IS NULL OR farm_type = $2::farm_type)
			AND ($3::VARCHAR IS NULL OR status = $3::farm_status)
			AND ($4::VARCHAR IS NULL OR region = $4)
			AND ($5::VARCHAR IS NULL OR country = $5)
			AND ($6::VARCHAR IS NULL OR climate_zone = $6::climate_zone)
			AND ($7::VARCHAR IS NULL OR name ILIKE '%' || $7 || '%')
		ORDER BY created_at DESC LIMIT $8 OFFSET $9`,
		params.TenantID,
		nullableFarmType(params.FarmType), nullableFarmStatus(params.Status),
		params.Region, params.Country, nullableClimateZonePtr(params.ClimateZone),
		params.Search, params.PageSize, params.Offset,
	)
	if err != nil {
		return nil, 0, errors.InternalServer("FARM_LIST_FAILED", "failed to list farms")
	}
	defer rows.Close()

	farms := make([]domain.Farm, 0)
	for rows.Next() {
		var f domain.Farm
		if err := scanFarmFromRows(rows, &f); err != nil {
			return nil, 0, errors.InternalServer("FARM_SCAN_FAILED", "failed to scan farm row")
		}
		farms = append(farms, f)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, errors.InternalServer("FARM_ROWS_ERROR", "row iteration error")
	}
	return farms, totalCount, nil
}

func (r *farmRepository) UpdateFarm(ctx context.Context, farm *domain.Farm) (*domain.Farm, error) {
	var metaJSON interface{}
	if len(farm.Metadata) > 0 {
		metaJSON = farm.Metadata
	}
	row := r.queryRow(ctx, `
		UPDATE farms SET
			name = COALESCE(NULLIF($3, ''), name),
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
		farm.Name, farm.Description, nilIfZeroFloat(farm.TotalAreaHectares),
		farm.Latitude, farm.Longitude, farm.ElevationMeters,
		nilIfEmptyFarmType(farm.FarmType), nilIfEmptyFarmStatus(farm.Status),
		nullableSoilType(farm.SoilType), nullableClimateZone(farm.ClimateZone),
		farm.Address, farm.Region, farm.Country, metaJSON, farm.UpdatedBy,
	)
	result := &domain.Farm{}
	if err := scanFarm(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", farm.UUID))
		}
		return nil, errors.InternalServer("FARM_UPDATE_FAILED", fmt.Sprintf("failed to update farm: %v", err))
	}
	return result, nil
}

func (r *farmRepository) DeleteFarm(ctx context.Context, uuid, tenantID, deletedBy string) error {
	if err := r.exec(ctx, `
		UPDATE farms SET is_active = FALSE, deleted_by = $3, deleted_at = NOW()
		WHERE uuid = $1 AND tenant_id = $2 AND is_active = TRUE AND deleted_at IS NULL`,
		uuid, tenantID, deletedBy,
	); err != nil {
		return errors.InternalServer("FARM_DELETE_FAILED", fmt.Sprintf("failed to delete farm: %v", err))
	}
	return nil
}

func (r *farmRepository) CheckFarmExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	row := r.queryRow(ctx, `
		SELECT EXISTS(SELECT 1 FROM farms WHERE uuid=$1 AND tenant_id=$2 AND is_active=TRUE AND deleted_at IS NULL)`,
		uuid, tenantID)
	if err := row.Scan(&exists); err != nil {
		return false, errors.InternalServer("FARM_CHECK_FAILED", "failed to check farm exists")
	}
	return exists, nil
}

func (r *farmRepository) CheckFarmNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	row := r.queryRow(ctx, `
		SELECT EXISTS(SELECT 1 FROM farms WHERE name=$1 AND tenant_id=$2 AND is_active=TRUE AND deleted_at IS NULL)`,
		name, tenantID)
	if err := row.Scan(&exists); err != nil {
		return false, errors.InternalServer("FARM_NAME_CHECK_FAILED", "failed to check farm name")
	}
	return exists, nil
}

// ---- Farm Boundary ----

func (r *farmRepository) CreateFarmBoundary(ctx context.Context, b *domain.FarmBoundary) (*domain.FarmBoundary, error) {
	b.UUID = ulid.NewString()
	b.CreatedAt = time.Now()
	b.IsActive = true

	row := r.queryRow(ctx, `
		INSERT INTO farm_boundaries (
			uuid, farm_id, farm_uuid, tenant_id, geojson,
			boundary, area_hectares, perimeter_meters,
			is_active, created_by, created_at
		) VALUES ($1, $2, $3, $4, $5, ST_GeomFromGeoJSON($5), $6, $7, TRUE, $8, NOW())
		RETURNING id, uuid, farm_id, farm_uuid, tenant_id, geojson,
			area_hectares, perimeter_meters, is_active,
			created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		b.UUID, b.FarmID, b.FarmUUID, b.TenantID,
		b.GeoJSON, b.AreaHectares, b.PerimeterMeters, b.CreatedBy,
	)
	result := &domain.FarmBoundary{}
	if err := scanBoundary(row, result); err != nil {
		return nil, errors.InternalServer("BOUNDARY_CREATE_FAILED", fmt.Sprintf("failed to create boundary: %v", err))
	}
	return result, nil
}

func (r *farmRepository) GetFarmBoundaryByFarmUUID(ctx context.Context, farmUUID, tenantID string) (*domain.FarmBoundary, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, farm_id, farm_uuid, tenant_id, geojson,
			area_hectares, perimeter_meters, is_active,
			created_by, created_at, updated_by, updated_at, deleted_by, deleted_at
		FROM farm_boundaries
		WHERE farm_uuid=$1 AND tenant_id=$2 AND is_active=TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID)
	b := &domain.FarmBoundary{}
	if err := scanBoundary(row, b); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("BOUNDARY_NOT_FOUND", fmt.Sprintf("boundary not found for farm: %s", farmUUID))
		}
		return nil, errors.InternalServer("BOUNDARY_GET_FAILED", fmt.Sprintf("failed to get boundary: %v", err))
	}
	return b, nil
}

func (r *farmRepository) UpdateFarmBoundary(ctx context.Context, b *domain.FarmBoundary) (*domain.FarmBoundary, error) {
	row := r.queryRow(ctx, `
		UPDATE farm_boundaries SET
			geojson=$3, boundary=ST_GeomFromGeoJSON($3),
			area_hectares=$4, perimeter_meters=$5,
			updated_by=$6, updated_at=NOW()
		WHERE farm_uuid=$1 AND tenant_id=$2 AND is_active=TRUE AND deleted_at IS NULL
		RETURNING id, uuid, farm_id, farm_uuid, tenant_id, geojson,
			area_hectares, perimeter_meters, is_active,
			created_by, created_at, updated_by, updated_at, deleted_by, deleted_at`,
		b.FarmUUID, b.TenantID, b.GeoJSON, b.AreaHectares, b.PerimeterMeters, b.UpdatedBy,
	)
	result := &domain.FarmBoundary{}
	if err := scanBoundary(row, result); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("BOUNDARY_NOT_FOUND", fmt.Sprintf("boundary not found for farm: %s", b.FarmUUID))
		}
		return nil, errors.InternalServer("BOUNDARY_UPDATE_FAILED", fmt.Sprintf("failed to update boundary: %v", err))
	}
	return result, nil
}

func (r *farmRepository) DeleteFarmBoundary(ctx context.Context, farmUUID, tenantID, deletedBy string) error {
	return r.exec(ctx, `
		UPDATE farm_boundaries SET is_active=FALSE, deleted_by=$3, deleted_at=NOW()
		WHERE farm_uuid=$1 AND tenant_id=$2 AND is_active=TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, deletedBy)
}

// ---- Farm Owners ----

func (r *farmRepository) CreateFarmOwner(ctx context.Context, o *domain.FarmOwner) (*domain.FarmOwner, error) {
	o.UUID = ulid.NewString()
	o.CreatedAt = time.Now()
	o.IsActive = true
	if o.AcquiredAt.IsZero() {
		o.AcquiredAt = time.Now()
	}
	row := r.queryRow(ctx, `
		INSERT INTO farm_owners (
			uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, TRUE, $12, NOW())
		RETURNING id, uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at`,
		o.UUID, o.FarmID, o.FarmUUID, o.TenantID, o.UserID,
		o.OwnerName, o.Email, o.Phone, o.IsPrimary, o.OwnershipPercentage,
		o.AcquiredAt, o.CreatedBy,
	)
	result := &domain.FarmOwner{}
	if err := scanOwner(row, result); err != nil {
		return nil, errors.InternalServer("OWNER_CREATE_FAILED", fmt.Sprintf("failed to create owner: %v", err))
	}
	return result, nil
}

func (r *farmRepository) GetFarmOwnersByFarmUUID(ctx context.Context, farmUUID, tenantID string) ([]domain.FarmOwner, error) {
	rows, err := r.query(ctx, `
		SELECT id, uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM farm_owners
		WHERE farm_uuid=$1 AND tenant_id=$2 AND is_active=TRUE AND deleted_at IS NULL
		ORDER BY is_primary DESC, created_at ASC`,
		farmUUID, tenantID)
	if err != nil {
		return nil, errors.InternalServer("OWNER_LIST_FAILED", "failed to list owners")
	}
	defer rows.Close()

	owners := make([]domain.FarmOwner, 0)
	for rows.Next() {
		var o domain.FarmOwner
		if err := scanOwnerFromRows(rows, &o); err != nil {
			return nil, errors.InternalServer("OWNER_SCAN_FAILED", "failed to scan owner")
		}
		owners = append(owners, o)
	}
	return owners, rows.Err()
}

func (r *farmRepository) GetFarmOwnerByUserID(ctx context.Context, farmUUID, tenantID, userID string) (*domain.FarmOwner, error) {
	row := r.queryRow(ctx, `
		SELECT id, uuid, farm_id, farm_uuid, tenant_id, user_id,
			owner_name, email, phone, is_primary, ownership_percentage,
			acquired_at, is_active, created_by, created_at,
			updated_by, updated_at, deleted_by, deleted_at
		FROM farm_owners
		WHERE farm_uuid=$1 AND tenant_id=$2 AND user_id=$3 AND is_active=TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, userID)
	o := &domain.FarmOwner{}
	if err := scanOwner(row, o); err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("OWNER_NOT_FOUND", fmt.Sprintf("owner %s not found for farm %s", userID, farmUUID))
		}
		return nil, errors.InternalServer("OWNER_GET_FAILED", fmt.Sprintf("failed to get owner: %v", err))
	}
	return o, nil
}

func (r *farmRepository) DeactivateFarmOwner(ctx context.Context, farmUUID, tenantID, userID, deletedBy string) error {
	return r.exec(ctx, `
		UPDATE farm_owners SET is_active=FALSE, deleted_by=$4, deleted_at=NOW()
		WHERE farm_uuid=$1 AND tenant_id=$2 AND user_id=$3 AND is_active=TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, userID, deletedBy)
}

func (r *farmRepository) ClearPrimaryOwner(ctx context.Context, farmUUID, tenantID, updatedBy string) error {
	return r.exec(ctx, `
		UPDATE farm_owners SET is_primary=FALSE, updated_by=$3, updated_at=NOW()
		WHERE farm_uuid=$1 AND tenant_id=$2 AND is_primary=TRUE AND is_active=TRUE AND deleted_at IS NULL`,
		farmUUID, tenantID, updatedBy)
}

// ---- Scan helpers ----

func scanFarm(row pgx.Row, f *domain.Farm) error {
	var farmType, status string
	var soilType, climateZone *string
	err := row.Scan(
		&f.ID, &f.UUID, &f.TenantID, &f.Name, &f.Description, &f.TotalAreaHectares,
		&f.Latitude, &f.Longitude, &f.ElevationMeters, &farmType, &status,
		&soilType, &climateZone, &f.Address, &f.Region, &f.Country,
		&f.Metadata, &f.Version, &f.IsActive, &f.CreatedBy, &f.CreatedAt,
		&f.UpdatedBy, &f.UpdatedAt, &f.DeletedBy, &f.DeletedAt,
	)
	if err != nil {
		return err
	}
	f.FarmType = domain.FarmType(farmType)
	f.Status = domain.FarmStatus(status)
	if soilType != nil {
		st := domain.SoilType(*soilType)
		f.SoilType = &st
	}
	if climateZone != nil {
		cz := domain.ClimateZone(*climateZone)
		f.ClimateZone = &cz
	}
	return nil
}

func scanFarmFromRows(rows pgx.Rows, f *domain.Farm) error {
	var farmType, status string
	var soilType, climateZone *string
	err := rows.Scan(
		&f.ID, &f.UUID, &f.TenantID, &f.Name, &f.Description, &f.TotalAreaHectares,
		&f.Latitude, &f.Longitude, &f.ElevationMeters, &farmType, &status,
		&soilType, &climateZone, &f.Address, &f.Region, &f.Country,
		&f.Metadata, &f.Version, &f.IsActive, &f.CreatedBy, &f.CreatedAt,
		&f.UpdatedBy, &f.UpdatedAt, &f.DeletedBy, &f.DeletedAt,
	)
	if err != nil {
		return err
	}
	f.FarmType = domain.FarmType(farmType)
	f.Status = domain.FarmStatus(status)
	if soilType != nil {
		st := domain.SoilType(*soilType)
		f.SoilType = &st
	}
	if climateZone != nil {
		cz := domain.ClimateZone(*climateZone)
		f.ClimateZone = &cz
	}
	return nil
}

func scanBoundary(row pgx.Row, b *domain.FarmBoundary) error {
	return row.Scan(
		&b.ID, &b.UUID, &b.FarmID, &b.FarmUUID, &b.TenantID, &b.GeoJSON,
		&b.AreaHectares, &b.PerimeterMeters, &b.IsActive,
		&b.CreatedBy, &b.CreatedAt, &b.UpdatedBy, &b.UpdatedAt, &b.DeletedBy, &b.DeletedAt,
	)
}

func scanOwner(row pgx.Row, o *domain.FarmOwner) error {
	return row.Scan(
		&o.ID, &o.UUID, &o.FarmID, &o.FarmUUID, &o.TenantID, &o.UserID,
		&o.OwnerName, &o.Email, &o.Phone, &o.IsPrimary, &o.OwnershipPercentage,
		&o.AcquiredAt, &o.IsActive, &o.CreatedBy, &o.CreatedAt,
		&o.UpdatedBy, &o.UpdatedAt, &o.DeletedBy, &o.DeletedAt,
	)
}

func scanOwnerFromRows(rows pgx.Rows, o *domain.FarmOwner) error {
	return rows.Scan(
		&o.ID, &o.UUID, &o.FarmID, &o.FarmUUID, &o.TenantID, &o.UserID,
		&o.OwnerName, &o.Email, &o.Phone, &o.IsPrimary, &o.OwnershipPercentage,
		&o.AcquiredAt, &o.IsActive, &o.CreatedBy, &o.CreatedAt,
		&o.UpdatedBy, &o.UpdatedAt, &o.DeletedBy, &o.DeletedAt,
	)
}

// ---- Null helpers ----

func nilIfZeroFloat(f float64) interface{} {
	if f == 0 {
		return nil
	}
	return f
}

func nilIfEmptyFarmType(ft domain.FarmType) interface{} {
	if ft == domain.FarmTypeUnspecified {
		return nil
	}
	return string(ft)
}

func nilIfEmptyFarmStatus(fs domain.FarmStatus) interface{} {
	if fs == domain.FarmStatusUnspecified {
		return nil
	}
	return string(fs)
}

func nullableSoilType(st *domain.SoilType) interface{} {
	if st == nil {
		return nil
	}
	return string(*st)
}

func nullableClimateZone(cz *domain.ClimateZone) interface{} {
	if cz == nil {
		return nil
	}
	return string(*cz)
}

func nullableFarmType(ft *domain.FarmType) interface{} {
	if ft == nil {
		return nil
	}
	return string(*ft)
}

func nullableFarmStatus(fs *domain.FarmStatus) interface{} {
	if fs == nil {
		return nil
	}
	return string(*fs)
}

func nullableClimateZonePtr(cz *domain.ClimateZone) interface{} {
	if cz == nil {
		return nil
	}
	return string(*cz)
}
