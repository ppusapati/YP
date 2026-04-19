// Package inbound defines the primary ports for the soil-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
)

// SoilService is the primary port for all soil business operations.
type SoilService interface {
	CreateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error)
	GetSoil(ctx context.Context, uuid string) (*domain.Soil, error)
	ListSoils(ctx context.Context, params domain.ListSoilParams) ([]domain.Soil, int32, error)
	UpdateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error)
	DeleteSoil(ctx context.Context, uuid string) error
}
