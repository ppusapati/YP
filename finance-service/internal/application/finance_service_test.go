package application

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"go.uber.org/zap"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/finance-service/internal/domain"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/finance-service/internal/ports/outbound"
)

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

type fakeRepo struct {
	quotes      map[string]*domain.InsuranceQuote
	assessments map[string]*domain.CreditAssessment
	claims      map[string]*domain.Claim

	// savedAssessments counts every write, which is how "an assessment is never
	// overwritten" is checked.
	savedAssessments int
}

func newRepo() *fakeRepo {
	return &fakeRepo{
		quotes:      map[string]*domain.InsuranceQuote{},
		assessments: map[string]*domain.CreditAssessment{},
		claims:      map[string]*domain.Claim{},
	}
}

func (r *fakeRepo) CreateQuote(_ context.Context, q *domain.InsuranceQuote) (*domain.InsuranceQuote, error) {
	clone := *q
	r.quotes[q.ID] = &clone
	return &clone, nil
}

func (r *fakeRepo) GetQuote(_ context.Context, id, _ string) (*domain.InsuranceQuote, error) {
	q, ok := r.quotes[id]
	if !ok {
		return nil, errors.New("quote not found")
	}
	clone := *q
	return &clone, nil
}

func (r *fakeRepo) ListQuotes(_ context.Context, _ domain.ListQuotesParams) ([]domain.InsuranceQuote, int64, error) {
	out := make([]domain.InsuranceQuote, 0, len(r.quotes))
	for _, q := range r.quotes {
		out = append(out, *q)
	}
	return out, int64(len(out)), nil
}

func (r *fakeRepo) SaveAssessment(_ context.Context, a *domain.CreditAssessment) (*domain.CreditAssessment, error) {
	r.savedAssessments++
	clone := *a
	r.assessments[a.ID] = &clone
	return &clone, nil
}

func (r *fakeRepo) GetAssessment(_ context.Context, id, _ string) (*domain.CreditAssessment, error) {
	a, ok := r.assessments[id]
	if !ok {
		return nil, errors.New("assessment not found")
	}
	clone := *a
	return &clone, nil
}

func (r *fakeRepo) CreateClaim(_ context.Context, c *domain.Claim) (*domain.Claim, error) {
	clone := *c
	r.claims[c.ID] = &clone
	return &clone, nil
}

func (r *fakeRepo) GetClaim(_ context.Context, id, _ string) (*domain.Claim, error) {
	c, ok := r.claims[id]
	if !ok {
		return nil, errors.New("claim not found")
	}
	clone := *c
	return &clone, nil
}

func (r *fakeRepo) ListClaims(_ context.Context, _ domain.ListClaimsParams) ([]domain.Claim, int64, error) {
	out := make([]domain.Claim, 0, len(r.claims))
	for _, c := range r.claims {
		out = append(out, *c)
	}
	return out, int64(len(out)), nil
}

func (r *fakeRepo) SaveClaim(_ context.Context, c *domain.Claim) (*domain.Claim, error) {
	clone := *c
	clone.Version++
	r.claims[c.ID] = &clone
	return &clone, nil
}

type fakeYields struct {
	field []domain.YieldSeason
	farm  []domain.YieldSeason
	err   error
}

func (y *fakeYields) FieldHistory(_ context.Context, _ string, _, _ int) ([]domain.YieldSeason, error) {
	return y.field, y.err
}

func (y *fakeYields) FarmHistory(_ context.Context, _ string, _, _ int) ([]domain.YieldSeason, error) {
	return y.farm, y.err
}

type fakeSatellite struct {
	observations []domain.NDVIObservation
	err          error
}

func (s *fakeSatellite) NDVISeries(_ context.Context, _ string, _, _ time.Time) ([]domain.NDVIObservation, error) {
	return s.observations, s.err
}

type fakeWeather struct {
	window domain.WeatherWindow
	err    error
}

func (w *fakeWeather) Window(_ context.Context, _ string, _, _ time.Time) (domain.WeatherWindow, error) {
	return w.window, w.err
}

type fakePublisher struct{ topics []string }

func (p *fakePublisher) Publish(_ context.Context, topic, _ string, _ []byte) error {
	p.topics = append(p.topics, topic)
	return nil
}

