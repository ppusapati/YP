package scheduler

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	pb "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/testutil"
)

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

type fakeStore struct {
	due     []*models.AlertRule
	listErr error

	touched  []touch
	touchErr error
}

type touch struct {
	tenantID string
	ruleID   string
	at       time.Time
}

func (s *fakeStore) ListDueRules(_ context.Context, _ time.Time, limit int) ([]*models.AlertRule, error) {
	if s.listErr != nil {
		return nil, s.listErr
	}
	if limit > 0 && len(s.due) > limit {
		return s.due[:limit], nil
	}
	return s.due, nil
}

func (s *fakeStore) TouchRuleFired(_ context.Context, tenantID, id string, at time.Time) error {
	s.touched = append(s.touched, touch{tenantID: tenantID, ruleID: id, at: at})
	return s.touchErr
}

type fakeEvaluator struct {
	// risk by field id.
	risk    map[string]*pb.FieldRiskScore
	riskErr map[string]error

	// evaluations counts GetFieldRisk per field, so a test can show that six
	// rules on one field cost one gateway call.
	evaluations map[string]int
	// tenantSeen records the tenant the context carried at evaluation time.
	tenantSeen map[string]string

	recorded []*models.Alert
	tenants  []string
	seen     map[string]bool
	recErr   error
}

func newFakeEvaluator() *fakeEvaluator {
	return &fakeEvaluator{
		risk:        map[string]*pb.FieldRiskScore{},
		riskErr:     map[string]error{},
		evaluations: map[string]int{},
		tenantSeen:  map[string]string{},
		seen:        map[string]bool{},
	}
}

func (e *fakeEvaluator) GetFieldRisk(ctx context.Context, fieldID string) (*pb.FieldRiskScore, error) {
	e.evaluations[fieldID]++
	e.tenantSeen[fieldID] = p9context.TenantID(ctx)
	if err, ok := e.riskErr[fieldID]; ok {
		return nil, err
	}
	r, ok := e.risk[fieldID]
	if !ok {
		return nil, errors.New("no risk configured for " + fieldID)
	}
	return r, nil
}

func (e *fakeEvaluator) RecordExternalAlert(_ context.Context, tenantID string, a *models.Alert) (*models.Alert, bool, error) {
	if e.recErr != nil {
		return nil, false, e.recErr
	}
	// Mirrors the repository's (source, source_alert_id) idempotency.
	key := tenantID + "|" + a.Source + "|" + a.SourceAlertID
	created := !e.seen[key]
	e.seen[key] = true
	if created {
		e.recorded = append(e.recorded, a)
		e.tenants = append(e.tenants, tenantID)
	}
	return a, created, nil
}

func risk(overall float64, factors map[string]float64) *pb.FieldRiskScore {
	return &pb.FieldRiskScore{OverallScore: overall, RiskFactors: factors}
}

func rule(id, tenant, field, metric, condition string, threshold float64) *models.AlertRule {
	return &models.AlertRule{
		ID:              id,
		TenantID:        tenant,
		FieldID:         field,
		FarmID:          "farm-1",
		Metric:          metric,
		Condition:       condition,
		Threshold:       threshold,
		Severity:        models.AlertSeverityWarning,
		Enabled:         true,
		CooldownMinutes: 60,
	}
}

func newTestScanner(t *testing.T, store RuleStore, eval Evaluator, now time.Time) *RuleScanner {
	t.Helper()
	return NewRuleScanner(store, eval, testutil.NopLogger{}, WithClock(func() time.Time { return now }))
}

