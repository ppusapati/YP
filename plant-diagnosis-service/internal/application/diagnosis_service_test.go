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

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/outbound"
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
// Mock: DiagnosisRepository
// ---------------------------------------------------------------------------

type mockDiagnosisRepo struct {
	requests       map[string]*domain.DiagnosisRequest
	results        map[string]*domain.DiagnosisResult // keyed by requestID
	diseases       map[string]*domain.DiseaseInfo
	treatmentPlans map[string]*domain.TreatmentPlan // keyed by diagnosisID
}

func newMockDiagnosisRepo() *mockDiagnosisRepo {
	return &mockDiagnosisRepo{
		requests:       make(map[string]*domain.DiagnosisRequest),
		results:        make(map[string]*domain.DiagnosisResult),
		diseases:       make(map[string]*domain.DiseaseInfo),
		treatmentPlans: make(map[string]*domain.TreatmentPlan),
	}
}

func (m *mockDiagnosisRepo) CreateDiagnosisRequest(_ context.Context, req *domain.DiagnosisRequest) (*domain.DiagnosisRequest, error) {
	req.ID = "diag-req-001"
	m.requests[req.ID] = req
	return req, nil
}

func (m *mockDiagnosisRepo) GetDiagnosisRequestByID(_ context.Context, id, tenantID string) (*domain.DiagnosisRequest, error) {
	r, ok := m.requests[id]
	if !ok || r.TenantID != tenantID {
		return nil, errors.NotFound("DIAGNOSIS_NOT_FOUND", fmt.Sprintf("diagnosis not found: %s", id))
	}
	return r, nil
}

