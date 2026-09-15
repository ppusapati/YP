// Package outbound defines the secondary ports for the weather-service.
package outbound

import (
	"context"
	"time"

	"p9e.in/samavaya/agriculture/weather-service/internal/domain"
)

// WeatherRepository is the secondary port for weather persistence.
type WeatherRepository interface {
	UpsertFieldLocation(ctx context.Context, loc *domain.FieldLocation) (*domain.FieldLocation, error)
	GetFieldLocation(ctx context.Context, fieldID, tenantID string) (*domain.FieldLocation, error)
	ListFieldLocations(ctx context.Context, params domain.ListLocationsParams) ([]domain.FieldLocation, int64, error)
	ListAllFieldLocations(ctx context.Context) ([]domain.FieldLocation, error)
	TouchLastPolled(ctx context.Context, fieldID, tenantID string, at time.Time) error

	UpsertObservations(ctx context.Context, obs []domain.Observation) (int, error)
	GetLatestObservation(ctx context.Context, fieldID, tenantID string) (*domain.Observation, error)
	ListObservations(ctx context.Context, params domain.ListObservationsParams) ([]domain.Observation, int64, error)

	UpsertForecasts(ctx context.Context, fc []domain.DailyForecast) (int, error)
	ListForecasts(ctx context.Context, fieldID, tenantID string, from time.Time, days int) ([]domain.DailyForecast, error)

	UpsertDailyMetrics(ctx context.Context, rows []domain.DailyAgroMetrics) (int, error)
	ListDailyMetrics(ctx context.Context, fieldID, tenantID string, start, end time.Time) ([]domain.DailyAgroMetrics, error)

	CreateAlert(ctx context.Context, alert *domain.WeatherAlert) (*domain.WeatherAlert, error)
	AlertExists(ctx context.Context, tenantID, fieldID string, alertType domain.AlertType, validFrom time.Time) (bool, error)
	ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.WeatherAlert, int64, error)

	// InTenantTx runs fn inside a transaction whose RLS tenant variable is set,
	// so background work without a request context still satisfies row policies.
	InTenantTx(ctx context.Context, tenantID string, fn func(ctx context.Context, repo WeatherRepository) error) error
}

// WeatherProvider is the secondary port for an upstream weather data source.
type WeatherProvider interface {
	Name() domain.Provider
	// FetchHourly returns hourly observations from start to end (inclusive of
	// past hours; providers may also return a short horizon of future hours).
	FetchHourly(ctx context.Context, loc domain.FieldLocation, start, end time.Time) ([]domain.Observation, error)
	// FetchDailyForecast returns up to `days` days of daily forecast.
	FetchDailyForecast(ctx context.Context, loc domain.FieldLocation, days int) ([]domain.DailyForecast, error)
	// FetchHistoricalDaily returns daily aggregates for the historical range.
	FetchHistoricalDaily(ctx context.Context, loc domain.FieldLocation, start, end time.Time) ([]domain.DailyAgroMetrics, error)
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}

// FieldClient is the secondary port for calling field-service.
type FieldClient interface {
	// FieldCentroid returns the centroid of the field boundary and its farm ID.
	FieldCentroid(ctx context.Context, fieldID string) (lat, lon float64, farmID string, err error)
}
