package ratelimit

import (
	"context"
	"time"
)

// Algorithm represents a rate limiting algorithm type
type Algorithm string

const (
	// AlgorithmTokenBucket enforces a configured rate with burst capacity.
	AlgorithmTokenBucket Algorithm = "token_bucket"

	// AlgorithmAdaptive bounds concurrency from measured latency degradation,
	// with no configured rate. See algorithms.AdaptiveLimiter.
	AlgorithmAdaptive Algorithm = "adaptive"

	// AlgorithmDistributed coordinates limits across instances in PostgreSQL.
	AlgorithmDistributed Algorithm = "distributed"
)

// Limiter defines the rate limiting interface
type Limiter interface {
	// Allow checks if a request is allowed
	// Returns true if request is allowed, false if rate limit exceeded
	Allow(ctx context.Context, key string) (bool, error)

	// AllowN allows N requests (batch operation)
	AllowN(ctx context.Context, key string, n int) (bool, error)

	// Reserve reserves capacity for a future request
	// Returns a Reservation that can be cancelled
	Reserve(ctx context.Context, key string) (*Reservation, error)

	// GetStats returns current rate limit stats
	GetStats(ctx context.Context, key string) (*Stats, error)

	// Reset resets rate limit state for a key
	Reset(ctx context.Context, key string) error
}

// Reservation represents a reserved capacity for a future request
type Reservation struct {
	// Unique reservation ID
	ID string

	// When the request can be made
	ReadyAt time.Time

	// How long to wait before making the request
	Delay time.Duration

	// Whether the reservation was successful
	OK bool
}

// Stats contains rate limit statistics
type Stats struct {
	// The rate limit key (service, client, etc.)
	Key string

	// Current number of allowed requests in window
	AllowedCount int64

	// Current number of rejected requests in window
	RejectedCount int64

	// Current rate limit (requests per second)
	CurrentLimit int64

	// When the current window started
	WindowStart time.Time

	// When the current window ends
	WindowEnd time.Time

	// Additional metrics
	Metrics map[string]interface{}
}

// RateLimitConfig defines configuration for a rate limiter
type RateLimitConfig struct {
	// Algorithm to use
	Algorithm Algorithm

	// Default limit (requests per second)
	DefaultLimit int64

	// Burst capacity (for token bucket)
	BurstCapacity int64

	// Window size (for sliding window)
	WindowSize time.Duration

	// Whether to enable adaptive limits
	EnableAdaptive bool

	// Adaptive thresholds
	AdaptiveHighLoad   float64 // Load threshold to reduce limit (0.0-1.0, default 0.8)
	AdaptiveLowLoad    float64 // Load threshold to increase limit (0.0-1.0, default 0.2)
	AdaptiveMultiplier float64 // Adjustment multiplier (default 1.2)
}

// DefaultRateLimitConfig returns sensible defaults
func DefaultRateLimitConfig() RateLimitConfig {
	return RateLimitConfig{
		Algorithm:          AlgorithmTokenBucket,
		DefaultLimit:       100,
		BurstCapacity:      200,
		WindowSize:         1 * time.Second,
		EnableAdaptive:     false,
		AdaptiveHighLoad:   0.8,
		AdaptiveLowLoad:    0.2,
		AdaptiveMultiplier: 1.2,
	}
}

// RateLimitPolicy defines per-service rate limit policy
type RateLimitPolicy struct {
	// Service name
	ServiceName string

	// Default limit (requests per second)
	DefaultLimit int64

	// Per-client limit (map of client_id -> limit)
	ClientLimits map[string]int64

	// Per-endpoint limit (map of endpoint -> limit)
	EndpointLimits map[string]int64

	// Algorithm to use
	Algorithm Algorithm

	// Burst capacity
	BurstCapacity int64

	// Custom metadata
	Metadata map[string]string
}

// Options for rate limiter configuration
type Options struct {
	// Configuration
	Config RateLimitConfig

	// Enable rate limit enforcement (if false, allows all requests)
	Enabled bool

	// Metrics callback (called when rate limit is hit)
	OnRateLimitHit func(ctx context.Context, key string)

	// Custom header name for rate limit info
	RateLimitHeader string
}

// DefaultOptions returns sensible defaults
func DefaultOptions() Options {
	return Options{
		Config:          DefaultRateLimitConfig(),
		Enabled:         true,
		RateLimitHeader: "X-RateLimit-Limit",
	}
}

// Option is a functional option for configuring rate limiter
type Option func(*Options)

// WithAlgorithm sets the rate limiting algorithm
func WithAlgorithm(algo Algorithm) Option {
	return func(o *Options) {
		o.Config.Algorithm = algo
	}
}

// WithDefaultLimit sets the default rate limit
func WithDefaultLimit(limit int64) Option {
	return func(o *Options) {
		o.Config.DefaultLimit = limit
	}
}

// WithBurstCapacity sets the burst capacity
func WithBurstCapacity(capacity int64) Option {
	return func(o *Options) {
		o.Config.BurstCapacity = capacity
	}
}

// WithEnabled enables or disables rate limit enforcement
func WithEnabled(enabled bool) Option {
	return func(o *Options) {
		o.Enabled = enabled
	}
}

// WithOnRateLimitHit sets the callback for rate limit hits
func WithOnRateLimitHit(callback func(ctx context.Context, key string)) Option {
	return func(o *Options) {
		o.OnRateLimitHit = callback
	}
}

// AdaptiveMetrics describes what an adaptive concurrency limiter exposes.
//
// It replaces a BBRMetrics that named a bandwidth estimate, a bandwidth-delay
// product and four BBR states. Those were the wrong quantities for admitting
// requests to a service: a service has no bottleneck bandwidth to estimate, and
// the BDP computed from queueing latency drives the window the wrong way. What
// is worth reporting is the limit, how much of it is in use, the latency the
// service shows when idle, the latency it is showing now, and the ratio between
// them that moves the limit.
type AdaptiveMetrics struct {
	// Limit is the current concurrency ceiling.
	Limit int64

	// InFlight is how much of it is in use.
	InFlight int64

	// NoLoadRTT is the smallest latency seen recently, which is the service's
	// cost with no queue in front of it. Windowed, so it rises when the
	// service genuinely becomes slower.
	NoLoadRTT time.Duration

	// SampleRTT is the smallest latency in the window just measured.
	SampleRTT time.Duration

	// Gradient is NoLoadRTT/SampleRTT: 1 when there is no queue, falling
	// toward 0 as one builds. Zero means the last window contained a failure
	// and no gradient was computed from it.
	Gradient float64

	// Allowed and Rejected count admissions and refusals for the key.
	Allowed  int64
	Rejected int64
}
