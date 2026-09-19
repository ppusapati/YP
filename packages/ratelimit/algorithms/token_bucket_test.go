package algorithms

import (
	"context"
	"testing"
	"time"

	"p9e.in/samavaya/packages/ratelimit"
)

func TestTokenBucketAllow(t *testing.T) {
	// 100 capacity, 50 req/sec
	limiter := NewTokenBucketLimiter(100, 50.0)

	ctx := context.Background()

	// Should allow initial requests up to capacity
	for i := 0; i < 100; i++ {
		ok, _ := limiter.Allow(ctx, "test-key")
		if !ok {
			t.Fatalf("Request %d should be allowed", i)
		}
	}

	// Next request should be rejected
	ok, _ := limiter.Allow(ctx, "test-key")
	if ok {
		t.Fatal("Request should be rejected after capacity exhausted")
	}
}

func TestTokenBucketRefill(t *testing.T) {
	// 10 capacity, 5 req/sec
	limiter := NewTokenBucketLimiter(10, 5.0)

	ctx := context.Background()

	// Exhaust bucket
	for i := 0; i < 10; i++ {
		limiter.Allow(ctx, "test-key")
	}

	// Should be rejected
	ok, _ := limiter.Allow(ctx, "test-key")
	if ok {
		t.Fatal("Request should be rejected")
	}

	// Wait for refill (1 second = 5 tokens at 5 req/sec)
	time.Sleep(1100 * time.Millisecond)

	// Should now have ~5 tokens
	allowCount := 0
	for i := 0; i < 10; i++ {
		ok, _ := limiter.Allow(ctx, "test-key")
		if ok {
			allowCount++
		} else {
			break
		}
	}

	if allowCount < 4 || allowCount > 6 {
		t.Errorf("Expected ~5 requests allowed, got %d", allowCount)
	}
}

func TestTokenBucketAllowN(t *testing.T) {
	limiter := NewTokenBucketLimiter(100, 50.0)

	ctx := context.Background()

	// Request 50 tokens at once
	ok, _ := limiter.AllowN(ctx, "test-key", 50)
	if !ok {
		t.Fatal("Should allow 50 tokens")
	}

	// Request another 50
	ok, _ = limiter.AllowN(ctx, "test-key", 50)
	if !ok {
		t.Fatal("Should allow another 50 tokens")
	}

	// Next 50 should fail
	ok, _ = limiter.AllowN(ctx, "test-key", 50)
	if ok {
		t.Fatal("Should not allow 50 tokens")
	}
}

func TestTokenBucketReserve(t *testing.T) {
	limiter := NewTokenBucketLimiter(10, 5.0)

	ctx := context.Background()

	// Exhaust bucket
	for i := 0; i < 10; i++ {
		limiter.Allow(ctx, "test-key")
	}

	// Reserve should indicate delay
	res, _ := limiter.Reserve(ctx, "test-key")
	if res.OK {
		t.Fatal("Reserve should indicate not OK after capacity exhausted")
	}

	if res.Delay == 0 {
		t.Fatal("Reserve should indicate delay needed")
	}
}

func TestTokenBucketMultipleKeys(t *testing.T) {
	limiter := NewTokenBucketLimiter(10, 5.0)

	ctx := context.Background()

	// Exhaust key1
	for i := 0; i < 10; i++ {
		limiter.Allow(ctx, "key1")
	}

	// key2 should still have capacity
	ok, _ := limiter.Allow(ctx, "key2")
	if !ok {
		t.Fatal("key2 should have capacity")
	}
}

func BenchmarkTokenBucketAllow(b *testing.B) {
	limiter := NewTokenBucketLimiter(1000, 1000.0)
	ctx := context.Background()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		limiter.Allow(ctx, "bench-key")
	}
}

func BenchmarkTokenBucketAllowN(b *testing.B) {
	limiter := NewTokenBucketLimiter(10000, 10000.0)
	ctx := context.Background()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		limiter.AllowN(ctx, "bench-key", 100)
	}
}

func TestBBRAllow(t *testing.T) {
	bbr := NewBBRLimiter()

	ctx := context.Background()

	// Should allow initial requests
	ok, _ := bbr.Allow(ctx, "test-key")
	if !ok {
		t.Fatal("Should allow initial request")
	}

	// Should track inflight
	stats, _ := bbr.GetStats(ctx, "test-key")
	if stats.Metrics["inflight"] != int64(1) {
		t.Errorf("Expected inflight=1, got %v", stats.Metrics["inflight"])
	}
}

