package domain

import (
	"math"
	"strings"
	"testing"
	"time"
)

var refNow = time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)

// ─────────────────────────────────────────────────────────────────────────────
// Unit conversion
// ─────────────────────────────────────────────────────────────────────────────

func TestToPerQuintal(t *testing.T) {
	// The conversion that stops ₹50/kg reading as a hundredth of
	// ₹5,000/quintal. They are the same price.
	cases := []struct {
		unit  PriceUnit
		price float64
		want  float64
	}{
		{UnitPerKg, 50, 5000},
		{UnitPerQuintal, 5000, 5000},
		{UnitPerTonne, 50000, 5000},
	}
	for _, tc := range cases {
		got, err := tc.unit.ToPerQuintal(tc.price)
		if err != nil {
			t.Fatalf("%s: %v", tc.unit, err)
		}
		if math.Abs(got-tc.want) > 1e-9 {
			t.Errorf("%s %.2f -> %.2f, want %.2f", tc.unit, tc.price, got, tc.want)
		}
	}
}

func TestToPerQuintal_RefusesAnUnknownUnit(t *testing.T) {
	// A quote with no unit cannot be compared with anything. Defaulting it to
	// per-quintal would silently divide an exchange price by ten.
	if _, err := PriceUnit("").ToPerQuintal(100); err != ErrUnknownUnit {
		t.Fatalf("expected ErrUnknownUnit, got %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Quote validation
// ─────────────────────────────────────────────────────────────────────────────

func goodQuote() PriceQuote {
	return PriceQuote{
		Commodity:  "Cotton",
		MarketID:   "mkt-1",
		MinPrice:   6800,
		MaxPrice:   7400,
		ModalPrice: 7100,
		Unit:       UnitPerQuintal,
		QuotedOn:   refNow.Add(-24 * time.Hour),
	}
}

func TestNormalise_FillsInThePerQuintalPrice(t *testing.T) {
	q := goodQuote()
	q.Unit = UnitPerKg
	q.MinPrice, q.MaxPrice, q.ModalPrice = 68, 74, 71

	if err := q.Normalise(refNow); err != nil {
		t.Fatalf("normalise: %v", err)
	}
	if math.Abs(q.PricePerQuintal-7100) > 1e-9 {
		t.Errorf("price per quintal = %.2f, want 7100", q.PricePerQuintal)
	}
	if q.Currency != "INR" {
		t.Errorf("currency defaulted to %q", q.Currency)
	}
}

func TestNormalise_RefusesAModalPriceOutsideItsOwnRange(t *testing.T) {
	// A parsing error in the feed. Storing it puts a wrong number into every
	// statistic afterwards, where it is far harder to notice than here.
	q := goodQuote()
	q.ModalPrice = 9000

	if err := q.Normalise(refNow); err != ErrModalOutOfRange {
		t.Fatalf("expected ErrModalOutOfRange, got %v", err)
	}
}

func TestNormalise_AcceptsAModalOnlyQuote(t *testing.T) {
	// Many feeds report only a modal price. Zero min and max is normal and
	// must not be read as a range the modal price falls outside.
	q := goodQuote()
	q.MinPrice, q.MaxPrice = 0, 0

	if err := q.Normalise(refNow); err != nil {
		t.Fatalf("a modal-only quote was refused: %v", err)
	}
	if q.PricePerQuintal != 7100 {
		t.Errorf("price per quintal = %.2f", q.PricePerQuintal)
	}
}

func TestNormalise_RefusesAnInvertedRange(t *testing.T) {
	q := goodQuote()
	q.MinPrice, q.MaxPrice = 7400, 6800

	if err := q.Normalise(refNow); err != ErrPriceRangeWrong {
		t.Fatalf("expected ErrPriceRangeWrong, got %v", err)
	}
}

func TestNormalise_RefusesNegativePrices(t *testing.T) {
	q := goodQuote()
	q.ModalPrice = -1

	if err := q.Normalise(refNow); err != ErrNegativePrice {
		t.Fatalf("expected ErrNegativePrice, got %v", err)
	}
}

func TestNormalise_RefusesAQuoteFromTheFuture(t *testing.T) {
	// A timestamp past tomorrow is a timezone bug in the ingester, not
	// tomorrow's price.
	q := goodQuote()
	q.QuotedOn = refNow.Add(48 * time.Hour)

	if err := q.Normalise(refNow); err != ErrFutureQuote {
		t.Fatalf("expected ErrFutureQuote, got %v", err)
	}
}

func TestNormalise_AllowsTodayInAnyTimezone(t *testing.T) {
	// A mandi in IST reports its day before UTC has finished it. Refusing
	// those would drop a whole feed every evening.
	q := goodQuote()
	q.QuotedOn = refNow.Add(10 * time.Hour)

	if err := q.Normalise(refNow); err != nil {
		t.Fatalf("a same-day quote from ahead of UTC was refused: %v", err)
	}
}

func TestNormalise_RefusesAQuoteWithNoCommodityOrMarket(t *testing.T) {
	q := goodQuote()
	q.Commodity = "   "
	if err := q.Normalise(refNow); err != ErrMissingCommodity {
		t.Fatalf("expected ErrMissingCommodity, got %v", err)
	}

	q = goodQuote()
	q.MarketID = ""
	if err := q.Normalise(refNow); err != ErrMissingMarket {
		t.Fatalf("expected ErrMissingMarket, got %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Statistics
// ─────────────────────────────────────────────────────────────────────────────

// series builds daily quotes from a list of per-quintal prices, oldest first.
func series(prices ...float64) []PriceQuote {
	out := make([]PriceQuote, len(prices))
	start := refNow.AddDate(0, 0, -len(prices))
	for i, p := range prices {
		out[i] = PriceQuote{
			Commodity:       "Cotton",
			MarketID:        "mkt-1",
			PricePerQuintal: p,
			QuotedOn:        start.AddDate(0, 0, i),
		}
	}
	return out
}

func TestComputeStatistics_EmptyWindowIsNotZeroes(t *testing.T) {
	// A zeroed struct renders as "the price is ₹0" and reads as data.
	if _, ok := ComputeStatistics("Cotton", "mkt-1", nil); ok {
		t.Fatal("an empty window reported statistics")
	}
}

func TestComputeStatistics_MeanMedianAndRange(t *testing.T) {
	stats, ok := ComputeStatistics("Cotton", "mkt-1", series(100, 200, 300, 400, 500))
	if !ok {
		t.Fatal("statistics were not produced")
	}

	if stats.MeanPerQuintal != 300 {
		t.Errorf("mean = %v, want 300", stats.MeanPerQuintal)
	}
	if stats.MedianPerQuintal != 300 {
		t.Errorf("median = %v, want 300", stats.MedianPerQuintal)
	}
	if stats.MinPerQuintal != 100 || stats.MaxPerQuintal != 500 {
		t.Errorf("range = %v..%v, want 100..500", stats.MinPerQuintal, stats.MaxPerQuintal)
	}
	if stats.LatestPerQuintal != 500 {
		t.Errorf("latest = %v, want 500 (the window is oldest-first)", stats.LatestPerQuintal)
	}
	if stats.ObservationDays != 5 {
		t.Errorf("observation days = %d", stats.ObservationDays)
	}
}

func TestComputeStatistics_MedianOfAnEvenWindow(t *testing.T) {
	stats, _ := ComputeStatistics("Cotton", "mkt-1", series(100, 200, 300, 400))
	if stats.MedianPerQuintal != 250 {
		t.Errorf("median = %v, want 250", stats.MedianPerQuintal)
	}
}

func TestComputeStatistics_MedianIgnoresAnOutlier(t *testing.T) {
	// One mis-parsed quote drags the mean and leaves the median alone, which
	// is why both are reported.
	stats, _ := ComputeStatistics("Cotton", "mkt-1", series(5000, 5100, 5050, 5080, 500000))

	if stats.MeanPerQuintal < 50000 {
		t.Errorf("mean should be dragged by the outlier, got %v", stats.MeanPerQuintal)
	}
	if stats.MedianPerQuintal != 5080 {
		t.Errorf("median = %v, want 5080", stats.MedianPerQuintal)
	}
}

func TestComputeStatistics_ZScoreIsZeroWhenEveryPriceIsIdentical(t *testing.T) {
	// The z-score is undefined at zero variance; reporting 0 is right, because
	// the latest price is exactly at the mean. NaN would poison every
	// comparison downstream.
	stats, _ := ComputeStatistics("Cotton", "mkt-1", series(5000, 5000, 5000))

	if stats.StdDevPerQuintal != 0 {
		t.Errorf("std dev = %v, want 0", stats.StdDevPerQuintal)
	}
	if stats.LatestZScore != 0 || math.IsNaN(stats.LatestZScore) {
		t.Errorf("z = %v, want 0", stats.LatestZScore)
	}
}

func TestComputeStatistics_TrendUsesDatesNotIndices(t *testing.T) {
	// Mandi reporting has gaps — holidays, closures. Regressing against the
	// index treats a five-day gap as one step and turns a slow drift into a
	// jump.
	gappy := []PriceQuote{
		{PricePerQuintal: 5000, QuotedOn: refNow.AddDate(0, 0, -20)},
		{PricePerQuintal: 5100, QuotedOn: refNow.AddDate(0, 0, -10)},
		{PricePerQuintal: 5200, QuotedOn: refNow},
	}
	stats, _ := ComputeStatistics("Cotton", "mkt-1", gappy)

	// 200 rupees over 20 days is 10/day, not 100/day as an index fit would say.
	if math.Abs(stats.TrendPerDay-10) > 0.01 {
		t.Errorf("trend = %.2f/day, want 10", stats.TrendPerDay)
	}
}

func TestComputeStatistics_TrendDirection(t *testing.T) {
	rising, _ := ComputeStatistics("C", "m", series(5000, 5100, 5200, 5300, 5400))
	if rising.Trend != TrendRising {
		t.Errorf("rising series reported %s", rising.Trend)
	}

	falling, _ := ComputeStatistics("C", "m", series(5400, 5300, 5200, 5100, 5000))
	if falling.Trend != TrendFalling {
		t.Errorf("falling series reported %s", falling.Trend)
	}

	// Within a rupee a day: inside the noise of daily mandi reporting, and
	// not a trend anybody should act on.
	flat, _ := ComputeStatistics("C", "m", series(5000, 5001, 5000, 5001, 5002))
	if flat.Trend != TrendFlat {
		t.Errorf("a 0.4/day drift reported %s, want FLAT", flat.Trend)
	}
}

func TestComputeStatistics_SingleQuoteHasNoSlope(t *testing.T) {
	stats, ok := ComputeStatistics("C", "m", series(5000))
	if !ok {
		t.Fatal("a single quote produced no statistics")
	}
	if stats.TrendPerDay != 0 || stats.Trend != TrendFlat {
		t.Errorf("a single quote reported a trend: %v %s", stats.TrendPerDay, stats.Trend)
	}
}

func TestComputeStatistics_AllQuotesOnOneDay(t *testing.T) {
	// Several markets reporting the same day; the slope is undefined and must
	// not divide by zero.
	sameDay := []PriceQuote{
		{PricePerQuintal: 5000, QuotedOn: refNow},
		{PricePerQuintal: 5200, QuotedOn: refNow},
	}
	stats, _ := ComputeStatistics("C", "m", sameDay)

	if math.IsNaN(stats.TrendPerDay) || math.IsInf(stats.TrendPerDay, 0) {
		t.Fatalf("trend = %v", stats.TrendPerDay)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Sell signal
// ─────────────────────────────────────────────────────────────────────────────

func TestGenerateSellSignal_TooLittleHistorySaysSo(t *testing.T) {
	// A recommendation from three points carries the same weight on screen as
	// one from three months. Saying "not enough data" is the honest answer.
	stats, _ := ComputeStatistics("Cotton", "mkt-1", series(5000, 5100, 5200))
	signal := GenerateSellSignal(stats, true, refNow)

	if signal.Recommendation != InsufficientData {
		t.Fatalf("recommendation = %s, want INSUFFICIENT_DATA", signal.Recommendation)
	}
	if signal.Confidence != 0 {
		t.Errorf("confidence = %v, want 0", signal.Confidence)
	}
	if !strings.Contains(signal.Rationale, "3 day") {
		t.Errorf("the rationale does not say how much history there is: %q", signal.Rationale)
	}
}

func TestGenerateSellSignal_NoStatisticsAtAll(t *testing.T) {
	signal := GenerateSellSignal(PriceStatistics{}, false, refNow)
	if signal.Recommendation != InsufficientData {
		t.Fatalf("recommendation = %s", signal.Recommendation)
	}
}

func TestGenerateSellSignal_HighAndOffThePeakIsSellNow(t *testing.T) {
	// The case both slope fits get wrong. Eight flat days, a spike, one tick
	// down: the jump dominates any window long enough to include it, so both
	// the whole-window and the recent fit report "rising" — while the thing a
	// farmer needs to know is that the peak has passed.
	prices := []float64{5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 6200, 6100}
	stats, _ := ComputeStatistics("Cotton", "mkt-1", series(prices...))

	if stats.Trend != TrendRising {
		t.Fatalf("precondition: the window fit should read as rising, got %s", stats.Trend)
	}
	if stats.AtWindowHigh {
		t.Fatal("precondition: the latest price is not the window high")
	}

	signal := GenerateSellSignal(stats, true, refNow)
	if signal.Recommendation != SellNow {
		t.Fatalf("recommendation = %s, want SELL_NOW (z=%.2f trend=%s)",
			signal.Recommendation, stats.LatestZScore, stats.Trend)
	}
	if signal.Confidence <= 0 {
		t.Error("a sell recommendation was given with zero confidence")
	}
	if !strings.Contains(signal.Rationale, "standard deviation") {
		t.Errorf("the rationale does not name the numbers: %q", signal.Rationale)
	}
}

func TestGenerateSellSignal_HighAndStillRisingIsHold(t *testing.T) {
	// Above the mean is not itself a reason to sell: the trend says tomorrow
	// is better.
	stats, _ := ComputeStatistics("Cotton", "mkt-1",
		series(5000, 5100, 5200, 5300, 5400, 5500, 5700, 6000, 6400, 6900))
	signal := GenerateSellSignal(stats, true, refNow)

	if signal.Recommendation != Hold {
		t.Fatalf("recommendation = %s, want HOLD (z=%.2f trend=%s)",
			signal.Recommendation, stats.LatestZScore, stats.Trend)
	}
	if !strings.Contains(signal.Rationale, "not peaked") {
		t.Errorf("the rationale does not explain the hold: %q", signal.Rationale)
	}
}

func TestGenerateSellSignal_BelowTheMeanIsHold(t *testing.T) {
	// Selling into a low is the decision this feature exists to help avoid.
	prices := []float64{6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 4800, 4700}
	stats, _ := ComputeStatistics("Cotton", "mkt-1", series(prices...))
	signal := GenerateSellSignal(stats, true, refNow)

	if signal.Recommendation != Hold {
		t.Fatalf("recommendation = %s, want HOLD (z=%.2f)", signal.Recommendation, stats.LatestZScore)
	}
	if !strings.Contains(signal.Rationale, "below") {
		t.Errorf("the rationale does not explain the hold: %q", signal.Rationale)
	}
}

func TestGenerateSellSignal_AnOrdinaryPriceGivesWeakAdvice(t *testing.T) {
	// The price is unremarkable, so the honest signal is a weak one rather
	// than a confident "hold" that reads as a considered judgement.
	stats, _ := ComputeStatistics("Cotton", "mkt-1",
		series(5000, 5010, 4990, 5005, 4995, 5002, 4998, 5001))
	signal := GenerateSellSignal(stats, true, refNow)

	if signal.Recommendation != Hold {
		t.Fatalf("recommendation = %s", signal.Recommendation)
	}
	if signal.Confidence > 0.35 {
		t.Errorf("confidence = %.2f; an unremarkable price should not be confident advice",
			signal.Confidence)
	}
}

func TestGenerateSellSignal_ConfidenceGrowsWithHistory(t *testing.T) {
	// Ten days and ninety days of the same shape should not be equally
	// trustworthy.
	short := makeSpike(10)
	long := makeSpike(40)

	shortStats, _ := ComputeStatistics("C", "m", short)
	longStats, _ := ComputeStatistics("C", "m", long)

	shortSignal := GenerateSellSignal(shortStats, true, refNow)
	longSignal := GenerateSellSignal(longStats, true, refNow)

	if shortSignal.Recommendation != SellNow || longSignal.Recommendation != SellNow {
		t.Fatalf("expected SELL_NOW from both, got %s and %s",
			shortSignal.Recommendation, longSignal.Recommendation)
	}
	if longSignal.Confidence <= shortSignal.Confidence {
		t.Errorf("confidence did not grow with history: %.3f (short) vs %.3f (long)",
			shortSignal.Confidence, longSignal.Confidence)
	}
}

func TestGenerateSellSignal_ConfidenceStaysInRange(t *testing.T) {
	stats, _ := ComputeStatistics("C", "m", makeSpike(90))
	signal := GenerateSellSignal(stats, true, refNow)

	if signal.Confidence < 0 || signal.Confidence > 1 {
		t.Errorf("confidence = %v, outside 0..1", signal.Confidence)
	}
}

// makeSpike builds n flat days followed by a high, falling pair.
func makeSpike(n int) []PriceQuote {
	prices := make([]float64, 0, n)
	for i := 0; i < n-2; i++ {
		prices = append(prices, 5000)
	}
	prices = append(prices, 6200, 6100)
	return series(prices...)
}

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────

func alert(direction AlertDirection, threshold float64) PriceAlert {
	return PriceAlert{
		Commodity:           "Cotton",
		MarketID:            "mkt-1",
		Direction:           direction,
		ThresholdPerQuintal: threshold,
		Enabled:             true,
	}
}

func TestPriceAlert_Validate(t *testing.T) {
	a := alert(AlertAbove, 6000)
	if err := a.Validate(); err != nil {
		t.Fatalf("a good alert was refused: %v", err)
	}

	bad := alert(AlertAbove, 0)
	if err := bad.Validate(); err != ErrThresholdInvalid {
		t.Errorf("expected ErrThresholdInvalid, got %v", err)
	}

	noDirection := alert("SIDEWAYS", 6000)
	if err := noDirection.Validate(); err == nil {
		t.Error("an alert with no usable direction was accepted")
	}
}

func TestPriceAlert_FiresOnTheFirstQuoteItSees(t *testing.T) {
	// The farmer asked to be told when the price is above ₹6,000 and it is.
	a := alert(AlertAbove, 6000)
	if !a.ShouldFire(6200, 0, false) {
		t.Error("the first satisfying quote did not fire")
	}
}

func TestPriceAlert_FiresOnACrossingNotAState(t *testing.T) {
	// An alert that fires on every quote while the price stays above the
	// threshold sends twenty notifications for one event and teaches a farmer
	// to turn alerts off.
	a := alert(AlertAbove, 6000)

	if !a.ShouldFire(6100, 5900, true) {
		t.Error("the crossing did not fire")
	}
	if a.ShouldFire(6200, 6100, true) {
		t.Error("the alert fired again while the price stayed above the threshold")
	}
}

func TestPriceAlert_FiresAgainAfterComingBack(t *testing.T) {
	a := alert(AlertAbove, 6000)

	if a.ShouldFire(6200, 6100, true) {
		t.Fatal("fired while still above")
	}
	// Dropped below and crossed back up: a new event.
	if !a.ShouldFire(6100, 5800, true) {
		t.Error("a second genuine crossing did not fire")
	}
}

func TestPriceAlert_BelowDirection(t *testing.T) {
	a := alert(AlertBelow, 4500)

	if !a.ShouldFire(4400, 4600, true) {
		t.Error("a downward crossing did not fire")
	}
	if a.ShouldFire(4300, 4400, true) {
		t.Error("the alert fired again while the price stayed below")
	}
	if a.ShouldFire(4600, 4400, true) {
		t.Error("the alert fired on a price above its below-threshold")
	}
}

func TestPriceAlert_FiresAtExactlyTheThreshold(t *testing.T) {
	// "Tell me when it reaches ₹6,000" means at ₹6,000, not above it.
	a := alert(AlertAbove, 6000)
	if !a.ShouldFire(6000, 5900, true) {
		t.Error("the alert did not fire at exactly its threshold")
	}
}

func TestPriceAlert_DisabledNeverFires(t *testing.T) {
	a := alert(AlertAbove, 6000)
	a.Enabled = false

	if a.ShouldFire(9999, 0, false) {
		t.Error("a disabled alert fired")
	}
}
