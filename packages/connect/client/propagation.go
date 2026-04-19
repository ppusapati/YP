package client

import (
	"context"
	"net/http"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/connect/interceptors"
	"p9e.in/samavaya/packages/p9context"
)

const (
	// headerAuthorization is the standard auth header forwarded on inter-service calls.
	headerAuthorization = "Authorization"
	// headerTenantName is the multi-tenant identifier header (see interceptors.TenantHeader).
	headerTenantName = "X-Tenant-Name"
	// headerRequestID is the distributed-trace correlation header.
	headerRequestID = interceptors.RequestIDHeader
	// headerTraceID is the trace ID header.
	headerTraceID = interceptors.TraceIDHeader
)

type rawTokenContextKey struct{}

// WithRawToken stores the raw Bearer JWT in the context so that
// ContextPropagator can forward it on outbound inter-service calls.
//
// Call this in your inbound auth middleware after validating the token:
//
//	ctx = client.WithRawToken(ctx, rawJWT)
func WithRawToken(ctx context.Context, token string) context.Context {
	return context.WithValue(ctx, rawTokenContextKey{}, token)
}

// RawTokenFromContext retrieves the raw Bearer JWT stored by WithRawToken.
// Returns empty string if not set.
func RawTokenFromContext(ctx context.Context) string {
	if tok, ok := ctx.Value(rawTokenContextKey{}).(string); ok {
		return tok
	}
	return ""
}

// ContextPropagator is a connect.UnaryInterceptorFunc that reads tracing and
// tenant values from the incoming Go context and copies them into outgoing
// Connect request headers.  Attach this interceptor to every peer-service client
// so that tenant isolation, distributed tracing, and auth tokens flow through
// the entire call chain automatically.
//
// Usage:
//
//	farmClient := farmv1connect.NewFarmServiceClient(
//	    client.NewHTTPClient(client.DefaultConfig(cfg.FarmServiceURL)),
//	    cfg.FarmServiceURL,
//	    connect.WithInterceptors(client.ContextPropagator()),
//	)
func ContextPropagator() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			propagateHeaders(ctx, req)
			return next(ctx, req)
		}
	}
}

// propagateHeaders copies context values into the outbound request header set.
func propagateHeaders(ctx context.Context, req connect.AnyRequest) {
	// Request / trace correlation
	if id := p9context.RequestID(ctx); id != "" {
		req.Header().Set(headerRequestID, id)
	}
	if rc, ok := p9context.FromRequestContext(ctx); ok && rc.TraceID != "" {
		req.Header().Set(headerTraceID, rc.TraceID)
	}

	// Tenant identifier for multi-tenancy
	if tenantID := p9context.TenantID(ctx); tenantID != "" {
		req.Header().Set(headerTenantName, tenantID)
	}

	// JWT forwarding: forward raw token stored via WithRawToken.
	if tok := RawTokenFromContext(ctx); tok != "" {
		req.Header().Set(headerAuthorization, "Bearer "+tok)
	}
}

// ServiceCallOption returns a connect.Option that attaches the ContextPropagator
// plus any caller-supplied options.  Use this as a convenience when constructing
// peer clients in cmd/server/main.go.
func ServiceCallOption(extra ...connect.Option) connect.Option {
	opts := append([]connect.Option{connect.WithInterceptors(ContextPropagator())}, extra...)
	return connect.WithOptions(opts...)
}

// MachineHTTPClient creates an *http.Client and injects a fixed service-account
// Bearer token into every request.  Use this for background jobs or consumers
// that have no incoming user JWT to forward.
func MachineHTTPClient(cfg Config, serviceAccountToken string) *http.Client {
	base := NewHTTPClient(cfg)
	return &http.Client{
		Timeout:   base.Timeout,
		Transport: &tokenInjectingTransport{inner: base.Transport, token: serviceAccountToken},
	}
}

// tokenInjectingTransport injects a fixed Bearer token into every request.
type tokenInjectingTransport struct {
	inner http.RoundTripper
	token string
}

func (t *tokenInjectingTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	if t.token != "" {
		clone := req.Clone(req.Context())
		clone.Header.Set(headerAuthorization, "Bearer "+t.token)
		req = clone
	}
	return t.inner.RoundTrip(req)
}
