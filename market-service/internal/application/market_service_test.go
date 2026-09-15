package application

import (
	"context"
	"strings"
	"testing"
	"time"

	"go.uber.org/zap"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/market-service/internal/domain"
)

var testNow = time.Date(2026, 3, 14, 9, 0, 0, 0, time.UTC)

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

type fakeRepo struct {
	quotes []domain.PriceQuote
	window []domain.PriceQuote
	alerts []domain.PriceAlert

	upserted []domain.PriceQuote
	fired    []string
	created  *domain.PriceAlert
}

func (f *fakeRepo) ListMarkets(context.Context, domain.ListMarketsParams) ([]domain.Market, int64, error) {
	return nil, 0, nil
}

func (f *fakeRepo) UpsertMarket(_ context.Context, m *domain.Market) (*domain.Market, error) {
	return m, nil
}

func (f *fakeRepo) UpsertQuotes(_ context.Context, quotes []domain.PriceQuote) (int, error) {
	f.upserted = append(f.upserted, quotes...)
	return len(quotes), nil
}

func (f *fakeRepo) ListQuotes(context.Context, domain.ListQuotesParams) ([]domain.PriceQuote, int64, error) {
	return f.quotes, int64(len(f.quotes)), nil
}

func (f *fakeRepo) QuoteWindow(context.Context, string, string, string, int) ([]domain.PriceQuote, error) {
	return f.window, nil
}

func (f *fakeRepo) CreateAlert(_ context.Context, a *domain.PriceAlert) (*domain.PriceAlert, error) {
	f.created = a
	return a, nil
}

func (f *fakeRepo) ListAlerts(context.Context, domain.ListAlertsParams) ([]domain.PriceAlert, int64, error) {
	return f.alerts, int64(len(f.alerts)), nil
}

func (f *fakeRepo) DeleteAlert(context.Context, string, string) (bool, error) { return true, nil }

func (f *fakeRepo) MatchingAlerts(context.Context, string, string, string) ([]domain.PriceAlert, error) {
	return f.alerts, nil
}

func (f *fakeRepo) MarkAlertFired(_ context.Context, id, _ string, _ float64) error {
	f.fired = append(f.fired, id)
	return nil
}

type fakePublisher struct {
	published int
}

func (f *fakePublisher) Publish(context.Context, string, string, []byte) error {
	f.published++
	return nil
}

func newService(repo *fakeRepo) (*marketService, *fakePublisher) {
	pub := &fakePublisher{}
	svc := NewMarketService(repo, pub, p9log.NewLogger(zap.NewNop())).(*marketService)
	svc.now = func() time.Time { return testNow }
	return svc, pub
}

func tenantCtx(tenantID string) context.Context {
	ctx := context.Background()
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	return ctx
}

func quote(commodity string, modal float64, unit domain.PriceUnit) domain.PriceQuote {
	return domain.PriceQuote{
		Commodity:  commodity,
		MarketID:   "mkt-1",
		ModalPrice: modal,
		Unit:       unit,
		QuotedOn:   testNow.Add(-24 * time.Hour),
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Tenancy
// ─────────────────────────────────────────────────────────────────────────────

func TestEveryOperationRequiresATenant(t *testing.T) {
	// Without a tenant, RLS returns zero rows *successfully* — so an operation
	// that does not check reports an empty market rather than a missing
	// credential, which is the failure mode this platform has had before.
	svc, _ := newService(&fakeRepo{})
	ctx := context.Background()

	if _, err := svc.RecordQuotes(ctx, []domain.PriceQuote{quote("Cotton", 5000, domain.UnitPerQuintal)}); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("RecordQuotes: %v", err)
	}
	if _, _, err := svc.ListQuotes(ctx, domain.ListQuotesParams{}); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("ListQuotes: %v", err)
	}
	if _, _, err := svc.GetPriceStatistics(ctx, "Cotton", "mkt-1", 30); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("GetPriceStatistics: %v", err)
	}
	if _, err := svc.CreatePriceAlert(ctx, &domain.PriceAlert{}); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("CreatePriceAlert: %v", err)
	}
	if _, err := svc.DeletePriceAlert(ctx, "a"); !isBadRequest(err, "MISSING_TENANT") {
		t.Errorf("DeletePriceAlert: %v", err)
	}
}

func isBadRequest(err error, reason string) bool {
	return err != nil && errors.IsBadRequest(err) && errors.Reason(err) == reason
}

