package application

import (
	"context"
	"errors"
	"testing"
	"time"

	"go.uber.org/zap"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/planning-service/internal/domain"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/planning-service/internal/ports/outbound"
)

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

type fakeRepo struct {
	plans map[string]*domain.SeasonPlan

	previous    string
	previousErr error

	createErr error
	updateErr error

	// lastBase is the version the service passed through to the repository,
	// which is what makes a concurrent edit detectable.
	lastBase int64
}

func newRepo() *fakeRepo { return &fakeRepo{plans: map[string]*domain.SeasonPlan{}} }

func (r *fakeRepo) CreatePlan(_ context.Context, p *domain.SeasonPlan) (*domain.SeasonPlan, error) {
	if r.createErr != nil {
		return nil, r.createErr
	}
	clone := *p
	r.plans[p.ID] = &clone
	return &clone, nil
}

func (r *fakeRepo) GetPlan(_ context.Context, id, _ string) (*domain.SeasonPlan, error) {
	plan, ok := r.plans[id]
	if !ok {
		return nil, errors.New("not found")
	}
	clone := *plan
	return &clone, nil
}

func (r *fakeRepo) ListPlans(_ context.Context, params domain.ListPlansParams) ([]domain.SeasonPlan, int64, error) {
	out := make([]domain.SeasonPlan, 0, len(r.plans))
	for _, p := range r.plans {
		out = append(out, *p)
	}
	_ = params
	return out, int64(len(out)), nil
}

func (r *fakeRepo) UpdatePlan(_ context.Context, p *domain.SeasonPlan, baseVersion int64) (*domain.SeasonPlan, error) {
	if r.updateErr != nil {
		return nil, r.updateErr
	}
	clone := *p
	clone.Version = baseVersion + 1
	r.lastBase = baseVersion
	r.plans[p.ID] = &clone
	return &clone, nil
}

func (r *fakeRepo) SetStatus(_ context.Context, id, _ string, status domain.PlanStatus) (*domain.SeasonPlan, error) {
	plan, ok := r.plans[id]
	if !ok {
		return nil, errors.New("not found")
	}
	plan.Status = status
	clone := *plan
	return &clone, nil
}

func (r *fakeRepo) PreviousCrop(_ context.Context, _, _ string, _ int, _ domain.Season) (string, error) {
	return r.previous, r.previousErr
}

type fakeWeather struct {
	onset *domain.MonsoonOnset
	err   error
	calls int
}

func (w *fakeWeather) MonsoonOnset(_ context.Context, _ string) (*domain.MonsoonOnset, error) {
	w.calls++
	return w.onset, w.err
}

type fakePublisher struct {
	topics []string
}

func (p *fakePublisher) Publish(_ context.Context, topic, _ string, _ []byte) error {
	p.topics = append(p.topics, topic)
	return nil
}

// newService takes the ports as interfaces, not as concrete pointers.
//
// A typed nil pointer assigned to an interface is not nil — the interface
// carries the type — so a helper that took *fakeWeather and returned it would
// hand the service a non-nil weather client backed by nothing, and the nil
// guard inside would not fire.
func newService(repo outbound.PlanRepository, weather outbound.WeatherClient, pub outbound.EventPublisher) inbound.PlanningService {
	logger := p9log.NewLogger(zap.NewNop())
	svc := NewPlanningService(repo, weather, pub, logger).(*planningService)
	svc.now = func() time.Time {
		return time.Date(2026, time.March, 14, 10, 0, 0, 0, time.UTC)
	}
	return svc
}

func tenantCtx() context.Context {
	return p9context.NewConnectionInfo(context.Background(),
		&saas.ConnectionInfo{TenantID: "01TENANT0000000000000000AA"})
}

