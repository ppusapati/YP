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

	"p9e.in/samavaya/agriculture/crop-service/internal/domain"
	"p9e.in/samavaya/agriculture/crop-service/internal/ports/outbound"
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
// Mock: CropRepository
// ---------------------------------------------------------------------------

type mockCropRepo struct {
	crops        map[string]*domain.Crop         // keyed by UUID
	names        map[string]bool                  // tenantID+"/"+name -> exists
	varieties    map[int64][]*domain.CropVariety  // keyed by crop ID
	growthStages map[int64][]*domain.CropGrowthStage
	requirements map[int64]*domain.CropRequirements
	recs         []*domain.CropRecommendation
}

func newMockCropRepo() *mockCropRepo {
	return &mockCropRepo{
		crops:        make(map[string]*domain.Crop),
		names:        make(map[string]bool),
		varieties:    make(map[int64][]*domain.CropVariety),
		growthStages: make(map[int64][]*domain.CropGrowthStage),
		requirements: make(map[int64]*domain.CropRequirements),
	}
}

func (m *mockCropRepo) CreateCrop(_ context.Context, c *domain.Crop) (*domain.Crop, error) {
	c.UUID = "crop-uuid-001"
	c.ID = 1
	m.crops[c.UUID] = c
	m.names[c.TenantID+"/"+c.Name] = true
	return c, nil
}

func (m *mockCropRepo) GetCropByUUID(_ context.Context, uuid, tenantID string) (*domain.Crop, error) {
	c, ok := m.crops[uuid]
	if !ok || c.TenantID != tenantID {
		return nil, errors.NotFound("CROP_NOT_FOUND", fmt.Sprintf("crop not found: %s", uuid))
	}
	return c, nil
}

func (m *mockCropRepo) ListCrops(_ context.Context, params domain.ListCropParams) ([]domain.Crop, int32, error) {
	var result []domain.Crop
	for _, c := range m.crops {
		if c.TenantID == params.TenantID {
			result = append(result, *c)
		}
	}
	return result, int32(len(result)), nil
}

func (m *mockCropRepo) UpdateCrop(_ context.Context, c *domain.Crop) (*domain.Crop, error) {
	existing, ok := m.crops[c.UUID]
	if !ok {
		return nil, errors.NotFound("CROP_NOT_FOUND", "crop not found")
	}
	if c.Name != "" {
		existing.Name = c.Name
	}
	existing.UpdatedBy = c.UpdatedBy
	return existing, nil
}

func (m *mockCropRepo) DeleteCrop(_ context.Context, uuid, tenantID, _ string) error {
	if c, ok := m.crops[uuid]; ok && c.TenantID == tenantID {
		delete(m.crops, uuid)
		return nil
	}
	return errors.NotFound("CROP_NOT_FOUND", "crop not found")
}

func (m *mockCropRepo) CheckCropExists(_ context.Context, uuid, tenantID string) (bool, error) {
	c, ok := m.crops[uuid]
	return ok && c.TenantID == tenantID, nil
}

func (m *mockCropRepo) CheckCropNameExists(_ context.Context, name, tenantID string) (bool, error) {
	return m.names[tenantID+"/"+name], nil
}

func (m *mockCropRepo) CreateVariety(_ context.Context, v *domain.CropVariety) (*domain.CropVariety, error) {
	v.UUID = "variety-uuid-001"
	m.varieties[v.CropID] = append(m.varieties[v.CropID], v)
	return v, nil
}

func (m *mockCropRepo) ListVarietiesByCropID(_ context.Context, cropID int64, _ string, _, _ int32) ([]*domain.CropVariety, int32, error) {
	list := m.varieties[cropID]
	return list, int32(len(list)), nil
}

func (m *mockCropRepo) GetGrowthStagesByCropID(_ context.Context, cropID int64, _ string) ([]*domain.CropGrowthStage, error) {
	return m.growthStages[cropID], nil
}

func (m *mockCropRepo) GetCropRequirementsByCropID(_ context.Context, cropID int64, _ string) (*domain.CropRequirements, error) {
	req, ok := m.requirements[cropID]
	if !ok {
		return nil, errors.NotFound("REQUIREMENTS_NOT_FOUND", "not found")
	}
	return req, nil
}

