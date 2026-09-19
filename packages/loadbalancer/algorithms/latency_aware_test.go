package algorithms

import (
	"testing"
	"time"
)

// Percentiles must come from the samples, not from arithmetic on the mean and
// the maximum.
//
// What this replaces:
//
//	P50 = AvgLatency
//	P95 = MaxLatency * 0.95
//	P99 = MaxLatency * 0.99
//
// Select() routes on these, so a p95 that is really the worst request ever seen
// sends traffic away from an endpoint that has been healthy for hours.
func TestPercentilesComeFromSamples(t *testing.T) {
	lab := NewLatencyAwareBalancer()

	// A steady endpoint, and one slow call early on.
	lab.RecordMetrics("a", 5*time.Second, true) // the outlier, first
	for i := 0; i < 999; i++ {
		lab.RecordMetrics("a", 10*time.Millisecond, true)
	}

	m := lab.GetMetrics("a")
	if m == nil {
		t.Fatal("no metrics recorded")
	}

	// The old formula would give 0.95 x 5s = 4.75s.
	affine := time.Duration(float64(5*time.Second) * 0.95)
	if m.P95Latency == affine {
		t.Fatalf("P95 = %v, which is 0.95 x the maximum — the arithmetic is back", m.P95Latency)
	}
	if m.P95Latency > 100*time.Millisecond {
		t.Errorf("P95 = %v after 999 calls at 10ms and one at 5s; one slow call "+
			"is still dominating", m.P95Latency)
	}

	// And the maximum is still reachable at the top of the distribution.
	if m.MaxLatency != 5*time.Second {
		t.Errorf("MaxLatency = %v, want 5s", m.MaxLatency)
	}
	t.Logf("P50=%v P95=%v P99=%v against a max of %v and a mean of %v",
		m.P50Latency, m.P95Latency, m.P99Latency, m.MaxLatency, m.AvgLatency)
}

// The median is not the mean. A right-skewed distribution is where the
// difference matters, and latency distributions are always right-skewed.
func TestMedianIsNotTheMean(t *testing.T) {
	lab := NewLatencyAwareBalancer()

	for i := 0; i < 900; i++ {
		lab.RecordMetrics("a", 10*time.Millisecond, true)
	}
	for i := 0; i < 100; i++ {
		lab.RecordMetrics("a", time.Second, true)
	}

	m := lab.GetMetrics("a")
	if m.P50Latency == m.AvgLatency {
		t.Errorf("P50 equals AvgLatency (%v); the median is being read off the mean",
			m.AvgLatency)
	}
	if m.P50Latency > 50*time.Millisecond {
		t.Errorf("P50 = %v with 90%% of calls at 10ms", m.P50Latency)
	}
}

// Percentiles must recover when an endpoint does.
//
// The old maximum never decayed, so nothing derived from it could recover.
func TestPercentilesRecoverAfterASlowPeriod(t *testing.T) {
	lab := NewLatencyAwareBalancerWithSamples(100)

	for i := 0; i < 100; i++ {
		lab.RecordMetrics("a", time.Second, true)
	}
	degraded := lab.GetMetrics("a").P95Latency

	// The endpoint recovers for longer than the window.
	for i := 0; i < 100; i++ {
		lab.RecordMetrics("a", 5*time.Millisecond, true)
	}
	recovered := lab.GetMetrics("a").P95Latency

	if recovered >= degraded {
		t.Errorf("P95 went %v -> %v across a full window of fast calls; it is not "+
			"recovering", degraded, recovered)
	}
	if recovered > 50*time.Millisecond {
		t.Errorf("P95 = %v after a full window at 5ms", recovered)
	}
}

// Endpoints keep their own samples.
func TestSamplesArePerEndpoint(t *testing.T) {
	lab := NewLatencyAwareBalancer()

	for i := 0; i < 200; i++ {
		lab.RecordMetrics("fast", 5*time.Millisecond, true)
		lab.RecordMetrics("slow", 800*time.Millisecond, true)
	}

	fast := lab.GetMetrics("fast").P95Latency
	slow := lab.GetMetrics("slow").P95Latency

	if fast >= slow {
		t.Errorf("fast P95 %v is not below slow P95 %v — the windows are shared",
			fast, slow)
	}
	if fast > 50*time.Millisecond {
		t.Errorf("fast P95 = %v against calls of 5ms", fast)
	}
}

// Reset must clear the samples, not only the counters.
func TestResetClearsSamples(t *testing.T) {
	lab := NewLatencyAwareBalancer()

	for i := 0; i < 200; i++ {
		lab.RecordMetrics("a", time.Second, true)
	}
	lab.Reset()

	// One fast call after the reset should be all the limiter knows.
	lab.RecordMetrics("a", 5*time.Millisecond, true)

	m := lab.GetMetrics("a")
	if m.P95Latency > 50*time.Millisecond {
		t.Errorf("P95 = %v after Reset and one 5ms call; the pre-reset samples "+
			"survived", m.P95Latency)
	}
}

// The sample size option is honoured, which is what makes
// loadbalancer.WithMaxLatencySamples mean anything.
func TestSampleSizeIsHonoured(t *testing.T) {
	lab := NewLatencyAwareBalancerWithSamples(10)

	for i := 0; i < 10; i++ {
		lab.RecordMetrics("a", time.Second, true)
	}
	// Ten more fast calls fully replace the window.
	for i := 0; i < 10; i++ {
		lab.RecordMetrics("a", 5*time.Millisecond, true)
	}

	if got := lab.GetMetrics("a").P99Latency; got > 50*time.Millisecond {
		t.Errorf("P99 = %v after the 10-sample window was refilled with 5ms calls", got)
	}
}

func TestZeroSampleSizeFallsBackToDefault(t *testing.T) {
	lab := NewLatencyAwareBalancerWithSamples(0)
	lab.RecordMetrics("a", 10*time.Millisecond, true)
	if got := lab.GetMetrics("a").P50Latency; got != 10*time.Millisecond {
		t.Errorf("P50 = %v, want 10ms", got)
	}
}
