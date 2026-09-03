package application

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	"p9e.in/samavaya/agriculture/field-service/internal/domain"
	"p9e.in/samavaya/agriculture/field-service/internal/ports/outbound"
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
// Mock: FarmClient
// ---------------------------------------------------------------------------

type mockFarmClient struct {
	existing map[string]bool // farmUUID -> exists
}

func (m *mockFarmClient) FarmExists(_ context.Context, farmUUID, _ string) (bool, error) {
	return m.existing[farmUUID], nil
}

func (m *mockFarmClient) GetFarmBoundary(context.Context, string, string) (string, error) {
	return `{"type":"Polygon"}`, nil
}

// ---------------------------------------------------------------------------
// Mock: CropClient
// ---------------------------------------------------------------------------

type mockCropClient struct {
	existing map[string]bool
}

func (m *mockCropClient) CropExists(_ context.Context, uuid, _ string) (bool, error) {
	return m.existing[uuid], nil
}

// ---------------------------------------------------------------------------
// Mock: FieldRepository
// ---------------------------------------------------------------------------

type mockFieldRepo struct {
	fields map[string]*domain.Field // keyed by UUID
	names  map[string]bool          // farmID+"/"+name -> exists
}

func newMockFieldRepo() *mockFieldRepo {
	return &mockFieldRepo{
		fields: make(map[string]*domain.Field),
		names:  make(map[string]bool),
	}
}

func (m *mockFieldRepo) CreateField(_ context.Context, f *domain.Field) (*domain.Field, error) {
	f.ID = "field-uuid-001"
	m.fields[f.ID] = f
	m.names[f.FarmID+"/"+f.Name] = true
	return f, nil
}

func (m *mockFieldRepo) GetFieldByUUID(_ context.Context, uuid, tenantID string) (*domain.Field, error) {
	f, ok := m.fields[uuid]
	if !ok || f.TenantID != tenantID {
		return nil, errors.NotFound("FIELD_NOT_FOUND", fmt.Sprintf("field not found: %s", uuid))
	}
	return f, nil
}

