// Package ratelimit provides rate and concurrency limiting for the platform's
// services.
//
// # Choosing between them
//
// Two different questions, two different tools:
//
//   - TokenBucket answers "how many requests per second may this caller make",
//     which is what you want when the limit is a policy: a quota, a tier, an
//     agreement. You know the number because you chose it.
//
//   - AdaptiveLimiter answers "how much work can this service take right now",
//     which is what you want when the limit is a property of the service rather
//     than a decision about the caller. You do not know the number, and it
//     moves — so it is measured instead of configured.
//
//   - Distributed coordinates a token bucket's state across instances in
//     PostgreSQL, for when the limit is per-fleet rather than per-process.
//
// Reach for the token bucket at the edge, facing clients. Reach for the
// adaptive limiter in front of a dependency you can overload.
//
// # Token Bucket
//
// A configured rate with burst capacity:
//   - Capacity: maximum tokens in the bucket
//   - Refill rate: tokens added per second
//   - Each request consumes one token
//   - Bursts are allowed up to the capacity
//
// State is kept per key, so one caller exhausting its bucket does not affect
// another.
//
// # Adaptive Concurrency
//
// A ceiling on in-flight requests, derived from the service's own latency:
//   - The smallest latency seen recently is the service's cost with no queue
//   - The ratio of that to the current latency says how deep the queue is
//   - The limit follows that ratio, probing upward when there is no queue
//   - Failures back the limit off multiplicatively
//
// Nothing is configured except the bounds it may move between. The window over
// which the no-load latency is remembered rotates, so the estimate rises when a
// service genuinely becomes slower rather than treating the new normal as
// permanent congestion.
//
// This replaced a BBRLimiter. That implementation carried BBR's vocabulary over
// a control loop that never closed — a congestion window with no path that
// could raise it, a bandwidth estimate that could only ratchet up, a BDP
// computed from queueing latency, no failure path for in-flight accounting, and
// one window shared by every key. None of it had a caller. The name is gone
// along with it, because the four-state machine is about pacing packets over a
// link and this is about admitting requests to a service.
//
// # Usage
//
//	// Token bucket: a rate you chose.
//	limiter := algorithms.NewTokenBucketLimiter(100, 50.0) // burst 100, 50 req/sec
//	if ok, _ := limiter.Allow(ctx, clientID); !ok {
//	    return errTooManyRequests
//	}
//
//	// Adaptive: a concurrency the service tells you.
//	//
//	// Acquire returns a lease; exactly one of Success, Failure or Ignore must
//	// be called, which defer makes hard to forget. Failure is the deferred
//	// default so an early return or a panic still backs the limiter off.
//	adaptive := algorithms.NewAdaptiveLimiter()
//
//	lease, ok, err := adaptive.Acquire(ctx, "soil-service")
//	if err != nil || !ok {
//	    return errTooManyRequests
//	}
//	defer lease.Failure()
//
//	resp, err := client.Call(ctx, req)
//	if err != nil {
//	    return err // the deferred Failure backs the limit off
//	}
//	lease.Success()
//
//	// Distributed (multi-instance)
//	pool := pgxpool.New(ctx, connString)
//	distributed := backend.NewPostgresRateLimiter(pool, logger)
//
//	allowed, err := distributed.Allow(ctx, "service-name", "client-id")
//	if allowed {
//	    processRequest()
//	}
//
// # Per-Service vs Per-Client Limits
//
// The rate limiter supports multiple scopes:
//
//   - Global limit: All requests to a service
//   - Per-client limit: Per API key / user ID
//   - Per-endpoint limit: Different limits for different operations
//
// # Distributed Rate Limiting
//
// For multi-instance deployments:
//   - Shared state in PostgreSQL
//   - Advisory locks for coordination
//   - Fast local caching with sync-back
//   - Configurable sync interval (default 10 seconds)
//
// # Circuit Breaker Integration
//
// When rate limiter rejects requests:
//   - Record in metrics
//   - Update dependency tracking
//   - Consider circuit breaker state
//   - Return 429 Too Many Requests (HTTP) or RESOURCE_EXHAUSTED (gRPC)
package ratelimit
