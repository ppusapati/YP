// Package inbound defines the primary ports for the pest-prediction-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
)

// PestService is the primary port for all pest business operations.
type PestService interface {
	CreatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error)
	GetPest(ctx context.Context, uuid string) (*domain.Pest, error)
	ListPestPredictions(ctx context.Context, params domain.ListPestPredictionParams) ([]domain.Pest, int32, error)
	UpdatePest(ctx context.Context, entity *domain.Pest) (*domain.Pest, error)
	DeletePest(ctx context.Context, uuid string) error
}
