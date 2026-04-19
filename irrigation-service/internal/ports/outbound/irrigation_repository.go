// Package outbound defines the secondary ports for the irrigation-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

// IrrigationRepository is the secondary port for irrigation persistence.
type IrrigationRepository interface {
	CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	GetIrrigationByUUID(ctx context.Context, uuid, tenantID string) (*domain.Irrigation, error)
	ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error)
	UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	DeleteIrrigation(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckIrrigationExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckIrrigationNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) IrrigationRepository
}
