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

	CreateSoilSample(ctx context.Context, sample *domain.SoilSample) (*domain.SoilSample, error)
	GetSoilSample(ctx context.Context, id, tenantID string) (*domain.SoilSample, error)
	ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]domain.SoilSample, int64, error)

	AnalyzeSoil(ctx context.Context, sampleID, tenantID, analysisType string) (*domain.SoilAnalysis, error)
	ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]domain.SoilAnalysis, int64, error)

	GetSoilMap(ctx context.Context, fieldID, tenantID, mapType string) (*domain.SoilMap, error)

	GetSoilHealth(ctx context.Context, fieldID, tenantID string) (*domain.SoilHealthScore, error)

	GetNutrientLevels(ctx context.Context, sampleID, tenantID string) ([]domain.SoilNutrient, error)

	GenerateSoilReport(ctx context.Context, fieldID, tenantID, farmID string) (*domain.SoilReport, error)
}
