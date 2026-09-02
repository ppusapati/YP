package middleware

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
)

// ReadinessChecker determines whether the service is ready to receive traffic.
type ReadinessChecker interface {
	Ping(ctx context.Context) error
}

// NewHealthMux returns an *http.ServeMux pre-wired with operational
// endpoints suitable for an admin/sidecar port:
//
//	GET /health  — liveness probe  (200 + {"status":"ok","service":"<name>"})
//	GET /ready   — readiness probe (200 + {"status":"ready","service":"<name>"})
//	GET /metrics — Prometheus scrape endpoint (default registry)
func NewHealthMux(serviceName string, checkers ...ReadinessChecker) *http.ServeMux {
	mux := http.NewServeMux()

	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]string{
			"status":  "ok",
			"service": serviceName,
		})
	})

	mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
		defer cancel()

		for _, c := range checkers {
			if err := c.Ping(ctx); err != nil {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusServiceUnavailable)
				_ = json.NewEncoder(w).Encode(map[string]string{
					"status":  "unavailable",
					"service": serviceName,
				})
				return
			}
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]string{
			"status":  "ready",
			"service": serviceName,
		})
	})

	mux.Handle("/metrics", PrometheusHandler())

	return mux
}
