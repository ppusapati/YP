package services

import (
	"context"
	"fmt"
	"math"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	"p9e.in/samavaya/packages/deps"
	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/saas"

	analyticsmodels "p9e.in/samavaya/agriculture/satellite-analytics-service/internal/models"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/repositories"
	"p9e.in/samavaya/agriculture/satellite-analytics-service/internal/timeseries"
)

// ---------------------------------------------------------------------------
// Mock: AnalyticsRepository
// ---------------------------------------------------------------------------

type mockAnalyticsRepo struct {
	stressAlerts     map[string]*analyticsmodels.StressAlert      // keyed by UUID
	alertsByJob      map[string][]analyticsmodels.StressAlert     // keyed by processingJobID
	temporalAnalyses map[string]*analyticsmodels.TemporalAnalysis // keyed by UUID
	latestAnalysis   map[string]*analyticsmodels.TemporalAnalysis // keyed by tenantID/farmID/fieldID
	activeAlertCount map[string]int32                             // keyed by tenantID/farmID/fieldID
	dominantStress   map[string]*analyticsmodels.StressType       // keyed by tenantID/farmID/fieldID
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
	alert.ID = "alert-uuid-001"
	alert.IsActive = true
	alert.Acknowledged = false
	alert.CreatedAt = time.Now()
	m.stressAlerts[alert.ID] = alert
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
	analysis.ID = "analysis-uuid-001"
	analysis.IsActive = true
	analysis.CreatedAt = time.Now()
	m.temporalAnalyses[analysis.ID] = analysis
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

// fakeVegClient serves a canned NDVI series for temporal analysis tests.
type fakeVegClient struct {
	samples []timeseries.Sample
	err     error
	calls   int
}

func (f *fakeVegClient) GetNDVITimeSeries(_ context.Context, _, _ string, from, to time.Time) ([]timeseries.Sample, error) {
	f.calls++
	if f.err != nil {
		return nil, f.err
	}
	var out []timeseries.Sample
	for _, s := range f.samples {
		if !s.Date.Before(from) && !s.Date.After(to) {
			out = append(out, s)
		}
	}
	return out, nil
}

// seasonSeries returns a bell-shaped NDVI season (peak ≈ day 90) sampled every 5 days.
func seasonSeries(start time.Time, days int) []timeseries.Sample {
	var out []timeseries.Sample
	for d := 0; d <= days; d += 5 {
		v := 0.2 + 0.6*math.Exp(-math.Pow(float64(d-90)/30, 2))
		out = append(out, timeseries.Sample{Date: start.AddDate(0, 0, d), Value: v, Sensor: "SENTINEL2"})
	}
	return out
}

var testPeriodStart = time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)

// errVegUnavailable stands in for the index service being down.
var errVegUnavailable = fmt.Errorf("vegetation index service unavailable")

func newTestService() (*mockAnalyticsRepo, AnalyticsService) {
	repo, svc, _ := newTestServiceWithVeg(&fakeVegClient{samples: seasonSeries(testPeriodStart, 180)})
	return repo, svc
}

func newTestServiceWithVeg(veg *fakeVegClient) (*mockAnalyticsRepo, AnalyticsService, *fakeVegClient) {
	repo := newMockAnalyticsRepo()
	d := deps.ServiceDeps{
		Log: p9log.NewLogger(zap.NewNop()),
	}
	svc := NewAnalyticsService(d, repo, nil, veg)
	return repo, svc, veg
}

// ---------------------------------------------------------------------------
// Tests: DetectStress
// ---------------------------------------------------------------------------

// droppingSeries returns a healthy NDVI plateau that falls away at the end,
// ending `drop` below its own baseline. This is what stress looks like in a
// time series: not a low absolute value, but a fall from what this field was
// doing a fortnight ago.
func droppingSeries(end time.Time, n int, baseline, drop float64) []timeseries.Sample {
	out := make([]timeseries.Sample, 0, n)
	for i := 0; i < n; i++ {
		v := baseline
		// The last three scenes fall, so the smoothing window sees the decline
		// rather than averaging one bad reading away.
		if i >= n-3 {
			v = baseline - drop*float64(i-(n-4))/3
		}
		out = append(out, timeseries.Sample{
			Date:   end.AddDate(0, 0, -5*(n-1-i)),
			Value:  v,
			Sensor: "SENTINEL2",
		})
	}
	return out
}

