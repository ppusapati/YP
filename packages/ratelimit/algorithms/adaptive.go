package algorithms

import (
	"context"
	"math"
	"sync"
	"time"

	"p9e.in/samavaya/packages/ratelimit"
)

// AdaptiveLimiter bounds concurrency by watching how much a service's own
// latency degrades under load.
//
// # Why concurrency and not a rate
//
// A token bucket enforces a rate somebody chose in advance. That number is a
// guess about a service that changes: a slower database, a noisy neighbour, a
// cold cache and a bigger instance all move the rate the service can actually
// sustain, and the configured number does not move with them. Set it low and
// capacity is wasted; set it high and the limiter stops protecting anything at
// exactly the moment it is needed.
//
// A concurrency limit does not need the number. A service has some level of
// in-flight work at which it is fastest. Below that, latency is flat — requests
// are served as they arrive. Past it, they queue, and latency rises in
// proportion to the queue rather than the work. The ratio between the latency
// seen when idle and the latency seen now is therefore an observation of how
// deep the queue is, and it is measured rather than configured.
//
// # The control loop
//
// That ratio is the gradient:
//
//	gradient = noLoadRTT / sampleRTT      clamped to [0.5, 1]
//	newLimit = limit*gradient + sqrt(limit)
//	limit    = limit + smoothing*(newLimit - limit)
//
// With no queue the gradient is 1 and the limit grows by sqrt(limit) — the
// headroom term is what lets it find more capacity, and taking the square root
// makes the probe proportionally gentler as the limit gets larger. With a queue
// the gradient shrinks the limit toward the level that produced the flat
// latency. The clamp at 0.5 stops a single slow request from halving the limit;
// a genuine slowdown persists across samples and still converges down quickly.
//
// Failures are handled separately, multiplicatively: a service returning errors
// is not telling you about its queue, it is telling you to back off.
//
// # What this replaces
//
// This file replaces a BBRLimiter that carried BBR's vocabulary — STARTUP,
// DRAIN, PROBE_BW, PROBE_RTT, bandwidth-delay product — over a control loop
// that never closed. Tracing it showed STARTUP exiting on its first sample
// because the BDP it compared against was still zero; a congestion window with
// no code path that could ever raise it; a bandwidth estimate that was a
// permanent high-water mark because the sample window it collected was never
// read; a BDP computed from queueing latency rather than the minimum, which is
// the positive feedback loop BBR exists to avoid; in-flight accounting with no
// failure path, so errored requests wedged it shut, and no floor, so recorded
// deliveries drove it negative and it admitted everything; and one window
// shared by every key, so one tenant starved the rest.
//
// The parts of BBR that matter here are kept: a windowed minimum that can rise
// rather than a monotonic floor, and a limit that probes upward instead of only
// decaying. The parts that are about pacing packets over a link are not.
type AdaptiveLimiter struct {
	cfg  AdaptiveConfig
	mu   sync.Mutex
	keys map[string]*adaptiveKey

	// now is injectable so the control loop can be tested against a virtual
	// clock rather than by sleeping.
	now func() time.Time
}

// AdaptiveConfig configures an AdaptiveLimiter.
type AdaptiveConfig struct {
	// InitialLimit is the concurrency allowed before anything is measured.
	InitialLimit int

	// MinLimit is the floor. A limiter that can reach zero can never recover,
	// because it needs a completed request to measure with.
	MinLimit int

	// MaxLimit is the ceiling, which exists so a service that never shows
	// latency degradation (because the bottleneck is somewhere else entirely)
	// still has a bound.
	MaxLimit int

	// Smoothing is how much of each computed limit is adopted, in (0, 1].
	// Lower reacts more slowly and is steadier under noise.
	Smoothing float64

	// LongWindow is how far back the no-load latency is remembered. Two
	// buckets of this length rotate, so the remembered minimum spans between
	// one and two windows and, crucially, can rise when the service genuinely
	// becomes slower.
	LongWindow time.Duration

	// SampleWindow is how many completions are gathered before the limit is
	// adjusted. Zero derives it from the current limit, which keeps the loop
	// running about once per round of in-flight work.
	SampleWindow int

	// DropPenalty multiplies the limit when a sample window contained a
	// failure. Below 1.
	DropPenalty float64

	// MaxLeaseAge reclaims in-flight slots whose owner never reported an
	// outcome.
	//
	// This is a safety net, not a mechanism: the correct path is Acquire and
	// Lease.Success/Failure, which cannot be forgotten by a caller using
	// defer. It is here because the limiter this replaces had no such net, and
	// a hundred unreported requests closed it permanently — a limiter whose
	// failure mode is refusing all traffic for ever is worse than no limiter.
	MaxLeaseAge time.Duration
}

