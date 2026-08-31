// Package outbound defines the secondary ports for the yield-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
)

// YieldRepository is the secondary port for yield persistence.
type YieldRepository interface {
	CreateYield(ctx context.Context, entity *domain.Yield) (*domain.Yield, error)
	GetYieldByUUID(ctx context.Context, uuid, tenantID string) (*domain.Yield, error)
	ListYields(ctx context.Context, params domain.ListYieldParams) ([]domain.Yield, int32, error)
	UpdateYield(ctx context.Context, entity *domain.Yield) (*domain.Yield, error)
	DeleteYield(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckYieldExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckYieldNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) YieldRepository
}
