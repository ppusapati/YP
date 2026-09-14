package featureflags

import (
	"context"
	"math"
	"testing"
)

// The arithmetic is checked against known values, but the tests that matter
// are the ones about refusing to answer: too few samples, no difference, a
// difference in the wrong direction.

func conversionExperiment(minSamples int) Experiment {
	return Experiment{
		Name: "crop-rec", Flag: "crop_recommendation_model", Metric: "accepted",
		Kind: MetricConversion, Control: "v1", HigherIsBetter: true, MinSamples: minSamples,
	}
}

func continuousExperiment(minSamples int) Experiment {
	return Experiment{
		Name: "irrigation", Flag: "enhanced_irrigation", Metric: "yield_t_per_ha",
		Kind: MetricContinuous, Control: "current", HigherIsBetter: true, MinSamples: minSamples,
	}
}

// fill assigns n subjects to a variant and records an outcome for each.
func fill(t *testing.T, tr *ExperimentTracker, exp, variant string, values []float64) {
	t.Helper()
	ctx := context.Background()
	for i, v := range values {
		subject := variant + "-" + itoa(i)
		if err := tr.Assign(ctx, Assignment{Experiment: exp, Variant: variant, Subject: subject}); err != nil {
			t.Fatalf("Assign: %v", err)
		}
		if err := tr.Record(ctx, Outcome{Experiment: exp, Subject: subject, Value: v}); err != nil {
			t.Fatalf("Record: %v", err)
		}
	}
}

// conversions builds n outcomes of which k are 1.
func conversions(n, k int) []float64 {
	out := make([]float64, n)
	for i := 0; i < k; i++ {
		out[i] = 1
	}
	return out
}

func analyse(t *testing.T, tr *ExperimentTracker, name string) *Analysis {
	t.Helper()
	a, err := tr.Analyse(name, 0.05)
	if err != nil {
		t.Fatalf("Analyse: %v", err)
	}
	return a
}

func only(t *testing.T, a *Analysis) Comparison {
	t.Helper()
	if len(a.Comparisons) != 1 {
		t.Fatalf("got %d comparisons, want 1", len(a.Comparisons))
	}
	return a.Comparisons[0]
}

// ── refusing to answer ──────────────────────────────────────────────────────

func TestASmallSampleIsNotSignificantHoweverStarkTheDifference(t *testing.T) {
	// Ten out of ten against nought out of ten looks decisive and is not. This
	// is the single most useful thing this package does.
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(100)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	fill(t, tr, "crop-rec", "v1", conversions(10, 0))
	fill(t, tr, "crop-rec", "v2", conversions(10, 10))

	c := only(t, analyse(t, tr, "crop-rec"))
	if c.Significant {
		t.Error("reported significance on ten observations per arm")
	}
	if c.Note == "" {
		t.Error("no explanation of why the result should not be acted on")
	}
}

func TestIdenticalVariantsAreNotSignificant(t *testing.T) {
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(50)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	fill(t, tr, "crop-rec", "v1", conversions(400, 120))
	fill(t, tr, "crop-rec", "v2", conversions(400, 120))

	c := only(t, analyse(t, tr, "crop-rec"))
	if c.Significant {
		t.Errorf("identical arms reported significant, p=%v", c.PValue)
	}
	if c.PValue < 0.9 {
		t.Errorf("p-value %v for identical arms; should be near 1", c.PValue)
	}
}

func TestRepeatedInspectionIsSurfaced(t *testing.T) {
	// A threshold checked repeatedly is crossed by chance far more often than
	// alpha suggests, and a dashboard invites exactly that.
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(50)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	fill(t, tr, "crop-rec", "v1", conversions(100, 30))
	fill(t, tr, "crop-rec", "v2", conversions(100, 35))

	first := analyse(t, tr, "crop-rec")
	if first.Warning != "" {
		t.Error("warned on the first inspection")
	}
	third := analyse(t, tr, "crop-rec")
	third = analyse(t, tr, "crop-rec")
	if third.Inspections != 3 {
		t.Errorf("inspections %d, want 3", third.Inspections)
	}
	if third.Warning == "" {
		t.Error("repeated inspection was not surfaced")
	}
}

