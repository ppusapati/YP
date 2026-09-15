// Package domain holds market-service's entities and the pricing logic.
package domain

import (
	"errors"
	"fmt"
	"math"
	"sort"
	"strings"
	"time"
)

// Errors the domain returns.
var (
	ErrUnknownUnit      = errors.New("market: price unit is required")
	ErrNegativePrice    = errors.New("market: price cannot be negative")
	ErrPriceRangeWrong  = errors.New("market: min price is above max price")
	ErrModalOutOfRange  = errors.New("market: modal price is outside the min-max range")
	ErrMissingCommodity = errors.New("market: commodity is required")
	ErrMissingMarket    = errors.New("market: market is required")
	ErrFutureQuote      = errors.New("market: quote is dated in the future")
	ErrThresholdInvalid = errors.New("market: alert threshold must be positive")
)

// PriceUnit is the quantity a price is quoted against.
type PriceUnit string

const (
	UnitPerKg      PriceUnit = "PER_KG"
	UnitPerQuintal PriceUnit = "PER_QUINTAL"
	UnitPerTonne   PriceUnit = "PER_TONNE"
)

// quintalsPer converts one of the unit's quantities into quintals.
//
// A quintal is 100 kg, and it is the unit India's mandi price reports use. The
// conversions are exact rather than approximate because a rounding error here
// shifts every downstream comparison by the same amount and is invisible.
func (u PriceUnit) quintalsPer() (float64, bool) {
	switch u {
	case UnitPerKg:
		return 0.01, true // 1 kg = 0.01 quintal
	case UnitPerQuintal:
		return 1, true
	case UnitPerTonne:
		return 10, true // 1 tonne = 10 quintals
	default:
		return 0, false
	}
}

// ToPerQuintal converts a price quoted in this unit into rupees per quintal.
//
// This is the single conversion in the service. Mandi prices arrive per
// quintal, exchanges quote per tonne, and a farm-gate offer is usually per
// kilogram; comparing them unconverted makes ₹5,000/quintal look a hundred
// times larger than ₹50/kg, which is the same price.
func (u PriceUnit) ToPerQuintal(price float64) (float64, error) {
	quintals, ok := u.quintalsPer()
	if !ok {
		return 0, ErrUnknownUnit
	}
	return price / quintals * 1, nil
}

// MarketKind is where a price came from.
type MarketKind string

const (
	MarketMandi    MarketKind = "MANDI"
	MarketExchange MarketKind = "EXCHANGE"
	MarketFarmGate MarketKind = "FARM_GATE"
)

// Market is a place prices are quoted.
type Market struct {
	ID          string     `json:"id" db:"id"`
	TenantID    string     `json:"tenant_id" db:"tenant_id"`
	Name        string     `json:"name" db:"name"`
	Kind        MarketKind `json:"kind" db:"kind"`
	State       string     `json:"state" db:"state"`
	District    string     `json:"district" db:"district"`
	Latitude    float64    `json:"latitude" db:"latitude"`
	Longitude   float64    `json:"longitude" db:"longitude"`
	ExternalRef string     `json:"external_ref" db:"external_ref"`
	CreatedAt   time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at" db:"updated_at"`
}

