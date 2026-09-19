package grpclimit

import (
	"context"
	"net"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/test/bufconn"
	"google.golang.org/protobuf/types/known/structpb"

	"p9e.in/samavaya/packages/ratelimit/algorithms"
)

// The tests run a real gRPC server over an in-memory listener rather than a
// fake invoker, so the interceptor is exercised through the same path it takes
// in production: real status codes, real deadline propagation, real
// concurrency.

const testMethod = "/test.Service/Call"

// serverBehaviour is what the stub server does with a call.
type serverBehaviour struct {
	mu sync.Mutex

	latency time.Duration
	code    codes.Code // OK for success

	inflight    atomic.Int64
	maxInflight atomic.Int64
	calls       atomic.Int64
}

func (b *serverBehaviour) set(latency time.Duration, code codes.Code) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.latency, b.code = latency, code
}

func (b *serverBehaviour) get() (time.Duration, codes.Code) {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.latency, b.code
}

// handle implements the one method the stub server serves.
func (b *serverBehaviour) handle(ctx context.Context, dec func(any) error) (any, error) {
	b.calls.Add(1)

	n := b.inflight.Add(1)
	for {
		peak := b.maxInflight.Load()
		if n <= peak || b.maxInflight.CompareAndSwap(peak, n) {
			break
		}
	}
	defer b.inflight.Add(-1)

	latency, code := b.get()
	if latency > 0 {
		select {
		case <-time.After(latency):
		case <-ctx.Done():
			return nil, status.FromContextError(ctx.Err()).Err()
		}
	}
	if code != codes.OK {
		return nil, status.Error(code, "stub server")
	}
	return &structpb.Struct{}, nil
}

// newStubServer starts a gRPC server with one unary method on a bufconn.
func newStubServer(t *testing.T) (*grpc.ClientConn, *serverBehaviour, func()) {
	t.Helper()

	behaviour := &serverBehaviour{}
	lis := bufconn.Listen(1 << 20)

	srv := grpc.NewServer(grpc.UnknownServiceHandler(
		func(_ any, stream grpc.ServerStream) error {
			var in structpb.Struct
			if err := stream.RecvMsg(&in); err != nil {
				return err
			}
			out, err := behaviour.handle(stream.Context(), nil)
			if err != nil {
				return err
			}
			return stream.SendMsg(out)
		},
	))

	go func() { _ = srv.Serve(lis) }()

	conn, err := grpc.NewClient("passthrough:///bufnet",
		grpc.WithContextDialer(func(ctx context.Context, _ string) (net.Conn, error) {
			return lis.DialContext(ctx)
		}),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		t.Fatalf("dial: %v", err)
	}

	return conn, behaviour, func() {
		_ = conn.Close()
		srv.Stop()
		_ = lis.Close()
	}
}

// call invokes the stub method through the interceptor.
func call(ctx context.Context, conn *grpc.ClientConn, icept grpc.UnaryClientInterceptor) error {
	invoker := func(ctx context.Context, method string, req, reply any, cc *grpc.ClientConn, opts ...grpc.CallOption) error {
		return cc.Invoke(ctx, method, req, reply, opts...)
	}
	return icept(ctx, testMethod, &structpb.Struct{}, &structpb.Struct{}, conn, invoker)
}

func newIcept(t *testing.T, cfg algorithms.AdaptiveConfig, timeout time.Duration) (grpc.UnaryClientInterceptor, *algorithms.AdaptiveLimiter) {
	t.Helper()
	lim := algorithms.NewAdaptiveLimiterWithConfig(cfg)
	return UnaryClientInterceptor(Options{
		Limiter: lim,
		Timeout: timeout,
		Name:    t.Name(),
	}), lim
}

// ── Shedding ────────────────────────────────────────────────────────────────