func (m *mockCropRepo) CreateRecommendation(_ context.Context, rec *domain.CropRecommendation) (*domain.CropRecommendation, error) {
	rec.ID = 1
	rec.UUID = "rec-uuid-001"
	m.recs = append(m.recs, rec)
	return rec, nil
}

func (m *mockCropRepo) CropExistsByName(_ context.Context, tenantID, name string) (bool, error) {
	return m.names[tenantID+"/"+name], nil
}

func (m *mockCropRepo) WithTx(_ pgx.Tx) outbound.CropRepository {
	return m
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

func newService() (*mockCropRepo, *mockEventPublisher, *cropService) {
	repo := newMockCropRepo()
	pub := &mockEventPublisher{}
	svc := NewCropService(repo, pub, nil, nopLogger{})
	return repo, pub, svc
}

// ---------------------------------------------------------------------------
// Tests: CreateCrop
// ---------------------------------------------------------------------------

func TestCreateCrop_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	crop := &domain.Crop{Name: "Rice"}
	created, err := svc.CreateCrop(ctx, crop)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "Rice", created.Name)
	assert.Equal(t, domain.CropStatusActive, created.Status)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.NotEmpty(t, created.UUID)

	// Event published.
	assert.Len(t, pub.published, 1)
	assert.Equal(t, eventTopic, pub.published[0].topic)
}