// PriceQuote is one commodity's price at one market on one day.
type PriceQuote struct {
	ID         string `json:"id" db:"id"`
	TenantID   string `json:"tenant_id" db:"tenant_id"`
	Commodity  string `json:"commodity" db:"commodity"`
	Variety    string `json:"variety" db:"variety"`
	MarketID   string `json:"market_id" db:"market_id"`
	MarketName string `json:"market_name" db:"market_name"`

	MinPrice   float64   `json:"min_price" db:"min_price"`
	MaxPrice   float64   `json:"max_price" db:"max_price"`
	ModalPrice float64   `json:"modal_price" db:"modal_price"`
	Unit       PriceUnit `json:"unit" db:"unit"`
	Currency   string    `json:"currency" db:"currency"`

	// PricePerQuintal is the modal price normalised, computed on the way in so
	// every read and every statistic works in one unit.
	PricePerQuintal float64 `json:"price_per_quintal" db:"price_per_quintal"`

	ArrivalsTonnes float64   `json:"arrivals_tonnes" db:"arrivals_tonnes"`
	QuotedOn       time.Time `json:"quoted_on" db:"quoted_on"`
	Source         string    `json:"source" db:"source"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
}

// Normalise validates a quote and fills in its per-quintal price.
//
// Rejecting rather than repairing: a quote whose modal price sits outside its
// own min-max range is a parsing error in the feed, and storing it would put a
// wrong number into every statistic computed afterwards, where it is far
// harder to notice than a rejection at ingest.
func (q *PriceQuote) Normalise(now time.Time) error {
	if strings.TrimSpace(q.Commodity) == "" {
		return ErrMissingCommodity
	}
	if strings.TrimSpace(q.MarketID) == "" {
		return ErrMissingMarket
	}
	if q.MinPrice < 0 || q.MaxPrice < 0 || q.ModalPrice < 0 {
		return ErrNegativePrice
	}
	if q.MinPrice > q.MaxPrice {
		return ErrPriceRangeWrong
	}
	// A feed that reports only a modal price leaves min and max at zero; that
	// is normal and must not be read as a range the modal price falls outside.
	if q.MaxPrice > 0 && (q.ModalPrice < q.MinPrice || q.ModalPrice > q.MaxPrice) {
		return ErrModalOutOfRange
	}
	// Quotes are dated by the market day, so a timestamp later than today is a
	// timezone bug in the ingester rather than tomorrow's price.
	if q.QuotedOn.After(now.Add(24 * time.Hour)) {
		return ErrFutureQuote
	}

	perQuintal, err := q.Unit.ToPerQuintal(q.ModalPrice)
	if err != nil {
		return err
	}
	q.PricePerQuintal = perQuintal

	if q.Currency == "" {
		q.Currency = "INR"
	}
	return nil
}

// PriceTrend summarises where a price has been going.
type PriceTrend string

const (
	TrendRising  PriceTrend = "RISING"
	TrendFalling PriceTrend = "FALLING"
	TrendFlat    PriceTrend = "FLAT"
)

// PriceStatistics summarises a commodity's recent prices at a market.
type PriceStatistics struct {
	Commodity string `json:"commodity"`
	MarketID  string `json:"market_id"`

	MeanPerQuintal   float64 `json:"mean_per_quintal"`
	MedianPerQuintal float64 `json:"median_per_quintal"`
	MinPerQuintal    float64 `json:"min_per_quintal"`
	MaxPerQuintal    float64 `json:"max_per_quintal"`
	LatestPerQuintal float64 `json:"latest_per_quintal"`

	// StdDevPerQuintal is the population standard deviation of the window.
	StdDevPerQuintal float64 `json:"std_dev_per_quintal"`

	// LatestZScore is how far the latest price is from the mean, in standard
	// deviations. A percentage would say a 5% move is a 5% move whether the
	// commodity normally moves 1% a week or 15%; this says whether it is
	// unusual for *this* commodity.
	LatestZScore float64 `json:"latest_z_score"`

	// Trend and TrendPerDay fit the whole window: where the price has been
	// going over the period, which is the context a person wants to see.
	Trend       PriceTrend `json:"trend"`
	TrendPerDay float64    `json:"trend_per_day"`

	// RecentTrend fits only the last few observations: where the price has been
	// going lately, as against over the whole window.
	RecentTrend       PriceTrend `json:"recent_trend"`
	RecentTrendPerDay float64    `json:"recent_trend_per_day"`

	// AtWindowHigh is true when the latest price is the highest in the window.
	//
	// This, rather than either slope, is what the sell decision turns on, and
	// the reason is a case both fits get wrong. A commodity that sat flat for
	// eight days, spiked, and has ticked down once has a *rising* slope on any
	// window long enough to include the step — the jump dominates the fit —
	// while the thing a farmer needs to know is that the peak has passed.
	// "Is it still making new highs?" answers that without a threshold to
	// tune, and it is the question a person actually asks.
	AtWindowHigh bool `json:"at_window_high"`

	ObservationDays int `json:"observation_days"`
}

// MinObservationsForSignal is the shortest history the signal will speak from.
//
// Seven daily quotes. Fewer cannot distinguish a trend from two noisy days,
// and a recommendation drawn from three points carries the same visual weight
// on screen as one drawn from three months.
const MinObservationsForSignal = 7

// flatTrendThresholdPerDay is the slope below which a price is called flat.
//
// ₹2 per quintal per day is about ₹60 a month on a commodity trading near
// ₹5,000 — roughly 1%, which is inside the noise of daily mandi reporting and
// not a trend anybody should act on.
const flatTrendThresholdPerDay = 2.0

// ComputeStatistics summarises a window of quotes.
//
// Quotes must be ordered oldest first. Returns ok=false for an empty window
// rather than a zeroed struct, because a struct of zeros renders as "the price
// is ₹0" and reads as data.
func ComputeStatistics(commodity, marketID string, quotes []PriceQuote) (PriceStatistics, bool) {
	if len(quotes) == 0 {
		return PriceStatistics{}, false
	}

	prices := make([]float64, len(quotes))
	for i, q := range quotes {
		prices[i] = q.PricePerQuintal
	}

	sum := 0.0
	minPrice, maxPrice := prices[0], prices[0]
	for _, p := range prices {
		sum += p
		minPrice = math.Min(minPrice, p)
		maxPrice = math.Max(maxPrice, p)
	}
	mean := sum / float64(len(prices))

	variance := 0.0
	for _, p := range prices {
		variance += (p - mean) * (p - mean)
	}
	variance /= float64(len(prices))
	stdDev := math.Sqrt(variance)

	sorted := append([]float64(nil), prices...)
	sort.Float64s(sorted)
	median := sorted[len(sorted)/2]
	if len(sorted)%2 == 0 {
		median = (sorted[len(sorted)/2-1] + sorted[len(sorted)/2]) / 2
	}

	latest := prices[len(prices)-1]

	// A zero standard deviation means every price in the window was identical.
	// The z-score is undefined there, and reporting it as 0 is right: the
	// latest price is exactly at the mean.
	z := 0.0
	if stdDev > 0 {
		z = (latest - mean) / stdDev
	}

	slope := leastSquaresSlopePerDay(quotes)
	recentSlope := leastSquaresSlopePerDay(recentWindow(quotes))

	return PriceStatistics{
		Commodity:         commodity,
		MarketID:          marketID,
		MeanPerQuintal:    mean,
		MedianPerQuintal:  median,
		MinPerQuintal:     minPrice,
		MaxPerQuintal:     maxPrice,
		LatestPerQuintal:  latest,
		StdDevPerQuintal:  stdDev,
		LatestZScore:      z,
		Trend:             classifyTrend(slope),
		TrendPerDay:       slope,
		RecentTrend:       classifyTrend(recentSlope),
		RecentTrendPerDay: recentSlope,
		AtWindowHigh:      latest >= maxPrice,
		ObservationDays:   len(quotes),
	}, true
}

// classifyTrend turns a slope into a direction, with a dead band.
func classifyTrend(slopePerDay float64) PriceTrend {
	switch {
	case slopePerDay > flatTrendThresholdPerDay:
		return TrendRising
	case slopePerDay < -flatTrendThresholdPerDay:
		return TrendFalling
	default:
		return TrendFlat
	}
}

// recentObservations is how many quotes the "going now" fit uses.
//
// Five. Fewer is two points and a straight line through noise; more starts to
// average away the turn the signal is trying to catch.
const recentObservations = 5

// recentWindow is the tail of the series the recent trend is fitted to.
//
// Never more than half the window, so a short history does not have its
// "recent" and "overall" trends computed from nearly the same points and then
// reported as if they were independent.
func recentWindow(quotes []PriceQuote) []PriceQuote {
	n := recentObservations
	if half := len(quotes) / 2; half < n {
		n = half
	}
	if n < 2 {
		return quotes
	}
	return quotes[len(quotes)-n:]
}

// leastSquaresSlopePerDay fits a line to the quotes and returns its slope in
// rupees per quintal per day.
//
// Regressed against the actual dates rather than against the index, because
// mandi reporting has gaps — holidays, closures — and treating a 5-day gap as
// one step makes a slow drift look like a jump.
func leastSquaresSlopePerDay(quotes []PriceQuote) float64 {
	if len(quotes) < 2 {
		return 0
	}

	origin := quotes[0].QuotedOn
	var sumX, sumY, sumXY, sumXX float64
	n := float64(len(quotes))

	for _, q := range quotes {
		x := q.QuotedOn.Sub(origin).Hours() / 24
		y := q.PricePerQuintal
		sumX += x
		sumY += y
		sumXY += x * y
		sumXX += x * x
	}

	denominator := n*sumXX - sumX*sumX
	if denominator == 0 {
		// Every quote on the same day: no slope to fit.
		return 0
	}
	return (n*sumXY - sumX*sumY) / denominator
}

// SellRecommendation is what the timing signal suggests.
type SellRecommendation string

const (
	SellNow          SellRecommendation = "SELL_NOW"
	Hold             SellRecommendation = "HOLD"
	InsufficientData SellRecommendation = "INSUFFICIENT_DATA"
)

// SellSignal is the timing advice for one commodity at one market.
type SellSignal struct {
	Commodity      string             `json:"commodity"`
	MarketID       string             `json:"market_id"`
	Recommendation SellRecommendation `json:"recommendation"`
	Confidence     float64            `json:"confidence"`
	Rationale      string             `json:"rationale"`
	Statistics     PriceStatistics    `json:"statistics"`
	GeneratedAt    time.Time          `json:"generated_at"`
}

// strongMoveZ is how far above the mean counts as a genuinely good price.
//
// One standard deviation. Higher would mean the signal almost never fires;
// lower would have it firing on ordinary weekly variation, and a signal that
// says "sell" every other day is one a farmer learns to ignore.
const strongMoveZ = 1.0

// GenerateSellSignal turns a price window into timing advice.
//
// The direction it reasons from is [PriceStatistics.RecentTrend], not the
// whole-window fit — see the note on that field for why the two differ and
// why using the wrong one gives confidently wrong advice.
//
// The reasoning, in the order it is applied:
//
//  1. **Not enough history is its own answer.** With fewer than
//     [MinObservationsForSignal] quotes the signal says so, rather than
//     guessing from three points and presenting it the same way as advice
//     drawn from three months.
//  2. **Price above the mean and still making new highs** is not a reason to
//     sell — it is a reason to wait, because it has not peaked yet.
//  3. **Price above the mean and off its peak** is the sell case: this is
//     about as good as it has been and it is no longer improving.
//  4. **Price below the mean** is a hold, whichever way it is moving. Selling
//     into a low is the decision this feature exists to help avoid.
//
// Confidence scales with both how unusual the price is and how much history
// there is. A recommendation given with false certainty does more harm than
// no recommendation, because a farmer acts on it.
func GenerateSellSignal(stats PriceStatistics, hasStats bool, now time.Time) SellSignal {
	signal := SellSignal{
		Commodity:   stats.Commodity,
		MarketID:    stats.MarketID,
		Statistics:  stats,
		GeneratedAt: now,
	}

	if !hasStats || stats.ObservationDays < MinObservationsForSignal {
		signal.Recommendation = InsufficientData
		signal.Confidence = 0
		signal.Rationale = fmt.Sprintf(
			"Only %d day(s) of prices for this commodity at this market; "+
				"at least %d are needed before a timing signal means anything.",
			stats.ObservationDays, MinObservationsForSignal,
		)
		return signal
	}

	z := stats.LatestZScore
	historyWeight := math.Min(float64(stats.ObservationDays)/30.0, 1.0)

	switch {
	case z >= strongMoveZ && !stats.AtWindowHigh:
		signal.Recommendation = SellNow
		signal.Confidence = clamp01(math.Min(math.Abs(z)/2.0, 1.0) * historyWeight)
		signal.Rationale = fmt.Sprintf(
			"₹%.0f/quintal is %.1f standard deviations above the %d-day mean of ₹%.0f, "+
				"and is below the %d-day high of ₹%.0f. The price is near the top of its "+
				"recent range and has stopped making new highs.",
			stats.LatestPerQuintal, z, stats.ObservationDays, stats.MeanPerQuintal,
			stats.ObservationDays, stats.MaxPerQuintal,
		)

	case z >= strongMoveZ && stats.AtWindowHigh:
		signal.Recommendation = Hold
		signal.Confidence = clamp01(math.Min(math.Abs(z)/2.0, 1.0) * historyWeight)
		signal.Rationale = fmt.Sprintf(
			"₹%.0f/quintal is already %.1f standard deviations above the %d-day mean, "+
				"and is the highest price in that window. It has not peaked yet, so waiting "+
				"is likely to pay.",
			stats.LatestPerQuintal, z, stats.ObservationDays,
		)

	case z <= -strongMoveZ:
		signal.Recommendation = Hold
		signal.Confidence = clamp01(math.Min(math.Abs(z)/2.0, 1.0) * historyWeight)
		signal.Rationale = fmt.Sprintf(
			"₹%.0f/quintal is %.1f standard deviations below the %d-day mean of ₹%.0f. "+
				"Selling into this would take a price well under what this market has been paying.",
			stats.LatestPerQuintal, math.Abs(z), stats.ObservationDays, stats.MeanPerQuintal,
		)

	default:
		signal.Recommendation = Hold
		// Deliberately low: the price is unremarkable, so the honest signal is
		// a weak one rather than a confident "hold".
		signal.Confidence = clamp01(0.3 * historyWeight)
		signal.Rationale = fmt.Sprintf(
			"₹%.0f/quintal is close to the %d-day mean of ₹%.0f and the trend is %s. "+
				"Nothing in the recent prices argues for selling today in particular.",
			stats.LatestPerQuintal, stats.ObservationDays, stats.MeanPerQuintal,
			strings.ToLower(string(stats.RecentTrend)),
		)
	}

	return signal
}

func clamp01(v float64) float64 {
	return math.Max(0, math.Min(1, v))
}

// AlertDirection is which way a price must move to fire an alert.
type AlertDirection string

const (
	AlertAbove AlertDirection = "ABOVE"
	AlertBelow AlertDirection = "BELOW"
)

// PriceAlert fires when a commodity crosses a threshold at a market.
type PriceAlert struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`

	Commodity string `json:"commodity" db:"commodity"`
	MarketID  string `json:"market_id" db:"market_id"`

	Direction           AlertDirection `json:"direction" db:"direction"`
	ThresholdPerQuintal float64        `json:"threshold_per_quintal" db:"threshold_per_quintal"`

	Enabled bool `json:"enabled" db:"enabled"`

	CreatedBy      string     `json:"created_by" db:"created_by"`
	CreatedAt      time.Time  `json:"created_at" db:"created_at"`
	LastFiredAt    *time.Time `json:"last_fired_at" db:"last_fired_at"`
	LastFiredPrice float64    `json:"last_fired_price" db:"last_fired_price"`
}

