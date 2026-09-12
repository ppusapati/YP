package quotas

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- In-memory mock store ---

type mockQuotaStore struct {
	mu     sync.Mutex
	limits map[string]map[QuotaType]int64    // tenantID -> type -> limit
	usage  map[string]map[QuotaType]*QuotaUsage // tenantID -> type -> usage
	getUsageErr error
}

func newMockQuotaStore() *mockQuotaStore {
	return &mockQuotaStore{
		limits: make(map[string]map[QuotaType]int64),
		usage:  make(map[string]map[QuotaType]*QuotaUsage),
	}
}

func (m *mockQuotaStore) GetLimits(_ context.Context, tenantID string) (*QuotaConfig, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	config := &QuotaConfig{
		TenantID: tenantID,
		Limits:   make(map[QuotaType]int64),
	}
	if lim, ok := m.limits[tenantID]; ok {
		for k, v := range lim {
			config.Limits[k] = v
		}
	}
	return config, nil
}

func (m *mockQuotaStore) SetLimits(_ context.Context, config QuotaConfig) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if _, ok := m.limits[config.TenantID]; !ok {
		m.limits[config.TenantID] = make(map[QuotaType]int64)
	}
	for k, v := range config.Limits {
		m.limits[config.TenantID][k] = v
	}
	return nil
}

func (m *mockQuotaStore) GetUsage(_ context.Context, tenantID string, quotaType QuotaType) (*QuotaUsage, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	if m.getUsageErr != nil {
		return nil, m.getUsageErr
	}

	if tu, ok := m.usage[tenantID]; ok {
		if u, ok := tu[quotaType]; ok {
			// Also attach the limit.
			if lim, ok := m.limits[tenantID]; ok {
				u.Limit = lim[quotaType]
			}
			return u, nil
		}
	}

	return &QuotaUsage{
		TenantID:     tenantID,
		Type:         quotaType,
		CurrentUsage: 0,
		Limit:        m.getLimit(tenantID, quotaType),
		WindowStart:  time.Now(),
		UpdatedAt:    time.Now(),
	}, nil
}

func (m *mockQuotaStore) IncrementUsage(_ context.Context, tenantID string, quotaType QuotaType, delta int64) (*QuotaUsage, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	if _, ok := m.usage[tenantID]; !ok {
		m.usage[tenantID] = make(map[QuotaType]*QuotaUsage)
	}

	u, ok := m.usage[tenantID][quotaType]
	if !ok {
		u = &QuotaUsage{
			TenantID:    tenantID,
			Type:        quotaType,
			WindowStart: time.Now(),
		}
		m.usage[tenantID][quotaType] = u
	}

	u.CurrentUsage += delta
	u.UpdatedAt = time.Now()
	u.Limit = m.getLimit(tenantID, quotaType)

	return u, nil
}

func (m *mockQuotaStore) SetUsage(_ context.Context, tenantID string, quotaType QuotaType, value int64) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if _, ok := m.usage[tenantID]; !ok {
		m.usage[tenantID] = make(map[QuotaType]*QuotaUsage)
	}

	m.usage[tenantID][quotaType] = &QuotaUsage{
		TenantID:     tenantID,
		Type:         quotaType,
		CurrentUsage: value,
		WindowStart:  time.Now(),
		UpdatedAt:    time.Now(),
	}
	return nil
}

func (m *mockQuotaStore) ResetUsage(_ context.Context, tenantID string, quotaType QuotaType) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if tu, ok := m.usage[tenantID]; ok {
		if u, ok := tu[quotaType]; ok {
			u.CurrentUsage = 0
			u.WindowStart = time.Now()
			u.UpdatedAt = time.Now()
		}
	}
	return nil
}

func (m *mockQuotaStore) GetAllUsage(_ context.Context, tenantID string) ([]QuotaUsage, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	var usages []QuotaUsage
	if tu, ok := m.usage[tenantID]; ok {
		for _, u := range tu {
			u.Limit = m.getLimit(tenantID, u.Type)
			usages = append(usages, *u)
		}
	}
	return usages, nil
}

