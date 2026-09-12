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

	"p9e.in/samavaya/agriculture/sensor-service/internal/domain"
	"p9e.in/samavaya/agriculture/sensor-service/internal/ports/outbound"
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
// Mock: SensorRepository
// ---------------------------------------------------------------------------

type mockSensorRepo struct {
	sensors      map[string]*domain.Sensor        // keyed by UUID
	deviceIndex  map[string]*domain.Sensor        // keyed by tenantID+"/"+deviceID
	readings     map[string]*domain.SensorReading  // keyed by sensorID (latest)
	alerts       map[string]*domain.SensorAlert    // keyed by UUID
	alertRules   map[string][]domain.SensorAlert   // keyed by sensorID (active rules)
	networks     map[string]*domain.SensorNetwork  // keyed by UUID or farmID
	calibrations map[string]*domain.SensorCalibration // keyed by sensorID (latest)
}

func newMockSensorRepo() *mockSensorRepo {
	return &mockSensorRepo{
		sensors:      make(map[string]*domain.Sensor),
		deviceIndex:  make(map[string]*domain.Sensor),
		readings:     make(map[string]*domain.SensorReading),
		alerts:       make(map[string]*domain.SensorAlert),
		alertRules:   make(map[string][]domain.SensorAlert),
		networks:     make(map[string]*domain.SensorNetwork),
		calibrations: make(map[string]*domain.SensorCalibration),
	}
}

func (m *mockSensorRepo) CreateSensor(_ context.Context, s *domain.Sensor) (*domain.Sensor, error) {
	s.ID = "sensor-uuid-001"
	m.sensors[s.ID] = s
	m.deviceIndex[s.TenantID+"/"+s.DeviceID] = s
	return s, nil
}

func (m *mockSensorRepo) GetSensorByUUID(_ context.Context, uuid, tenantID string) (*domain.Sensor, error) {
	s, ok := m.sensors[uuid]
	if !ok || s.TenantID != tenantID {
		return nil, errors.NotFound("SENSOR_NOT_FOUND", fmt.Sprintf("sensor not found: %s", uuid))
	}
	return s, nil
}

func (m *mockSensorRepo) GetSensorByDeviceID(_ context.Context, deviceID, tenantID string) (*domain.Sensor, error) {
	s, ok := m.deviceIndex[tenantID+"/"+deviceID]
	if !ok {
		return nil, errors.NotFound("SENSOR_NOT_FOUND", "sensor not found by device ID")
	}
	return s, nil
}