func samplePlan() *domain.SeasonPlan {
	return &domain.SeasonPlan{
		FieldID:      "01FIELD00000000000000000AA",
		FarmID:       "01FARM000000000000000000AA",
		Season:       domain.Kharif,
		Year:         2026,
		Crop:         "cotton",
		AreaHectares: 4,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Create
// ─────────────────────────────────────────────────────────────────────────────

func TestCreatePlanDerivesWindowRotationAndBudget(t *testing.T) {
	repo := newRepo()
	repo.previous = "soybean"
	pub := &fakePublisher{}
	svc := newService(repo, nil, pub)

	plan, err := svc.CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("CreatePlan: %v", err)
	}

	if plan.ID == "" {
		t.Error("the plan was stored without an id")
	}
	if plan.Status != domain.PlanDraft {
		t.Errorf("status = %s, want DRAFT — a new plan is not a commitment", plan.Status)
	}
	if plan.Crop != "Cotton" {
		t.Errorf("crop = %q, want the calendar's canonical %q", plan.Crop, "Cotton")
	}
	if plan.SowingWindow.Opens.IsZero() {
		t.Error("the plan has no sowing window")
	}
	if plan.RotationCheck.Verdict != domain.RotationGood {
		t.Errorf("verdict = %s, want GOOD — cotton after a legume", plan.RotationCheck.Verdict)
	}
	if plan.Budget.TotalCost <= 0 {
		t.Error("the plan has no budget")
	}
}

// The reason the three derived pieces are computed in one place: the rotation
// check finds the legume credit and the budget has to spend it.
func TestCreatePlanSpendsTheLegumeCreditInTheBudget(t *testing.T) {
	withLegume := newRepo()
	withLegume.previous = "soybean"
	afterLegume, err := newService(withLegume, nil, nil).CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("CreatePlan after a legume: %v", err)
	}

	withCereal := newRepo()
	withCereal.previous = "maize"
	afterCereal, err := newService(withCereal, nil, nil).CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("CreatePlan after a cereal: %v", err)
	}

	if afterLegume.RotationCheck.NitrogenCreditKgHa <= 0 {
		t.Fatal("soybean should leave a nitrogen credit")
	}

	legumeN := nitrogenLine(t, afterLegume.Budget)
	cerealN := nitrogenLine(t, afterCereal.Budget)
	if legumeN.Quantity >= cerealN.Quantity {
		t.Errorf("nitrogen after a legume = %.0f kg, after a cereal = %.0f kg; "+
			"the legume credit is not reaching the budget", legumeN.Quantity, cerealN.Quantity)
	}
	if legumeN.Note == "" {
		t.Error("the nitrogen line does not say why it is lower than the crop's demand")
	}
}

func nitrogenLine(t *testing.T, budget domain.InputBudget) domain.InputLine {
	t.Helper()
	for _, line := range budget.Lines {
		if line.Kind == domain.InputFertiliser && line.Unit == "kg N" {
			return line
		}
	}
	t.Fatal("the budget has no nitrogen line")
	return domain.InputLine{}
}

func TestCreatePlanRefusesACropItDoesNotKnow(t *testing.T) {
	plan := samplePlan()
	plan.Crop = "dragonfruit"

	_, err := newService(newRepo(), nil, nil).CreatePlan(tenantCtx(), plan)
	if err == nil {
		t.Fatal("a crop outside the calendar should be refused, not planned from zeroes")
	}
}

func TestCreatePlanRefusesACropOutOfSeason(t *testing.T) {
	plan := samplePlan()
	plan.Crop = "wheat" // rabi only
	plan.Season = domain.Kharif

	_, err := newService(newRepo(), nil, nil).CreatePlan(tenantCtx(), plan)
	if err == nil {
		t.Fatal("wheat is not a kharif crop and the plan should say so")
	}
}

func TestCreatePlanRequiresATenant(t *testing.T) {
	_, err := newService(newRepo(), nil, nil).CreatePlan(context.Background(), samplePlan())
	if err == nil {
		t.Fatal("a plan with no tenant should be refused")
	}
}