func (m *mockQuotaStore) getLimit(tenantID string, quotaType QuotaType) int64 {
	if lim, ok := m.limits[tenantID]; ok {
		return lim[quotaType]
	}
	return 0
}

// --- Tests ---

func TestQuotaManager_Check_UnderLimit(t *testing.T) {
	store := newMockQuotaStore()
	_ = store.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaMaxUsers: 10},
	})
	_ = store.SetUsage(context.Background(), "t1", QuotaMaxUsers, 5)

	mgr := NewQuotaManager(store)
	err := mgr.Check(context.Background(), "t1", QuotaMaxUsers)
	assert.NoError(t, err)
}

func TestQuotaManager_Check_AtLimit(t *testing.T) {
	store := newMockQuotaStore()
	_ = store.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaMaxUsers: 5},
	})
	_ = store.SetUsage(context.Background(), "t1", QuotaMaxUsers, 5)

	mgr := NewQuotaManager(store)
	err := mgr.Check(context.Background(), "t1", QuotaMaxUsers)
	assert.Error(t, err)
	assert.True(t, IsQuotaExceeded(err))

	var qe *QuotaExceededError
	require.True(t, errors.As(err, &qe))
	assert.Equal(t, "t1", qe.TenantID)
	assert.Equal(t, QuotaMaxUsers, qe.Type)
	assert.Equal(t, int64(5), qe.CurrentUsage)
	assert.Equal(t, int64(5), qe.Limit)
}

func TestQuotaManager_Check_OverLimit(t *testing.T) {
	store := newMockQuotaStore()
	_ = store.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaStorageBytes: 1000},
	})
	_ = store.SetUsage(context.Background(), "t1", QuotaStorageBytes, 1500)

	mgr := NewQuotaManager(store)
	err := mgr.Check(context.Background(), "t1", QuotaStorageBytes)
	assert.Error(t, err)
	assert.True(t, IsQuotaExceeded(err))
}

func TestQuotaManager_CheckAndIncrement_Success(t *testing.T) {
	store := newMockQuotaStore()
	_ = store.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaMaxUsers: 10},
	})
	_ = store.SetUsage(context.Background(), "t1", QuotaMaxUsers, 3)

	mgr := NewQuotaManager(store)
	err := mgr.CheckAndIncrement(context.Background(), "t1", QuotaMaxUsers, 1)
	assert.NoError(t, err)

	// Verify usage was incremented.
	usage, _ := store.GetUsage(context.Background(), "t1", QuotaMaxUsers)
	assert.Equal(t, int64(4), usage.CurrentUsage)
}

func TestQuotaManager_CheckAndIncrement_ExceedsLimit(t *testing.T) {
	store := newMockQuotaStore()
	_ = store.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaMaxUsers: 5},
	})
	_ = store.SetUsage(context.Background(), "t1", QuotaMaxUsers, 5)

	mgr := NewQuotaManager(store)
	err := mgr.CheckAndIncrement(context.Background(), "t1", QuotaMaxUsers, 1)
	assert.Error(t, err)
	assert.True(t, IsQuotaExceeded(err))

	// Verify usage was rolled back.
	usage, _ := store.GetUsage(context.Background(), "t1", QuotaMaxUsers)
	assert.Equal(t, int64(5), usage.CurrentUsage)
}

func TestQuotaManager_CheckAndIncrement_NoLimitConfigured(t *testing.T) {
	store := newMockQuotaStore()
	// No limits configured for this tenant.

	mgr := NewQuotaManager(store)
	err := mgr.CheckAndIncrement(context.Background(), "t1", QuotaMaxFields, 1)
	// Should allow when no limit is configured.
	assert.NoError(t, err)
}

func TestQuotaManager_SetLimits_InvalidatesCache(t *testing.T) {
	store := newMockQuotaStore()
	_ = store.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaMaxUsers: 5},
	})

	mgr := NewQuotaManager(store)

	// Prime the cache.
	_, err := mgr.getConfig(context.Background(), "t1")
	require.NoError(t, err)

	// Verify cache is populated.
	mgr.cacheMu.RLock()
	_, cached := mgr.configCache["t1"]
	mgr.cacheMu.RUnlock()
	assert.True(t, cached)

	// Update limits via manager.
	err = mgr.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaMaxUsers: 20},
	})
	require.NoError(t, err)

	// Cache should be invalidated.
	mgr.cacheMu.RLock()
	_, cached = mgr.configCache["t1"]
	mgr.cacheMu.RUnlock()
	assert.False(t, cached)
}

