// Package domain holds finance-service's entities and the actuarial arithmetic.
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
	ErrMissingField  = errors.New("finance: field is required")
	ErrMissingFarm   = errors.New("finance: farm is required")
	ErrMissingCrop   = errors.New("finance: crop is required")
	ErrInvalidArea   = errors.New("finance: area must be positive")
	ErrInvalidYear   = errors.New("finance: year is outside the range this service covers")
	ErrNoSumInsured  = errors.New("finance: a sum insured per hectare is required")
	ErrClaimNotDraft = errors.New("finance: only a draft claim can be changed")
)

// Season is the Indian cropping calendar.
type Season string

const (
	Kharif Season = "KHARIF"
	Rabi   Season = "RABI"
	Zaid   Season = "ZAID"
)

// CropCategory decides the farmer's premium share.
type CropCategory string

const (
	CategoryFoodGrain    CropCategory = "FOOD_GRAIN"
	CategoryOilseed      CropCategory = "OILSEED"
	CategoryCommercial   CropCategory = "COMMERCIAL"
	CategoryHorticulture CropCategory = "HORTICULTURE"
)

// QuoteConfidence is how much the yield history behind a quote supports it.
type QuoteConfidence string

const (
	ConfidenceFieldHistory  QuoteConfidence = "FIELD_HISTORY"
	ConfidenceShortHistory  QuoteConfidence = "SHORT_HISTORY"
	ConfidenceBenchmarkOnly QuoteConfidence = "BENCHMARK_ONLY"
)

// YieldSeason is one harvested season, as the risk model reads it.
type YieldSeason struct {
	Year        int
	Season      Season
	Crop        string
	YieldKgHa   float64
	AreaHa      float64
	ProfitPerHa float64
}

// ─────────────────────────────────────────────────────────────────────────────
// PMFBY parameters
// ─────────────────────────────────────────────────────────────────────────────

// Farmer premium caps under PMFBY, as a fraction of the sum insured.
//
// These are the scheme's numbers, not this service's judgement. The government
// pays whatever the actuarial premium exceeds them by, which is why the
// category is most of the price the farmer sees.
const (
	farmerCapKharif     = 0.02
	farmerCapRabi       = 0.015
	farmerCapCommercial = 0.05
)

// thresholdWindowYears and thresholdBestOf define the threshold yield.
//
// The average of the best five of the last seven seasons, which is the PMFBY
// formula. Best-of rather than plain average on purpose: including the
// disasters in the baseline would lower the threshold every time the field had
// a bad year, so a run of droughts would quietly reduce the cover that the
// next drought pays out on.
const (
	thresholdWindowYears = 7
	thresholdBestOf      = 5
)

// Indemnity levels the scheme writes cover at.
const (
	minIndemnityLevel     = 0.70
	defaultIndemnityLevel = 0.80
	maxIndemnityLevel     = 0.90
)

// minHistoryForFieldRate is the shortest history worth pricing a field from.
//
// Five seasons. Crop yield volatility is what the premium is made of, and
// estimating a standard deviation from three numbers gives an answer whose own
// error is larger than the thing it measures. Below this the quote is priced
// off a crop benchmark and says so.
const minHistoryForFieldRate = 5

// minHistoryForAnyRate is the point below which a field rate is not attempted.
const minHistoryForAnyRate = 3

// Loadings applied on top of the pure burn cost.
const (
	// expenseLoading covers administration, reinsurance and the insurer's
	// capital. A pure burn rate with no loading is not a premium anybody
	// could actually sell.
	expenseLoading = 0.20

	// uncertaintyLoadingFactor scales the standard error of the burn estimate
	// into an explicit loading line.
	//
	// This is the honest part of the price: a short history means a less
	// certain burn rate, and the person quoting has to charge for that
	// uncertainty or eat it. Charging for it visibly — as its own line that
	// shrinks as the record lengthens — is better than hiding it in a fatter
	// base rate, because it tells the farmer that keeping records makes their
	// cover cheaper, which is true.
	uncertaintyLoadingFactor = 1.0

	// minActuarialRate is a floor. A field that never had a bad year in its
	// recorded history still carries catastrophe risk that the record has not
	// yet seen, and a zero premium would be a promise nobody can fund.
	minActuarialRate = 0.02

	// maxActuarialRate caps the rate. Above this the answer is that the crop
	// is uninsurable on these terms, not that the premium is 60%.
	maxActuarialRate = 0.35
)

// benchmarkRates are the fallback actuarial rates by crop category.
//
// Used only when there is no usable field history, and the quote says so.
// These are indicative scheme-level rates, not a measurement of this field.
var benchmarkRates = map[CropCategory]float64{
	CategoryFoodGrain:    0.09,
	CategoryOilseed:      0.11,
	CategoryCommercial:   0.14,
	CategoryHorticulture: 0.16,
}

