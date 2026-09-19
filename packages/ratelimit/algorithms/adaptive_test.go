package algorithms

import (
	"context"
	"errors"
	"math"
	"sync"
	"testing"
	"time"
)

// ── A virtual clock, so the control loop is tested rather than the scheduler ──

type fakeClock struct {
	mu  sync.Mutex
	now time.Time
}

func newFakeClock() *fakeClock {
	return &fakeClock{now: time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)}
}

func (c *fakeClock) Now() time.Time {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.now
}

func (c *fakeClock) Advance(d time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.now = c.now.Add(d)
}

// newTestLimiter builds a limiter on a virtual clock.
func newTestLimiter(t *testing.T, cfg AdaptiveConfig) (*AdaptiveLimiter, *fakeClock) {
	t.Helper()
	clock := newFakeClock()
	lim := NewAdaptiveLimiterWithConfig(cfg)
	lim.now = clock.Now
	return lim, clock
}

// ── A simulated service with a known knee ───────────────────────────────────

// fakeService serves requests in baseLatency while at most capacity are in
// flight, and queues beyond that.
//
// Latency past the knee is baseLatency * inflight/capacity, which is what a
// queue does: the work per request has not changed, so the extra time is
// waiting. This is the shape the gradient is meant to detect, and stating it
// explicitly is what makes "the limiter converges near the knee" a claim the
// test can check rather than an aspiration.
type fakeService struct {
	baseLatency time.Duration
	capacity    int
}

func (s *fakeService) latency(inflight int) time.Duration {
	if inflight <= s.capacity {
		return s.baseLatency
	}
	return time.Duration(float64(s.baseLatency) * float64(inflight) / float64(s.capacity))
}

// drive runs rounds of the loop: fill the limiter, then complete everything at
// the latency the service would have produced for that concurrency.
func drive(t *testing.T, lim *AdaptiveLimiter, clock *fakeClock, svc *fakeService, key string, rounds int) {
	t.Helper()
	ctx := context.Background()

	for r := 0; r < rounds; r++ {
		var leases []*Lease
		for {
			lease, ok, err := lim.Acquire(ctx, key)
			if err != nil {
				t.Fatalf("Acquire: %v", err)
			}
			if !ok {
				break
			}
			leases = append(leases, lease)
			if len(leases) > 10000 {
				t.Fatal("limiter admitted more than 10000 concurrent; it is not limiting")
			}
		}
		if len(leases) == 0 {
			t.Fatalf("round %d: limiter admitted nothing", r)
		}

		clock.Advance(svc.latency(len(leases)))
		for _, l := range leases {
			l.Success()
		}
	}
}

func limitOf(t *testing.T, lim *AdaptiveLimiter, key string) float64 {
	t.Helper()
	stats, err := lim.GetStats(context.Background(), key)
	if err != nil {
		t.Fatalf("GetStats: %v", err)
	}
	return float64(stats.Metrics["limit"].(int64))
}

// ── The property the old limiter could not satisfy at all ───────────────────

// The limit must be able to grow.
//
// The BBRLimiter this replaces had no code path that raised its congestion
// window after startup: DRAIN decayed it, PROBE_BW left it untouched, and
// PROBE_RTT clamped it to four. Every instance converged on the floor whatever
// the service could actually take. That is the first thing to check here.
func TestAdaptiveLimitGrowsTowardCapacity(t *testing.T) {
	svc := &fakeService{baseLatency: 10 * time.Millisecond, capacity: 60}
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 5,
		MinLimit:     1,
		MaxLimit:     500,
		Smoothing:    0.3,
		SampleWindow: 5,
		LongWindow:   10 * time.Second,
	})

	start := limitOf(t, lim, "svc")
	drive(t, lim, clock, svc, "svc", 80)
	end := limitOf(t, lim, "svc")

	if end <= start {
		t.Fatalf("limit did not grow: started at %v, ended at %v", start, end)
	}
	if end < 20 {
		t.Errorf("limit %v is far below the service's capacity of %d", end, svc.capacity)
	}
	t.Logf("limit %v -> %v against a service with capacity %d", start, end, svc.capacity)
}

