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

func (r *soilRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

func (r *soilRepository) CreateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error) {
	entity.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO soils (uuid, tenant_id, name, status, is_active, created_by)
		VALUES ($1,$2,$3,$4,true,$5)
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status), entity.CreatedBy,
	)
	return scanSoil(row)
}

func (r *soilRepository) GetSoilByUUID(ctx context.Context, uuid, tenantID string) (*domain.Soil, error) {
	row := r.queryRow(ctx,
		`SELECT uuid, tenant_id, name, status, is_active, created_by, created_at, version
		FROM soils WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
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
		`UPDATE soils SET name=COALESCE(NULLIF($1,''),name), status=COALESCE(NULLIF($2,''),status),
		updated_by=$3, updated_at=NOW(), version=version+1
		WHERE uuid=$4 AND tenant_id=$5 AND deleted_at IS NULL
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
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
	return r.exec(ctx,
		`UPDATE soils SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE uuid=$2 AND tenant_id=$3`,
		deletedBy, uuid, tenantID,
	)
}

func (r *soilRepository) CheckSoilExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM soils WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	return exists, err
}

func (r *soilRepository) CheckSoilNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM soils WHERE name=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
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

func (r *soilRepository) CreateSoilSample(ctx context.Context, sample *domain.SoilSample) (*domain.SoilSample, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) GetSoilSampleByUUID(ctx context.Context, uuid, tenantID string) (*domain.SoilSample, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]domain.SoilSample, int64, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) DeleteSoilSample(ctx context.Context, uuid, tenantID string) error {
	return errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) CreateSoilAnalysis(ctx context.Context, analysis *domain.SoilAnalysis) (*domain.SoilAnalysis, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) GetSoilAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*domain.SoilAnalysis, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]domain.SoilAnalysis, int64, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) UpdateSoilAnalysisStatus(ctx context.Context, uuid string, status domain.AnalysisStatus) error {
	return errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) CreateSoilMap(ctx context.Context, soilMap *domain.SoilMap) (*domain.SoilMap, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) GetSoilMapByFieldAndType(ctx context.Context, fieldID, tenantID, mapType string) (*domain.SoilMap, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) CreateSoilNutrient(ctx context.Context, nutrient *domain.SoilNutrient) (*domain.SoilNutrient, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) ListNutrientsBySample(ctx context.Context, sampleID, tenantID string) ([]domain.SoilNutrient, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) BatchCreateNutrients(ctx context.Context, nutrients []domain.SoilNutrient) ([]domain.SoilNutrient, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) CreateSoilHealthScore(ctx context.Context, score *domain.SoilHealthScore) (*domain.SoilHealthScore, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) GetLatestSoilHealthScore(ctx context.Context, fieldID, tenantID string) (*domain.SoilHealthScore, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) UpdateSoilHealthScore(ctx context.Context, score *domain.SoilHealthScore) (*domain.SoilHealthScore, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *soilRepository) ListSoilHealthScoresByFarm(ctx context.Context, farmID, tenantID string, pageSize, pageOffset int32) ([]domain.SoilHealthScore, int64, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}
