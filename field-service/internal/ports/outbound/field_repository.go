package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
)

type FieldRepository interface {
	CreateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	GetFieldByUUID(ctx context.Context, uuid, tenantID string) (*domain.Field, error)
	ListFields(ctx context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error)
	UpdateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	DeleteField(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckFieldExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckFieldNameExists(ctx context.Context, name, farmID, tenantID string) (bool, error)

	SetFieldBoundary(ctx context.Context, b *domain.FieldBoundary) (*domain.FieldBoundary, error)

	CreateCropAssignment(ctx context.Context, a *domain.CropAssignment) (*domain.CropAssignment, error)
	GetCropHistory(ctx context.Context, fieldID, tenantID string, pageSize, offset int32) ([]domain.CropAssignment, int32, error)

	CreateFieldSegments(ctx context.Context, fieldID, tenantID string, segments []domain.FieldSegmentInput) ([]domain.FieldSegment, error)
	GetFieldSegments(ctx context.Context, fieldID, tenantID string) ([]domain.FieldSegment, error)
	DeleteFieldSegments(ctx context.Context, fieldID, tenantID string) error

	WithTx(tx pgx.Tx) FieldRepository
}
