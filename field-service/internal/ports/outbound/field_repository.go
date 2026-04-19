// Package outbound defines the secondary ports for the field service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
)

// FieldRepository is the secondary port for field persistence.
type FieldRepository interface {
	CreateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	GetFieldByUUID(ctx context.Context, uuid, tenantID string) (*domain.Field, error)
	ListFields(ctx context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error)
	UpdateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	DeleteField(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckFieldExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckFieldNameExists(ctx context.Context, name, farmID, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) FieldRepository
}
