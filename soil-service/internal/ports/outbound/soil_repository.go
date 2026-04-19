// Package outbound defines the secondary ports for the soil-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
)

// SoilRepository is the secondary port for soil persistence.
type SoilRepository interface {
	CreateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error)
	GetSoilByUUID(ctx context.Context, uuid, tenantID string) (*domain.Soil, error)
	ListSoils(ctx context.Context, params domain.ListSoilParams) ([]domain.Soil, int32, error)
	UpdateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error)
	DeleteSoil(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckSoilExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckSoilNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) SoilRepository
}
