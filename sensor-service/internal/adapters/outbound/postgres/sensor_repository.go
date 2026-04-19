// Package postgres implements the outbound.SensorRepository port using pgx.
package postgres

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/outbound"
)

type sensorRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewSensorRepository creates a new postgres-backed SensorRepository.
func NewSensorRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.SensorRepository {
	return &sensorRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "SensorPostgresRepository")),
	}
}

func (r *sensorRepository) WithTx(tx pgx.Tx) outbound.SensorRepository {
	return &sensorRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *sensorRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *sensorRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

func (r *sensorRepository) CreateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error) {
	entity.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO sensors (uuid, tenant_id, name, status, is_active, created_by)
		VALUES ($1,$2,$3,$4,true,$5)
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status), entity.CreatedBy,
	)
	return scanSensor(row)
}

func (r *sensorRepository) GetSensorByUUID(ctx context.Context, uuid, tenantID string) (*domain.Sensor, error) {
	row := r.queryRow(ctx,
		`SELECT uuid, tenant_id, name, status, is_active, created_by, created_at, version
		FROM sensors WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	e, err := scanSensor(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor not found: %s", uuid))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *sensorRepository) ListSensors(ctx context.Context, params domain.ListSensorParams) ([]domain.Sensor, int32, error) {
	return nil, 0, nil
}

func (r *sensorRepository) UpdateSensor(ctx context.Context, entity *domain.Sensor) (*domain.Sensor, error) {
	row := r.queryRow(ctx,
		`UPDATE sensors SET name=COALESCE(NULLIF($1,''),name), status=COALESCE(NULLIF($2,''),status),
		updated_by=$3, updated_at=NOW(), version=version+1
		WHERE uuid=$4 AND tenant_id=$5 AND deleted_at IS NULL
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.Name, string(entity.Status), entity.UpdatedBy, entity.UUID, entity.TenantID,
	)
	e, err := scanSensor(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor not found: %s", entity.UUID))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *sensorRepository) DeleteSensor(ctx context.Context, uuid, tenantID, deletedBy string) error {
	return r.exec(ctx,
		`UPDATE sensors SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE uuid=$2 AND tenant_id=$3`,
		deletedBy, uuid, tenantID,
	)
}

func (r *sensorRepository) CheckSensorExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM sensors WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	return exists, err
}

func (r *sensorRepository) CheckSensorNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM sensors WHERE name=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		name, tenantID,
	).Scan(&exists)
	return exists, err
}

func scanSensor(row pgx.Row) (*domain.Sensor, error) {
	e := &domain.Sensor{}
	err := row.Scan(
		&e.UUID, &e.TenantID, &e.Name, &e.Status,
		&e.IsActive, &e.CreatedBy, &e.CreatedAt, &e.Version,
	)
	return e, err
}
