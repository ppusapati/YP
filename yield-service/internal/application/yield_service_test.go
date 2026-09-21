package application

import (
	"context"
	"fmt"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"
	"p9e.in/samavaya/packages/testutil"

	"p9e.in/samavaya/agriculture/yield-service/internal/domain"
	"p9e.in/samavaya/agriculture/yield-service/internal/ports/outbound"
)

// nopLogger aliases the shared test logger. Each service package used to
// define its own, and all of them broke at once when p9log.Logger gained
// Debug/Info/Warn/Error — silently, because a _test.go file that does not
// compile is a test suite that does not run.
type nopLogger = testutil.NopLogger

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
	p.ID = "prediction-uuid-001"
	// The column defaults to TRUE, so a freshly inserted row is active
	// whether or not the caller said so.
	p.IsActive = true
	m.predictions[p.ID] = p
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
		// Mirrors the real query, which filters `deleted_at IS NULL AND
		// is_active = TRUE`. Without the is_active term the mock would hide
		// the difference between archiving a forecast and doing nothing.
		if p.TenantID == params.TenantID && p.IsActive && p.DeletedAt == nil {
			result = append(result, *p)
		}
	}
	return result, int32(len(result)), nil
}

// ArchiveFieldForecasts marks a field's forecasts inactive without deleting
// them, and leaves yield records alone — the distinction the real repository
// draws, and the reason the crop-performance join keeps working.
func (m *mockYieldRepo) ArchiveFieldForecasts(_ context.Context, fieldID, tenantID string) (int64, error) {
	var n int64
	for _, p := range m.predictions {
		if p.TenantID == tenantID && p.FieldID == fieldID && p.IsActive {
			p.IsActive = false
			n++
		}
	}
	for _, p := range m.harvestPlans {
		if p.TenantID == tenantID && p.FieldID == fieldID && p.IsActive {
			p.IsActive = false
			n++
		}
	}
	return n, nil
}

