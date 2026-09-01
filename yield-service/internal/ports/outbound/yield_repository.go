// Package outbound defines the secondary ports for the yield-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
)

// YieldRepository is the secondary port for yield persistence.
type YieldRepository interface {
	CreatePrediction(ctx context.Context, p *domain.YieldPrediction) (*domain.YieldPrediction, error)
	GetPredictionByID(ctx context.Context, id, tenantID string) (*domain.YieldPrediction, error)
	ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.YieldPrediction, int32, error)

	CreateYieldRecord(ctx context.Context, r *domain.YieldRecord) (*domain.YieldRecord, error)
	ListYieldRecords(ctx context.Context, params domain.YieldHistoryParams) ([]domain.YieldRecord, int32, error)

	CreateHarvestPlan(ctx context.Context, p *domain.HarvestPlan) (*domain.HarvestPlan, error)
	GetHarvestPlanByID(ctx context.Context, id, tenantID string) (*domain.HarvestPlan, error)
	ListHarvestPlans(ctx context.Context, params domain.ListHarvestPlansParams) ([]domain.HarvestPlan, int32, error)

	GetCropPerformance(ctx context.Context, params domain.CropPerformanceParams) (*domain.CropPerformance, error)

	WithTx(tx pgx.Tx) YieldRepository
}
