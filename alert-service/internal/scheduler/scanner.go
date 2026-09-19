// Package scheduler evaluates user-configured alert rules on a timer and
// raises alerts for the ones whose threshold is exceeded.
//
// Everything else in this service is reactive: something happens elsewhere,
// an event arrives, an alert is stored. Rules are the one path where the
// farmer states a condition in advance — "tell me when this field's water risk
// goes above 0.6" — and nothing else in the system goes looking for it. Three
// web routes and a mobile screen write these rules; until this package was
// wired, nothing read them, so a rule was a row that never did anything.
//
// The scan enumerates *rules*, not fields. Enumerating fields would need a
// cross-tenant listing from field-service, which does not exist, and would
// evaluate every field on every pass whether or not anybody had asked a
// question about it. Rules are the thing somebody configured, so they are the
// thing worth the gateway call.
package scheduler

import (
	"context"
	"fmt"
	"math"
	"strings"
	"time"

	pb "p9e.in/samavaya/agriculture/alert-service/api/v1"
	"p9e.in/samavaya/agriculture/alert-service/internal/models"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"
)

// scannerSource names the scanner against the alerts it raises. It is half of
// the idempotency key, so it must stay stable: changing it makes every alert
// already stored under the old name look like a different alert.
const scannerSource = "alert-service/scanner"

// Defaults for a scanner constructed without explicit options.
const (
	// DefaultInterval is how often the rule set is swept.
	//
	// Five minutes rather than one: a risk score is derived from weather and
	// imagery that move on the scale of hours, so a faster sweep would spend
	// gateway calls re-deriving the same number, and the rules' own cooldowns
	// (an hour by default) mean nothing would come of it anyway.
	DefaultInterval = 5 * time.Minute

	// DefaultBatchLimit caps how many due rules one pass will look at, so a
	// tenant with a very large rule set cannot make one pass run indefinitely.
	// Anything left over is picked up by the next pass, in the same order.
	DefaultBatchLimit = 500
)

// RuleStore is the slice of repositories.AlertRepository the scanner uses.
//
// Narrowed to two methods so the scan loop can be tested without a database:
// the interesting behaviour here is which rules fire and what alert they
// produce, and neither of those is a question about SQL.
type RuleStore interface {
	ListDueRules(ctx context.Context, now time.Time, limit int) ([]*models.AlertRule, error)
	TouchRuleFired(ctx context.Context, tenantID, id string, at time.Time) error
}

// Evaluator is the slice of services.AlertService the scanner uses.
type Evaluator interface {
	GetFieldRisk(ctx context.Context, fieldID string) (*pb.FieldRiskScore, error)
	RecordExternalAlert(ctx context.Context, tenantID string, a *models.Alert) (*models.Alert, bool, error)
}

// RuleScanner evaluates due alert rules and raises alerts for the ones whose
// threshold is met.
type RuleScanner struct {
	store      RuleStore
	eval       Evaluator
	logger     *p9log.Helper
	batchLimit int

	// now is injectable so tests can control the cooldown bucket rather than
	// sleep through it.
	now func() time.Time
}

// Option configures a RuleScanner.
type Option func(*RuleScanner)

// WithBatchLimit caps how many due rules a single pass considers.
func WithBatchLimit(n int) Option {
	return func(s *RuleScanner) {
		if n > 0 {
			s.batchLimit = n
		}
	}
}

// WithClock replaces the scanner's clock. For tests.
func WithClock(now func() time.Time) Option {
	return func(s *RuleScanner) {
		if now != nil {
			s.now = now
		}
	}
}

// NewRuleScanner creates a scanner over the given store and evaluator.
func NewRuleScanner(store RuleStore, eval Evaluator, logger p9log.Logger, opts ...Option) *RuleScanner {
	s := &RuleScanner{
		store:      store,
		eval:       eval,
		logger:     p9log.NewHelper(p9log.With(logger, "component", "RuleScanner")),
		batchLimit: DefaultBatchLimit,
		now:        func() time.Time { return time.Now().UTC() },
	}
	for _, o := range opts {
		o(s)
	}
	return s
}

