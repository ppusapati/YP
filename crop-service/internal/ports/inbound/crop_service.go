// Package inbound defines the primary ports for the crop-service.
package inbound

import (
	"context"

	cropmodels "p9e.in/samavaya/agriculture/crop-service/internal/models"
)

// CropService is the primary port for all crop business operations.
type CropService interface {
	CreateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error)
	GetCrop(ctx context.Context, id, tenantID string) (*cropmodels.Crop, error)
	ListCrops(ctx context.Context, tenantID string, category *string, searchTerm *string, limit, offset int32) ([]*cropmodels.Crop, int32, error)
	UpdateCrop(ctx context.Context, crop *cropmodels.Crop) (*cropmodels.Crop, error)
	DeleteCrop(ctx context.Context, id, tenantID string) error

	AddVariety(ctx context.Context, variety *cropmodels.CropVariety) (*cropmodels.CropVariety, error)
	ListVarieties(ctx context.Context, cropUUID, tenantID string, limit, offset int32) ([]*cropmodels.CropVariety, int32, error)
	GetGrowthStages(ctx context.Context, cropUUID, tenantID string) ([]*cropmodels.CropGrowthStage, error)
	GetCropRequirements(ctx context.Context, cropUUID, tenantID string) (*cropmodels.CropRequirements, error)
	GenerateRecommendation(ctx context.Context, input *cropmodels.RecommendationInput) (*cropmodels.CropRecommendation, error)
}
