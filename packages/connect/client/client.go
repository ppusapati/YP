// Package client provides a factory for creating ConnectRPC HTTP clients suitable
// for internal service-to-service communication (h2c, no TLS, circuit breaker, retries).
package client

import (
	"context"
	"net"
	"net/http"
	"time"

	"golang.org/x/net/http2"

	"p9e.in/samavaya/packages/circuitbreaker"
)

// Config holds the configuration for an internal service client.
type Config struct {
	// BaseURL is the target service base URL (e.g., "http://farm-service:8080").
	BaseURL string

	// Timeout is the per-request deadline. Defaults to 30s.
	Timeout time.Duration

	// MaxIdleConns controls the connection pool size.
	MaxIdleConns int

	// MaxConnsPerHost limits concurrent connections to a single host.
	MaxConnsPerHost int

	// CircuitBreaker configures failure detection. Nil disables it.
	CircuitBreaker *CircuitBreakerConfig
}

// CircuitBreakerConfig tunes the circuit breaker for outbound calls.
type CircuitBreakerConfig struct {
	// MaxFailures is the number of consecutive errors before opening. Default 5.
	MaxFailures int32
	// SuccessThreshold is the number of successes to close from half-open. Default 2.
	SuccessThreshold int32
	// Timeout is how long the circuit stays open before probing. Default 30s.
	Timeout time.Duration
}

// defaultConfig fills in zero values.
func defaultConfig(cfg Config) Config {
	if cfg.Timeout == 0 {
		cfg.Timeout = 30 * time.Second
	}
	if cfg.MaxIdleConns == 0 {
		cfg.MaxIdleConns = 100
	}
	if cfg.MaxConnsPerHost == 0 {
		cfg.MaxConnsPerHost = 20
	}
	return cfg
}

// NewHTTPClient creates a pre-configured *http.Client for calling internal services
// over h2c (HTTP/2 cleartext, no TLS). All inter-service calls should use this
// client so they share consistent timeout, pooling, and circuit-breaker behaviour.
//
// Pass the returned *http.Client as the first argument to any generated Connect
// client constructor (e.g., farmv1connect.NewFarmServiceClient).
func NewHTTPClient(cfg Config) *http.Client {
	cfg = defaultConfig(cfg)

	// h2c transport: HTTP/2 without TLS, required for Connect binary (grpc) protocol.
	transport := &http2.Transport{
		AllowHTTP: true,
		DialTLSContext: func(ctx context.Context, network, addr string, _ interface{}) (net.Conn, error) {
			return (&net.Dialer{
				Timeout:   10 * time.Second,
				KeepAlive: 30 * time.Second,
			}).DialContext(ctx, network, addr)
		},
	}

	base := &http.Client{
		Timeout:   cfg.Timeout,
		Transport: transport,
	}

	if cfg.CircuitBreaker == nil {
		return base
	}

	cbCfg := circuitbreaker.SimpleConfig{
		MaxFailures:      cfg.CircuitBreaker.MaxFailures,
		SuccessThreshold: cfg.CircuitBreaker.SuccessThreshold,
		Timeout:          cfg.CircuitBreaker.Timeout,
	}
	if cbCfg.MaxFailures == 0 {
		cbCfg.MaxFailures = 5
	}
	if cbCfg.SuccessThreshold == 0 {
		cbCfg.SuccessThreshold = 2
	}
	if cbCfg.Timeout == 0 {
		cbCfg.Timeout = 30 * time.Second
	}

	cb := circuitbreaker.NewSimpleCircuitBreaker(cbCfg)
	return &http.Client{
		Timeout:   cfg.Timeout,
		Transport: &circuitBreakerTransport{inner: transport, cb: cb},
	}
}

// DefaultConfig returns a Config with sensible defaults for a given service URL.
func DefaultConfig(baseURL string) Config {
	return Config{
		BaseURL: baseURL,
		CircuitBreaker: &CircuitBreakerConfig{
			MaxFailures:      5,
			SuccessThreshold: 2,
			Timeout:          30 * time.Second,
		},
	}
}

// circuitBreakerTransport wraps an http.RoundTripper with a circuit breaker.
type circuitBreakerTransport struct {
	inner http.RoundTripper
	cb    *circuitbreaker.SimpleCircuitBreaker
}

func (t *circuitBreakerTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	var resp *http.Response
	err := t.cb.Execute(req.Context(), func(ctx context.Context) error {
		var e error
		resp, e = t.inner.RoundTrip(req.WithContext(ctx))
		return e
	})
	return resp, err
}
