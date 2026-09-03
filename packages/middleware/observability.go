// Package middleware provides ConnectRPC interceptors for observability.
//
// MetricsInterceptor records Prometheus counters and histograms for every
// unary RPC call. TracingInterceptor creates an OpenTelemetry span per call
// and annotates it with service, method, tenant, and request identifiers.
//
// Both interceptors are designed to sit early in the interceptor chain
// (after recovery and request-ID, before auth/business logic) so that every
// request — successful or not — is observed.
package middleware

import (
	"context"
	"net/http"
	"time"

	"connectrpc.com/connect"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"

	"p9e.in/samavaya/packages/p9context"
)

// ── Prometheus metrics (registered once on the default registry) ────────────

var (
	rpcRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "rpc_requests_total",
			Help: "Total number of RPC requests handled, partitioned by service, method, and status code.",
		},
		[]string{"service", "method", "status_code"},
	)

	rpcRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "rpc_request_duration_seconds",
			Help:    "Histogram of RPC request latencies in seconds, partitioned by service and method.",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"service", "method"},
	)
)

// MetricsInterceptor returns a ConnectRPC unary interceptor that records
// rpc_requests_total (counter) and rpc_request_duration_seconds (histogram)
// for every request.
func MetricsInterceptor(serviceName string) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			start := time.Now()
			method := req.Spec().Procedure

			resp, err := next(ctx, req)

			duration := time.Since(start)
			statusCode := "ok"
			if err != nil {
				statusCode = connect.CodeOf(err).String()
			}

			rpcRequestsTotal.WithLabelValues(serviceName, method, statusCode).Inc()
			rpcRequestDuration.WithLabelValues(serviceName, method).Observe(duration.Seconds())

			return resp, err
		}
	}
}

// TracingInterceptor returns a ConnectRPC unary interceptor that creates an
// OpenTelemetry span for each RPC call.  The span carries:
//   - rpc.service  — the service name passed in
//   - rpc.method   — the ConnectRPC procedure string
//   - tenant_id    — extracted from p9context (if present)
//   - request_id   — extracted from p9context (if present)
//
// On error the span records the error and sets status to codes.Error.
func TracingInterceptor(serviceName string) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			tracer := otel.Tracer(serviceName)
			method := req.Spec().Procedure

			ctx, span := tracer.Start(ctx, method,
				trace.WithSpanKind(trace.SpanKindServer),
			)
			defer span.End()

			span.SetAttributes(
				attribute.String("rpc.service", serviceName),
				attribute.String("rpc.method", method),
			)

			if tenantID := p9context.TenantID(ctx); tenantID != "" {
				span.SetAttributes(attribute.String("tenant_id", tenantID))
			}
			if requestID := p9context.RequestID(ctx); requestID != "" {
				span.SetAttributes(attribute.String("request_id", requestID))
			}

			resp, err := next(ctx, req)

			if err != nil {
				span.RecordError(err)
				span.SetStatus(codes.Error, err.Error())
			} else {
				span.SetStatus(codes.Ok, "")
			}

			return resp, err
		}
	}
}

// PrometheusHandler returns an http.Handler that serves Prometheus metrics
// from the default registry.  Mount it on your admin mux at /metrics.
func PrometheusHandler() http.Handler {
	return promhttp.Handler()
}
