// Package outbound defines the secondary ports for the pest-prediction-service.
package outbound

import (
	"context"

	"github.com/jackc/pgx/v5"

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
)

// PestRepository is the secondary port for pest persistence.
type PestRepository interface {
	// Predictions
	CreatePrediction(ctx context.Context, p *domain.PestPrediction) (*domain.PestPrediction, error)
	GetPredictionByID(ctx context.Context, id, tenantID string) (*domain.PestPrediction, error)
	ListPredictions(ctx context.Context, params domain.ListPredictionsParams) ([]domain.PestPrediction, int32, error)
	CountPredictionsBySpecies(ctx context.Context, pestSpeciesID, tenantID string) (int, error)

	// Observations
	CreateObservation(ctx context.Context, o *domain.PestObservation) (*domain.PestObservation, error)
	ListObservations(ctx context.Context, params domain.ListObservationsParams) ([]domain.PestObservation, int32, error)

	// Species
	GetSpeciesByID(ctx context.Context, id, tenantID string) (*domain.PestSpecies, error)
	ListSpecies(ctx context.Context, params domain.ListPestSpeciesParams) ([]domain.PestSpecies, int32, error)

	// Risk maps
	GetRiskMap(ctx context.Context, pestSpeciesID, region, tenantID string) (*domain.PestRiskMap, error)

	// Alerts
	CreateAlert(ctx context.Context, a *domain.PestAlert) (*domain.PestAlert, error)
	GetAlertByID(ctx context.Context, id, tenantID string) (*domain.PestAlert, error)
	ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PestAlert, int32, error)
	AcknowledgeAlert(ctx context.Context, id, tenantID, userID string) (*domain.PestAlert, error)

	WithTx(tx pgx.Tx) PestRepository
}
