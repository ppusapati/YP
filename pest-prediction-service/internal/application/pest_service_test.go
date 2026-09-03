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

	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/ports/outbound"
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
// Mock: PestRepository
// ---------------------------------------------------------------------------

type mockPestRepo struct {
	predictions  map[string]*domain.PestPrediction
	observations map[string]*domain.PestObservation
	species      map[string]*domain.PestSpecies
	riskMaps     map[string]*domain.PestRiskMap // keyed by speciesID+"/"+region
	alerts       map[string]*domain.PestAlert
	speciesCnt   map[string]int // pestSpeciesID -> count
}

func newMockPestRepo() *mockPestRepo {
	return &mockPestRepo{
		predictions:  make(map[string]*domain.PestPrediction),
		observations: make(map[string]*domain.PestObservation),
		species:      make(map[string]*domain.PestSpecies),
		riskMaps:     make(map[string]*domain.PestRiskMap),
		alerts:       make(map[string]*domain.PestAlert),
		speciesCnt:   make(map[string]int),
	}
}

func (m *mockPestRepo) CreatePrediction(_ context.Context, p *domain.PestPrediction) (*domain.PestPrediction, error) {
	p.ID = "prediction-uuid-001"
	m.predictions[p.ID] = p
	return p, nil
}

func (m *mockPestRepo) GetPredictionByID(_ context.Context, id, tenantID string) (*domain.PestPrediction, error) {
	p, ok := m.predictions[id]
	if !ok || p.TenantID != tenantID {
		return nil, errors.NotFound("PREDICTION_NOT_FOUND", fmt.Sprintf("prediction not found: %s", id))
	}
	return p, nil
}

