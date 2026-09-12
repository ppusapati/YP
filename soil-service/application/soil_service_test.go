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

	"p9e.in/samavaya/agriculture/soil-service/internal/domain"
	"p9e.in/samavaya/agriculture/soil-service/internal/ports/outbound"
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
// Mock: SoilRepository
// ---------------------------------------------------------------------------

type mockSoilRepo struct {
	soils        map[string]*domain.Soil
	names        map[string]bool // tenantID+"/"+name -> exists
	samples      map[string]*domain.SoilSample
	analyses     map[string]*domain.SoilAnalysis
	soilMaps     map[string]*domain.SoilMap // keyed by fieldID+"/"+mapType
	nutrients    map[string][]domain.SoilNutrient
	healthScores map[string]*domain.SoilHealthScore // keyed by fieldID
}

func newMockSoilRepo() *mockSoilRepo {
	return &mockSoilRepo{
		soils:        make(map[string]*domain.Soil),
		names:        make(map[string]bool),
		samples:      make(map[string]*domain.SoilSample),
		analyses:     make(map[string]*domain.SoilAnalysis),
		soilMaps:     make(map[string]*domain.SoilMap),
		nutrients:    make(map[string][]domain.SoilNutrient),
		healthScores: make(map[string]*domain.SoilHealthScore),
	}
}

func (m *mockSoilRepo) CreateSoil(_ context.Context, e *domain.Soil) (*domain.Soil, error) {
	e.ID = "soil-uuid-001"
	m.soils[e.ID] = e
	m.names[e.TenantID+"/"+e.Name] = true
	return e, nil
}

func (m *mockSoilRepo) GetSoilByUUID(_ context.Context, uuid, tenantID string) (*domain.Soil, error) {
	e, ok := m.soils[uuid]
	if !ok || e.TenantID != tenantID {
		return nil, errors.NotFound("SOIL_NOT_FOUND", fmt.Sprintf("soil not found: %s", uuid))
	}
	return e, nil
}

