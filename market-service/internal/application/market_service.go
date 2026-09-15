// Package application holds market-service's use cases.
package application

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/market-service/internal/domain"
	"p9e.in/samavaya/agriculture/market-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/market-service/internal/ports/outbound"
)

// eventTopic is where price-alert firings are published.
const eventTopic = "yp.market.alerts"

// DefaultStatisticsDays is the window used when a caller does not say.
//
// Thirty days: long enough for a mean to mean something on a commodity that
// moves weekly, short enough that last season's price does not drag it.
const DefaultStatisticsDays = 30

// maxStatisticsDays caps the window, so one request cannot pull a year of
// quotes for every commodity at once.
const maxStatisticsDays = 365

type marketService struct {
	repo outbound.MarketRepository
	pub  outbound.EventPublisher
	log  *p9log.Helper
	now  func() time.Time
}

// NewMarketService creates the market service.
func NewMarketService(
	repo outbound.MarketRepository,
	pub outbound.EventPublisher,
	log p9log.Logger,
) inbound.MarketService {
	return &marketService{
		repo: repo,
		pub:  pub,
		log:  p9log.NewHelper(p9log.With(log, "component", "MarketService")),
		now:  time.Now,
	}
}

func (s *marketService) ListMarkets(ctx context.Context, params domain.ListMarketsParams) ([]domain.Market, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.repo.ListMarkets(ctx, params)
}

// RecordQuotes normalises and stores a batch of price quotes, then checks them
// against the standing alerts.
//
// One bad quote does not sink the batch. A mandi feed carrying two hundred
// commodities regularly has a handful of malformed rows, and refusing the
// whole import for them would leave the prices stale — which is worse than
// importing 198 of 200 and saying which two were dropped.
func (s *marketService) RecordQuotes(ctx context.Context, quotes []domain.PriceQuote) (inbound.RecordQuotesResult, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return inbound.RecordQuotesResult{}, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if len(quotes) == 0 {
		return inbound.RecordQuotesResult{}, errors.BadRequest("NO_QUOTES", "at least one quote is required")
	}

	now := s.now()
	accepted := make([]domain.PriceQuote, 0, len(quotes))
	var rejected []string

	for i := range quotes {
		q := quotes[i]
		q.TenantID = tenantID
		if q.ID == "" {
			q.ID = ulid.NewString()
		}
		if err := q.Normalise(now); err != nil {
			rejected = append(rejected, fmt.Sprintf(
				"quotes[%d] %s at %s on %s: %v",
				i, q.Commodity, q.MarketID, q.QuotedOn.Format("2006-01-02"), err,
			))
			continue
		}
		accepted = append(accepted, q)
	}

	if len(accepted) == 0 {
		return inbound.RecordQuotesResult{Rejected: rejected}, nil
	}

	written, err := s.repo.UpsertQuotes(ctx, accepted)
	if err != nil {
		return inbound.RecordQuotesResult{}, err
	}

	// Alerts are checked after the write, so a firing always refers to a price
	// that is actually stored. Failures here are logged and not returned: the
	// prices are in, and losing the import because a notification could not be
	// published would be the wrong trade.
	s.checkAlerts(ctx, tenantID, accepted)

	return inbound.RecordQuotesResult{Recorded: written, Rejected: rejected}, nil
}

// checkAlerts fires the standing alerts that a new batch crosses.
func (s *marketService) checkAlerts(ctx context.Context, tenantID string, quotes []domain.PriceQuote) {
	// One lookup per commodity-market pair rather than per quote: a batch of
	// two hundred quotes usually covers a few dozen pairs.
	type pair struct{ commodity, marketID string }
	latest := make(map[pair]domain.PriceQuote)
	for _, q := range quotes {
		key := pair{q.Commodity, q.MarketID}
		if existing, ok := latest[key]; !ok || q.QuotedOn.After(existing.QuotedOn) {
			latest[key] = q
		}
	}

	for key, q := range latest {
		alerts, err := s.repo.MatchingAlerts(ctx, tenantID, key.commodity, key.marketID)
		if err != nil {
			s.log.Warnw("msg", "could not load alerts", "commodity", key.commodity, "error", err)
			continue
		}
		for i := range alerts {
			alert := alerts[i]
			hasPrevious := alert.LastFiredAt != nil
			if !alert.ShouldFire(q.PricePerQuintal, alert.LastFiredPrice, hasPrevious) {
				continue
			}
			if err := s.repo.MarkAlertFired(ctx, alert.ID, tenantID, q.PricePerQuintal); err != nil {
				s.log.Warnw("msg", "could not mark alert fired", "alert", alert.ID, "error", err)
				continue
			}
			s.publishAlert(ctx, alert, q)
		}
	}
}

