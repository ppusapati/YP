// Package outbound defines the secondary ports for the crop-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/crop-service/internal/domain"
)

// CropRepository is the secondary port for crop persistence.
type CropRepository interface {
	CreateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error)
	GetCropByUUID(ctx context.Context, uuid, tenantID string) (*domain.Crop, error)
	ListCrops(ctx context.Context, params domain.ListCropParams) ([]domain.Crop, int32, error)
	UpdateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error)
	DeleteCrop(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckCropExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckCropNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) CropRepository
}