// Validate checks an alert can be acted on.
func (a *PriceAlert) Validate() error {
	if strings.TrimSpace(a.Commodity) == "" {
		return ErrMissingCommodity
	}
	if strings.TrimSpace(a.MarketID) == "" {
		return ErrMissingMarket
	}
	if a.ThresholdPerQuintal <= 0 {
		return ErrThresholdInvalid
	}
	if a.Direction != AlertAbove && a.Direction != AlertBelow {
		return fmt.Errorf("market: alert direction %q is not ABOVE or BELOW", a.Direction)
	}
	return nil
}

// ShouldFire reports whether a quote crosses this alert's threshold.
//
// A *crossing*, not a state: an alert that fires on every quote while the price
// stays above the threshold sends a farmer twenty notifications for one event
// and teaches them to turn alerts off. It fires again only once the price has
// been back on the other side.
func (a *PriceAlert) ShouldFire(pricePerQuintal float64, previousPrice float64, hasPrevious bool) bool {
	if !a.Enabled {
		return false
	}

	nowSatisfied := a.satisfied(pricePerQuintal)
	if !nowSatisfied {
		return false
	}
	if !hasPrevious {
		// The first quote we have ever seen for this alert. Firing is right:
		// the farmer asked to be told when the price is above ₹X and it is.
		return true
	}
	// Already satisfied last time: this is the same event continuing.
	return !a.satisfied(previousPrice)
}

func (a *PriceAlert) satisfied(price float64) bool {
	switch a.Direction {
	case AlertAbove:
		return price >= a.ThresholdPerQuintal
	case AlertBelow:
		return price <= a.ThresholdPerQuintal
	default:
		return false
	}
}

// ListQuotesParams filters a quote query.
type ListQuotesParams struct {
	TenantID  string
	Commodity string
	MarketID  string
	From      time.Time
	To        time.Time
	Limit     int
	Offset    int
}

// ListMarketsParams filters a market query.
type ListMarketsParams struct {
	TenantID string
	State    string
	District string
	Kind     MarketKind
	Limit    int
	Offset   int
}

// ListAlertsParams filters an alert query.
type ListAlertsParams struct {
	TenantID  string
	Commodity string
	Limit     int
	Offset    int
}
