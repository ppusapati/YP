// Package inbound defines the primary ports for the crop-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/crop-service/internal/domain"
)

// CropService is the primary port for all crop business operations.
type CropService interface {
	CreateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error)
	GetCrop(ctx context.Context, uuid string) (*domain.Crop, error)
	ListCrops(ctx context.Context, params domain.ListCropParams) ([]domain.Crop, int32, error)
	UpdateCrop(ctx context.Context, entity *domain.Crop) (*domain.Crop, error)
	DeleteCrop(ctx context.Context, uuid string) error

	AddVariety(ctx context.Context, variety *domain.CropVariety) (*domain.CropVariety, error)
	ListVarieties(ctx context.Context, cropUUID, tenantID string, limit, offset int32) ([]*domain.CropVariety, int32, error)
	GetGrowthStages(ctx context.Context, cropUUID, tenantID string) ([]*domain.CropGrowthStage, error)
	GetCropRequirements(ctx context.Context, cropUUID, tenantID string) (*domain.CropRequirements, error)
	GenerateRecommendation(ctx context.Context, input *domain.RecommendationInput) (*domain.CropRecommendation, error)
}
