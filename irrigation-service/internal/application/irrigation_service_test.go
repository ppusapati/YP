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

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
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
// Mock: FieldClient
// ---------------------------------------------------------------------------

type mockFieldClient struct {
	existing map[string]bool
}

func (m *mockFieldClient) FieldExists(_ context.Context, uuid, _ string) (bool, error) {
	return m.existing[uuid], nil
}

// ---------------------------------------------------------------------------
// Mock: FarmClient
// ---------------------------------------------------------------------------

type mockFarmClient struct {
	existing map[string]bool
}

func (m *mockFarmClient) FarmExists(_ context.Context, uuid, _ string) (bool, error) {
	return m.existing[uuid], nil
}

// ---------------------------------------------------------------------------
// Mock: IrrigationRepository
// ---------------------------------------------------------------------------

type mockIrrigationRepo struct {
	irrigations map[string]*domain.Irrigation
	names       map[string]bool // tenantID+"/"+name -> exists
	zones       map[string]*domain.IrrigationZone
	controllers map[string]*domain.WaterController
	schedules   map[string]*domain.IrrigationSchedule
	events      map[string]*domain.IrrigationEvent
	decisions   map[string]*domain.IrrigationDecision
	usageLogs   map[string][]domain.WaterUsageLog
}

func newMockIrrigationRepo() *mockIrrigationRepo {
	return &mockIrrigationRepo{
		irrigations: make(map[string]*domain.Irrigation),
		names:       make(map[string]bool),
		zones:       make(map[string]*domain.IrrigationZone),
		controllers: make(map[string]*domain.WaterController),
		schedules:   make(map[string]*domain.IrrigationSchedule),
		events:      make(map[string]*domain.IrrigationEvent),
		decisions:   make(map[string]*domain.IrrigationDecision),
		usageLogs:   make(map[string][]domain.WaterUsageLog),
	}
}

func (m *mockIrrigationRepo) CreateIrrigation(_ context.Context, e *domain.Irrigation) (*domain.Irrigation, error) {
	e.UUID = "irrig-uuid-001"
	e.ID = 1
	m.irrigations[e.UUID] = e
	m.names[e.TenantID+"/"+e.Name] = true
	return e, nil
}

func (m *mockIrrigationRepo) GetIrrigationByUUID(_ context.Context, uuid, tenantID string) (*domain.Irrigation, error) {
	e, ok := m.irrigations[uuid]
	if !ok || e.TenantID != tenantID {
		return nil, errors.NotFound("IRRIGATION_NOT_FOUND", fmt.Sprintf("irrigation not found: %s", uuid))
	}
	return e, nil
}