// A history lookup that fails must not block the season. The rotation check
// already reports a missing previous crop as unverified.
func TestCreatePlanSurvivesAFailedHistoryLookup(t *testing.T) {
	repo := newRepo()
	repo.previousErr = errors.New("history query timed out")

	plan, err := newService(repo, nil, nil).CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("a failed history lookup should not block planning: %v", err)
	}
	if plan.RotationCheck.Verdict != domain.RotationAcceptable {
		t.Errorf("verdict = %s, want ACCEPTABLE — unverified, not approved",
			plan.RotationCheck.Verdict)
	}
	if plan.RotationCheck.PreviousCrop != "" {
		t.Error("a failed lookup should not invent a previous crop")
	}
}

func TestCreatePlanPublishesCreated(t *testing.T) {
	pub := &fakePublisher{}
	if _, err := newService(newRepo(), nil, pub).CreatePlan(tenantCtx(), samplePlan()); err != nil {
		t.Fatalf("CreatePlan: %v", err)
	}
	if len(pub.topics) != 1 || pub.topics[0] != topicPlanCreated {
		t.Errorf("published %v, want one %s", pub.topics, topicPlanCreated)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Weather
// ─────────────────────────────────────────────────────────────────────────────

func TestCreatePlanUsesRainfallHistoryForAKharifWindow(t *testing.T) {
	// Day 170 is 19 June — a fortnight after the calendar's 1 June kharif start.
	weather := &fakeWeather{onset: &domain.MonsoonOnset{DayOfYear: 170, Years: 6}}

	informed, err := newService(newRepo(), weather, nil).CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("CreatePlan: %v", err)
	}
	calendar, err := newService(newRepo(), nil, nil).CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("CreatePlan without weather: %v", err)
	}

	if !informed.SowingWindow.WeatherInformed {
		t.Error("the window does not record that it came from rainfall history")
	}
	if !informed.SowingWindow.Opens.After(calendar.SowingWindow.Opens) {
		t.Errorf("a late monsoon should push the window back: informed opens %s, calendar opens %s",
			informed.SowingWindow.Opens.Format("2 Jan"), calendar.SowingWindow.Opens.Format("2 Jan"))
	}
	if calendar.SowingWindow.WeatherInformed {
		t.Error("a calendar window must not claim to be weather-informed")
	}
}

// weather-service being down is not a reason to refuse to plan.
func TestCreatePlanFallsBackWhenWeatherFails(t *testing.T) {
	weather := &fakeWeather{err: errors.New("weather-service unavailable")}

	plan, err := newService(newRepo(), weather, nil).CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("a weather failure should not block planning: %v", err)
	}
	if plan.SowingWindow.Opens.IsZero() {
		t.Fatal("no window was produced")
	}
	if plan.SowingWindow.WeatherInformed {
		t.Error("the window claims to be weather-informed after the lookup failed")
	}
}

