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

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/outbound"
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
// Mock: YieldRepository
// ---------------------------------------------------------------------------

type mockYieldRepo struct {
	predictions  map[string]*domain.YieldPrediction
	yieldRecords map[string]*domain.YieldRecord
	harvestPlans map[string]*domain.HarvestPlan
	performances map[string]*domain.CropPerformance // keyed by "tenantID/farmID/fieldID/cropID/season/year"
}

func newMockYieldRepo() *mockYieldRepo {
	return &mockYieldRepo{
		predictions:  make(map[string]*domain.YieldPrediction),
		yieldRecords: make(map[string]*domain.YieldRecord),
		harvestPlans: make(map[string]*domain.HarvestPlan),
		performances: make(map[string]*domain.CropPerformance),
	}
}

func (m *mockYieldRepo) CreatePrediction(_ context.Context, p *domain.YieldPrediction) (*domain.YieldPrediction, error) {
	p.UUID = "prediction-uuid-001"
	p.ID = 1
	m.predictions[p.UUID] = p
	return p, nil
}

func (m *mockYieldRepo) GetPredictionByID(_ context.Context, id, tenantID string) (*domain.YieldPrediction, error) {
	p, ok := m.predictions[id]
	if !ok || p.TenantID != tenantID {
		return nil, errors.NotFound("PREDICTION_NOT_FOUND", fmt.Sprintf("prediction not found: %s", id))
	}
	return p, nil
}

