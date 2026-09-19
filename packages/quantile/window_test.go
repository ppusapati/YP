package quantile

import (
	"math/rand"
	"sync"
	"testing"
)

// A known distribution, so the answers are arithmetic rather than opinion.
func TestQuantilesOverAKnownDistribution(t *testing.T) {
	w := New(100)
	for i := 1; i <= 100; i++ {
		w.Add(int64(i))
	}

	cases := []struct {
		q    float64
		want int64
	}{
		{0, 1},
		// The true median of 1..100 is 50.5, exactly between two samples.
		// Interpolation lands there and math.Round takes halves away from
		// zero, so 51.
		{0.5, 51},
		{0.9, 90},
		{0.95, 95},
		{0.99, 99},
		{1, 100},
	}

	for _, tc := range cases {
		if got := w.Quantile(tc.q); got != tc.want {
			t.Errorf("Quantile(%v) = %d, want %d", tc.q, got, tc.want)
		}
	}
}

// Order of arrival must not change the answer.
//
// This is the defect in observability/graph stated directly: it indexed the
// slice in insertion order, so shuffling the same samples gave a different
// "percentile".
func TestQuantileIsIndependentOfArrivalOrder(t *testing.T) {
	values := make([]int64, 500)
	for i := range values {
		values[i] = int64(i + 1)
	}

	ascending := New(500)
	for _, v := range values {
		ascending.Add(v)
	}

	shuffled := New(500)
	rng := rand.New(rand.NewSource(1))
	perm := rng.Perm(len(values))
	for _, i := range perm {
		shuffled.Add(values[i])
	}

	for _, q := range []float64{0.5, 0.9, 0.95, 0.99} {
		a, b := ascending.Quantile(q), shuffled.Quantile(q)
		if a != b {
			t.Errorf("q=%v: ascending gave %d, shuffled gave %d — the estimate "+
				"depends on arrival order", q, a, b)
		}
	}
}

// The window slides; it does not freeze after the first N samples.
//
// observability/graph appended only while `len(latencies) < 1000`, so a
// dependency that got slower after its first thousand calls reported the p99 of
// its healthiest period for ever.
func TestWindowSlidesRatherThanFreezing(t *testing.T) {
	w := New(100)

	// A fast period.
	for i := 0; i < 100; i++ {
		w.Add(10)
	}
	if got := w.Quantile(0.99); got != 10 {
		t.Fatalf("p99 = %d during the fast period, want 10", got)
	}

	// The service degrades and stays degraded for longer than the window.
	for i := 0; i < 100; i++ {
		w.Add(500)
	}
	if got := w.Quantile(0.99); got != 500 {
		t.Errorf("p99 = %d after the window filled with slow samples, want 500 — "+
			"the window is not sliding", got)
	}

	// And it recovers.
	for i := 0; i < 100; i++ {
		w.Add(10)
	}
	if got := w.Quantile(0.99); got != 10 {
		t.Errorf("p99 = %d after recovery, want 10", got)
	}
}

// One outlier must not dominate a high quantile the way max×0.95 does.
//
// loadbalancer set P95 = 0.95 × MaxLatency against a maximum that never
// decayed, so a single slow call pinned p95 near it permanently.
func TestSingleOutlierDoesNotPinTheHighQuantile(t *testing.T) {
	w := New(1000)
	for i := 0; i < 999; i++ {
		w.Add(10)
	}
	w.Add(1_000_000) // one very slow call

	p95 := w.Quantile(0.95)
	if p95 != 10 {
		t.Errorf("p95 = %d with 999 samples at 10 and one at 1000000, want 10", p95)
	}

	// The outlier belongs at the top, and nowhere else.
	if max := w.Quantile(1); max != 1_000_000 {
		t.Errorf("max = %d, want 1000000", max)
	}

	// The affine transform this replaces would have said:
	if affine := int64(float64(1_000_000) * 0.95); affine == p95 {
		t.Error("p95 matches 0.95 x max, which is the bug being fixed")
	}
}

