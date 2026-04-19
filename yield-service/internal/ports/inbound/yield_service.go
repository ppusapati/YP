// Package inbound defines the primary ports for the yield-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
)

// YieldService is the primary port for all yield business operations.
type YieldService interface {
	CreateYield(ctx context.Context, entity *domain.Yield) (*domain.Yield, error)
	GetYield(ctx context.Context, uuid string) (*domain.Yield, error)
	ListYields(ctx context.Context, params domain.ListYieldParams) ([]domain.Yield, int32, error)
	UpdateYield(ctx context.Context, entity *domain.Yield) (*domain.Yield, error)
	DeleteYield(ctx context.Context, uuid string) error
}