var fixedNow = time.Date(2026, 3, 4, 11, 30, 0, 0, time.UTC)

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// The point of the whole package: a rule whose threshold is exceeded produces
// a stored alert. Before this, the scanner logged the exceedance and returned,
// so a farmer who configured a threshold was told nothing.
func TestExceededRuleRaisesAnAlert(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("rule-1", "tenant-a", "field-1", "water", "GT", 0.6),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.72, map[string]float64{"water": 0.81, "pest": 0.2})

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 1 {
		t.Fatalf("Scan raised %d alerts, want 1", got)
	}

	if len(eval.recorded) != 1 {
		t.Fatalf("stored %d alerts, want 1", len(eval.recorded))
	}
	a := eval.recorded[0]
	if a.FieldID != "field-1" || a.FarmID != "farm-1" {
		t.Errorf("alert is against field=%q farm=%q", a.FieldID, a.FarmID)
	}
	if a.Source != scannerSource {
		t.Errorf("Source = %q, want %q", a.Source, scannerSource)
	}
	if a.MetricValue != 0.81 || a.ThresholdValue != 0.6 {
		t.Errorf("metric/threshold = %v/%v, want 0.81/0.6", a.MetricValue, a.ThresholdValue)
	}
	if a.Status != models.AlertStatusActive {
		t.Errorf("Status = %q, want ACTIVE", a.Status)
	}
	if a.AlertType != models.AlertTypeWaterStress {
		t.Errorf("AlertType = %q, want WATER_STRESS from the water metric", a.AlertType)
	}
	// The whole risk picture rides along, not only the factor that tripped.
	if a.Metrics["pest"] != 0.2 || a.Metrics["overall"] != 0.72 {
		t.Errorf("Metrics = %v, want the other factors and the overall score", a.Metrics)
	}
	if eval.tenants[0] != "tenant-a" {
		t.Errorf("alert stored against tenant %q", eval.tenants[0])
	}

	// The firing is recorded, which is what the cooldown is read from.
	if len(store.touched) != 1 || store.touched[0].ruleID != "rule-1" ||
		store.touched[0].tenantID != "tenant-a" {
		t.Errorf("TouchRuleFired calls = %+v, want one for rule-1/tenant-a", store.touched)
	}
}

// A rule whose threshold is not met must not fire, and must not have its
// cooldown touched — touching it would push the next genuine firing out by a
// whole cooldown window.
func TestRuleBelowThresholdDoesNotFire(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("rule-1", "tenant-a", "field-1", "water", "GT", 0.6),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.2, map[string]float64{"water": 0.3})

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 0 {
		t.Fatalf("Scan raised %d alerts for a rule under its threshold", got)
	}
	if len(eval.recorded) != 0 {
		t.Errorf("stored %d alerts", len(eval.recorded))
	}
	if len(store.touched) != 0 {
		t.Errorf("cooldown touched for a rule that did not fire: %+v", store.touched)
	}
}

// A "less than" rule fires when the score is low, not when it is high.
//
// The old scanner compared every rule with `score >= rule.GetThreshold()`
// regardless of the condition the farmer chose, so an LT rule fired on exactly
// the fields that were fine and stayed silent on the ones that were not.
func TestConditionDirectionIsRespected(t *testing.T) {
	cases := []struct {
		condition string
		score     float64
		threshold float64
		want      bool
	}{
		{"GT", 0.7, 0.6, true},
		{"GT", 0.6, 0.6, false},
		{"GTE", 0.6, 0.6, true},
		{"LT", 0.3, 0.4, true},
		{"LT", 0.5, 0.4, false},
		{"LTE", 0.4, 0.4, true},
		{"<", 0.3, 0.4, true},
		{">=", 0.6, 0.6, true},
		{"", 0.7, 0.6, true}, // empty condition means the GT default
	}

	for _, tc := range cases {
		store := &fakeStore{due: []*models.AlertRule{
			rule("rule-1", "tenant-a", "field-1", "water", tc.condition, tc.threshold),
		}}
		eval := newFakeEvaluator()
		eval.risk["field-1"] = risk(0.5, map[string]float64{"water": tc.score})

		got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()) == 1
		if got != tc.want {
			t.Errorf("%q with score %v against threshold %v fired=%v, want %v",
				tc.condition, tc.score, tc.threshold, got, tc.want)
		}
	}
}

// An unrecognised condition is skipped rather than silently read as GT.
func TestUnknownConditionIsSkipped(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("rule-1", "tenant-a", "field-1", "water", "APPROXIMATELY", 0.6),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.9, map[string]float64{"water": 0.9})

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 0 {
		t.Fatalf("an unrecognised condition raised %d alerts; it must not be "+
			"defaulted to a comparison the farmer did not write", got)
	}
}

// A rule on a metric the evaluator does not produce is skipped, not treated as
// a score of zero — which an LT rule would read as a breach.
func TestMissingMetricIsSkipped(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("rule-1", "tenant-a", "field-1", "salinity", "LT", 0.4),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.5, map[string]float64{"water": 0.5})

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 0 {
		t.Fatalf("a rule on an unevaluated metric raised %d alerts", got)
	}
}

// Several rules on one field cost one risk evaluation, which is a gateway call.
func TestOneEvaluationPerField(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("r1", "tenant-a", "field-1", "water", "GT", 0.6),
		rule("r2", "tenant-a", "field-1", "pest", "GT", 0.5),
		rule("r3", "tenant-a", "field-1", "disease", "GT", 0.9),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.7, map[string]float64{"water": 0.8, "pest": 0.7, "disease": 0.1})

	raised := newTestScanner(t, store, eval, fixedNow).Scan(context.Background())
	if raised != 2 {
		t.Errorf("raised %d alerts, want 2 (water and pest over, disease under)", raised)
	}
	if eval.evaluations["field-1"] != 1 {
		t.Errorf("GetFieldRisk called %d times for one field", eval.evaluations["field-1"])
	}
}

