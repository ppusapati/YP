package services

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	analyticsmodels "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/repositories"
)

// ---------------------------------------------------------------------------
// No-op logger satisfying p9log.Logger
// ---------------------------------------------------------------------------

type nopLogger struct{}

func (nopLogger) Log(_ p9log.Level, _ ...interface{}) error { return nil }

// ---------------------------------------------------------------------------
// Mock: AnalyticsRepository
// ---------------------------------------------------------------------------

type mockAnalyticsRepo struct {
	stressAlerts      map[string]*analyticsmodels.StressAlert          // keyed by UUID
	alertsByJob       map[string][]analyticsmodels.StressAlert         // keyed by processingJobID
	temporalAnalyses  map[string]*analyticsmodels.TemporalAnalysis     // keyed by UUID
	latestAnalysis    map[string]*analyticsmodels.TemporalAnalysis     // keyed by tenantID/farmID/fieldID
	activeAlertCount  map[string]int32                                 // keyed by tenantID/farmID/fieldID
	dominantStress    map[string]*analyticsmodels.StressType           // keyed by tenantID/farmID/fieldID
}

func newMockAnalyticsRepo() *mockAnalyticsRepo {
	return &mockAnalyticsRepo{
		stressAlerts:     make(map[string]*analyticsmodels.StressAlert),
		alertsByJob:      make(map[string][]analyticsmodels.StressAlert),
		temporalAnalyses: make(map[string]*analyticsmodels.TemporalAnalysis),
		latestAnalysis:   make(map[string]*analyticsmodels.TemporalAnalysis),
		activeAlertCount: make(map[string]int32),
		dominantStress:   make(map[string]*analyticsmodels.StressType),
	}
}

func (m *mockAnalyticsRepo) CreateStressAlert(_ context.Context, alert *analyticsmodels.StressAlert) (*analyticsmodels.StressAlert, error) {
	alert.UUID = "alert-uuid-001"
	alert.ID = 1
	alert.IsActive = true
	alert.Acknowledged = false
	alert.CreatedAt = time.Now()
	m.stressAlerts[alert.UUID] = alert
	return alert, nil
}

func (m *mockAnalyticsRepo) GetStressAlertByUUID(_ context.Context, uuid, tenantID string) (*analyticsmodels.StressAlert, error) {
	a, ok := m.stressAlerts[uuid]
	if !ok || a.TenantID != tenantID {
		return nil, errors.NotFound("STRESS_ALERT_NOT_FOUND", fmt.Sprintf("stress alert not found: %s", uuid))
	}
	return a, nil
}