func (m *mockYieldRepo) CreateYieldRecord(_ context.Context, r *domain.YieldRecord) (*domain.YieldRecord, error) {
	r.ID = "record-uuid-001"
	m.yieldRecords[r.ID] = r
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
	p.ID = "plan-uuid-001"
	p.IsActive = true
	m.harvestPlans[p.ID] = p
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
		if p.TenantID == params.TenantID && p.IsActive && p.DeletedAt == nil {
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
		p9log.NewLogger(zap.NewNop()),
		nil,
	)
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
	assert.Equal(t, "prediction-uuid-001", created.ID)

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
	repo.predictions["pred-001"].ID = "pred-001"

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

	// IsActive is promoted from BaseModel and defaults to TRUE in the column;
	// the listings filter on it, so a fixture without it is not a real row.
	repo.predictions["p1"] = &domain.YieldPrediction{FarmID: "farm-001"}
	repo.predictions["p1"].TenantID = "tenant-1"
	repo.predictions["p1"].ID = "p1"
	repo.predictions["p1"].IsActive = true
	repo.predictions["p2"] = &domain.YieldPrediction{FarmID: "farm-001"}
	repo.predictions["p2"].TenantID = "tenant-1"
	repo.predictions["p2"].ID = "p2"
	repo.predictions["p2"].IsActive = true

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
	assert.Equal(t, "record-uuid-001", created.ID)

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
	repo.yieldRecords["r1"].ID = "r1"

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
	assert.Equal(t, "plan-uuid-001", created.ID)

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
	repo.harvestPlans["plan-001"].ID = "plan-001"

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
	repo.harvestPlans["hp1"].ID = "hp1"
	repo.harvestPlans["hp1"].IsActive = true

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

// ---------------------------------------------------------------------------
// Tests: ArchiveFieldForecasts
// ---------------------------------------------------------------------------

// Archiving takes a deleted field's forecasts out of the listings.
func TestArchiveFieldForecasts_HidesForecasts(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["p1"] = &domain.YieldPrediction{FarmID: "farm-001", FieldID: "field-001"}
	repo.predictions["p1"].TenantID = "tenant-1"
	repo.predictions["p1"].ID = "p1"
	repo.predictions["p1"].IsActive = true

	repo.harvestPlans["hp1"] = &domain.HarvestPlan{FarmID: "farm-001", FieldID: "field-001"}
	repo.harvestPlans["hp1"].TenantID = "tenant-1"
	repo.harvestPlans["hp1"].ID = "hp1"
	repo.harvestPlans["hp1"].IsActive = true

	archived, err := svc.ArchiveFieldForecasts(ctx, "field-001")
	require.NoError(t, err)
	assert.Equal(t, int64(2), archived)

	_, predTotal, err := svc.ListPredictions(ctx, domain.ListPredictionsParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(0), predTotal, "an archived prediction is still listed")

	_, planTotal, err := svc.ListHarvestPlans(ctx, domain.ListHarvestPlansParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(0), planTotal, "an archived harvest plan is still listed")
}

// The forecast is archived, not deleted, and that is not cosmetic.
//
// GetCropPerformance joins a yield record to its prediction on
// `yp.deleted_at IS NULL`, wrapped in COALESCE(..., 0). Soft-deleting the
// prediction would drop that join and render a real forecast as a predicted
// yield of zero, so a harvest that beat its forecast would show as
// "predicted 0, actual 4200" — the model made to look as though it had
// forecast nothing.
func TestArchiveFieldForecasts_DoesNotSoftDelete(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["p1"] = &domain.YieldPrediction{FarmID: "farm-001", FieldID: "field-001"}
	repo.predictions["p1"].TenantID = "tenant-1"
	repo.predictions["p1"].ID = "p1"
	repo.predictions["p1"].IsActive = true

	_, err := svc.ArchiveFieldForecasts(ctx, "field-001")
	require.NoError(t, err)

	require.NotNil(t, repo.predictions["p1"], "the row was removed rather than archived")
	assert.Nil(t, repo.predictions["p1"].DeletedAt,
		"archiving set deleted_at, which drops the crop-performance join and "+
			"turns a real forecast into a predicted yield of zero")
}

// Yield records are never archived. A record is what was actually cut off that
// ground; it happened whether or not the field record survives, and it is what
// a traceability or subsidy audit asks for later.
func TestArchiveFieldForecasts_LeavesYieldRecordsAlone(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.yieldRecords["r1"] = &domain.YieldRecord{FarmID: "farm-001", FieldID: "field-001"}
	repo.yieldRecords["r1"].TenantID = "tenant-1"
	repo.yieldRecords["r1"].ID = "r1"
	repo.yieldRecords["r1"].IsActive = true

	archived, err := svc.ArchiveFieldForecasts(ctx, "field-001")
	require.NoError(t, err)
	assert.Equal(t, int64(0), archived, "a yield record was counted as a forecast")
	assert.True(t, repo.yieldRecords["r1"].IsActive,
		"the harvest that actually happened was archived along with the forecasts")
}

// Another field's forecasts are untouched.
func TestArchiveFieldForecasts_LeavesOtherFieldsAlone(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["p2"] = &domain.YieldPrediction{FarmID: "farm-001", FieldID: "field-002"}
	repo.predictions["p2"].TenantID = "tenant-1"
	repo.predictions["p2"].ID = "p2"
	repo.predictions["p2"].IsActive = true

	archived, err := svc.ArchiveFieldForecasts(ctx, "field-001")
	require.NoError(t, err)
	assert.Equal(t, int64(0), archived)
	assert.True(t, repo.predictions["p2"].IsActive, "a different field's forecast was archived")
}

// Replaying the cascade finds nothing left and says so rather than failing.
func TestArchiveFieldForecasts_IsIdempotent(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.predictions["p1"] = &domain.YieldPrediction{FarmID: "farm-001", FieldID: "field-001"}
	repo.predictions["p1"].TenantID = "tenant-1"
	repo.predictions["p1"].ID = "p1"
	repo.predictions["p1"].IsActive = true

	first, err := svc.ArchiveFieldForecasts(ctx, "field-001")
	require.NoError(t, err)
	assert.Equal(t, int64(1), first)

	second, err := svc.ArchiveFieldForecasts(ctx, "field-001")
	require.NoError(t, err)
	assert.Equal(t, int64(0), second, "a replay archived the same rows again")
}

// Without a tenant there is nothing to scope the archive to, and guessing one
// would archive another tenant's forecasts.
func TestArchiveFieldForecasts_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.ArchiveFieldForecasts(ctx, "field-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}
