// Package inbound defines the primary ports for the pest-prediction-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
)

// PestService is the primary port for all pest business operations.
type PestService interface {
	PredictPestRisk(ctx context.Context, params *domain.PredictPestRiskParams) (*domain.PestPrediction, error)
	GetPrediction(ctx context.Context, id string) (*domain.PestPrediction, error)
	ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.PestPrediction, int32, error)
	ReportObservation(ctx context.Context, obs *domain.PestObservation) (*domain.PestObservation, error)
	ListObservations(ctx context.Context, params domain.ListObservationsParams) ([]domain.PestObservation, int32, error)
	GetPestSpecies(ctx context.Context, id string) (*domain.PestSpecies, error)
	ListPestSpecies(ctx context.Context, params domain.ListPestSpeciesParams) ([]domain.PestSpecies, int32, error)
	GetTreatmentPlan(ctx context.Context, predictionID string) (*domain.PestPrediction, error)
	GetRiskMap(ctx context.Context, pestSpeciesID, region string) (*domain.PestRiskMap, error)
	ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PestAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, id string) (*domain.PestAlert, error)
}