func TestBBRRecordRTT(t *testing.T) {
	bbr := NewBBRLimiter()

	// Record RTT
	bbr.RecordRTT(10 * time.Millisecond)

	stats, _ := bbr.GetStats(context.Background(), "test")
	rttMs := stats.Metrics["rtt_ms"].(int64)

	if rttMs < 9 || rttMs > 11 {
		t.Errorf("Expected RTT ~10ms, got %dms", rttMs)
	}
}

func TestBBRStateTransition(t *testing.T) {
	bbr := NewBBRLimiter()

	ctx := context.Background()

	// Start in STARTUP.
	//
	// Compared against ratelimit.BBRStartup, not against the untyped string
	// "STARTUP". Metrics is a map[string]interface{} and the value in it is a
	// ratelimit.BBRState, so comparing it to a string compares the dynamic
	// types first and is false however the two print — which is why this
	// assertion used to fail with "Expected STARTUP state, got STARTUP".
	stats, err := bbr.GetStats(ctx, "test")
	if err != nil {
		t.Fatalf("GetStats: %v", err)
	}
	if got := stats.Metrics["state"]; got != ratelimit.BBRStartup {
		t.Errorf("Expected %v state, got %v (%T)", ratelimit.BBRStartup, got, got)
	}

	// Record deliveries to trigger state transitions
	for i := 0; i < 50; i++ {
		bbr.RecordDelivery(10, 10*time.Millisecond)
	}

	stats, err = bbr.GetStats(ctx, "test")
	if err != nil {
		t.Fatalf("GetStats: %v", err)
	}

	// The tail of this test used to be a t.Logf and the comment "Should
	// transition through states", which is a test that passes whatever the
	// limiter does — including never leaving STARTUP, which is the failure that
	// matters: a limiter stuck in startup doubles its congestion window on
	// every delivery and stops limiting anything.
	state, ok := stats.Metrics["state"].(ratelimit.BBRState)
	if !ok {
		t.Fatalf("state metric is %T, want ratelimit.BBRState", stats.Metrics["state"])
	}
	if state == ratelimit.BBRStartup {
		t.Error("still in STARTUP after 50 deliveries; the state machine did not advance")
	}
	switch state {
	case ratelimit.BBRDrain, ratelimit.BBRProbeBW, ratelimit.BBRProbeRTT:
	default:
		t.Errorf("unknown state %v", state)
	}

	// The congestion window must stay within its own floor.
	if cwnd := stats.Metrics["cwnd"].(int64); cwnd < 4 {
		t.Errorf("cwnd = %d, below the minimum of 4", cwnd)
	}
}

// PROBE_BW and PROBE_RTT alternate on every delivery when only deliveries are
// recorded, because the interval that gates them is measured in roundCount and
// roundCount only advances in RecordRTT.
//
// PROBE_RTT clamps the congestion window to 4, so a caller that records
// deliveries without also recording round-trip times has its admission window
// collapse to the floor on alternate calls whatever bandwidth it measured. This
// test records the behaviour rather than asserting it is right: it is a real
// defect in the state machine, and changing the gating is a change to
// congestion control that wants its own decision rather than being slipped in
// alongside a test repair.
func TestBBRProbeCyclingWithoutRTTSamples(t *testing.T) {
	bbr := NewBBRLimiter()
	ctx := context.Background()

	for i := 0; i < 10; i++ {
		bbr.RecordDelivery(10, 10*time.Millisecond)
	}

	var seen []ratelimit.BBRState
	for i := 0; i < 4; i++ {
		bbr.RecordDelivery(10, 10*time.Millisecond)
		stats, err := bbr.GetStats(ctx, "test")
		if err != nil {
			t.Fatalf("GetStats: %v", err)
		}
		seen = append(seen, stats.Metrics["state"].(ratelimit.BBRState))
	}

	alternating := seen[0] != seen[1] && seen[0] == seen[2] && seen[1] == seen[3]
	if !alternating {
		t.Logf("states no longer alternate (%v) — if the roundCount gating was "+
			"fixed, this test has served its purpose and can go", seen)
	}
}

func BenchmarkBBRAllow(b *testing.B) {
	bbr := NewBBRLimiter()
	ctx := context.Background()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		bbr.Allow(ctx, "bench-key")
	}
}