// Past the limit the interceptor refuses locally, without touching the wire.
//
// That is the whole point: the gateway is the thing being protected, so a call
// it would have had to accept, parse and queue before refusing must not reach
// it at all.
func TestShedsWithoutReachingTheServer(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, _ := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 3, MinLimit: 1, MaxLimit: 3,
		SampleWindow: 1000, LongWindow: time.Hour,
	}, 0)

	behaviour.set(200*time.Millisecond, codes.OK)

	// Three concurrent calls fill the limit and stay in flight.
	var wg sync.WaitGroup
	for i := 0; i < 3; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			_ = call(context.Background(), conn, icept)
		}()
	}

	// Give them time to be admitted and reach the server.
	deadline := time.After(2 * time.Second)
	for behaviour.inflight.Load() < 3 {
		select {
		case <-deadline:
			t.Fatalf("only %d calls reached the server", behaviour.inflight.Load())
		case <-time.After(time.Millisecond):
		}
	}

	before := behaviour.calls.Load()
	err := call(context.Background(), conn, icept)
	after := behaviour.calls.Load()

	if status.Code(err) != codes.ResourceExhausted {
		t.Fatalf("got %v, want ResourceExhausted", err)
	}
	if after != before {
		t.Errorf("the refused call still reached the server (%d -> %d)", before, after)
	}

	wg.Wait()
}

// A refusal must release nothing and admit the next caller once room appears.
func TestRecoversAfterShedding(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, _ := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 2, MinLimit: 1, MaxLimit: 2,
		SampleWindow: 1000, LongWindow: time.Hour,
	}, 0)

	behaviour.set(0, codes.OK)

	for i := 0; i < 20; i++ {
		if err := call(context.Background(), conn, icept); err != nil {
			t.Fatalf("sequential call %d refused: %v", i, err)
		}
	}
}

// ── Deadlines ───────────────────────────────────────────────────────────────

// A call with no deadline gets one, so a wedged server cannot hold a lease
// until the sweeper reclaims it.
func TestAppliesDeadlineWhenCallerHasNone(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, _ := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 5, MinLimit: 1, MaxLimit: 5,
		SampleWindow: 1000, LongWindow: time.Hour,
	}, 100*time.Millisecond)

	behaviour.set(5*time.Second, codes.OK) // far longer than the deadline

	start := time.Now()
	err := call(context.Background(), conn, icept)
	elapsed := time.Since(start)

	if status.Code(err) != codes.DeadlineExceeded {
		t.Fatalf("got %v, want DeadlineExceeded", err)
	}
	if elapsed > time.Second {
		t.Errorf("call took %v; the interceptor's deadline was not applied", elapsed)
	}
}

// A caller's shorter deadline must win.
func TestDoesNotExtendACallersDeadline(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, _ := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 5, MinLimit: 1, MaxLimit: 5,
		SampleWindow: 1000, LongWindow: time.Hour,
	}, 10*time.Second)

	behaviour.set(5*time.Second, codes.OK)

	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	start := time.Now()
	err := call(ctx, conn, icept)
	elapsed := time.Since(start)

	if status.Code(err) != codes.DeadlineExceeded {
		t.Fatalf("got %v, want DeadlineExceeded", err)
	}
	if elapsed > time.Second {
		t.Errorf("call took %v; the interceptor overrode the caller's shorter deadline", elapsed)
	}
}

// ── Outcome classification ──────────────────────────────────────────────────

// The three buckets, checked through the limiter's own accounting.
func TestClassification(t *testing.T) {
	cases := []struct {
		name string
		code codes.Code
		want outcome
	}{
		{"ok", codes.OK, outcomeSuccess},
		{"deadline exceeded", codes.DeadlineExceeded, outcomeFailure},
		{"resource exhausted", codes.ResourceExhausted, outcomeFailure},
		{"unavailable", codes.Unavailable, outcomeFailure},
		{"invalid argument", codes.InvalidArgument, outcomeIgnore},
		{"not found", codes.NotFound, outcomeIgnore},
		{"permission denied", codes.PermissionDenied, outcomeIgnore},
		{"unauthenticated", codes.Unauthenticated, outcomeIgnore},
		{"internal", codes.Internal, outcomeIgnore},
		{"unimplemented", codes.Unimplemented, outcomeIgnore},
		{"canceled", codes.Canceled, outcomeIgnore},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var err error
			if tc.code != codes.OK {
				err = status.Error(tc.code, "x")
			}
			if got := classify(err); got != tc.want {
				t.Errorf("classify(%v) = %v, want %v", tc.code, got, tc.want)
			}
		})
	}
}

