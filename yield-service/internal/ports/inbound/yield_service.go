// Package inbound defines the primary ports for the yield-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
)

// YieldService is the primary port for all yield business operations.
type YieldService interface {
	PredictYield(ctx context.Context, prediction *domain.YieldPrediction) (*domain.YieldPrediction, error)
	GetPrediction(ctx context.Context, id string) (*domain.YieldPrediction, error)
	ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.YieldPrediction, int32, error)

	RecordYield(ctx context.Context, record *domain.YieldRecord) (*domain.YieldRecord, error)
	GetYieldHistory(ctx context.Context, params domain.YieldHistoryParams) ([]domain.YieldRecord, int32, error)

	CreateHarvestPlan(ctx context.Context, plan *domain.HarvestPlan) (*domain.HarvestPlan, error)
	GetHarvestPlan(ctx context.Context, id string) (*domain.HarvestPlan, error)
	ListHarvestPlans(ctx context.Context, params domain.ListHarvestPlansParams) ([]domain.HarvestPlan, int32, error)

	GetCropPerformance(ctx context.Context, params domain.CropPerformanceParams) (*domain.CropPerformance, error)
	CompareYields(ctx context.Context, params domain.CompareYieldsParams) (*domain.CropPerformance, *domain.CropPerformance, error)
}