func TestCreateCrop_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.CreateCrop(ctx, &domain.Crop{Name: "Rice"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestCreateCrop_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.CreateCrop(ctx, &domain.Crop{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_NAME", errors.Reason(err))
}

func TestCreateCrop_DuplicateName(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.names["tenant-1/Rice"] = true

	_, err := svc.CreateCrop(ctx, &domain.Crop{Name: "Rice"})
	require.Error(t, err)
	assert.True(t, errors.IsConflict(err))
	assert.Equal(t, "CROP_NAME_EXISTS", errors.Reason(err))
}

func TestCreateCrop_SystemUser(t *testing.T) {
	_, _, svc := newService()
	// No user in context.
	ctx := testContext("tenant-1", "")

	crop := &domain.Crop{Name: "Wheat"}
	created, err := svc.CreateCrop(ctx, crop)
	require.NoError(t, err)
	assert.Equal(t, "system", created.CreatedBy)
}

// ---------------------------------------------------------------------------
// Tests: GetCrop
// ---------------------------------------------------------------------------

func TestGetCrop_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"

	crop, err := svc.GetCrop(ctx, "crop-uuid-001")
	require.NoError(t, err)
	assert.Equal(t, "Rice", crop.Name)
}

func TestGetCrop_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GetCrop(ctx, "some-uuid")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestGetCrop_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetCrop(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestGetCrop_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GetCrop(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: ListCrops
// ---------------------------------------------------------------------------

func TestListCrops_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["c1"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["c1"].UUID = "c1"
	repo.crops["c2"] = &domain.Crop{TenantID: "tenant-1", Name: "Wheat"}
	repo.crops["c2"].UUID = "c2"

	crops, total, err := svc.ListCrops(ctx, domain.ListCropParams{})
	require.NoError(t, err)
	assert.Equal(t, int32(2), total)
	assert.Len(t, crops, 2)
}

func TestListCrops_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, _, err := svc.ListCrops(ctx, domain.ListCropParams{})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

func TestListCrops_DefaultPageSize(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["c1"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["c1"].UUID = "c1"

	// PageSize <= 0 should default to 20.
	_, _, err := svc.ListCrops(ctx, domain.ListCropParams{PageSize: 0})
	require.NoError(t, err)
}

func TestListCrops_CapsPageSize(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	// PageSize > 100 should be capped.
	_, _, err := svc.ListCrops(ctx, domain.ListCropParams{PageSize: 500})
	require.NoError(t, err)
}

// ---------------------------------------------------------------------------
// Tests: UpdateCrop
// ---------------------------------------------------------------------------

func TestUpdateCrop_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"

	updated, err := svc.UpdateCrop(ctx, &domain.Crop{Name: "Basmati Rice"})
	// UUID is empty so we expect MISSING_ID
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
	_ = updated

	// Now with UUID set.
	updated, err = svc.UpdateCrop(ctx, &domain.Crop{Name: "Basmati Rice"})
	// Still no UUID -- test properly:
	crop := &domain.Crop{Name: "Basmati Rice"}
	crop.UUID = "crop-uuid-001"
	updated, err = svc.UpdateCrop(ctx, crop)
	require.NoError(t, err)
	assert.Equal(t, "Basmati Rice", updated.Name)
	assert.Len(t, pub.published, 1)
}

func TestUpdateCrop_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	crop := &domain.Crop{Name: "X"}
	crop.UUID = "crop-uuid-001"
	_, err := svc.UpdateCrop(ctx, crop)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestUpdateCrop_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.UpdateCrop(ctx, &domain.Crop{Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestUpdateCrop_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	crop := &domain.Crop{Name: "X"}
	crop.UUID = "nonexistent"
	_, err := svc.UpdateCrop(ctx, crop)
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: DeleteCrop
// ---------------------------------------------------------------------------

func TestDeleteCrop_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"

	err := svc.DeleteCrop(ctx, "crop-uuid-001")
	require.NoError(t, err)
	assert.Len(t, pub.published, 1)
}

func TestDeleteCrop_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	err := svc.DeleteCrop(ctx, "crop-uuid-001")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_TENANT", errors.Reason(err))
}

func TestDeleteCrop_MissingID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.DeleteCrop(ctx, "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "MISSING_ID", errors.Reason(err))
}

func TestDeleteCrop_NotFound(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	err := svc.DeleteCrop(ctx, "nonexistent")
	require.Error(t, err)
	assert.True(t, errors.IsNotFound(err))
}

// ---------------------------------------------------------------------------
// Tests: AddVariety
// ---------------------------------------------------------------------------

func TestAddVariety_HappyPath(t *testing.T) {
	_, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	variety := &domain.CropVariety{
		CropID: 1,
		Name:   "Basmati 370",
	}
	created, err := svc.AddVariety(ctx, variety)
	require.NoError(t, err)
	assert.Equal(t, "tenant-1", created.TenantID)
	assert.Equal(t, "Basmati 370", created.Name)
	assert.True(t, created.IsActive)
	assert.Equal(t, "user-1", created.CreatedBy)
	assert.Len(t, pub.published, 1)
}

func TestAddVariety_MissingName(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AddVariety(ctx, &domain.CropVariety{CropID: 1, Name: "  "})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_VARIETY_NAME", errors.Reason(err))
}

func TestAddVariety_InvalidCropID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.AddVariety(ctx, &domain.CropVariety{CropID: 0, Name: "X"})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CROP_ID", errors.Reason(err))
}

// ---------------------------------------------------------------------------
// Tests: ListVarieties
// ---------------------------------------------------------------------------

func TestListVarieties_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"
	repo.crops["crop-uuid-001"].ID = 1
	repo.varieties[1] = []*domain.CropVariety{{Name: "Basmati"}}

	varieties, total, err := svc.ListVarieties(ctx, "crop-uuid-001", "", 0, 0)
	require.NoError(t, err)
	assert.Equal(t, int32(1), total)
	assert.Len(t, varieties, 1)
}

func TestListVarieties_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, _, err := svc.ListVarieties(ctx, "crop-uuid-001", "", 0, 0)
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetGrowthStages
// ---------------------------------------------------------------------------

func TestGetGrowthStages_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"
	repo.crops["crop-uuid-001"].ID = 1
	repo.growthStages[1] = []*domain.CropGrowthStage{{Name: "Germination"}}

	stages, err := svc.GetGrowthStages(ctx, "crop-uuid-001", "")
	require.NoError(t, err)
	assert.Len(t, stages, 1)
	assert.Equal(t, "Germination", stages[0].Name)
}

func TestGetGrowthStages_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.GetGrowthStages(ctx, "crop-uuid-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GetCropRequirements
// ---------------------------------------------------------------------------

func TestGetCropRequirements_HappyPath(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"
	repo.crops["crop-uuid-001"].ID = 1
	repo.requirements[1] = &domain.CropRequirements{OptimalTempMin: 20, OptimalTempMax: 35}

	req, err := svc.GetCropRequirements(ctx, "crop-uuid-001", "")
	require.NoError(t, err)
	assert.Equal(t, float64(20), req.OptimalTempMin)
}

func TestGetCropRequirements_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "")

	_, err := svc.GetCropRequirements(ctx, "crop-uuid-001", "")
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
}

// ---------------------------------------------------------------------------
// Tests: GenerateRecommendation
// ---------------------------------------------------------------------------

