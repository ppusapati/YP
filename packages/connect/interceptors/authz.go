package interceptors

import (
	"context"
	"strings"

	"connectrpc.com/connect"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

// Role represents a user role with a defined hierarchy.
type Role string

const (
	RoleViewer  Role = "viewer"
	RoleWorker  Role = "worker"
	RoleManager Role = "manager"
	RoleAdmin   Role = "admin"

	// RolePlatform operates the platform itself, across tenants.
	//
	// Every role below it is scoped to one tenant: an `admin` is the highest
	// authority *within* their tenant and has no business seeing another's
	// data. This one exists because operating the platform requires a view
	// that crosses that boundary — which tenants exist, which are healthy,
	// what they are consuming — and that view is a deliberate hole in the
	// isolation model rather than an extension of tenant admin.
	//
	// It therefore must not be grantable by a tenant admin, and anything it
	// reaches should be aggregate rather than a tenant's actual records. See
	// packages/tenant/admin.
	RolePlatform Role = "platform"
)

var roleRank = map[Role]int{
	RoleViewer:   0,
	RoleWorker:   1,
	RoleManager:  2,
	RoleAdmin:    3,
	RolePlatform: 4,
}

// RoleAtLeast returns true if the user's role is at least the required role
// in the hierarchy: viewer < worker < manager < admin < platform.
//
// Note that platform now satisfies every check written as
// RoleAtLeast(role, RoleAdmin). That is intended — a platform operator can do
// anything a tenant admin can — but it means adding a role above admin widened
// what those existing checks admit, which is worth knowing when reading them.
func RoleAtLeast(userRole, requiredRole Role) bool {
	ur, ok1 := roleRank[userRole]
	rr, ok2 := roleRank[requiredRole]
	if !ok1 || !ok2 {
		return false
	}
	return ur >= rr
}

// AuthzRule maps a ConnectRPC procedure to its minimum required role.
type AuthzRule struct {
	Procedure   string
	MinimumRole Role
}

type authzConfig struct {
	procedureRoles map[string]Role
	defaultRole    Role
}

// AuthzOption configures the Authz interceptor.
type AuthzOption func(*authzConfig)

// WithProcedureRole sets the minimum role for a specific procedure.
func WithProcedureRole(procedure string, minRole Role) AuthzOption {
	return func(c *authzConfig) {
		c.procedureRoles[procedure] = minRole
	}
}

// WithProcedureRoles sets minimum roles for multiple procedures.
func WithProcedureRoles(rules []AuthzRule) AuthzOption {
	return func(c *authzConfig) {
		for _, r := range rules {
			c.procedureRoles[r.Procedure] = r.MinimumRole
		}
	}
}

// WithDefaultMinRole sets the default minimum role when no explicit rule
// or verb-based inference applies. Defaults to RoleViewer.
func WithDefaultMinRole(role Role) AuthzOption {
	return func(c *authzConfig) {
		c.defaultRole = role
	}
}

// AuthzInterceptor returns a Connect interceptor that enforces role-based
// access control. It must be placed after the AuthInterceptor in the chain
// so that the user context is available.
//
// The minimum required role for a procedure is resolved in order:
//  1. Explicit per-procedure rule (set via WithProcedureRole/WithProcedureRoles)
//  2. Verb-based inference from the method name (Delete/Transfer/Remove → manager,
//     Create/Update/Set/Assign/Place/Cancel → worker, everything else → viewer)
//  3. The configured default (WithDefaultMinRole, defaults to viewer)
func AuthzInterceptor(opts ...AuthzOption) connect.UnaryInterceptorFunc {
	cfg := &authzConfig{
		procedureRoles: make(map[string]Role),
		defaultRole:    RoleViewer,
	}
	for _, opt := range opts {
		opt(cfg)
	}

	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			procedure := req.Spec().Procedure

			userRole := Role(p9context.UserRole(ctx))
			if userRole == "" {
				p9log.Context(ctx).Warn("authz interceptor: no role in user context")
				return nil, connect.NewError(connect.CodePermissionDenied, nil)
			}

			required := cfg.resolveRole(procedure)

			if !RoleAtLeast(userRole, required) {
				p9log.Context(ctx).Warnf(
					"authz interceptor: role %q insufficient for %s (requires %s)",
					userRole, procedure, required,
				)
				return nil, connect.NewError(connect.CodePermissionDenied, nil)
			}

			return next(ctx, req)
		}
	}
}

func (c *authzConfig) resolveRole(procedure string) Role {
	if role, ok := c.procedureRoles[procedure]; ok {
		return role
	}
	return inferRoleFromVerb(procedure, c.defaultRole)
}

// inferRoleFromVerb extracts the method name from a procedure like
// "/agriculture.farm.v1.FarmService/DeleteFarm" and maps destructive
// verbs to manager, write verbs to worker, and everything else to the default.
func inferRoleFromVerb(procedure string, fallback Role) Role {
	idx := strings.LastIndex(procedure, "/")
	if idx < 0 {
		return fallback
	}
	method := procedure[idx+1:]

	switch {
	case strings.HasPrefix(method, "Delete"),
		strings.HasPrefix(method, "Transfer"),
		strings.HasPrefix(method, "Remove"):
		return RoleManager
	case strings.HasPrefix(method, "Create"),
		strings.HasPrefix(method, "Update"),
		strings.HasPrefix(method, "Set"),
		strings.HasPrefix(method, "Assign"),
		strings.HasPrefix(method, "Place"),
		strings.HasPrefix(method, "Cancel"),
		strings.HasPrefix(method, "Request"),
		strings.HasPrefix(method, "Record"):
		return RoleWorker
	default:
		return fallback
	}
}
