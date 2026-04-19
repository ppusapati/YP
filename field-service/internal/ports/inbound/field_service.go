// Package inbound defines the primary ports — the interfaces that drive the
// field-service application core.  These interfaces are implemented by the
// application service and called by inbound adapters (ConnectRPC handler,
// Kafka consumer).
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
)

// FieldService is the primary port for all field business operations.
type FieldService interface {
	CreateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	GetField(ctx context.Context, uuid string) (*domain.Field, error)
	ListFields(ctx context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error)
	UpdateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	DeleteField(ctx context.Context, uuid string) error
	AssignCrop(ctx context.Context, params domain.AssignCropParams) (*domain.Field, error)
	GetFieldSummary(ctx context.Context, uuid string) (*domain.FieldSummary, error)
}
