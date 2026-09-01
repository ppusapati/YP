// Package inbound defines the primary ports for the soil-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/soil-service/internal/models"
)

// SoilService is the primary port for all soil business operations.
type SoilService interface {
	// Samples
	CreateSoilSample(ctx context.Context, sample *models.SoilSample) (*models.SoilSample, error)
	GetSoilSample(ctx context.Context, id, tenantID string) (*models.SoilSample, error)
	ListSoilSamples(ctx context.Context, tenantID, fieldID, farmID string, pageSize, pageOffset int32) ([]models.SoilSample, int64, error)

	// Analyses
	AnalyzeSoil(ctx context.Context, sampleID, tenantID, analysisType string) (*models.SoilAnalysis, error)
	ListSoilAnalyses(ctx context.Context, tenantID, fieldID, farmID, sampleID string, pageSize, pageOffset int32) ([]models.SoilAnalysis, int64, error)

	// Maps
	GetSoilMap(ctx context.Context, fieldID, tenantID, mapType string) (*models.SoilMap, error)

	// Health
	GetSoilHealth(ctx context.Context, fieldID, tenantID string) (*models.SoilHealthScore, error)

	// Nutrients
	GetNutrientLevels(ctx context.Context, sampleID, tenantID string) ([]models.SoilNutrient, error)

	// Reports
	GenerateSoilReport(ctx context.Context, fieldID, tenantID, farmID string) (*models.SoilReport, error)
}
