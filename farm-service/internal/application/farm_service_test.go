package application

import (
	"context"
	"fmt"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/farm-service/internal/domain"
	"p9e.in/samavaya/agriculture/farm-service/internal/ports/outbound"
)

// ---------------------------------------------------------------------------
// No-op logger satisfying p9log.Logger
// ---------------------------------------------------------------------------

type nopLogger struct{}

func (nopLogger) Log(_ p9log.Level, _ ...interface{}) error { return nil }

// ---------------------------------------------------------------------------
// Mock: EventPublisher
// ---------------------------------------------------------------------------

type mockEventPublisher struct {
	published []publishedEvent
}

type publishedEvent struct {
	topic, key string
	payload    []byte
}

func (m *mockEventPublisher) Publish(_ context.Context, topic, key string, payload []byte) error {
	m.published = append(m.published, publishedEvent{topic, key, payload})
	return nil
}

// ---------------------------------------------------------------------------
// Mock: FarmRepository
// ---------------------------------------------------------------------------

type mockFarmRepo struct {
	farms      map[string]*domain.Farm // keyed by UUID
	boundaries map[string]*domain.FarmBoundary
	owners     map[string][]domain.FarmOwner
	names      map[string]bool // tenantID+name -> exists

	// Hooks for fine-grained control (optional).
	createFarmFn func(ctx context.Context, f *domain.Farm) (*domain.Farm, error)
}

func newMockFarmRepo() *mockFarmRepo {
	return &mockFarmRepo{
		farms:      make(map[string]*domain.Farm),
		boundaries: make(map[string]*domain.FarmBoundary),
		owners:     make(map[string][]domain.FarmOwner),
		names:      make(map[string]bool),
	}
}

func (m *mockFarmRepo) CreateFarm(_ context.Context, f *domain.Farm) (*domain.Farm, error) {
	if m.createFarmFn != nil {
		return m.createFarmFn(nil, f)
	}
	f.ID = "farm-uuid-001"
	m.farms[f.ID] = f
	m.names[f.TenantID+"/"+f.Name] = true
	return f, nil
}

func (m *mockFarmRepo) GetFarmByUUID(_ context.Context, uuid, tenantID string) (*domain.Farm, error) {
	f, ok := m.farms[uuid]
	if !ok || f.TenantID != tenantID {
		return nil, errors.NotFound("FARM_NOT_FOUND", fmt.Sprintf("farm not found: %s", uuid))
	}
	return f, nil
}