func (m *mockSensorRepo) ListSensors(_ context.Context, filter domain.SensorListFilter) ([]domain.Sensor, int32, error) {
	var result []domain.Sensor
	for _, s := range m.sensors {
		if s.TenantID == filter.TenantID {
			result = append(result, *s)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockSensorRepo) UpdateSensor(_ context.Context, s *domain.Sensor) (*domain.Sensor, error) {
	existing, ok := m.sensors[s.ID]
	if !ok {
		return nil, errors.NotFound("SENSOR_NOT_FOUND", "sensor not found")
	}
	if s.Name != "" {
		existing.Name = s.Name
	}
	existing.UpdatedBy = s.UpdatedBy
	return existing, nil
}

func (m *mockSensorRepo) DecommissionSensor(_ context.Context, uuid, tenantID, _ string) (*domain.Sensor, error) {
	s, ok := m.sensors[uuid]
	if !ok || s.TenantID != tenantID {
		return nil, errors.NotFound("SENSOR_NOT_FOUND", "sensor not found")
	}
	s.Status = domain.SensorStatusDecommissioned
	return s, nil
}

func (m *mockSensorRepo) UpdateSensorLastReading(_ context.Context, _, _ string, _ time.Time, _, _ *float64) error {
	return nil
}

func (m *mockSensorRepo) CreateReading(_ context.Context, r *domain.SensorReading) (*domain.SensorReading, error) {
	r.ID = "reading-uuid-001"
	m.readings[r.SensorID] = r
	return r, nil
}

func (m *mockSensorRepo) GetLatestReading(_ context.Context, sensorID, tenantID string) (*domain.SensorReading, error) {
	r, ok := m.readings[sensorID]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("READING_NOT_FOUND", "no readings found")
	}
	return r, nil
}

func (m *mockSensorRepo) GetReadingHistory(_ context.Context, _, _ string, _, _ time.Time, _ string, _, _ int32) ([]domain.SensorReading, int32, error) {
	return nil, 0, nil
}

func (m *mockSensorRepo) CreateAlert(_ context.Context, a *domain.SensorAlert) (*domain.SensorAlert, error) {
	a.ID = "alert-uuid-001"
	m.alerts[a.ID] = a
	return a, nil
}

func (m *mockSensorRepo) ListAlerts(_ context.Context, filter domain.AlertListFilter) ([]domain.SensorAlert, int32, error) {
	var result []domain.SensorAlert
	for _, a := range m.alerts {
		if a.TenantID == filter.TenantID {
			result = append(result, *a)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockSensorRepo) AcknowledgeAlert(_ context.Context, uuid, tenantID, userID string) (*domain.SensorAlert, error) {
	a, ok := m.alerts[uuid]
	if !ok || a.TenantID != tenantID {
		return nil, errors.NotFound("ALERT_NOT_FOUND", "alert not found")
	}
	a.Acknowledged = true
	a.AcknowledgedBy = &userID
	now := time.Now()
	a.AcknowledgedAt = &now
	return a, nil
}

func (m *mockSensorRepo) GetActiveAlertsForSensor(_ context.Context, sensorID, _ string) ([]domain.SensorAlert, error) {
	return m.alertRules[sensorID], nil
}

func (m *mockSensorRepo) GetSensorNetworkByUUID(_ context.Context, uuid, tenantID string) (*domain.SensorNetwork, error) {
	n, ok := m.networks[uuid]
	if !ok || n.TenantID != tenantID {
		return nil, errors.NotFound("NETWORK_NOT_FOUND", "network not found")
	}
	return n, nil
}

func (m *mockSensorRepo) GetSensorNetworkByFarm(_ context.Context, farmID, tenantID string) (*domain.SensorNetwork, error) {
	for _, n := range m.networks {
		if n.FarmID == farmID && n.TenantID == tenantID {
			return n, nil
		}
	}
	return nil, errors.NotFound("NETWORK_NOT_FOUND", "network not found for farm")
}

func (m *mockSensorRepo) CreateCalibration(_ context.Context, cal *domain.SensorCalibration) (*domain.SensorCalibration, error) {
	cal.ID = "cal-uuid-001"
	m.calibrations[cal.SensorID] = cal
	return cal, nil
}

func (m *mockSensorRepo) GetLatestCalibration(_ context.Context, sensorID, _ string) (*domain.SensorCalibration, error) {
	c, ok := m.calibrations[sensorID]
	if !ok {
		return nil, errors.NotFound("CALIBRATION_NOT_FOUND", "no calibration found")
	}
	return c, nil
}

func (m *mockSensorRepo) WithTx(_ pgx.Tx) outbound.SensorRepository { return m }

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

func newService() (*mockSensorRepo, *mockEventPublisher, *sensorService) {
	repo := newMockSensorRepo()
	pub := &mockEventPublisher{}
	fieldClient := &mockFieldClient{existing: map[string]bool{"field-001": true}}
	farmClient := &mockFarmClient{existing: map[string]bool{"farm-001": true}}
	svc := NewSensorService(repo, pub, fieldClient, farmClient, nil, nopLogger{})
	return repo, pub, svc
}

func validSensor() *domain.Sensor {
	return &domain.Sensor{
		DeviceID:   "device-001",
		FieldID:    "field-001",
		FarmID:     "farm-001",
		SensorType: domain.SensorTypeSoilMoisture,
		Name:       "Moisture Sensor A",
	}
}

// ---------------------------------------------------------------------------
// Tests: RegisterSensor
// ---------------------------------------------------------------------------

func TestRegisterSensor_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	created, err := svc.RegisterSensor(ctx, sensor)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, domain.SensorStatusActive, created.Status)
	assert.Equal(t, "sensor-uuid-001", created.ID)

	// Event published.
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestRegisterSensor_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.RegisterSensor(ctx, validSensor())
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestRegisterSensor_MissingDeviceID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	sensor.DeviceID = ""
	_, err := svc.RegisterSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_DEVICE_ID", errors.Reason(err))
}

func TestRegisterSensor_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	sensor.FieldID = ""
	_, err := svc.RegisterSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FIELD_ID", errors.Reason(err))
}