// Having grown, it must settle rather than run away to the ceiling.
func TestAdaptiveLimitSettlesNearCapacity(t *testing.T) {
	svc := &fakeService{baseLatency: 10 * time.Millisecond, capacity: 40}
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 5,
		MinLimit:     1,
		MaxLimit:     1000,
		Smoothing:    0.3,
		SampleWindow: 5,
		LongWindow:   time.Hour, // one window, so the no-load floor is stable
	})

	drive(t, lim, clock, svc, "svc", 200)
	settled := limitOf(t, lim, "svc")

	// A gradient controller sits above the knee by the headroom it probes
	// with; it does not sit exactly on it. What matters is that it is in the
	// neighbourhood and nowhere near the 1000 ceiling.
	if settled < float64(svc.capacity)/2 {
		t.Errorf("limit %v is less than half the capacity %d", settled, svc.capacity)
	}
	if settled > float64(svc.capacity)*3 {
		t.Errorf("limit %v ran away from capacity %d", settled, svc.capacity)
	}
	t.Logf("settled at %v for capacity %d", settled, svc.capacity)
}

// And it must come back down when the service loses capacity.
func TestAdaptiveLimitShrinksWhenCapacityDrops(t *testing.T) {
	svc := &fakeService{baseLatency: 10 * time.Millisecond, capacity: 80}
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 5,
		MinLimit:     1,
		MaxLimit:     1000,
		Smoothing:    0.3,
		SampleWindow: 5,
		LongWindow:   time.Hour,
	})

	drive(t, lim, clock, svc, "svc", 150)
	before := limitOf(t, lim, "svc")

	// The service loses most of its capacity — a dependency slowed down, or
	// the instance was scaled in.
	svc.capacity = 10
	drive(t, lim, clock, svc, "svc", 150)
	after := limitOf(t, lim, "svc")

	if after >= before {
		t.Fatalf("limit did not fall after capacity dropped: %v -> %v", before, after)
	}
	if after > before/2 {
		t.Errorf("limit fell only from %v to %v after an 8x capacity loss", before, after)
	}
	t.Logf("limit %v -> %v after capacity 80 -> 10", before, after)
}

// ── The no-load minimum must be able to rise ────────────────────────────────

// A monotonic minimum makes every later window look congested.
//
// The old limiter's minRTT only ever fell, for the life of the process. Once a
// service genuinely became slower — a larger dataset, a colder cache — every
// sample was measured against a floor it could no longer reach, so the gradient
// would read as permanent congestion and the limit would collapse and stay
// collapsed. The rotating window is what prevents that.
func TestAdaptiveNoLoadRTTRises(t *testing.T) {
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 10,
		MinLimit:     1,
		MaxLimit:     100,
		SampleWindow: 4,
		LongWindow:   10 * time.Second,
	})
	ctx := context.Background()

	fast := func(d time.Duration) {
		lease, ok, _ := lim.Acquire(ctx, "svc")
		if !ok {
			t.Fatal("not admitted")
		}
		clock.Advance(d)
		lease.Success()
	}

	for i := 0; i < 8; i++ {
		fast(5 * time.Millisecond)
	}
	stats, _ := lim.GetStats(ctx, "svc")
	if got := stats.Metrics["no_load_rtt_ms"].(int64); got != 5 {
		t.Fatalf("no-load RTT = %dms, want 5ms", got)
	}

	// The service is now genuinely slower, and stays that way for longer than
	// two windows.
	for w := 0; w < 3; w++ {
		for i := 0; i < 8; i++ {
			fast(40 * time.Millisecond)
		}
		clock.Advance(11 * time.Second)
		fast(40 * time.Millisecond) // a completion after the rotation
	}

	stats, _ = lim.GetStats(ctx, "svc")
	got := stats.Metrics["no_load_rtt_ms"].(int64)
	if got <= 5 {
		t.Errorf("no-load RTT stuck at %dms; it can only fall, which is the bug "+
			"that made every later window read as congested", got)
	}
	t.Logf("no-load RTT rose from 5ms to %dms", got)
}

// ── In-flight accounting ────────────────────────────────────────────────────