func (m *mockFarmRepo) ListFarms(_ context.Context, params domain.ListFarmsParams) ([]domain.Farm, int32, error) {
	var result []domain.Farm
	for _, f := range m.farms {
		if f.TenantID == params.TenantID {
			result = append(result, *f)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockFarmRepo) UpdateFarm(_ context.Context, f *domain.Farm) (*domain.Farm, error) {
	existing, ok := m.farms[f.ID]
	if !ok {
		return nil, errors.NotFound("FARM_NOT_FOUND", "farm not found")
	}
	if f.Name != "" {
		existing.Name = f.Name
	}
	return existing, nil
}

func (m *mockFarmRepo) DeleteFarm(_ context.Context, uuid, tenantID, _ string) error {
	key := uuid
	if f, ok := m.farms[key]; ok && f.TenantID == tenantID {
		delete(m.farms, key)
		return nil
	}
	return errors.NotFound("FARM_NOT_FOUND", "farm not found")
}

func (m *mockFarmRepo) CheckFarmExists(_ context.Context, uuid, tenantID string) (bool, error) {
	f, ok := m.farms[uuid]
	return ok && f.TenantID == tenantID, nil
}

func (m *mockFarmRepo) CheckFarmNameExists(_ context.Context, name, tenantID string) (bool, error) {
	return m.names[tenantID+"/"+name], nil
}

func (m *mockFarmRepo) CreateFarmBoundary(_ context.Context, b *domain.FarmBoundary) (*domain.FarmBoundary, error) {
	b.ID = "boundary-uuid-001"
	m.boundaries[b.FarmUUID] = b
	return b, nil
}

func (m *mockFarmRepo) GetFarmBoundaryByFarmUUID(_ context.Context, farmUUID, _ string) (*domain.FarmBoundary, error) {
	b, ok := m.boundaries[farmUUID]
	if !ok {
		return nil, errors.NotFound("BOUNDARY_NOT_FOUND", "boundary not found")
	}
	return b, nil
}

func (m *mockFarmRepo) UpdateFarmBoundary(_ context.Context, b *domain.FarmBoundary) (*domain.FarmBoundary, error) {
	m.boundaries[b.FarmUUID] = b
	return b, nil
}

func (m *mockFarmRepo) DeleteFarmBoundary(_ context.Context, farmUUID, _, _ string) error {
	delete(m.boundaries, farmUUID)
	return nil
}

func (m *mockFarmRepo) CreateFarmOwner(_ context.Context, o *domain.FarmOwner) (*domain.FarmOwner, error) {
	o.ID = "owner-uuid-001"
	m.owners[o.FarmUUID] = append(m.owners[o.FarmUUID], *o)
	return o, nil
}

func (m *mockFarmRepo) GetFarmOwnersByFarmUUID(_ context.Context, farmUUID, _ string) ([]domain.FarmOwner, error) {
	return m.owners[farmUUID], nil
}

func (m *mockFarmRepo) GetFarmOwnerByUserID(_ context.Context, farmUUID, _, userID string) (*domain.FarmOwner, error) {
	for i, o := range m.owners[farmUUID] {
		if o.UserID == userID {
			return &m.owners[farmUUID][i], nil
		}
	}
	return nil, errors.NotFound("OWNER_NOT_FOUND", "owner not found")
}

func (m *mockFarmRepo) DeactivateFarmOwner(context.Context, string, string, string, string) error {
	return nil
}

func (m *mockFarmRepo) ClearPrimaryOwner(context.Context, string, string, string) error {
	return nil
}

func (m *mockFarmRepo) CreateManagementUnit(_ context.Context, u *domain.ManagementUnit) (*domain.ManagementUnit, error) {
	return u, nil
}

func (m *mockFarmRepo) GetManagementUnitByID(context.Context, string, string) (*domain.ManagementUnit, error) {
	return nil, errors.NotFound("UNIT_NOT_FOUND", "not found")
}

func (m *mockFarmRepo) ListManagementUnits(_ context.Context, _ domain.ListManagementUnitsParams) ([]domain.ManagementUnit, int32, error) {
	return nil, 0, nil
}

func (m *mockFarmRepo) UpdateManagementUnit(_ context.Context, u *domain.ManagementUnit) (*domain.ManagementUnit, error) {
	return u, nil
}

func (m *mockFarmRepo) DeleteManagementUnit(context.Context, string, string, string) error {
	return nil
}

func (m *mockFarmRepo) GetUnitFieldIDs(context.Context, string, string) ([]string, error) {
	return nil, nil
}

func (m *mockFarmRepo) AssignFieldsToUnit(context.Context, string, string, []string) error {
	return nil
}

func (m *mockFarmRepo) RemoveFieldsFromUnit(context.Context, string, string, []string) error {
	return nil
}

func (m *mockFarmRepo) WithTx(_ pgx.Tx) outbound.FarmRepository {
	return m
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// testContext returns a context with tenant and user info set the way the
// production middleware would.
func testContext(tenantID, userID string) context.Context {
	ctx := context.Background()
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	if userID != "" {
		ctx = p9context.NewUserContext(ctx, p9context.UserContext{UserID: userID})
	}
	return ctx
}

// newTestFarmService builds a farmService wired to mocks (no DB pool needed
// because the mock repo ignores WithTx).
func newTestFarmService() (*mockFarmRepo, *mockEventPublisher, *farmService) {
	repo := newMockFarmRepo()
	pub := &mockEventPublisher{}
	svc := &farmService{
		repo: repo,
		pub:  pub,
		pool: nil, // transaction helper is bypassed by the mock returning itself from WithTx
		log:  nil, // will be set below
	}
	// Build a p9log.Helper from a no-op logger.
	svc.log = nil // The service uses s.log.Infow etc. — we need a real Helper.
	return repo, pub, svc
}

// newService builds the service through the public constructor so it is tested
// via the inbound.FarmService interface.
func newService() (*mockFarmRepo, *mockEventPublisher, *farmService) {
	repo := newMockFarmRepo()
	pub := &mockEventPublisher{}
	svc := NewFarmService(repo, pub, nil, nopLogger{}).(*farmService)
	return repo, pub, svc
}

// ---------------------------------------------------------------------------
// Tests: CreateFarm
// ---------------------------------------------------------------------------

// NOTE: The CreateFarm happy path requires a real pgxpool.Pool for
// uow.WithTransaction. Validation-error paths are fully exercised here;
// the transactional happy path belongs in an integration test with a live DB.

func TestCreateFarm_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1") // no tenant

	_, err := svc.CreateFarm(ctx, &domain.Farm{Name: "X", FarmType: domain.FarmTypeCrop}, nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateFarm_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateFarm(ctx, &domain.Farm{FarmType: domain.FarmTypeCrop}, nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FARM_NAME", errors.Reason(err))
}

func TestCreateFarm_InvalidFarmType(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateFarm(ctx, &domain.Farm{Name: "X", FarmType: "INVALID"}, nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FARM_TYPE", errors.Reason(err))
}

func TestCreateFarm_DuplicateName(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Pre-register the name so the uniqueness check fails.
	repo.names["tenant-1/Existing Farm"] = true

	_, err := svc.CreateFarm(ctx, &domain.Farm{Name: "Existing Farm", FarmType: domain.FarmTypeCrop}, nil)
	require.Error(t, err)
	assert.True(t, errors.IsConflict(err))
	assert.Equal(t, "FARM_NAME_EXISTS", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetFarm
// ---------------------------------------------------------------------------

func TestGetFarm_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Seed a farm in the mock.
	repo.farms["farm-uuid-001"] = &domain.Farm{
		TenantID: "tenant-1",
		Name:     "Sunrise Farm",
		FarmType: domain.FarmTypeCrop,
	}
	repo.farms["farm-uuid-001"].ID = "farm-uuid-001"

	farm, err := svc.GetFarm(ctx, "farm-uuid-001")
	require.NoError(t, err)
	assert.Equal(t, "Sunrise Farm", farm.Name)
}

func TestGetFarm_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetFarm(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListFarms
// ---------------------------------------------------------------------------

func TestListFarms_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.farms["f1"] = &domain.Farm{TenantID: "tenant-1", Name: "Farm A"}
	repo.farms["f1"].ID = "f1"
	repo.farms["f2"] = &domain.Farm{TenantID: "tenant-1", Name: "Farm B"}
	repo.farms["f2"].ID = "f2"

	farms, total, err := svc.ListFarms(ctx, domain.ListFarmsParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, farms, 2)
}

func TestListFarms_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListFarms(ctx, domain.ListFarmsParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}