func TestRegisterSensor_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	sensor.FarmID = ""
	_, err := svc.RegisterSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

func TestRegisterSensor_InvalidSensorType(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	sensor.SensorType = "INVALID"
	_, err := svc.RegisterSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_SENSOR_TYPE", errors.Reason(err))
}

func TestRegisterSensor_NegativeInterval(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	sensor.ReadingIntervalSeconds = -1
	_, err := svc.RegisterSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_INTERVAL", errors.Reason(err))
}

func TestRegisterSensor_InvalidLatitude(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	lat := 91.0
	sensor.Latitude = &lat
	_, err := svc.RegisterSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_LATITUDE", errors.Reason(err))
}

func TestRegisterSensor_InvalidLongitude(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := validSensor()
	lng := -181.0
	sensor.Longitude = &lng
	_, err := svc.RegisterSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_LONGITUDE", errors.Reason(err))
}

func TestRegisterSensor_DuplicateDevice(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Pre-register device.
	existing := validSensor()
	existing.TenantID = "tenant-1"
	existing.ID = "existing-uuid"
	repo.sensors["existing-uuid"] = existing
	repo.deviceIndex["tenant-1/device-001"] = existing

	_, err := svc.RegisterSensor(ctx, validSensor())
	require.Error(t, err)
	assert.True(t, errors.IsConflict(err))
}

func TestRegisterSensor_DefaultUserSystem(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "") // no user

	sensor := validSensor()
	created, err := svc.RegisterSensor(ctx, sensor)
	require.NoError(t, err)
	assert.Equal(t, "system", created.CreatedBy)
}

// ---------------------------------------------------------------------------
// Tests: GetSensor
// ---------------------------------------------------------------------------

func TestGetSensor_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		Name:       "Temp Sensor",
		SensorType: domain.SensorTypeTemperature,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	sensor, err := svc.GetSensor(ctx, "sensor-001")
	require.NoError(t, err)
	assert.Equal(t, "Temp Sensor", sensor.Name)
}

func TestGetSensor_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetSensor(ctx, "sensor-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestGetSensor_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSensor(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetSensor_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSensor(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListSensors
// ---------------------------------------------------------------------------

func TestListSensors_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["s1"] = &domain.Sensor{TenantID: "tenant-1", Name: "A"}
	repo.sensors["s1"].ID = "s1"
	repo.sensors["s2"] = &domain.Sensor{TenantID: "tenant-1", Name: "B"}
	repo.sensors["s2"].ID = "s2"

	sensors, total, err := svc.ListSensors(ctx, domain.SensorListFilter{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, sensors, 2)
}

func TestListSensors_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListSensors(ctx, domain.SensorListFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListSensors_DefaultPageSize(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Should not error with zero page size, it defaults.
	_, _, err := svc.ListSensors(ctx, domain.SensorListFilter{PageSize: 0})
	require.NoError(t, err)
}

func TestListSensors_ClampsMaxPageSize(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.ListSensors(ctx, domain.SensorListFilter{PageSize: 500})
	require.NoError(t, err)
}

// ---------------------------------------------------------------------------
// Tests: UpdateSensor
// ---------------------------------------------------------------------------

func TestUpdateSensor_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		Name:       "Old Name",
		SensorType: domain.SensorTypeSoilMoisture,
		Status:     domain.SensorStatusActive,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	updated, err := svc.UpdateSensor(ctx, &domain.Sensor{
		Name: "New Name",
	})
	// UUID is required, so missing UUID should fail.
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))

	// Now with UUID.
	sensor := &domain.Sensor{Name: "New Name"}
	sensor.ID = "sensor-001"
	updated, err = svc.UpdateSensor(ctx, sensor)
	require.NoError(t, err)
	assert.Equal(t, "New Name", updated.Name)
	assert.NotNil(t, updated.UpdatedBy)
	assert.Equal(t, "user-1", *updated.UpdatedBy)

	// Event published.
	assert.Len(t, pub.published, 1)
}

