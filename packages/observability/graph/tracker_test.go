package graph

import (
	"context"
	"testing"
	"time"

	"p9e.in/samavaya/packages/p9log"
)

func newTestTracker(t *testing.T) *Tracker {
	t.Helper()
	return NewTracker(p9log.NoOp())
}

// p99 must reflect recent calls, not the first thousand ever made.
//
// The sample buffer used to append only while `len(latencies) < 1000`, under a
// comment reading "keep recent latencies (last 1000)". It kept the *first*
// thousand and then recorded nothing, so a dependency that degraded after its
// first thousand calls reported the p99 of its healthiest hour indefinitely —
// and this is a dependency-health view somebody is meant to read during an
// incident.
func TestP99FollowsRecentLatency(t *testing.T) {
	tr := newTestTracker(t)

	// A healthy period, longer than the sample window.
	for i := 0; i < 1200; i++ {
		tr.RecordCall(context.Background(), "caller", "dependency", "Op", 10*time.Millisecond, true)
	}
	healthy := p99Of(t, tr, "dependency")
	if healthy > 20 {
		t.Fatalf("p99 = %dms during the healthy period, want about 10ms", healthy)
	}

	// The dependency degrades, and stays degraded for longer than the window.
	for i := 0; i < 1200; i++ {
		tr.RecordCall(context.Background(), "caller", "dependency", "Op", 800*time.Millisecond, true)
	}
	degraded := p99Of(t, tr, "dependency")

	if degraded <= healthy {
		t.Fatalf("p99 went %dms -> %dms after 1200 calls at 800ms; the sample "+
			"window is frozen", healthy, degraded)
	}
	if degraded < 700 {
		t.Errorf("p99 = %dms after a full window at 800ms", degraded)
	}
	t.Logf("p99 %dms -> %dms as the dependency degraded", healthy, degraded)
}

// The estimate must not depend on the order calls arrived in.
//
// calculatePercentile indexed the slice at len*p/100 without sorting it, so it
// returned whichever sample landed at that offset.
func TestP99IsIndependentOfArrivalOrder(t *testing.T) {
	// One slow call among many fast ones must not become the p99 simply by
	// arriving at the index the old formula would have picked.
	tr := newTestTracker(t)

	for i := 0; i < 1000; i++ {
		// Place the single slow call at the position len*99/100 would select.
		latency := 10 * time.Millisecond
		if i == 990 {
			latency = 30 * time.Second
		}
		tr.RecordCall(context.Background(), "caller", "dependency", "Op", latency, true)
	}

	// With 999 samples at 10ms and one at 30s, p99 is 10ms.
	if got := p99Of(t, tr, "dependency"); got > 100 {
		t.Errorf("p99 = %dms; a single 30s call among 999 at 10ms is dominating, "+
			"which is what indexing an unsorted slice produces", got)
	}
}

// Dependencies are tracked separately.
func TestDependenciesAreIndependent(t *testing.T) {
	tr := newTestTracker(t)

	for i := 0; i < 500; i++ {
		tr.RecordCall(context.Background(), "caller", "fast-dep", "Op", 5*time.Millisecond, true)
		tr.RecordCall(context.Background(), "caller", "slow-dep", "Op", 900*time.Millisecond, true)
	}

	fast, slow := p99Of(t, tr, "fast-dep"), p99Of(t, tr, "slow-dep")
	if fast >= slow {
		t.Errorf("fast-dep p99 %dms is not below slow-dep p99 %dms", fast, slow)
	}
	if fast > 50 {
		t.Errorf("fast-dep p99 = %dms against calls of 5ms", fast)
	}
}

// A dependency with no calls reports zero rather than a fabricated figure.
func TestNoCallsReportsZero(t *testing.T) {
	tr := newTestTracker(t)
	tr.RecordCall(context.Background(), "caller", "dependency", "Op", 0, true)

	if got := p99Of(t, tr, "dependency"); got != 0 {
		t.Errorf("p99 = %dms for a single zero-latency call, want 0", got)
	}
}

// p99Of reads one dependency's p99 in milliseconds from the graph.
func p99Of(t *testing.T, tr *Tracker, dependency string) int64 {
	t.Helper()

	deps := tr.GetDependencies(context.Background(), "caller")
	if deps == nil {
		t.Fatal("GetDependencies returned nil")
	}
	for _, d := range deps.Dependencies {
		if d.Service == dependency {
			return d.P99Latency
		}
	}
	t.Fatalf("dependency %q not in the graph", dependency)
	return 0
}

// The composite key must be parsed, not reported verbatim.
//
// `depService := key` put "soil-service:GetSample" in a field named Service, so
// a caller with three operations against one dependency saw three dependencies,
// none of them named after the service.
func TestServiceAndOperationAreSeparated(t *testing.T) {
	tr := newTestTracker(t)

	tr.RecordCall(context.Background(), "caller", "soil-service", "GetSample", 10*time.Millisecond, true)
	tr.RecordCall(context.Background(), "caller", "soil-service", "ListSamples", 20*time.Millisecond, true)

	deps := tr.GetDependencies(context.Background(), "caller")
	if len(deps.Dependencies) != 2 {
		t.Fatalf("got %d dependency rows, want 2 (one per operation)", len(deps.Dependencies))
	}

	ops := map[string]bool{}
	for _, d := range deps.Dependencies {
		if d.Service != "soil-service" {
			t.Errorf("Service = %q, want %q — the composite key is unparsed",
				d.Service, "soil-service")
		}
		ops[d.Operation] = true
	}
	for _, want := range []string{"GetSample", "ListSamples"} {
		if !ops[want] {
			t.Errorf("no row for operation %q; got %v", want, ops)
		}
	}
}