// Run sweeps the rule set every interval until ctx is cancelled.
//
// The first sweep waits for the ticker rather than running immediately. A
// deployment restarting several replicas at once would otherwise have all of
// them evaluate the same rules in the same second; the cooldown in the
// database means only one alert survives, but the gateway still takes the
// whole fan-out.
func (s *RuleScanner) Run(ctx context.Context, interval time.Duration) {
	if interval <= 0 {
		interval = DefaultInterval
	}
	s.logger.Infow("msg", "rule scanner started", "interval", interval.String(),
		"batch_limit", s.batchLimit)

	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			s.logger.Infow("msg", "rule scanner stopped", "reason", ctx.Err())
			return
		case <-ticker.C:
			s.Scan(ctx)
		}
	}
}

// Scan performs one pass and reports how many alerts it raised.
func (s *RuleScanner) Scan(ctx context.Context) int {
	now := s.now()

	rules, err := s.store.ListDueRules(ctx, now, s.batchLimit)
	if err != nil {
		s.logger.Errorw("msg", "could not list due rules", "error", err)
		return 0
	}
	if len(rules) == 0 {
		return 0
	}

	raised := 0
	for _, group := range groupByField(rules) {
		if ctx.Err() != nil {
			return raised
		}
		raised += s.evaluateField(ctx, group, now)
	}

	s.logger.Infow("msg", "rule scan complete",
		"rules", len(rules), "alerts_raised", raised)
	return raised
}

// fieldGroup is the set of rules configured against one field, which share one
// risk evaluation.
type fieldGroup struct {
	tenantID string
	fieldID  string
	rules    []*models.AlertRule
}

// groupByField collects rules per (tenant, field) so that a field with six
// rules on it costs one gateway call rather than six. The repository already
// orders by tenant then field, so this walks rather than sorts, and the
// resulting order is the query's order — which is what makes a truncated batch
// resumable on the next pass.
func groupByField(rules []*models.AlertRule) []fieldGroup {
	var out []fieldGroup
	index := make(map[string]int, len(rules))

	for _, r := range rules {
		if r == nil || strings.TrimSpace(r.TenantID) == "" || strings.TrimSpace(r.FieldID) == "" {
			continue
		}
		key := r.TenantID + "\x00" + r.FieldID
		if i, ok := index[key]; ok {
			out[i].rules = append(out[i].rules, r)
			continue
		}
		index[key] = len(out)
		out = append(out, fieldGroup{tenantID: r.TenantID, fieldID: r.FieldID, rules: []*models.AlertRule{r}})
	}
	return out
}

// evaluateField scores one field once and tests every rule on it.
func (s *RuleScanner) evaluateField(ctx context.Context, g fieldGroup, now time.Time) int {
	// The scan has no request behind it, so there is no tenant to inherit.
	// Building one explicitly per group is what lets the repository's RLS
	// scope and the AI client's tenant header agree with the rule being
	// evaluated.
	tctx := tenantContext(ctx, g.tenantID)

	risk, err := s.eval.GetFieldRisk(tctx, g.fieldID)
	if err != nil {
		// Logged and skipped, not retried: the next pass will try again, and
		// a field whose gateway call is failing should not stop the fields
		// behind it in the batch from being evaluated.
		s.logger.Warnw("msg", "field risk evaluation failed; skipping field",
			"tenant_id", g.tenantID, "field_id", g.fieldID, "error", err)
		return 0
	}

	factors := risk.GetRiskFactors()
	raised := 0

	for _, rule := range g.rules {
		score, present := factors[rule.Metric]
		if !present {
			// A rule on a metric the evaluator does not produce is a
			// configuration mistake — a typo, or a metric that was removed —
			// and silently treating a missing score as zero would make the
			// rule look like it was passing.
			s.logger.Warnw("msg", "rule metric is not among the evaluated risk factors",
				"tenant_id", g.tenantID, "field_id", g.fieldID,
				"rule_id", rule.ID, "metric", rule.Metric)
			continue
		}

		triggered, ok := conditionMet(rule.Condition, score, rule.Threshold)
		if !ok {
			s.logger.Warnw("msg", "rule has an unrecognised condition; skipping",
				"rule_id", rule.ID, "condition", rule.Condition)
			continue
		}
		if !triggered {
			continue
		}

		if s.raise(tctx, g, rule, score, risk, now) {
			raised++
		}
	}
	return raised
}