// The median is not the mean, and a right-skewed distribution is where that
// bites. loadbalancer set P50 = AvgLatency.
func TestMedianIsNotTheMean(t *testing.T) {
	w := New(1000)
	// 990 fast, 10 very slow: mean is dragged up, median is not.
	for i := 0; i < 990; i++ {
		w.Add(10)
	}
	for i := 0; i < 10; i++ {
		w.Add(100_000)
	}

	var sum int64
	for i := 0; i < 990; i++ {
		sum += 10
	}
	sum += 10 * 100_000
	mean := sum / 1000

	median := w.Quantile(0.5)
	if median != 10 {
		t.Errorf("median = %d, want 10", median)
	}
	if median == mean {
		t.Errorf("median equals the mean (%d); the fixture is not skewed", mean)
	}
	t.Logf("median %d against a mean of %d", median, mean)
}

func TestPartialWindow(t *testing.T) {
	w := New(1000)
	if got := w.Quantile(0.99); got != 0 {
		t.Errorf("empty window gave %d, want 0", got)
	}
	if got := w.Len(); got != 0 {
		t.Errorf("empty window Len = %d, want 0", got)
	}

	w.Add(42)
	if got := w.Quantile(0.99); got != 42 {
		t.Errorf("single-sample window gave %d, want 42", got)
	}
	if got := w.Quantile(0); got != 42 {
		t.Errorf("single-sample q=0 gave %d, want 42", got)
	}
	if got := w.Len(); got != 1 {
		t.Errorf("Len = %d, want 1", got)
	}
}

func TestQuantileClampsItsArgument(t *testing.T) {
	w := New(10)
	for i := 1; i <= 10; i++ {
		w.Add(int64(i))
	}

	if got := w.Quantile(-1); got != 1 {
		t.Errorf("Quantile(-1) = %d, want the minimum 1", got)
	}
	if got := w.Quantile(2); got != 10 {
		t.Errorf("Quantile(2) = %d, want the maximum 10", got)
	}
}

func TestReset(t *testing.T) {
	w := New(10)
	for i := 1; i <= 10; i++ {
		w.Add(int64(i))
	}
	w.Reset()

	if got := w.Len(); got != 0 {
		t.Errorf("Len = %d after Reset, want 0", got)
	}
	if got := w.Quantile(0.5); got != 0 {
		t.Errorf("Quantile = %d after Reset, want 0", got)
	}
}

func TestNewClampsSize(t *testing.T) {
	for _, size := range []int{0, -1} {
		w := New(size)
		if len(w.buf) != DefaultSize {
			t.Errorf("New(%d) made a window of %d, want the default %d",
				size, len(w.buf), DefaultSize)
		}
	}
}

// Recorded on one goroutine while read on another is the normal case: both
// call sites record from request handlers and read from a metrics endpoint.
func TestConcurrentAddAndQuantile(t *testing.T) {
	w := New(500)

	var wg sync.WaitGroup
	for g := 0; g < 8; g++ {
		wg.Add(1)
		go func(g int) {
			defer wg.Done()
			for i := 0; i < 500; i++ {
				w.Add(int64(g*1000 + i))
			}
		}(g)
	}
	for r := 0; r < 4; r++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for i := 0; i < 500; i++ {
				_ = w.Quantile(0.99)
				_ = w.Len()
			}
		}()
	}
	wg.Wait()

	if got := w.Len(); got != 500 {
		t.Errorf("Len = %d after 4000 adds into a 500 window, want 500", got)
	}
}

func BenchmarkQuantile(b *testing.B) {
	w := New(1000)
	rng := rand.New(rand.NewSource(1))
	for i := 0; i < 1000; i++ {
		w.Add(rng.Int63n(1_000_000))
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_ = w.Quantile(0.99)
	}
}