// defaultSumInsuredPerHa is the scale-of-finance fallback, in rupees.
var defaultSumInsuredPerHa = map[CropCategory]float64{
	CategoryFoodGrain:    45000,
	CategoryOilseed:      50000,
	CategoryCommercial:   80000,
	CategoryHorticulture: 120000,
}

// quoteValidDays is how long a quote holds.
//
// 30 days. Long enough to take to a bank, short enough that a quote priced
// before the monsoon is not still being honoured after it failed.
const quoteValidDays = 30

// ─────────────────────────────────────────────────────────────────────────────
// Quote
// ─────────────────────────────────────────────────────────────────────────────

// PremiumLine is one component of the actuarial premium.
type PremiumLine struct {
	Label  string  `json:"label"`
	Rate   float64 `json:"rate"`
	Amount float64 `json:"amount"`
	Basis  string  `json:"basis"`
}

// InsuranceQuote prices one season's cover for one field.
type InsuranceQuote struct {
	ID       string `json:"id" db:"id"`
	TenantID string `json:"tenant_id" db:"tenant_id"`
	FieldID  string `json:"field_id" db:"field_id"`
	FarmID   string `json:"farm_id" db:"farm_id"`

	Crop     string       `json:"crop" db:"crop"`
	Category CropCategory `json:"category" db:"category"`
	Season   Season       `json:"season" db:"season"`
	Year     int          `json:"year" db:"year"`

	AreaHectares         float64 `json:"area_hectares" db:"area_hectares"`
	SumInsuredPerHectare float64 `json:"sum_insured_per_hectare" db:"sum_insured_per_hectare"`
	TotalSumInsured      float64 `json:"total_sum_insured" db:"total_sum_insured"`

	IndemnityLevel     float64 `json:"indemnity_level" db:"indemnity_level"`
	ThresholdYieldKgHa float64 `json:"threshold_yield_kg_ha" db:"threshold_yield_kg_ha"`

	Lines            []PremiumLine `json:"lines" db:"lines"`
	ActuarialPremium float64       `json:"actuarial_premium" db:"actuarial_premium"`
	ActuarialRate    float64       `json:"actuarial_rate" db:"actuarial_rate"`
	FarmerPremium    float64       `json:"farmer_premium" db:"farmer_premium"`
	Subsidy          float64       `json:"subsidy" db:"subsidy"`

	Confidence     QuoteConfidence `json:"confidence" db:"confidence"`
	HistorySeasons int             `json:"history_seasons" db:"history_seasons"`
	Basis          string          `json:"basis" db:"basis"`

	QuotedAt  time.Time `json:"quoted_at" db:"quoted_at"`
	ExpiresAt time.Time `json:"expires_at" db:"expires_at"`
}

// QuoteParams is what a quote is priced from beyond the yield history.
type QuoteParams struct {
	FieldID              string
	FarmID               string
	Crop                 string
	Category             CropCategory
	Season               Season
	Year                 int
	AreaHectares         float64
	SumInsuredPerHectare float64
	IndemnityLevel       float64
}

