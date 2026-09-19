# Rate Limiter Integration Guide

## Overview

The rate limiter package provides multiple algorithms for controlling request flow across 125+ microservices.

## Integration Points

### 1. Service Mesh Integration

```go
import "p9e.in/samavaya/packages/packages/mesh"
import "p9e.in/samavaya/packages/packages/ratelimit/backend"

// In mesh initialization
limiter := backend.NewPostgresRateLimiter(pool, logger)

// Before routing request
key := fmt.Sprintf("%s:%s", serviceName, clientID)
allowed, err := limiter.Allow(ctx, key)
if !allowed {
    return fmt.Errorf("rate limit exceeded for %s", serviceName)
}

// After response
if err != nil {
    limiter.RecordFailure(ctx, key)
}
```

### 2. Load Balancer Integration

```go
import "p9e.in/samavaya/packages/packages/loadbalancer"
import "p9e.in/samavaya/packages/packages/ratelimit/algorithms"

// Create load balancer
lb := algorithms.NewRoundRobinBalancer()

// When recording metrics
endpoint, _ := lb.Select(ctx, instances)
lb.RecordMetrics(endpoint.Instance.ID, latency, success)
```

### 3. Circuit Breaker Integration

```go
import "p9e.in/samavaya/packages/packages/circuitbreaker"
import "p9e.in/samavaya/packages/packages/ratelimit"

// When circuit breaker is OPEN
result, _ := breaker.Check(ctx, "service:op")
if !result.Allowed {
    // Also apply rate limiting backpressure
    rateLimiter.SetLimit(ctx, key, newLimit/2)
}
```

### 4. HTTP Middleware Integration

```go
import "p9e.in/samavaya/packages/packages/ratelimit/api"

// Create API handler
limiterAPI := api.New(limiter, logger)

// Add to HTTP router
http.Handle("/v1/ratelimit/", limiterAPI)

// Use in middleware
func RateLimitMiddleware(limiter ratelimit.Limiter) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        clientID := getClientID(r) // From auth header
        serviceName := "my-service"
        key := fmt.Sprintf("%s:%s", serviceName, clientID)

        allowed, _ := limiter.Allow(r.Context(), key)
        if !allowed {
            w.Header().Set("Retry-After", "1")
            w.WriteHeader(http.StatusTooManyRequests)
            return
        }

        // Continue processing
    }
}
```

### 5. Outbound gRPC Integration

`ratelimit/grpclimit` pairs the adaptive limiter with a per-call deadline as a
gRPC client interceptor, so no call site can forget to release a slot.

```go
import (
    "p9e.in/samavaya/packages/ratelimit/algorithms"
    "p9e.in/samavaya/packages/ratelimit/grpclimit"
)

conn, err := grpc.NewClient(addr,
    grpcdial.TransportCredentials(),
    grpclimit.WithAdaptiveConcurrency(grpclimit.Options{
        Limiter: algorithms.NewAdaptiveLimiter(),
        Name:    "ai-gateway",   // metrics label
        Timeout: 30 * time.Second,
    }),
)
```

Past the limit the interceptor returns `ResourceExhausted` **without touching
the wire**, which is the point: the dependency being protected should not have
to accept, parse and queue a request before refusing it.

**Outcome classification** decides what each call taught the limiter:

| Result | Bucket | Why |
|---|---|---|
| `OK` | success | its duration is service time, which is what the loop measures |
| `DeadlineExceeded`, `ResourceExhausted`, `Unavailable` | failure | congestion signals; back the limit off multiplicatively |
| everything else | ignore | an `InvalidArgument` returned in 2ms is a fast answer to a bad request — counting it as a latency sample would drag the no-load baseline down and make every honest call look congested |

**Keying** defaults to `PerMethod`. That matters when one server does mixed
work: a vision call answering in seconds and a tabular call answering in
milliseconds should not share a limit, or the slow one sheds the fast one. Use
`PerService` when every method on a server costs about the same.

**Metrics**: `grpc_client_adaptive_admitted_total`,
`grpc_client_adaptive_shed_total` and `grpc_client_adaptive_limit`, labelled by
`target` and `method`.

**Failing open**: if the limiter itself errors, the call proceeds unlimited. A
bug in admission control should not become an outage.

## Database Schema

The rate limiter uses the `rate_limits` table created in Phase 1:

```sql
CREATE TABLE rate_limits (
    key VARCHAR(255) PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    client_id VARCHAR(255),
    allowed_requests BIGINT DEFAULT 0,
    rejected_requests BIGINT DEFAULT 0,
    limit_per_second INT DEFAULT 100,
    window_start TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

## Algorithms

### Token Bucket

Simple and predictable:
```go
limiter := algorithms.NewTokenBucketLimiter(
    100,  // Capacity
    50.0, // Refill rate (tokens per second)
)
```

**Use when:**
- Predictable traffic patterns
- Need simple burst handling
- Per-API key limits

### Adaptive concurrency

No configured rate; the limit is derived from the service's own latency.

```go
adaptive := algorithms.NewAdaptiveLimiter()