// Failures must release the slot they hold.
//
// The old limiter had no failure path at all: a hundred errored requests
// consumed its whole window permanently, and it refused everything from then
// on. A limiter whose failure mode is a total outage is worse than none.
func TestAdaptiveFailuresReleaseAndBackOff(t *testing.T) {
	// MinLimit 4 so the floor stays above the batch size: the point here is
	// that a failed request gives its slot back, and a limit that has
	// legitimately backed off past the batch would refuse for the right reason
	// and hide the wrong one.
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 20,
		MinLimit:     4,
		MaxLimit:     100,
		SampleWindow: 4,
		DropPenalty:  0.5,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	before := limitOf(t, lim, "svc")

	for round := 0; round < 6; round++ {
		var leases []*Lease
		for i := 0; i < 4; i++ {
			lease, ok, _ := lim.Acquire(ctx, "svc")
			if !ok {
				t.Fatalf("round %d, slot %d: not admitted at limit %v — a failed "+
					"request kept its slot", round, i, limitOf(t, lim, "svc"))
			}
			leases = append(leases, lease)
		}
		clock.Advance(10 * time.Millisecond)
		for _, l := range leases {
			l.Failure()
		}
	}

	stats, _ := lim.GetStats(ctx, "svc")
	if inflight := stats.Metrics["inflight"].(int64); inflight != 0 {
		t.Errorf("inflight = %d after every request completed, want 0", inflight)
	}

	after := limitOf(t, lim, "svc")
	if after >= before {
		t.Errorf("limit %v did not back off from %v under sustained failures", after, before)
	}
	// Sustained failure drives it to the floor and no further: a limiter that
	// reaches zero can never recover, because recovering needs a completed
	// request to measure.
	if after != 4 {
		t.Errorf("limit settled at %v under sustained failure, want the floor of 4", after)
	}
	t.Logf("limit %v -> %v under failures", before, after)
}

// An abandoned lease must be reclaimed rather than held for ever.
func TestAdaptiveAbandonedLeasesAreReclaimed(t *testing.T) {
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 5,
		MinLimit:     1,
		MaxLimit:     10,
		SampleWindow: 4,
		MaxLeaseAge:  30 * time.Second,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	for i := 0; i < 5; i++ {
		if _, ok, _ := lim.Acquire(ctx, "svc"); !ok {
			t.Fatalf("admission %d refused below the limit", i)
		}
	}
	if _, ok, _ := lim.Acquire(ctx, "svc"); ok {
		t.Fatal("admitted past the limit")
	}

	// Nobody reports an outcome. Past MaxLeaseAge the slots come back.
	clock.Advance(31 * time.Second)

	if _, ok, _ := lim.Acquire(ctx, "svc"); !ok {
		t.Fatal("abandoned leases were never reclaimed; the limiter is wedged shut")
	}
}

// Releasing twice must not create capacity that was never there.
//
// `defer lease.Failure()` followed by `lease.Success()` on the happy path is
// the idiom this has to support, so the second release is a no-op rather than
// a second decrement.
func TestAdaptiveDoubleReleaseIsHarmless(t *testing.T) {
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 4,
		MinLimit:     1,
		MaxLimit:     4,
		SampleWindow: 100, // never adjust; this is about accounting
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	for i := 0; i < 20; i++ {
		lease, ok, _ := lim.Acquire(ctx, "svc")
		if !ok {
			t.Fatalf("iteration %d: refused", i)
		}
		clock.Advance(time.Millisecond)
		lease.Success()
		lease.Failure() // the deferred call, after an explicit Success
		lease.Ignore()
	}

	stats, _ := lim.GetStats(ctx, "svc")
	if inflight := stats.Metrics["inflight"].(int64); inflight != 0 {
		t.Errorf("inflight = %d after repeated double releases, want 0", inflight)
	}

	// The limit still holds: four in flight, then refusal.
	for i := 0; i < 4; i++ {
		if _, ok, _ := lim.Acquire(ctx, "svc"); !ok {
			t.Fatalf("admission %d refused below the limit", i)
		}
	}
	if _, ok, _ := lim.Acquire(ctx, "svc"); ok {
		t.Fatal("admitted past the limit — double releases manufactured capacity")
	}
}