func (m *mockSoilRepo) ListSoils(_ context.Context, params domain.ListSoilParams) ([]domain.Soil, int32, error) {
	var result []domain.Soil
	for _, e := range m.soils {
		if e.TenantID == params.TenantID {
			result = append(result, *e)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockSoilRepo) UpdateSoil(_ context.Context, e *domain.Soil) (*domain.Soil, error) {
	existing, ok := m.soils[e.ID]
	if !ok {
		return nil, errors.NotFound("SOIL_NOT_FOUND", "not found")
	}
	if e.Name != "" {
		existing.Name = e.Name
	}
	existing.UpdatedBy = e.UpdatedBy
	return existing, nil
}

func (m *mockSoilRepo) DeleteSoil(_ context.Context, uuid, tenantID, _ string) error {
	if e, ok := m.soils[uuid]; ok && e.TenantID == tenantID {
		delete(m.soils, uuid)
		return nil
	}
	return errors.NotFound("SOIL_NOT_FOUND", "not found")
}

func (m *mockSoilRepo) CheckSoilExists(_ context.Context, uuid, tenantID string) (bool, error) {
	e, ok := m.soils[uuid]
	return ok && e.TenantID == tenantID, nil
}

func (m *mockSoilRepo) CheckSoilNameExists(_ context.Context, name, tenantID string) (bool, error) {
	return m.names[tenantID+"/"+name], nil
}

func (m *mockSoilRepo) WithTx(_ pgx.Tx) outbound.SoilRepository { return m }

func (m *mockSoilRepo) CreateSoilSample(_ context.Context, s *domain.SoilSample) (*domain.SoilSample, error) {
	if s.ID == "" {
		s.ID = "sample-uuid-001"
	}
	m.samples[s.ID] = s
	return s, nil
}

func (m *mockSoilRepo) GetSoilSampleByUUID(_ context.Context, uuid, tenantID string) (*domain.SoilSample, error) {
	s, ok := m.samples[uuid]
	if !ok || s.TenantID != tenantID {
		return nil, errors.NotFound("SAMPLE_NOT_FOUND", fmt.Sprintf("sample not found: %s", uuid))
	}
	return s, nil
}

func (m *mockSoilRepo) ListSoilSamples(_ context.Context, tenantID, fieldID, _ string, _, _ int32) ([]domain.SoilSample, int64, error) {
	var result []domain.SoilSample
	for _, s := range m.samples {
		if s.TenantID == tenantID && (fieldID == "" || s.FieldID == fieldID) {
			result = append(result, *s)
		}
	}
	return result, int64(len(result)), nil
}

func (m *mockSoilRepo) DeleteSoilSample(_ context.Context, uuid, tenantID string) error {
	if s, ok := m.samples[uuid]; ok && s.TenantID == tenantID {
		delete(m.samples, uuid)
		return nil
	}
	return errors.NotFound("SAMPLE_NOT_FOUND", "not found")
}

func (m *mockSoilRepo) CreateSoilAnalysis(_ context.Context, a *domain.SoilAnalysis) (*domain.SoilAnalysis, error) {
	if a.ID == "" {
		a.ID = "analysis-uuid-001"
	}
	m.analyses[a.ID] = a
	return a, nil
}

func (m *mockSoilRepo) GetSoilAnalysisByUUID(_ context.Context, uuid, tenantID string) (*domain.SoilAnalysis, error) {
	a, ok := m.analyses[uuid]
	if !ok || a.TenantID != tenantID {
		return nil, errors.NotFound("ANALYSIS_NOT_FOUND", "not found")
	}
	return a, nil
}

func (m *mockSoilRepo) ListSoilAnalyses(_ context.Context, tenantID, _, _, _ string, _, _ int32) ([]domain.SoilAnalysis, int64, error) {
	var result []domain.SoilAnalysis
	for _, a := range m.analyses {
		if a.TenantID == tenantID {
			result = append(result, *a)
		}
	}
	return result, int64(len(result)), nil
}

func (m *mockSoilRepo) UpdateSoilAnalysisStatus(_ context.Context, uuid string, status domain.AnalysisStatus) error {
	if a, ok := m.analyses[uuid]; ok {
		a.Status = status
		return nil
	}
	return errors.NotFound("ANALYSIS_NOT_FOUND", "not found")
}

func (m *mockSoilRepo) CreateSoilMap(_ context.Context, sm *domain.SoilMap) (*domain.SoilMap, error) {
	sm.ID = "map-uuid-001"
	m.soilMaps[sm.FieldID+"/"+sm.MapType] = sm
	return sm, nil
}

func (m *mockSoilRepo) GetSoilMapByFieldAndType(_ context.Context, fieldID, tenantID, mapType string) (*domain.SoilMap, error) {
	sm, ok := m.soilMaps[fieldID+"/"+mapType]
	if !ok || sm.TenantID != tenantID {
		return nil, errors.NotFound("SOIL_MAP_NOT_FOUND", "soil map not found")
	}
	return sm, nil
}

func (m *mockSoilRepo) CreateSoilNutrient(_ context.Context, n *domain.SoilNutrient) (*domain.SoilNutrient, error) {
	m.nutrients[n.SampleID] = append(m.nutrients[n.SampleID], *n)
	return n, nil
}

func (m *mockSoilRepo) ListNutrientsBySample(_ context.Context, sampleID, tenantID string) ([]domain.SoilNutrient, error) {
	result := m.nutrients[sampleID]
	var filtered []domain.SoilNutrient
	for _, n := range result {
		if n.TenantID == tenantID {
			filtered = append(filtered, n)
		}
	}
	return filtered, nil
}

func (m *mockSoilRepo) BatchCreateNutrients(_ context.Context, nutrients []domain.SoilNutrient) ([]domain.SoilNutrient, error) {
	for i := range nutrients {
		nutrients[i].ID = fmt.Sprintf("nutrient-%d", i+1)
		m.nutrients[nutrients[i].SampleID] = append(m.nutrients[nutrients[i].SampleID], nutrients[i])
	}
	return nutrients, nil
}

func (m *mockSoilRepo) CreateSoilHealthScore(_ context.Context, s *domain.SoilHealthScore) (*domain.SoilHealthScore, error) {
	if s.ID == "" {
		s.ID = "health-uuid-001"
	}
	m.healthScores[s.FieldID] = s
	return s, nil
}

func (m *mockSoilRepo) GetLatestSoilHealthScore(_ context.Context, fieldID, tenantID string) (*domain.SoilHealthScore, error) {
	h, ok := m.healthScores[fieldID]
	if !ok || h.TenantID != tenantID {
		return nil, errors.NotFound("HEALTH_SCORE_NOT_FOUND", "health score not found")
	}
	return h, nil
}

func (m *mockSoilRepo) UpdateSoilHealthScore(_ context.Context, s *domain.SoilHealthScore) (*domain.SoilHealthScore, error) {
	m.healthScores[s.FieldID] = s
	return s, nil
}

func (m *mockSoilRepo) ListSoilHealthScoresByFarm(_ context.Context, _, _ string, _, _ int32) ([]domain.SoilHealthScore, int64, error) {
	return nil, 0, nil
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

func newService() (*mockSoilRepo, *mockEventPublisher, *soilService) {
	repo := newMockSoilRepo()
	pub := &mockEventPublisher{}
	fieldClient := &mockFieldClient{existing: map[string]bool{"field-001": true}}
	farmClient := &mockFarmClient{existing: map[string]bool{"farm-001": true}}
	svc := NewSoilService(repo, pub, fieldClient, farmClient, nil, nopLogger{})
	return repo, pub, svc
}

func validSoilSample() *domain.SoilSample {
	return &domain.SoilSample{
		TenantID:               "tenant-1",
		FieldID:                "field-001",
		FarmID:                 "farm-001",
		PH:                     6.5,
		MoisturePct:            30.0,
		OrganicMatterPct:       4.0,
		SampleDepthCm:          15.0,
		BulkDensity:            1.2,
		NitrogenPPM:            30.0,
		PhosphorusPPM:          35.0,
		PotassiumPPM:           200.0,
		CalciumPPM:             2000.0,
		MagnesiumPPM:           200.0,
		SulfurPPM:              20.0,
		IronPPM:                10.0,
		ManganesePPM:           3.0,
		ZincPPM:                2.0,
		CopperPPM:              0.5,
		BoronPPM:               1.0,
		CationExchangeCapacity: 20.0,
		Texture:                domain.SoilTextureLoamy,
		Latitude:               12.5,
		Longitude:              77.5,
	}
}

// ---------------------------------------------------------------------------
// Tests: CreateSoil
// ---------------------------------------------------------------------------

func TestCreateSoil_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	entity := &domain.Soil{Name: "Red Soil"}
	created, err := svc.CreateSoil(ctx, entity)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, domain.SoilStatusActive, created.Status)
	assert.Equal(t, "soil-uuid-001", created.ID)
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestCreateSoil_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateSoil(ctx, &domain.Soil{Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateSoil_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateSoil(ctx, &domain.Soil{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_NAME", errors.Reason(err))
}

func TestCreateSoil_DuplicateName(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.names["tenant-1/Existing"] = true

	_, err := svc.CreateSoil(ctx, &domain.Soil{Name: "Existing"})
	require.Error(t, err)
	assert.True(t, errors.IsConflict(err))
	assert.Equal(t, "SOIL_NAME_EXISTS", errors.Reason(err))
}

func TestCreateSoil_DefaultUserSystem(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "")

	created, err := svc.CreateSoil(ctx, &domain.Soil{Name: "X"})
	require.NoError(t, err)
	assert.Equal(t, "system", created.CreatedBy)
}

// ---------------------------------------------------------------------------
// Tests: GetSoil
// ---------------------------------------------------------------------------

func TestGetSoil_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.soils["soil-001"] = &domain.Soil{TenantID: "tenant-1", Name: "Red Soil"}
	repo.soils["soil-001"].ID = "soil-001"

	result, err := svc.GetSoil(ctx, "soil-001")
	require.NoError(t, err)
	assert.Equal(t, "Red Soil", result.Name)
}

func TestGetSoil_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetSoil(ctx, "soil-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSoil_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSoil(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetSoil_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSoil(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListSoils
// ---------------------------------------------------------------------------

func TestListSoils_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.soils["s1"] = &domain.Soil{TenantID: "tenant-1", Name: "A"}
	repo.soils["s1"].ID = "s1"
	repo.soils["s2"] = &domain.Soil{TenantID: "tenant-1", Name: "B"}
	repo.soils["s2"].ID = "s2"

	list, total, err := svc.ListSoils(ctx, domain.ListSoilParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, list, 2)
}

func TestListSoils_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListSoils(ctx, domain.ListSoilParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: UpdateSoil
// ---------------------------------------------------------------------------

func TestUpdateSoil_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.soils["soil-001"] = &domain.Soil{TenantID: "tenant-1", Name: "Old Name"}
	repo.soils["soil-001"].ID = "soil-001"

	entity := &domain.Soil{Name: "New Name"}
	entity.ID = "soil-001"
	updated, err := svc.UpdateSoil(ctx, entity)
	require.NoError(t, err)
	assert.Equal(t, "New Name", updated.Name)
	assert.NotNil(t, updated.UpdatedBy)
	assert.Equal(t, "user-1", *updated.UpdatedBy)
	assert.Len(t, pub.published, 1)
}

func TestUpdateSoil_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	entity := &domain.Soil{Name: "X"}
	entity.ID = "soil-001"
	_, err := svc.UpdateSoil(ctx, entity)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestUpdateSoil_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateSoil(ctx, &domain.Soil{Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestUpdateSoil_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	entity := &domain.Soil{Name: "X"}
	entity.ID = "nonexistent"
	_, err := svc.UpdateSoil(ctx, entity)
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: DeleteSoil
// ---------------------------------------------------------------------------

func TestDeleteSoil_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.soils["soil-001"] = &domain.Soil{TenantID: "tenant-1", Name: "X"}
	repo.soils["soil-001"].ID = "soil-001"

	err := svc.DeleteSoil(ctx, "soil-001")
	require.NoError(t, err)
	assert.Len(t, pub.published, 1)
}

func TestDeleteSoil_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	err := svc.DeleteSoil(ctx, "soil-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestDeleteSoil_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.DeleteSoil(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestDeleteSoil_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.DeleteSoil(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: CreateSoilSample
// ---------------------------------------------------------------------------

func TestCreateSoilSample_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	created, err := svc.CreateSoilSample(ctx, sample)
	require.NoError(t, err)
	assert.NotEmpty(t, created.ID)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Equal(t, int64(1), created.Version)
	assert.True(t, created.IsActive)
	assert.Len(t, pub.published, 1)
}

func TestCreateSoilSample_MissingTenantID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	sample := validSoilSample()
	sample.TenantID = "" // Context also has no tenant.
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.FieldID = ""
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_MissingFarmID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.FarmID = ""
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_InvalidPH(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.PH = 15.0
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_InvalidMoisture(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.MoisturePct = -1.0
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_InvalidOrganicMatter(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.OrganicMatterPct = 101.0
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_InvalidDepth(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.SampleDepthCm = -1.0
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_InvalidBulkDensity(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.BulkDensity = -0.5
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_InvalidLatitude(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.Latitude = 91.0
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestCreateSoilSample_InvalidLongitude(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.Longitude = -181.0
	_, err := svc.CreateSoilSample(ctx, sample)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetSoilSample
// ---------------------------------------------------------------------------

func TestGetSoilSample_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.samples["sample-001"] = &domain.SoilSample{
		TenantID: "tenant-1",
		FieldID:  "field-001",
	}
	repo.samples["sample-001"].ID = "sample-001"

	result, err := svc.GetSoilSample(ctx, "sample-001", "")
	require.NoError(t, err)
	assert.Equal(t, "field-001", result.FieldID)
}

func TestGetSoilSample_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSoilSample(ctx, "", "tenant-1")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSoilSample_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.GetSoilSample(ctx, "sample-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSoilSample_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSoilSample(ctx, "nonexistent", "")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListSoilSamples
// ---------------------------------------------------------------------------

func TestListSoilSamples_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, _, err := svc.ListSoilSamples(ctx, "", "", "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListSoilSamples_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.samples["s1"] = &domain.SoilSample{TenantID: "tenant-1", FieldID: "f1"}
	repo.samples["s1"].ID = "s1"

	samples, total, err := svc.ListSoilSamples(ctx, "", "", "", 20, 0)
	require.NoError(t, err)
	assert.Equal(t, int64(1), total)
	assert.Len(t, samples, 1)
}

// ---------------------------------------------------------------------------
// Tests: AnalyzeSoil
// ---------------------------------------------------------------------------

func TestAnalyzeSoil_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.ID = "sample-001"
	repo.samples["sample-001"] = sample

	analysis, err := svc.AnalyzeSoil(ctx, "sample-001", "", "STANDARD")
	require.NoError(t, err)
	assert.NotEmpty(t, analysis.ID)
	assert.Equal(t, "tenant-1", analysis.TenantID)
	assert.Equal(t, "sample-001", analysis.SampleID)
	assert.Equal(t, domain.AnalysisStatusCompleted, analysis.Status)
	assert.Greater(t, analysis.SoilHealthScore, 0.0)
	assert.NotEmpty(t, analysis.HealthCategory)
	assert.NotEmpty(t, analysis.Summary)
	// At least two events: analysis + possibly deficiencies.
	assert.GreaterOrEqual(t, len(pub.published), 1)
}

func TestAnalyzeSoil_MissingSampleID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AnalyzeSoil(ctx, "", "", "STANDARD")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestAnalyzeSoil_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.AnalyzeSoil(ctx, "sample-001", "", "STANDARD")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestAnalyzeSoil_SampleNotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AnalyzeSoil(ctx, "nonexistent", "", "")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

func TestAnalyzeSoil_DefaultAnalysisType(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.ID = "sample-001"
	repo.samples["sample-001"] = sample

	analysis, err := svc.AnalyzeSoil(ctx, "sample-001", "", "")
	require.NoError(t, err)
	assert.Equal(t, "STANDARD", analysis.AnalysisType)
}

// ---------------------------------------------------------------------------
// Tests: ListSoilAnalyses
// ---------------------------------------------------------------------------

func TestListSoilAnalyses_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, _, err := svc.ListSoilAnalyses(ctx, "", "", "", "", 20, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetSoilMap
// ---------------------------------------------------------------------------

func TestGetSoilMap_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.soilMaps["field-001/nutrient"] = &domain.SoilMap{
		TenantID: "tenant-1",
		FieldID:  "field-001",
		MapType:  "nutrient",
	}

	result, err := svc.GetSoilMap(ctx, "field-001", "", "nutrient")
	require.NoError(t, err)
	assert.Equal(t, "nutrient", result.MapType)
}

func TestGetSoilMap_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSoilMap(ctx, "", "", "nutrient")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSoilMap_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.GetSoilMap(ctx, "field-001", "", "nutrient")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSoilMap_DefaultMapType(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.soilMaps["field-001/nutrient"] = &domain.SoilMap{
		TenantID: "tenant-1",
		FieldID:  "field-001",
		MapType:  "nutrient",
	}

	result, err := svc.GetSoilMap(ctx, "field-001", "", "") // Empty mapType defaults to "nutrient".
	require.NoError(t, err)
	assert.Equal(t, "nutrient", result.MapType)
}

// ---------------------------------------------------------------------------
// Tests: GetSoilHealth
// ---------------------------------------------------------------------------

func TestGetSoilHealth_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.healthScores["field-001"] = &domain.SoilHealthScore{
		TenantID:     "tenant-1",
		FieldID:      "field-001",
		OverallScore: 82.0,
	}

	result, err := svc.GetSoilHealth(ctx, "field-001", "")
	require.NoError(t, err)
	assert.Equal(t, 82.0, result.OverallScore)
}

func TestGetSoilHealth_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSoilHealth(ctx, "", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSoilHealth_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.GetSoilHealth(ctx, "field-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetSoilHealth_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetSoilHealth(ctx, "nonexistent-field", "")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: GetNutrientLevels
// ---------------------------------------------------------------------------

func TestGetNutrientLevels_MissingSampleID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetNutrientLevels(ctx, "", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGetNutrientLevels_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.GetNutrientLevels(ctx, "sample-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GenerateSoilReport
// ---------------------------------------------------------------------------

func TestGenerateSoilReport_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	sample := validSoilSample()
	sample.ID = "sample-001"
	repo.samples["sample-001"] = sample

	report, err := svc.GenerateSoilReport(ctx, "field-001", "", "farm-001")
	require.NoError(t, err)
	assert.NotNil(t, report.Sample)
	assert.NotEmpty(t, report.Recommendations)
	assert.False(t, report.GeneratedAt.IsZero())
}

func TestGenerateSoilReport_MissingFieldID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GenerateSoilReport(ctx, "", "", "farm-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGenerateSoilReport_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.GenerateSoilReport(ctx, "field-001", "", "farm-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestGenerateSoilReport_NoSamples(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GenerateSoilReport(ctx, "field-001", "", "farm-001")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
	assert.Equal(t, "NO_SAMPLES_FOUND", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: Soil Health Computation (pure functions)
// ---------------------------------------------------------------------------

func TestComputeSoilHealthScore_OptimalSample(t *testing.T) {
	sample := validSoilSample()
	score := computeSoilHealthScore(sample)
	assert.Greater(t, score, 50.0)
	assert.LessOrEqual(t, score, 100.0)
}

func TestClassifyHealthCategory(t *testing.T) {
	assert.Equal(t, domain.HealthCategoryExcellent, classifyHealthCategory(90))
	assert.Equal(t, domain.HealthCategoryGood, classifyHealthCategory(75))
	assert.Equal(t, domain.HealthCategoryFair, classifyHealthCategory(55))
	assert.Equal(t, domain.HealthCategoryPoor, classifyHealthCategory(35))
	assert.Equal(t, domain.HealthCategoryCritical, classifyHealthCategory(20))
}

func TestComputePHScore_Optimal(t *testing.T) {
	score := computePHScore(6.5)
	assert.Equal(t, 100.0, score)
}

func TestComputePHScore_Low(t *testing.T) {
	score := computePHScore(4.0)
	assert.Greater(t, score, 0.0)
	assert.Less(t, score, 60.0)
}

func TestComputeOrganicMatterScore_High(t *testing.T) {
	score := computeOrganicMatterScore(6.0)
	assert.Equal(t, 100.0, score)
}

func TestComputeOrganicMatterScore_Low(t *testing.T) {
	score := computeOrganicMatterScore(0.5)
	assert.Greater(t, score, 0.0)
	assert.Less(t, score, 30.0)
}

func TestDetectNutrientDeficiencies_NoDeficiencies(t *testing.T) {
	sample := validSoilSample()
	defs := detectNutrientDeficiencies(sample)
	assert.Empty(t, defs)
}

func TestDetectNutrientDeficiencies_LowNitrogen(t *testing.T) {
	sample := validSoilSample()
	sample.NitrogenPPM = 5.0
	defs := detectNutrientDeficiencies(sample)
	assert.NotEmpty(t, defs)
	found := false
	for _, d := range defs {
		if d.NutrientName == "Nitrogen" {
			found = true
			assert.Equal(t, domain.NutrientLevelDeficient, d.Level)
		}
	}
	assert.True(t, found, "expected Nitrogen deficiency")
}

func TestGenerateRecommendations_OptimalSoil(t *testing.T) {
	sample := validSoilSample()
	recs := generateRecommendations(sample, 85.0)
	assert.Len(t, recs, 1)
	assert.Contains(t, recs[0], "optimal ranges")
}

func TestGenerateRecommendations_LowPH(t *testing.T) {
	sample := validSoilSample()
	sample.PH = 4.5
	recs := generateRecommendations(sample, 50.0)
	found := false
	for _, r := range recs {
		if r == "Apply agricultural lime to raise soil pH to the optimal 6.0-7.0 range" {
			found = true
		}
	}
	assert.True(t, found, "expected lime recommendation for low pH")
}