// PriceQuote works out what a season's cover costs.
//
// The rate comes from a burn-cost analysis of the field's own yield history:
// for each recorded season, what the policy would have paid out that year
// against the threshold, averaged across the record. That is the pure risk
// cost, and everything on top of it is a named line — expenses, and an
// uncertainty loading that shrinks as the history lengthens.
//
// Where there is too little history the rate is a crop benchmark and the quote
// says so in its confidence and its basis. A benchmark presented as a
// measurement is the failure mode here: it looks identical to a priced risk,
// and the farmer has no way to tell that nobody looked at their field.
func PriceQuote(params QuoteParams, history []YieldSeason, now time.Time) (InsuranceQuote, error) {
	if strings.TrimSpace(params.FieldID) == "" {
		return InsuranceQuote{}, ErrMissingField
	}
	if strings.TrimSpace(params.Crop) == "" {
		return InsuranceQuote{}, ErrMissingCrop
	}
	if params.AreaHectares <= 0 {
		return InsuranceQuote{}, ErrInvalidArea
	}

	category := params.Category
	if category == "" {
		category = CategoryFoodGrain
	}

	sumInsured := params.SumInsuredPerHectare
	if sumInsured <= 0 {
		sumInsured = defaultSumInsuredPerHa[category]
	}
	if sumInsured <= 0 {
		return InsuranceQuote{}, ErrNoSumInsured
	}

	indemnity := params.IndemnityLevel
	if indemnity <= 0 {
		indemnity = defaultIndemnityLevel
	}
	indemnity = clamp(indemnity, minIndemnityLevel, maxIndemnityLevel)

	relevant := relevantHistory(history, params.Crop, params.Year)

	quote := InsuranceQuote{
		FieldID:              params.FieldID,
		FarmID:               params.FarmID,
		Crop:                 params.Crop,
		Category:             category,
		Season:               params.Season,
		Year:                 params.Year,
		AreaHectares:         params.AreaHectares,
		SumInsuredPerHectare: sumInsured,
		TotalSumInsured:      sumInsured * params.AreaHectares,
		IndemnityLevel:       indemnity,
		HistorySeasons:       len(relevant),
		QuotedAt:             now,
		ExpiresAt:            now.AddDate(0, 0, quoteValidDays),
	}

	threshold, hasThreshold := ThresholdYield(relevant, indemnity)
	quote.ThresholdYieldKgHa = threshold

	burnRate, standardError, priced := burnCost(relevant, threshold)

	switch {
	case !hasThreshold || !priced:
		quote.Confidence = ConfidenceBenchmarkOnly
		burnRate = benchmarkRates[category]
		standardError = 0
		quote.Basis = fmt.Sprintf(
			"This field has %d recorded season%s of %s, which is not enough to price "+
				"its own risk. The rate below is the %s benchmark — it is not a "+
				"measurement of this field, and a season or two of recorded harvests "+
				"would replace it with one.",
			len(relevant), plural(len(relevant)), params.Crop, categoryLabel(category))

	case len(relevant) < minHistoryForFieldRate:
		quote.Confidence = ConfidenceShortHistory
		quote.Basis = fmt.Sprintf(
			"Priced from %d recorded seasons, which is short. The uncertainty loading "+
				"below is what that costs; it shrinks as the record lengthens.",
			len(relevant))

	default:
		quote.Confidence = ConfidenceFieldHistory
		quote.Basis = fmt.Sprintf(
			"Priced from %d recorded seasons of this field, against a threshold yield "+
				"of %.0f kg/ha at %.0f%% indemnity.",
			len(relevant), threshold, indemnity*100)
	}

	// The lines are built so the arithmetic can be followed end to end: a
	// premium a farmer cannot take apart is one they cannot argue with.
	quote.Lines = append(quote.Lines, PremiumLine{
		Label:  "Expected loss",
		Rate:   burnRate,
		Amount: burnRate * quote.TotalSumInsured,
		Basis:  burnBasis(quote.Confidence, len(relevant)),
	})

	uncertainty := uncertaintyLoadingFactor * standardError
	if uncertainty > 0 {
		quote.Lines = append(quote.Lines, PremiumLine{
			Label:  "Uncertainty loading",
			Rate:   uncertainty,
			Amount: uncertainty * quote.TotalSumInsured,
			Basis: fmt.Sprintf(
				"the standard error of an expected loss estimated from %d seasons. "+
					"Each further recorded harvest reduces it.", len(relevant)),
		})
	}

	expense := (burnRate + uncertainty) * expenseLoading
	quote.Lines = append(quote.Lines, PremiumLine{
		Label:  "Expenses and capital",
		Rate:   expense,
		Amount: expense * quote.TotalSumInsured,
		Basis:  fmt.Sprintf("%.0f%% of the risk cost", expenseLoading*100),
	})

	rate := burnRate + uncertainty + expense

	// Floored, because a field with no recorded bad year still carries the
	// catastrophe risk its short record has not yet seen; capped, because
	// above the ceiling the honest answer is that the crop is not insurable on
	// these terms rather than that the premium is 60% of the cover.
	if rate < minActuarialRate {
		quote.Lines = append(quote.Lines, PremiumLine{
			Label:  "Minimum rate adjustment",
			Rate:   minActuarialRate - rate,
			Amount: (minActuarialRate - rate) * quote.TotalSumInsured,
			Basis: "no bad season appears in this field's record, but the cover still " +
				"carries catastrophe risk the record has not yet seen",
		})
		rate = minActuarialRate
	}
	if rate > maxActuarialRate {
		quote.Lines = append(quote.Lines, PremiumLine{
			Label:  "Capped at the maximum rate",
			Rate:   maxActuarialRate - rate,
			Amount: (maxActuarialRate - rate) * quote.TotalSumInsured,
			Basis: fmt.Sprintf(
				"the priced rate came to %.1f%%, above the %.0f%% ceiling. Treat this "+
					"as a sign that the crop is marginal on this field rather than as a price.",
				rate*100, maxActuarialRate*100),
		})
		rate = maxActuarialRate
	}

	quote.ActuarialRate = rate
	quote.ActuarialPremium = rate * quote.TotalSumInsured

	cap := farmerCap(category, params.Season)
	quote.FarmerPremium = math.Min(quote.ActuarialPremium, cap*quote.TotalSumInsured)
	quote.Subsidy = quote.ActuarialPremium - quote.FarmerPremium

	return quote, nil
}

