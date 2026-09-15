// Package outbound defines the secondary ports for market-service.
package outbound

import (
	"context"

	"p9e.in/samavaya/agriculture/market-service/internal/domain"
)

// MarketRepository is the secondary port for market persistence.
type MarketRepository interface {
	ListMarkets(ctx context.Context, params domain.ListMarketsParams) ([]domain.Market, int64, error)
	UpsertMarket(ctx context.Context, m *domain.Market) (*domain.Market, error)

	// UpsertQuotes writes a batch, correcting a day's price rather than adding
	// a second row for it — a feed replayed after an outage would otherwise
	// double that day's weight in every average.
	UpsertQuotes(ctx context.Context, quotes []domain.PriceQuote) (int, error)
	ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.PriceQuote, int64, error)

	// QuoteWindow returns the last `days` of quotes for one commodity at one
	// market, oldest first — the order the statistics and the trend fit expect.
	QuoteWindow(ctx context.Context, tenantID, commodity, marketID string, days int) ([]domain.PriceQuote, error)

	CreateAlert(ctx context.Context, alert *domain.PriceAlert) (*domain.PriceAlert, error)
	ListAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PriceAlert, int64, error)
	DeleteAlert(ctx context.Context, id, tenantID string) (bool, error)

	// MatchingAlerts returns the enabled alerts for a commodity and market, so
	// a newly recorded quote can be checked against them.
	MatchingAlerts(ctx context.Context, tenantID, commodity, marketID string) ([]domain.PriceAlert, error)
	MarkAlertFired(ctx context.Context, id, tenantID string, price float64) error
}

// EventPublisher is the secondary port for emitting domain events.
type EventPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}