func TestUpdateSensor_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	sensor := &domain.Sensor{Name: "X"}
	sensor.ID = "sensor-001"
	_, err := svc.UpdateSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestUpdateSensor_Decommissioned(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID: "tenant-1",
		Status:   domain.SensorStatusDecommissioned,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	sensor := &domain.Sensor{Name: "X"}
	sensor.ID = "sensor-001"
	_, err := svc.UpdateSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "SENSOR_DECOMMISSIONED", errors.Reason(err))
}

func TestUpdateSensor_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sensor := &domain.Sensor{Name: "X"}
	sensor.ID = "nonexistent"
	_, err := svc.UpdateSensor(ctx, sensor)
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: DecommissionSensor
// ---------------------------------------------------------------------------

func TestDecommissionSensor_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID: "tenant-1",
		DeviceID: "dev-001",
		Status:   domain.SensorStatusActive,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	decommissioned, err := svc.DecommissionSensor(ctx, "sensor-001", "end of life")
	require.NoError(t, err)
	assert.Equal(t, domain.SensorStatusDecommissioned, decommissioned.Status)
	assert.Len(t, pub.published, 1)
}

func TestDecommissionSensor_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.DecommissionSensor(ctx, "sensor-001", "reason")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestDecommissionSensor_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.DecommissionSensor(ctx, "", "reason")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestDecommissionSensor_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.DecommissionSensor(ctx, "nonexistent", "reason")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: IngestReading
// ---------------------------------------------------------------------------

func TestIngestReading_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		SensorType: domain.SensorTypeSoilMoisture,
		Status:     domain.SensorStatusActive,
		FieldID:    "field-001",
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	reading, alert, err := svc.IngestReading(ctx, "sensor-001", 45.0, "%", time.Now(), domain.ReadingQualityGood, nil, nil, nil)
	require.NoError(t, err)
	assert.NotNil(t, reading)
	assert.Equal(t, "reading-uuid-001", reading.ID)
	assert.Nil(t, alert) // No alert rules set up.
	assert.Len(t, pub.published, 1)
}

func TestIngestReading_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.IngestReading(ctx, "sensor-001", 45.0, "%", time.Now(), "", nil, nil, nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestIngestReading_MissingSensorID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.IngestReading(ctx, "", 45.0, "%", time.Now(), "", nil, nil, nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SENSOR_ID", errors.Reason(err))
}

func TestIngestReading_SensorNotActive(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID: "tenant-1",
		Status:   domain.SensorStatusInactive,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	_, _, err := svc.IngestReading(ctx, "sensor-001", 45.0, "%", time.Now(), "", nil, nil, nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "SENSOR_NOT_ACTIVE", errors.Reason(err))
}

func TestIngestReading_SensorNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.IngestReading(ctx, "nonexistent", 45.0, "%", time.Now(), "", nil, nil, nil)
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestIngestReading_AppliesCalibration(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		SensorType: domain.SensorTypeSoilMoisture,
		Status:     domain.SensorStatusActive,
		FieldID:    "field-001",
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	// Set up calibration: value = (raw * scale) + offset
	repo.calibrations["sensor-001"] = &domain.SensorCalibration{
		SensorID:    "sensor-001",
		ScaleFactor: 1.1,
		OffsetValue: 2.0,
	}

	reading, _, err := svc.IngestReading(ctx, "sensor-001", 40.0, "%", time.Now(), domain.ReadingQualityGood, nil, nil, nil)
	require.NoError(t, err)
	// Calibrated value = (40.0 * 1.1) + 2.0 = 46.0
	assert.Equal(t, 46.0, reading.Value)
}

func TestIngestReading_DefaultUnit(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		SensorType: domain.SensorTypeTemperature,
		Status:     domain.SensorStatusActive,
		FieldID:    "field-001",
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	reading, _, err := svc.IngestReading(ctx, "sensor-001", 25.0, "", time.Now(), domain.ReadingQualityGood, nil, nil, nil)
	require.NoError(t, err)
	assert.NotEmpty(t, reading.Unit) // Should default from ValidReadingRanges
}

// ---------------------------------------------------------------------------
// Tests: BatchIngestReadings
// ---------------------------------------------------------------------------

func TestBatchIngestReadings_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		SensorType: domain.SensorTypeSoilMoisture,
		Status:     domain.SensorStatusActive,
		FieldID:    "field-001",
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	readings := []domain.ReadingInput{
		{SensorID: "sensor-001", Value: 30.0, Unit: "%", Timestamp: time.Now()},
		{SensorID: "sensor-001", Value: 35.0, Unit: "%", Timestamp: time.Now()},
	}

	ingested, failed, errs, _, err := svc.BatchIngestReadings(ctx, readings)
	require.NoError(t, err)
	assert.Equal(t, int32(2), ingested)
	assert.Equal(t, int32(0), failed)
	assert.Empty(t, errs)
}

