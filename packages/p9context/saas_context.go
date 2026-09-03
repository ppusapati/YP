package p9context

import (
	"context"
	"fmt"

	"p9e.in/samavaya/packages/saas"
)

type (
	currentTenantCtx  struct{}
	tenantResolveRes  struct{}
	connectionInfoCtx struct{}
)

// NewCurrentTenant creates a new context with the tenant ID and name.
func NewCurrentTenant(ctx context.Context, id, name string) context.Context {
	return NewCurrentTenantInfo(ctx, saas.NewBasicTenantInfo(id, name))
}

// NewCurrentTenantInfo creates a new context with the given tenant info.
func NewCurrentTenantInfo(ctx context.Context, info saas.TenantInfo) context.Context {
	return context.WithValue(ctx, currentTenantCtx{}, info)
}

// FromCurrentTenant extracts tenant info from the context.
// Returns the tenant info and true if found, or an empty tenant info and false if not found.
func FromCurrentTenant(ctx context.Context) (saas.TenantInfo, bool) {
	value, ok := ctx.Value(currentTenantCtx{}).(saas.TenantInfo)
	if ok {
		return value, true
	}
	return saas.NewBasicTenantInfo("", ""), false
}

func NewTenantResolveRes(ctx context.Context, t *saas.TenantResolveResult) context.Context {
	return context.WithValue(ctx, tenantResolveRes{}, t)
}

func FromTenantResolveRes(ctx context.Context) *saas.TenantResolveResult {
	v, ok := ctx.Value(tenantResolveRes{}).(*saas.TenantResolveResult)
	if ok {
		return v
	}
	return nil
}

// NewConnectionInfo stores ConnectionInfo in the context
func NewConnectionInfo(ctx context.Context, info *saas.ConnectionInfo) context.Context {
	return context.WithValue(ctx, connectionInfoCtx{}, info)
}

// FromConnectionInfo retrieves ConnectionInfo from context
// Returns nil and false if not present
func FromConnectionInfo(ctx context.Context) (*saas.ConnectionInfo, bool) {
	v, ok := ctx.Value(connectionInfoCtx{}).(*saas.ConnectionInfo)
	if ok && v != nil {
		return v, true
	}
	return nil, false
}

// MustConnectionInfo retrieves ConnectionInfo from context
// Returns error if not present
func MustConnectionInfo(ctx context.Context) (*saas.ConnectionInfo, error) {
	info, ok := FromConnectionInfo(ctx)
	if !ok {
		return nil, fmt.Errorf("connection info not found in context")
	}
	return info, nil
}

// TenantIDFromConnectionInfo retrieves just the tenant ID from ConnectionInfo in context
// Returns empty string if not present
func TenantIDFromConnectionInfo(ctx context.Context) string {
	info, ok := FromConnectionInfo(ctx)
	if !ok {
		return ""
	}
	return info.TenantID
}

// TenantID returns the authenticated tenant ID.
// It reads from the JWT-validated UserContext first (set by AuthInterceptor),
// falling back to ConnectionInfo only when UserContext is absent.
// This ensures tenant identity is sourced from verified JWT claims, not
// unverified headers.
func TenantID(ctx context.Context) string {
	if id := UserTenantID(ctx); id != "" {
		return id
	}
	return TenantIDFromConnectionInfo(ctx)
}
