package featureflags

import (
	"context"
	"fmt"
	"math"
	"sort"
	"sync"
	"time"
)

// Experiment tracking.
//
// The flag machinery already splits traffic between variants. What it could not
// do is tell you which variant was better, and a split with no readout is not
// an experiment — it is a coin flip nobody looked at.
//
// The hard part here is not the arithmetic. It is refusing to answer too early.
// A comparison of two variants will, by chance alone, cross any significance
// threshold at some point if you keep checking; the standard finding is roughly
// a one-in-five false positive rate for a test that is inspected repeatedly
// rather than once at a pre-declared sample size. Since a dashboard invites
// exactly that, this package carries the minimum sample and a peeking count on
// the result, and says plainly when a difference is not yet worth acting on.
//
// The other thing it refuses to do is average a ratio. "Yield per hectare" over
// a set of fields is the total yield over the total area, not the mean of each
// field's ratio — a half-hectare plot must not count as much as a twenty-hectare
// one. Recording the numerator and denominator separately is what makes that
// possible, and is why Outcome carries Weight.

// MinSamplesPerVariant is the default number of observations each variant needs
// before a difference is reported as significant.
//
// Not a statistically derived number — the right one depends on the effect size
// worth detecting and the variance of the metric — but a floor low enough to be
// reachable and high enough that the normal approximations below hold.
const MinSamplesPerVariant = 100

// Experiment declares what is being compared and how it will be judged.
type Experiment struct {
	// Name identifies the experiment.
	Name string `json:"name" yaml:"name"`
	// Flag is the multivariate flag that assigns variants.
	Flag string `json:"flag" yaml:"flag"`
	// Metric names what is being measured, for the readout.
	Metric string `json:"metric" yaml:"metric"`
	// Kind decides which test applies.
	Kind MetricKind `json:"kind" yaml:"kind"`
	// Control is the variant everything else is compared against.
	Control string `json:"control" yaml:"control"`
	// HigherIsBetter says which direction counts as a win. Stated up front
	// because deciding afterwards is how a regression becomes a success.
	HigherIsBetter bool `json:"higher_is_better" yaml:"higher_is_better"`
	// MinSamples per variant before significance is reported. Zero uses
	// MinSamplesPerVariant.
	MinSamples int `json:"min_samples" yaml:"min_samples"`
	// StartedAt and EndedAt bound the experiment. A zero EndedAt means it is
	// still running.
	StartedAt time.Time `json:"started_at" yaml:"started_at"`
	EndedAt   time.Time `json:"ended_at,omitempty" yaml:"ended_at,omitempty"`
}

// MetricKind selects the statistical test.
type MetricKind string

const (
	// MetricConversion is a yes/no outcome — the recommendation was accepted,
	// the alert was acted on. Compared with a two-proportion z-test.
	MetricConversion MetricKind = "conversion"
	// MetricContinuous is a measured quantity — yield, water used, days to
	// harvest. Compared with Welch's t-test, which does not assume the two
	// variants have equal variance. They rarely do: a treatment that changes
	// the mean usually changes the spread too.
	MetricContinuous MetricKind = "continuous"
)

// Assignment records that a subject was placed in a variant.
type Assignment struct {
	Experiment string    `json:"experiment"`
	Variant    string    `json:"variant"`
	Subject    string    `json:"subject"`
	TenantID   string    `json:"tenant_id,omitempty"`
	At         time.Time `json:"at"`
}

// Outcome records what happened to an assigned subject.
type Outcome struct {
	Experiment string `json:"experiment"`
	Subject    string `json:"subject"`
	// Value is the measurement. For a conversion metric, 0 or 1.
	Value float64 `json:"value"`
	// Weight is the denominator when the metric is a ratio — hectares, for
	// yield per hectare. Zero or one means unweighted.
	//
	// Without it a half-hectare plot counts as much as a twenty-hectare one,
	// and the average of per-field ratios is not the ratio anyone means.
	Weight float64   `json:"weight,omitempty"`
	At     time.Time `json:"at"`
}

// VariantStats summarises one arm.
type VariantStats struct {
	Variant string  `json:"variant"`
	N       int     `json:"n"`
	Mean    float64 `json:"mean"`
	StdDev  float64 `json:"std_dev"`
	Sum     float64 `json:"sum"`
	Weight  float64 `json:"weight"`
}