// Rabi is sown on residual moisture after the kharif harvest; the monsoon
// onset is the wrong signal for it, and using it would move the window by a
// rule borrowed from another season.
func TestRabiWindowIgnoresMonsoonOnset(t *testing.T) {
	weather := &fakeWeather{onset: &domain.MonsoonOnset{DayOfYear: 175, Years: 8}}

	plan := samplePlan()
	plan.Crop = "wheat"
	plan.Season = domain.Rabi

	created, err := newService(newRepo(), weather, nil).CreatePlan(tenantCtx(), plan)
	if err != nil {
		t.Fatalf("CreatePlan: %v", err)
	}
	if created.SowingWindow.WeatherInformed {
		t.Error("a rabi window must not be shifted by the monsoon onset")
	}
	if created.SowingWindow.Opens.Month() != time.November {
		t.Errorf("wheat opens %s, want November — 20 days after the 15 October rabi start",
			created.SowingWindow.Opens.Format("2 Jan"))
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Update and commit
// ─────────────────────────────────────────────────────────────────────────────

func TestUpdatePlanRecomputesTheBudgetForTheNewArea(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, nil, nil)

	created, err := svc.CreatePlan(tenantCtx(), samplePlan())
	if err != nil {
		t.Fatalf("CreatePlan: %v", err)
	}

	updated, err := svc.UpdatePlan(tenantCtx(), &domain.SeasonPlan{
		ID:           created.ID,
		Crop:         created.Crop,
		AreaHectares: created.AreaHectares * 2,
	}, created.Version)
	if err != nil {
		t.Fatalf("UpdatePlan: %v", err)
	}

	if updated.Budget.TotalCost <= created.Budget.TotalCost {
		t.Errorf("doubling the area left the budget at %.0f (was %.0f); "+
			"the plan is carrying the old area's costs",
			updated.Budget.TotalCost, created.Budget.TotalCost)
	}
	if repo.lastBase != created.Version {
		t.Errorf("base version passed to the repository = %d, want %d",
			repo.lastBase, created.Version)
	}
}

// Field, season and year are the plan's identity. Letting an edit move them
// would quietly relocate the plan onto other ground.
func TestUpdatePlanKeepsTheFieldSeasonAndYear(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, nil, nil)

	created, _ := svc.CreatePlan(tenantCtx(), samplePlan())

	updated, err := svc.UpdatePlan(tenantCtx(), &domain.SeasonPlan{
		ID:           created.ID,
		FieldID:      "01OTHERFIELD000000000000AA",
		Season:       domain.Rabi,
		Year:         2099,
		Crop:         created.Crop,
		AreaHectares: created.AreaHectares,
	}, created.Version)
	if err != nil {
		t.Fatalf("UpdatePlan: %v", err)
	}

	if updated.FieldID != created.FieldID {
		t.Errorf("field moved to %s; an edit must not relocate the plan", updated.FieldID)
	}
	if updated.Season != created.Season || updated.Year != created.Year {
		t.Errorf("season/year moved to %s %d, want %s %d",
			updated.Season, updated.Year, created.Season, created.Year)
	}
}

func TestUpdatePlanRefusesACommittedPlan(t *testing.T) {
	repo := newRepo()
	svc := newService(repo, nil, nil)

	created, _ := svc.CreatePlan(tenantCtx(), samplePlan())
	if _, err := svc.CommitPlan(tenantCtx(), created.ID); err != nil {
		t.Fatalf("CommitPlan: %v", err)
	}

	_, err := svc.UpdatePlan(tenantCtx(), &domain.SeasonPlan{
		ID:           created.ID,
		Crop:         "maize",
		AreaHectares: 4,
	}, created.Version)
	if err == nil {
		t.Fatal("a committed plan has seed ordered against it and must not be edited in place")
	}
}

func TestCommitPlanPublishesAndIsIdempotent(t *testing.T) {
	repo := newRepo()
	pub := &fakePublisher{}
	svc := newService(repo, nil, pub)

	created, _ := svc.CreatePlan(tenantCtx(), samplePlan())

	first, err := svc.CommitPlan(tenantCtx(), created.ID)
	if err != nil {
		t.Fatalf("CommitPlan: %v", err)
	}
	if first.Status != domain.PlanCommitted {
		t.Errorf("status = %s, want COMMITTED", first.Status)
	}

	second, err := svc.CommitPlan(tenantCtx(), created.ID)
	if err != nil {
		t.Fatalf("a retried commit should be harmless: %v", err)
	}
	if second.Status != domain.PlanCommitted {
		t.Errorf("status after the retry = %s, want COMMITTED", second.Status)
	}

	commits := 0
	for _, topic := range pub.topics {
		if topic == topicPlanCommitted {
			commits++
		}
	}
	if commits != 1 {
		t.Errorf("published %d commit events, want 1 — the retry should not re-announce it", commits)
	}
}