// A server that is failing for congestion reasons backs the limit off.
func TestCongestionErrorsBackOffTheLimit(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, lim := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 40, MinLimit: 2, MaxLimit: 100,
		SampleWindow: 2, DropPenalty: 0.5, LongWindow: time.Hour,
	}, time.Second)

	before := limitOf(t, lim, testMethod)

	behaviour.set(0, codes.Unavailable)
	for i := 0; i < 20; i++ {
		if err := call(context.Background(), conn, icept); status.Code(err) != codes.Unavailable {
			// Once the limit collapses the interceptor sheds instead, which is
			// the behaviour under test; stop here.
			break
		}
	}

	after := limitOf(t, lim, testMethod)
	if after >= before {
		t.Fatalf("limit %v did not back off from %v under Unavailable", after, before)
	}
	t.Logf("limit %v -> %v under Unavailable", before, after)
}

// A server rejecting bad requests quickly must not be mistaken for a fast
// server, or the no-load baseline it teaches makes every real call look slow.
func TestBadRequestsDoNotTeachTheBaseline(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, lim := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 10, MinLimit: 1, MaxLimit: 50,
		SampleWindow: 2, LongWindow: time.Hour,
	}, time.Second)

	// Real work takes 50ms.
	behaviour.set(50*time.Millisecond, codes.OK)
	for i := 0; i < 6; i++ {
		if err := call(context.Background(), conn, icept); err != nil {
			t.Fatalf("setup call %d: %v", i, err)
		}
	}
	baseline := noLoadOf(t, lim, testMethod)
	if baseline <= 0 {
		t.Fatal("no baseline was learned from the successful calls")
	}

	// A burst of instant rejections.
	behaviour.set(0, codes.InvalidArgument)
	for i := 0; i < 20; i++ {
		_ = call(context.Background(), conn, icept)
	}

	if got := noLoadOf(t, lim, testMethod); got < baseline {
		t.Errorf("no-load baseline fell from %dms to %dms on instant "+
			"InvalidArgument responses", baseline, got)
	}
}

// ── Accounting ──────────────────────────────────────────────────────────────

// Every admitted call releases its lease, whatever the server did.
func TestEveryOutcomeReleasesItsLease(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, lim := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 10, MinLimit: 1, MaxLimit: 10,
		SampleWindow: 1000, LongWindow: time.Hour,
	}, 500*time.Millisecond)

	for _, code := range []codes.Code{
		codes.OK, codes.InvalidArgument, codes.Unavailable,
		codes.NotFound, codes.ResourceExhausted, codes.Internal,
	} {
		behaviour.set(0, code)
		for i := 0; i < 3; i++ {
			_ = call(context.Background(), conn, icept)
		}
	}

	// And a call the server never answers in time.
	behaviour.set(2*time.Second, codes.OK)
	_ = call(context.Background(), conn, icept)

	if got := inflightOf(t, lim, testMethod); got != 0 {
		t.Errorf("inflight = %d after every call completed, want 0", got)
	}
}

// A cancelled caller releases without teaching the limiter anything.
func TestCallerCancellationIsIgnored(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, lim := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 5, MinLimit: 1, MaxLimit: 5,
		SampleWindow: 1000, LongWindow: time.Hour,
	}, 0)

	behaviour.set(2*time.Second, codes.OK)

	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan error, 1)
	go func() { done <- call(ctx, conn, icept) }()

	time.Sleep(50 * time.Millisecond)
	cancel()

	select {
	case <-done:
	case <-time.After(3 * time.Second):
		t.Fatal("cancelled call never returned")
	}

	if got := inflightOf(t, lim, testMethod); got != 0 {
		t.Errorf("inflight = %d after a cancelled call, want 0", got)
	}
	if got := noLoadOf(t, lim, testMethod); got != 0 {
		t.Errorf("a cancelled call taught the limiter a %dms baseline", got)
	}
}

// ── Keying ──────────────────────────────────────────────────────────────────