func (p *fakePublisher) has(topic string) bool {
	for _, t := range p.topics {
		if t == topic {
			return true
		}
	}
	return false
}

var testNow = time.Date(2026, time.October, 10, 0, 0, 0, 0, time.UTC)

// newService takes the ports as interfaces, not concrete pointers: a typed nil
// pointer in an interface is not nil, and the nil guards inside would not fire.
func newService(
	repo *fakeRepo,
	yields outbound.YieldClient,
	satellite outbound.SatelliteClient,
	weather outbound.WeatherClient,
	pub outbound.EventPublisher,
) inbound.FinanceService {
	svc := NewFinanceService(repo, repo, repo, yields, satellite, weather, pub,
		p9log.NewLogger(zap.NewNop())).(*financeService)
	svc.now = func() time.Time { return testNow }
	return svc
}

func tenantCtx() context.Context {
	return p9context.NewConnectionInfo(context.Background(),
		&saas.ConnectionInfo{TenantID: "01TENANT0000000000000000AA"})
}

func history(yields ...float64) []domain.YieldSeason {
	out := make([]domain.YieldSeason, 0, len(yields))
	for i, y := range yields {
		out = append(out, domain.YieldSeason{
			Year: 2026 - len(yields) + i, Crop: "wheat",
			YieldKgHa: y, AreaHa: 2, ProfitPerHa: 22000,
		})
	}
	return out
}

func quoteParams() domain.QuoteParams {
	return domain.QuoteParams{
		FieldID: "field-1", FarmID: "farm-1", Crop: "wheat",
		Category: domain.CategoryFoodGrain, Season: domain.Kharif,
		Year: 2026, AreaHectares: 2, SumInsuredPerHectare: 50000,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Quotes
// ─────────────────────────────────────────────────────────────────────────────

func TestQuoteUsesTheFieldsHistory(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 1500, 4100, 3900)}
	pub := &fakePublisher{}

	quote, err := newService(repo, yields, nil, nil, pub).QuoteInsurance(tenantCtx(), quoteParams())
	if err != nil {
		t.Fatalf("QuoteInsurance: %v", err)
	}

	if quote.Confidence != domain.ConfidenceFieldHistory {
		t.Errorf("confidence = %s, want FIELD_HISTORY", quote.Confidence)
	}
	if quote.ID == "" {
		t.Error("the quote was not stored")
	}
	if !pub.has(topicQuoteIssued) {
		t.Errorf("published %v, want a quote-issued event", pub.topics)
	}
}

// A benchmark rate and a priced one look identical in a number. The farmer has
// to be able to tell that nobody looked at their field.
func TestAFailedHistoryReadFallsBackToABenchmarkAndSaysSo(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{err: errors.New("yield-service unavailable")}

	quote, err := newService(repo, yields, nil, nil, nil).QuoteInsurance(tenantCtx(), quoteParams())
	if err != nil {
		t.Fatalf("a yield-service failure should not block a quote: %v", err)
	}
	if quote.Confidence != domain.ConfidenceBenchmarkOnly {
		t.Errorf("confidence = %s, want BENCHMARK_ONLY", quote.Confidence)
	}
	if !strings.Contains(quote.Basis, "not a measurement of this field") {
		t.Errorf("basis = %q", quote.Basis)
	}
}

func TestQuoteDefaultsTheYear(t *testing.T) {
	repo := newRepo()
	params := quoteParams()
	params.Year = 0

	quote, err := newService(repo, &fakeYields{}, nil, nil, nil).QuoteInsurance(tenantCtx(), params)
	if err != nil {
		t.Fatalf("QuoteInsurance: %v", err)
	}
	if quote.Year != 2026 {
		t.Errorf("year = %d, want 2026", quote.Year)
	}
}