func (s *marketService) publishAlert(ctx context.Context, alert domain.PriceAlert, q domain.PriceQuote) {
	if s.pub == nil {
		return
	}
	payload, err := json.Marshal(map[string]any{
		"tenant_id":             alert.TenantID,
		"alert_id":              alert.ID,
		"commodity":             alert.Commodity,
		"market_id":             alert.MarketID,
		"direction":             alert.Direction,
		"threshold_per_quintal": alert.ThresholdPerQuintal,
		"price_per_quintal":     q.PricePerQuintal,
		"quoted_on":             q.QuotedOn,
	})
	if err != nil {
		s.log.Errorw("msg", "could not encode alert event", "alert", alert.ID, "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, alert.ID, payload); err != nil {
		s.log.Warnw("msg", "could not publish alert event", "alert", alert.ID, "error", err)
	}
}

func (s *marketService) ListQuotes(ctx context.Context, params domain.ListQuotesParams) ([]domain.PriceQuote, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.repo.ListQuotes(ctx, params)
}

// GetPriceStatistics summarises a commodity's recent prices at a market.
//
// The bool reports whether there were any quotes at all. A zeroed struct would
// render as "the price is ₹0", which reads as data rather than as an absence.
func (s *marketService) GetPriceStatistics(ctx context.Context, commodity, marketID string, days int) (domain.PriceStatistics, bool, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return domain.PriceStatistics{}, false, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(commodity) == "" {
		return domain.PriceStatistics{}, false, errors.BadRequest("MISSING_COMMODITY", "commodity is required")
	}
	if strings.TrimSpace(marketID) == "" {
		return domain.PriceStatistics{}, false, errors.BadRequest("MISSING_MARKET", "market_id is required")
	}

	quotes, err := s.repo.QuoteWindow(ctx, tenantID, commodity, marketID, clampDays(days))
	if err != nil {
		return domain.PriceStatistics{}, false, err
	}

	stats, ok := domain.ComputeStatistics(commodity, marketID, quotes)
	return stats, ok, nil
}

// GetSellSignal turns the recent price window into timing advice.
func (s *marketService) GetSellSignal(ctx context.Context, commodity, marketID string, days int) (domain.SellSignal, error) {
	stats, ok, err := s.GetPriceStatistics(ctx, commodity, marketID, days)
	if err != nil {
		return domain.SellSignal{}, err
	}

	signal := domain.GenerateSellSignal(stats, ok, s.now())
	// Carried through even when there were no quotes, so the caller can label
	// the empty answer with what it asked about.
	signal.Commodity = commodity
	signal.MarketID = marketID
	return signal, nil
}

func (s *marketService) CreatePriceAlert(ctx context.Context, alert *domain.PriceAlert) (*domain.PriceAlert, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}

	alert.TenantID = tenantID
	alert.ID = ulid.NewString()
	alert.Enabled = true
	alert.CreatedAt = s.now()
	if user := p9context.UserID(ctx); user != "" {
		alert.CreatedBy = user
	} else {
		alert.CreatedBy = "system"
	}

	if err := alert.Validate(); err != nil {
		return nil, errors.BadRequest("INVALID_ALERT", err.Error())
	}

	return s.repo.CreateAlert(ctx, alert)
}

func (s *marketService) ListPriceAlerts(ctx context.Context, params domain.ListAlertsParams) ([]domain.PriceAlert, int64, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	params.TenantID = tenantID
	params.Limit = clampLimit(params.Limit)
	return s.repo.ListAlerts(ctx, params)
}

func (s *marketService) DeletePriceAlert(ctx context.Context, id string) (bool, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return false, errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	if strings.TrimSpace(id) == "" {
		return false, errors.BadRequest("MISSING_ID", "id is required")
	}
	return s.repo.DeleteAlert(ctx, id, tenantID)
}

// clampLimit keeps a page size sane. Zero means "the caller did not say".
func clampLimit(limit int) int {
	switch {
	case limit <= 0:
		return 50
	case limit > 500:
		return 500
	default:
		return limit
	}
}

func clampDays(days int) int {
	switch {
	case days <= 0:
		return DefaultStatisticsDays
	case days > maxStatisticsDays:
		return maxStatisticsDays
	default:
		return days
	}
}