func TestBatchIngestReadings_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, _, _, err := svc.BatchIngestReadings(ctx, []domain.ReadingInput{{SensorID: "s1"}})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestBatchIngestReadings_EmptyBatch(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, _, _, err := svc.BatchIngestReadings(ctx, nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "EMPTY_BATCH", errors.Reason(err))
}

func TestBatchIngestReadings_TooLarge(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	readings := make([]domain.ReadingInput, 10001)
	_, _, _, _, err := svc.BatchIngestReadings(ctx, readings)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "BATCH_TOO_LARGE", errors.Reason(err))
}

func TestBatchIngestReadings_PartialFailure(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		SensorType: domain.SensorTypeSoilMoisture,
		Status:     domain.SensorStatusActive,
		FieldID:    "field-001",
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	readings := []domain.ReadingInput{
		{SensorID: "sensor-001", Value: 30.0},
		{SensorID: "nonexistent", Value: 40.0}, // Will fail: sensor not found.
	}

	ingested, failed, errs, _, err := svc.BatchIngestReadings(ctx, readings)
	require.NoError(t, err)
	assert.Equal(t, int32(1), ingested)
	assert.Equal(t, int32(1), failed)
	assert.Len(t, errs, 1)
}

// ---------------------------------------------------------------------------
// Tests: GetLatestReading
// ---------------------------------------------------------------------------