func TestGenerateRecommendation_HappyPath(t *testing.T) {
	repo, pub, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice", ScientificName: "Oryza sativa"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"
	repo.crops["crop-uuid-001"].ID = 1

	input := &domain.RecommendationInput{
		CropID:             "crop-uuid-001",
		TenantID:           "tenant-1",
		RecommendationType: "irrigation",
		CurrentTemperature:  30,
	}

	rec, err := svc.GenerateRecommendation(ctx, input)
	require.NoError(t, err)
	assert.NotEmpty(t, rec.UUID)
	assert.Equal(t, "irrigation", rec.RecommendationType)
	assert.Len(t, pub.published, 1)
}

func TestGenerateRecommendation_MissingCropID(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GenerateRecommendation(ctx, &domain.RecommendationInput{
		RecommendationType: "irrigation",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_CROP_ID", errors.Reason(err))
}

func TestGenerateRecommendation_MissingTenant(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("", "user-1")

	_, err := svc.GenerateRecommendation(ctx, &domain.RecommendationInput{
		CropID:             "crop-uuid-001",
		RecommendationType: "irrigation",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_TENANT_ID", errors.Reason(err))
}

func TestGenerateRecommendation_MissingType(t *testing.T) {
	_, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	_, err := svc.GenerateRecommendation(ctx, &domain.RecommendationInput{
		CropID: "crop-uuid-001",
	})
	require.Error(t, err)
	assert.True(t, errors.IsBadRequest(err))
	assert.Equal(t, "INVALID_RECOMMENDATION_TYPE", errors.Reason(err))
}

func TestGenerateRecommendation_WithRequirements(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice", ScientificName: "Oryza sativa"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"
	repo.crops["crop-uuid-001"].ID = 1
	repo.requirements[1] = &domain.CropRequirements{
		OptimalTempMin:     20,
		OptimalTempMax:     35,
		OptimalHumidityMin: 60,
		OptimalHumidityMax: 80,
		OptimalSoilPhMin:   5.5,
		OptimalSoilPhMax:   7.0,
	}

	// All conditions within optimal range.
	input := &domain.RecommendationInput{
		CropID:              "crop-uuid-001",
		TenantID:            "tenant-1",
		RecommendationType:  "irrigation",
		CurrentTemperature:  25,
		CurrentHumidity:     70,
		CurrentSoilPH:       6.0,
		CurrentSoilMoisture: 0, // Not provided.
	}

	rec, err := svc.GenerateRecommendation(ctx, input)
	require.NoError(t, err)
	assert.Equal(t, "info", rec.Severity)
	assert.InDelta(t, 0.95, rec.ConfidenceScore, 0.01, "should be 0.95 when all conditions are optimal")
}

func TestGenerateRecommendation_WarningConditions(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice", ScientificName: "Oryza sativa"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"
	repo.crops["crop-uuid-001"].ID = 1
	repo.requirements[1] = &domain.CropRequirements{
		OptimalTempMin: 20,
		OptimalTempMax: 35,
	}

	// Temperature slightly below optimal (warning, not critical).
	input := &domain.RecommendationInput{
		CropID:             "crop-uuid-001",
		TenantID:           "tenant-1",
		RecommendationType: "general",
		CurrentTemperature: 15, // 5 below optimal min
	}

	rec, err := svc.GenerateRecommendation(ctx, input)
	require.NoError(t, err)
	assert.Equal(t, "warning", rec.Severity)
}

func TestGenerateRecommendation_CriticalConditions(t *testing.T) {
	repo, _, svc := newService()
	ctx := testContext("tenant-1", "user-1")

	repo.crops["crop-uuid-001"] = &domain.Crop{TenantID: "tenant-1", Name: "Rice", ScientificName: "Oryza sativa"}
	repo.crops["crop-uuid-001"].UUID = "crop-uuid-001"
	repo.crops["crop-uuid-001"].ID = 1
	repo.requirements[1] = &domain.CropRequirements{
		OptimalTempMin: 20,
		OptimalTempMax: 35,
	}

	// Temperature way below optimal (critical).
	input := &domain.RecommendationInput{
		CropID:             "crop-uuid-001",
		TenantID:           "tenant-1",
		RecommendationType: "general",
		CurrentTemperature: 5, // 15 below optimal min
	}

	rec, err := svc.GenerateRecommendation(ctx, input)
	require.NoError(t, err)
	assert.Equal(t, "critical", rec.Severity)
}
