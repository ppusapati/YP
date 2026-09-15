package provisioning

import (
	"context"
	"errors"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/saas"
)

// --- Mock implementations ---

type mockTenantStore struct {
	tenants       map[string]saas.TenantConfig
	createErr     error
	updateErr     error
	deleteErr     error
	deleteCalled  bool
}

func newMockTenantStore() *mockTenantStore {
	return &mockTenantStore{tenants: make(map[string]saas.TenantConfig)}
}

func (m *mockTenantStore) CreateTenant(_ context.Context, cfg saas.TenantConfig) error {
	if m.createErr != nil {
		return m.createErr
	}
	if _, exists := m.tenants[cfg.Name]; exists {
		return ErrTenantExists
	}
	m.tenants[cfg.ID] = cfg
	return nil
}

func (m *mockTenantStore) GetByNameOrId(_ context.Context, nameOrId string) (*saas.TenantConfig, error) {
	for _, cfg := range m.tenants {
		if cfg.ID == nameOrId || cfg.Name == nameOrId {
			return &cfg, nil
		}
	}
	return nil, saas.ErrTenantNotFound
}

func (m *mockTenantStore) UpdateStatus(_ context.Context, tenantID string, isActive bool) error {
	if m.updateErr != nil {
		return m.updateErr
	}
	if cfg, ok := m.tenants[tenantID]; ok {
		cfg.IsActive = isActive
		m.tenants[tenantID] = cfg
	}
	return nil
}

func (m *mockTenantStore) DeleteTenant(_ context.Context, tenantID string) error {
	m.deleteCalled = true
	if m.deleteErr != nil {
		return m.deleteErr
	}
	delete(m.tenants, tenantID)
	return nil
}

type mockDatabaseCreator struct {
	databases   map[string]struct{}
	createErr   error
	dropErr     error
	dropCalled  bool
}

func newMockDatabaseCreator() *mockDatabaseCreator {
	return &mockDatabaseCreator{databases: make(map[string]struct{})}
}

func (m *mockDatabaseCreator) CreateDatabase(_ context.Context, name string) error {
	if m.createErr != nil {
		return m.createErr
	}
	m.databases[name] = struct{}{}
	return nil
}

func (m *mockDatabaseCreator) DropDatabase(_ context.Context, name string) error {
	m.dropCalled = true
	if m.dropErr != nil {
		return m.dropErr
	}
	delete(m.databases, name)
	return nil
}

type mockPoolProvider struct {
	err error
}

func (m *mockPoolProvider) GetPool(_ context.Context, _ string) (*pgxpool.Pool, error) {
	if m.err != nil {
		return nil, m.err
	}
	// Return nil pool; tests that need a real pool should use integration tests.
	return nil, nil
}

type mockMigrationRunner struct {
	err       error
	called    bool
	tenantID  string
}

func (m *mockMigrationRunner) RunMigrations(_ context.Context, _ *pgxpool.Pool, tenantID string) error {
	m.called = true
	m.tenantID = tenantID
	return m.err
}

type mockDataSeeder struct {
	err      error
	called   bool
	seedData *SeedData
}

func (m *mockDataSeeder) Seed(_ context.Context, _ *pgxpool.Pool, _ CreateTenantRequest, _ string) (*SeedData, error) {
	m.called = true
	if m.err != nil {
		return nil, m.err
	}
	if m.seedData != nil {
		return m.seedData, nil
	}
	return &SeedData{
		AdminUserID: "admin-001",
		Roles:       DefaultRoles(),
		Settings:    DefaultSettings(),
	}, nil
}

// --- Tests ---

func newTestProvisioner(store *mockTenantStore, dbCreator *mockDatabaseCreator, poolProvider *mockPoolProvider, migrator *mockMigrationRunner, seeder *mockDataSeeder) *TenantProvisioner {
	return NewTenantProvisioner(
		nil, // masterPool not needed for unit tests
		store,
		dbCreator,
		poolProvider,
		migrator,
		seeder,
	)
}

