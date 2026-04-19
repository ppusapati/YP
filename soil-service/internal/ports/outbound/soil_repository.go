// Package outbound defines the secondary ports for the soil-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
)

// SoilRepository is the secondary port for soil persistence.
type SoilRepository interface {
	CreateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error)
	GetSoilByUUID(ctx context.Context, uuid, tenantID string) (*domain.Soil, error)
	ListSoils(ctx context.Context, params domain.ListSoilParams) ([]domain.Soil, int32, error)
	UpdateSoil(ctx context.Context, entity *domain.Soil) (*domain.Soil, error)
	DeleteSoil(ctx context.Context, uuid, tenantID, deletedBy string) error
	CheckSoilExists(ctx context.Context, uuid, tenantID string) (bool, error)
	CheckSoilNameExists(ctx context.Context, name, tenantID string) (bool, error)
	WithTx(tx pgx.Tx) SoilRepository

	CreateSoilSample(ctx context.Context, sample *domain.SoilSample) (*domain.SoilSample, error)
	GetSoilSampleByUUID(ctx context.Context, uuid, tenantID string) (*domain.SoilSample, error)
	ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]domain.SoilSample, int64, error)
	DeleteSoilSample(ctx context.Context, uuid, tenantID string) error

	CreateSoilAnalysis(ctx context.Context, analysis *domain.SoilAnalysis) (*domain.SoilAnalysis, error)
	GetSoilAnalysisByUUID(ctx context.Context, uuid, tenantID string) (*domain.SoilAnalysis, error)
	ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]domain.SoilAnalysis, int64, error)
	UpdateSoilAnalysisStatus(ctx context.Context, uuid string, status domain.AnalysisStatus) error

	CreateSoilMap(ctx context.Context, soilMap *domain.SoilMap) (*domain.SoilMap, error)
	GetSoilMapByFieldAndType(ctx context.Context, fieldID, tenantID, mapType string) (*domain.SoilMap, error)

	CreateSoilNutrient(ctx context.Context, nutrient *domain.SoilNutrient) (*domain.SoilNutrient, error)
	ListNutrientsBySample(ctx context.Context, sampleID, tenantID string) ([]domain.SoilNutrient, error)
	BatchCreateNutrients(ctx context.Context, nutrients []domain.SoilNutrient) ([]domain.SoilNutrient, error)

	CreateSoilHealthScore(ctx context.Context, score *domain.SoilHealthScore) (*domain.SoilHealthScore, error)
	GetLatestSoilHealthScore(ctx context.Context, fieldID, tenantID string) (*domain.SoilHealthScore, error)
	UpdateSoilHealthScore(ctx context.Context, score *domain.SoilHealthScore) (*domain.SoilHealthScore, error)
	ListSoilHealthScoresByFarm(ctx context.Context, farmID, tenantID string, pageSize, pageOffset int32) ([]domain.SoilHealthScore, int64, error)
}