func (m *mockYieldRepo) ListPredictions(_ context.Context, params domain.ListPredictionsParams) ([]domain.YieldPrediction, int32, error) {
	var result []domain.YieldPrediction
	for _, p := range m.predictions {
		if p.TenantID == params.TenantID {
			result = append(result, *p)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockYieldRepo) CreateYieldRecord(_ context.Context, r *domain.YieldRecord) (*domain.YieldRecord, error) {
	r.UUID = "record-uuid-001"
	r.ID = 1
	m.yieldRecords[r.UUID] = r
	return r, nil
}

func (m *mockYieldRepo) ListYieldRecords(_ context.Context, params domain.YieldHistoryParams) ([]domain.YieldRecord, int32, error) {
	var result []domain.YieldRecord
	for _, r := range m.yieldRecords {
		if r.TenantID == params.TenantID {
			result = append(result, *r)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockYieldRepo) CreateHarvestPlan(_ context.Context, p *domain.HarvestPlan) (*domain.HarvestPlan, error) {
	p.UUID = "plan-uuid-001"
	p.ID = 1
	m.harvestPlans[p.UUID] = p
	return p, nil
}

func (m *mockYieldRepo) GetHarvestPlanByID(_ context.Context, id, tenantID string) (*domain.HarvestPlan, error) {
	p, ok := m.harvestPlans[id]
	if !ok || p.TenantID != tenantID {
		return nil, errors.NotFound("HARVEST_PLAN_NOT_FOUND", fmt.Sprintf("harvest plan not found: %s", id))
	}
	return p, nil
}

func (m *mockYieldRepo) ListHarvestPlans(_ context.Context, params domain.ListHarvestPlansParams) ([]domain.HarvestPlan, int32, error) {
	var result []domain.HarvestPlan
	for _, p := range m.harvestPlans {
		if p.TenantID == params.TenantID {
			result = append(result, *p)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockYieldRepo) GetCropPerformance(_ context.Context, params domain.CropPerformanceParams) (*domain.CropPerformance, error) {
	key := fmt.Sprintf("%s/%s/%s/%s/%s/%d", params.TenantID, params.FarmID, params.FieldID, params.CropID, params.Season, params.Year)
	p, ok := m.performances[key]
	if !ok {
		return nil, errors.NotFound("PERFORMANCE_NOT_FOUND", "crop performance not found")
	}
	return p, nil
}

func (m *mockYieldRepo) WithTx(_ pgx.Tx) outbound.YieldRepository { return m }

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
// Mock: SoilClient
// ---------------------------------------------------------------------------

type mockSoilClient struct{}

func (m *mockSoilClient) SoilExists(_ context.Context, _, _ string) (bool, error) {
	return true, nil
}

func (m *mockSoilClient) GetLatestAnalysis(_ context.Context, _, _ string) (float64, error) {
	return 75.0, nil
}

// ---------------------------------------------------------------------------
// Mock: IrrigationClient
// ---------------------------------------------------------------------------

type mockIrrigationClient struct{}

func (m *mockIrrigationClient) IrrigationExists(_ context.Context, _, _ string) (bool, error) {
	return true, nil
}

func (m *mockIrrigationClient) GetWaterUsage(_ context.Context, _, _ string) (float64, error) {
	return 50.0, nil
}

// ---------------------------------------------------------------------------
// Mock: PestClient
// ---------------------------------------------------------------------------

type mockPestClient struct{}

func (m *mockPestClient) PestExists(_ context.Context, _, _ string) (bool, error) {
	return true, nil
}

func (m *mockPestClient) GetLatestPrediction(_ context.Context, _, _ string) (string, error) {
	return "LOW", nil
}

// ---------------------------------------------------------------------------
// Mock: CropClient
// ---------------------------------------------------------------------------

type mockCropClient struct{}

func (m *mockCropClient) CropExists(_ context.Context, _, _ string) (bool, error) {
	return true, nil
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

func newService() (*mockYieldRepo, *mockEventPublisher, *yieldService) {
	repo := newMockYieldRepo()
	pub := &mockEventPublisher{}
	svc := NewYieldService(
		repo, pub,
		&mockFieldClient{existing: map[string]bool{"field-001": true}},
		&mockSoilClient{},
		&mockIrrigationClient{},
		&mockPestClient{},
		&mockCropClient{},
		&mockFarmClient{},
		nil,
		nopLogger{},
	).(*yieldService)
	return repo, pub, svc
}

// ---------------------------------------------------------------------------
// Tests: PredictYield
// ---------------------------------------------------------------------------

func TestPredictYield_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	prediction := &domain.YieldPrediction{
		FarmID:            "farm-001",
		FieldID:           "field-001",
		CropID:            "wheat",
		Season:            "kharif",
		Year:              2026,
		SoilQualityScore:  80,
		WeatherScore:      70,
		IrrigationScore:   60,
		PestPressureScore: 50,
		NutrientScore:     65,
		ManagementScore:   75,
	}

	created, err := svc.PredictYield(ctx, prediction)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, "PREDICTION_STATUS_COMPLETED", created.Status)
	assert.Equal(t, domain.PredictionModelVersion, created.PredictionModelVersion)
	assert.Greater(t, created.PredictedYieldKgPerHectare, 0.0)
	assert.Greater(t, created.PredictionConfidencePct, 0.0)
	assert.Equal(t, "prediction-uuid-001", created.UUID)

	// Event published.
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestPredictYield_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.PredictYield(ctx, &domain.YieldPrediction{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestPredictYield_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.PredictYield(ctx, &domain.YieldPrediction{
		FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FARM_ID", errors.Reason(err))
}

func TestPredictYield_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.PredictYield(ctx, &domain.YieldPrediction{
		FarmID: "farm-001", CropID: "wheat", Season: "kharif", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FIELD_ID", errors.Reason(err))
}

func TestPredictYield_MissingCropID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.PredictYield(ctx, &domain.YieldPrediction{
		FarmID: "farm-001", FieldID: "field-001", Season: "kharif", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CROP_ID", errors.Reason(err))
}

func TestPredictYield_MissingSeason(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.PredictYield(ctx, &domain.YieldPrediction{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_SEASON", errors.Reason(err))
}

func TestPredictYield_InvalidYear(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.PredictYield(ctx, &domain.YieldPrediction{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: 0,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_YEAR", errors.Reason(err))
}

func TestPredictYield_DefaultUserID(t *testing.T) {
	_, _, svc := newService()
	// Context with tenant but no user.
	ctx := testContext("tenant-1", "")

	prediction := &domain.YieldPrediction{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: 2026,
	}

	created, err := svc.PredictYield(ctx, prediction)
	require.NoError(t, err)
	assert.Equal(t, "system", created.CreatedBy)
}

// ---------------------------------------------------------------------------
// Tests: GetPrediction
// ---------------------------------------------------------------------------

func TestGetPrediction_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["pred-001"] = &domain.YieldPrediction{
		FarmID:  "farm-001",
		FieldID: "field-001",
		CropID:  "wheat",
	}
	repo.predictions["pred-001"].TenantID = "tenant-1"
	repo.predictions["pred-001"].UUID = "pred-001"

	pred, err := svc.GetPrediction(ctx, "pred-001")
	require.NoError(t, err)
	assert.Equal(t, "wheat", pred.CropID)
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

	repo.predictions["p1"] = &domain.YieldPrediction{FarmID: "farm-001"}
	repo.predictions["p1"].TenantID = "tenant-1"
	repo.predictions["p1"].UUID = "p1"
	repo.predictions["p2"] = &domain.YieldPrediction{FarmID: "farm-001"}
	repo.predictions["p2"].TenantID = "tenant-1"
	repo.predictions["p2"].UUID = "p2"

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
// Tests: RecordYield
// ---------------------------------------------------------------------------

func TestRecordYield_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	record := &domain.YieldRecord{
		FarmID:            "farm-001",
		FieldID:           "field-001",
		CropID:            "wheat",
		Season:            "kharif",
		Year:              2026,
		RevenuePerHectare: 1000.0,
		CostPerHectare:    400.0,
	}

	created, err := svc.RecordYield(ctx, record)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, 600.0, created.ProfitPerHectare)
	assert.Equal(t, "record-uuid-001", created.UUID)

	assert.Len(t, pub.published, 1)
}

func TestRecordYield_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.RecordYield(ctx, &domain.YieldRecord{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestRecordYield_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RecordYield(ctx, &domain.YieldRecord{
		FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FARM_ID", errors.Reason(err))
}

func TestRecordYield_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RecordYield(ctx, &domain.YieldRecord{
		FarmID: "farm-001", CropID: "wheat", Season: "kharif", Year: 2026,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FIELD_ID", errors.Reason(err))
}

func TestRecordYield_InvalidYear(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RecordYield(ctx, &domain.YieldRecord{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: -1,
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_YEAR", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetYieldHistory
// ---------------------------------------------------------------------------

func TestGetYieldHistory_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.yieldRecords["r1"] = &domain.YieldRecord{FarmID: "farm-001"}
	repo.yieldRecords["r1"].TenantID = "tenant-1"
	repo.yieldRecords["r1"].UUID = "r1"

	records, total, err := svc.GetYieldHistory(ctx, domain.YieldHistoryParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(1), total)
	assert.Len(t, records, 1)
}

func TestGetYieldHistory_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.GetYieldHistory(ctx, domain.YieldHistoryParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateHarvestPlan
// ---------------------------------------------------------------------------

func TestCreateHarvestPlan_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	plan := &domain.HarvestPlan{
		FarmID:  "farm-001",
		FieldID: "field-001",
		CropID:  "wheat",
	}

	created, err := svc.CreateHarvestPlan(ctx, plan)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, "HARVEST_PLAN_STATUS_DRAFT", created.Status)
	assert.Equal(t, "plan-uuid-001", created.UUID)

	assert.Len(t, pub.published, 1)
}

func TestCreateHarvestPlan_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateHarvestPlan(ctx, &domain.HarvestPlan{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateHarvestPlan_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateHarvestPlan(ctx, &domain.HarvestPlan{
		FieldID: "field-001", CropID: "wheat",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FARM_ID", errors.Reason(err))
}

func TestCreateHarvestPlan_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateHarvestPlan(ctx, &domain.HarvestPlan{
		FarmID: "farm-001", CropID: "wheat",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FIELD_ID", errors.Reason(err))
}

func TestCreateHarvestPlan_MissingCropID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateHarvestPlan(ctx, &domain.HarvestPlan{
		FarmID: "farm-001", FieldID: "field-001",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CROP_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: GetHarvestPlan
// ---------------------------------------------------------------------------

func TestGetHarvestPlan_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.harvestPlans["plan-001"] = &domain.HarvestPlan{
		FarmID: "farm-001",
		CropID: "wheat",
	}
	repo.harvestPlans["plan-001"].TenantID = "tenant-1"
	repo.harvestPlans["plan-001"].UUID = "plan-001"

	plan, err := svc.GetHarvestPlan(ctx, "plan-001")
	require.NoError(t, err)
	assert.Equal(t, "wheat", plan.CropID)
}

func TestGetHarvestPlan_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetHarvestPlan(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestGetHarvestPlan_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetHarvestPlan(ctx, "plan-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetHarvestPlan_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetHarvestPlan(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListHarvestPlans
// ---------------------------------------------------------------------------

func TestListHarvestPlans_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.harvestPlans["hp1"] = &domain.HarvestPlan{FarmID: "farm-001"}
	repo.harvestPlans["hp1"].TenantID = "tenant-1"
	repo.harvestPlans["hp1"].UUID = "hp1"

	plans, total, err := svc.ListHarvestPlans(ctx, domain.ListHarvestPlansParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(1), total)
	assert.Len(t, plans, 1)
}

func TestListHarvestPlans_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListHarvestPlans(ctx, domain.ListHarvestPlansParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetCropPerformance
// ---------------------------------------------------------------------------

func TestGetCropPerformance_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.performances["tenant-1/farm-001/field-001/wheat/kharif/2026"] = &domain.CropPerformance{
		FarmID:                  "farm-001",
		FieldID:                 "field-001",
		CropID:                  "wheat",
		ActualYieldKgPerHectare: 3000.0,
	}

	perf, err := svc.GetCropPerformance(ctx, domain.CropPerformanceParams{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat", Season: "kharif", Year: 2026,
	})
	require.NoError(t, err)
	assert.Equal(t, 3000.0, perf.ActualYieldKgPerHectare)
}

func TestGetCropPerformance_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetCropPerformance(ctx, domain.CropPerformanceParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: CompareYields
// ---------------------------------------------------------------------------

func TestCompareYields_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.performances["tenant-1/farm-001/field-001/wheat/kharif/2025"] = &domain.CropPerformance{
		ActualYieldKgPerHectare: 2800.0,
	}
	repo.performances["tenant-1/farm-001/field-001/wheat/rabi/2026"] = &domain.CropPerformance{
		ActualYieldKgPerHectare: 3200.0,
	}

	perfA, perfB, err := svc.CompareYields(ctx, domain.CompareYieldsParams{
		FarmID: "farm-001", FieldID: "field-001", CropID: "wheat",
		SeasonA: "kharif", YearA: 2025,
		SeasonB: "rabi", YearB: 2026,
	})
	require.NoError(t, err)
	assert.Equal(t, 2800.0, perfA.ActualYieldKgPerHectare)
	assert.Equal(t, 3200.0, perfB.ActualYieldKgPerHectare)
}

func TestCompareYields_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.CompareYields(ctx, domain.CompareYieldsParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: computeConfidence helper
// ---------------------------------------------------------------------------

func TestComputeConfidence_AllZero(t *testing.T) {
	c := computeConfidence(domain.YieldFactors{})
	assert.Equal(t, 0.0, c)
}

func TestComputeConfidence_AllSet(t *testing.T) {
	c := computeConfidence(domain.YieldFactors{
		SoilQualityScore:  80,
		WeatherScore:      70,
		IrrigationScore:   60,
		PestPressureScore: 50,
		NutrientScore:     65,
		ManagementScore:   75,
	})
	// (80+70+60+50+65+75) / 6 = 66.666...
	assert.InDelta(t, 66.67, c, 0.1)
}

// ---------------------------------------------------------------------------
// Tests: clampPageSize helper
// ---------------------------------------------------------------------------

func TestClampPageSize(t *testing.T) {
	assert.Equal(t, defaultPageSize, clampPageSize(0))
	assert.Equal(t, defaultPageSize, clampPageSize(-5))
	assert.Equal(t, int32(50), clampPageSize(50))
	assert.Equal(t, maxPageSize, clampPageSize(200))
}