// Recording more completions than admissions must not drive in-flight negative.
//
// The old limiter subtracted without a floor, reached -1550 in a short trace,
// and from then on admitted everything because a negative count is always
// below the window.
func TestAdaptiveCannotGoNegative(t *testing.T) {
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 3,
		MinLimit:     1,
		MaxLimit:     3,
		SampleWindow: 100,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	for i := 0; i < 50; i++ {
		lim.Record(ctx, "svc", 10*time.Millisecond, nil)
	}

	stats, _ := lim.GetStats(ctx, "svc")
	if inflight := stats.Metrics["inflight"].(int64); inflight < 0 {
		t.Fatalf("inflight = %d", inflight)
	}

	for i := 0; i < 3; i++ {
		if ok, _ := lim.Allow(ctx, "svc"); !ok {
			t.Fatalf("admission %d refused below the limit", i)
		}
		clock.Advance(time.Millisecond)
	}
	if ok, _ := lim.Allow(ctx, "svc"); ok {
		t.Fatal("admitted past the limit — unmatched completions manufactured capacity")
	}
}

// ── Isolation ───────────────────────────────────────────────────────────────

// One key filling its window must not affect another.
//
// The old limiter accepted a key and ignored it: one global window, so the
// first caller to fill it starved everyone else. Measured on that code,
// tenant-a was admitted 100 times and tenant-b zero.
func TestAdaptiveKeysAreIndependent(t *testing.T) {
	lim, _ := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 10,
		MinLimit:     1,
		MaxLimit:     10,
		SampleWindow: 100,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	a := 0
	for i := 0; i < 50; i++ {
		if ok, _ := lim.Allow(ctx, "tenant-a"); ok {
			a++
		}
	}
	b := 0
	for i := 0; i < 50; i++ {
		if ok, _ := lim.Allow(ctx, "tenant-b"); ok {
			b++
		}
	}

	if a != 10 || b != 10 {
		t.Fatalf("tenant-a admitted %d, tenant-b admitted %d; want 10 each", a, b)
	}
}

// ── Reserve ─────────────────────────────────────────────────────────────────

// The delay offered under load must reflect the load.
//
// The old limiter returned a fixed one millisecond however deep the queue was,
// because it computed the inter-packet gap at the pacing rate rather than a
// time until capacity. A client honouring that retries a thousand times a
// second.
func TestAdaptiveReserveDelayReflectsLoad(t *testing.T) {
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 8,
		MinLimit:     1,
		MaxLimit:     8,
		SampleWindow: 4,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	// Teach it a latency.
	for i := 0; i < 4; i++ {
		lease, ok, _ := lim.Acquire(ctx, "svc")
		if !ok {
			t.Fatal("not admitted")
		}
		clock.Advance(100 * time.Millisecond)
		lease.Success()
	}

	// Fill the window.
	for {
		r, err := lim.Reserve(ctx, "svc")
		if err != nil {
			t.Fatalf("Reserve: %v", err)
		}
		if !r.OK {
			if r.Delay <= 0 {
				t.Fatal("refused with no delay estimate")
			}
			if r.Delay >= 100*time.Millisecond {
				t.Errorf("delay %v is not divided across the in-flight requests", r.Delay)
			}
			t.Logf("refused with delay %v against a 100ms service", r.Delay)
			return
		}
	}
}

// ── Config hygiene ──────────────────────────────────────────────────────────

// A partially-filled config must not produce a limiter that admits nothing.
func TestAdaptiveConfigDefaultsFillIn(t *testing.T) {
	lim := NewAdaptiveLimiterWithConfig(AdaptiveConfig{Smoothing: 0.5})
	ctx := context.Background()

	if ok, _ := lim.Allow(ctx, "svc"); !ok {
		t.Fatal("a limiter built from a sparse config admitted nothing")
	}
	if lim.cfg.MaxLimit < lim.cfg.MinLimit {
		t.Errorf("MaxLimit %d below MinLimit %d", lim.cfg.MaxLimit, lim.cfg.MinLimit)
	}
	if lim.cfg.DropPenalty <= 0 || lim.cfg.DropPenalty >= 1 {
		t.Errorf("DropPenalty %v is not a decrease", lim.cfg.DropPenalty)
	}
}

