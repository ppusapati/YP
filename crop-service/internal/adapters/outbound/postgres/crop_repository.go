// Package postgres implements the outbound.CropRepository port using pgx.
package postgres

import (
	"context"
	"fmt"

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

func (r *cropRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

func (r *cropRepository) CreateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
	entity.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO crops (uuid, tenant_id, name, status, is_active, created_by)
		VALUES ($1,$2,$3,$4,true,$5)
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status), entity.CreatedBy,
	)
	return scanCrop(row)
}

func (r *cropRepository) GetCropByUUID(ctx context.Context, uuid, tenantID string) (*domain.Crop, error) {
	row := r.queryRow(ctx,
		`SELECT uuid, tenant_id, name, status, is_active, created_by, created_at, version
		FROM crops WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	e, err := scanCrop(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", uuid))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *cropRepository) ListCrops(ctx context.Context, params domain.ListCropParams) ([]domain.Crop, int32, error) {
	return nil, 0, nil
}

func (r *cropRepository) UpdateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error) {
	row := r.queryRow(ctx,
		`UPDATE crops SET name=COALESCE(NULLIF($1,''),name), status=COALESCE(NULLIF($2,''),status),
		updated_by=$3, updated_at=NOW(), version=version+1
		WHERE uuid=$4 AND tenant_id=$5 AND deleted_at IS NULL
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.Name, string(entity.Status), entity.UpdatedBy, entity.UUID, entity.TenantID,
	)
	e, err := scanCrop(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", entity.UUID))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *cropRepository) DeleteCrop(ctx context.Context, uuid, tenantID, deletedBy string) error {
	return r.exec(ctx,
		`UPDATE crops SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE uuid=$2 AND tenant_id=$3`,
		deletedBy, uuid, tenantID,
	)
}

func (r *cropRepository) CheckCropExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM crops WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	return exists, err
}

func (r *cropRepository) CheckCropNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM crops WHERE name=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		name, tenantID,
	).Scan(&exists)
	return exists, err
}

func scanCrop(row pgx.Row) (*domain.Crop, error) {
	e := &domain.Crop{}
	err := row.Scan(
		&e.UUID, &e.TenantID, &e.Name, &e.Status,
		&e.IsActive, &e.CreatedBy, &e.CreatedAt, &e.Version,
	)
	return e, err
}
