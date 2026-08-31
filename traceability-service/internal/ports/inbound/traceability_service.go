// Package inbound defines the primary ports for the traceability-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/traceability-service/internal/domain"
)

// TraceabilityService is the primary port for all traceability business operations.
type TraceabilityService interface {
	CreateTraceability(ctx context.Context, entity *domain.Traceability) (*domain.Traceability, error)
	GetTraceability(ctx context.Context, uuid string) (*domain.Traceability, error)
	ListTraceabilitys(ctx context.Context, params domain.ListTraceabilityParams) ([]domain.Traceability, int32, error)
	UpdateTraceability(ctx context.Context, entity *domain.Traceability) (*domain.Traceability, error)
	DeleteTraceability(ctx context.Context, uuid string) error
}