func (m *mockAnalyticsRepo) ListStressAlerts(_ context.Context, params analyticsmodels.ListStressAlertsParams) ([]analyticsmodels.StressAlert, int32, error) {
	var result []analyticsmodels.StressAlert
	for _, a := range m.stressAlerts {
		if a.TenantID == params.TenantID {
			result = append(result, *a)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockAnalyticsRepo) AcknowledgeStressAlert(_ context.Context, uuid, tenantID, acknowledgedBy string) error {
	a, ok := m.stressAlerts[uuid]
	if !ok || a.TenantID != tenantID {
		return errors.NotFound("STRESS_ALERT_NOT_FOUND", fmt.Sprintf("stress alert not found: %s", uuid))
	}
	a.Acknowledged = true
	ab := acknowledgedBy
	a.AcknowledgedBy = &ab
	now := time.Now()
	a.AcknowledgedAt = &now
	return nil
}

func (m *mockAnalyticsRepo) ListStressAlertsByProcessingJob(_ context.Context, processingJobID, _ string) ([]analyticsmodels.StressAlert, error) {
	alerts, ok := m.alertsByJob[processingJobID]
	if !ok {
		return []analyticsmodels.StressAlert{}, nil
	}
	return alerts, nil
}

func (m *mockAnalyticsRepo) CountActiveStressAlerts(_ context.Context, tenantID, farmID, fieldID string) (int32, error) {
	key := tenantID + "/" + farmID + "/" + fieldID
	return m.activeAlertCount[key], nil
}

func (m *mockAnalyticsRepo) GetDominantStressType(_ context.Context, tenantID, farmID, fieldID string) (*analyticsmodels.StressType, error) {
	key := tenantID + "/" + farmID + "/" + fieldID
	return m.dominantStress[key], nil
}

func (m *mockAnalyticsRepo) CreateTemporalAnalysis(_ context.Context, analysis *analyticsmodels.TemporalAnalysis) (*analyticsmodels.TemporalAnalysis, error) {
	analysis.UUID = "analysis-uuid-001"
	analysis.ID = 1
	analysis.IsActive = true
	analysis.CreatedAt = time.Now()
	m.temporalAnalyses[analysis.UUID] = analysis
	return analysis, nil
}

func (m *mockAnalyticsRepo) GetTemporalAnalysisByUUID(_ context.Context, uuid, tenantID string) (*analyticsmodels.TemporalAnalysis, error) {
	a, ok := m.temporalAnalyses[uuid]
	if !ok || a.TenantID != tenantID {
		return nil, errors.NotFound("TEMPORAL_ANALYSIS_NOT_FOUND", fmt.Sprintf("temporal analysis not found: %s", uuid))
	}
	return a, nil
}

func (m *mockAnalyticsRepo) GetLatestTemporalAnalysis(_ context.Context, tenantID, farmID, fieldID string) (*analyticsmodels.TemporalAnalysis, error) {
	key := tenantID + "/" + farmID + "/" + fieldID
	return m.latestAnalysis[key], nil
}

func (m *mockAnalyticsRepo) WithTx(_ pgx.Tx) repositories.AnalyticsRepository { return m }

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

func newTestService() (*mockAnalyticsRepo, AnalyticsService) {
	repo := newMockAnalyticsRepo()
	d := deps.ServiceDeps{
		Log: nopLogger{},
	}
	svc := NewAnalyticsService(d, repo, nil)
	return repo, svc
}

// ---------------------------------------------------------------------------
// Tests: DetectStress
// ---------------------------------------------------------------------------

func TestDetectStress_HappyPath(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	require.Len(t, alerts, 1)
	assert.Equal(t, "tenant-1", alerts[0].TenantID)
	assert.Equal(t, "farm-001", alerts[0].FarmID)
	assert.Equal(t, "field-001", alerts[0].FieldID)
	assert.Equal(t, analyticsmodels.StressTypeWater, alerts[0].StressType)
	assert.Equal(t, analyticsmodels.SeverityLevelMedium, alerts[0].Severity)
	assert.Equal(t, "user-1", alerts[0].CreatedBy)
}

func TestDetectStress_ReturnsExistingAlerts(t *testing.T) {
	repo, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	// Pre-populate existing alerts for this processing job.
	existingAlert := analyticsmodels.StressAlert{
		TenantID:   "tenant-1",
		FarmID:     "farm-001",
		FieldID:    "field-001",
		StressType: analyticsmodels.StressTypeNutrient,
		Severity:   analyticsmodels.SeverityLevelHigh,
	}
	existingAlert.UUID = "existing-alert-001"
	repo.alertsByJob["job-001"] = []analyticsmodels.StressAlert{existingAlert}

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	require.Len(t, alerts, 1)
	assert.Equal(t, "existing-alert-001", alerts[0].UUID)
	assert.Equal(t, analyticsmodels.StressTypeNutrient, alerts[0].StressType)
}

func TestDetectStress_MissingTenant(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("", "user-1")

	_, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestDetectStress_MissingFarmID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.DetectStress(ctx, "", "field-001", "job-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

func TestDetectStress_MissingFieldID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.DetectStress(ctx, "farm-001", "", "job-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FIELD_ID", errors.Reason(err))
}

func TestDetectStress_MissingProcessingJobID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.DetectStress(ctx, "farm-001", "field-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_PROCESSING_JOB_ID", errors.Reason(err))
}

func TestDetectStress_DefaultUserID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "")

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	require.Len(t, alerts, 1)
	assert.Equal(t, "system", alerts[0].CreatedBy)
}