// Reset must clear everything, not some of it.
func TestAdaptiveResetClearsMeasurements(t *testing.T) {
	svc := &fakeService{baseLatency: 10 * time.Millisecond, capacity: 50}
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 5,
		MinLimit:     1,
		MaxLimit:     200,
		Smoothing:    0.3,
		SampleWindow: 5,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	drive(t, lim, clock, svc, "svc", 60)
	if grown := limitOf(t, lim, "svc"); grown <= 5 {
		t.Fatalf("setup did not grow the limit: %v", grown)
	}

	if err := lim.Reset(ctx, "svc"); err != nil {
		t.Fatalf("Reset: %v", err)
	}

	stats, _ := lim.GetStats(ctx, "svc")
	if got := stats.Metrics["limit"].(int64); got != 5 {
		t.Errorf("limit = %d after reset, want the initial 5", got)
	}
	if got := stats.Metrics["no_load_rtt_ms"].(int64); got != 0 {
		t.Errorf("no-load RTT = %dms after reset, want 0", got)
	}
	if got := stats.Metrics["allowed_total"].(int64); got != 0 {
		t.Errorf("allowed_total = %d after reset, want 0", got)
	}
}

// Every metric is a typed Go value.
//
// A previous limiter put a named string type in this map and its own test
// compared it to an untyped constant, which is false however the two print.
// Asserting the types here keeps the map's contract explicit.
func TestAdaptiveStatsAreTyped(t *testing.T) {
	lim, _ := newTestLimiter(t, DefaultAdaptiveConfig())
	stats, err := lim.GetStats(context.Background(), "svc")
	if err != nil {
		t.Fatalf("GetStats: %v", err)
	}

	int64Keys := []string{
		"limit", "inflight", "no_load_rtt_ms", "sample_rtt_ms",
		"sample_count", "sample_drops", "allowed_total", "rejected_total",
	}
	for _, k := range int64Keys {
		v, ok := stats.Metrics[k]
		if !ok {
			t.Errorf("metric %q missing", k)
			continue
		}
		if _, ok := v.(int64); !ok {
			t.Errorf("metric %q is %T, want int64", k, v)
		}
	}
	if _, ok := stats.Metrics["gradient"].(float64); !ok {
		t.Errorf("metric \"gradient\" is %T, want float64", stats.Metrics["gradient"])
	}
}

// ── Concurrency ─────────────────────────────────────────────────────────────

// The limiter is shared by every request handler in a process, so it has to be
// correct under concurrent use and not merely free of reported races.
func TestAdaptiveConcurrentUse(t *testing.T) {
	lim := NewAdaptiveLimiterWithConfig(AdaptiveConfig{
		InitialLimit: 50,
		MinLimit:     1,
		MaxLimit:     200,
		SampleWindow: 10,
		LongWindow:   time.Second,
	})
	ctx := context.Background()

	var wg sync.WaitGroup
	for g := 0; g < 16; g++ {
		wg.Add(1)
		go func(g int) {
			defer wg.Done()
			key := []string{"a", "b", "c"}[g%3]
			for i := 0; i < 200; i++ {
				lease, ok, err := lim.Acquire(ctx, key)
				if err != nil {
					t.Errorf("Acquire: %v", err)
					return
				}
				if !ok {
					continue
				}
				if i%17 == 0 {
					lease.Failure()
				} else {
					lease.Success()
				}
			}
		}(g)
	}
	wg.Wait()

	for _, key := range []string{"a", "b", "c"} {
		stats, _ := lim.GetStats(ctx, key)
		inflight := stats.Metrics["inflight"].(int64)
		if inflight != 0 {
			t.Errorf("key %q: inflight = %d after every lease was released", key, inflight)
		}
		limit := stats.Metrics["limit"].(int64)
		if limit < 1 || limit > 200 {
			t.Errorf("key %q: limit %d escaped its clamps", key, limit)
		}
	}
}

// ── The interface contract ──────────────────────────────────────────────────

