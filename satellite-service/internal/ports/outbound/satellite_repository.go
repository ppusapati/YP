// Package outbound defines the secondary ports for the satellite-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/satellite-service/internal/domain"
)

// SatelliteRepository is the secondary port for satellite persistence.
type SatelliteRepository interface {
	CreateSatellite(ctx context.Context, entity *domain.Satellite) (*domain.Satellite, error)
	GetSatelliteByUUID(ctx context.Context, uuid, tenantID string) (*domain.Satellite, error)
	ListSatellites(ctx context.Context, params domain.ListSatelliteParams) ([]domain.Satellite, int32, error)
	UpdateSatellite(ctx context.Context, entity *domain.Satellite) (*domain.Satellite, error)
	DeleteSatellite(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckSatelliteExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckSatelliteNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) SatelliteRepository
}