// raise stores the alert and records the firing. Reports whether a new alert
// was created.
func (s *RuleScanner) raise(
	ctx context.Context,
	g fieldGroup,
	rule *models.AlertRule,
	score float64,
	risk *pb.FieldRiskScore,
	now time.Time,
) bool {
	alert := &models.Alert{
		ID:             ulid.NewString(),
		FieldID:        rule.FieldID,
		FarmID:         rule.FarmID,
		AlertType:      alertTypeFor(rule),
		Severity:       severityFor(rule),
		Status:         models.AlertStatusActive,
		Title:          ruleTitle(rule.Metric),
		Message:        ruleMessage(rule.Metric, rule.Condition, score, rule.Threshold),
		Source:         scannerSource,
		SourceAlertID:  sourceAlertID(rule, now),
		MetricValue:    score,
		ThresholdValue: rule.Threshold,
		Metrics:        metricsOf(risk),
		CreatedAt:      now,
	}

	_, created, err := s.eval.RecordExternalAlert(ctx, g.tenantID, alert)
	if err != nil {
		s.logger.Errorw("msg", "could not store rule alert",
			"tenant_id", g.tenantID, "rule_id", rule.ID, "error", err)
		return false
	}

	// Touched whether or not the row was new. A duplicate means another
	// replica raised the same alert in the same window; not recording the
	// firing here would leave this replica's view of the cooldown unset and
	// make it try again on the very next pass.
	if err := s.store.TouchRuleFired(ctx, g.tenantID, rule.ID, now); err != nil {
		s.logger.Errorw("msg", "alert stored but cooldown not recorded",
			"tenant_id", g.tenantID, "rule_id", rule.ID, "error", err)
	}

	if !created {
		return false
	}

	s.logger.Infow("msg", "rule alert raised",
		"tenant_id", g.tenantID, "field_id", rule.FieldID, "rule_id", rule.ID,
		"metric", rule.Metric, "score", score, "threshold", rule.Threshold)
	return true
}

// ---------------------------------------------------------------------------

// tenantContext gives a background pass the tenant a request would have
// carried. Mirrors weather-service's equivalent, deliberately: both are
// background jobs acting for a tenant nobody authenticated as.
func tenantContext(ctx context.Context, tenantID string) context.Context {
	if p9context.TenantID(ctx) != tenantID {
		ctx = p9context.NewUserContext(ctx, p9context.UserContext{UserID: "system", TenantID: tenantID})
	}
	ctx = p9context.NewCurrentTenant(ctx, tenantID, "")
	return p9context.NewRLSScopeTenantOnly(ctx, tenantID)
}

// conditionMet compares a score against a threshold. The second return is
// false when the condition is not one this service understands.
//
// An unknown condition is reported rather than defaulted to "greater than".
// Defaulting would evaluate a rule the farmer wrote as LT in the opposite
// direction, which fires on exactly the fields that are fine and stays quiet
// on the ones that are not.
func conditionMet(condition string, score, threshold float64) (bool, bool) {
	switch strings.ToUpper(strings.TrimSpace(condition)) {
	case "", "GT", ">":
		return score > threshold, true
	case "GTE", "GE", ">=":
		return score >= threshold, true
	case "LT", "<":
		return score < threshold, true
	case "LTE", "LE", "<=":
		return score <= threshold, true
	case "EQ", "==", "=":
		return nearlyEqual(score, threshold), true
	case "NEQ", "NE", "!=", "<>":
		return !nearlyEqual(score, threshold), true
	default:
		return false, false
	}
}

// nearlyEqual compares two risk scores for equality.
//
// Exact float equality on a number that arrived through JSON and a threshold
// somebody typed into a form will essentially never hold, so an EQ rule
// written with == would never fire. Risk scores live in [0,1], so a fixed
// epsilon is meaningful here in a way a relative one would not be.
func nearlyEqual(a, b float64) bool {
	return math.Abs(a-b) < 1e-9
}