func (m *mockDiagnosisRepo) ListDiagnosisRequests(_ context.Context, params domain.ListDiagnosesParams) ([]domain.DiagnosisRequest, int32, error) {
	var result []domain.DiagnosisRequest
	for _, r := range m.requests {
		if r.TenantID == params.TenantID {
			result = append(result, *r)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockDiagnosisRepo) GetDiagnosisResultByRequestID(_ context.Context, requestID, tenantID string) (*domain.DiagnosisResult, error) {
	r, ok := m.results[requestID]
	if !ok {
		return nil, errors.NotFound("RESULT_NOT_FOUND", "result not found")
	}
	if r.TenantID != tenantID {
		return nil, errors.NotFound("RESULT_NOT_FOUND", "result not found")
	}
	return r, nil
}

func (m *mockDiagnosisRepo) GetDiseaseByID(_ context.Context, id, tenantID string) (*domain.DiseaseInfo, error) {
	d, ok := m.diseases[id]
	if !ok || d.TenantID != tenantID {
		return nil, errors.NotFound("DISEASE_NOT_FOUND", fmt.Sprintf("disease not found: %s", id))
	}
	return d, nil
}

func (m *mockDiagnosisRepo) ListDiseases(_ context.Context, params domain.ListDiseasesParams) ([]domain.DiseaseInfo, int32, error) {
	var result []domain.DiseaseInfo
	for _, d := range m.diseases {
		if d.TenantID == params.TenantID {
			result = append(result, *d)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockDiagnosisRepo) GetTreatmentPlanByDiagnosisID(_ context.Context, diagnosisID, tenantID string) (*domain.TreatmentPlan, error) {
	p, ok := m.treatmentPlans[diagnosisID]
	if !ok {
		return nil, nil // not found returns nil, nil for optional lookup
	}
	if p.TenantID != tenantID {
		return nil, nil
	}
	return p, nil
}

func (m *mockDiagnosisRepo) CreateTreatmentPlan(_ context.Context, plan *domain.TreatmentPlan) (*domain.TreatmentPlan, error) {
	plan.ID = "treatment-plan-001"
	m.treatmentPlans[plan.DiagnosisID] = plan
	return plan, nil
}

func (m *mockDiagnosisRepo) WithTx(_ pgx.Tx) outbound.DiagnosisRepository { return m }

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

func newService() (*mockDiagnosisRepo, *mockEventPublisher, *diagnosisService) {
	repo := newMockDiagnosisRepo()
	pub := &mockEventPublisher{}
	svc := NewDiagnosisService(
		repo, pub,
		&mockFieldClient{existing: map[string]bool{"field-001": true}},
		&mockFarmClient{},
		nil,
		nopLogger{},
		nil, // aiClient
	).(*diagnosisService)
	return repo, pub, svc
}

// ---------------------------------------------------------------------------
// Tests: SubmitDiagnosis
// ---------------------------------------------------------------------------

func TestSubmitDiagnosis_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	req := &domain.DiagnosisRequest{
		FarmID: "farm-001",
	}

	created, err := svc.SubmitDiagnosis(ctx, req)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, domain.DiagnosisStatusPending, created.Status)
	assert.Equal(t, int32(1), created.Version)
	assert.Equal(t, "diag-req-001", created.ID)

	// Event published.
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestSubmitDiagnosis_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.SubmitDiagnosis(ctx, &domain.DiagnosisRequest{FarmID: "farm-001"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestSubmitDiagnosis_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.SubmitDiagnosis(ctx, &domain.DiagnosisRequest{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_FARM_ID", errors.Reason(err))
}

func TestSubmitDiagnosis_DefaultUserID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "")

	created, err := svc.SubmitDiagnosis(ctx, &domain.DiagnosisRequest{FarmID: "farm-001"})
	require.NoError(t, err)
	assert.Equal(t, "system", created.CreatedBy)
}

// ---------------------------------------------------------------------------
// Tests: GetDiagnosis
// ---------------------------------------------------------------------------

func TestGetDiagnosis_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.requests["diag-001"] = &domain.DiagnosisRequest{
		ID:       "diag-001",
		TenantID: "tenant-1",
		FarmID:   "farm-001",
		Status:   domain.DiagnosisStatusCompleted,
	}

	diag, err := svc.GetDiagnosis(ctx, "diag-001")
	require.NoError(t, err)
	assert.Equal(t, "farm-001", diag.FarmID)
	assert.Equal(t, domain.DiagnosisStatusCompleted, diag.Status)
}

func TestGetDiagnosis_WithResult(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.requests["diag-001"] = &domain.DiagnosisRequest{
		ID:       "diag-001",
		TenantID: "tenant-1",
		FarmID:   "farm-001",
	}
	repo.results["diag-001"] = &domain.DiagnosisResult{
		ID:                 "result-001",
		TenantID:           "tenant-1",
		DiagnosisRequestID: "diag-001",
		AIModelVersion:     "v1.0",
	}

	diag, err := svc.GetDiagnosis(ctx, "diag-001")
	require.NoError(t, err)
	require.NotNil(t, diag.Result)
	assert.Equal(t, "v1.0", diag.Result.AIModelVersion)
}

func TestGetDiagnosis_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetDiagnosis(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestGetDiagnosis_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetDiagnosis(ctx, "diag-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestGetDiagnosis_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetDiagnosis(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListDiagnoses
// ---------------------------------------------------------------------------

func TestListDiagnoses_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.requests["d1"] = &domain.DiagnosisRequest{ID: "d1", TenantID: "tenant-1", FarmID: "farm-001"}
	repo.requests["d2"] = &domain.DiagnosisRequest{ID: "d2", TenantID: "tenant-1", FarmID: "farm-001"}

	diagnoses, total, err := svc.ListDiagnoses(ctx, domain.ListDiagnosesParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, diagnoses, 2)
}

func TestListDiagnoses_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListDiagnoses(ctx, domain.ListDiagnosesParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetDiseaseInfo
// ---------------------------------------------------------------------------

func TestGetDiseaseInfo_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.diseases["disease-001"] = &domain.DiseaseInfo{
		ID:          "disease-001",
		TenantID:    "tenant-1",
		DiseaseName: "Late Blight",
	}

	disease, err := svc.GetDiseaseInfo(ctx, "disease-001")
	require.NoError(t, err)
	assert.Equal(t, "Late Blight", disease.DiseaseName)
}

func TestGetDiseaseInfo_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetDiseaseInfo(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestGetDiseaseInfo_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetDiseaseInfo(ctx, "disease-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetDiseaseInfo_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetDiseaseInfo(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListDiseases
// ---------------------------------------------------------------------------

func TestListDiseases_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.diseases["d1"] = &domain.DiseaseInfo{ID: "d1", TenantID: "tenant-1", DiseaseName: "Rust"}
	repo.diseases["d2"] = &domain.DiseaseInfo{ID: "d2", TenantID: "tenant-1", DiseaseName: "Smut"}

	diseases, total, err := svc.ListDiseases(ctx, domain.ListDiseasesParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, diseases, 2)
}

func TestListDiseases_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListDiseases(ctx, domain.ListDiseasesParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetTreatmentPlan
// ---------------------------------------------------------------------------

func TestGetTreatmentPlan_ExistingPlan(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.requests["diag-001"] = &domain.DiagnosisRequest{
		ID:       "diag-001",
		TenantID: "tenant-1",
		FarmID:   "farm-001",
	}
	repo.treatmentPlans["diag-001"] = &domain.TreatmentPlan{
		ID:          "plan-001",
		TenantID:    "tenant-1",
		DiagnosisID: "diag-001",
		Title:       "Existing Plan",
	}

	plan, err := svc.GetTreatmentPlan(ctx, "diag-001")
	require.NoError(t, err)
	assert.Equal(t, "Existing Plan", plan.Title)
}

func TestGetTreatmentPlan_GeneratesSyntheticPlan(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// Diagnosis exists but no treatment plan.
	repo.requests["diag-001"] = &domain.DiagnosisRequest{
		ID:       "diag-001",
		TenantID: "tenant-1",
		FarmID:   "farm-001",
	}

	plan, err := svc.GetTreatmentPlan(ctx, "diag-001")
	require.NoError(t, err)
	assert.Equal(t, "Preliminary Treatment Plan", plan.Title)
	assert.Equal(t, "treatment-plan-001", plan.ID)
	assert.Equal(t, "diag-001", plan.DiagnosisID)
}

func TestGetTreatmentPlan_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetTreatmentPlan(ctx, "diag-001")
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

func TestGetTreatmentPlan_DiagnosisNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetTreatmentPlan(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: IdentifySpecies (synthetic fallback, no AI client)
// ---------------------------------------------------------------------------

func TestIdentifySpecies_SyntheticFallback(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	images := []domain.DiagnosisImage{
		{ImageURL: "https://example.com/leaf.jpg", ImageType: "LEAF"},
	}

	species, err := svc.IdentifySpecies(ctx, images)
	require.NoError(t, err)
	require.Len(t, species, 1)
	assert.Equal(t, "Unknown", species[0].CommonName)
	assert.Equal(t, 0.0, species[0].Confidence)
}

// ---------------------------------------------------------------------------
// Tests: DetectNutrientDeficiency (synthetic fallback, no AI client)
// ---------------------------------------------------------------------------

func TestDetectNutrientDeficiency_SyntheticFallback(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	images := []domain.DiagnosisImage{
		{ImageURL: "https://example.com/leaf.jpg", ImageType: "LEAF"},
	}

	deficiencies, err := svc.DetectNutrientDeficiency(ctx, "species-001", images)
	require.NoError(t, err)
	require.Len(t, deficiencies, 1)
	assert.Equal(t, "Nitrogen", deficiencies[0].Nutrient)
	assert.Equal(t, domain.SeverityModerate, deficiencies[0].Severity)
}

// ---------------------------------------------------------------------------
// Tests: DetectPestDamage (synthetic fallback, no AI client)
// ---------------------------------------------------------------------------

func TestDetectPestDamage_SyntheticFallback(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	images := []domain.DiagnosisImage{
		{ImageURL: "https://example.com/leaf.jpg", ImageType: "LEAF"},
	}

	pests, err := svc.DetectPestDamage(ctx, "species-001", images)
	require.NoError(t, err)
	require.Len(t, pests, 1)
	assert.Equal(t, "Analysis pending", pests[0].PestName)
	assert.Equal(t, domain.SeverityUnspecified, pests[0].DamageLevel)
}
