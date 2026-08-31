// Package postgres implements the outbound.IrrigationRepository port using pgx.
package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

type irrigationRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
	tx   pgx.Tx
}

// NewIrrigationRepository creates a new postgres-backed IrrigationRepository.
func NewIrrigationRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.IrrigationRepository {
	return &irrigationRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "IrrigationPostgresRepository")),
	}
}

func (r *irrigationRepository) WithTx(tx pgx.Tx) outbound.IrrigationRepository {
	return &irrigationRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *irrigationRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	if r.tx != nil {
		return r.tx.QueryRow(ctx, sql, args...)
	}
	return r.pool.QueryRow(ctx, sql, args...)
}

func (r *irrigationRepository) exec(ctx context.Context, sql string, args ...any) error {
	var err error
	if r.tx != nil {
		_, err = r.tx.Exec(ctx, sql, args...)
	} else {
		_, err = r.pool.Exec(ctx, sql, args...)
	}
	return err
}

func (r *irrigationRepository) CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
	entity.UUID = ulid.NewString()
	row := r.queryRow(ctx,
		`INSERT INTO irrigations (uuid, tenant_id, name, status, is_active, created_by)
		VALUES ($1,$2,$3,$4,true,$5)
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.UUID, entity.TenantID, entity.Name, string(entity.Status), entity.CreatedBy,
	)
	return scanIrrigation(row)
}

func (r *irrigationRepository) GetIrrigationByUUID(ctx context.Context, uuid, tenantID string) (*domain.Irrigation, error) {
	row := r.queryRow(ctx,
		`SELECT uuid, tenant_id, name, status, is_active, created_by, created_at, version
		FROM irrigations WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
		uuid, tenantID,
	)
	e, err := scanIrrigation(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", uuid))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *irrigationRepository) ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error) {
	return nil, 0, nil
}

func (r *irrigationRepository) UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error) {
	row := r.queryRow(ctx,
		`UPDATE irrigations SET name=COALESCE(NULLIF($1,''),name), status=COALESCE(NULLIF($2,''),status),
		updated_by=$3, updated_at=NOW(), version=version+1
		WHERE uuid=$4 AND tenant_id=$5 AND deleted_at IS NULL
		RETURNING uuid, tenant_id, name, status, is_active, created_by, created_at, version`,
		entity.Name, string(entity.Status), entity.UpdatedBy, entity.UUID, entity.TenantID,
	)
	e, err := scanIrrigation(row)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", entity.UUID))
		}
		return nil, errors.InternalServer("DB_ERROR", err.Error())
	}
	return e, nil
}

func (r *irrigationRepository) DeleteIrrigation(ctx context.Context, uuid, tenantID, deletedBy string) error {
	return r.exec(ctx,
		`UPDATE irrigations SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE uuid=$2 AND tenant_id=$3`,
		deletedBy, uuid, tenantID,
	)
}

func (r *irrigationRepository) CheckIrrigationExists(ctx context.Context, uuid, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM irrigations WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		uuid, tenantID,
	).Scan(&exists)
	return exists, err
}

func (r *irrigationRepository) CheckIrrigationNameExists(ctx context.Context, name, tenantID string) (bool, error) {
	var exists bool
	err := r.queryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM irrigations WHERE name=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
		name, tenantID,
	).Scan(&exists)
	return exists, err
}

func scanIrrigation(row pgx.Row) (*domain.Irrigation, error) {
	e := &domain.Irrigation{}
	err := row.Scan(
		&e.UUID, &e.TenantID, &e.Name, &e.Status,
		&e.IsActive, &e.CreatedBy, &e.CreatedAt, &e.Version,
	)
	return e, err
}

func (r *irrigationRepository) CreateZone(ctx context.Context, zone *domain.IrrigationZone) (*domain.IrrigationZone, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) GetZoneByUUID(ctx context.Context, uuid string) (*domain.IrrigationZone, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListZonesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListZonesByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.IrrigationZone, int32, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) CreateController(ctx context.Context, ctrl *domain.WaterController) (*domain.WaterController, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) GetControllerByUUID(ctx context.Context, uuid string) (*domain.WaterController, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListControllersByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.WaterController, int32, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) UpdateControllerStatus(ctx context.Context, uuid string, status domain.ControllerStatus) (*domain.WaterController, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) CreateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) GetScheduleByUUID(ctx context.Context, uuid string) (*domain.IrrigationSchedule, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListSchedulesByField(ctx context.Context, fieldID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListSchedulesByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationSchedule, int32, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) UpdateSchedule(ctx context.Context, sched *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) UpdateScheduleStatus(ctx context.Context, uuid string, status domain.IrrigationStatus) (*domain.IrrigationSchedule, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) DeleteSchedule(ctx context.Context, uuid string) error {
	return errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) CreateEvent(ctx context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) GetEventByUUID(ctx context.Context, uuid string) (*domain.IrrigationEvent, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListEventsByZone(ctx context.Context, zoneID string, pageSize, offset int32) ([]domain.IrrigationEvent, int32, error) {
	return nil, 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListEventsByTimeRange(ctx context.Context, zoneID string, start, end time.Time) ([]domain.IrrigationEvent, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) UpdateEvent(ctx context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) CreateDecision(ctx context.Context, decision *domain.IrrigationDecision) (*domain.IrrigationDecision, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) MarkDecisionApplied(ctx context.Context, uuid string) error {
	return errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) CreateWaterUsageLog(ctx context.Context, log *domain.WaterUsageLog) (*domain.WaterUsageLog, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) ListWaterUsageLogs(ctx context.Context, zoneID string, start, end time.Time) ([]domain.WaterUsageLog, error) {
	return nil, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}

func (r *irrigationRepository) SumWaterUsageByZone(ctx context.Context, zoneID string, start, end time.Time) (float64, error) {
	return 0, errors.InternalServer("NOT_IMPLEMENTED", "not implemented")
}