// The scan has no request behind it, so each rule must be evaluated in a
// context carrying its own tenant. Without this every gateway call and every
// repository read would arrive with no tenant, and RLS would return nothing.
func TestEachFieldIsEvaluatedInItsOwnTenant(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("r1", "tenant-a", "field-a", "water", "GT", 0.1),
		rule("r2", "tenant-b", "field-b", "water", "GT", 0.1),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-a"] = risk(0.5, map[string]float64{"water": 0.5})
	eval.risk["field-b"] = risk(0.5, map[string]float64{"water": 0.5})

	newTestScanner(t, store, eval, fixedNow).Scan(context.Background())

	if eval.tenantSeen["field-a"] != "tenant-a" {
		t.Errorf("field-a evaluated with tenant %q", eval.tenantSeen["field-a"])
	}
	if eval.tenantSeen["field-b"] != "tenant-b" {
		t.Errorf("field-b evaluated with tenant %q", eval.tenantSeen["field-b"])
	}
	if len(eval.tenants) != 2 || eval.tenants[0] != "tenant-a" || eval.tenants[1] != "tenant-b" {
		t.Errorf("alerts stored against tenants %v", eval.tenants)
	}
}

// Two replicas sweeping the same rule in the same cooldown window produce the
// same idempotency key, so the second is deduplicated rather than doubling the
// alert in the farmer's list.
func TestConcurrentReplicasDeduplicate(t *testing.T) {
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.7, map[string]float64{"water": 0.8})

	for i := 0; i < 2; i++ {
		store := &fakeStore{due: []*models.AlertRule{
			rule("rule-1", "tenant-a", "field-1", "water", "GT", 0.6),
		}}
		newTestScanner(t, store, eval, fixedNow).Scan(context.Background())
	}

	if len(eval.recorded) != 1 {
		t.Errorf("two replicas stored %d alerts for one firing", len(eval.recorded))
	}
}

// Once the cooldown has elapsed the same rule raises a new alert, rather than
// deduplicating onto the first one for ever. Keying only on the rule id would
// mean a rule alerted exactly once in its life.
func TestFiringAgainAfterTheCooldownIsANewAlert(t *testing.T) {
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.7, map[string]float64{"water": 0.8})

	r := rule("rule-1", "tenant-a", "field-1", "water", "GT", 0.6)
	for _, at := range []time.Time{fixedNow, fixedNow.Add(2 * time.Hour)} {
		store := &fakeStore{due: []*models.AlertRule{r}}
		newTestScanner(t, store, eval, at).Scan(context.Background())
	}

	if len(eval.recorded) != 2 {
		t.Fatalf("stored %d alerts across two cooldown windows, want 2", len(eval.recorded))
	}
	if eval.recorded[0].SourceAlertID == eval.recorded[1].SourceAlertID {
		t.Errorf("both firings share source alert id %q", eval.recorded[0].SourceAlertID)
	}
	if !strings.HasPrefix(eval.recorded[0].SourceAlertID, "rule-1@") {
		t.Errorf("SourceAlertID = %q, want it keyed on the rule", eval.recorded[0].SourceAlertID)
	}
}

// A zero cooldown must not panic. time.Truncate(0) does.
func TestZeroCooldownDoesNotPanic(t *testing.T) {
	r := rule("rule-1", "tenant-a", "field-1", "water", "GT", 0.6)
	r.CooldownMinutes = 0

	store := &fakeStore{due: []*models.AlertRule{r}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.7, map[string]float64{"water": 0.8})

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 1 {
		t.Errorf("a rule with a zero cooldown raised %d alerts", got)
	}
}

// One field whose evaluation fails must not stop the fields behind it in the
// batch. A gateway hiccup on one field is not a reason to skip a frost warning
// on another.
func TestAFailedEvaluationDoesNotStopTheBatch(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("r1", "tenant-a", "broken-field", "water", "GT", 0.1),
		rule("r2", "tenant-a", "field-2", "water", "GT", 0.1),
	}}
	eval := newFakeEvaluator()
	eval.riskErr["broken-field"] = errors.New("gateway unavailable")
	eval.risk["field-2"] = risk(0.5, map[string]float64{"water": 0.5})

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 1 {
		t.Fatalf("raised %d alerts; the healthy field behind the failing one was skipped", got)
	}
	if eval.recorded[0].FieldID != "field-2" {
		t.Errorf("alert raised for %q", eval.recorded[0].FieldID)
	}
}

