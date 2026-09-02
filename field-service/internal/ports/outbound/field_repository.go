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

	CreateCropCycle(ctx context.Context, c *domain.CropCycle) (*domain.CropCycle, error)
	GetCropCycleByID(ctx context.Context, id, tenantID string) (*domain.CropCycle, error)
	ListCropCycles(ctx context.Context, params domain.ListCropCyclesParams) ([]domain.CropCycle, int32, error)
	UpdateCropCycle(ctx context.Context, c *domain.CropCycle) (*domain.CropCycle, error)

	CreateActivityEvent(ctx context.Context, e *domain.ActivityEvent) (*domain.ActivityEvent, error)
	ListActivityEvents(ctx context.Context, params domain.ListActivityEventsParams) ([]domain.ActivityEvent, int32, error)

	CreateActivityEvidence(ctx context.Context, e *domain.ActivityEvidence) (*domain.ActivityEvidence, error)
	ListActivityEvidence(ctx context.Context, params domain.ListActivityEvidenceParams) ([]domain.ActivityEvidence, int32, error)
	DeleteActivityEvidence(ctx context.Context, id, tenantID string) error

	WithTx(tx pgx.Tx) FieldRepository
}