// ─────────────────────────────────────────────────────────────────────────────
// Ingest
// ─────────────────────────────────────────────────────────────────────────────

func TestRecordQuotes_NormalisesBeforeStoring(t *testing.T) {
	repo := &fakeRepo{}
	svc, _ := newService(repo)

	_, err := svc.RecordQuotes(tenantCtx("tenant-1"), []domain.PriceQuote{
		quote("Cotton", 50, domain.UnitPerKg),
	})
	if err != nil {
		t.Fatalf("record: %v", err)
	}

	if len(repo.upserted) != 1 {
		t.Fatalf("expected 1 stored quote, got %d", len(repo.upserted))
	}
	if repo.upserted[0].PricePerQuintal != 5000 {
		t.Errorf("stored price per quintal = %v, want 5000", repo.upserted[0].PricePerQuintal)
	}
	if repo.upserted[0].TenantID != "tenant-1" {
		t.Errorf("the quote was stored without its tenant: %q", repo.upserted[0].TenantID)
	}
	if repo.upserted[0].ID == "" {
		t.Error("the quote was stored with no id")
	}
}

func TestRecordQuotes_OneBadQuoteDoesNotSinkTheBatch(t *testing.T) {
	// A mandi feed carrying two hundred commodities regularly has a handful of
	// malformed rows. Refusing the whole import leaves every price stale, which
	// is worse than importing the rest and saying which were dropped.
	repo := &fakeRepo{}
	svc, _ := newService(repo)

	good := quote("Cotton", 5000, domain.UnitPerQuintal)
	bad := quote("Soybean", 4000, domain.UnitPerQuintal)
	bad.MinPrice, bad.MaxPrice = 4500, 4800 // modal outside its own range

	result, err := svc.RecordQuotes(tenantCtx("tenant-1"), []domain.PriceQuote{good, bad})
	if err != nil {
		t.Fatalf("record: %v", err)
	}

	if result.Recorded != 1 {
		t.Errorf("recorded = %d, want 1", result.Recorded)
	}
	if len(result.Rejected) != 1 {
		t.Fatalf("rejected = %v, want 1 entry", result.Rejected)
	}
	// The rejection has to name the quote, or an ingester cannot find it.
	if !strings.Contains(result.Rejected[0], "Soybean") {
		t.Errorf("the rejection does not name the commodity: %q", result.Rejected[0])
	}
	if !strings.Contains(result.Rejected[0], "quotes[1]") {
		t.Errorf("the rejection does not say which row: %q", result.Rejected[0])
	}
}

func TestRecordQuotes_AllBadWritesNothing(t *testing.T) {
	repo := &fakeRepo{}
	svc, _ := newService(repo)

	result, err := svc.RecordQuotes(tenantCtx("tenant-1"), []domain.PriceQuote{
		quote("Cotton", 5000, ""), // no unit
	})
	if err != nil {
		t.Fatalf("record: %v", err)
	}

	if result.Recorded != 0 || len(repo.upserted) != 0 {
		t.Error("an unusable batch was written anyway")
	}
	if len(result.Rejected) != 1 {
		t.Errorf("rejected = %v", result.Rejected)
	}
}