func (m *mockPestRepo) ListPredictions(_ context.Context, params domain.ListPredictionsParams) ([]domain.PestPrediction, int32, error) {
	var result []domain.PestPrediction
	for _, p := range m.predictions {
		if p.TenantID == params.TenantID {
			result = append(result, *p)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockPestRepo) CountPredictionsBySpecies(_ context.Context, pestSpeciesID, _ string) (int, error) {
	return m.speciesCnt[pestSpeciesID], nil
}

func (m *mockPestRepo) CreateObservation(_ context.Context, o *domain.PestObservation) (*domain.PestObservation, error) {
	o.ID = "observation-uuid-001"
	m.observations[o.ID] = o
	return o, nil
}

func (m *mockPestRepo) ListObservations(_ context.Context, params domain.ListObservationsParams) ([]domain.PestObservation, int32, error) {
	var result []domain.PestObservation
	for _, o := range m.observations {
		if o.TenantID == params.TenantID {
			result = append(result, *o)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockPestRepo) GetSpeciesByID(_ context.Context, id, tenantID string) (*domain.PestSpecies, error) {
	s, ok := m.species[id]
	if !ok || s.TenantID != tenantID {
		return nil, errors.NotFound("SPECIES_NOT_FOUND", fmt.Sprintf("species not found: %s", id))
	}
	return s, nil
}

func (m *mockPestRepo) ListSpecies(_ context.Context, params domain.ListPestSpeciesParams) ([]domain.PestSpecies, int32, error) {
	var result []domain.PestSpecies
	for _, s := range m.species {
		if s.TenantID == params.TenantID {
			result = append(result, *s)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockPestRepo) GetRiskMap(_ context.Context, pestSpeciesID, region, tenantID string) (*domain.PestRiskMap, error) {
	key := pestSpeciesID + "/" + region
	rm, ok := m.riskMaps[key]
	if !ok || rm.TenantID != tenantID {
		return nil, errors.NotFound("RISK_MAP_NOT_FOUND", "risk map not found")
	}
	return rm, nil
}

func (m *mockPestRepo) CreateAlert(_ context.Context, a *domain.PestAlert) (*domain.PestAlert, error) {
	a.ID = "alert-uuid-001"
	m.alerts[a.ID] = a
	return a, nil
}

func (m *mockPestRepo) GetAlertByID(_ context.Context, id, tenantID string) (*domain.PestAlert, error) {
	a, ok := m.alerts[id]
	if !ok || a.TenantID != tenantID {
		return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("alert not found: %s", id))
	}
	return a, nil
}

func (m *mockPestRepo) ListAlerts(_ context.Context, params domain.ListAlertsParams) ([]domain.PestAlert, int32, error) {
	var result []domain.PestAlert
	for _, a := range m.alerts {
		if a.TenantID == params.TenantID {
			result = append(result, *a)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockPestRepo) AcknowledgeAlert(_ context.Context, id, tenantID, userID string) (*domain.PestAlert, error) {
	a, ok := m.alerts[id]
	if !ok || a.TenantID != tenantID {
		return nil, errors.NotFound("ALERT_NOT_FOUND", fmt.Sprintf("alert not found: %s", id))
	}
	a.Status = domain.AlertStatusAcknowledged
	ack := userID
	a.AcknowledgedBy = &ack
	return a, nil
}

func (m *mockPestRepo) WithTx(_ pgx.Tx) outbound.PestRepository { return m }

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
// Mock: SensorClient
// ---------------------------------------------------------------------------

type mockSensorClient struct{}

func (m *mockSensorClient) SensorExists(_ context.Context, _, _ string) (bool, error) {
	return true, nil
}

func (m *mockSensorClient) GetLatestReading(_ context.Context, _, _ string) (float64, error) {
	return 25.0, nil
}

// ---------------------------------------------------------------------------
// Mock: FarmClient
// ---------------------------------------------------------------------------

type mockFarmClient struct{}

func (m *mockFarmClient) FarmExists(_ context.Context, _, _ string) (bool, error) {
	return true, nil
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

func newService() (*mockPestRepo, *mockEventPublisher, *pestService) {
	repo := newMockPestRepo()
	pub := &mockEventPublisher{}
	svc := NewPestService(
		repo, pub,
		&mockFieldClient{existing: map[string]bool{"field-001": true}},
		&mockSensorClient{},
		&mockFarmClient{},
		nil,
		nopLogger{},
		nil,
	).(*pestService)
	return repo, pub, svc
}

// ---------------------------------------------------------------------------
// Tests: PredictPestRisk
// ---------------------------------------------------------------------------

func TestPredictPestRisk_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	params := &domain.PredictPestRiskParams{
		FarmID:   "farm-001",
		FieldID:  "field-001",
		CropType: "wheat",
		Weather: domain.WeatherFactors{
			TemperatureCelsius: 25,
			HumidityPct:        70,
			RainfallMm:         30,
			WindSpeedKmh:       10,
		},
	}

	pred, err := svc.PredictPestRisk(ctx, params)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", pred.TenantID)
	assert.Equal(t, "user-1", pred.CreatedBy)
	assert.Equal(t, "prediction-uuid-001", pred.ID)
	assert.True(t, pred.RiskLevel.IsValid())
	assert.Greater(t, pred.RiskScore, 0)
	assert.Greater(t, pred.ConfidencePct, 0.0)
	assert.NotEmpty(t, pred.RecommendedTreatments)

	// Event published.
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestPredictPestRisk_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.PredictPestRisk(ctx, &domain.PredictPestRiskParams{CropType: "wheat"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestPredictPestRisk_MissingCropType(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.PredictPestRisk(ctx, &domain.PredictPestRiskParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CROP_TYPE", errors.Reason(err))
}

func TestPredictPestRisk_DefaultUserID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "")

	params := &domain.PredictPestRiskParams{
		CropType: "wheat",
		Weather:  domain.WeatherFactors{TemperatureCelsius: 25, HumidityPct: 70},
	}

	pred, err := svc.PredictPestRisk(ctx, params)
	require.NoError(t, err)
	assert.Equal(t, "system", pred.CreatedBy)
}

func TestPredictPestRisk_HighRiskCreatesAlert(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Weather conditions that produce a high risk score.
	gs := domain.GrowthStageFlowering
	params := &domain.PredictPestRiskParams{
		FarmID:      "farm-001",
		FieldID:     "field-001",
		CropType:    "wheat",
		GrowthStage: &gs,
		Weather: domain.WeatherFactors{
			TemperatureCelsius: 30,
			HumidityPct:        90,
			RainfallMm:         60,
			WindSpeedKmh:       20,
		},
	}

	pred, err := svc.PredictPestRisk(ctx, params)
	require.NoError(t, err)
	// With these conditions, risk should be HIGH or CRITICAL.
	assert.True(t, pred.RiskLevel.Severity() >= domain.RiskLevelHigh.Severity(),
		"expected risk >= HIGH, got %s (score=%d)", pred.RiskLevel, pred.RiskScore)
	// Alert should have been auto-created.
	assert.NotEmpty(t, repo.alerts, "expected auto-created alert for high risk")
}

// ---------------------------------------------------------------------------
// Tests: GetPrediction
// ---------------------------------------------------------------------------

func TestGetPrediction_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["pred-001"] = &domain.PestPrediction{
		TenantID: "tenant-1",
		CropType: "wheat",
	}
	repo.predictions["pred-001"].ID = "pred-001"

	pred, err := svc.GetPrediction(ctx, "pred-001")
	require.NoError(t, err)
	assert.Equal(t, "wheat", pred.CropType)
}

func TestGetPrediction_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetPrediction(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestGetPrediction_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetPrediction(ctx, "pred-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestGetPrediction_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetPrediction(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListPredictions
// ---------------------------------------------------------------------------

func TestListPredictions_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["p1"] = &domain.PestPrediction{TenantID: "tenant-1"}
	repo.predictions["p1"].ID = "p1"
	repo.predictions["p2"] = &domain.PestPrediction{TenantID: "tenant-1"}
	repo.predictions["p2"].ID = "p2"

	predictions, total, err := svc.ListPredictions(ctx, domain.ListPredictionsParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, predictions, 2)
}

func TestListPredictions_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListPredictions(ctx, domain.ListPredictionsParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: ReportObservation
// ---------------------------------------------------------------------------

func TestReportObservation_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	obs := &domain.PestObservation{
		FarmID:  "farm-001",
		FieldID: "field-001",
	}

	created, err := svc.ReportObservation(ctx, obs)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.ObservedBy)
	assert.Equal(t, "observation-uuid-001", created.ID)
	assert.False(t, created.ObservedAt.IsZero())

	assert.Len(t, pub.published, 1)
}

func TestReportObservation_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.ReportObservation(ctx, &domain.PestObservation{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestReportObservation_DefaultUserID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "")

	created, err := svc.ReportObservation(ctx, &domain.PestObservation{})
	require.NoError(t, err)
	assert.Equal(t, "system", created.ObservedBy)
}

// ---------------------------------------------------------------------------
// Tests: ListObservations
// ---------------------------------------------------------------------------

func TestListObservations_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.observations["o1"] = &domain.PestObservation{TenantID: "tenant-1"}
	repo.observations["o1"].ID = "o1"

	observations, total, err := svc.ListObservations(ctx, domain.ListObservationsParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(1), total)
	assert.Len(t, observations, 1)
}

func TestListObservations_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListObservations(ctx, domain.ListObservationsParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetPestSpecies
// ---------------------------------------------------------------------------

func TestGetPestSpecies_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.species["sp-001"] = &domain.PestSpecies{
		TenantID:   "tenant-1",
		CommonName: "Fall Armyworm",
	}
	repo.species["sp-001"].ID = "sp-001"

	sp, err := svc.GetPestSpecies(ctx, "sp-001")
	require.NoError(t, err)
	assert.Equal(t, "Fall Armyworm", sp.CommonName)
}

func TestGetPestSpecies_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetPestSpecies(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestGetPestSpecies_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetPestSpecies(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListPestSpecies
// ---------------------------------------------------------------------------

func TestListPestSpecies_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.species["sp1"] = &domain.PestSpecies{TenantID: "tenant-1", CommonName: "Aphid"}
	repo.species["sp1"].ID = "sp1"

	species, total, err := svc.ListPestSpecies(ctx, domain.ListPestSpeciesParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(1), total)
	assert.Len(t, species, 1)
}

func TestListPestSpecies_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListPestSpecies(ctx, domain.ListPestSpeciesParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetTreatmentPlan
// ---------------------------------------------------------------------------

func TestGetTreatmentPlan_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["pred-001"] = &domain.PestPrediction{
		TenantID: "tenant-1",
		CropType: "wheat",
	}
	repo.predictions["pred-001"].ID = "pred-001"

	pred, err := svc.GetTreatmentPlan(ctx, "pred-001")
	require.NoError(t, err)
	assert.Equal(t, "wheat", pred.CropType)
}

func TestGetTreatmentPlan_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetTreatmentPlan(ctx, "pred-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetTreatmentPlan_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetTreatmentPlan(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetRiskMap
// ---------------------------------------------------------------------------

func TestGetRiskMap_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.riskMaps["sp-001/south-india"] = &domain.PestRiskMap{
		TenantID:         "tenant-1",
		Region:           "south-india",
		OverallRiskLevel: domain.RiskLevelModerate,
	}

	rm, err := svc.GetRiskMap(ctx, "sp-001", "south-india")
	require.NoError(t, err)
	assert.Equal(t, domain.RiskLevelModerate, rm.OverallRiskLevel)
}

func TestGetRiskMap_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetRiskMap(ctx, "sp-001", "south-india")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetRiskMap_MissingSpeciesID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetRiskMap(ctx, "", "south-india")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_SPECIES_ID", errors.Reason(err))
}

func TestGetRiskMap_MissingRegion(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetRiskMap(ctx, "sp-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_REGION", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListAlerts
// ---------------------------------------------------------------------------

func TestListAlerts_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.alerts["a1"] = &domain.PestAlert{TenantID: "tenant-1", Status: domain.AlertStatusActive}
	repo.alerts["a1"].ID = "a1"

	alerts, total, err := svc.ListAlerts(ctx, domain.ListAlertsParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(1), total)
	assert.Len(t, alerts, 1)
}

func TestListAlerts_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListAlerts(ctx, domain.ListAlertsParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: AcknowledgeAlert
// ---------------------------------------------------------------------------

func TestAcknowledgeAlert_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.alerts["alert-001"] = &domain.PestAlert{
		TenantID: "tenant-1",
		Status:   domain.AlertStatusActive,
	}
	repo.alerts["alert-001"].ID = "alert-001"

	alert, err := svc.AcknowledgeAlert(ctx, "alert-001")
	require.NoError(t, err)
	assert.Equal(t, domain.AlertStatusAcknowledged, alert.Status)
	require.NotNil(t, alert.AcknowledgedBy)
	assert.Equal(t, "user-1", *alert.AcknowledgedBy)

	assert.Len(t, pub.published, 1)
}

func TestAcknowledgeAlert_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.AcknowledgeAlert(ctx, "alert-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
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
// Tests: normalizePageSize helper
// ---------------------------------------------------------------------------

func TestNormalizePageSize(t *testing.T) {
	assert.Equal(t, defaultPageSize, normalizePageSize(0))
	assert.Equal(t, defaultPageSize, normalizePageSize(-5))
	assert.Equal(t, int32(50), normalizePageSize(50))
	assert.Equal(t, maxPageSize, normalizePageSize(200))
}

// ---------------------------------------------------------------------------
// Tests: computeRiskScore helper
// ---------------------------------------------------------------------------

func TestComputeRiskScore_HighConditions(t *testing.T) {
	gs := domain.GrowthStageFlowering
	params := &domain.PredictPestRiskParams{
		CropType:    "wheat",
		GrowthStage: &gs,
		Weather: domain.WeatherFactors{
			TemperatureCelsius: 30,
			HumidityPct:        90,
			RainfallMm:         60,
			WindSpeedKmh:       20,
		},
	}
	score := computeRiskScore(params)
	// 25 (temp) + 25 (humidity) + 15 (rainfall) + 10 (wind) + 25 (flowering) = 100
	assert.Equal(t, 100, score)
}

func TestComputeRiskScore_LowConditions(t *testing.T) {
	params := &domain.PredictPestRiskParams{
		CropType: "wheat",
		Weather: domain.WeatherFactors{
			TemperatureCelsius: 5,
			HumidityPct:        20,
			RainfallMm:         0,
			WindSpeedKmh:       2,
		},
	}
	score := computeRiskScore(params)
	assert.Equal(t, 0, score)
}