// A slow method must not shed a fast one.
//
// This is the reason the limiter is per key. One limit across a vision model
// and a tabular model would be set by whichever is busier.
func TestSlowMethodDoesNotShedFastMethod(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	lim := algorithms.NewAdaptiveLimiterWithConfig(algorithms.AdaptiveConfig{
		InitialLimit: 2, MinLimit: 1, MaxLimit: 2,
		SampleWindow: 1000, LongWindow: time.Hour,
	})
	icept := UnaryClientInterceptor(Options{Limiter: lim, Name: t.Name()})

	invoker := func(ctx context.Context, method string, req, reply any, cc *grpc.ClientConn, opts ...grpc.CallOption) error {
		return cc.Invoke(ctx, method, req, reply, opts...)
	}
	invoke := func(method string) error {
		return icept(context.Background(), method, &structpb.Struct{}, &structpb.Struct{}, conn, invoker)
	}

	behaviour.set(300*time.Millisecond, codes.OK)

	const slow = "/test.Service/Slow"
	const fast = "/test.Service/Fast"

	var wg sync.WaitGroup
	for i := 0; i < 2; i++ {
		wg.Add(1)
		go func() { defer wg.Done(); _ = invoke(slow) }()
	}

	deadline := time.After(2 * time.Second)
	for behaviour.inflight.Load() < 2 {
		select {
		case <-deadline:
			t.Fatal("the slow calls never filled their limit")
		case <-time.After(time.Millisecond):
		}
	}

	// Slow is full; Fast has its own budget and must still be admitted.
	if err := invoke(slow); status.Code(err) != codes.ResourceExhausted {
		t.Fatalf("slow method: got %v, want ResourceExhausted", err)
	}
	if err := invoke(fast); status.Code(err) == codes.ResourceExhausted {
		t.Error("the fast method was shed because a different method was busy")
	}

	wg.Wait()
}

func TestPerServiceKeyer(t *testing.T) {
	cases := map[string]string{
		"/agriculture.ai.v1.AIGatewayService/RecommendCrops": "/agriculture.ai.v1.AIGatewayService",
		"/pkg.Svc/M": "/pkg.Svc",
		"nomethod":   "nomethod",
	}
	for in, want := range cases {
		if got := PerService(in); got != want {
			t.Errorf("PerService(%q) = %q, want %q", in, got, want)
		}
	}
}

// ── Failing open ────────────────────────────────────────────────────────────

// Concurrent traffic through the interceptor must not corrupt the accounting.
func TestConcurrentTraffic(t *testing.T) {
	conn, behaviour, stop := newStubServer(t)
	defer stop()

	icept, lim := newIcept(t, algorithms.AdaptiveConfig{
		InitialLimit: 20, MinLimit: 2, MaxLimit: 60,
		SampleWindow: 5, LongWindow: time.Second,
	}, 2*time.Second)

	behaviour.set(time.Millisecond, codes.OK)

	var wg sync.WaitGroup
	for g := 0; g < 12; g++ {
		wg.Add(1)
		go func(g int) {
			defer wg.Done()
			for i := 0; i < 40; i++ {
				if g%4 == 0 && i%7 == 0 {
					behaviour.set(time.Millisecond, codes.Unavailable)
				} else if i%11 == 0 {
					behaviour.set(time.Millisecond, codes.OK)
				}
				_ = call(context.Background(), conn, icept)
			}
		}(g)
	}
	wg.Wait()

	if got := inflightOf(t, lim, testMethod); got != 0 {
		t.Errorf("inflight = %d after every call returned, want 0", got)
	}
	limit := limitOf(t, lim, testMethod)
	if limit < 2 || limit > 60 {
		t.Errorf("limit %v escaped its clamps", limit)
	}
}

// ── helpers ─────────────────────────────────────────────────────────────────

func limitOf(t *testing.T, lim *algorithms.AdaptiveLimiter, key string) int64 {
	t.Helper()
	return metricOf(t, lim, key, "limit")
}

func inflightOf(t *testing.T, lim *algorithms.AdaptiveLimiter, key string) int64 {
	t.Helper()
	return metricOf(t, lim, key, "inflight")
}

func noLoadOf(t *testing.T, lim *algorithms.AdaptiveLimiter, key string) int64 {
	t.Helper()
	return metricOf(t, lim, key, "no_load_rtt_ms")
}

func metricOf(t *testing.T, lim *algorithms.AdaptiveLimiter, key, metric string) int64 {
	t.Helper()
	stats, err := lim.GetStats(context.Background(), key)
	if err != nil {
		t.Fatalf("GetStats: %v", err)
	}
	v, ok := stats.Metrics[metric].(int64)
	if !ok {
		t.Fatalf("metric %q is %T, want int64", metric, stats.Metrics[metric])
	}
	return v
}
