// Package inbound defines the primary ports for the satellite-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/satellite-service/internal/domain"
)

// SatelliteService is the primary port for all satellite business operations.
type SatelliteService interface {
	CreateSatellite(ctx context.Context, entity *domain.Satellite) (*domain.Satellite, error)
	GetSatellite(ctx context.Context, uuid string) (*domain.Satellite, error)
	ListSatellites(ctx context.Context, params domain.ListSatelliteParams) ([]domain.Satellite, int32, error)
	UpdateSatellite(ctx context.Context, entity *domain.Satellite) (*domain.Satellite, error)
	DeleteSatellite(ctx context.Context, uuid string) error
}