func TestProvision_FreeTier_Success(t *testing.T) {
	store := newMockTenantStore()
	dbCreator := newMockDatabaseCreator()
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{}
	seeder := &mockDataSeeder{}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	req := CreateTenantRequest{
		Name:       "acme-farm",
		AdminEmail: "admin@acme.com",
		AdminName:  "Admin User",
		Region:     "us-east-1",
		Type:       "free",
	}

	result, err := p.Provision(context.Background(), req)

	require.NoError(t, err)
	assert.Equal(t, StatusComplete, result.Status)
	assert.Equal(t, "acme-farm", result.Tenant.Name)
	assert.Equal(t, "free", result.Tenant.Type)
	assert.Equal(t, "shared", result.Tenant.DatabaseName)
	assert.Equal(t, "admin-001", result.Tenant.AdminUserID)
	assert.NotEmpty(t, result.Tenant.ID)
	assert.True(t, result.Duration > 0)

	// Verify all steps completed.
	assert.Len(t, result.Steps, 4)
	for _, step := range result.Steps {
		assert.Equal(t, StatusComplete, step.Status, "step %s should be complete", step.Name)
	}

	// Verify the migrator and seeder were called.
	assert.True(t, migrator.called)
	assert.True(t, seeder.called)

	// Free tier should NOT create a dedicated database.
	assert.Empty(t, dbCreator.databases)
}

func TestProvision_PaidTier_Success(t *testing.T) {
	store := newMockTenantStore()
	dbCreator := newMockDatabaseCreator()
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{}
	seeder := &mockDataSeeder{}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	req := CreateTenantRequest{
		Name:       "bigcorp",
		AdminEmail: "admin@bigcorp.com",
		AdminName:  "Admin",
		Type:       "paid",
	}

	result, err := p.Provision(context.Background(), req)

	require.NoError(t, err)
	assert.Equal(t, StatusComplete, result.Status)
	assert.Equal(t, "paid", result.Tenant.Type)
	assert.Equal(t, "bigcorp", result.Tenant.DatabaseName)

	// Paid tier should create a dedicated database.
	_, exists := dbCreator.databases["bigcorp"]
	assert.True(t, exists, "dedicated database should be created for paid tenant")
}

func TestProvision_DefaultsToFreeTier(t *testing.T) {
	store := newMockTenantStore()
	dbCreator := newMockDatabaseCreator()
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{}
	seeder := &mockDataSeeder{}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	req := CreateTenantRequest{
		Name:       "default-tenant",
		AdminEmail: "admin@default.com",
		// Type is empty; should default to free.
	}

	result, err := p.Provision(context.Background(), req)

	require.NoError(t, err)
	assert.Equal(t, "free", result.Tenant.Type)
}

func TestProvision_ValidationErrors(t *testing.T) {
	store := newMockTenantStore()
	dbCreator := newMockDatabaseCreator()
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{}
	seeder := &mockDataSeeder{}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	tests := []struct {
		name string
		req  CreateTenantRequest
		err  error
	}{
		{
			name: "empty name",
			req:  CreateTenantRequest{AdminEmail: "a@b.com"},
			err:  ErrNameRequired,
		},
		{
			name: "empty admin email",
			req:  CreateTenantRequest{Name: "test"},
			err:  ErrAdminEmailRequired,
		},
		{
			name: "invalid tenant type",
			req:  CreateTenantRequest{Name: "test", AdminEmail: "a@b.com", Type: "premium"},
			err:  ErrInvalidTenantType,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result, err := p.Provision(context.Background(), tt.req)
			assert.ErrorIs(t, err, tt.err)
			assert.Equal(t, StatusFailed, result.Status)
		})
	}
}

func TestProvision_CreateRecordFailure_NoRollback(t *testing.T) {
	store := newMockTenantStore()
	store.createErr = errors.New("db write failure")
	dbCreator := newMockDatabaseCreator()
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{}
	seeder := &mockDataSeeder{}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	req := CreateTenantRequest{
		Name:       "failing-tenant",
		AdminEmail: "admin@fail.com",
	}

	result, err := p.Provision(context.Background(), req)

	assert.Error(t, err)
	assert.Equal(t, StatusFailed, result.Status)
	assert.Contains(t, err.Error(), "create tenant record")

	// Nothing to roll back since only the record creation was attempted.
	assert.False(t, store.deleteCalled)
	assert.False(t, dbCreator.dropCalled)
}