func TestQuotaManager_APIRequests_WindowReset(t *testing.T) {
	store := newMockQuotaStore()
	_ = store.SetLimits(context.Background(), QuotaConfig{
		TenantID: "t1",
		Limits:   map[QuotaType]int64{QuotaAPIRequests: 100},
	})

	// Set usage to be at the limit, but with an expired window.
	store.mu.Lock()
	store.usage["t1"] = map[QuotaType]*QuotaUsage{
		QuotaAPIRequests: {
			TenantID:     "t1",
			Type:         QuotaAPIRequests,
			CurrentUsage: 100,
			WindowStart:  time.Now().Add(-2 * time.Hour), // 2 hours ago
			UpdatedAt:    time.Now(),
		},
	}
	store.mu.Unlock()

	mgr := NewQuotaManager(store, WithWindowDuration(1*time.Hour))

	// Even though usage is at the limit, the window has expired so Check should pass.
	err := mgr.Check(context.Background(), "t1", QuotaAPIRequests)
	assert.NoError(t, err)
}

func TestQuotaUsage_Remaining(t *testing.T) {
	tests := []struct {
		name     string
		usage    QuotaUsage
		expected int64
	}{
		{name: "under limit", usage: QuotaUsage{CurrentUsage: 3, Limit: 10}, expected: 7},
		{name: "at limit", usage: QuotaUsage{CurrentUsage: 10, Limit: 10}, expected: 0},
		{name: "over limit", usage: QuotaUsage{CurrentUsage: 15, Limit: 10}, expected: 0},
		{name: "zero usage", usage: QuotaUsage{CurrentUsage: 0, Limit: 100}, expected: 100},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.expected, tt.usage.Remaining())
		})
	}
}

func TestQuotaUsage_IsExceeded(t *testing.T) {
	assert.False(t, (&QuotaUsage{CurrentUsage: 5, Limit: 10}).IsExceeded())
	assert.True(t, (&QuotaUsage{CurrentUsage: 10, Limit: 10}).IsExceeded())
	assert.True(t, (&QuotaUsage{CurrentUsage: 15, Limit: 10}).IsExceeded())
}

func TestQuotaUsage_UsagePercent(t *testing.T) {
	u := &QuotaUsage{CurrentUsage: 50, Limit: 200}
	assert.InDelta(t, 25.0, u.UsagePercent(), 0.001)

	zero := &QuotaUsage{CurrentUsage: 5, Limit: 0}
	assert.InDelta(t, 100.0, zero.UsagePercent(), 0.001)
}

func TestQuotaExceededError_Error(t *testing.T) {
	e := &QuotaExceededError{
		TenantID:     "t1",
		Type:         QuotaMaxUsers,
		CurrentUsage: 10,
		Limit:        10,
	}
	assert.Contains(t, e.Error(), "t1")
	assert.Contains(t, e.Error(), string(QuotaMaxUsers))
	assert.Contains(t, e.Error(), "10/10")
}

func TestQuotaExceededError_Is(t *testing.T) {
	e := &QuotaExceededError{TenantID: "t1", Type: QuotaMaxUsers}
	assert.True(t, errors.Is(e, ErrQuotaExceeded))
	assert.True(t, IsQuotaExceeded(e))
	assert.False(t, IsQuotaExceeded(errors.New("some other error")))
}

func TestDefaultTierLimits(t *testing.T) {
	free := DefaultFreeTierLimits()
	paid := DefaultPaidTierLimits()

	// Paid tier should have higher limits than free tier for all quota types.
	for _, qt := range AllQuotaTypes() {
		assert.Greater(t, paid[qt], free[qt], "paid tier should have higher %s limit", qt)
	}
}
