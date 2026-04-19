// Package inbound defines the primary ports for the irrigation-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
)

// IrrigationService is the primary port for all irrigation business operations.
type IrrigationService interface {
	CreateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	GetIrrigation(ctx context.Context, uuid string) (*domain.Irrigation, error)
	ListIrrigations(ctx context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error)
	UpdateIrrigation(ctx context.Context, entity *domain.Irrigation) (*domain.Irrigation, error)
	DeleteIrrigation(ctx context.Context, uuid string) error
}