// DefaultAdaptiveConfig returns settings suitable for an RPC service call.
func DefaultAdaptiveConfig() AdaptiveConfig {
	return AdaptiveConfig{
		InitialLimit: 20,
		MinLimit:     4,
		MaxLimit:     500,
		Smoothing:    0.2,
		LongWindow:   10 * time.Second,
		SampleWindow: 0,
		DropPenalty:  0.8,
		MaxLeaseAge:  60 * time.Second,
	}
}

const (
	// gradientFloor stops one slow response from halving the limit. A real
	// slowdown shows up in the next window too, and 0.5 per window still
	// converges downward fast.
	gradientFloor = 0.5

	// minSampleWindow is the fewest completions worth adjusting on. Below
	// this the window minimum is dominated by which few requests happened to
	// land in it.
	minSampleWindow = 3

	// maxSampleWindow bounds how long a very high limit can go without
	// adjusting.
	maxSampleWindow = 100

	// sweepInterval is how often abandoned leases are looked for, so the scan
	// is not paid on every admission.
	sweepInterval = time.Second
)

// adaptiveKey is one key's independent limiter.
//
// Per key, not one global window. The limiter this replaces accepted a key and
// ignored it, so the first caller to fill the window starved every other
// caller — in a multi-tenant platform that is an isolation failure rather than
// a performance one.
type adaptiveKey struct {
	limit    float64
	lastGrad float64

	// outstanding maps an admission to when it started, and is the single
	// source of truth for in-flight count. A counter that is incremented and
	// decremented separately can drift; a set cannot.
	outstanding map[uint64]time.Time
	anonQueue   []uint64 // ids admitted through Allow, released oldest first
	nextID      uint64
	lastSweep   time.Time

	// Current sampling window.
	sampleMin   time.Duration
	sampleCount int
	sampleDrops int

	// Rotating no-load minimum.
	curMin      time.Duration
	prevMin     time.Duration
	windowStart time.Time

	allowed  int64
	rejected int64
}

// NewAdaptiveLimiter creates a limiter with the default configuration.
func NewAdaptiveLimiter() *AdaptiveLimiter {
	return NewAdaptiveLimiterWithConfig(DefaultAdaptiveConfig())
}

// NewAdaptiveLimiterWithConfig creates a limiter, filling in any zero field
// from the defaults so a partially-specified config cannot produce a limiter
// that admits nothing.
func NewAdaptiveLimiterWithConfig(cfg AdaptiveConfig) *AdaptiveLimiter {
	d := DefaultAdaptiveConfig()
	if cfg.InitialLimit <= 0 {
		cfg.InitialLimit = d.InitialLimit
	}
	if cfg.MinLimit <= 0 {
		cfg.MinLimit = d.MinLimit
	}
	if cfg.MaxLimit <= 0 {
		cfg.MaxLimit = d.MaxLimit
	}
	if cfg.MaxLimit < cfg.MinLimit {
		cfg.MaxLimit = cfg.MinLimit
	}
	cfg.InitialLimit = clampInt(cfg.InitialLimit, cfg.MinLimit, cfg.MaxLimit)
	if cfg.Smoothing <= 0 || cfg.Smoothing > 1 {
		cfg.Smoothing = d.Smoothing
	}
	if cfg.LongWindow <= 0 {
		cfg.LongWindow = d.LongWindow
	}
	if cfg.DropPenalty <= 0 || cfg.DropPenalty >= 1 {
		cfg.DropPenalty = d.DropPenalty
	}
	if cfg.MaxLeaseAge <= 0 {
		cfg.MaxLeaseAge = d.MaxLeaseAge
	}

	return &AdaptiveLimiter{
		cfg:  cfg,
		keys: make(map[string]*adaptiveKey),
		now:  time.Now,
	}
}

// Lease is one admitted request. Exactly one of Success, Failure or Ignore
// must be called, which `defer` makes hard to get wrong:
//
//	lease, ok, err := limiter.Acquire(ctx, key)
//	if err != nil || !ok {
//	    return errTooBusy
//	}
//	defer lease.Failure() // replaced by Success on the happy path
//	...
//	lease.Success()
//
// Calling more than once is a no-op after the first, so the deferred call above
// is safe.
type Lease struct {
	limiter *AdaptiveLimiter
	key     string
	id      uint64
	done    bool
}

