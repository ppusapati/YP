package quotas

import (
	"context"
	"fmt"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// QuotaInterceptorOption configures the quota interceptor.
type QuotaInterceptorOption func(*quotaInterceptorConfig)

type quotaInterceptorConfig struct {
	// skipProcedures are RPC procedures exempt from quota checks.
	skipProcedures map[string]struct{}
	// quotaTypes are the quota dimensions to check on every request.
	quotaTypes []QuotaType
}

// WithSkipProcedures exempts the given RPC procedures from quota enforcement.
func WithSkipProcedures(procedures ...string) QuotaInterceptorOption {
	return func(c *quotaInterceptorConfig) {
		for _, p := range procedures {
			c.skipProcedures[p] = struct{}{}
		}
	}
}

// WithQuotaTypes sets which quota types to check per request.
// Defaults to QuotaAPIRequests if not set.
func WithQuotaTypes(types ...QuotaType) QuotaInterceptorOption {
	return func(c *quotaInterceptorConfig) {
		c.quotaTypes = types
	}
}

// QuotaInterceptor returns a ConnectRPC unary interceptor that checks per-tenant
// quotas before processing each request. It reads the tenant ID from the
// authenticated user context (set by the auth interceptor) and checks the
// configured quota types.
//
// If any quota is exceeded, it returns connect.CodeResourceExhausted.
func QuotaInterceptor(manager *QuotaManager, opts ...QuotaInterceptorOption) connect.UnaryInterceptorFunc {
	cfg := &quotaInterceptorConfig{
		skipProcedures: make(map[string]struct{}),
		quotaTypes:     []QuotaType{QuotaAPIRequests},
	}
	for _, opt := range opts {
		opt(cfg)
	}

	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			procedure := req.Spec().Procedure

			// Skip exempt procedures.
			if _, skip := cfg.skipProcedures[procedure]; skip {
				return next(ctx, req)
			}

			// Extract tenant ID from the authenticated user context.
			tenantID := p9context.TenantID(ctx)
			if tenantID == "" {
				// No tenant context; skip quota check (unauthenticated endpoints).
				return next(ctx, req)
			}

			// Check each configured quota type.
			for _, qt := range cfg.quotaTypes {
				var err error
				if qt == QuotaAPIRequests {
					// Rate-based: increment the counter atomically.
					err = manager.CheckAndIncrement(ctx, tenantID, qt, 1)
				} else {
					// Absolute quotas: check without incrementing.
					err = manager.Check(ctx, tenantID, qt)
				}

				if err != nil {
					if IsQuotaExceeded(err) {
						p9log.Context(ctx).Warnf("quota interceptor: %v", err)
						return nil, connect.NewError(
							connect.CodeResourceExhausted,
							fmt.Errorf("quota exceeded: %s", qt),
						)
					}
					// Non-quota errors are logged but do not block the request.
					p9log.Context(ctx).Errorf("quota interceptor: error checking quota %s: %v", qt, err)
				}
			}

			return next(ctx, req)
		}
	}
}