// ---------------------------------------------------------------------------
// Tests: ListStressAlerts
// ---------------------------------------------------------------------------

func TestListStressAlerts_HappyPath(t *testing.T) {
	repo, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	repo.stressAlerts["a1"] = &analyticsmodels.StressAlert{
		TenantID:   "tenant-1",
		StressType: analyticsmodels.StressTypeWater,
	}
	repo.stressAlerts["a1"].UUID = "a1"

	alerts, total, err := svc.ListStressAlerts(ctx, analyticsmodels.ListStressAlertsParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(1), total)
	assert.Len(t, alerts, 1)
}

func TestListStressAlerts_MissingTenant(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListStressAlerts(ctx, analyticsmodels.ListStressAlertsParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: AcknowledgeAlert
// ---------------------------------------------------------------------------

func TestAcknowledgeAlert_HappyPath(t *testing.T) {
	repo, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	repo.stressAlerts["alert-001"] = &analyticsmodels.StressAlert{
		TenantID:     "tenant-1",
		Acknowledged: false,
	}
	repo.stressAlerts["alert-001"].UUID = "alert-001"

	err := svc.AcknowledgeAlert(ctx, "alert-001")
	require.NoError(t, err)
	assert.True(t, repo.stressAlerts["alert-001"].Acknowledged)
}

func TestAcknowledgeAlert_MissingTenant(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("", "user-1")

	err := svc.AcknowledgeAlert(ctx, "alert-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestAcknowledgeAlert_MissingAlertID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.AcknowledgeAlert(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ALERT_ID", errors.Reason(err))
}

func TestAcknowledgeAlert_NotFound(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.AcknowledgeAlert(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestAcknowledgeAlert_AlreadyAcknowledged(t *testing.T) {
	repo, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	repo.stressAlerts["alert-001"] = &analyticsmodels.StressAlert{
		TenantID:     "tenant-1",
		Acknowledged: true,
	}
	repo.stressAlerts["alert-001"].UUID = "alert-001"

	err := svc.AcknowledgeAlert(ctx, "alert-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "ALREADY_ACKNOWLEDGED", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: RunTemporalAnalysis
// ---------------------------------------------------------------------------

func TestRunTemporalAnalysis_HappyPath(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	start := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	end := time.Date(2026, 6, 1, 0, 0, 0, 0, time.UTC)

	analysis, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, start, end)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", analysis.TenantID)
	assert.Equal(t, "farm-001", analysis.FarmID)
	assert.Equal(t, "field-001", analysis.FieldID)
	assert.Equal(t, analyticsmodels.AnalysisTypeTemporalTrend, analysis.AnalysisType)
	assert.Equal(t, "NDVI", analysis.MetricName)
	assert.Equal(t, "user-1", analysis.CreatedBy)
	assert.Equal(t, "analysis-uuid-001", analysis.UUID)
}

func TestRunTemporalAnalysis_MissingTenant(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, time.Now(), time.Now().Add(24*time.Hour))
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestRunTemporalAnalysis_MissingFarmID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, time.Now(), time.Now().Add(24*time.Hour))
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

func TestRunTemporalAnalysis_MissingFieldID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "",
		analyticsmodels.AnalysisTypeTemporalTrend, time.Now(), time.Now().Add(24*time.Hour))
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FIELD_ID", errors.Reason(err))
}

func TestRunTemporalAnalysis_InvalidAnalysisType(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisType("INVALID"), time.Now(), time.Now().Add(24*time.Hour))
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_ANALYSIS_TYPE", errors.Reason(err))
}

func TestRunTemporalAnalysis_ZeroPeriod(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, time.Time{}, time.Time{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_PERIOD", errors.Reason(err))
}

func TestRunTemporalAnalysis_EndBeforeStart(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	end := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	start := time.Date(2026, 6, 1, 0, 0, 0, 0, time.UTC)

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, start, end)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_PERIOD", errors.Reason(err))
}

func TestRunTemporalAnalysis_StressDetectionMetric(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	start := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	end := time.Date(2026, 6, 1, 0, 0, 0, 0, time.UTC)

	analysis, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeStressDetection, start, end)
	require.NoError(t, err)
	assert.Equal(t, "stress_index", analysis.MetricName)
}