// sourceAlertID is the idempotency key for one firing of one rule.
//
// It is the rule plus the cooldown window it fired in. Two replicas sweeping
// at the same moment produce the same key and the second is deduped by the
// repository; a firing after the cooldown has elapsed falls in a later window
// and produces a new alert, which is the whole point of the cooldown expiring.
//
// Keying on the rule alone would mean the rule raised exactly one alert ever.
// Keying on the timestamp would mean two replicas raise two alerts.
func sourceAlertID(rule *models.AlertRule, now time.Time) string {
	window := time.Duration(rule.CooldownMinutes) * time.Minute
	if window < time.Minute {
		// A zero cooldown is "fire every pass", not "fire continuously": the
		// window still has to be non-zero or Truncate panics, and a minute is
		// below any sweep interval worth running.
		window = time.Minute
	}
	return fmt.Sprintf("%s@%d", rule.ID, now.UTC().Truncate(window).Unix())
}

// alertTypeFor picks the type to store against a rule's alert.
//
// The rule's own alert_type wins when it is set and recognised, because it is
// the only place the farmer's intent is recorded. The per-metric fallback is a
// guess and is marked as such: a "temperature" risk factor does not say
// whether the field is too cold or too hot, so the fallback for it is the
// generic growth anomaly rather than a coin flip between frost and heat.
func alertTypeFor(rule *models.AlertRule) models.AlertType {
	if rule.AlertType.IsValid() {
		return rule.AlertType
	}
	switch strings.ToLower(rule.Metric) {
	case "water":
		return models.AlertTypeWaterStress
	case "pest":
		return models.AlertTypePestOutbreak
	case "disease":
		return models.AlertTypeDiseaseDetected
	case "nutrient":
		return models.AlertTypeNutrientDeficiency
	case "growth", "temperature":
		return models.AlertTypeGrowthAnomaly
	default:
		return models.AlertTypeGrowthAnomaly
	}
}

func severityFor(rule *models.AlertRule) models.AlertSeverity {
	if rule.Severity.IsValid() {
		return rule.Severity
	}
	return models.AlertSeverityWarning
}

// metricsOf carries the whole risk picture onto the alert, not just the factor
// that tripped. A farmer told their water risk is high is better served
// knowing at the same time that the pest risk is also climbing.
func metricsOf(risk *pb.FieldRiskScore) map[string]float64 {
	out := make(map[string]float64, len(risk.GetRiskFactors())+1)
	for k, v := range risk.GetRiskFactors() {
		out[k] = v
	}
	out["overall"] = risk.GetOverallScore()
	return out
}

// metricLabels give the stored alert a title a person can read. A metric with
// no entry falls back to its own name rather than to something generic, so a
// metric added to the evaluator later still produces a usable alert.
var metricLabels = map[string]string{
	"temperature": "Temperature risk",
	"water":       "Water risk",
	"pest":        "Pest risk",
	"disease":     "Disease risk",
	"nutrient":    "Nutrient risk",
	"growth":      "Growth risk",
}

func metricLabel(metric string) string {
	if l, ok := metricLabels[strings.ToLower(metric)]; ok {
		return l
	}
	if metric == "" {
		return "Field risk"
	}
	return metric
}

func ruleTitle(metric string) string {
	return metricLabel(metric) + " threshold reached"
}

func ruleMessage(metric, condition string, score, threshold float64) string {
	return fmt.Sprintf("%s is %.2f, %s the configured threshold of %.2f.",
		metricLabel(metric), score, conditionPhrase(condition), threshold)
}

func conditionPhrase(condition string) string {
	switch strings.ToUpper(strings.TrimSpace(condition)) {
	case "LT", "<":
		return "below"
	case "LTE", "LE", "<=":
		return "at or below"
	case "GTE", "GE", ">=":
		return "at or above"
	case "EQ", "==", "=":
		return "equal to"
	case "NEQ", "NE", "!=", "<>":
		return "different from"
	default:
		return "above"
	}
}