lease, ok, err := adaptive.Acquire(ctx, "soil-service")
if err != nil || !ok {
    return errTooManyRequests
}
defer lease.Failure() // replaced by Success on the happy path

resp, err := client.Call(ctx, req)
if err != nil {
    return err // the deferred Failure backs the limit off
}
lease.Success()
```

Exactly one of `Success`, `Failure` or `Ignore` must be called, and `defer`
makes that hard to forget. Calling more than once is a no-op after the first,
so the deferred `Failure` above is safe alongside an explicit `Success`.

Use `Ignore` for work whose duration says nothing about the service — a
cancelled context, a request the caller abandoned — so the limiter does not
learn a latency that was never the service's.

**Use when:**
- Calling a dependency you can overload
- The safe concurrency is not a number you know, and moves
- You want the limit to find capacity rather than be told it

**Tuning:** `AdaptiveConfig` sets only the bounds and how fast the limit moves
(`MinLimit`, `MaxLimit`, `Smoothing`, `DropPenalty`, `LongWindow`). Any zero
field is filled from `DefaultAdaptiveConfig`.

> Replaced `NewBBRLimiter`, which had no callers and a control loop that never
> closed: its window had no path that could grow, its bandwidth estimate only
> ratcheted upward, it computed a bandwidth-delay product from queueing latency,
> it had no failure path for in-flight accounting, and every key shared one
> window.

### Distributed (PostgreSQL)

Multi-instance coordination:
```go
limiter := backend.NewPostgresRateLimiter(pool, logger)

// Automatically syncs every 10 seconds
// Uses advisory locks for coordination
```

**Use when:**
- Multiple instances of same service
- Need consistent rate limiting
- Can tolerate eventual consistency

## Per-Service vs Per-Client

### Per-Service Limit

```go
key := fmt.Sprintf("payment-service")
allowed, _ := limiter.Allow(ctx, key)
```

Limits total requests to a service: 100 req/sec

### Per-Client Limit

```go
clientID := extractClientID(r.Header.Get("Authorization"))
key := fmt.Sprintf("payment-service:%s", clientID)
allowed, _ := limiter.Allow(ctx, key)
```

Limits per API key/user: 10 req/sec per client

### Per-Endpoint Limit

```go
endpoint := r.URL.Path
key := fmt.Sprintf("payment-service:%s:%s", clientID, endpoint)
allowed, _ := limiter.Allow(ctx, key)
```

Different limits for different operations

## Monitoring

### Via HTTP API

```bash
# Check stats
curl -X GET http://localhost:8080/v1/ratelimit/stats/payment-service

# Set new limit
curl -X PUT http://localhost:8080/v1/ratelimit/payment-service \
  -d '{"limit_per_second": 200}'

# Check if request allowed
curl -X POST http://localhost:8080/v1/ratelimit/check/payment-service:client-1 \
  -d '{"tokens": 1}'

# Reset limiter
curl -X POST http://localhost:8080/v1/ratelimit/reset/payment-service
```

### Via Code

```go
stats, _ := limiter.GetStats(ctx, "payment-service")
fmt.Printf("Allowed: %d, Rejected: %d, Limit: %d\n",
    stats.AllowedCount, stats.RejectedCount, stats.CurrentLimit)
```

## Error Handling

```go
allowed, err := limiter.Allow(ctx, key)
if err != nil {
    // Database/infrastructure error
    logger.Error("rate limiter error", "error", err)
    // Fail open or closed based on policy
}

if !allowed {
    // Rate limit hit - normal backpressure
    return ErrRateLimitExceeded
}
```

## Configuration

### Per-Service Limits

In routing policy:

```json
{
  "service_name": "payment-service",
  "rate_limit": {
    "algorithm": "token_bucket",
    "limit_per_second": 1000,
    "burst_capacity": 2000
  }
}
```

### Adaptive Limits

```go
config := ratelimit.RateLimitConfig{
    Algorithm:       ratelimit.AlgorithmAdaptive,
    DefaultLimit:    100,
    EnableAdaptive:  true,
    AdaptiveHighLoad: 0.8,  // Reduce at 80% load
    AdaptiveLowLoad: 0.2,   // Increase at 20% load
}
```

## Testing

```bash
# Run tests
go test ./packages/ratelimit/...

# With coverage
go test -cover ./packages/ratelimit/...

# Benchmarks
go test -bench=. ./packages/ratelimit/algorithms/
```

## Performance

- **Token Bucket**: <1μs per Allow() call
- **Adaptive**: <1μs per Acquire, plus an O(in-flight) sweep at most once a second
- **Distributed**: ~10ms per Allow() call (with DB round trip)

Use local caching with distributed limiter to achieve <100μs latency:
- Cache validity: 10 seconds (configurable)
- Sync interval: 10 seconds (configurable)
- Fallback: Local buffer when cache misses