// A poor rotation is advice, not a veto. A planner that blocked the season over
// it would be worked around rather than heeded.
func TestCommitPlanAllowsAPoorRotation(t *testing.T) {
	repo := newRepo()
	repo.previous = "chilli" // Solanaceae, same family as tomato
	svc := newService(repo, nil, nil)

	plan := samplePlan()
	plan.Crop = "tomato"

	created, err := svc.CreatePlan(tenantCtx(), plan)
	if err != nil {
		t.Fatalf("CreatePlan: %v", err)
	}
	if created.RotationCheck.Verdict != domain.RotationPoor {
		t.Fatalf("verdict = %s, want POOR — tomato after chilli is the same family",
			created.RotationCheck.Verdict)
	}

	if _, err := svc.CommitPlan(tenantCtx(), created.ID); err != nil {
		t.Fatalf("a poor rotation is a warning, not a refusal: %v", err)
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// Standalone queries
// ─────────────────────────────────────────────────────────────────────────────

func TestCheckRotationAnswersWithoutAPlan(t *testing.T) {
	repo := newRepo()
	repo.previous = "wheat"

	check, err := newService(repo, nil, nil).CheckRotation(tenantCtx(), "01FIELD00000000000000000AA", "rice")
	if err != nil {
		t.Fatalf("CheckRotation: %v", err)
	}
	if check.Verdict != domain.RotationPoor {
		t.Errorf("verdict = %s, want POOR — rice after wheat is cereal on cereal", check.Verdict)
	}
	if check.Rationale == "" {
		t.Error("a verdict with no rationale tells a farmer nothing they can act on")
	}
}

func TestGetSowingWindowWithoutAFieldIsStillAnswerable(t *testing.T) {
	weather := &fakeWeather{onset: &domain.MonsoonOnset{DayOfYear: 170, Years: 5}}
	svc := newService(newRepo(), weather, nil)

	window, err := svc.GetSowingWindow(tenantCtx(), "", "wheat", domain.Rabi, 2026)
	if err != nil {
		t.Fatalf("GetSowingWindow: %v", err)
	}
	if window.Opens.IsZero() {
		t.Fatal("no window was produced")
	}
	if weather.calls != 0 {
		t.Error("weather was consulted for a question with no field attached to it")
	}
}

func TestGetSowingWindowDefaultsTheYearAndSeason(t *testing.T) {
	// The clock is 14 March 2026, which is still rabi — the crop sown the
	// previous October.
	window, err := newService(newRepo(), nil, nil).GetSowingWindow(tenantCtx(), "", "wheat", "", 0)
	if err != nil {
		t.Fatalf("GetSowingWindow: %v", err)
	}
	if window.Season != domain.Rabi {
		t.Errorf("season = %s, want RABI for mid-March", window.Season)
	}
	if window.Opens.Year() != 2026 {
		t.Errorf("year = %d, want 2026", window.Opens.Year())
	}
}

func TestGetSowingWindowRefusesAnUnknownCrop(t *testing.T) {
	_, err := newService(newRepo(), nil, nil).GetSowingWindow(tenantCtx(), "", "dragonfruit", domain.Kharif, 2026)
	if err == nil {
		t.Fatal("an unknown crop should be refused rather than given a default window")
	}
}

func TestCurrentSeason(t *testing.T) {
	cases := []struct {
		date time.Time
		want domain.Season
	}{
		{time.Date(2026, time.January, 20, 0, 0, 0, 0, time.UTC), domain.Rabi},
		{time.Date(2026, time.March, 14, 0, 0, 0, 0, time.UTC), domain.Rabi},
		{time.Date(2026, time.April, 2, 0, 0, 0, 0, time.UTC), domain.Zaid},
		{time.Date(2026, time.July, 4, 0, 0, 0, 0, time.UTC), domain.Kharif},
		// Early October is still the kharif crop standing in the field; the
		// rabi sowing starts on the 15th.
		{time.Date(2026, time.October, 3, 0, 0, 0, 0, time.UTC), domain.Kharif},
		{time.Date(2026, time.October, 20, 0, 0, 0, 0, time.UTC), domain.Rabi},
		{time.Date(2026, time.December, 1, 0, 0, 0, 0, time.UTC), domain.Rabi},
	}
	for _, tc := range cases {
		if got := currentSeason(tc.date); got != tc.want {
			t.Errorf("currentSeason(%s) = %s, want %s", tc.date.Format("2 Jan"), got, tc.want)
		}
	}
}