func (m *mockFieldRepo) ListFields(_ context.Context, params domain.ListFieldsParams) ([]domain.Field, int32, error) {
	var result []domain.Field
	for _, f := range m.fields {
		if f.TenantID == params.TenantID {
			result = append(result, *f)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockFieldRepo) UpdateField(_ context.Context, f *domain.Field) (*domain.Field, error) {
	existing, ok := m.fields[f.ID]
	if !ok {
		return nil, errors.NotFound("FIELD_NOT_FOUND", "field not found")
	}
	if f.Name != "" {
		existing.Name = f.Name
	}
	return existing, nil
}

func (m *mockFieldRepo) DeleteField(_ context.Context, uuid, tenantID, _ string) error {
	if f, ok := m.fields[uuid]; ok && f.TenantID == tenantID {
		delete(m.fields, uuid)
		return nil
	}
	return errors.NotFound("FIELD_NOT_FOUND", "field not found")
}

func (m *mockFieldRepo) CheckFieldExists(_ context.Context, uuid, tenantID string) (bool, error) {
	f, ok := m.fields[uuid]
	return ok && f.TenantID == tenantID, nil
}

func (m *mockFieldRepo) CheckFieldNameExists(_ context.Context, name, farmID, _ string) (bool, error) {
	return m.names[farmID+"/"+name], nil
}

func (m *mockFieldRepo) SetFieldBoundary(_ context.Context, b *domain.FieldBoundary) (*domain.FieldBoundary, error) {
	b.ID = "boundary-001"
	return b, nil
}

func (m *mockFieldRepo) CreateCropAssignment(_ context.Context, a *domain.CropAssignment) (*domain.CropAssignment, error) {
	a.ID = "assignment-001"
	return a, nil
}

func (m *mockFieldRepo) GetCropHistory(context.Context, string, string, int32, int32) ([]domain.CropAssignment, int32, error) {
	return nil, 0, nil
}

func (m *mockFieldRepo) CreateFieldSegments(_ context.Context, _, _ string, _ []domain.FieldSegmentInput) ([]domain.FieldSegment, error) {
	return nil, nil
}

func (m *mockFieldRepo) GetFieldSegments(context.Context, string, string) ([]domain.FieldSegment, error) {
	return nil, nil
}

func (m *mockFieldRepo) DeleteFieldSegments(context.Context, string, string) error { return nil }

func (m *mockFieldRepo) CreateCropCycle(_ context.Context, c *domain.CropCycle) (*domain.CropCycle, error) {
	c.ID = "cycle-001"
	return c, nil
}

func (m *mockFieldRepo) GetCropCycleByID(context.Context, string, string) (*domain.CropCycle, error) {
	return nil, errors.NotFound("CYCLE_NOT_FOUND", "not found")
}

func (m *mockFieldRepo) ListCropCycles(_ context.Context, _ domain.ListCropCyclesParams) ([]domain.CropCycle, int32, error) {
	return nil, 0, nil
}

func (m *mockFieldRepo) UpdateCropCycle(_ context.Context, c *domain.CropCycle) (*domain.CropCycle, error) {
	return c, nil
}

func (m *mockFieldRepo) CreateActivityEvent(_ context.Context, e *domain.ActivityEvent) (*domain.ActivityEvent, error) {
	e.ID = "event-001"
	return e, nil
}

func (m *mockFieldRepo) ListActivityEvents(_ context.Context, _ domain.ListActivityEventsParams) ([]domain.ActivityEvent, int32, error) {
	return nil, 0, nil
}

func (m *mockFieldRepo) CreateActivityEvidence(_ context.Context, e *domain.ActivityEvidence) (*domain.ActivityEvidence, error) {
	e.ID = "evidence-001"
	return e, nil
}

func (m *mockFieldRepo) ListActivityEvidence(_ context.Context, _ domain.ListActivityEvidenceParams) ([]domain.ActivityEvidence, int32, error) {
	return nil, 0, nil
}

func (m *mockFieldRepo) DeleteActivityEvidence(context.Context, string, string) error { return nil }

func (m *mockFieldRepo) WithTx(_ pgx.Tx) outbound.FieldRepository { return m }

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func testContext(tenantID, userID string) context.Context {
	ctx := context.Background()
	ctx = p9context.NewConnectionInfo(ctx, &saas.ConnectionInfo{TenantID: tenantID})
	if userID != "" {
		ctx = p9context.NewUserContext(ctx, p9context.UserContext{UserID: userID})
	}
	return ctx
}

func newService() (*mockFieldRepo, *mockEventPublisher, *mockFarmClient, *fieldService) {
	repo := newMockFieldRepo()
	pub := &mockEventPublisher{}
	farmClient := &mockFarmClient{existing: map[string]bool{"farm-001": true}}
	cropClient := &mockCropClient{existing: map[string]bool{"crop-001": true}}
	svc := NewFieldService(repo, pub, farmClient, cropClient, nil, nopLogger{}).(*fieldService)
	return repo, pub, farmClient, svc
}

// ---------------------------------------------------------------------------
// Tests: CreateField
// ---------------------------------------------------------------------------

func TestCreateField_HappyPath(t *testing.T) {
	_, pub, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	field := &domain.Field{
		FarmID: "farm-001",
		Name:   "North Plot",
	}

	created, err := svc.CreateField(ctx, field)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "North Plot", created.Name)
	assert.Equal(t, domain.FieldStatusActive, created.Status)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.NotEmpty(t, created.ID)

	// Event published.
	assert.Len(t, pub.published, 1)
	assert.Equal(t, fieldEventTopic, pub.published[0].topic)
}

func TestCreateField_MissingTenant(t *testing.T) {
	_, _, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateField(ctx, &domain.Field{FarmID: "farm-001", Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateField_MissingFarmID(t *testing.T) {
	_, _, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateField(ctx, &domain.Field{Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

func TestCreateField_FarmNotFound(t *testing.T) {
	_, _, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateField(ctx, &domain.Field{FarmID: "nonexistent-farm", Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
	assert.Equal(t, "FARM_NOT_FOUND", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetField
// ---------------------------------------------------------------------------

func TestGetField_HappyPath(t *testing.T) {
	repo, _, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.fields["field-uuid-001"] = &domain.Field{
		TenantID: "tenant-1",
		FarmID:   "farm-001",
		Name:     "North Plot",
	}
	repo.fields["field-uuid-001"].ID = "field-uuid-001"

	field, err := svc.GetField(ctx, "field-uuid-001")
	require.NoError(t, err)
	assert.Equal(t, "North Plot", field.Name)
}

func TestGetField_NotFound(t *testing.T) {
	_, _, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetField(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListFields
// ---------------------------------------------------------------------------

func TestListFields_HappyPath(t *testing.T) {
	repo, _, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.fields["f1"] = &domain.Field{TenantID: "tenant-1", Name: "A"}
	repo.fields["f1"].ID = "f1"
	repo.fields["f2"] = &domain.Field{TenantID: "tenant-1", Name: "B"}
	repo.fields["f2"].ID = "f2"

	fields, total, err := svc.ListFields(ctx, domain.ListFieldsParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, fields, 2)
}

// ---------------------------------------------------------------------------
// Tests: LogActivityEvent
// ---------------------------------------------------------------------------

func TestLogActivityEvent_HappyPath(t *testing.T) {
	repo, pub, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Seed a field so existence check passes.
	repo.fields["field-001"] = &domain.Field{TenantID: "tenant-1", Name: "Plot"}
	repo.fields["field-001"].ID = "field-001"

	event := &domain.ActivityEvent{
		FieldID:      "field-001",
		ActivityType: "IRRIGATION",
		StartedAt:    time.Now(),
	}

	created, err := svc.LogActivityEvent(ctx, event)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.PerformedBy)
	assert.Equal(t, "event-001", created.ID)
	assert.Len(t, pub.published, 1)
}

func TestLogActivityEvent_MissingFieldID(t *testing.T) {
	_, _, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.LogActivityEvent(ctx, &domain.ActivityEvent{
		ActivityType: "IRRIGATION",
		StartedAt:    time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FIELD_ID", errors.Reason(err))
}

func TestLogActivityEvent_MissingTenant(t *testing.T) {
	_, _, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.LogActivityEvent(ctx, &domain.ActivityEvent{
		FieldID:      "field-001",
		ActivityType: "IRRIGATION",
		StartedAt:    time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}
