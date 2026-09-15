package domain

import (
	"math"
	"strings"
	"testing"
	"time"
)

var quoteNow = time.Date(2026, time.May, 20, 0, 0, 0, 0, time.UTC)

func closeTo(got, want, tolerance float64) bool {
	return math.Abs(got-want) <= tolerance
}

// steadyHistory is a field that yields the same every year.
func steadyHistory(seasons int, yieldKgHa float64) []YieldSeason {
	out := make([]YieldSeason, 0, seasons)
	for i := 0; i < seasons; i++ {
		out = append(out, YieldSeason{
			Year: 2026 - seasons + i, Crop: "wheat",
			YieldKgHa: yieldKgHa, AreaHa: 2, ProfitPerHa: 20000,
		})
	}
	return out
}

func historyOf(yields ...float64) []YieldSeason {
	out := make([]YieldSeason, 0, len(yields))
	for i, y := range yields {
		out = append(out, YieldSeason{
			Year: 2026 - len(yields) + i, Crop: "wheat",
			YieldKgHa: y, AreaHa: 2, ProfitPerHa: 20000,
		})
	}
	return out
}

func baseParams() QuoteParams {
	return QuoteParams{
		FieldID: "field-1", FarmID: "farm-1", Crop: "wheat",
		Category: CategoryFoodGrain, Season: Kharif, Year: 2026,
		AreaHectares: 2, SumInsuredPerHectare: 50000,
	}
}

func lineNamed(t *testing.T, quote InsuranceQuote, label string) (PremiumLine, bool) {
	t.Helper()
	for _, line := range quote.Lines {
		if strings.EqualFold(line.Label, label) {
			return line, true
		}
	}
	return PremiumLine{}, false
}

// The threshold is the average of the best five of the last seven seasons. A
// plain average would fall every time the field had a bad year, quietly
// shrinking the cover that the next bad year pays out on.
func TestThresholdUsesTheBestFiveSeasons(t *testing.T) {
	// Five good years and two disasters. The best five are the good ones.
	history := historyOf(4000, 4000, 4000, 4000, 4000, 500, 600)

	threshold, ok := ThresholdYield(history, 0.80)
	if !ok {
		t.Fatal("a seven-season history should produce a threshold")
	}
	if !closeTo(threshold, 3200, 1) {
		t.Errorf("threshold = %.0f, want 3200 — the best five average 4000, times 80%%",
			threshold)
	}

	// The same field with a plain average of all seven would be much lower,
	// which is the behaviour this formula exists to avoid.
	plain := (4000*5 + 500 + 600) / 7.0 * 0.80
	if closeTo(threshold, plain, 1) {
		t.Errorf("threshold matches a plain seven-year average (%.0f); the disasters "+
			"are being folded into the baseline they are meant to be measured against",
			plain)
	}
}

func TestThresholdNeedsAMinimumHistory(t *testing.T) {
	if _, ok := ThresholdYield(historyOf(4000, 3800), 0.80); ok {
		t.Fatal("two seasons should not produce a threshold yield")
	}
}

// A benchmark presented as a measurement is the failure mode here: it looks
// identical to a priced risk and the farmer cannot tell nobody looked.
func TestNoHistoryIsPricedFromABenchmarkAndSaysSo(t *testing.T) {
	quote, err := PriceQuote(baseParams(), nil, quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}

	if quote.Confidence != ConfidenceBenchmarkOnly {
		t.Errorf("confidence = %s, want BENCHMARK_ONLY", quote.Confidence)
	}
	if !strings.Contains(quote.Basis, "not a measurement of this field") {
		t.Errorf("basis = %q; it does not say the rate is not this field's risk", quote.Basis)
	}
	if quote.HistorySeasons != 0 {
		t.Errorf("history seasons = %d, want 0", quote.HistorySeasons)
	}
	if quote.ActuarialPremium <= 0 {
		t.Error("a benchmark quote still has to have a price")
	}
}