func TestProvision_CreateDatabaseFailure_RollsBackRecord(t *testing.T) {
	store := newMockTenantStore()
	dbCreator := newMockDatabaseCreator()
	dbCreator.createErr = errors.New("disk full")
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{}
	seeder := &mockDataSeeder{}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	req := CreateTenantRequest{
		Name:       "paid-fail",
		AdminEmail: "admin@paid.com",
		Type:       "paid",
	}

	result, err := p.Provision(context.Background(), req)

	assert.Error(t, err)
	assert.Equal(t, StatusFailed, result.Status)
	assert.Contains(t, err.Error(), "create database")

	// Record should have been rolled back.
	assert.True(t, store.deleteCalled)
}

func TestProvision_MigrationFailure_RollsBackAll(t *testing.T) {
	store := newMockTenantStore()
	dbCreator := newMockDatabaseCreator()
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{err: errors.New("migration syntax error")}
	seeder := &mockDataSeeder{}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	req := CreateTenantRequest{
		Name:       "migrate-fail",
		AdminEmail: "admin@migrate.com",
		Type:       "paid",
	}

	result, err := p.Provision(context.Background(), req)

	assert.Error(t, err)
	assert.Equal(t, StatusFailed, result.Status)
	assert.Contains(t, err.Error(), "run migrations")

	// Both database and record should be rolled back.
	assert.True(t, dbCreator.dropCalled)
	assert.True(t, store.deleteCalled)
}

func TestProvision_SeedFailure_RollsBackAll(t *testing.T) {
	store := newMockTenantStore()
	dbCreator := newMockDatabaseCreator()
	poolProvider := &mockPoolProvider{}
	migrator := &mockMigrationRunner{}
	seeder := &mockDataSeeder{err: errors.New("seed constraint violation")}

	p := newTestProvisioner(store, dbCreator, poolProvider, migrator, seeder)

	req := CreateTenantRequest{
		Name:       "seed-fail",
		AdminEmail: "admin@seed.com",
		Type:       "paid",
	}

	result, err := p.Provision(context.Background(), req)

	assert.Error(t, err)
	assert.Equal(t, StatusFailed, result.Status)
	assert.Contains(t, err.Error(), "seed data")
	assert.True(t, dbCreator.dropCalled)
	assert.True(t, store.deleteCalled)
}

func TestCreateTenantRequest_Validate(t *testing.T) {
	tests := []struct {
		name    string
		req     CreateTenantRequest
		wantErr bool
	}{
		{
			name:    "valid free",
			req:     CreateTenantRequest{Name: "test", AdminEmail: "a@b.com", Type: "free"},
			wantErr: false,
		},
		{
			name:    "valid paid",
			req:     CreateTenantRequest{Name: "test", AdminEmail: "a@b.com", Type: "paid"},
			wantErr: false,
		},
		{
			name:    "valid empty type defaults",
			req:     CreateTenantRequest{Name: "test", AdminEmail: "a@b.com"},
			wantErr: false,
		},
		{
			name:    "missing name",
			req:     CreateTenantRequest{AdminEmail: "a@b.com"},
			wantErr: true,
		},
		{
			name:    "missing email",
			req:     CreateTenantRequest{Name: "test"},
			wantErr: true,
		},
		{
			name:    "invalid type",
			req:     CreateTenantRequest{Name: "test", AdminEmail: "a@b.com", Type: "enterprise"},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestDefaultRoles(t *testing.T) {
	roles := DefaultRoles()
	assert.Contains(t, roles, "admin")
	assert.Contains(t, roles, "manager")
	assert.Contains(t, roles, "user")
	assert.Contains(t, roles, "viewer")
	assert.Len(t, roles, 4)
}

func TestDefaultSettings(t *testing.T) {
	settings := DefaultSettings()
	assert.NotEmpty(t, settings)
	assert.Equal(t, "en", settings["locale"])
	assert.Equal(t, "UTC", settings["timezone"])
	assert.Equal(t, "USD", settings["currency"])
}
