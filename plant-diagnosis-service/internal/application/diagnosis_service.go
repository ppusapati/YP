// Package application contains the plant-diagnosis-service application service.
package application

import (
	"context"
	"encoding/json"

	"github.com/jackc/pgx/v5/pgxpool"

	"p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9context"
	"p9e.in/samavaya/packages/p9log"
	"p9e.in/samavaya/packages/ulid"

	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/domain"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/inbound"
	"p9e.in/samavaya/agriculture/plant-diagnosis-service/internal/ports/outbound"
)

const (
	serviceName           = "plant-diagnosis-service"
	eventTopic            = "samavaya.agriculture.plant-diagnosis.events"
	maxPageSize     int32 = 100
	defaultPageSize       = int32(20)

	placeholderModelVersion = "v0.1.0-placeholder"
)

type diagnosisService struct {
	repo        outbound.DiagnosisRepository
	pub         outbound.EventPublisher
	fieldClient outbound.FieldClient
	pool        *pgxpool.Pool
	log         *p9log.Helper
}

// NewDiagnosisService creates a new application-layer DiagnosisService.
func NewDiagnosisService(
	repo outbound.DiagnosisRepository,
	pub outbound.EventPublisher,
	fieldClient outbound.FieldClient,
	pool *pgxpool.Pool,
	log p9log.Logger,
) inbound.DiagnosisService {
	return &diagnosisService{
		repo:        repo,
		pub:         pub,
		fieldClient: fieldClient,
		pool:        pool,
		log:         p9log.NewHelper(p9log.With(log, "component", "DiagnosisService")),
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// SubmitDiagnosis
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) SubmitDiagnosis(ctx context.Context, req *domain.DiagnosisRequest) (*domain.DiagnosisRequest, error) {
	tenantID := p9context.TenantID(ctx)
	userID := p9context.UserID(ctx)

	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if req.FarmID == "" {
		return nil, errors.BadRequest("INVALID_FARM_ID", "farm_id is required")
	}
	if userID == "" {
		userID = "system"
	}

	req.TenantID = tenantID
	req.CreatedBy = userID
	req.Status = domain.DiagnosisStatusPending
	req.Version = 1

	created, err := s.repo.CreateDiagnosisRequest(ctx, req)
	if err != nil {
		return nil, err
	}

	s.emitEvent(ctx, "agriculture.plant-diagnosis.created", created.ID, map[string]interface{}{
		"plant_diagnosis_id": created.ID, "tenant_id": tenantID,
	})
	s.log.Infow("msg", "diagnosis submitted", "id", created.ID)
	return created, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// GetDiagnosis
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) GetDiagnosis(ctx context.Context, id string) (*domain.DiagnosisRequest, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "diagnosis ID is required")
	}

	diag, err := s.repo.GetDiagnosisRequestByID(ctx, id, tenantID)
	if err != nil {
		return nil, err
	}

	// Attempt to join the result.
	result, err := s.repo.GetDiagnosisResultByRequestID(ctx, id, tenantID)
	if err != nil {
		s.log.Errorw("msg", "failed to fetch diagnosis result", "diagnosis_id", id, "error", err)
	}
	if result != nil {
		diag.Result = result
	}

	return diag, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// ListDiagnoses
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) ListDiagnoses(ctx context.Context, params domain.ListDiagnosesParams) ([]domain.DiagnosisRequest, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListDiagnosisRequests(ctx, params)
}

// ─────────────────────────────────────────────────────────────────────────────
// GetDiseaseInfo
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) GetDiseaseInfo(ctx context.Context, id string) (*domain.DiseaseInfo, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if id == "" {
		return nil, errors.BadRequest("MISSING_ID", "disease ID is required")
	}
	return s.repo.GetDiseaseByID(ctx, id, tenantID)
}

// ─────────────────────────────────────────────────────────────────────────────
// ListDiseases
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) ListDiseases(ctx context.Context, params domain.ListDiseasesParams) ([]domain.DiseaseInfo, int32, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, 0, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	params.TenantID = tenantID

	if params.PageSize <= 0 {
		params.PageSize = defaultPageSize
	}
	if params.PageSize > maxPageSize {
		params.PageSize = maxPageSize
	}

	return s.repo.ListDiseases(ctx, params)
}