func TestAFullHistoryIsPricedFromTheField(t *testing.T) {
	quote, err := PriceQuote(baseParams(), steadyHistory(6, 4000), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}
	if quote.Confidence != ConfidenceFieldHistory {
		t.Errorf("confidence = %s, want FIELD_HISTORY with six seasons", quote.Confidence)
	}
	if quote.HistorySeasons != 6 {
		t.Errorf("history seasons = %d, want 6", quote.HistorySeasons)
	}
}

// A volatile field costs more than a steady one at the same mean. That is the
// whole point of pricing from a burn cost rather than from an average yield.
func TestAVolatileFieldIsPricedHigherThanASteadyOne(t *testing.T) {
	steady, err := PriceQuote(baseParams(), steadyHistory(6, 3000), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote steady: %v", err)
	}
	// The same mean of 3000, alternating between a good year and a failure.
	volatile, err := PriceQuote(baseParams(),
		historyOf(5000, 1000, 5000, 1000, 5000, 1000), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote volatile: %v", err)
	}

	if volatile.ActuarialRate <= steady.ActuarialRate {
		t.Errorf("volatile rate %.3f is not above the steady field's %.3f at the same "+
			"mean yield; the premium is not reflecting the risk",
			volatile.ActuarialRate, steady.ActuarialRate)
	}
}

// The uncertainty loading is the honest part of the price, and it has to
// shrink as the record lengthens or it is just a fatter base rate.
func TestTheUncertaintyLoadingShrinksWithMoreHistory(t *testing.T) {
	pattern := []float64{4000, 1500, 3800, 4200, 1800, 4000, 3900, 4100, 1600, 4000}

	short, err := PriceQuote(baseParams(), historyOf(pattern[:4]...), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote short: %v", err)
	}
	long, err := PriceQuote(baseParams(), historyOf(pattern...), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote long: %v", err)
	}

	shortLine, ok := lineNamed(t, short, "Uncertainty loading")
	if !ok {
		t.Fatal("a four-season quote has no uncertainty loading line")
	}
	longLine, ok := lineNamed(t, long, "Uncertainty loading")
	if !ok {
		t.Fatal("a ten-season quote has no uncertainty loading line")
	}

	if longLine.Rate >= shortLine.Rate {
		t.Errorf("uncertainty loading is %.4f on ten seasons and %.4f on four; it "+
			"should fall as the record lengthens", longLine.Rate, shortLine.Rate)
	}
	if !strings.Contains(shortLine.Basis, "reduces it") {
		t.Errorf("the loading does not tell the farmer that more records make cover "+
			"cheaper: %q", shortLine.Basis)
	}
}

func TestShortHistoryIsFlaggedAsShort(t *testing.T) {
	quote, err := PriceQuote(baseParams(), steadyHistory(4, 4000), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}
	if quote.Confidence != ConfidenceShortHistory {
		t.Errorf("confidence = %s, want SHORT_HISTORY with four seasons", quote.Confidence)
	}
}

// A field with no bad year on record still carries catastrophe risk the record
// has not seen. A zero premium would be a promise nobody can fund.
func TestAPerfectRecordStillPaysTheMinimumRate(t *testing.T) {
	quote, err := PriceQuote(baseParams(), steadyHistory(7, 4000), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}

	if quote.ActuarialRate < minActuarialRate {
		t.Errorf("rate = %.4f, below the %.2f floor", quote.ActuarialRate, minActuarialRate)
	}
	if _, ok := lineNamed(t, quote, "Minimum rate adjustment"); !ok {
		t.Error("the floor was applied without a line saying so; the arithmetic no " +
			"longer adds up for anyone reading it")
	}
}

