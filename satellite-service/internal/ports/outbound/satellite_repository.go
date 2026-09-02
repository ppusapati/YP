// Package outbound defines the secondary ports for the satellite-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/satellite-service/internal/domain"
)

// SatelliteRepository is the secondary port for satellite persistence.
type SatelliteRepository interface {
	// Images
	CreateImage(ctx context.Context, img *domain.SatelliteImage) (*domain.SatelliteImage, error)
	GetImageByID(ctx context.Context, id, tenantID string) (*domain.SatelliteImage, error)
	ListImages(ctx context.Context, params domain.ListImagesParams) ([]domain.SatelliteImage, int32, error)

	// Vegetation Indices
	CreateVegetationIndex(ctx context.Context, idx *domain.VegetationIndex) (*domain.VegetationIndex, error)
	GetVegetationIndices(ctx context.Context, params domain.GetVegetationIndicesParams) ([]domain.VegetationIndex, error)
	GetVegetationIndicesForTemporal(ctx context.Context, params domain.TemporalAnalysisParams) ([]domain.VegetationIndex, error)

	// Alerts
	CreateAlert(ctx context.Context, alert *domain.CropStressAlert) (*domain.CropStressAlert, error)
	ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.CropStressAlert, int32, error)

	// Tasks
	CreateTask(ctx context.Context, task *domain.SatelliteTask) (*domain.SatelliteTask, error)

	WithTx(tx pgx.Tx) SatelliteRepository
}
