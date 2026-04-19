// Package postgres implements the outbound.FieldRepository port using pgx.
package postgres

import (
"context"
"fmt"

"github.com/jackc/pgx/v5"
"github.com/jackc/pgx/v5/pgxpool"

"p9e.in/samavaya/packages/errors"
"p9e.in/samavaya/packages/p9log"
"p9e.in/samavaya/packages/ulid"

"p9e.in/samavaya/agriculture/field-service/internal/domain"
"p9e.in/samavaya/agriculture/field-service/internal/ports/outbound"
)

type fieldRepository struct {
pool *pgxpool.Pool
log  *p9log.Helper
tx   pgx.Tx
}

// NewFieldRepository creates a new postgres-backed FieldRepository.
func NewFieldRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.FieldRepository {
return &fieldRepository{
pool: pool,
log:  p9log.NewHelper(p9log.With(log, "component", "FieldPostgresRepository")),
}
}

func (r *fieldRepository) WithTx(tx pgx.Tx) outbound.FieldRepository {
return &fieldRepository{pool: r.pool, log: r.log, tx: tx}
}

func (r *fieldRepository) queryRow(ctx context.Context, sql string, args ...any) pgx.Row {
if r.tx != nil {
return r.tx.QueryRow(ctx, sql, args...)
}
return r.pool.QueryRow(ctx, sql, args...)
}

func (r *fieldRepository) exec(ctx context.Context, sql string, args ...any) error {
var err error
if r.tx != nil {
_, err = r.tx.Exec(ctx, sql, args...)
} else {
_, err = r.pool.Exec(ctx, sql, args...)
}
return err
}

func (r *fieldRepository) CreateField(ctx context.Context, field *domain.Field) (*domain.Field, error) {
field.UUID = ulid.NewString()
row := r.queryRow(ctx,
`INSERT INTO fields (uuid, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage,
is_active, created_by)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,true,$14)
RETURNING uuid, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage,
is_active, created_by, created_at, version`,
field.UUID, field.TenantID, field.FarmID, field.Name, field.AreaHectares,
string(field.FieldType), string(field.SoilType), string(field.IrrigationType),
string(field.Status), field.ElevationMeters, field.SlopeDegrees,
string(field.AspectDirection), string(field.GrowthStage), field.CreatedBy,
)
return scanField(row)
}

func (r *fieldRepository) GetFieldByUUID(ctx context.Context, uuid, tenantID string) (*domain.Field, error) {
row := r.queryRow(ctx,
`SELECT uuid, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage,
is_active, created_by, created_at, version
FROM fields WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL`,
uuid, tenantID,
)
f, err := scanField(row)
if err != nil {
if err == pgx.ErrNoRows {
return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", uuid))
}
return nil, errors.InternalServer("DB_ERROR", err.Error())
}
return f, nil
}

func (r *fieldRepository) ListFields(ctx context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error) {
// Simplified list implementation
return nil, 0, nil
}

func (r *fieldRepository) UpdateField(ctx context.Context, field *domain.Field) (*domain.Field, error) {
row := r.queryRow(ctx,
`UPDATE fields SET name=COALESCE(NULLIF($1,''),name), status=COALESCE(NULLIF($2,''),status),
updated_by=$3, updated_at=NOW(), version=version+1
WHERE uuid=$4 AND tenant_id=$5 AND deleted_at IS NULL
RETURNING uuid, tenant_id, farm_id, name, area_hectares, field_type, soil_type,
irrigation_type, status, elevation_meters, slope_degrees, aspect_direction, growth_stage,
is_active, created_by, created_at, version`,
field.Name, string(field.Status), field.UpdatedBy, field.UUID, field.TenantID,
)
f, err := scanField(row)
if err != nil {
if err == pgx.ErrNoRows {
return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", field.UUID))
}
return nil, errors.InternalServer("DB_ERROR", err.Error())
}
return f, nil
}

func (r *fieldRepository) DeleteField(ctx context.Context, uuid, tenantID, deletedBy string) error {
return r.exec(ctx,
`UPDATE fields SET deleted_at=NOW(), deleted_by=$1, is_active=false WHERE uuid=$2 AND tenant_id=$3`,
deletedBy, uuid, tenantID,
)
}

func (r *fieldRepository) CheckFieldExists(ctx context.Context, uuid, tenantID string) (bool, error) {
var exists bool
err := r.queryRow(ctx,
`SELECT EXISTS(SELECT 1 FROM fields WHERE uuid=$1 AND tenant_id=$2 AND deleted_at IS NULL)`,
uuid, tenantID,
).Scan(&exists)
return exists, err
}

func (r *fieldRepository) CheckFieldNameExists(ctx context.Context, name, farmID, tenantID string) (bool, error) {
var exists bool
err := r.queryRow(ctx,
`SELECT EXISTS(SELECT 1 FROM fields WHERE name=$1 AND farm_id=$2 AND tenant_id=$3 AND deleted_at IS NULL)`,
name, farmID, tenantID,
).Scan(&exists)
return exists, err
}

func scanField(row pgx.Row) (*domain.Field, error) {
f := &domain.Field{}
err := row.Scan(
&f.UUID, &f.TenantID, &f.FarmID, &f.Name, &f.AreaHectares,
&f.FieldType, &f.SoilType, &f.IrrigationType, &f.Status,
&f.ElevationMeters, &f.SlopeDegrees, &f.AspectDirection, &f.GrowthStage,
&f.IsActive, &f.CreatedBy, &f.CreatedAt, &f.Version,
)
return f, err
}