// Above the ceiling the honest answer is that the crop is marginal here, not
// that the premium is 60% of the cover.
func TestARuinousRecordIsCappedAndSaysWhy(t *testing.T) {
	// A field that fails most years.
	quote, err := PriceQuote(baseParams(),
		historyOf(4000, 200, 300, 150, 400, 250, 200), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}

	if quote.ActuarialRate > maxActuarialRate+1e-9 {
		t.Errorf("rate = %.3f, above the %.2f ceiling", quote.ActuarialRate, maxActuarialRate)
	}
	line, ok := lineNamed(t, quote, "Capped at the maximum rate")
	if !ok {
		t.Fatal("the cap was applied silently")
	}
	if !strings.Contains(line.Basis, "marginal") {
		t.Errorf("the cap does not say what it means: %q", line.Basis)
	}
}

// The premium lines have to add up to the rate, or nobody can check the price.
func TestThePremiumLinesAddUpToTheRate(t *testing.T) {
	for name, history := range map[string][]YieldSeason{
		"steady":    steadyHistory(7, 4000),
		"volatile":  historyOf(5000, 1000, 5000, 1200, 4800, 900, 5100),
		"benchmark": nil,
	} {
		quote, err := PriceQuote(baseParams(), history, quoteNow)
		if err != nil {
			t.Fatalf("%s: PriceQuote: %v", name, err)
		}

		sum := 0.0
		for _, line := range quote.Lines {
			sum += line.Rate
		}
		if !closeTo(sum, quote.ActuarialRate, 1e-9) {
			t.Errorf("%s: the lines sum to %.6f but the rate is %.6f",
				name, sum, quote.ActuarialRate)
		}
		if !closeTo(quote.ActuarialPremium, quote.ActuarialRate*quote.TotalSumInsured, 0.01) {
			t.Errorf("%s: premium %.2f is not rate x sum insured", name, quote.ActuarialPremium)
		}
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// PMFBY caps
// ─────────────────────────────────────────────────────────────────────────────

func TestTheFarmerPaysNoMoreThanTheSchemeCap(t *testing.T) {
	cases := []struct {
		name     string
		category CropCategory
		season   Season
		cap      float64
	}{
		{"kharif food grain", CategoryFoodGrain, Kharif, 0.02},
		{"rabi food grain", CategoryFoodGrain, Rabi, 0.015},
		{"commercial", CategoryCommercial, Kharif, 0.05},
		{"horticulture", CategoryHorticulture, Rabi, 0.05},
	}

	for _, tc := range cases {
		params := baseParams()
		params.Category = tc.category
		params.Season = tc.season

		// A ruinous history, so the actuarial premium is well above every cap.
		quote, err := PriceQuote(params, historyOf(4000, 200, 300, 150, 400, 250, 200), quoteNow)
		if err != nil {
			t.Fatalf("%s: PriceQuote: %v", tc.name, err)
		}

		want := tc.cap * quote.TotalSumInsured
		if !closeTo(quote.FarmerPremium, want, 0.01) {
			t.Errorf("%s: farmer pays %.0f, want the capped %.0f",
				tc.name, quote.FarmerPremium, want)
		}
		if !closeTo(quote.Subsidy, quote.ActuarialPremium-quote.FarmerPremium, 0.01) {
			t.Errorf("%s: subsidy does not make up the difference", tc.name)
		}
	}
}

// A cheap risk costs the farmer the actual premium, not the cap.
func TestTheFarmerPaysTheActualPremiumWhenItIsBelowTheCap(t *testing.T) {
	quote, err := PriceQuote(baseParams(), steadyHistory(7, 4000), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}
	// The floor rate is 2% and the kharif cap is 2%, so they meet. Use rabi,
	// where the cap is 1.5% and the floored rate is above it.
	params := baseParams()
	params.Season = Rabi
	rabi, _ := PriceQuote(params, steadyHistory(7, 4000), quoteNow)

	if rabi.FarmerPremium > quote.FarmerPremium {
		t.Errorf("the rabi cap (1.5%%) charged more than the kharif one (2%%): %.0f vs %.0f",
			rabi.FarmerPremium, quote.FarmerPremium)
	}
}

// An unstated season must not quote a farmer below what the scheme allows.
func TestAnUnstatedSeasonUsesTheHigherFoodCropCap(t *testing.T) {
	params := baseParams()
	params.Season = ""

	quote, err := PriceQuote(params, historyOf(4000, 200, 300, 150, 400, 250, 200), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}
	if !closeTo(quote.FarmerPremium, farmerCapKharif*quote.TotalSumInsured, 0.01) {
		t.Errorf("farmer premium = %.0f; an unstated season should not be quoted below "+
			"the kharif cap", quote.FarmerPremium)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// History selection
// ─────────────────────────────────────────────────────────────────────────────

// A field's wheat yields say nothing about the risk of its cotton.
func TestHistoryIsFilteredToTheCropBeingInsured(t *testing.T) {
	mixed := append(steadyHistory(6, 4000), YieldSeason{
		Year: 2024, Crop: "cotton", YieldKgHa: 600, AreaHa: 2,
	})

	params := baseParams()
	params.Crop = "cotton"

	quote, err := PriceQuote(params, mixed, quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}
	if quote.HistorySeasons != 1 {
		t.Errorf("history seasons = %d, want 1 — the wheat record is not cotton risk",
			quote.HistorySeasons)
	}
	if quote.Confidence != ConfidenceBenchmarkOnly {
		t.Errorf("confidence = %s; one cotton season is not enough to price cotton",
			quote.Confidence)
	}
}

// A quote for 2026 must not be priced using 2026's own harvest, which has not
// happened yet.
func TestHistoryExcludesTheYearBeingQuoted(t *testing.T) {
	history := append(steadyHistory(6, 4000), YieldSeason{
		Year: 2026, Crop: "wheat", YieldKgHa: 100, AreaHa: 2,
	})

	quote, err := PriceQuote(baseParams(), history, quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}
	if quote.HistorySeasons != 6 {
		t.Errorf("history seasons = %d, want 6 — the quoted year's own harvest is in "+
			"the risk estimate", quote.HistorySeasons)
	}
}

func TestQuoteRequiresAFieldCropAndArea(t *testing.T) {
	for name, mutate := range map[string]func(*QuoteParams){
		"no field": func(p *QuoteParams) { p.FieldID = "" },
		"no crop":  func(p *QuoteParams) { p.Crop = "" },
		"no area":  func(p *QuoteParams) { p.AreaHectares = 0 },
	} {
		params := baseParams()
		mutate(&params)
		if _, err := PriceQuote(params, steadyHistory(6, 4000), quoteNow); err == nil {
			t.Errorf("%s was accepted", name)
		}
	}
}

func TestQuoteFallsBackToTheScaleOfFinanceSumInsured(t *testing.T) {
	params := baseParams()
	params.SumInsuredPerHectare = 0

	quote, err := PriceQuote(params, steadyHistory(6, 4000), quoteNow)
	if err != nil {
		t.Fatalf("PriceQuote: %v", err)
	}
	if quote.SumInsuredPerHectare != defaultSumInsuredPerHa[CategoryFoodGrain] {
		t.Errorf("sum insured = %.0f, want the food-grain default",
			quote.SumInsuredPerHectare)
	}
}

func TestIndemnityLevelIsClamped(t *testing.T) {
	params := baseParams()
	params.IndemnityLevel = 0.99

	quote, _ := PriceQuote(params, steadyHistory(6, 4000), quoteNow)
	if quote.IndemnityLevel != maxIndemnityLevel {
		t.Errorf("indemnity = %.2f, want it clamped to %.2f",
			quote.IndemnityLevel, maxIndemnityLevel)
	}
}

func TestQuoteExpires(t *testing.T) {
	quote, _ := PriceQuote(baseParams(), steadyHistory(6, 4000), quoteNow)
	if !quote.ExpiresAt.After(quote.QuotedAt) {
		t.Error("the quote has no expiry; a price set before the monsoon must not " +
			"still be honoured after it failed")
	}
}