// A rule with no tenant cannot be acted on — there is nobody to show the alert
// to — and must be skipped rather than evaluated against an empty tenant.
func TestRulesWithoutATenantOrFieldAreSkipped(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("r1", "", "field-1", "water", "GT", 0.1),
		rule("r2", "tenant-a", "", "water", "GT", 0.1),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.5, map[string]float64{"water": 0.5})

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 0 {
		t.Fatalf("raised %d alerts from unusable rules", got)
	}
	if eval.evaluations["field-1"] != 0 {
		t.Errorf("a rule with no tenant still triggered a gateway call")
	}
}

// A store that cannot list is logged and the pass ends; it is not a panic and
// not a partial sweep against stale data.
func TestListFailureEndsThePassCleanly(t *testing.T) {
	store := &fakeStore{listErr: errors.New("database down")}
	eval := newFakeEvaluator()

	if got := newTestScanner(t, store, eval, fixedNow).Scan(context.Background()); got != 0 {
		t.Errorf("Scan reported %d alerts after a failed listing", got)
	}
}

// The rule's own alert type wins over the per-metric guess, because it is the
// only place the farmer's intent is recorded.
func TestConfiguredAlertTypeIsPreserved(t *testing.T) {
	r := rule("rule-1", "tenant-a", "field-1", "temperature", "GT", 0.6)
	r.AlertType = models.AlertTypeFrostRisk

	store := &fakeStore{due: []*models.AlertRule{r}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.7, map[string]float64{"temperature": 0.9})

	newTestScanner(t, store, eval, fixedNow).Scan(context.Background())

	if len(eval.recorded) != 1 {
		t.Fatalf("stored %d alerts", len(eval.recorded))
	}
	if eval.recorded[0].AlertType != models.AlertTypeFrostRisk {
		t.Errorf("AlertType = %q, want the rule's own FROST_RISK", eval.recorded[0].AlertType)
	}
}

// The batch limit is passed through, so one very large tenant cannot make a
// single pass run without end.
func TestBatchLimitIsApplied(t *testing.T) {
	var due []*models.AlertRule
	for i := 0; i < 10; i++ {
		// Distinct rule ids, or every alert shares one idempotency key and the
		// store deduplicates nine of them — which would be the repository
		// working, not the batch limit.
		id := "rule-" + string(rune('a'+i))
		due = append(due, rule(id, "tenant-a", "field-"+string(rune('a'+i)), "water", "GT", 0.1))
	}
	store := &fakeStore{due: due}
	eval := newFakeEvaluator()
	for i := 0; i < 10; i++ {
		eval.risk["field-"+string(rune('a'+i))] = risk(0.5, map[string]float64{"water": 0.5})
	}

	s := NewRuleScanner(store, eval, testutil.NopLogger{},
		WithClock(func() time.Time { return fixedNow }), WithBatchLimit(3))

	if got := s.Scan(context.Background()); got != 3 {
		t.Errorf("Scan raised %d alerts under a batch limit of 3", got)
	}
}

// A cancelled context stops the sweep rather than working through the rest of
// the batch during shutdown.
func TestCancelledContextStopsTheSweep(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("r1", "tenant-a", "field-1", "water", "GT", 0.1),
		rule("r2", "tenant-a", "field-2", "water", "GT", 0.1),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.5, map[string]float64{"water": 0.5})
	eval.risk["field-2"] = risk(0.5, map[string]float64{"water": 0.5})

	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	if got := newTestScanner(t, store, eval, fixedNow).Scan(ctx); got != 0 {
		t.Errorf("a cancelled scan raised %d alerts", got)
	}
}

// The message names the direction the rule was written in, so an LT rule does
// not tell the farmer their score is "above" a threshold it is under.
func TestMessageMatchesTheCondition(t *testing.T) {
	store := &fakeStore{due: []*models.AlertRule{
		rule("rule-1", "tenant-a", "field-1", "water", "LT", 0.4),
	}}
	eval := newFakeEvaluator()
	eval.risk["field-1"] = risk(0.2, map[string]float64{"water": 0.1})

	newTestScanner(t, store, eval, fixedNow).Scan(context.Background())

	if len(eval.recorded) != 1 {
		t.Fatalf("stored %d alerts", len(eval.recorded))
	}
	msg := eval.recorded[0].Message
	if !strings.Contains(msg, "below") {
		t.Errorf("message for an LT rule reads %q", msg)
	}
	if strings.Contains(msg, "above") {
		t.Errorf("message for an LT rule says the score is above the threshold: %q", msg)
	}
}
