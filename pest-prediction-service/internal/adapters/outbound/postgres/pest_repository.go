// Package postgres implements the outbound.PestRepository port using pgx.
package postgres

import (
	"context"
	"fmt"

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

func (r *pestRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

func (r *pestRepository) CreatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error) {
	entity.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO pest_predictions (uuid, tenant_id, name, status, is_active, created_by)
		VALUES ($1,$2,$3,$4,true,$5)
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status), entity.CreatedBy,
	)
	return scanPest(row)
}

func (r *pestRepository) GetPestByUUID(ctx context.Context, uuid, tenantID string) (*domain.Pest, error) {
	row := r.queryRow(ctx,
		`SELECT uuid, tenant_id, name, status, is_active, created_by, created_at, version
		FROM pest_predictions WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	e, err := scanPest(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PEST_NOT_FOUND", fmt.Sprintf("pest not found: %s", uuid))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *pestRepository) ListPestPredictions(ctx context.Context, params domain.ListPestPredictionParams) ([]domain.Pest, int32, error) {
	return nil, 0, nil
}

func (r *pestRepository) UpdatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error) {
	row := r.queryRow(ctx,
		`UPDATE pest_predictions SET name=COALESCE(NULLIF($1,''),name), status=COALESCE(NULLIF($2,''),status),
		updated_by=$3, updated_at=NOW(), version=version+1
		WHERE uuid=$4 AND tenant_id=$5 AND deleted_at IS NULL
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.Name, string(entity.Status), entity.UpdatedBy, entity.UUID, entity.TenantID,
	)
	e, err := scanPest(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("PEST_NOT_FOUND", fmt.Sprintf("pest not found: %s", entity.UUID))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *pestRepository) DeletePest(ctx context.Context, uuid, tenantID, deletedBy string) error {
	return r.exec(ctx,
		`UPDATE pest_predictions SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE uuid=$2 AND tenant_id=$3`,
		deletedBy, uuid, tenantID,
	)
}

func (r *pestRepository) CheckPestExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM pest_predictions WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	return exists, err
}

func (r *pestRepository) CheckPestNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM pest_predictions WHERE name=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		name, tenantID,
	).Scan(&exists)
	return exists, err
}

func scanPest(row pgx.Row) (*domain.Pest, error) {
	e := &domain.Pest{}
	err := row.Scan(
		&e.UUID, &e.TenantID, &e.Name, &e.Status,
		&e.IsActive, &e.CreatedBy, &e.CreatedAt, &e.Version,
	)
	return e, err
}