// ---------------------------------------------------------------------------
// Tests: GetFieldAnalyticsSummary
// ---------------------------------------------------------------------------

func TestGetFieldAnalyticsSummary_HappyPath(t *testing.T) {
	repo, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	key := "tenant-1/farm-001/field-001"
	repo.activeAlertCount[key] = 2
	waterStress := analyticsmodels.StressTypeWater
	repo.dominantStress[key] = &waterStress
	repo.latestAnalysis[key] = &analyticsmodels.TemporalAnalysis{
		TrendSlope: 0.03,
	}
	repo.latestAnalysis[key].CreatedAt = time.Now()

	summary, err := svc.GetFieldAnalyticsSummary(ctx, "farm-001", "field-001")
	require.NoError(t, err)
	assert.Equal(t, int32(2), summary.ActiveStressAlerts)
	assert.Equal(t, "WATER", summary.DominantStressType)
	assert.Equal(t, 0.03, summary.NdviTrend)
	assert.NotNil(t, summary.LastAnalysis)
	// Health: 100 - 20 (2 alerts * 10) + 5 (positive trend > 0.02) = 85
	assert.Equal(t, 85.0, summary.HealthScore)
}

func TestGetFieldAnalyticsSummary_NoAlerts(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	summary, err := svc.GetFieldAnalyticsSummary(ctx, "farm-001", "field-001")
	require.NoError(t, err)
	assert.Equal(t, int32(0), summary.ActiveStressAlerts)
	assert.Equal(t, 100.0, summary.HealthScore)
	assert.Empty(t, summary.DominantStressType)
	assert.Nil(t, summary.LastAnalysis)
}

func TestGetFieldAnalyticsSummary_MissingTenant(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("", "user-1")

	_, err := svc.GetFieldAnalyticsSummary(ctx, "farm-001", "field-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestGetFieldAnalyticsSummary_MissingFarmID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetFieldAnalyticsSummary(ctx, "", "field-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FARM_ID", errors.Reason(err))
}

func TestGetFieldAnalyticsSummary_MissingFieldID(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetFieldAnalyticsSummary(ctx, "farm-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_FIELD_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: computeHealthScore helper
// ---------------------------------------------------------------------------

func TestComputeHealthScore_NoAlertsPositiveTrend(t *testing.T) {
	score := computeHealthScore(0, 0.03)
	assert.Equal(t, 100.0, score) // 100 + 5 = 105, clamped to 100
}

func TestComputeHealthScore_ManyAlertsNegativeTrend(t *testing.T) {
	score := computeHealthScore(5, -0.06)
	// 100 - 40 (capped penalty) - 30 (strong negative) = 30
	assert.Equal(t, 30.0, score)
}

func TestComputeHealthScore_ClampedToZero(t *testing.T) {
	// 100 - 40 (10 alerts, capped at 40) - 30 (strong negative trend) = 30
	score := computeHealthScore(10, -0.1)
	assert.Equal(t, 30.0, score)
}

func TestComputeHealthScore_MildNegativeTrend(t *testing.T) {
	// 100 - 10 (1 alert) - 5 (mild negative -0.01) = 85
	score := computeHealthScore(1, -0.01)
	assert.Equal(t, 85.0, score)
}

func TestComputeHealthScore_ModerateNegativeTrend(t *testing.T) {
	// 100 - 30 (3 alerts) - 15 (moderate negative -0.03) = 55
	score := computeHealthScore(3, -0.03)
	assert.Equal(t, 55.0, score)
}