func TestRecordQuotes_RefusesAnEmptyBatch(t *testing.T) {
	svc, _ := newService(&fakeRepo{})

	if _, err := svc.RecordQuotes(tenantCtx("tenant-1"), nil); !isBadRequest(err, "NO_QUOTES") {
		t.Fatalf("expected NO_QUOTES, got %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Alerts firing on ingest
// ─────────────────────────────────────────────────────────────────────────────

func TestRecordQuotes_FiresAMatchingAlert(t *testing.T) {
	repo := &fakeRepo{alerts: []domain.PriceAlert{{
		ID:                  "alert-1",
		TenantID:            "tenant-1",
		Commodity:           "Cotton",
		MarketID:            "mkt-1",
		Direction:           domain.AlertAbove,
		ThresholdPerQuintal: 6000,
		Enabled:             true,
	}}}
	svc, pub := newService(repo)

	_, err := svc.RecordQuotes(tenantCtx("tenant-1"), []domain.PriceQuote{
		quote("Cotton", 6500, domain.UnitPerQuintal),
	})
	if err != nil {
		t.Fatalf("record: %v", err)
	}

	if len(repo.fired) != 1 || repo.fired[0] != "alert-1" {
		t.Errorf("fired = %v, want [alert-1]", repo.fired)
	}
	if pub.published != 1 {
		t.Errorf("published %d events, want 1", pub.published)
	}
}

func TestRecordQuotes_DoesNotFireAnAlertThatIsNotCrossed(t *testing.T) {
	repo := &fakeRepo{alerts: []domain.PriceAlert{{
		ID:                  "alert-1",
		TenantID:            "tenant-1",
		Commodity:           "Cotton",
		MarketID:            "mkt-1",
		Direction:           domain.AlertAbove,
		ThresholdPerQuintal: 8000,
		Enabled:             true,
	}}}
	svc, pub := newService(repo)

	_, _ = svc.RecordQuotes(tenantCtx("tenant-1"), []domain.PriceQuote{
		quote("Cotton", 6500, domain.UnitPerQuintal),
	})

	if len(repo.fired) != 0 || pub.published != 0 {
		t.Error("an alert fired on a price that did not reach its threshold")
	}
}

func TestRecordQuotes_ChecksAlertsAgainstTheLatestQuoteOfABatch(t *testing.T) {
	// A backfill covering a week must be judged on where the price ended up,
	// not on whichever day happened to be last in the array.
	repo := &fakeRepo{alerts: []domain.PriceAlert{{
		ID:                  "alert-1",
		TenantID:            "tenant-1",
		Commodity:           "Cotton",
		MarketID:            "mkt-1",
		Direction:           domain.AlertAbove,
		ThresholdPerQuintal: 6000,
		Enabled:             true,
	}}}
	svc, _ := newService(repo)

	newest := quote("Cotton", 6500, domain.UnitPerQuintal)
	newest.QuotedOn = testNow.Add(-24 * time.Hour)
	older := quote("Cotton", 5000, domain.UnitPerQuintal)
	older.QuotedOn = testNow.Add(-72 * time.Hour)

	// Deliberately out of order, as a backfill arrives.
	_, _ = svc.RecordQuotes(tenantCtx("tenant-1"), []domain.PriceQuote{newest, older})

	if len(repo.fired) != 1 {
		t.Errorf("fired = %v; the newest quote in the batch should decide", repo.fired)
	}
}

func TestRecordQuotes_AnAlertFailureDoesNotLoseTheImport(t *testing.T) {
	// The prices are in. Losing the import because a notification could not be
	// published would be the wrong trade.
	repo := &failingAlertRepo{fakeRepo: fakeRepo{}}
	svc, _ := newService(&repo.fakeRepo)
	svc.repo = repo

	result, err := svc.RecordQuotes(tenantCtx("tenant-1"), []domain.PriceQuote{
		quote("Cotton", 6500, domain.UnitPerQuintal),
	})
	if err != nil {
		t.Fatalf("the import failed because an alert lookup did: %v", err)
	}
	if result.Recorded != 1 {
		t.Errorf("recorded = %d, want 1", result.Recorded)
	}
}

type failingAlertRepo struct {
	fakeRepo
}

func (f *failingAlertRepo) MatchingAlerts(context.Context, string, string, string) ([]domain.PriceAlert, error) {
	return nil, errors.InternalServer("BOOM", "alert lookup failed")
}

// ─────────────────────────────────────────────────────────────────────────────
// Statistics and signal
// ─────────────────────────────────────────────────────────────────────────────

func TestGetPriceStatistics_ReportsAbsenceRatherThanZeroes(t *testing.T) {
	svc, _ := newService(&fakeRepo{window: nil})

	_, ok, err := svc.GetPriceStatistics(tenantCtx("tenant-1"), "Cotton", "mkt-1", 30)
	if err != nil {
		t.Fatalf("statistics: %v", err)
	}
	if ok {
		t.Error("an empty window reported statistics")
	}
}

func TestGetPriceStatistics_RequiresACommodityAndMarket(t *testing.T) {
	svc, _ := newService(&fakeRepo{})
	ctx := tenantCtx("tenant-1")

	if _, _, err := svc.GetPriceStatistics(ctx, "", "mkt-1", 30); !isBadRequest(err, "MISSING_COMMODITY") {
		t.Errorf("expected MISSING_COMMODITY, got %v", err)
	}
	if _, _, err := svc.GetPriceStatistics(ctx, "Cotton", " ", 30); !isBadRequest(err, "MISSING_MARKET") {
		t.Errorf("expected MISSING_MARKET, got %v", err)
	}
}

func TestGetSellSignal_LabelsAnEmptyAnswer(t *testing.T) {
	// With no quotes there are no statistics to carry the commodity, so the
	// service has to put it back — otherwise the caller gets advice about
	// nothing in particular.
	svc, _ := newService(&fakeRepo{window: nil})

	signal, err := svc.GetSellSignal(tenantCtx("tenant-1"), "Cotton", "mkt-1", 30)
	if err != nil {
		t.Fatalf("signal: %v", err)
	}

	if signal.Recommendation != domain.InsufficientData {
		t.Errorf("recommendation = %s", signal.Recommendation)
	}
	if signal.Commodity != "Cotton" || signal.MarketID != "mkt-1" {
		t.Errorf("the empty answer is not labelled: %+v", signal)
	}
}

func TestGetSellSignal_UsesTheStoredWindow(t *testing.T) {
	window := make([]domain.PriceQuote, 0, 10)
	start := testNow.AddDate(0, 0, -10)
	for i, p := range []float64{5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 6200, 6100} {
		window = append(window, domain.PriceQuote{
			Commodity:       "Cotton",
			MarketID:        "mkt-1",
			PricePerQuintal: p,
			QuotedOn:        start.AddDate(0, 0, i),
		})
	}
	svc, _ := newService(&fakeRepo{window: window})

	signal, err := svc.GetSellSignal(tenantCtx("tenant-1"), "Cotton", "mkt-1", 30)
	if err != nil {
		t.Fatalf("signal: %v", err)
	}
	if signal.Recommendation != domain.SellNow {
		t.Errorf("recommendation = %s, want SELL_NOW", signal.Recommendation)
	}
	if signal.Rationale == "" {
		t.Error("advice was given with no rationale")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Alerts CRUD
// ─────────────────────────────────────────────────────────────────────────────

func TestCreatePriceAlert_RefusesAnUnusableAlert(t *testing.T) {
	svc, _ := newService(&fakeRepo{})

	_, err := svc.CreatePriceAlert(tenantCtx("tenant-1"), &domain.PriceAlert{
		Commodity: "Cotton",
		MarketID:  "mkt-1",
		Direction: domain.AlertAbove,
		// No threshold: an alert that can never fire.
	})
	if !isBadRequest(err, "INVALID_ALERT") {
		t.Fatalf("expected INVALID_ALERT, got %v", err)
	}
}

func TestCreatePriceAlert_StampsTenantAndDefaults(t *testing.T) {
	repo := &fakeRepo{}
	svc, _ := newService(repo)

	created, err := svc.CreatePriceAlert(tenantCtx("tenant-1"), &domain.PriceAlert{
		Commodity:           "Cotton",
		MarketID:            "mkt-1",
		Direction:           domain.AlertAbove,
		ThresholdPerQuintal: 6000,
	})
	if err != nil {
		t.Fatalf("create: %v", err)
	}

	if created.TenantID != "tenant-1" {
		t.Errorf("tenant = %q", created.TenantID)
	}
	if created.ID == "" {
		t.Error("no id was assigned")
	}
	if !created.Enabled {
		t.Error("a new alert was created disabled")
	}
	if created.CreatedBy == "" {
		t.Error("no author was recorded")
	}
}

func TestClampDays(t *testing.T) {
	if got := clampDays(0); got != DefaultStatisticsDays {
		t.Errorf("clampDays(0) = %d, want %d", got, DefaultStatisticsDays)
	}
	if got := clampDays(-5); got != DefaultStatisticsDays {
		t.Errorf("clampDays(-5) = %d", got)
	}
	// One request must not be able to pull a decade of quotes.
	if got := clampDays(100000); got != maxStatisticsDays {
		t.Errorf("clampDays(100000) = %d, want %d", got, maxStatisticsDays)
	}
	if got := clampDays(14); got != 14 {
		t.Errorf("clampDays(14) = %d", got)
	}
}

func TestClampLimit(t *testing.T) {
	if got := clampLimit(0); got != 50 {
		t.Errorf("clampLimit(0) = %d, want 50", got)
	}
	if got := clampLimit(10000); got != 500 {
		t.Errorf("clampLimit(10000) = %d, want 500", got)
	}
}
