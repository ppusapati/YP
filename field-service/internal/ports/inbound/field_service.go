package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
)

type FieldService interface {
	CreateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	GetField(ctx context.Context, uuid string) (*domain.Field, error)
	ListFields(ctx context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error)
	UpdateField(ctx context.Context, field *domain.Field) (*domain.Field, error)
	DeleteField(ctx context.Context, uuid string) error
	AssignCrop(ctx context.Context, params domain.AssignCropParams) (*domain.CropAssignment, error)
	GetFieldSummary(ctx context.Context, uuid string) (*domain.FieldSummary, error)

	SetFieldBoundary(ctx context.Context, params domain.SetBoundaryParams) (*domain.FieldBoundary, error)
	ListFieldsByFarm(ctx context.Context, farmID string, pageSize, offset int32) ([]domain.Field, int32, error)
	SegmentField(ctx context.Context, params domain.SegmentFieldParams) ([]domain.FieldSegment, error)
	GetFieldSegments(ctx context.Context, fieldID string) ([]domain.FieldSegment, error)
	GetCropHistory(ctx context.Context, params domain.CropHistoryParams) ([]domain.CropAssignment, int32, error)
}
