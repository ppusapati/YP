package interceptors

import (
	"context"
	"fmt"
	"regexp"
	"sync"
	"unicode"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
)

var (
	// tenantIDPattern validates tenant IDs: alphanumeric, underscores, hyphens only
	tenantIDPattern = regexp.MustCompile(`^[a-zA-Z0-9_-]+$`)

	// Maximum tenant ID length to prevent abuse
	maxTenantIDLength = 64
)

// TenantHeader is the header for tenant identification.
const TenantHeader = "X-Tenant-Name"

// DBPoolResolver resolves database pools for tenants.
type DBPoolResolver interface {
	// ResolvePool returns the database pool for the given tenant ID.
	// Returns the shared pool if tenantID is empty or for shared tenants.
	ResolvePool(ctx context.Context, tenantID string) (*pgxpool.Pool, error)
}

// SimpleDBPoolResolver implements DBPoolResolver with shared and independent pools.
type SimpleDBPoolResolver struct {
	sharedPool      *pgxpool.Pool
	independentPool map[string]*pgxpool.Pool
	sharedTenants   map[string]struct{}
	poolConfig      IndependentPoolConfig
	mu              sync.RWMutex
}

// IndependentPoolConfig holds configuration for creating independent tenant pools.
type IndependentPoolConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	SSLMode  string
}

// NewSimpleDBPoolResolver creates a new SimpleDBPoolResolver.
func NewSimpleDBPoolResolver(sharedPool *pgxpool.Pool, poolConfig IndependentPoolConfig) *SimpleDBPoolResolver {
	return &SimpleDBPoolResolver{
		sharedPool:      sharedPool,
		independentPool: make(map[string]*pgxpool.Pool),
		sharedTenants:   make(map[string]struct{}),
		poolConfig:      poolConfig,
	}
}

// RegisterSharedTenant marks a tenant as using the shared database.
func (r *SimpleDBPoolResolver) RegisterSharedTenant(tenantID string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.sharedTenants[tenantID] = struct{}{}
}

// ResolvePool returns the database pool for the given tenant ID.
func (r *SimpleDBPoolResolver) ResolvePool(ctx context.Context, tenantID string) (*pgxpool.Pool, error) {
	// Empty tenant ID uses shared database
	if tenantID == "" {
		return r.sharedPool, nil
	}

	// Validate tenant ID
	sanitizedID, err := sanitizeTenantID(tenantID)
	if err != nil {
		return nil, err
	}

	// Check if shared tenant
	r.mu.RLock()
	_, isShared := r.sharedTenants[sanitizedID]
	// If no shared tenants configured, default to shared
	if len(r.sharedTenants) == 0 {
		isShared = true
	}
	r.mu.RUnlock()

	if isShared {
		return r.sharedPool, nil
	}

	// Get or create independent pool
	r.mu.Lock()
	defer r.mu.Unlock()

	if pool, exists := r.independentPool[sanitizedID]; exists {
		return pool, nil
	}

	// Create new pool for tenant
	connStr := fmt.Sprintf(
		"user=%s password=%s host=%s port=%d dbname=%s sslmode=%s",
		r.poolConfig.User,
		r.poolConfig.Password,
		r.poolConfig.Host,
		r.poolConfig.Port,
		sanitizedID, // Use tenant ID as database name
		r.poolConfig.SSLMode,
	)

	pool, err := pgxpool.New(ctx, connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to create pool for tenant %s: %w", sanitizedID, err)
	}

	r.independentPool[sanitizedID] = pool
	return pool, nil
}

// DBInterceptorOption configures the DB interceptor.
type DBInterceptorOption func(*dbConfig)

type dbConfig struct {
	resolver DBPoolResolver
}

// WithDBPoolResolver sets the pool resolver.
func WithDBPoolResolver(resolver DBPoolResolver) DBInterceptorOption {
	return func(c *dbConfig) {
		c.resolver = resolver
	}
}

// DBInterceptor returns a Connect interceptor that resolves the database pool.
// It stores the resolved pool in context using p9context.NewDBPoolContext.
// If the X-Tenant-Name header is present, it is validated against the
// authenticated user's tenant ID from JWT claims.
func DBInterceptor(sharedPool *pgxpool.Pool, opts ...DBInterceptorOption) connect.UnaryInterceptorFunc {
	cfg := &dbConfig{}
	for _, opt := range opts {
		opt(cfg)
	}

	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			var pool *pgxpool.Pool
			var err error

			tenantID := req.Header().Get(TenantHeader)

			// Cross-validate: if authenticated user context exists, the header
			// tenant must match the JWT tenant to prevent routing to another
			// tenant's database.
			if user, ok := p9context.FromUserContext(ctx); ok && user != nil && user.TenantID != "" {
				if tenantID != "" && tenantID != user.TenantID {
					p9log.Context(ctx).Warnf("db interceptor: X-Tenant-Name header %q does not match JWT tenant %q — rejecting",
						tenantID, user.TenantID)
					return nil, connect.NewError(connect.CodePermissionDenied, fmt.Errorf("tenant mismatch"))
				}
				if tenantID == "" {
					tenantID = user.TenantID
				}
			}

			if cfg.resolver != nil {
				pool, err = cfg.resolver.ResolvePool(ctx, tenantID)
				if err != nil {
					p9log.Context(ctx).Errorf("db interceptor: failed to resolve pool: %v", err)
					return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("failed to resolve database"))
				}
			} else {
				pool = sharedPool
			}

			if pool == nil {
				p9log.Context(ctx).Error("db interceptor: no database pool available")
				return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("no database pool"))
			}

			ctx = p9context.NewDBPoolContext(ctx, pool)

			return next(ctx, req)
		}
	}
}

// sanitizeTenantID validates and sanitizes the tenantID.
func sanitizeTenantID(tenantID string) (string, error) {
	if tenantID == "" {
		return "", nil
	}

	// Check length
	if len(tenantID) > maxTenantIDLength {
		return "", fmt.Errorf("tenant ID exceeds maximum length of %d characters", maxTenantIDLength)
	}

	// Check for valid characters only
	if !tenantIDPattern.MatchString(tenantID) {
		return "", fmt.Errorf("tenant ID contains invalid characters")
	}

	// Additional validation for database name safety
	for _, r := range tenantID {
		if !unicode.IsLetter(r) && !unicode.IsDigit(r) && r != '_' && r != '-' {
			return "", fmt.Errorf("invalid character in tenant ID: %c", r)
		}
	}

	return tenantID, nil
}
