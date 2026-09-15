// Package outbound defines the secondary ports for planning-service.
package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/planning-service/internal/domain"
)

// PlanRepository is the secondary port for plan persistence.
type PlanRepository interface {
	CreatePlan(ctx context.Context, p *domain.SeasonPlan) (*domain.SeasonPlan, error)
	GetPlan(ctx context.Context, id, tenantID string) (*domain.SeasonPlan, error)
	ListPlans(ctx context.Context, params domain.ListPlansParams) ([]domain.SeasonPlan, int64, error)
	UpdatePlan(ctx context.Context, p *domain.SeasonPlan, baseVersion int64) (*domain.SeasonPlan, error)
	SetStatus(ctx context.Context, id, tenantID string, status domain.PlanStatus) (*domain.SeasonPlan, error)

	// PreviousCrop is what the field last grew, for the rotation check.
	//
	// Returns "" without an error when there is no history: a newly broken
	// field has none, and that is not a failure — it is the reason the check
	// reports "unverified" rather than "good".
	PreviousCrop(ctx context.Context, tenantID, fieldID string, beforeYear int, beforeSeason domain.Season) (string, error)
}

// WeatherClient is the secondary port for rainfall history.
//
// Optional by design: a deployment with no weather-service still plans, and
// the sowing window says it came from the crop calendar rather than from this
// field's own rainfall.
type WeatherClient interface {
	MonsoonOnset(ctx context.Context, fieldID string) (*domain.MonsoonOnset, error)
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