// Comparison is one variant measured against the control.
type Comparison struct {
	Variant string `json:"variant"`
	Control string `json:"control"`
	// Lift is the relative change against the control.
	Lift float64 `json:"lift"`
	// AbsoluteDiff is the change in the metric's own units.
	AbsoluteDiff float64 `json:"absolute_diff"`
	// PValue is the probability of seeing a difference at least this large if
	// the two variants were in truth identical.
	PValue float64 `json:"p_value"`
	// Significant is PValue below the threshold *and* enough samples. Both,
	// because a significant-looking result on forty observations is noise.
	Significant bool `json:"significant"`
	// Better says whether the variant beat the control, in the direction the
	// experiment declared at the start.
	Better bool `json:"better"`
	// Note explains a result that should not be acted on yet.
	Note string `json:"note,omitempty"`
}

// Analysis is the readout.
type Analysis struct {
	Experiment  string                  `json:"experiment"`
	Metric      string                  `json:"metric"`
	Kind        MetricKind              `json:"kind"`
	Variants    map[string]VariantStats `json:"variants"`
	Comparisons []Comparison            `json:"comparisons"`
	// Inspections counts how many times this experiment has been analysed.
	// Surfaced because repeated inspection is what turns a 5% false-positive
	// rate into something much larger, and the number is the only warning a
	// reader gets.
	Inspections int    `json:"inspections"`
	Warning     string `json:"warning,omitempty"`
}

// ExperimentTracker records assignments and outcomes and computes the readout.
//
// In memory, which is the right scope for a single instance and the wrong one
// for a fleet — assignments recorded on one replica are invisible to the
// others, so a fleet needs the same interface over a shared store. The analysis
// is separated from the storage for exactly that reason.
type ExperimentTracker struct {
	mu          sync.Mutex
	experiments map[string]Experiment
	assignments map[string]map[string]Assignment // experiment -> subject -> assignment
	outcomes    map[string]map[string]Outcome    // experiment -> subject -> outcome
	inspections map[string]int
	now         func() time.Time
}

// NewExperimentTracker creates an empty tracker.
func NewExperimentTracker() *ExperimentTracker {
	return &ExperimentTracker{
		experiments: map[string]Experiment{},
		assignments: map[string]map[string]Assignment{},
		outcomes:    map[string]map[string]Outcome{},
		inspections: map[string]int{},
		now:         time.Now,
	}
}