func TestASignificantRegressionIsNotReportedAsAWin(t *testing.T) {
	// The direction is declared up front, because deciding afterwards is how a
	// regression becomes a success.
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(50)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	fill(t, tr, "crop-rec", "v1", conversions(500, 250)) // 50%
	fill(t, tr, "crop-rec", "v2", conversions(500, 150)) // 30%

	c := only(t, analyse(t, tr, "crop-rec"))
	if !c.Significant {
		t.Fatalf("a 20-point drop over 500 each was not significant, p=%v", c.PValue)
	}
	if c.Better {
		t.Error("a regression was reported as better")
	}
	if c.Note == "" {
		t.Error("a significant regression carried no note")
	}
}

// ── the arithmetic ──────────────────────────────────────────────────────────

func TestALargeConversionDifferenceIsSignificant(t *testing.T) {
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(50)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	fill(t, tr, "crop-rec", "v1", conversions(500, 150)) // 30%
	fill(t, tr, "crop-rec", "v2", conversions(500, 250)) // 50%

	c := only(t, analyse(t, tr, "crop-rec"))
	if !c.Significant {
		t.Errorf("p=%v for a 20-point difference over 500 each", c.PValue)
	}
	if !c.Better {
		t.Error("the better arm was not reported as better")
	}
	// 0.50 against 0.30 is a lift of two thirds.
	if math.Abs(c.Lift-0.6667) > 0.01 {
		t.Errorf("lift %.4f, want about 0.667", c.Lift)
	}
}

func TestTwoProportionMatchesAKnownValue(t *testing.T) {
	// 60/200 against 80/200: pooled p = 0.35, se = sqrt(0.35*0.65*(1/200+1/200))
	// = 0.047697, z = 0.1/0.047697 = 2.0966, two-sided p ≈ 0.0360.
	a := VariantStats{N: 200, Sum: 60}
	b := VariantStats{N: 200, Sum: 80}
	got := twoProportionP(a, b)
	if math.Abs(got-0.0360) > 0.001 {
		t.Errorf("p = %.4f, want about 0.0360", got)
	}
}

func TestWelchMatchesAKnownValue(t *testing.T) {
	// Means 5.0 and 5.5, sd 1.0 each, n = 100 each.
	// se = sqrt(1/100 + 1/100) = 0.141421, z = 0.5/0.141421 = 3.5355,
	// two-sided p ≈ 0.000407.
	a := VariantStats{N: 100, Mean: 5.0, StdDev: 1.0}
	b := VariantStats{N: 100, Mean: 5.5, StdDev: 1.0}
	got := welchP(a, b)
	if math.Abs(got-0.000407) > 0.0001 {
		t.Errorf("p = %.6f, want about 0.000407", got)
	}
}

func TestWelchDoesNotAssumeEqualVariance(t *testing.T) {
	// The same difference in means is far less convincing when one arm is much
	// noisier. Student's t pooled would understate that.
	tight := welchP(
		VariantStats{N: 200, Mean: 10, StdDev: 1},
		VariantStats{N: 200, Mean: 11, StdDev: 1})
	noisy := welchP(
		VariantStats{N: 200, Mean: 10, StdDev: 1},
		VariantStats{N: 200, Mean: 11, StdDev: 10})
	if !(noisy > tight) {
		t.Errorf("p was %v with a noisy arm and %v with a tight one; variance is being ignored", noisy, tight)
	}
}

func TestIdenticalProportionsGiveNoEvidence(t *testing.T) {
	// Both arms at 0% or both at 100% make the standard error zero. Dividing
	// by it would give an infinite z and a p-value of 0 — "certainly
	// different" from two arms that behaved identically.
	for _, k := range []int{0, 100} {
		got := twoProportionP(VariantStats{N: 100, Sum: float64(k)},
			VariantStats{N: 100, Sum: float64(k)})
		if got != 1 {
			t.Errorf("p = %v for two arms both at %d/100, want 1", got, k)
		}
	}
}

// ── weighted metrics ────────────────────────────────────────────────────────

