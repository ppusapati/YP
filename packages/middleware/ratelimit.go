package middleware

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"connectrpc.com/connect"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"

	"p9e.in/samavaya/packages/ratelimit/algorithms"
)

// RateLimitConfig configures HTTP rate limiting.
type RateLimitConfig struct {
	RequestsPerSecond float64
	BurstSize         float64
	KeyFunc           func(*http.Request) string
	Enabled           bool
}

// DefaultRateLimitConfig returns defaults suitable for a single service instance.
func DefaultRateLimitConfig() RateLimitConfig {
	return RateLimitConfig{
		RequestsPerSecond: 100,
		BurstSize:         200,
		KeyFunc:           clientIPKey,
		Enabled:           true,
	}
}

func clientIPKey(r *http.Request) string {
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		if first, _, ok := strings.Cut(xff, ","); ok {
			return strings.TrimSpace(first)
		}
		return strings.TrimSpace(xff)
	}
	if addr, _, ok := strings.Cut(r.RemoteAddr, ":"); ok {
		return addr
	}
	return r.RemoteAddr
}

var (
	rateLimitRejectedTotal = promauto.NewCounter(
		prometheus.CounterOpts{
			Name: "http_rate_limit_rejected_total",
			Help: "Total HTTP requests rejected by rate limiting.",
		},
	)
)

// RateLimitMiddleware returns HTTP middleware that enforces per-client-IP rate
// limits using a token bucket. Rejected requests receive 429 with Retry-After.
func RateLimitMiddleware(cfg RateLimitConfig) func(http.Handler) http.Handler {
	if !cfg.Enabled {
		return func(next http.Handler) http.Handler { return next }
	}

	limiter := algorithms.NewTokenBucketLimiter(cfg.BurstSize, cfg.RequestsPerSecond)
	keyFunc := cfg.KeyFunc
	if keyFunc == nil {
		keyFunc = clientIPKey
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			key := keyFunc(r)
			allowed, _ := limiter.Allow(r.Context(), key)
			if !allowed {
				rateLimitRejectedTotal.Inc()
				w.Header().Set("Content-Type", "application/json")
				w.Header().Set("Retry-After", "1")
				w.WriteHeader(http.StatusTooManyRequests)
				_ = json.NewEncoder(w).Encode(map[string]string{
					"error":   "rate_limit_exceeded",
					"message": "too many requests",
				})
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// RPCRateLimitInterceptor returns a ConnectRPC unary interceptor that rate-limits
// per client IP extracted from HTTP headers. The key combines the client IP with
// the RPC procedure for per-endpoint granularity.
func RPCRateLimitInterceptor(requestsPerSecond, burstSize float64) connect.UnaryInterceptorFunc {
	limiter := algorithms.NewTokenBucketLimiter(burstSize, requestsPerSecond)

	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			ip := req.Header().Get("X-Forwarded-For")
			if ip != "" {
				if first, _, ok := strings.Cut(ip, ","); ok {
					ip = strings.TrimSpace(first)
				} else {
					ip = strings.TrimSpace(ip)
				}
			} else {
				ip = req.Peer().Addr
			}

			key := ip + ":" + req.Spec().Procedure
			allowed, _ := limiter.Allow(ctx, key)
			if !allowed {
				rateLimitRejectedTotal.Inc()
				return nil, connect.NewError(
					connect.CodeResourceExhausted,
					fmt.Errorf("rate limit exceeded"),
				)
			}
			return next(ctx, req)
		}
	}
}
