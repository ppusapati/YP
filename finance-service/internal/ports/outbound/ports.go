// Package outbound defines the secondary ports for finance-service.
package outbound

import (
	"context"
	"time"

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
)

// QuoteRepository is the secondary port for stored quotes.
type QuoteRepository interface {
	CreateQuote(ctx context.Context, q *domain.InsuranceQuote) (*domain.InsuranceQuote, error)
	GetQuote(ctx context.Context, id, tenantID string) (*domain.InsuranceQuote, error)
	ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.InsuranceQuote, int64, error)
}

// CreditRepository is the secondary port for stored credit assessments.
type CreditRepository interface {
	SaveAssessment(ctx context.Context, a *domain.CreditAssessment) (*domain.CreditAssessment, error)
	GetAssessment(ctx context.Context, id, tenantID string) (*domain.CreditAssessment, error)
}

// ClaimRepository is the secondary port for claims.
type ClaimRepository interface {
	CreateClaim(ctx context.Context, c *domain.Claim) (*domain.Claim, error)
	GetClaim(ctx context.Context, id, tenantID string) (*domain.Claim, error)
	ListClaims(ctx context.Context, params domain.ListClaimsParams) ([]domain.Claim, int64, error)
	SaveClaim(ctx context.Context, c *domain.Claim) (*domain.Claim, error)
}

// YieldClient reads the harvest record every part of this service depends on.
//
// Not optional. A quote priced without it is a benchmark and a credit score
// without it cannot exist, so a deployment with no yield-service can do very
// little here — which the service says rather than quietly pricing everything
// off benchmarks as though it had looked.
type YieldClient interface {
	FieldHistory(ctx context.Context, fieldID string, fromYear, toYear int) ([]domain.YieldSeason, error)
	FarmHistory(ctx context.Context, farmID string, fromYear, toYear int) ([]domain.YieldSeason, error)
}

// SatelliteClient reads the imagery behind a claim's evidence.
type SatelliteClient interface {
	// NDVISeries returns the field's readings over a window, each carrying the
	// cloud cover of the scene it came from. The cloud figure is what lets the
	// assessment discard a reading that is mostly sky — without it a flood
	// claim gets contradicted by a cloud top.
	NDVISeries(ctx context.Context, fieldID string, from, to time.Time) ([]domain.NDVIObservation, error)
}

// WeatherClient reads what the weather did over a loss window.
type WeatherClient interface {
	Window(ctx context.Context, fieldID string, from, to time.Time) (domain.WeatherWindow, error)
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