func TestQuoteRequiresATenant(t *testing.T) {
	repo := newRepo()
	_, err := newService(repo, &fakeYields{}, nil, nil, nil).
		QuoteInsurance(context.Background(), quoteParams())
	if err == nil {
		t.Fatal("a quote with no tenant should be refused")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Credit
// ─────────────────────────────────────────────────────────────────────────────

// The failure this guard exists for: telling a farmer with eight good seasons
// that they have no track record, because a query timed out, ends with them
// being turned down for a loan they had earned.
func TestAFailedHistoryReadDoesNotProduceAnEmptyAssessment(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{err: errors.New("yield-service unavailable")}

	_, err := newService(repo, yields, nil, nil, nil).AssessCredit(tenantCtx(), "farm-1", 0, 0)
	if err == nil {
		t.Fatal("a failed history read produced an assessment; an empty history reads " +
			"as 'no track record', which is not the same thing")
	}
	if !strings.Contains(err.Error(), "not the same thing") {
		t.Errorf("the error does not explain why no assessment was produced: %v", err)
	}
	if repo.savedAssessments != 0 {
		t.Error("an assessment was stored despite the failed read")
	}
}

func TestAssessCreditStoresAndPublishes(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{farm: history(3900, 4100, 4000, 4200, 3950, 4050)}
	pub := &fakePublisher{}

	assessment, err := newService(repo, yields, nil, nil, pub).
		AssessCredit(tenantCtx(), "farm-1", 0, 0)
	if err != nil {
		t.Fatalf("AssessCredit: %v", err)
	}

	if assessment.Status != domain.ScoreScored {
		t.Fatalf("status = %s, want SCORED", assessment.Status)
	}
	if assessment.Score == 0 {
		t.Error("a scored assessment has no score")
	}
	if assessment.Caveat == "" {
		t.Error("the assessment carries no caveat")
	}
	if !pub.has(topicCreditAssessed) {
		t.Errorf("published %v, want a credit-assessed event", pub.topics)
	}
}

// A score is a thing somebody may have been lent money against.
func TestEveryAssessmentIsKept(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{farm: history(3900, 4100, 4000, 4200)}
	svc := newService(repo, yields, nil, nil, nil)
	ctx := tenantCtx()

	first, _ := svc.AssessCredit(ctx, "farm-1", 0, 0)
	second, _ := svc.AssessCredit(ctx, "farm-1", 0, 0)

	if first.ID == second.ID {
		t.Fatal("the second assessment reused the first one's id")
	}
	if len(repo.assessments) != 2 {
		t.Errorf("%d assessments stored; a lender's copy was overwritten",
			len(repo.assessments))
	}
}

func TestAssessCreditWithNoYieldServiceRefuses(t *testing.T) {
	repo := newRepo()
	_, err := newService(repo, nil, nil, nil, nil).AssessCredit(tenantCtx(), "farm-1", 0, 0)
	if err == nil {
		t.Fatal("an assessment with no harvest record behind it should be refused")
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Claims
// ─────────────────────────────────────────────────────────────────────────────

func storedQuote(t *testing.T, repo *fakeRepo, yields *fakeYields) *domain.InsuranceQuote {
	t.Helper()
	quote, err := newService(repo, yields, nil, nil, nil).
		QuoteInsurance(tenantCtx(), quoteParams())
	if err != nil {
		t.Fatalf("QuoteInsurance: %v", err)
	}
	return quote
}

func TestFileClaimTakesItsTermsFromTheQuote(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)
	pub := &fakePublisher{}

	claim, err := newService(repo, yields, nil, nil, pub).FileClaim(tenantCtx(), &domain.Claim{
		QuoteID:             quote.ID,
		FieldID:             "field-1",
		Cause:               domain.CauseDrought,
		LossStartedOn:       time.Date(2026, time.August, 1, 0, 0, 0, 0, time.UTC),
		ClaimedAreaHectares: 2,
		ReportedYieldKgHa:   1200,
	})
	if err != nil {
		t.Fatalf("FileClaim: %v", err)
	}

	if claim.ThresholdYieldKgHa != quote.ThresholdYieldKgHa {
		t.Errorf("threshold = %.0f, want the quote's %.0f — a claim assessed against "+
			"figures the claimant supplied is not the policy",
			claim.ThresholdYieldKgHa, quote.ThresholdYieldKgHa)
	}
	if claim.Crop != quote.Crop || claim.Year != quote.Year {
		t.Error("the claim did not take its crop and year from the cover")
	}
	if claim.IndicatedPayout <= 0 {
		t.Error("a yield well below the threshold produced no indicated payout")
	}
	if claim.Status != domain.ClaimSubmitted {
		t.Errorf("status = %s, want SUBMITTED", claim.Status)
	}
	if !pub.has(topicClaimFiled) {
		t.Errorf("published %v, want a claim-filed event", pub.topics)
	}
}

func TestFileClaimRefusesMoreAreaThanIsInsured(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)

	_, err := newService(repo, yields, nil, nil, nil).FileClaim(tenantCtx(), &domain.Claim{
		QuoteID:             quote.ID,
		FieldID:             "field-1",
		Cause:               domain.CauseFlood,
		LossStartedOn:       testNow,
		ClaimedAreaHectares: 10, // the cover is for 2 ha
		ReportedYieldKgHa:   0,
	})
	if err == nil {
		t.Fatal("a claim over ten hectares against two hectares of cover was accepted")
	}
}

func TestFileClaimRefusesAFieldTheCoverIsNotOn(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)

	_, err := newService(repo, yields, nil, nil, nil).FileClaim(tenantCtx(), &domain.Claim{
		QuoteID:             quote.ID,
		FieldID:             "some-other-field",
		Cause:               domain.CauseFlood,
		LossStartedOn:       testNow,
		ClaimedAreaHectares: 1,
	})
	if err == nil {
		t.Fatal("a claim on a field the cover was not written on was accepted")
	}
}

// A pack with no satellite entry looks like a pack nobody bothered to build.
// One that says why the satellite could not help is a fact about the claim.
func TestEverySourceProducesAnEntryEvenWhenItCannotHelp(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)

	svc := newService(repo, yields, nil, nil, nil) // no satellite, no weather
	ctx := tenantCtx()

	claim, err := svc.FileClaim(ctx, &domain.Claim{
		QuoteID: quote.ID, FieldID: "field-1", Cause: domain.CauseDrought,
		LossStartedOn:       time.Date(2026, time.August, 1, 0, 0, 0, 0, time.UTC),
		ClaimedAreaHectares: 2, ReportedYieldKgHa: 1000,
	})
	if err != nil {
		t.Fatalf("FileClaim: %v", err)
	}

	gathered, err := svc.GatherEvidence(ctx, claim.ID)
	if err != nil {
		t.Fatalf("GatherEvidence: %v", err)
	}

	sources := map[domain.EvidenceSource]bool{}
	for _, item := range gathered.Evidence {
		sources[item.Source] = true
		if item.ID == "" {
			t.Errorf("evidence from %s has no id", item.Source)
		}
		if item.Summary == "" {
			t.Errorf("evidence from %s has no summary", item.Source)
		}
	}
	for _, want := range []domain.EvidenceSource{
		domain.EvidenceSatelliteNDVI, domain.EvidenceWeather, domain.EvidenceYieldRecord,
	} {
		if !sources[want] {
			t.Errorf("the pack has no %s entry at all", want)
		}
	}
	if gathered.Status != domain.ClaimEvidenceReady {
		t.Errorf("status = %s, want EVIDENCE_READY", gathered.Status)
	}
}

