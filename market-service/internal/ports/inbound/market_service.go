// Package inbound defines the primary ports for market-service.
package inbound

import (
	"context"

	"p9e.in/samavaya/agriculture/market-service/internal/domain"
)

// RecordQuotesResult reports what an ingest batch did.
//
// Rejections are returned rather than counted, so an ingester that is silently
// dropping half its feed can tell which half and why. A count alone looks like
// a healthy import right up until somebody asks why the prices are stale.
type RecordQuotesResult struct {
	Recorded int
	Rejected []string
}

// MarketService is the primary port for market operations.
type MarketService interface {
	ListMarkets(ctx context.Context, params domain.ListMarketsParams) ([]domain.Market, int64, error)

	RecordQuotes(ctx context.Context, quotes []domain.PriceQuote) (RecordQuotesResult, error)
	ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.PriceQuote, int64, error)

	GetPriceStatistics(ctx context.Context, commodity, marketID string, days int) (domain.PriceStatistics, bool, error)
	GetSellSignal(ctx context.Context, commodity, marketID string, days int) (domain.SellSignal, error)

	CreatePriceAlert(ctx context.Context, alert *domain.PriceAlert) (*domain.PriceAlert, error)
	ListPriceAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PriceAlert, int64, error)
	DeletePriceAlert(ctx context.Context, id string) (bool, error)
}
