// Package outbound defines the secondary ports for the pest-prediction-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
)

// PestRepository is the secondary port for pest persistence.
type PestRepository interface {
	CreatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error)
	GetPestByUUID(ctx context.Context, uuid, tenantID string) (*domain.Pest, error)
	ListPestPredictions(ctx context.Context, params domain.ListPestPredictionParams) ([]domain.Pest, int32, error)
	UpdatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error)
	DeletePest(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckPestExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckPestNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) PestRepository
}