func TestGatherEvidenceUsesTheSatelliteAndWeatherWhenTheyAreThere(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)

	lossStart := time.Date(2026, time.August, 1, 0, 0, 0, 0, time.UTC)
	satellite := &fakeSatellite{observations: []domain.NDVIObservation{
		{At: lossStart.AddDate(0, 0, -20), Value: 0.70, CloudCover: 0.05},
		{At: lossStart.AddDate(0, 0, -8), Value: 0.72, CloudCover: 0.05},
		{At: lossStart.AddDate(0, 0, 6), Value: 0.25, CloudCover: 0.05},
	}}
	weather := &fakeWeather{window: domain.WeatherWindow{
		RainfallMM: 20, NormalRainfallMM: 180, HasNormal: true, DryDays: 25, Days: 45,
	}}
	pub := &fakePublisher{}

	svc := newService(repo, yields, satellite, weather, pub)
	ctx := tenantCtx()

	claim, _ := svc.FileClaim(ctx, &domain.Claim{
		QuoteID: quote.ID, FieldID: "field-1", Cause: domain.CauseDrought,
		LossStartedOn:       lossStart,
		LossEndedOn:         lossStart.AddDate(0, 0, 20),
		ClaimedAreaHectares: 2, ReportedYieldKgHa: 900,
	})

	gathered, err := svc.GatherEvidence(ctx, claim.ID)
	if err != nil {
		t.Fatalf("GatherEvidence: %v", err)
	}

	supports := 0
	for _, item := range gathered.Evidence {
		if item.Verdict == domain.VerdictSupports {
			supports++
		}
	}
	if supports < 3 {
		t.Errorf("%d of %d sources support a drought with a collapsed NDVI, a 90%% "+
			"rainfall deficit and a yield well under the threshold",
			supports, len(gathered.Evidence))
	}
	if !strings.Contains(gathered.EvidenceSummary, "not a decision") {
		t.Errorf("the summary does not say it is not a decision: %q", gathered.EvidenceSummary)
	}
	if !pub.has(topicEvidenceReady) {
		t.Errorf("published %v, want an evidence-ready event", pub.topics)
	}
}