// Register declares an experiment.
func (t *ExperimentTracker) Register(e Experiment) error {
	if e.Name == "" {
		return fmt.Errorf("featureflags: experiment has no name")
	}
	if e.Control == "" {
		return fmt.Errorf("featureflags: experiment %q has no control variant", e.Name)
	}
	if e.Kind != MetricConversion && e.Kind != MetricContinuous {
		return fmt.Errorf("featureflags: experiment %q has unknown metric kind %q", e.Name, e.Kind)
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	if e.StartedAt.IsZero() {
		e.StartedAt = t.now()
	}
	t.experiments[e.Name] = e
	return nil
}

// Assign records a subject's variant.
//
// The first assignment wins. A subject that moves between variants mid-flight
// contributes to both arms and belongs in neither, which quietly corrupts the
// comparison rather than failing visibly.
func (t *ExperimentTracker) Assign(_ context.Context, a Assignment) error {
	if a.Experiment == "" || a.Subject == "" || a.Variant == "" {
		return fmt.Errorf("featureflags: assignment needs an experiment, subject and variant")
	}
	t.mu.Lock()
	defer t.mu.Unlock()

	if _, ok := t.experiments[a.Experiment]; !ok {
		return fmt.Errorf("featureflags: no experiment named %q", a.Experiment)
	}
	if t.assignments[a.Experiment] == nil {
		t.assignments[a.Experiment] = map[string]Assignment{}
	}
	if _, exists := t.assignments[a.Experiment][a.Subject]; exists {
		return nil
	}
	if a.At.IsZero() {
		a.At = t.now()
	}
	t.assignments[a.Experiment][a.Subject] = a
	return nil
}

// Record stores an outcome for an assigned subject.
//
// An outcome for a subject that was never assigned is rejected rather than
// counted, because it cannot be attributed to an arm — and silently dropping it
// into one would bias whichever arm it landed in.
func (t *ExperimentTracker) Record(_ context.Context, o Outcome) error {
	if o.Experiment == "" || o.Subject == "" {
		return fmt.Errorf("featureflags: outcome needs an experiment and subject")
	}
	if math.IsNaN(o.Value) || math.IsInf(o.Value, 0) {
		return fmt.Errorf("featureflags: outcome value is not a finite number")
	}
	t.mu.Lock()
	defer t.mu.Unlock()

	if _, ok := t.assignments[o.Experiment][o.Subject]; !ok {
		return fmt.Errorf("featureflags: subject %q has no assignment in experiment %q",
			o.Subject, o.Experiment)
	}
	if t.outcomes[o.Experiment] == nil {
		t.outcomes[o.Experiment] = map[string]Outcome{}
	}
	if o.At.IsZero() {
		o.At = t.now()
	}
	// Last write wins: an outcome that is revised — a yield corrected after
	// weighing — should replace the estimate, not be counted twice.
	t.outcomes[o.Experiment][o.Subject] = o
	return nil
}

// Analyse computes the readout at the given significance threshold.
//
// alpha of 0.05 is conventional. It is also the number that makes repeated
// inspection dangerous, which is why the inspection count comes back with the
// result.
func (t *ExperimentTracker) Analyse(experiment string, alpha float64) (*Analysis, error) {
	if alpha <= 0 || alpha >= 1 {
		alpha = 0.05
	}
	t.mu.Lock()
	exp, ok := t.experiments[experiment]
	if !ok {
		t.mu.Unlock()
		return nil, fmt.Errorf("featureflags: no experiment named %q", experiment)
	}
	t.inspections[experiment]++
	inspections := t.inspections[experiment]

	// Group outcomes by the arm their subject was assigned to.
	byVariant := map[string][]Outcome{}
	for subject, o := range t.outcomes[experiment] {
		a := t.assignments[experiment][subject]
		byVariant[a.Variant] = append(byVariant[a.Variant], o)
	}
	t.mu.Unlock()

	minSamples := exp.MinSamples
	if minSamples <= 0 {
		minSamples = MinSamplesPerVariant
	}

	analysis := &Analysis{
		Experiment:  exp.Name,
		Metric:      exp.Metric,
		Kind:        exp.Kind,
		Variants:    map[string]VariantStats{},
		Inspections: inspections,
	}
	for variant, outcomes := range byVariant {
		analysis.Variants[variant] = summarise(variant, outcomes)
	}
	if inspections > 1 {
		analysis.Warning = fmt.Sprintf(
			"analysed %d times; a threshold checked repeatedly is crossed by chance far more often than alpha suggests",
			inspections)
	}

	control, hasControl := analysis.Variants[exp.Control]
	if !hasControl {
		return analysis, nil
	}

	names := make([]string, 0, len(analysis.Variants))
	for name := range analysis.Variants {
		if name != exp.Control {
			names = append(names, name)
		}
	}
	sort.Strings(names) // stable output, so a report does not reshuffle

	for _, name := range names {
		analysis.Comparisons = append(analysis.Comparisons,
			compare(exp, control, analysis.Variants[name], alpha, minSamples))
	}
	return analysis, nil
}

// summarise computes the statistics for one arm.
func summarise(variant string, outcomes []Outcome) VariantStats {
	st := VariantStats{Variant: variant, N: len(outcomes)}
	if st.N == 0 {
		return st
	}

	var weighted bool
	for _, o := range outcomes {
		w := o.Weight
		if w > 0 {
			weighted = true
		} else {
			w = 1
		}
		st.Sum += o.Value
		st.Weight += w
	}

	if weighted {
		// A ratio metric: the mean is the total over the total, not the mean
		// of the per-subject ratios.
		st.Mean = st.Sum / st.Weight
	} else {
		st.Mean = st.Sum / float64(st.N)
	}

	// Sample standard deviation — n-1, because these are a sample of what the
	// variant would do, not the whole of it.
	if st.N > 1 {
		var ss float64
		for _, o := range outcomes {
			d := o.Value - st.Sum/float64(st.N)
			ss += d * d
		}
		st.StdDev = math.Sqrt(ss / float64(st.N-1))
	}
	return st
}

// compare tests one variant against the control.
func compare(exp Experiment, control, variant VariantStats, alpha float64, minSamples int) Comparison {
	c := Comparison{
		Variant:      variant.Variant,
		Control:      exp.Control,
		AbsoluteDiff: variant.Mean - control.Mean,
		PValue:       1,
	}
	if control.Mean != 0 {
		c.Lift = (variant.Mean - control.Mean) / math.Abs(control.Mean)
	}
	c.Better = (variant.Mean > control.Mean) == exp.HigherIsBetter && variant.Mean != control.Mean

	if control.N < minSamples || variant.N < minSamples {
		c.Note = fmt.Sprintf(
			"not enough data: %s has %d and %s has %d, %d needed per variant",
			exp.Control, control.N, variant.Variant, variant.N, minSamples)
		return c
	}

	switch exp.Kind {
	case MetricConversion:
		c.PValue = twoProportionP(control, variant)
	default:
		c.PValue = welchP(control, variant)
	}
	c.Significant = c.PValue < alpha

	if c.Significant && !c.Better {
		c.Note = "significant, but in the wrong direction for this experiment"
	}
	return c
}

// twoProportionP is the two-sided p-value of a two-proportion z-test.
func twoProportionP(a, b VariantStats) float64 {
	na, nb := float64(a.N), float64(b.N)
	if na == 0 || nb == 0 {
		return 1
	}
	pa, pb := a.Sum/na, b.Sum/nb

	// Pooled proportion under the null hypothesis that both arms convert at
	// the same rate.
	pooled := (a.Sum + b.Sum) / (na + nb)
	se := math.Sqrt(pooled * (1 - pooled) * (1/na + 1/nb))
	if se == 0 {
		// Both arms converted identically — including both at 0% or both at
		// 100%. There is no evidence of a difference.
		return 1
	}
	return twoSided(math.Abs(pa-pb) / se)
}

// welchP is the two-sided p-value of Welch's t-test.
//
// Welch rather than Student's because it does not assume equal variance, and
// two variants of a recommendation rarely have it: one that shifts the mean
// usually shifts the spread too. Approximated by the normal distribution,
// which is close enough once each arm has the minimum sample this package
// insists on.
func welchP(a, b VariantStats) float64 {
	na, nb := float64(a.N), float64(b.N)
	if na < 2 || nb < 2 {
		return 1
	}
	va, vb := a.StdDev*a.StdDev, b.StdDev*b.StdDev
	se := math.Sqrt(va/na + vb/nb)
	if se == 0 {
		return 1
	}
	return twoSided(math.Abs(a.Mean-b.Mean) / se)
}

// twoSided converts a z statistic into a two-sided p-value.
func twoSided(z float64) float64 {
	p := 2 * (1 - normalCDF(z))
	return math.Max(0, math.Min(1, p))
}

// normalCDF is the standard normal cumulative distribution, via erf.
func normalCDF(z float64) float64 {
	return 0.5 * (1 + math.Erf(z/math.Sqrt2))
}

// LogEvaluation lets the tracker sit behind the flag service's evaluation hook,
// so assignment is recorded wherever a flag is read rather than at call sites
// that have to remember to do it.
//
// Only multivariate results are recorded: a boolean flag has no arms to
// compare. Errors are swallowed on purpose — a failure to record an assignment
// must not fail the request that happened to evaluate the flag.
func (t *ExperimentTracker) LogEvaluation(ctx context.Context, result EvaluationResult, attrs Attributes) {
	if result.VariantKey == "" {
		return
	}
	subject := attrs["user_id"]
	if subject == "" {
		subject = attrs["tenant_id"]
	}
	if subject == "" {
		return
	}

	t.mu.Lock()
	var name string
	for _, exp := range t.experiments {
		if exp.Flag == result.FlagName && exp.EndedAt.IsZero() {
			name = exp.Name
			break
		}
	}
	t.mu.Unlock()
	if name == "" {
		return
	}

	_ = t.Assign(ctx, Assignment{
		Experiment: name,
		Variant:    result.VariantKey,
		Subject:    subject,
		TenantID:   attrs["tenant_id"],
	})
}

var _ EvaluationLogger = (*ExperimentTracker)(nil)