func TestAdaptiveSatisfiesLimiter(t *testing.T) {
	var _ interface {
		Allow(context.Context, string) (bool, error)
		AllowN(context.Context, string, int) (bool, error)
	} = NewAdaptiveLimiter()
}

func TestAdaptiveAllowNIsAllOrNothing(t *testing.T) {
	lim, _ := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 5,
		MinLimit:     1,
		MaxLimit:     5,
		SampleWindow: 100,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	if ok, _ := lim.AllowN(ctx, "svc", 3); !ok {
		t.Fatal("3 refused against a limit of 5")
	}
	if ok, _ := lim.AllowN(ctx, "svc", 3); ok {
		t.Fatal("a second 3 was admitted against a limit of 5")
	}

	stats, _ := lim.GetStats(ctx, "svc")
	if inflight := stats.Metrics["inflight"].(int64); inflight != 3 {
		t.Errorf("inflight = %d after one admitted batch of 3 and one refused", inflight)
	}
}

// A window containing a failure must not also be read as a latency
// measurement: the time taken to fail says nothing about service time.
func TestAdaptiveFailureWindowIgnoresLatency(t *testing.T) {
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 20,
		MinLimit:     1,
		MaxLimit:     100,
		SampleWindow: 2,
		DropPenalty:  0.5,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	// One fast success and one failure in the same window.
	l1, _, _ := lim.Acquire(ctx, "svc")
	clock.Advance(time.Millisecond)
	l1.Success()

	l2, _, _ := lim.Acquire(ctx, "svc")
	clock.Advance(time.Millisecond)
	l2.Failure()

	stats, _ := lim.GetStats(ctx, "svc")
	if got := stats.Metrics["gradient"].(float64); got != 0 {
		t.Errorf("gradient = %v for a window containing a failure; no gradient "+
			"should be computed from one", got)
	}
	if got := float64(stats.Metrics["limit"].(int64)); got >= 20 {
		t.Errorf("limit = %v; the failure should have backed it off from 20", got)
	}
}

func TestAdaptiveGradientStaysInRange(t *testing.T) {
	svc := &fakeService{baseLatency: 5 * time.Millisecond, capacity: 25}
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 2,
		MinLimit:     1,
		MaxLimit:     400,
		Smoothing:    0.4,
		SampleWindow: 4,
		LongWindow:   time.Hour,
	})

	for r := 0; r < 120; r++ {
		drive(t, lim, clock, svc, "svc", 1)
		stats, _ := lim.GetStats(context.Background(), "svc")
		g := stats.Metrics["gradient"].(float64)
		if g != 0 && (g < gradientFloor-1e-9 || g > 1+1e-9) {
			t.Fatalf("round %d: gradient %v outside [%v, 1]", r, g, gradientFloor)
		}
		if math.IsNaN(g) {
			t.Fatalf("round %d: gradient is NaN", r)
		}
	}
}

var errBackend = errors.New("backend failed")

// Record must accept the legacy Allow/Record pairing and keep the count honest.
func TestAdaptiveAllowRecordPairing(t *testing.T) {
	lim, clock := newTestLimiter(t, AdaptiveConfig{
		InitialLimit: 6,
		MinLimit:     1,
		MaxLimit:     6,
		SampleWindow: 3,
		DropPenalty:  0.5,
		LongWindow:   time.Hour,
	})
	ctx := context.Background()

	for i := 0; i < 6; i++ {
		if ok, _ := lim.Allow(ctx, "svc"); !ok {
			t.Fatalf("admission %d refused below the limit", i)
		}
	}
	if ok, _ := lim.Allow(ctx, "svc"); ok {
		t.Fatal("admitted past the limit")
	}

	clock.Advance(5 * time.Millisecond)
	for i := 0; i < 5; i++ {
		lim.Record(ctx, "svc", 5*time.Millisecond, nil)
	}
	lim.Record(ctx, "svc", 5*time.Millisecond, errBackend)

	stats, _ := lim.GetStats(ctx, "svc")
	if inflight := stats.Metrics["inflight"].(int64); inflight != 0 {
		t.Errorf("inflight = %d after six admissions and six records", inflight)
	}
}