// ─────────────────────────────────────────────────────────────────────────────
// GetTreatmentPlan
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) GetTreatmentPlan(ctx context.Context, diagnosisID string) (*domain.TreatmentPlan, error) {
	tenantID := p9context.TenantID(ctx)
	if tenantID == "" {
		return nil, errors.BadRequest("MISSING_TENANT", "tenant ID is required")
	}
	if diagnosisID == "" {
		return nil, errors.BadRequest("MISSING_ID", "diagnosis_id is required")
	}

	// Verify the diagnosis exists.
	_, err := s.repo.GetDiagnosisRequestByID(ctx, diagnosisID, tenantID)
	if err != nil {
		return nil, err
	}

	// Check for existing plan.
	plan, err := s.repo.GetTreatmentPlanByDiagnosisID(ctx, diagnosisID, tenantID)
	if err != nil {
		return nil, err
	}
	if plan != nil {
		return plan, nil
	}

	// Generate a synthetic placeholder plan.
	syntheticPlan := s.generateSyntheticTreatmentPlan(tenantID, diagnosisID)
	created, err := s.repo.CreateTreatmentPlan(ctx, syntheticPlan)
	if err != nil {
		return nil, err
	}
	return created, nil
}

func (s *diagnosisService) generateSyntheticTreatmentPlan(tenantID, diagnosisID string) *domain.TreatmentPlan {
	steps := []domain.TreatmentStep{
		{StepNumber: 1, Action: "Inspect affected plants closely", Notes: "Document visual symptoms", DurationDays: 1},
		{StepNumber: 2, Action: "Apply recommended treatment", Product: "Pending analysis", Frequency: "As directed", DurationDays: 7},
		{StepNumber: 3, Action: "Monitor progress and re-evaluate", Notes: "Reassess after treatment period", DurationDays: 14},
	}
	stepsJSON, _ := json.Marshal(steps)
	desc := "Auto-generated treatment plan pending full AI analysis"
	cost := "TBD"
	days := int32(22)

	return &domain.TreatmentPlan{
		TenantID:      tenantID,
		DiagnosisID:   diagnosisID,
		Title:         "Preliminary Treatment Plan",
		Description:   &desc,
		Priority:      string(domain.SeverityUnspecified),
		Steps:         stepsJSON,
		EstimatedCost: &cost,
		EstimatedDays: &days,
	}
}

// ─────────────────────────────────────────────────────────────────────────────
// IdentifySpecies (synthetic placeholder)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) IdentifySpecies(_ context.Context, _ []domain.DiagnosisImage) ([]domain.PlantSpecies, error) {
	return []domain.PlantSpecies{
		{
			ID:             ulid.NewString(),
			CommonName:     "Unknown",
			ScientificName: "Analysis pending",
			Family:         "",
			Confidence:     0.0,
		},
	}, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// DetectNutrientDeficiency (synthetic placeholder)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) DetectNutrientDeficiency(_ context.Context, _ string, _ []domain.DiagnosisImage) ([]domain.NutrientDeficiency, error) {
	return []domain.NutrientDeficiency{
		{
			Nutrient:        "Nitrogen",
			ConfidenceScore: 0.5,
			Severity:        domain.SeverityModerate,
			Description:     "Possible nitrogen deficiency detected",
		},
	}, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// DetectPestDamage (synthetic placeholder)
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) DetectPestDamage(_ context.Context, _ string, _ []domain.DiagnosisImage) ([]domain.PestDamage, error) {
	return []domain.PestDamage{
		{
			PestID:          ulid.NewString(),
			PestName:        "Analysis pending",
			ConfidenceScore: 0.0,
			DamageLevel:     domain.SeverityUnspecified,
		},
	}, nil
}

// ─────────────────────────────────────────────────────────────────────────────
// Event publishing
// ─────────────────────────────────────────────────────────────────────────────

func (s *diagnosisService) emitEvent(ctx context.Context, eventType, aggregateID string, data map[string]interface{}) {
	if s.pub == nil {
		return
	}
	payload := map[string]interface{}{
		"id":             ulid.NewString(),
		"type":           eventType,
		"aggregate_id":   aggregateID,
		"source":         serviceName,
		"correlation_id": p9context.RequestID(ctx),
		"data":           data,
	}
	raw, err := json.Marshal(payload)
	if err != nil {
		s.log.Errorw("msg", "failed to marshal event", "error", err)
		return
	}
	if err := s.pub.Publish(ctx, eventTopic, aggregateID, raw); err != nil {
		s.log.Errorw("msg", "failed to publish event", "event_type", eventType, "error", err)
	}
}