func TestEvidenceCannotBeRegatheredOnAClosedClaim(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)
	svc := newService(repo, yields, nil, nil, nil)
	ctx := tenantCtx()

	claim, _ := svc.FileClaim(ctx, &domain.Claim{
		QuoteID: quote.ID, FieldID: "field-1", Cause: domain.CauseHail,
		LossStartedOn: testNow, ClaimedAreaHectares: 2, ReportedYieldKgHa: 500,
	})
	if _, err := svc.UpdateClaimStatus(ctx, claim.ID, domain.ClaimSettled, "paid in full"); err != nil {
		t.Fatalf("UpdateClaimStatus: %v", err)
	}

	if _, err := svc.GatherEvidence(ctx, claim.ID); err == nil {
		t.Fatal("the evidence pack of a settled claim was rebuilt; the insurer decided " +
			"on what they saw")
	}
}

// A claim marked rejected with no reason leaves a farmer with nothing to
// appeal against.
func TestRejectingAClaimNeedsAReason(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)
	svc := newService(repo, yields, nil, nil, nil)
	ctx := tenantCtx()

	claim, _ := svc.FileClaim(ctx, &domain.Claim{
		QuoteID: quote.ID, FieldID: "field-1", Cause: domain.CausePest,
		LossStartedOn: testNow, ClaimedAreaHectares: 2, ReportedYieldKgHa: 500,
	})

	if _, err := svc.UpdateClaimStatus(ctx, claim.ID, domain.ClaimRejected, ""); err == nil {
		t.Fatal("a claim was rejected with no reason")
	}

	rejected, err := svc.UpdateClaimStatus(ctx, claim.ID, domain.ClaimRejected,
		"the loss fell outside the cover period")
	if err != nil {
		t.Fatalf("UpdateClaimStatus: %v", err)
	}
	if !strings.Contains(rejected.Description, "outside the cover period") {
		t.Errorf("the reason was not recorded on the claim: %q", rejected.Description)
	}
}

func TestASettledClaimCannotBeReopened(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)
	svc := newService(repo, yields, nil, nil, nil)
	ctx := tenantCtx()

	claim, _ := svc.FileClaim(ctx, &domain.Claim{
		QuoteID: quote.ID, FieldID: "field-1", Cause: domain.CauseFire,
		LossStartedOn: testNow, ClaimedAreaHectares: 2, ReportedYieldKgHa: 0,
	})
	if _, err := svc.UpdateClaimStatus(ctx, claim.ID, domain.ClaimSettled, "paid"); err != nil {
		t.Fatalf("UpdateClaimStatus: %v", err)
	}

	if _, err := svc.UpdateClaimStatus(ctx, claim.ID, domain.ClaimSubmitted, "reopening"); err == nil {
		t.Fatal("a settled claim was reopened")
	}
}

func TestFileClaimValidatesTheClaim(t *testing.T) {
	repo := newRepo()
	yields := &fakeYields{field: history(4000, 3800, 4200, 4100, 3900, 4050)}
	quote := storedQuote(t, repo, yields)
	svc := newService(repo, yields, nil, nil, nil)

	_, err := svc.FileClaim(tenantCtx(), &domain.Claim{
		QuoteID: quote.ID, FieldID: "field-1",
		// No cause, which every weather test is written against.
		LossStartedOn: testNow, ClaimedAreaHectares: 2,
	})
	if err == nil {
		t.Fatal("a claim with no loss cause was accepted")
	}
}