// Success releases the lease and feeds its measured latency into the loop.
func (l *Lease) Success() {
	l.release(true)
}

// Failure releases the lease and records a drop, which backs the limit off
// multiplicatively. Use it for errors that mean the service is struggling —
// timeouts, 5xx, circuit-breaker rejections — not for a caller's bad request.
func (l *Lease) Failure() {
	l.release(false)
}

// Ignore releases the lease without measuring it, for work whose duration says
// nothing about the service: a cancelled context, a request the caller
// abandoned. Counting those as latency would teach the limiter the wrong shape.
func (l *Lease) Ignore() {
	if l == nil || l.done {
		return
	}
	l.done = true
	lim := l.limiter
	lim.mu.Lock()
	defer lim.mu.Unlock()
	if k, ok := lim.keys[l.key]; ok {
		delete(k.outstanding, l.id)
	}
}

func (l *Lease) release(success bool) {
	if l == nil || l.done {
		return
	}
	l.done = true
	l.limiter.complete(l.key, l.id, success)
}

// Acquire admits a request and returns a Lease for reporting its outcome.
//
// This is the API to prefer over Allow: the lease carries the start time, so
// the latency fed back is the one actually measured and no caller can release
// a slot it never took.
func (a *AdaptiveLimiter) Acquire(ctx context.Context, key string) (*Lease, bool, error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	k := a.keyState(key)
	now := a.now()
	a.sweep(k, now)

	if float64(len(k.outstanding)) >= k.limit {
		k.rejected++
		return nil, false, nil
	}

	id := k.nextID
	k.nextID++
	k.outstanding[id] = now
	k.allowed++

	return &Lease{limiter: a, key: key, id: id}, true, nil
}

// Allow reports whether a request may proceed, satisfying ratelimit.Limiter.
//
// The caller must then call Record with the outcome. Prefer Acquire: this form
// cannot tie the report back to the admission, so Record releases the
// oldest outstanding admission rather than a specific one, and a caller that
// never reports leaks a slot until MaxLeaseAge reclaims it.
func (a *AdaptiveLimiter) Allow(ctx context.Context, key string) (bool, error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	k := a.keyState(key)
	now := a.now()
	a.sweep(k, now)

	if float64(len(k.outstanding)) >= k.limit {
		k.rejected++
		return false, nil
	}

	id := k.nextID
	k.nextID++
	k.outstanding[id] = now
	k.anonQueue = append(k.anonQueue, id)
	k.allowed++

	return true, nil
}

