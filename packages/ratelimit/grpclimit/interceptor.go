// Package grpclimit bounds what a gRPC client will ask of a server.
//
// # Why a client-side limit
//
// The platform's nine AI-calling services dial one ai-gateway. At their
// autoscalers' ceilings that is seventy caller pods, each holding a connection
// the gateway allows 256 concurrent streams on, against two gateway replicas
// with no autoscaler of their own. The gateway's own guard —
// `concurrency_limit_per_connection` — is per connection, so it rises with the
// number of callers instead of capping the total: the ceiling is seventy times
// 256, not 256.
//
// A server can refuse work, but by the time it does it has already paid to
// accept, parse and queue it, and every caller is still waiting on a reply that
// is now slower for everyone. A caller that declines to send is the cheaper
// refusal, and it is the only one that can keep a shared dependency out of
// collapse when the callers outnumber it.
//
// # What the interceptor does
//
// Per call, in order: take a lease from the adaptive limiter, apply a deadline
// if the context has none, invoke, then report the outcome by gRPC status code.
// Being an interceptor rather than a helper at each call site is the point —
// eleven hand-placed leases across nine services is eleven chances to forget
// one, and a forgotten lease is a slot that never comes back.
package grpclimit

import (
	"context"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"p9e.in/samavaya/packages/ratelimit/algorithms"
)

// Keyer derives a limiter key from a gRPC method name such as
// "/agriculture.ai.v1.AIGatewayService/RecommendCrops".
type Keyer func(fullMethod string) string

// PerMethod gives every RPC its own limit.
//
// The right default for a gateway serving mixed work. RecommendCrops is a
// tabular model answering in milliseconds and DiagnosePlant is a vision model
// answering in seconds; one limit across both would be set by whichever is
// busier, and a slow batch of image work would shed crop recommendations that
// the gateway had ample room for.
func PerMethod(fullMethod string) string { return fullMethod }

// PerService groups a whole service behind one limit, for a server whose
// methods all cost about the same.
func PerService(fullMethod string) string {
	// "/pkg.Service/Method" -> "/pkg.Service"
	for i := len(fullMethod) - 1; i > 0; i-- {
		if fullMethod[i] == '/' {
			return fullMethod[:i]
		}
	}
	return fullMethod
}

// Options configures the interceptor.
type Options struct {
	// Limiter is shared across the calls this interceptor sees. Required.
	Limiter *algorithms.AdaptiveLimiter

	// Key selects the limiter key. Defaults to PerMethod.
	Key Keyer

	// Timeout is applied when the caller's context carries no earlier
	// deadline. Zero leaves the context alone.
	//
	// Worth setting. None of the nine AI clients set one, so a call to a
	// wedged gateway hung until something upstream gave up — and for the
	// limiter specifically, a call with no deadline holds its lease until the
	// sweeper reclaims it, which is the slowest way to learn anything.
	Timeout time.Duration

	// Name labels this interceptor's metrics, e.g. "ai-gateway".
	Name string
}

var (
	admitted = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "grpc_client_adaptive_admitted_total",
		Help: "Outbound gRPC calls admitted by the adaptive concurrency limiter.",
	}, []string{"target", "method"})

	shed = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "grpc_client_adaptive_shed_total",
		Help: "Outbound gRPC calls refused locally by the adaptive concurrency limiter.",
	}, []string{"target", "method"})

	limitGauge = promauto.NewGaugeVec(prometheus.GaugeOpts{
		Name: "grpc_client_adaptive_limit",
		Help: "Current concurrency limit the adaptive limiter has settled on.",
	}, []string{"target", "method"})
)

// UnaryClientInterceptor returns an interceptor that bounds concurrency and
// applies a deadline.
func UnaryClientInterceptor(opts Options) grpc.UnaryClientInterceptor {
	if opts.Limiter == nil {
		panic("grpclimit: Options.Limiter is required")
	}
	if opts.Key == nil {
		opts.Key = PerMethod
	}
	name := opts.Name
	if name == "" {
		name = "unnamed"
	}

	return func(
		ctx context.Context,
		method string,
		req, reply any,
		cc *grpc.ClientConn,
		invoker grpc.UnaryInvoker,
		callOpts ...grpc.CallOption,
	) error {
		key := opts.Key(method)

		lease, ok, err := opts.Limiter.Acquire(ctx, key)
		if err != nil {
			// The limiter failing is not a reason to refuse traffic; it is a
			// reason to stop limiting. Failing open here is deliberate: a bug
			// in admission control should not become an outage.
			return invoker(ctx, method, req, reply, cc, callOpts...)
		}
		if !ok {
			shed.WithLabelValues(name, method).Inc()
			recordLimit(opts.Limiter, name, method, key)
			return status.Errorf(codes.ResourceExhausted,
				"%s: local concurrency limit reached for %s", name, method)
		}
		admitted.WithLabelValues(name, method).Inc()

		if opts.Timeout > 0 {
			if _, hasDeadline := ctx.Deadline(); !hasDeadline {
				var cancel context.CancelFunc
				ctx, cancel = context.WithTimeout(ctx, opts.Timeout)
				defer cancel()
			}
		}

		// Failure by default, replaced below by the outcome the status code
		// implies. If invoker panics, the deferred release still runs and the
		// slot comes back.
		defer lease.Failure()

		callErr := invoker(ctx, method, req, reply, cc, callOpts...)

		switch classify(callErr) {
		case outcomeSuccess:
			lease.Success()
		case outcomeFailure:
			lease.Failure()
		default:
			lease.Ignore()
		}

		recordLimit(opts.Limiter, name, method, key)
		return callErr
	}
}

// WithAdaptiveConcurrency is the dial option form, for adding to an existing
// grpc.NewClient call in one line.
func WithAdaptiveConcurrency(opts Options) grpc.DialOption {
	return grpc.WithChainUnaryInterceptor(UnaryClientInterceptor(opts))
}

type outcome int

const (
	outcomeSuccess outcome = iota
	outcomeFailure
	outcomeIgnore
)

// classify decides what a call's result says about the server's queue.
//
// Three buckets, and the third is the one that is easy to get wrong.
//
//   - Success is a completed call. Its duration is service time, which is what
//     the limiter measures.
//
//   - Failure is a congestion signal: the server ran out of time, said it was
//     out of resources, or was unreachable. These back the limit off
//     multiplicatively, because a struggling server is not reporting its queue
//     depth, it is asking to be left alone.
//
//   - Ignore is everything else, and it is not the same as success. An
//     InvalidArgument returned in two milliseconds is a fast answer to a
//     malformed request; counting it as a latency sample would drag the no-load
//     minimum down toward two milliseconds and make every honest call afterwards
//     look congested by comparison. A cancelled call is the caller leaving, and
//     says nothing about the server at all.
func classify(err error) outcome {
	if err == nil {
		return outcomeSuccess
	}

	switch status.Code(err) {
	case codes.DeadlineExceeded, codes.ResourceExhausted, codes.Unavailable:
		return outcomeFailure
	default:
		return outcomeIgnore
	}
}

func recordLimit(lim *algorithms.AdaptiveLimiter, name, method, key string) {
	stats, err := lim.GetStats(context.Background(), key)
	if err != nil || stats == nil {
		return
	}
	if v, ok := stats.Metrics["limit"].(int64); ok {
		limitGauge.WithLabelValues(name, method).Set(float64(v))
	}
}
