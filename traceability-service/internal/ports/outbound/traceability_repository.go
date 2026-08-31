// Package outbound defines the secondary ports for the traceability-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/traceability-service/internal/domain"
)

// TraceabilityRepository is the secondary port for traceability persistence.
type TraceabilityRepository interface {
	CreateTraceability(ctx context.Context, entity *domain.Traceability) (*domain.Traceability, error)
	GetTraceabilityByUUID(ctx context.Context, uuid, tenantID string) (*domain.Traceability, error)
	ListTraceabilitys(ctx context.Context, params domain.ListTraceabilityParams) ([]domain.Traceability, int32, error)
	UpdateTraceability(ctx context.Context, entity *domain.Traceability) (*domain.Traceability, error)
	DeleteTraceability(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckTraceabilityExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckTraceabilityNameExists(ctx context.Context, name, tenantID string) (bool, error)

	WithTx(tx pgx.Tx) TraceabilityRepository
}