// farmerCap is the share of the sum insured the farmer pays under PMFBY.
func farmerCap(category CropCategory, season Season) float64 {
	if category == CategoryCommercial || category == CategoryHorticulture {
		return farmerCapCommercial
	}
	if season == Rabi {
		return farmerCapRabi
	}
	// Kharif, and anything whose season was not stated. The kharif cap is the
	// higher of the two food-crop caps, so an unstated season never quotes a
	// farmer a lower premium than the scheme actually allows.
	return farmerCapKharif
}

// relevantHistory narrows a yield record to the crop and the window.
//
// Matched on crop, because a field's wheat yields say nothing about the risk
// of its cotton. A history filtered to nothing is not an error — it means this
// crop is new to this field, which is exactly when a benchmark rate is the
// honest answer.
func relevantHistory(history []YieldSeason, crop string, year int) []YieldSeason {
	lower := strings.ToLower(strings.TrimSpace(crop))
	cutoff := year - thresholdWindowYears

	out := make([]YieldSeason, 0, len(history))
	for _, season := range history {
		if season.YieldKgHa <= 0 {
			continue
		}
		if year > 0 && (season.Year < cutoff || season.Year >= year) {
			continue
		}
		if lower != "" && !strings.EqualFold(strings.TrimSpace(season.Crop), lower) {
			continue
		}
		out = append(out, season)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Year < out[j].Year })
	return out
}

// ThresholdYield is the yield below which the policy pays out.
//
// The average of the best five of the last seven seasons, scaled by the
// indemnity level. Best-of rather than a plain average matters: a plain
// average would fall every time the field had a bad year, so a run of droughts
// would quietly shrink the cover that the next drought pays out on.
func ThresholdYield(history []YieldSeason, indemnityLevel float64) (float64, bool) {
	if len(history) < minHistoryForAnyRate {
		return 0, false
	}

	yields := make([]float64, 0, len(history))
	for _, season := range history {
		yields = append(yields, season.YieldKgHa)
	}
	sort.Sort(sort.Reverse(sort.Float64Slice(yields)))

	take := thresholdBestOf
	if len(yields) < take {
		take = len(yields)
	}

	sum := 0.0
	for _, y := range yields[:take] {
		sum += y
	}
	return (sum / float64(take)) * indemnityLevel, true
}

// burnCost is the expected loss as a fraction of the sum insured.
//
// For each recorded season, what the policy would have paid that year:
// (threshold - actual) / threshold, floored at zero. Averaged, that is the
// pure risk cost. The standard error of that mean comes back with it, which is
// what the uncertainty loading is built from — a three-season estimate and a
// ten-season estimate are not the same number even when they are equal.
func burnCost(history []YieldSeason, threshold float64) (rate, standardError float64, ok bool) {
	if len(history) < minHistoryForAnyRate || threshold <= 0 {
		return 0, 0, false
	}

	losses := make([]float64, 0, len(history))
	for _, season := range history {
		shortfall := (threshold - season.YieldKgHa) / threshold
		if shortfall < 0 {
			shortfall = 0
		}
		if shortfall > 1 {
			shortfall = 1
		}
		losses = append(losses, shortfall)
	}

	mean := 0.0
	for _, loss := range losses {
		mean += loss
	}
	mean /= float64(len(losses))

	// Sample variance with the n-1 correction. With five observations the
	// difference from dividing by n is 25%, and it is 25% in the direction of
	// understating the uncertainty — which is the direction that undercharges.
	variance := 0.0
	for _, loss := range losses {
		variance += (loss - mean) * (loss - mean)
	}
	if len(losses) > 1 {
		variance /= float64(len(losses) - 1)
	}

	return mean, math.Sqrt(variance / float64(len(losses))), true
}

func burnBasis(confidence QuoteConfidence, seasons int) string {
	if confidence == ConfidenceBenchmarkOnly {
		return "a crop-level benchmark, because this field has no usable yield history"
	}
	return fmt.Sprintf(
		"the average payout this policy would have made over the field's %d recorded seasons",
		seasons)
}

func categoryLabel(c CropCategory) string {
	switch c {
	case CategoryFoodGrain:
		return "food grain"
	case CategoryOilseed:
		return "oilseed"
	case CategoryCommercial:
		return "commercial crop"
	case CategoryHorticulture:
		return "horticulture"
	default:
		return strings.ToLower(strings.ReplaceAll(string(c), "_", " "))
	}
}

func clamp(v, lo, hi float64) float64 {
	return math.Max(lo, math.Min(hi, v))
}

func plural(n int) string {
	if n == 1 {
		return ""
	}
	return "s"
}

// ListQuotesParams filters a quote query.
type ListQuotesParams struct {
	TenantID string
	FieldID  string
	FarmID   string
	Year     int
	Limit    int
	Offset   int
}