func (m *mockIrrigationRepo) ListIrrigations(_ context.Context, params domain.ListIrrigationParams) ([]domain.Irrigation, int32, error) {
	var result []domain.Irrigation
	for _, e := range m.irrigations {
		if e.TenantID == params.TenantID {
			result = append(result, *e)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockIrrigationRepo) UpdateIrrigation(_ context.Context, e *domain.Irrigation) (*domain.Irrigation, error) {
	existing, ok := m.irrigations[e.UUID]
	if !ok {
		return nil, errors.NotFound("IRRIGATION_NOT_FOUND", "not found")
	}
	if e.Name != "" {
		existing.Name = e.Name
	}
	existing.UpdatedBy = e.UpdatedBy
	return existing, nil
}

func (m *mockIrrigationRepo) DeleteIrrigation(_ context.Context, uuid, tenantID, _ string) error {
	if e, ok := m.irrigations[uuid]; ok && e.TenantID == tenantID {
		delete(m.irrigations, uuid)
		return nil
	}
	return errors.NotFound("IRRIGATION_NOT_FOUND", "not found")
}

func (m *mockIrrigationRepo) CheckIrrigationExists(_ context.Context, uuid, tenantID string) (bool, error) {
	e, ok := m.irrigations[uuid]
	return ok && e.TenantID == tenantID, nil
}

func (m *mockIrrigationRepo) CheckIrrigationNameExists(_ context.Context, name, tenantID string) (bool, error) {
	return m.names[tenantID+"/"+name], nil
}

func (m *mockIrrigationRepo) WithTx(_ pgx.Tx) outbound.IrrigationRepository { return m }

func (m *mockIrrigationRepo) CreateZone(_ context.Context, z *domain.IrrigationZone) (*domain.IrrigationZone, error) {
	z.UUID = "zone-uuid-001"
	z.ID = 1
	m.zones[z.UUID] = z
	return z, nil
}

func (m *mockIrrigationRepo) GetZoneByUUID(_ context.Context, uuid string) (*domain.IrrigationZone, error) {
	z, ok := m.zones[uuid]
	if !ok {
		return nil, errors.NotFound("ZONE_NOT_FOUND", fmt.Sprintf("zone not found: %s", uuid))
	}
	return z, nil
}

func (m *mockIrrigationRepo) ListZonesByField(_ context.Context, fieldID string, _, _ int32) ([]domain.IrrigationZone, int32, error) {
	var result []domain.IrrigationZone
	for _, z := range m.zones {
		if z.FieldID == fieldID {
			result = append(result, *z)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockIrrigationRepo) ListZonesByFarm(_ context.Context, farmID string, _, _ int32) ([]domain.IrrigationZone, int32, error) {
	var result []domain.IrrigationZone
	for _, z := range m.zones {
		if z.FarmID == farmID {
			result = append(result, *z)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockIrrigationRepo) CreateController(_ context.Context, c *domain.WaterController) (*domain.WaterController, error) {
	c.UUID = "ctrl-uuid-001"
	c.ID = 1
	m.controllers[c.UUID] = c
	return c, nil
}

func (m *mockIrrigationRepo) GetControllerByUUID(_ context.Context, uuid string) (*domain.WaterController, error) {
	c, ok := m.controllers[uuid]
	if !ok {
		return nil, errors.NotFound("CONTROLLER_NOT_FOUND", fmt.Sprintf("controller not found: %s", uuid))
	}
	return c, nil
}

func (m *mockIrrigationRepo) ListControllersByZone(_ context.Context, zoneID string, _, _ int32) ([]domain.WaterController, int32, error) {
	var result []domain.WaterController
	for _, c := range m.controllers {
		if c.ZoneID == zoneID {
			result = append(result, *c)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockIrrigationRepo) UpdateControllerStatus(_ context.Context, uuid string, status domain.ControllerStatus) (*domain.WaterController, error) {
	c, ok := m.controllers[uuid]
	if !ok {
		return nil, errors.NotFound("CONTROLLER_NOT_FOUND", "not found")
	}
	c.Status = status
	return c, nil
}

func (m *mockIrrigationRepo) CreateSchedule(_ context.Context, s *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	s.UUID = "sched-uuid-001"
	s.ID = 1
	m.schedules[s.UUID] = s
	return s, nil
}

func (m *mockIrrigationRepo) GetScheduleByUUID(_ context.Context, uuid string) (*domain.IrrigationSchedule, error) {
	s, ok := m.schedules[uuid]
	if !ok {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", fmt.Sprintf("schedule not found: %s", uuid))
	}
	return s, nil
}

func (m *mockIrrigationRepo) ListSchedulesByField(_ context.Context, fieldID string, _, _ int32) ([]domain.IrrigationSchedule, int32, error) {
	var result []domain.IrrigationSchedule
	for _, s := range m.schedules {
		if s.FieldID == fieldID {
			result = append(result, *s)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockIrrigationRepo) ListSchedulesByZone(_ context.Context, zoneID string, _, _ int32) ([]domain.IrrigationSchedule, int32, error) {
	var result []domain.IrrigationSchedule
	for _, s := range m.schedules {
		if s.ZoneID == zoneID {
			result = append(result, *s)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockIrrigationRepo) UpdateSchedule(_ context.Context, s *domain.IrrigationSchedule) (*domain.IrrigationSchedule, error) {
	existing, ok := m.schedules[s.UUID]
	if !ok {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", "not found")
	}
	if s.Name != "" {
		existing.Name = s.Name
	}
	existing.UpdatedBy = s.UpdatedBy
	return existing, nil
}

func (m *mockIrrigationRepo) UpdateScheduleStatus(_ context.Context, uuid string, status domain.IrrigationStatus) (*domain.IrrigationSchedule, error) {
	s, ok := m.schedules[uuid]
	if !ok {
		return nil, errors.NotFound("SCHEDULE_NOT_FOUND", "not found")
	}
	s.Status = status
	return s, nil
}

func (m *mockIrrigationRepo) DeleteSchedule(_ context.Context, uuid string) error {
	delete(m.schedules, uuid)
	return nil
}

func (m *mockIrrigationRepo) CreateEvent(_ context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error) {
	evt.UUID = "event-uuid-001"
	evt.ID = 1
	m.events[evt.UUID] = evt
	return evt, nil
}

func (m *mockIrrigationRepo) GetEventByUUID(_ context.Context, uuid string) (*domain.IrrigationEvent, error) {
	evt, ok := m.events[uuid]
	if !ok {
		return nil, errors.NotFound("EVENT_NOT_FOUND", "event not found")
	}
	return evt, nil
}

func (m *mockIrrigationRepo) ListEventsByZone(_ context.Context, zoneID string, _, _ int32) ([]domain.IrrigationEvent, int32, error) {
	var result []domain.IrrigationEvent
	for _, e := range m.events {
		if e.ZoneID == zoneID {
			result = append(result, *e)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockIrrigationRepo) ListEventsByTimeRange(_ context.Context, _ string, _, _ time.Time) ([]domain.IrrigationEvent, error) {
	return nil, nil
}

func (m *mockIrrigationRepo) UpdateEvent(_ context.Context, evt *domain.IrrigationEvent) (*domain.IrrigationEvent, error) {
	return evt, nil
}

func (m *mockIrrigationRepo) CreateDecision(_ context.Context, d *domain.IrrigationDecision) (*domain.IrrigationDecision, error) {
	d.UUID = "decision-uuid-001"
	d.ID = 1
	m.decisions[d.UUID] = d
	return d, nil
}

func (m *mockIrrigationRepo) MarkDecisionApplied(_ context.Context, uuid string) error {
	if d, ok := m.decisions[uuid]; ok {
		d.Applied = true
		return nil
	}
	return errors.NotFound("DECISION_NOT_FOUND", "not found")
}

func (m *mockIrrigationRepo) CreateWaterUsageLog(_ context.Context, log *domain.WaterUsageLog) (*domain.WaterUsageLog, error) {
	log.UUID = "usage-uuid-001"
	m.usageLogs[log.ZoneID] = append(m.usageLogs[log.ZoneID], *log)
	return log, nil
}

func (m *mockIrrigationRepo) ListWaterUsageLogs(_ context.Context, zoneID string, _, _ time.Time) ([]domain.WaterUsageLog, error) {
	return m.usageLogs[zoneID], nil
}

func (m *mockIrrigationRepo) SumWaterUsageByZone(_ context.Context, zoneID string, _, _ time.Time) (float64, error) {
	total := 0.0
	for _, l := range m.usageLogs[zoneID] {
		total += l.WaterLiters
	}
	return total, nil
}

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

func newService() (*mockIrrigationRepo, *mockEventPublisher, *irrigationService) {
	repo := newMockIrrigationRepo()
	pub := &mockEventPublisher{}
	fieldClient := &mockFieldClient{existing: map[string]bool{"field-001": true}}
	farmClient := &mockFarmClient{existing: map[string]bool{"farm-001": true}}
	svc := NewIrrigationService(repo, pub, fieldClient, farmClient, nil, nopLogger{})
	return repo, pub, svc
}

// ---------------------------------------------------------------------------
// Tests: CreateIrrigation
// ---------------------------------------------------------------------------

func TestCreateIrrigation_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	entity := &domain.Irrigation{Name: "Main Irrigation"}
	created, err := svc.CreateIrrigation(ctx, entity)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, domain.IrrigationStatusActive, created.Status)
	assert.Equal(t, "irrig-uuid-001", created.UUID)
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestCreateIrrigation_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateIrrigation(ctx, &domain.Irrigation{Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateIrrigation_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateIrrigation(ctx, &domain.Irrigation{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_NAME", errors.Reason(err))
}

func TestCreateIrrigation_DuplicateName(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.names["tenant-1/Existing"] = true

	_, err := svc.CreateIrrigation(ctx, &domain.Irrigation{Name: "Existing"})
	require.Error(t, err)
	assert.True(t, errors.IsConflict(err))
	assert.Equal(t, "IRRIGATION_NAME_EXISTS", errors.Reason(err))
}

func TestCreateIrrigation_DefaultUserSystem(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "")

	created, err := svc.CreateIrrigation(ctx, &domain.Irrigation{Name: "X"})
	require.NoError(t, err)
	assert.Equal(t, "system", created.CreatedBy)
}

// ---------------------------------------------------------------------------
// Tests: GetIrrigation
// ---------------------------------------------------------------------------

func TestGetIrrigation_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.irrigations["irrig-001"] = &domain.Irrigation{
		TenantID: "tenant-1",
		Name:     "Main",
	}
	repo.irrigations["irrig-001"].UUID = "irrig-001"

	result, err := svc.GetIrrigation(ctx, "irrig-001")
	require.NoError(t, err)
	assert.Equal(t, "Main", result.Name)
}

func TestGetIrrigation_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetIrrigation(ctx, "irrig-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetIrrigation_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetIrrigation(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetIrrigation_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetIrrigation(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListIrrigations
// ---------------------------------------------------------------------------

func TestListIrrigations_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.irrigations["i1"] = &domain.Irrigation{TenantID: "tenant-1", Name: "A"}
	repo.irrigations["i1"].UUID = "i1"
	repo.irrigations["i2"] = &domain.Irrigation{TenantID: "tenant-1", Name: "B"}
	repo.irrigations["i2"].UUID = "i2"

	list, total, err := svc.ListIrrigations(ctx, domain.ListIrrigationParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, list, 2)
}

func TestListIrrigations_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListIrrigations(ctx, domain.ListIrrigationParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: UpdateIrrigation
// ---------------------------------------------------------------------------

func TestUpdateIrrigation_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.irrigations["irrig-001"] = &domain.Irrigation{
		TenantID: "tenant-1",
		Name:     "Old Name",
	}
	repo.irrigations["irrig-001"].UUID = "irrig-001"

	entity := &domain.Irrigation{Name: "New Name"}
	entity.UUID = "irrig-001"
	updated, err := svc.UpdateIrrigation(ctx, entity)
	require.NoError(t, err)
	assert.Equal(t, "New Name", updated.Name)
	assert.NotNil(t, updated.UpdatedBy)
	assert.Equal(t, "user-1", *updated.UpdatedBy)
	assert.Len(t, pub.published, 1)
}

func TestUpdateIrrigation_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	entity := &domain.Irrigation{Name: "X"}
	entity.UUID = "irrig-001"
	_, err := svc.UpdateIrrigation(ctx, entity)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestUpdateIrrigation_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateIrrigation(ctx, &domain.Irrigation{Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestUpdateIrrigation_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	entity := &domain.Irrigation{Name: "X"}
	entity.UUID = "nonexistent"
	_, err := svc.UpdateIrrigation(ctx, entity)
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: DeleteIrrigation
// ---------------------------------------------------------------------------

func TestDeleteIrrigation_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.irrigations["irrig-001"] = &domain.Irrigation{TenantID: "tenant-1", Name: "X"}
	repo.irrigations["irrig-001"].UUID = "irrig-001"

	err := svc.DeleteIrrigation(ctx, "irrig-001")
	require.NoError(t, err)
	assert.Len(t, pub.published, 1)
}

func TestDeleteIrrigation_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	err := svc.DeleteIrrigation(ctx, "irrig-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestDeleteIrrigation_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.DeleteIrrigation(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestDeleteIrrigation_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.DeleteIrrigation(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateZone
// ---------------------------------------------------------------------------

func TestCreateZone_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	zone := &domain.IrrigationZone{
		Name:    "Zone A",
		FieldID: "field-001",
		FarmID:  "farm-001",
	}
	created, err := svc.CreateZone(ctx, zone)
	require.NoError(t, err)
	assert.Equal(t, "zone-uuid-001", created.UUID)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Len(t, pub.published, 1)
}

func TestCreateZone_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateZone(ctx, &domain.IrrigationZone{Name: "Z", FieldID: "f", FarmID: "fm"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateZone_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateZone(ctx, &domain.IrrigationZone{FieldID: "f", FarmID: "fm"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_ZONE_NAME", errors.Reason(err))
}

func TestCreateZone_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateZone(ctx, &domain.IrrigationZone{Name: "Z", FarmID: "fm"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FIELD_ID", errors.Reason(err))
}

func TestCreateZone_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateZone(ctx, &domain.IrrigationZone{Name: "Z", FieldID: "f"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

func TestCreateZone_InvalidArea(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateZone(ctx, &domain.IrrigationZone{
		Name: "Z", FieldID: "f", FarmID: "fm", AreaHectares: -1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_AREA", errors.Reason(err))
}

func TestCreateZone_InvalidLatitude(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateZone(ctx, &domain.IrrigationZone{
		Name: "Z", FieldID: "f", FarmID: "fm", Latitude: 91,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_LATITUDE", errors.Reason(err))
}

func TestCreateZone_InvalidLongitude(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateZone(ctx, &domain.IrrigationZone{
		Name: "Z", FieldID: "f", FarmID: "fm", Longitude: -181,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_LONGITUDE", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetZone
// ---------------------------------------------------------------------------

func TestGetZone_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.zones["zone-001"] = &domain.IrrigationZone{
		TenantID: "tenant-1",
		Name:     "Zone A",
	}
	repo.zones["zone-001"].UUID = "zone-001"

	zone, err := svc.GetZone(ctx, "zone-001")
	require.NoError(t, err)
	assert.Equal(t, "Zone A", zone.Name)
}

func TestGetZone_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetZone(ctx, "zone-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetZone_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetZone(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ZONE_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListZonesByField
// ---------------------------------------------------------------------------

func TestListZonesByField_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListZonesByField(ctx, "field-001", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListZonesByField_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.ListZonesByField(ctx, "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FIELD_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListZonesByFarm
// ---------------------------------------------------------------------------

func TestListZonesByFarm_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListZonesByFarm(ctx, "farm-001", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListZonesByFarm_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.ListZonesByFarm(ctx, "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateController
// ---------------------------------------------------------------------------

func TestCreateController_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.zones["zone-001"] = &domain.IrrigationZone{TenantID: "tenant-1", Name: "Zone A"}
	repo.zones["zone-001"].UUID = "zone-001"

	ctrl := &domain.WaterController{
		Name:                     "Valve 1",
		ZoneID:                   "zone-001",
		Endpoint:                 "mqtt://valve1",
		MaxFlowRateLitersPerHour: 100,
	}
	created, err := svc.CreateController(ctx, ctrl)
	require.NoError(t, err)
	assert.Equal(t, "ctrl-uuid-001", created.UUID)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, domain.ControllerStatusOffline, created.Status)
}

func TestCreateController_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateController(ctx, &domain.WaterController{
		Name: "X", ZoneID: "z", Endpoint: "e", MaxFlowRateLitersPerHour: 1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateController_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateController(ctx, &domain.WaterController{
		ZoneID: "z", Endpoint: "e", MaxFlowRateLitersPerHour: 1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CONTROLLER_NAME", errors.Reason(err))
}

func TestCreateController_MissingZoneID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateController(ctx, &domain.WaterController{
		Name: "X", Endpoint: "e", MaxFlowRateLitersPerHour: 1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ZONE_ID", errors.Reason(err))
}

func TestCreateController_MissingEndpoint(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateController(ctx, &domain.WaterController{
		Name: "X", ZoneID: "z", MaxFlowRateLitersPerHour: 1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ENDPOINT", errors.Reason(err))
}

func TestCreateController_InvalidFlowRate(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateController(ctx, &domain.WaterController{
		Name: "X", ZoneID: "z", Endpoint: "e", MaxFlowRateLitersPerHour: 0,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FLOW_RATE", errors.Reason(err))
}

func TestCreateController_ZoneNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateController(ctx, &domain.WaterController{
		Name: "X", ZoneID: "nonexistent", Endpoint: "e", MaxFlowRateLitersPerHour: 1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "ZONE_NOT_FOUND", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetController
// ---------------------------------------------------------------------------

func TestGetController_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetController(ctx, "ctrl-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetController_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetController(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_CONTROLLER_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListControllersByZone
// ---------------------------------------------------------------------------

func TestListControllersByZone_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListControllersByZone(ctx, "zone-001", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListControllersByZone_MissingZoneID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.ListControllersByZone(ctx, "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ZONE_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: UpdateControllerStatus
// ---------------------------------------------------------------------------

func TestUpdateControllerStatus_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.controllers["ctrl-001"] = &domain.WaterController{
		TenantID: "tenant-1",
		Status:   domain.ControllerStatusOffline,
	}
	repo.controllers["ctrl-001"].UUID = "ctrl-001"

	updated, err := svc.UpdateControllerStatus(ctx, "ctrl-001", domain.ControllerStatusOnline)
	require.NoError(t, err)
	assert.Equal(t, domain.ControllerStatusOnline, updated.Status)
}

func TestUpdateControllerStatus_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.UpdateControllerStatus(ctx, "ctrl-001", domain.ControllerStatusOnline)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestUpdateControllerStatus_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateControllerStatus(ctx, "", domain.ControllerStatusOnline)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_CONTROLLER_ID", errors.Reason(err))
}

func TestUpdateControllerStatus_MissingStatus(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateControllerStatus(ctx, "ctrl-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_STATUS", errors.Reason(err))
}

func TestUpdateControllerStatus_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateControllerStatus(ctx, "nonexistent", domain.ControllerStatusOnline)
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateSchedule
// ---------------------------------------------------------------------------

func TestCreateSchedule_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.zones["zone-001"] = &domain.IrrigationZone{TenantID: "tenant-1", Name: "Zone A"}
	repo.zones["zone-001"].UUID = "zone-001"

	sched := &domain.IrrigationSchedule{
		Name:            "Morning Schedule",
		ZoneID:          "zone-001",
		DurationMinutes: 30,
		StartTime:       time.Now().Add(1 * time.Hour),
	}
	created, err := svc.CreateSchedule(ctx, sched)
	require.NoError(t, err)
	assert.Equal(t, "sched-uuid-001", created.UUID)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, domain.IrrigationStatusScheduled, created.Status)
	assert.Len(t, pub.published, 1)
}

func TestCreateSchedule_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateSchedule(ctx, &domain.IrrigationSchedule{
		Name: "X", ZoneID: "z", DurationMinutes: 10, StartTime: time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSchedule_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateSchedule(ctx, &domain.IrrigationSchedule{
		ZoneID: "z", DurationMinutes: 10, StartTime: time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_SCHEDULE_NAME", errors.Reason(err))
}

func TestCreateSchedule_MissingZoneID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateSchedule(ctx, &domain.IrrigationSchedule{
		Name: "X", DurationMinutes: 10, StartTime: time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ZONE_ID", errors.Reason(err))
}

func TestCreateSchedule_InvalidDuration(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateSchedule(ctx, &domain.IrrigationSchedule{
		Name: "X", ZoneID: "z", DurationMinutes: 0, StartTime: time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_DURATION", errors.Reason(err))
}

func TestCreateSchedule_MissingStartTime(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateSchedule(ctx, &domain.IrrigationSchedule{
		Name: "X", ZoneID: "z", DurationMinutes: 10,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_START_TIME", errors.Reason(err))
}

func TestCreateSchedule_InvalidWaterQuantity(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateSchedule(ctx, &domain.IrrigationSchedule{
		Name: "X", ZoneID: "z", DurationMinutes: 10, StartTime: time.Now(),
		WaterQuantityLiters: -1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_WATER_QUANTITY", errors.Reason(err))
}

func TestCreateSchedule_ZoneNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateSchedule(ctx, &domain.IrrigationSchedule{
		Name: "X", ZoneID: "nonexistent", DurationMinutes: 10, StartTime: time.Now(),
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "ZONE_NOT_FOUND", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetSchedule
// ---------------------------------------------------------------------------

func TestGetSchedule_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetSchedule(ctx, "sched-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSchedule_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSchedule(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SCHEDULE_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: CancelSchedule
// ---------------------------------------------------------------------------

func TestCancelSchedule_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.schedules["sched-001"] = &domain.IrrigationSchedule{
		TenantID: "tenant-1",
		Status:   domain.IrrigationStatusScheduled,
	}
	repo.schedules["sched-001"].UUID = "sched-001"

	err := svc.CancelSchedule(ctx, "sched-001")
	require.NoError(t, err)
	assert.Equal(t, domain.IrrigationStatusCancelled, repo.schedules["sched-001"].Status)
	assert.Len(t, pub.published, 1)
}

func TestCancelSchedule_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	err := svc.CancelSchedule(ctx, "sched-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCancelSchedule_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.CancelSchedule(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SCHEDULE_ID", errors.Reason(err))
}

func TestCancelSchedule_AlreadyCancelled(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.schedules["sched-001"] = &domain.IrrigationSchedule{
		TenantID: "tenant-1",
		Status:   domain.IrrigationStatusCancelled,
	}
	repo.schedules["sched-001"].UUID = "sched-001"

	err := svc.CancelSchedule(ctx, "sched-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "ALREADY_CANCELLED", errors.Reason(err))
}

func TestCancelSchedule_AlreadyCompleted(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.schedules["sched-001"] = &domain.IrrigationSchedule{
		TenantID: "tenant-1",
		Status:   domain.IrrigationStatusCompleted,
	}
	repo.schedules["sched-001"].UUID = "sched-001"

	err := svc.CancelSchedule(ctx, "sched-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "ALREADY_COMPLETED", errors.Reason(err))
}

func TestCancelSchedule_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.CancelSchedule(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: TriggerIrrigation
// ---------------------------------------------------------------------------

func TestTriggerIrrigation_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.schedules["sched-001"] = &domain.IrrigationSchedule{
		TenantID:            "tenant-1",
		ZoneID:              "zone-001",
		DurationMinutes:     30,
		WaterQuantityLiters: 500,
		Status:              domain.IrrigationStatusScheduled,
	}
	repo.schedules["sched-001"].UUID = "sched-001"

	evt, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.NoError(t, err)
	assert.Equal(t, "event-uuid-001", evt.UUID)
	assert.Equal(t, domain.IrrigationStatusActive, evt.Status)
	assert.NotNil(t, evt.StartedAt)
	assert.Len(t, pub.published, 1)
}

func TestTriggerIrrigation_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestTriggerIrrigation_MissingScheduleID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.TriggerIrrigation(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SCHEDULE_ID", errors.Reason(err))
}

func TestTriggerIrrigation_ScheduleNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.TriggerIrrigation(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestTriggerIrrigation_ControllerNotOnline(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.controllers["ctrl-001"] = &domain.WaterController{
		TenantID: "tenant-1",
		Status:   domain.ControllerStatusOffline,
	}
	repo.controllers["ctrl-001"].UUID = "ctrl-001"

	repo.schedules["sched-001"] = &domain.IrrigationSchedule{
		TenantID:     "tenant-1",
		ZoneID:       "zone-001",
		ControllerID: "ctrl-001",
		Status:       domain.IrrigationStatusScheduled,
	}
	repo.schedules["sched-001"].UUID = "sched-001"

	_, err := svc.TriggerIrrigation(ctx, "sched-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "CONTROLLER_NOT_ONLINE", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetEvent
// ---------------------------------------------------------------------------

func TestGetEvent_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetEvent(ctx, "evt-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetEvent_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetEvent(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_EVENT_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListEventsBySchedule
// ---------------------------------------------------------------------------

func TestListEventsBySchedule_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListEventsBySchedule(ctx, "sched-001", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListEventsBySchedule_MissingScheduleID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.ListEventsBySchedule(ctx, "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SCHEDULE_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: RequestDecision
// ---------------------------------------------------------------------------

func TestRequestDecision_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.zones["zone-001"] = &domain.IrrigationZone{TenantID: "tenant-1", Name: "Zone A"}
	repo.zones["zone-001"].UUID = "zone-001"

	decision := &domain.IrrigationDecision{
		ZoneID: "zone-001",
		Inputs: domain.DecisionInputs{SoilMoisture: 20.0, Temperature: 30.0},
	}

	result, err := svc.RequestDecision(ctx, decision)
	require.NoError(t, err)
	assert.Equal(t, "decision-uuid-001", result.UUID)
	assert.Equal(t, "tenant-1", result.TenantID)
	assert.True(t, result.Output.ShouldIrrigate) // Soil moisture 20 < 30 threshold.
	assert.False(t, result.Applied)
}

func TestRequestDecision_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.RequestDecision(ctx, &domain.IrrigationDecision{ZoneID: "z"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestRequestDecision_MissingZoneID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RequestDecision(ctx, &domain.IrrigationDecision{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ZONE_ID", errors.Reason(err))
}

func TestRequestDecision_ZoneNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RequestDecision(ctx, &domain.IrrigationDecision{ZoneID: "nonexistent"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "ZONE_NOT_FOUND", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetWaterUsage
// ---------------------------------------------------------------------------

func TestGetWaterUsage_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetWaterUsage(ctx, "zone-001", time.Now(), time.Now())
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetWaterUsage_MissingZoneID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetWaterUsage(ctx, "", time.Now(), time.Now())
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ZONE_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: computeIrrigationDecision (pure function)
// ---------------------------------------------------------------------------

func TestComputeIrrigationDecision_LowMoisture(t *testing.T) {
	output := computeIrrigationDecision(domain.DecisionInputs{SoilMoisture: 20.0})
	assert.True(t, output.ShouldIrrigate)
	assert.Greater(t, output.WaterQuantityLiters, 0.0)
	assert.Greater(t, output.DurationMinutes, int32(0))
}

func TestComputeIrrigationDecision_AdequateMoisture(t *testing.T) {
	output := computeIrrigationDecision(domain.DecisionInputs{SoilMoisture: 50.0})
	assert.False(t, output.ShouldIrrigate)
}

func TestComputeIrrigationDecision_HighTempTrigger(t *testing.T) {
	output := computeIrrigationDecision(domain.DecisionInputs{
		SoilMoisture: 40.0, // Above 30 threshold but below 45.
		Temperature:  36.0,
	})
	assert.True(t, output.ShouldIrrigate)
}

func TestComputeIrrigationDecision_RainfallReduces(t *testing.T) {
	outputNoRain := computeIrrigationDecision(domain.DecisionInputs{SoilMoisture: 20.0})
	outputWithRain := computeIrrigationDecision(domain.DecisionInputs{
		SoilMoisture:       20.0,
		RainfallForecastMM: 10.0,
	})
	assert.True(t, outputWithRain.ShouldIrrigate)
	assert.Less(t, outputWithRain.WaterQuantityLiters, outputNoRain.WaterQuantityLiters)
}