func TestGetLatestReading_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetLatestReading(ctx, "sensor-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetLatestReading_MissingSensorID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetLatestReading(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SENSOR_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetReadingHistory
// ---------------------------------------------------------------------------

func TestGetReadingHistory_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.GetReadingHistory(ctx, "sensor-001", time.Time{}, time.Time{}, "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetReadingHistory_MissingSensorID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, _, err := svc.GetReadingHistory(ctx, "", time.Time{}, time.Time{}, "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SENSOR_ID", errors.Reason(err))
}

func TestGetReadingHistory_InvalidTimeRange(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	start := time.Now()
	end := start.Add(-1 * time.Hour) // end before start

	_, _, err := svc.GetReadingHistory(ctx, "sensor-001", start, end, "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_TIME_RANGE", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateAlert
// ---------------------------------------------------------------------------

func TestCreateAlert_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID:   "tenant-1",
		SensorType: domain.SensorTypeSoilMoisture,
		FieldID:    "field-001",
		Status:     domain.SensorStatusActive,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	alert := &domain.SensorAlert{
		SensorID:  "sensor-001",
		Condition: domain.AlertConditionGT,
		Threshold: 80.0,
	}

	created, err := svc.CreateAlert(ctx, alert)
	require.NoError(t, err)
	assert.Equal(t, "alert-uuid-001", created.ID)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "field-001", created.FieldID)
	assert.Equal(t, domain.SensorTypeSoilMoisture, created.SensorType)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.True(t, created.IsActive)
	assert.Equal(t, domain.AlertSeverityMedium, created.Severity) // Default severity.
}

func TestCreateAlert_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateAlert(ctx, &domain.SensorAlert{SensorID: "s1", Condition: "GT"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateAlert_MissingSensorID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateAlert(ctx, &domain.SensorAlert{Condition: "GT"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SENSOR_ID", errors.Reason(err))
}

func TestCreateAlert_MissingCondition(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateAlert(ctx, &domain.SensorAlert{SensorID: "s1"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_CONDITION", errors.Reason(err))
}

func TestCreateAlert_SensorNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateAlert(ctx, &domain.SensorAlert{SensorID: "nonexistent", Condition: "GT"})
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListAlerts
// ---------------------------------------------------------------------------

func TestListAlerts_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListAlerts(ctx, domain.AlertListFilter{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: AcknowledgeAlert
// ---------------------------------------------------------------------------

func TestAcknowledgeAlert_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.alerts["alert-001"] = &domain.SensorAlert{
		TenantID: "tenant-1",
		SensorID: "sensor-001",
	}
	repo.alerts["alert-001"].ID = "alert-001"

	acked, err := svc.AcknowledgeAlert(ctx, "alert-001")
	require.NoError(t, err)
	assert.True(t, acked.Acknowledged)
	assert.NotNil(t, acked.AcknowledgedBy)
	assert.Equal(t, "user-1", *acked.AcknowledgedBy)
}

func TestAcknowledgeAlert_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.AcknowledgeAlert(ctx, "alert-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestAcknowledgeAlert_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AcknowledgeAlert(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestAcknowledgeAlert_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AcknowledgeAlert(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: GetSensorNetwork
// ---------------------------------------------------------------------------

func TestGetSensorNetwork_ByID(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.networks["net-001"] = &domain.SensorNetwork{
		TenantID: "tenant-1",
		FarmID:   "farm-001",
		Name:     "Main Network",
	}
	repo.networks["net-001"].ID = "net-001"

	network, err := svc.GetSensorNetwork(ctx, "net-001", "")
	require.NoError(t, err)
	assert.Equal(t, "Main Network", network.Name)
}

func TestGetSensorNetwork_ByFarmID(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.networks["net-001"] = &domain.SensorNetwork{
		TenantID: "tenant-1",
		FarmID:   "farm-001",
		Name:     "Farm Network",
	}
	repo.networks["net-001"].ID = "net-001"

	network, err := svc.GetSensorNetwork(ctx, "", "farm-001")
	require.NoError(t, err)
	assert.Equal(t, "Farm Network", network.Name)
}

func TestGetSensorNetwork_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetSensorNetwork(ctx, "net-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSensorNetwork_MissingIdentifier(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSensorNetwork(ctx, "", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_IDENTIFIER", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: CalibrateSensor
// ---------------------------------------------------------------------------

func TestCalibrateSensor_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID: "tenant-1",
		Status:   domain.SensorStatusActive,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	cal, err := svc.CalibrateSensor(ctx, "sensor-001", 1.5, 1.1, "annual calibration", nil)
	require.NoError(t, err)
	assert.Equal(t, "cal-uuid-001", cal.ID)
	assert.Equal(t, 1.5, cal.OffsetValue)
	assert.Equal(t, 1.1, cal.ScaleFactor)
	assert.Equal(t, "user-1", cal.CalibratedBy)
	assert.Len(t, pub.published, 1)
}

func TestCalibrateSensor_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CalibrateSensor(ctx, "sensor-001", 0, 1.0, "", nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCalibrateSensor_MissingSensorID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CalibrateSensor(ctx, "", 0, 1.0, "", nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SENSOR_ID", errors.Reason(err))
}

func TestCalibrateSensor_ZeroScaleFactor(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CalibrateSensor(ctx, "sensor-001", 0, 0, "", nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_SCALE_FACTOR", errors.Reason(err))
}

func TestCalibrateSensor_Decommissioned(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.sensors["sensor-001"] = &domain.Sensor{
		TenantID: "tenant-1",
		Status:   domain.SensorStatusDecommissioned,
	}
	repo.sensors["sensor-001"].ID = "sensor-001"

	_, err := svc.CalibrateSensor(ctx, "sensor-001", 0, 1.0, "", nil)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "SENSOR_DECOMMISSIONED", errors.Reason(err))
}

func TestCalibrateSensor_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CalibrateSensor(ctx, "nonexistent", 0, 1.0, "", nil)
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}