// AllowN admits n requests at once, or none.
//
// All-or-nothing on purpose: admitting part of a batch leaves the caller to
// decide what to do with the remainder, which is the decision it asked the
// limiter to make.
func (a *AdaptiveLimiter) AllowN(ctx context.Context, key string, n int) (bool, error) {
	if n <= 0 {
		return true, nil
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	k := a.keyState(key)
	now := a.now()
	a.sweep(k, now)

	if float64(len(k.outstanding)+n) > k.limit {
		// Counted as n refusals, not one, so allowed and rejected are in the
		// same units and their ratio means something.
		k.rejected += int64(n)
		return false, nil
	}

	for i := 0; i < n; i++ {
		id := k.nextID
		k.nextID++
		k.outstanding[id] = now
		k.anonQueue = append(k.anonQueue, id)
	}
	k.allowed += int64(n)

	return true, nil
}

// Record reports the outcome of a request admitted through Allow.
//
// latency is how long the request took; err non-nil marks it a failure. Pass
// a zero latency to release the slot without feeding the control loop, which
// is what Lease.Ignore does.
func (a *AdaptiveLimiter) Record(ctx context.Context, key string, latency time.Duration, err error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	k, ok := a.keys[key]
	if !ok || len(k.anonQueue) == 0 {
		return
	}

	id := k.anonQueue[0]
	k.anonQueue = k.anonQueue[1:]
	if _, live := k.outstanding[id]; !live {
		// Already reclaimed by the sweeper.
		return
	}
	delete(k.outstanding, id)

	if latency <= 0 && err == nil {
		return
	}
	a.observe(k, latency, err == nil)
}

// Reserve admits a request if there is room, and otherwise estimates how long
// until there will be.
//
// When OK is true a slot is held, exactly as Allow holds one, and the caller
// must report the outcome with Record.
//
// When OK is false nothing has been reserved — the limiter is holding no slot
// for this caller, and Delay is an estimate, not a promise. It is the expected
// time until one of the outstanding requests finishes: with `limit` requests in
// flight, each taking about the observed latency, one completes on average
// every latency/limit. The limiter this replaces returned a fixed one
// millisecond whatever the queue depth, which a caller honouring it turns into
// a thousand retries a second.
func (a *AdaptiveLimiter) Reserve(ctx context.Context, key string) (*ratelimit.Reservation, error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	k := a.keyState(key)
	now := a.now()
	a.sweep(k, now)

	if float64(len(k.outstanding)) < k.limit {
		id := k.nextID
		k.nextID++
		k.outstanding[id] = now
		k.anonQueue = append(k.anonQueue, id)
		k.allowed++
		return &ratelimit.Reservation{ReadyAt: now, Delay: 0, OK: true}, nil
	}

	k.rejected++

	rtt := k.noLoadRTT()
	if k.sampleMin > 0 {
		rtt = k.sampleMin
	}
	if rtt <= 0 {
		// Nothing measured yet; there is no honest estimate to give.
		return &ratelimit.Reservation{ReadyAt: now, Delay: 0, OK: false}, nil
	}

	inflight := math.Max(1, float64(len(k.outstanding)))
	delay := time.Duration(float64(rtt) / inflight)

	return &ratelimit.Reservation{
		ReadyAt: now.Add(delay),
		Delay:   delay,
		OK:      false,
	}, nil
}

// GetStats returns the current state for a key.
//
// Every value in Metrics is a Go value of its natural type, not a string:
// limit and in-flight are int64, latencies are int64 milliseconds, gradient is
// a float64.
func (a *AdaptiveLimiter) GetStats(ctx context.Context, key string) (*ratelimit.Stats, error) {
	a.mu.Lock()
	defer a.mu.Unlock()

	k := a.keyState(key)

	return &ratelimit.Stats{
		Key:           key,
		AllowedCount:  k.allowed,
		RejectedCount: k.rejected,
		CurrentLimit:  int64(k.limit),
		Metrics: map[string]interface{}{
			"limit":          int64(k.limit),
			"inflight":       int64(len(k.outstanding)),
			"no_load_rtt_ms": k.noLoadRTT().Milliseconds(),
			"sample_rtt_ms":  k.sampleMin.Milliseconds(),
			"gradient":       k.lastGrad,
			"sample_count":   int64(k.sampleCount),
			"sample_drops":   int64(k.sampleDrops),
			"allowed_total":  k.allowed,
			"rejected_total": k.rejected,
		},
	}, nil
}

// Reset returns a key to its initial state, including every measurement.
//
// All of it, deliberately: the limiter this replaces reset seven fields and
// left the bandwidth-delay product, the round counter and the cycle counter
// behind, so a reset limiter carried the estimates that made a reset seem
// necessary.
func (a *AdaptiveLimiter) Reset(ctx context.Context, key string) error {
	a.mu.Lock()
	defer a.mu.Unlock()

	delete(a.keys, key)
	return nil
}

// ── internals ───────────────────────────────────────────────────────────────

// keyState returns the key's limiter, creating it on first use. Callers hold
// a.mu.
func (a *AdaptiveLimiter) keyState(key string) *adaptiveKey {
	if k, ok := a.keys[key]; ok {
		return k
	}
	now := a.now()
	k := &adaptiveKey{
		limit:       float64(a.cfg.InitialLimit),
		outstanding: make(map[uint64]time.Time),
		windowStart: now,
		lastSweep:   now,
	}
	a.keys[key] = k
	return k
}

// complete releases a lease and feeds the loop with its measured duration.
func (a *AdaptiveLimiter) complete(key string, id uint64, success bool) {
	a.mu.Lock()
	defer a.mu.Unlock()

	k, ok := a.keys[key]
	if !ok {
		return
	}
	start, live := k.outstanding[id]
	if !live {
		// Reclaimed by the sweeper, or the key was Reset while in flight.
		return
	}
	delete(k.outstanding, id)

	a.observe(k, a.now().Sub(start), success)
}

// observe folds one completed request into the key's windows and adjusts the
// limit when the sampling window is full. Callers hold a.mu.
func (a *AdaptiveLimiter) observe(k *adaptiveKey, latency time.Duration, success bool) {
	now := a.now()
	k.rotate(now, a.cfg.LongWindow)

	if !success {
		k.sampleDrops++
	} else if latency > 0 {
		// The minimum of the window, not the mean: one slow request among many
		// says the tail is long, and the limit should answer to the queue
		// rather than to the tail.
		if k.sampleMin == 0 || latency < k.sampleMin {
			k.sampleMin = latency
		}
		// The no-load estimate only ever learns from successes. A failure's
		// duration is the time to fail, which is unrelated to service time.
		if k.curMin == 0 || latency < k.curMin {
			k.curMin = latency
		}
	}

	k.sampleCount++
	if k.sampleCount < a.sampleWindow(k) {
		return
	}

	a.adjust(k)
}

// sampleWindow is how many completions to gather before adjusting.
//
// Derived from the limit by default so the loop runs about once per round of
// in-flight work: adjusting on every completion chases noise, and adjusting
// too rarely leaves the limit stale while conditions move.
func (a *AdaptiveLimiter) sampleWindow(k *adaptiveKey) int {
	if a.cfg.SampleWindow > 0 {
		return a.cfg.SampleWindow
	}
	return clampInt(int(k.limit/2), minSampleWindow, maxSampleWindow)
}

// adjust recomputes the limit from the window just closed. Callers hold a.mu.
func (a *AdaptiveLimiter) adjust(k *adaptiveKey) {
	defer k.resetSample()

	noLoad := k.noLoadRTT()

	switch {
	case k.sampleDrops > 0:
		// A failing service is not reporting queue depth, it is asking to be
		// left alone. Multiplicative decrease, and no gradient is computed:
		// the latency of a window containing errors is not a measurement of
		// anything.
		k.lastGrad = 0
		a.setLimit(k, k.limit*a.cfg.DropPenalty)
		return

	case noLoad <= 0 || k.sampleMin <= 0:
		// Nothing measurable happened. Leave the limit where it is rather than
		// guessing.
		return
	}

	gradient := float64(noLoad) / float64(k.sampleMin)
	// Above 1 means this window was faster than the remembered minimum, which
	// is information about the minimum rather than about the queue; curMin has
	// already taken it.
	gradient = math.Min(1, math.Max(gradientFloor, gradient))
	k.lastGrad = gradient

	headroom := math.Sqrt(k.limit)
	target := k.limit*gradient + headroom

	a.setLimit(k, k.limit+a.cfg.Smoothing*(target-k.limit))
}

// setLimit applies the clamps. Callers hold a.mu.
func (a *AdaptiveLimiter) setLimit(k *adaptiveKey, next float64) {
	if math.IsNaN(next) || math.IsInf(next, 0) {
		return
	}
	k.limit = math.Min(float64(a.cfg.MaxLimit), math.Max(float64(a.cfg.MinLimit), next))
}

// sweep reclaims admissions whose owner never reported an outcome. Callers
// hold a.mu.
func (a *AdaptiveLimiter) sweep(k *adaptiveKey, now time.Time) {
	if now.Sub(k.lastSweep) < sweepInterval || len(k.outstanding) == 0 {
		return
	}
	k.lastSweep = now

	var expired map[uint64]struct{}
	for id, start := range k.outstanding {
		if now.Sub(start) > a.cfg.MaxLeaseAge {
			if expired == nil {
				expired = make(map[uint64]struct{})
			}
			expired[id] = struct{}{}
			delete(k.outstanding, id)
		}
	}
	if expired == nil {
		return
	}

	kept := k.anonQueue[:0]
	for _, id := range k.anonQueue {
		if _, gone := expired[id]; !gone {
			kept = append(kept, id)
		}
	}
	k.anonQueue = kept
}

// rotate advances the two no-load buckets when the window has elapsed.
//
// Two buckets rather than one running minimum, because a single minimum can
// only ever fall. A service that genuinely becomes slower — a bigger dataset, a
// colder cache, a smaller instance — would be measured for ever against a floor
// it can no longer reach, and every window would read as congested. Rotating
// lets the remembered minimum rise while still spanning at least one full
// window of history.
func (k *adaptiveKey) rotate(now time.Time, window time.Duration) {
	if now.Sub(k.windowStart) < window {
		return
	}
	elapsed := now.Sub(k.windowStart)
	if elapsed >= 2*window {
		// A long idle period: everything remembered is older than two windows.
		k.prevMin = 0
	} else {
		k.prevMin = k.curMin
	}
	k.curMin = 0
	k.windowStart = now
}

// noLoadRTT is the smallest latency remembered across both buckets.
func (k *adaptiveKey) noLoadRTT() time.Duration {
	switch {
	case k.curMin == 0:
		return k.prevMin
	case k.prevMin == 0:
		return k.curMin
	default:
		return min(k.curMin, k.prevMin)
	}
}

func (k *adaptiveKey) resetSample() {
	k.sampleMin = 0
	k.sampleCount = 0
	k.sampleDrops = 0
}

func clampInt(v, lo, hi int) int {
	return max(lo, min(hi, v))
}
