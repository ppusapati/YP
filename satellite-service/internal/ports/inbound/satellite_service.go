// Package inbound defines the primary ports for the satellite-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/satellite-service/internal/domain"
)

// SatelliteService is the primary port for all satellite business operations.
type SatelliteService interface {
	RequestImagery(ctx context.Context, image *domain.SatelliteImage) (*domain.SatelliteTask, error)
	GetImage(ctx context.Context, id string) (*domain.SatelliteImage, error)
	ListImages(ctx context.Context, params domain.ListImagesParams) ([]domain.SatelliteImage, int32, error)
	ComputeVegetationIndex(ctx context.Context, imageID, fieldID, indexType string) (*domain.VegetationIndex, error)
	GetVegetationIndices(ctx context.Context, params domain.GetVegetationIndicesParams) ([]domain.VegetationIndex, error)
	DetectCropStress(ctx context.Context, imageID, fieldID string) (*domain.CropStressAlert, error)
	GetTemporalAnalysis(ctx context.Context, params domain.TemporalAnalysisParams) (*domain.TemporalAnalysis, error)
	ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.CropStressAlert, int32, error)
}