func TestDetectStress_RaisesAnAlertWhenNDVIFallsBelowItsBaseline(t *testing.T) {
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{
		samples: droppingSeries(time.Now().UTC(), 10, 0.72, 0.30),
	})
	ctx := testContext("tenant-1", "user-1")

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	require.Len(t, alerts, 1)
	assert.Equal(t, "tenant-1", alerts[0].TenantID)
	assert.Equal(t, "farm-001", alerts[0].FarmID)
	assert.Equal(t, "field-001", alerts[0].FieldID)
	assert.Equal(t, "user-1", alerts[0].CreatedBy)

	// The type stays unspecified on purpose. NDVI falling says the canopy is
	// losing vigour; it does not say whether that is drought, disease or pest
	// damage, and naming one would be inventing an explanation.
	assert.Equal(t, analyticsmodels.StressTypeUnspecified, alerts[0].StressType)

	// A large drop should not come back as the mildest band.
	assert.NotEqual(t, analyticsmodels.SeverityLevelLow, alerts[0].Severity)

	// Confidence is capped below certainty: one index over ten scenes does not
	// justify more.
	assert.Greater(t, alerts[0].Confidence, 0.0)
	assert.LessOrEqual(t, alerts[0].Confidence, 0.90)

	// Area is not guessed. The field's extent is not known here, and the code
	// this replaced reported a literal 2.5 hectares for every field.
	assert.Zero(t, alerts[0].AffectedAreaHectares)
}

func TestDetectStress_SaysNothingAboutAHealthyField(t *testing.T) {
	// The defect this replaced: with no usable observation, the service wrote
	// a hardcoded "water stress detected in the northern section based on NDWI
	// analysis" at 0.85 confidence, persisted it, and emitted a domain event.
	repo, svc, _ := newTestServiceWithVeg(&fakeVegClient{
		samples: droppingSeries(time.Now().UTC(), 10, 0.72, 0.0),
	})
	ctx := testContext("tenant-1", "user-1")

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	assert.Empty(t, alerts, "a steady field should produce no alert")
	assert.Empty(t, repo.stressAlerts, "nothing should have been persisted")
}

func TestDetectStress_SaysNothingWithoutEnoughHistory(t *testing.T) {
	// Two scenes make a baseline that one cloudy pass could drag far enough to
	// alert on a healthy field. "We cannot tell yet" is the honest answer.
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{
		samples: droppingSeries(time.Now().UTC(), 3, 0.72, 0.40),
	})
	ctx := testContext("tenant-1", "user-1")

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	assert.Empty(t, alerts)
}

func TestDetectStress_SaysNothingWithoutAVegetationClient(t *testing.T) {
	repo := newMockAnalyticsRepo()
	svc := NewAnalyticsService(deps.ServiceDeps{Log: p9log.NewLogger(zap.NewNop())}, repo, nil, nil)
	ctx := testContext("tenant-1", "user-1")

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	assert.Empty(t, alerts, "no source of observations means no alert, not a guess")
}

func TestDetectStress_ReportsAnUnavailableDependencyAsAnError(t *testing.T) {
	// Reporting "no stress" when the index service is down is indistinguishable
	// from a healthy field, which is the worse failure of the two.
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{err: errVegUnavailable})
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.Error(t, err)
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
	existingAlert.ID = "existing-alert-001"
	repo.alertsByJob["job-001"] = []analyticsmodels.StressAlert{existingAlert}

	alerts, err := svc.DetectStress(ctx, "farm-001", "field-001", "job-001")
	require.NoError(t, err)
	require.Len(t, alerts, 1)
	assert.Equal(t, "existing-alert-001", alerts[0].ID)
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
	// Detection runs from a processing job, which has no user behind it, so an
	// alert has to be attributable to something.
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{
		samples: droppingSeries(time.Now().UTC(), 10, 0.72, 0.30),
	})
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
	repo.stressAlerts["a1"].ID = "a1"

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
	repo.stressAlerts["alert-001"].ID = "alert-001"

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
	repo.stressAlerts["alert-001"].ID = "alert-001"

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
	assert.Equal(t, "analysis-uuid-001", analysis.ID)
	// 151-day period over a 5-day cadence yields 31 observations.
	assert.Equal(t, 31, analysis.Details["observations"])
	assert.Contains(t, analysis.Details, "trend_direction")
	assert.InDelta(t, 0.2, analysis.CurrentValue, 0.05, "series ends back near baseline")
}

func TestRunTemporalAnalysis_TrendOnRisingSeries(t *testing.T) {
	var rising []timeseries.Sample
	for d := 0; d <= 60; d += 5 {
		rising = append(rising, timeseries.Sample{Date: testPeriodStart.AddDate(0, 0, d), Value: 0.3 + 0.005*float64(d)})
	}
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{samples: rising})
	ctx := testContext("tenant-1", "user-1")

	a, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, testPeriodStart, testPeriodStart.AddDate(0, 0, 60))
	require.NoError(t, err)
	assert.InDelta(t, 0.005, a.TrendSlope, 1e-9)
	assert.InDelta(t, 1.0, a.TrendRSquared, 1e-6)
	assert.InDelta(t, 0.3, a.BaselineValue, 1e-9)
	assert.InDelta(t, 0.6, a.CurrentValue, 1e-9)
	assert.InDelta(t, 100, a.DeviationPercent, 1e-6)
	assert.Equal(t, "increasing", a.Details["trend_direction"])
}

