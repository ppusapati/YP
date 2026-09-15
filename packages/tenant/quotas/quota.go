// Package quotas provides per-tenant quota tracking and enforcement.
// It supports rate-based quotas (API requests per hour) and absolute quotas
// (storage, users, fields/farms).
package quotas

import (
	"context"
	"fmt"
	"sync"
	"time"

	"p9e.in/samavaya/packages/p9log"
)

// QuotaManager tracks and enforces per-tenant limits.
type QuotaManager struct {
	store    QuotaStore
	cacheMu  sync.RWMutex
	// configCache caches tenant quota configs to avoid DB lookups on every request.
	configCache map[string]*cachedQuotaConfig
	cacheTTL    time.Duration
	// windowDuration is the measurement window for rate-based quotas.
	windowDuration time.Duration
	// nowFunc allows tests to control time.
	nowFunc func() time.Time
}

type cachedQuotaConfig struct {
	config   *QuotaConfig
	cachedAt time.Time
}

// ManagerOption is a functional option for configuring QuotaManager.
type ManagerOption func(*QuotaManager)

// WithCacheTTL sets the cache TTL for quota configs.
func WithCacheTTL(ttl time.Duration) ManagerOption {
	return func(m *QuotaManager) {
		m.cacheTTL = ttl
	}
}

// WithWindowDuration sets the measurement window for rate-based quotas.
func WithWindowDuration(d time.Duration) ManagerOption {
	return func(m *QuotaManager) {
		m.windowDuration = d
	}
}

// WithNowFunc sets the time function (useful for testing).
func WithNowFunc(fn func() time.Time) ManagerOption {
	return func(m *QuotaManager) {
		m.nowFunc = fn
	}
}

// NewQuotaManager creates a new QuotaManager.
func NewQuotaManager(store QuotaStore, opts ...ManagerOption) *QuotaManager {
	m := &QuotaManager{
		store:          store,
		configCache:    make(map[string]*cachedQuotaConfig),
		cacheTTL:       5 * time.Minute,
		windowDuration: 1 * time.Hour,
		nowFunc:        time.Now,
	}
	for _, opt := range opts {
		opt(m)
	}
	return m
}

// Check verifies that the tenant has not exceeded the given quota type.
// It does NOT increment usage; use CheckAndIncrement for that.
func (m *QuotaManager) Check(ctx context.Context, tenantID string, quotaType QuotaType) error {
	usage, err := m.store.GetUsage(ctx, tenantID, quotaType)
	if err != nil {
		return fmt.Errorf("check quota: %w", err)
	}

	// For rate-based quotas, check if the window has expired.
	if quotaType == QuotaAPIRequests {
		if m.isWindowExpired(usage.WindowStart) {
			// Window has expired, usage should be reset. This is not an error.
			return nil
		}
	}

	if usage.IsExceeded() {
		return &QuotaExceededError{
			TenantID:     tenantID,
			Type:         quotaType,
			CurrentUsage: usage.CurrentUsage,
			Limit:        usage.Limit,
		}
	}

	return nil
}

// CheckAndIncrement verifies the quota and atomically increments usage by delta.
// Returns a QuotaExceededError if the increment would exceed the limit.
func (m *QuotaManager) CheckAndIncrement(ctx context.Context, tenantID string, quotaType QuotaType, delta int64) error {
	// For rate-based quotas, check window expiry first.
	if quotaType == QuotaAPIRequests {
		if err := m.resetWindowIfExpired(ctx, tenantID, quotaType); err != nil {
			p9log.Errorf("quota: failed to reset expired window for tenant %s: %v", tenantID, err)
			// Continue anyway; let the increment proceed.
		}
	}

	// Get the limit to do a pre-check.
	config, err := m.getConfig(ctx, tenantID)
	if err != nil {
		return fmt.Errorf("get quota config: %w", err)
	}

	limit, ok := config.Limits[quotaType]
	if !ok {
		// No limit configured for this type; allow the request.
		return nil
	}

	// Atomically increment.
	usage, err := m.store.IncrementUsage(ctx, tenantID, quotaType, delta)
	if err != nil {
		return fmt.Errorf("increment quota usage: %w", err)
	}

	// Check if the post-increment value exceeds the limit.
	if usage.CurrentUsage > limit {
		// Roll back the increment by decrementing.
		if _, rollbackErr := m.store.IncrementUsage(ctx, tenantID, quotaType, -delta); rollbackErr != nil {
			p9log.Errorf("quota: failed to rollback increment for tenant %s: %v", tenantID, rollbackErr)
		}
		return &QuotaExceededError{
			TenantID:     tenantID,
			Type:         quotaType,
			CurrentUsage: usage.CurrentUsage - delta, // report pre-increment value
			Limit:        limit,
		}
	}

	return nil
}

// GetUsageSummary returns usage for all quota types for a tenant.
func (m *QuotaManager) GetUsageSummary(ctx context.Context, tenantID string) ([]QuotaUsage, error) {
	return m.store.GetAllUsage(ctx, tenantID)
}

// SetLimits configures quota limits for a tenant and invalidates the cache.
func (m *QuotaManager) SetLimits(ctx context.Context, config QuotaConfig) error {
	if err := m.store.SetLimits(ctx, config); err != nil {
		return err
	}
	m.invalidateCache(config.TenantID)
	return nil
}

// getConfig returns cached or fresh quota config for a tenant.
func (m *QuotaManager) getConfig(ctx context.Context, tenantID string) (*QuotaConfig, error) {
	m.cacheMu.RLock()
	cached, ok := m.configCache[tenantID]
	m.cacheMu.RUnlock()

	if ok && time.Since(cached.cachedAt) < m.cacheTTL {
		return cached.config, nil
	}

	config, err := m.store.GetLimits(ctx, tenantID)
	if err != nil {
		return nil, err
	}

	m.cacheMu.Lock()
	m.configCache[tenantID] = &cachedQuotaConfig{
		config:   config,
		cachedAt: m.nowFunc(),
	}
	m.cacheMu.Unlock()

	return config, nil
}

// invalidateCache removes a tenant from the config cache.
func (m *QuotaManager) invalidateCache(tenantID string) {
	m.cacheMu.Lock()
	delete(m.configCache, tenantID)
	m.cacheMu.Unlock()
}

// isWindowExpired checks whether the rate-limiting window has elapsed.
func (m *QuotaManager) isWindowExpired(windowStart time.Time) bool {
	return m.nowFunc().Sub(windowStart) >= m.windowDuration
}

// resetWindowIfExpired resets usage counters when the rate window has passed.
func (m *QuotaManager) resetWindowIfExpired(ctx context.Context, tenantID string, quotaType QuotaType) error {
	usage, err := m.store.GetUsage(ctx, tenantID, quotaType)
	if err != nil {
		// Usage might not exist yet, which is fine.
		return nil
	}

	if m.isWindowExpired(usage.WindowStart) {
		return m.store.ResetUsage(ctx, tenantID, quotaType)
	}

	return nil
}
