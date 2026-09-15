package featureflags

import (
	"context"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/p9context"
)

// flagServiceContextKey is the context key for storing the FlagService.
type flagServiceContextKey struct{}

// flagAttributesContextKey is the context key for storing evaluated attributes.
type flagAttributesContextKey struct{}

// WithFlagService stores a FlagService in the context.
func WithFlagService(ctx context.Context, svc FlagService) context.Context {
	return context.WithValue(ctx, flagServiceContextKey{}, svc)
}

// FromContext retrieves the FlagService from the context.
// Returns nil if no FlagService is present.
func FromContext(ctx context.Context) FlagService {
	svc, _ := ctx.Value(flagServiceContextKey{}).(FlagService)
	return svc
}

// ContextAttributes retrieves the pre-extracted attributes from the context.
// Returns nil if no attributes are present.
func ContextAttributes(ctx context.Context) Attributes {
	attrs, _ := ctx.Value(flagAttributesContextKey{}).(Attributes)
	return attrs
}

// IsEnabledFromContext is a convenience function that retrieves the FlagService
// from the context and evaluates whether the named flag is enabled.
// Returns false if the FlagService is not in context or the flag does not exist.
func IsEnabledFromContext(ctx context.Context, flagName string) bool {
	svc := FromContext(ctx)
	if svc == nil {
		return false
	}
	attrs := ContextAttributes(ctx)
	if attrs == nil {
		attrs = Attributes{}
	}
	return svc.IsEnabled(ctx, flagName, attrs)
}

// GetVariantFromContext is a convenience function that retrieves the FlagService
// from the context and returns the evaluation result for the named flag.
func GetVariantFromContext(ctx context.Context, flagName string) EvaluationResult {
	svc := FromContext(ctx)
	if svc == nil {
		return EvaluationResult{
			FlagName: flagName,
			Enabled:  false,
			Reason:   "no_flag_service_in_context",
		}
	}
	attrs := ContextAttributes(ctx)
	if attrs == nil {
		attrs = Attributes{}
	}
	return svc.GetVariant(ctx, flagName, attrs)
}

// InterceptorOption configures the feature flag interceptor.
type InterceptorOption func(*interceptorConfig)

type interceptorConfig struct {
	flagService FlagService
	// additionalAttrs are static attributes merged into every evaluation.
	additionalAttrs Attributes
}

// WithAdditionalAttributes sets static attributes that are merged into every
// evaluation. These are overridden by JWT-derived attributes if keys overlap.
func WithAdditionalAttributes(attrs Attributes) InterceptorOption {
	return func(c *interceptorConfig) {
		c.additionalAttrs = attrs
	}
}

// FlagInterceptor returns a ConnectRPC unary interceptor that injects the
// FlagService and user/tenant attributes into the request context.
//
// It extracts attributes from the p9context.UserContext (populated by the
// auth interceptor from JWT claims) and makes them available for flag evaluation
// throughout the handler chain.
func FlagInterceptor(flagService FlagService, opts ...InterceptorOption) connect.UnaryInterceptorFunc {
	cfg := &interceptorConfig{
		flagService: flagService,
	}
	for _, opt := range opts {
		opt(cfg)
	}

	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			// Build attributes from context.
			attrs := extractAttributes(ctx)

			// Merge additional static attributes (context values take precedence).
			if cfg.additionalAttrs != nil {
				for k, v := range cfg.additionalAttrs {
					if _, exists := attrs[k]; !exists {
						attrs[k] = v
					}
				}
			}

			// Inject FlagService and attributes into the context.
			ctx = WithFlagService(ctx, cfg.flagService)
			ctx = context.WithValue(ctx, flagAttributesContextKey{}, attrs)

			return next(ctx, req)
		}
	}
}

// extractAttributes builds an Attributes map from the p9context values
// that the auth interceptor sets after JWT validation.
func extractAttributes(ctx context.Context) Attributes {
	attrs := make(Attributes)

	// Extract from UserContext (JWT claims set by auth interceptor).
	if userCtx, ok := p9context.FromUserContext(ctx); ok {
		if userCtx.UserID != "" {
			attrs["user_id"] = userCtx.UserID
		}
		if userCtx.TenantID != "" {
			attrs["tenant_id"] = userCtx.TenantID
		}
		if userCtx.CompanyID != "" {
			attrs["company_id"] = userCtx.CompanyID
		}
		if userCtx.BranchID != "" {
			attrs["branch_id"] = userCtx.BranchID
		}
		if userCtx.Role != "" {
			attrs["user_role"] = userCtx.Role
		}
	}

	// Extract tenant ID from connection info if not already set.
	if _, hasTenant := attrs["tenant_id"]; !hasTenant {
		if tenantID := p9context.TenantIDFromConnectionInfo(ctx); tenantID != "" {
			attrs["tenant_id"] = tenantID
		}
	}

	return attrs
}