func TestRunTemporalAnalysis_ChangeDetection(t *testing.T) {
	var series []timeseries.Sample
	for d := 0; d < 60; d += 5 {
		v := 0.7
		if d >= 30 {
			v = 0.4
		}
		series = append(series, timeseries.Sample{Date: testPeriodStart.AddDate(0, 0, d), Value: v + 0.01*float64(d%2)})
	}
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{samples: series})
	ctx := testContext("tenant-1", "user-1")

	a, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeChangeDetection, testPeriodStart, testPeriodStart.AddDate(0, 0, 60))
	require.NoError(t, err)
	assert.Equal(t, "change_magnitude", a.MetricName)
	assert.InDelta(t, 0.7, a.BaselineValue, 0.02)
	assert.InDelta(t, 0.4, a.CurrentValue, 0.02)
	assert.Less(t, a.DeviationPercent, -35.0)
	assert.Equal(t, true, a.Details["significant"])
	assert.Less(t, a.Details["z_score"].(float64), -5.0)
}

func TestRunTemporalAnalysis_AnomalyDetection(t *testing.T) {
	series := seasonSeries(testPeriodStart, 180)
	series[10].Value = 0.05
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{samples: series})
	ctx := testContext("tenant-1", "user-1")

	a, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeAnomalyDetection, testPeriodStart, testPeriodStart.AddDate(0, 0, 180))
	require.NoError(t, err)
	assert.Equal(t, "anomaly_score", a.MetricName)
	assert.Equal(t, 1, a.Details["anomaly_count"])
	assert.Greater(t, a.Details["max_abs_z"].(float64), 3.0)
	anomalies := a.Details["anomalies"].([]interface{})
	require.Len(t, anomalies, 1)
	assert.Equal(t, series[10].Date.Format(time.RFC3339), anomalies[0].(map[string]interface{})["date"])
}

func TestRunTemporalAnalysis_Phenology(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	a, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypePhenology, testPeriodStart, testPeriodStart.AddDate(0, 0, 180))
	require.NoError(t, err)
	assert.Equal(t, "phenology", a.MetricName)
	assert.Equal(t, true, a.Details["detected"])
	assert.InDelta(t, 0.8, a.CurrentValue, 0.05)
	assert.InDelta(t, 0.2, a.BaselineValue, 0.05)
	peak, err := time.Parse(time.RFC3339, a.Details["peak_date"].(string))
	require.NoError(t, err)
	assert.InDelta(t, 90, peak.Sub(testPeriodStart).Hours()/24, 5)
	assert.Contains(t, a.Details, "season_start")
	assert.Contains(t, a.Details, "season_end")
}

func TestRunTemporalAnalysis_StressDetection(t *testing.T) {
	series := []timeseries.Sample{
		{Date: testPeriodStart, Value: 0.25},
		{Date: testPeriodStart.AddDate(0, 0, 5), Value: 0.28},
		{Date: testPeriodStart.AddDate(0, 0, 10), Value: 0.5},
		{Date: testPeriodStart.AddDate(0, 0, 15), Value: 0.6},
	}
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{samples: series})
	ctx := testContext("tenant-1", "user-1")

	a, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeStressDetection, testPeriodStart, testPeriodStart.AddDate(0, 0, 15))
	require.NoError(t, err)
	assert.Equal(t, "stress_index", a.MetricName)
	assert.InDelta(t, 0.5, a.CurrentValue, 1e-9)
	assert.InDelta(t, 0.6, a.Details["latest_ndvi"], 1e-9)
}

func TestRunTemporalAnalysis_InsufficientData(t *testing.T) {
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{samples: seasonSeries(testPeriodStart, 5)})
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, testPeriodStart, testPeriodStart.AddDate(0, 0, 5))
	require.Error(t, err)
	assert.Equal(t, "INSUFFICIENT_DATA", errors.Reason(err))
}

func TestRunTemporalAnalysis_VegClientFailure(t *testing.T) {
	_, svc, _ := newTestServiceWithVeg(&fakeVegClient{err: fmt.Errorf("upstream down")})
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeTemporalTrend, testPeriodStart, testPeriodStart.AddDate(0, 0, 60))
	require.Error(t, err)
	assert.Equal(t, "TIME_SERIES_FETCH_FAILED", errors.Reason(err))
}

func TestRunTemporalAnalysis_CropClassificationUnsupported(t *testing.T) {
	_, svc := newTestService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.RunTemporalAnalysis(ctx, "farm-001", "field-001",
		analyticsmodels.AnalysisTypeCropClassification, testPeriodStart, testPeriodStart.AddDate(0, 0, 60))
	require.Error(t, err)
	assert.Equal(t, "UNSUPPORTED_ANALYSIS_TYPE", errors.Reason(err))
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
