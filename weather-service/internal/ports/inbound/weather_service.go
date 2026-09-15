// Package inbound defines the primary ports for the weather-service.
package inbound

import (
	"context"
	"time"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
)

// WeatherService is the primary port for all weather business operations.
type WeatherService interface {
	RegisterFieldLocation(ctx context.Context, loc *domain.FieldLocation) (*domain.FieldLocation, error)
	RegisterFieldFromFieldService(ctx context.Context, tenantID, fieldID string) (*domain.FieldLocation, error)
	GetFieldLocation(ctx context.Context, fieldID string) (*domain.FieldLocation, error)
	ListFieldLocations(ctx context.Context, params domain.ListLocationsParams) ([]domain.FieldLocation, int64, error)

	GetCurrentWeather(ctx context.Context, fieldID string) (*domain.Observation, error)
	GetForecast(ctx context.Context, fieldID string, days int) ([]domain.DailyForecast, error)
	ListObservations(ctx context.Context, params domain.ListObservationsParams) ([]domain.Observation, int64, error)
	GetAgroMetrics(ctx context.Context, fieldID string, start, end time.Time, baseC, capC float64) ([]domain.DailyAgroMetrics, domain.AgroMetricsSummary, error)

	RefreshFieldWeather(ctx context.Context, fieldID string) (obsCount, fcCount int, err error)
	BackfillHistory(ctx context.Context, fieldID string, years int) (days int, from, to time.Time, err error)

	ListWeatherAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.WeatherAlert, int64, error)

	// RefreshAll polls every registered location; used by the background scheduler.
	RefreshAll(ctx context.Context) error
}