func TestAWeightedMetricIsARatioOfTotalsNotAMeanOfRatios(t *testing.T) {
	// Yield per hectare over a set of fields is the total yield over the total
	// area. A half-hectare plot must not count as much as a twenty-hectare one.
	//
	// 100 t over 20 ha and 4 t over 0.5 ha: the ratio of totals is
	// 104/20.5 = 5.07 t/ha. The mean of the per-field ratios would be
	// (5 + 8) / 2 = 6.5, which no field achieved on any meaningful acreage.
	tr := NewExperimentTracker()
	if err := tr.Register(continuousExperiment(1)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	ctx := context.Background()
	for i, o := range []Outcome{
		{Subject: "big", Value: 100, Weight: 20},
		{Subject: "small", Value: 4, Weight: 0.5},
	} {
		_ = i
		if err := tr.Assign(ctx, Assignment{Experiment: "irrigation", Variant: "current", Subject: o.Subject}); err != nil {
			t.Fatalf("Assign: %v", err)
		}
		o.Experiment = "irrigation"
		if err := tr.Record(ctx, o); err != nil {
			t.Fatalf("Record: %v", err)
		}
	}

	stats := analyse(t, tr, "irrigation").Variants["current"]
	if math.Abs(stats.Mean-104.0/20.5) > 0.001 {
		t.Errorf("mean %.4f, want the ratio of totals %.4f", stats.Mean, 104.0/20.5)
	}
}

// ── bookkeeping ─────────────────────────────────────────────────────────────

func TestASubjectKeepsItsFirstVariant(t *testing.T) {
	// A subject that moves between arms contributes to both and belongs in
	// neither, which corrupts the comparison quietly rather than failing.
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(1)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	ctx := context.Background()
	for _, v := range []string{"v1", "v2", "v3"} {
		if err := tr.Assign(ctx, Assignment{Experiment: "crop-rec", Variant: v, Subject: "s-1"}); err != nil {
			t.Fatalf("Assign: %v", err)
		}
	}
	if err := tr.Record(ctx, Outcome{Experiment: "crop-rec", Subject: "s-1", Value: 1}); err != nil {
		t.Fatalf("Record: %v", err)
	}

	a := analyse(t, tr, "crop-rec")
	if len(a.Variants) != 1 || a.Variants["v1"].N != 1 {
		t.Errorf("variants %v, want the subject only in v1", a.Variants)
	}
}

func TestAnUnassignedOutcomeIsRejected(t *testing.T) {
	// It cannot be attributed to an arm, and dropping it into one would bias
	// that arm.
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(1)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	err := tr.Record(context.Background(), Outcome{Experiment: "crop-rec", Subject: "nobody", Value: 1})
	if err == nil {
		t.Error("an outcome for an unassigned subject was accepted")
	}
}

func TestARevisedOutcomeReplacesTheOriginal(t *testing.T) {
	// A yield corrected after weighing should replace the estimate, not be
	// counted twice.
	tr := NewExperimentTracker()
	if err := tr.Register(continuousExperiment(1)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	ctx := context.Background()
	if err := tr.Assign(ctx, Assignment{Experiment: "irrigation", Variant: "current", Subject: "f-1"}); err != nil {
		t.Fatalf("Assign: %v", err)
	}
	for _, v := range []float64{4.0, 4.8} {
		if err := tr.Record(ctx, Outcome{Experiment: "irrigation", Subject: "f-1", Value: v}); err != nil {
			t.Fatalf("Record: %v", err)
		}
	}

	stats := analyse(t, tr, "irrigation").Variants["current"]
	if stats.N != 1 {
		t.Errorf("N = %d after a revision, want 1", stats.N)
	}
	if stats.Mean != 4.8 {
		t.Errorf("mean %v, want the revised value", stats.Mean)
	}
}

func TestANonFiniteOutcomeIsRejected(t *testing.T) {
	// One NaN makes every statistic downstream NaN, and the readout would say
	// nothing while looking like it had.
	tr := NewExperimentTracker()
	if err := tr.Register(continuousExperiment(1)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	ctx := context.Background()
	if err := tr.Assign(ctx, Assignment{Experiment: "irrigation", Variant: "current", Subject: "f-1"}); err != nil {
		t.Fatalf("Assign: %v", err)
	}
	for _, v := range []float64{math.NaN(), math.Inf(1)} {
		if err := tr.Record(ctx, Outcome{Experiment: "irrigation", Subject: "f-1", Value: v}); err == nil {
			t.Errorf("accepted a non-finite outcome %v", v)
		}
	}
}

func TestRegisterRejectsAnIncompleteExperiment(t *testing.T) {
	tr := NewExperimentTracker()
	cases := []Experiment{
		{Control: "v1", Kind: MetricConversion},                   // no name
		{Name: "e", Kind: MetricConversion},                       // no control
		{Name: "e", Control: "v1"},                                // no kind
		{Name: "e", Control: "v1", Kind: MetricKind("guesswork")}, // unknown kind
	}
	for i, e := range cases {
		if err := tr.Register(e); err == nil {
			t.Errorf("case %d: accepted %+v", i, e)
		}
	}
}

func TestComparisonsAreOrderedStably(t *testing.T) {
	// A report that reshuffles between reads is hard to trust and harder to
	// diff.
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(1)); err != nil {
		t.Fatalf("Register: %v", err)
	}
	for _, v := range []string{"v1", "v4", "v2", "v3"} {
		fill(t, tr, "crop-rec", v, conversions(5, 2))
	}
	for run := 0; run < 5; run++ {
		a := analyse(t, tr, "crop-rec")
		got := []string{a.Comparisons[0].Variant, a.Comparisons[1].Variant, a.Comparisons[2].Variant}
		want := []string{"v2", "v3", "v4"}
		for i := range want {
			if got[i] != want[i] {
				t.Fatalf("run %d: order %v, want %v", run, got, want)
			}
		}
	}
}

// ── the flag-service hook ───────────────────────────────────────────────────

func TestAssignmentIsRecordedFromAFlagEvaluation(t *testing.T) {
	// Assignment happens wherever the flag is read, rather than at call sites
	// that have to remember to do it.
	tr := NewExperimentTracker()
	if err := tr.Register(conversionExperiment(1)); err != nil {
		t.Fatalf("Register: %v", err)
	}

	svc := NewInMemoryFlagService(WithEvaluationLogger(tr))
	svc.SetFlag(Flag{
		Name: "crop_recommendation_model", Type: FlagTypeMultivariate, Enabled: true,
		DefaultVariant: "v1",
		Variants:       []Variant{{Key: "v1", Weight: 50}, {Key: "v2", Weight: 50}},
	})

	ctx := context.Background()
	svc.GetVariant(ctx, "crop_recommendation_model", Attributes{"user_id": "u-1", "tenant_id": "t-1"})

	a := analyse(t, tr, "crop-rec")
	total := 0
	for _, s := range a.Variants {
		total += s.N
	}
	// No outcome recorded yet, so the arms are empty — but the assignment must
	// exist, or the outcome would later be rejected.
	if err := tr.Record(ctx, Outcome{Experiment: "crop-rec", Subject: "u-1", Value: 1}); err != nil {
		t.Errorf("the flag evaluation did not record an assignment: %v", err)
	}
	_ = total
}

func TestABooleanFlagCreatesNoAssignment(t *testing.T) {
	// A flag with no variants has no arms to compare.
	tr := NewExperimentTracker()
	if err := tr.Register(Experiment{
		Name: "bool-exp", Flag: "new_dashboard_ui", Control: "off",
		Kind: MetricConversion, MinSamples: 1,
	}); err != nil {
		t.Fatalf("Register: %v", err)
	}

	svc := NewInMemoryFlagService(WithEvaluationLogger(tr))
	svc.SetFlag(Flag{Name: "new_dashboard_ui", Type: FlagTypeBoolean, Enabled: true})
	svc.GetVariant(context.Background(), "new_dashboard_ui", Attributes{"user_id": "u-1"})

	if len(analyse(t, tr, "bool-exp").Variants) != 0 {
		t.Error("a boolean evaluation created an assignment")
	}
}

func TestAnEndedExperimentStopsCollecting(t *testing.T) {
	tr := NewExperimentTracker()
	exp := conversionExperiment(1)
	exp.EndedAt = tr.now()
	if err := tr.Register(exp); err != nil {
		t.Fatalf("Register: %v", err)
	}

	svc := NewInMemoryFlagService(WithEvaluationLogger(tr))
	svc.SetFlag(Flag{
		Name: "crop_recommendation_model", Type: FlagTypeMultivariate, Enabled: true,
		Variants: []Variant{{Key: "v1", Weight: 1}, {Key: "v2", Weight: 1}},
	})
	svc.GetVariant(context.Background(), "crop_recommendation_model", Attributes{"user_id": "u-1"})

	if len(analyse(t, tr, "crop-rec").Variants) != 0 {
		t.Error("an ended experiment kept collecting assignments")
	}
}
