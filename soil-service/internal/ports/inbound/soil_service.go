// Package inbound defines the primary ports for the soil-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
)

// SoilService is the primary port for all soil business operations.
type SoilService interface {
	// Samples
	CreateSoilSample(ctx context.Context, sample *domain.SoilSample) (*domain.SoilSample, error)
	GetSoilSample(ctx context.Context, id, tenantID string) (*domain.SoilSample, error)
	ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]domain.SoilSample, int64, error)

	// Analyses
	AnalyzeSoil(ctx context.Context, sampleID, tenantID, analysisType string) (*domain.SoilAnalysis, error)
	ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]domain.SoilAnalysis, int64, error)

	// Maps
	GetSoilMap(ctx context.Context, fieldID, tenantID, mapType string) (*domain.SoilMap, error)

	// Health
	GetSoilHealth(ctx context.Context, fieldID, tenantID string) (*domain.SoilHealthScore, error)

	// Nutrients
	GetNutrientLevels(ctx context.Context, sampleID, tenantID string) ([]domain.SoilNutrient, error)

	// Reports
	GenerateSoilReport(ctx context.Context, fieldID, tenantID, farmID string) (*domain.SoilReport, error)
}
